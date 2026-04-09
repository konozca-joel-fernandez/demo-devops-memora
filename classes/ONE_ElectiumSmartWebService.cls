@RestResource(UrlMapping='/electium-smart') // Name of the endpoint
global with sharing class ONE_ElectiumSmartWebService {
    @TestVisible
    private static final String CORRECT_MESSAGE = 'Contrato creado correctamente';
    private static final String CLASS_NAME = 'ONE_ElectiumWebService';
    private static final String ENDPOINT_NAME = 'ELECTIUM_SMART';
    private List<ElementoWrapper> elementoWrappers;
    private Map<String, ElementoWrapper> codigoPreventivaToElementoWrapper;
    private Map<String, ElementoWrapper> documentNumberToElementoWrapper;
    private Set<String> accountDocumentNumbers;
    private Set<String> codigoPreventivas;
    private List<Account> existingAccounts;
    private List<ONE_Contrato__c> existingContratos;
    public Map<Account, ElementoWrapper> beneficiarioToElementoWrapper;
    private Map<Integer, List<Integer>> contratoTempId2DocumentTempIds;
    private Map<Integer, ONE_Contrato__c> contratoTempId2Contrato;
    private Map<Integer, ContentVersion> documentTempId2ContentVersion;
    private Integer tempIdIndex = 0;

    private static Map<String, Account> documentNumber2Account;

    private ONE_ElectiumSmartWebService(List<Elemento> elementos) {
        initiate(elementos);
    }

    @HttpPost
    global static void createData() {
        try {
            Blob request = RestContext.request.requestBody; // Get encodend body 
            if (request == null) { // If the request is empty return error
                throw new ONE_ElectiumSmartWebServiceException('No request body');
            }

            String requestStr = request.toString(); // Get String Body
            System.debug('Request Body JSON-->' + requestStr);
            RequestBody body = (RequestBody) JSON.deserialize(requestStr, RequestBody.class); // Deserialize JSON so it can be treated as an object
            System.debug('Request Body-->' + body);
            
            if (body.numero_elementos == null) { // Check if variable numero_elementos is empty
                throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{
                    'body.numero_elementos'
                }));
            }

            if (body.numero_elementos != body.elementos.size()) { // Check if the variable numero_elementos match with the structure size in the JSON
                throw new ONE_ElectiumSmartWebServiceException(String.format(Label.ElementosInvalid, new List<String>{
                    'body.numero_elementos'
                }));
            }

            if (documentNumber2Account == null) {
                documentNumber2Account = new Map<String, Account>();
            }

            Set<String> docNumbers = new Set<String>();
            for (Elemento elem : body.elementos) { // each element structure get corresponding ID
                if (elem.contratante != null && String.isNotBlank(elem.contratante.document_number_c)) {
                    docNumbers.add(elem.contratante.document_number_c);
                }
                if (elem.beneficiario != null && String.isNotBlank(elem.beneficiario.document_number_c)) {
                    docNumbers.add(elem.beneficiario.document_number_c);
                }
            }

            for (Account acc : [SELECT Id, ONE_N_Documento__pc FROM Account WHERE ONE_N_Documento__pc IN:docNumbers]) { // query existing accounts based in the DNI indicated in the nebeficiario or contratante
                documentNumber2Account.put(acc.ONE_N_Documento__pc, acc);
            }

            ONE_ElectiumSmartWebService ws = new ONE_ElectiumSmartWebService(body.elementos);
            ws.doValidation(); // Apply validation to elementos, contratante and beneficiarios structure
            ws.filterExistingRecords();

            ws.insertData();
			// Create response
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(ws.prepareResponse());
            RestContext.response.statusCode = ONE_CommonConstants.HTPP_SUCCESS_CODE; // if everything is inserted corrected a 200 code is send


            ONE_CommonUtils.createInboundIntegrationLog( // Create entry in the integration log object
                CLASS_NAME,
                requestStr,
                RestContext.response.responseBody.toString(),
                RestContext.request.httpMethod,
                ENDPOINT_NAME
            );

        } catch (Exception ex) { // In case of error send the error in the response 
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('Unexpected error');
            RestContext.response.statusCode = ONE_CommonConstants.HTPP_SERVER_ERROR_CODE;
        }
    }
	
    //Method to apply the data validations and them call the appropiate method to do the inser
    public static String createData(String request) { 
        String requestStr = request;
        RequestBody body = (RequestBody) JSON.deserialize(requestStr, RequestBody.class); // deserialize JSON 

        ONE_ElectiumSmartWebService ws = new ONE_ElectiumSmartWebService(body.elementos);
        ws.doValidation(); // Apply Validatios
        ws.filterExistingRecords(); //Check if the Accounts or Contract should be created or not

        ws.insertData(); //Create Accounts and Contracts in case is needed
        return ws.prepareResponse();
    }
	
    private void insertData() {
        Map<Integer, ElementoWrapper> accountToInsertIndexToElementoWrapper = new Map<Integer, ElementoWrapper>();

        contratoTempId2Contrato = new Map<Integer, ONE_Contrato__c>();
        contratoTempId2DocumentTempIds = new Map<Integer, List<Integer>>();
        documentTempId2ContentVersion = new Map<Integer, ContentVersion>();

        Savepoint mainSp = Database.setSavepoint();
        Savepoint accountSp = Database.setSavepoint();
        List<Account> accountsToInsert = prepareAccountsToInsertList(accountToInsertIndexToElementoWrapper);
        Boolean anyAccInsertFailed = insertAccounts(accountsToInsert, accountToInsertIndexToElementoWrapper);

        if (anyAccInsertFailed) { // In case whe got any errors in the Account creation we do a rollback of the accounts created before.
            accountToInsertIndexToElementoWrapper = new Map<Integer, ElementoWrapper>();
            Database.rollback(accountSp);
            accountsToInsert = prepareAccountsToInsertList(accountToInsertIndexToElementoWrapper);
            insertAccounts(accountsToInsert, accountToInsertIndexToElementoWrapper);
        }

        List<ONE_Contrato__c> contratosToInsertList = prepareContratosToInsertList();
        Boolean anyContratoInsertFailed = insertContratos(contratosToInsertList); // Insert Contract and return false in case we got any error

        if (anyContratoInsertFailed) { // In case whe got any errors in the contract creation we do a rollback of the accounts created before
            Database.rollback(mainSp); // Rollback of the previous operations
            accountToInsertIndexToElementoWrapper = new Map<Integer, ElementoWrapper>();
            accountsToInsert = prepareAccountsToInsertList(accountToInsertIndexToElementoWrapper);
            insertAccounts(accountsToInsert, accountToInsertIndexToElementoWrapper);
            contratosToInsertList = prepareContratosToInsertList();
            insertContratos(contratosToInsertList);
        }

        setNewRecordIds(accountsToInsert, contratosToInsertList, accountToInsertIndexToElementoWrapper);
		
        //Create PDF document based on the base64 codification in the documentos structure
        List<ContentVersion> cvs = new List<ContentVersion>();
        
        //Get base64 from the request and create the content version
        for (ContentVersion cv : documentTempId2ContentVersion.values()) {
            cvs.add(cv);
        }

        insert cvs;
		
        //Get content version ID
        Set<Id> cvsIDs = new Set<Id>();
        for (ContentVersion tcv : cvs) {
            cvsIDs.add(tcv.Id);
        }
		//With the content version ID get the Content Document ID
        Map<Id, ContentVersion> cvs2 = new Map<Id, ContentVersion>([
            SELECT Id, ContentDocumentId, PathOnClient, Title
            FROM ContentVersion
            WHERE Id IN:cvsIDs
        ]);

        //Generate Content Document link using the Content Document ID and the ID of the contract
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
		
        for (Integer tempId : contratoTempId2Contrato.keySet()) {
            for (Integer docTempId : contratoTempId2DocumentTempIds.get(tempId)) {
                documentTempId2ContentVersion.put(docTempId, cvs2.get(documentTempId2ContentVersion.get(docTempId).Id));
                cdls.add(new ContentDocumentLink(
                    ContentDocumentId = cvs2.get(documentTempId2ContentVersion.get(docTempId).Id).ContentDocumentId,
                    LinkedEntityId = contratoTempId2Contrato.get(tempId).Id,
                    Visibility = 'AllUsers'
                ));
            }
        }
        insert cdls;
		
        //Send OK response if the documentes where created OK
        prepareSuccessResponseItems(contratosToInsertList);
    }

    private void setNewRecordIds(List<Account> accounts, List<ONE_Contrato__c> contratos, Map<Integer, ElementoWrapper> accountToInsertIndexToElementoWrapper) {
        for (ONE_Contrato__c contrato : contratos) {
            ElementoWrapper el = codigoPreventivaToElementoWrapper.get(contrato.ONE_Codigo_Electium_Smart__c);
            el.contratoId = contrato.Id;
        }
        Integer idx = 0;
        for (Account acc : accounts) {
            ElementoWrapper el = accountToInsertIndexToElementoWrapper.get(idx);
            if (el.elemento.contratante.document_number_c == acc.ONE_N_Documento__pc && acc.ONE_N_Documento__pc != null) {
                el.contratanteId = acc.Id;
            } else if (el.elemento.beneficiario.document_number_c == acc.ONE_N_Documento__pc && acc.ONE_N_Documento__pc != null) {
                if (el != null) {
                    el.beneficiarioId = acc.Id;
                }
            }
            idx++;
        }
    }
	
    //Generate response adding the corresponding result into a JSON file
    private String prepareResponse() {
        System.debug('prepareResponse');
        List<ResponseItem> responseItems = new List<ResponseItem>();

        for (ElementoWrapper elementoWrapper : elementoWrappers) {
            System.debug(elementoWrapper);
            if (elementoWrapper != null && elementoWrapper.responseItem != null) {
                system.debug('respIitem');
                responseItems.add(elementoWrapper.responseItem);
            }
        }

        return JSON.serialize(responseItems);
    }
	
    private void prepareSuccessResponseItems(List<ONE_Contrato__c> contratos) {
        Map<Id, ONE_Contrato__c> idToContratos = new Map<Id, ONE_Contrato__c>(ONE_ContratoSelector.selectContratos(contratos));
        for (ElementoWrapper elementoWrapper : elementoWrappers) {
            System.debug('elementoWrapper.error');
            System.debug(elementoWrapper.error);
            System.debug(elementoWrapper.insertContract);
            if (!elementoWrapper.error && elementoWrapper.insertContract) {
                elementoWrapper.responseItem = new ResponseItem(false, elementoWrapper.elemento.codigo_preventiva, elementoWrapper.contratoId,
                    CORRECT_MESSAGE, elementoWrapper.contratanteId, elementoWrapper.beneficiarioId,
                    idToContratos.get(elementoWrapper.contratoId).Name
                );

                for (Integer tempId : contratoTempId2Contrato.keySet()) {
                    if (contratoTempId2Contrato.get(tempId).Id == elementoWrapper.contratoId) {
                        for (Integer tempDocId : contratoTempId2DocumentTempIds.get(tempId)) {
                            if (elementoWrapper.responseItem.documentos == null) {
                                elementoWrapper.responseItem.documentos = new List<DocumentosResponseWrapper>();
                            }
                            elementoWrapper.responseItem.documentos.add(
                                new DocumentosResponseWrapper(
                                    documentTempId2ContentVersion.get(tempDocId).PathOnClient,
                                    documentTempId2ContentVersion.get(tempDocId).ContentDocumentId
                                )
                            );
                        }
                    }
                }
            }
        }
    }

    private Boolean insertAccounts(List<Account> accountsToInsert, Map<Integer, ElementoWrapper> accountToInsertIndexToElementoWrapper) {
        Boolean anyAccInsertFailed = false;
        List<Database.UpsertResult> accSaveResults = Database.upsert(accountsToInsert, false);
        for (Integer idx = 0; idx < accSaveResults.size(); idx++) {
            Database.UpsertResult sr = accSaveResults.get(idx);
            Account acc = accountsToInsert.get(idx);
            ElementoWrapper elementoWrapper = accountToInsertIndexToElementoWrapper.get(idx);
            if (!sr.success) {
                anyAccInsertFailed = true;
                ResponseItem responseItem = new ResponseItem(true, elementoWrapper.elemento.codigo_preventiva, null,
                    ONE_CommonUtils.convertListToStringOfValues(sr.getErrors()), null, null, null
                );
                elementoWrapper.responseItem = responseItem;
                if (acc.ONE_N_Documento__pc != null && String.isNotBlank(acc.ONE_N_Documento__pc)) {
                    documentNumberToElementoWrapper.put(acc.ONE_N_Documento__pc, elementoWrapper);
                }
                codigoPreventivaToElementoWrapper.put(elementoWrapper.elemento.codigo_preventiva, elementoWrapper);
            } else {
                if (elementoWrapper.elemento.beneficiario != null
                    && elementoWrapper.elemento.beneficiario.document_number_c == acc.ONE_N_Documento__pc && acc.ONE_N_Documento__pc != null) {
                    elementoWrapper.beneficiarioId = acc.Id;
                } else if (elementoWrapper.elemento.contratante != null
                    && elementoWrapper.elemento.contratante.document_number_c == acc.ONE_N_Documento__pc && acc.ONE_N_Documento__pc != null) {
                    elementoWrapper.contratanteId = acc.Id;
                }
                if (acc.ONE_N_Documento__pc != null && String.isNotBlank(acc.ONE_N_Documento__pc)) {
                    documentNumberToElementoWrapper.put(acc.ONE_N_Documento__pc, elementoWrapper);
                }
                codigoPreventivaToElementoWrapper.put(elementoWrapper.elemento.codigo_preventiva, elementoWrapper);
            }
        }
        return anyAccInsertFailed;
    }

    private Boolean insertContratos(List<ONE_Contrato__c> contratosToInsert) {
        Boolean anyContractInsertFailed = false;
        List<Database.SaveResult> accSaveResults = Database.insert(contratosToInsert, false);
        for (Integer idx = 0; idx < accSaveResults.size(); idx++) {
            Database.SaveResult sr = accSaveResults.get(idx);
            ONE_Contrato__c contrato = contratosToInsert.get(idx);
            ElementoWrapper elementoWrapper = codigoPreventivaToElementoWrapper.get(contrato.ONE_Codigo_Electium_Smart__c);
            if (!sr.success) {
                anyContractInsertFailed = true;
                ResponseItem responseItem = new ResponseItem(true, elementoWrapper.elemento.codigo_preventiva, null,
                    ONE_CommonUtils.convertListToStringOfValues(sr.getErrors()), null, null, null
                );
                elementoWrapper.responseItem = responseItem;
                elementoWrapper.insertContract = false;
                elementoWrapper.insertContratante = false;
                elementoWrapper.insertBeneficiario = false;
            } else {
                System.debug(sr.getErrors());
            }
            idx++;
        }
        return anyContractInsertFailed;
    }

    private void initiate(List<Elemento> elementos) {
        elementoWrappers = new List<ElementoWrapper>();
        for (Elemento el : elementos) {
            elementoWrappers.add(
                new ElementoWrapper(el, null, true, true, el.beneficiario != null)
            );
        }

        codigoPreventivas = new Set<String>();
        accountDocumentNumbers = new Set<String>();
        codigoPreventivaToElementoWrapper = new Map<String, ElementoWrapper>();
        documentNumberToElementoWrapper = new Map<String, ElementoWrapper>();
        beneficiarioToElementoWrapper = new Map<Account, ElementoWrapper>();
    }

    private void doValidation() {
        for (ElementoWrapper elementoWrapper : elementoWrappers) {
            try {// if all validations are OK we send in the response the code of the created registers
                Elemento el = elementoWrapper.elemento;
                validateElemento(el);
                validateContratante(el.contratante);
                accountDocumentNumbers.add(el.contratante.document_number_c);
                if (el.beneficiario != null && String.isNotBlank(el.beneficiario.document_number_c)) {
                    accountDocumentNumbers.add(el.beneficiario.document_number_c);
                    documentNumberToElementoWrapper.put(el.beneficiario.document_number_c, elementoWrapper);
                }
                codigoPreventivas.add(el.codigo_preventiva);
                codigoPreventivaToElementoWrapper.put(el.codigo_preventiva, elementoWrapper);
                documentNumberToElementoWrapper.put(el.contratante.document_number_c, elementoWrapper);
            } catch (Exception ex) { // if any error occurs boolean variable are set to false and error message is send
                System.debug(ex.getMessage());
                System.debug(ex.getStackTraceString());
                Elemento el = elementoWrapper.elemento;
                elementoWrapper.responseItem = new ResponseItem(true, el.codigo_preventiva, null, ex.getMessage(), null, null, null);
                elementoWrapper.insertContract = false;
                elementoWrapper.insertContratante = false;
                elementoWrapper.insertBeneficiario = false;
            }
        }
    }

    //Apply Filters methods
    private void filterExistingRecords() {
        filterExistingAccounts();
        filterExistingContracts();
    }

    //Method to check if the Account already exist and use a boolean to indicate if the new Account should be inserted
    private void filterExistingAccounts() {
        existingAccounts = ONE_AccountSelector.selectAccounts(accountDocumentNumbers);

        for (Account acc : existingAccounts) {
            String accDocumentNumber = acc.ONE_N_Documento__pc;
            ElementoWrapper existingAccElementoWrapper = documentNumberToElementoWrapper.get(accDocumentNumber);
            if (existingAccElementoWrapper.elemento.beneficiario != null
                && existingAccElementoWrapper.elemento.beneficiario.document_number_c == accDocumentNumber) {
                existingAccElementoWrapper.insertBeneficiario = false;
                existingAccElementoWrapper.beneficiarioId = acc.Id;
            } else if (existingAccElementoWrapper.elemento.contratante.document_number_c == accDocumentNumber) {
                existingAccElementoWrapper.insertContratante = false;
                existingAccElementoWrapper.contratanteId = acc.Id;
            }
        }
    }
	
    private void filterExistingContracts() {
        existingContratos = ONE_ContratoSelector.selectContratos(codigoPreventivas);
        for (ONE_Contrato__c contrato : existingContratos) {
            String contratoCode = contrato.ONE_Codigo_Electium_Smart__c;
            ElementoWrapper existingContratoWrapper = codigoPreventivaToElementoWrapper.get(contratoCode);
            System.debug('setting to false');
            existingContratoWrapper.insertContract = false;
            existingContratoWrapper.contratoId = contrato.Id;
        }
    }

    private List<Account> prepareAccountsToInsertList(Map<Integer, ElementoWrapper> accountToInsertIndexToElementoWrapper) {
        Integer idx = 0;
        Set<Account> accounts = new Set<Account>();

        for (ElementoWrapper elementoWrapper : elementoWrappers) {
            if (!elementoWrapper.error) {
                Elemento el = elementoWrapper.elemento;
                if (elementoWrapper.insertContratante) {
                    accounts.add(
                        createAccount(el.contratante)
                    );
                    accountToInsertIndexToElementoWrapper.put(idx++, elementoWrapper);
                }

                if (elementoWrapper.insertBeneficiario) {
                    Account beneficiario = createAccount(el.beneficiario);
                    accounts.add(beneficiario);
                    beneficiarioToElementoWrapper.put(beneficiario, elementoWrapper);
                    accountToInsertIndexToElementoWrapper.put(idx++, elementoWrapper);
                }
            }
        }

        return new List<Account> (accounts);
    }

    private List<ONE_Contrato__c> prepareContratosToInsertList() {
        List<ONE_Contrato__c> contratos = new List<ONE_Contrato__c>();
        for (ElementoWrapper elementoWrapper : elementoWrappers) {
            if (!elementoWrapper.error && elementoWrapper.insertContract) {
                Elemento el = elementoWrapper.elemento;
                if (el?.contratante?.document_number_c == el?.beneficiario?.document_number_c && el?.contratante?.document_number_c != null) {
                    elementoWrapper.contratanteId = elementoWrapper.beneficiarioId;
                }
                ONE_Contrato__c cont = createContrato(el, elementoWrapper.contratanteId, elementoWrapper.beneficiarioId);
                contratos.add(
                    cont
                );
                Integer contratoTempId = tempIdIndex++;
                contratoTempId2Contrato.put(contratoTempId, cont);

                contratoTempId2DocumentTempIds.put(contratoTempId, new List<Integer>());
                for (FileWrapper fw : el.documentos) {
                    if (fw.content != null && fw.content != '') {
                        Integer docTempId = tempIdIndex++;
                        ContentVersion cv = new ContentVersion(
                            Title = fw.filename,
                            VersionData = EncodingUtil.base64Decode(fw.content),
                            PathOnClient = fw.filename,
                            ContentLocation = 'S'
                        );
                        contratoTempId2DocumentTempIds.get(contratoTempId).add(docTempId);
                        documentTempId2ContentVersion.put(docTempId, cv);
                    }
                }
            }
        }

        return contratos;
    }
	
    // Method to create the contract 
    private ONE_Contrato__c createContrato(Elemento el, Id contratanteId, Id beneficiarioId) {
        ONE_Contrato__c cont = new ONE_Contrato__c(
            ONE_Contratante__c = contratanteId,
            ONE_Beneficiario_1__c = beneficiarioId,
            ONE_Codigo_Electium_Smart__c = el.codigo_preventiva,
            ONE_Fecha_De_Contrato__c = Date.valueOf(el.mes_contrato),
            ONE_Fecha_De_Cobro__c = String.isBlank(el.fecha_cobro) ? null : Date.valueOf(el.fecha_cobro),
            ONE_Entidad_Bancaria__c = el.entidad_bancaria,
            ONE_IBAN__c = el.iban,
            ONE_Total_P_V_P__c = Decimal.valueOf(el.base_imponible),
            ONE_Parentesco__c = el.parentesco_c,
            ONE_Forma_De_Pago__c = el.forma_pago_c,
            ONE_Num_Mensualidades__c = el.numero_mensualidades_c != null && el.numero_mensualidades_c != '' ? Decimal.valueOf(el.numero_mensualidades_c) : null,
            ONE_Cuota_Mensual__c = el.importe_mensualidad_c != null && el.importe_mensualidad_c != '' ? Decimal.valueOf(el.importe_mensualidad_c) : null,
            ONE_Fecha_Primera_Mensualidad__c = el.fecha_primera_mensualidad_c != null && el.fecha_primera_mensualidad_c != '' ? Date.valueOf(el.fecha_primera_mensualidad_c) : null,
            ONE_Tipo_De_Presupuesto__c = el.tipo_presupuesto,
            ONE_Tipo_Servicio_Smart__c = el.tipo_servicio,
            ONE_Tipo_de_Sepelio__c = el.tipo_sepelio,
            ONE_Pais_de_Repatriacion__c = el.pais_repatriacion,
            ONE_Aeropuerto_Repatriacion__c = el.aeropuerto,
            ONE_Datos_Adicionales__c = el.aditional_data,
            ONE_Importe_Primera_Mensualidad__c = el.importe_primera_mensualidad != null && el.importe_primera_mensualidad != '' ? Decimal.valueOf(el.importe_primera_mensualidad) : null,
            ONE_Titular__c = el.titular
        );

        if (el.address != null &&
            (
                (el?.address?.primary_address_postalcode != null && el?.address?.primary_address_postalcode != '') ||
                    (el?.address?.primary_address_state != null && el?.address?.primary_address_state != '')
            )
            ) {
            cont.ONE_Direccion_Provincia_Smart__c = el?.address?.primary_address_state;
            cont.ONE_Direccion_Codigo_Postal_Smart__c = el?.address?.primary_address_postalcode;
        } else {
            cont.ONE_Direccion_Provincia_Smart__c = el?.contratante?.primary_address_state;
            cont.ONE_Direccion_Codigo_Postal_Smart__c = el?.contratante?.primary_address_postalcode;
        }

        return cont;
    }

    //Method to create new account
    private Account createAccount(AccountWrapper wr) { 
        if (documentNumber2Account == null) { // if the Account is not found via ID create a new one
            documentNumber2Account = new Map<String, Account>();
        } else {
            if (documentNumber2Account.containsKey(wr.document_number_c)) { //if the Account is already created update that one
                return documentNumber2Account.get(wr.document_number_c);
            }
        }

        Account acc = new Account( // Create new account
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
            FirstName = wr.first_name?.toUpperCase(),
            LastName = wr.last_name?.toUpperCase() + ' ' + ONE_CommonUtils.changeNullToBlank(wr.last_name2?.toUpperCase()),
            ONE_Email__c = wr.email_address,
            Phone = wr.phone_work,
            PersonHomePhone = wr.phone_mobile,
            ONE_Tipo_De_Calle_Picklist__c = wr.primary_address_street_type_c,
            ONE_Direccion__pc = wr.primary_address_street + ', ' + wr.primary_address_number_c + ' ' + wr.primary_address_door_c + ' ' + wr.primary_address_floor_c,
            ONE_Municipio__pc = wr.primary_address_city,
            ONE_Provincia__pc = wr.primary_address_state,
            ONE_Codigo_Postal__pc = wr.primary_address_postalcode,
            ONE_Pais__pc = wr.primary_address_country,
            ONE_Fecha_de_nacimiento__pc = String.isBlank(wr.birthdate) ? null : Date.valueOf(wr.birthdate),
            ONE_N_Documento__pc = wr.document_number_c,
            ONE_Tipo_de_documento__pc = wr.document_type_c
        );
        documentNumber2Account.put(wr.document_number_c, acc);
        system.debug('Account-->' + acc);
        return acc;
    }
	
    // Validations that shold apply to elemento's structure
    public static void validateElemento(Elemento elemento) { 
        /*if (elemento.codigo_preventiva == null || elemento.codigo_preventiva == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.codigo_preventiva'}));
        }
        if (elemento.mes_contrato == null || elemento.mes_contrato == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.mes_contrato'}));
        }
        if (elemento.fecha_cobro == null || elemento.fecha_cobro == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.fecha_cobro'}));
        }
        if (elemento.entidad_bancaria == null || elemento.entidad_bancaria == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.entidad_bancaria'}));
        }
        if (elemento.iban == null || elemento.iban == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.iban'}));
        }
        if (elemento.base_imponible == null || elemento.base_imponible == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.base_imponible'}));
        }
        if (elemento.parentesco_c == null || elemento.parentesco_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.parentesco_c'}));
        }
        if (elemento.numero_mensualidades_c == null || elemento.numero_mensualidades_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.numero_mensualidades_c'}));
        }
        if (elemento.importe_mensualidad_c == null || elemento.importe_mensualidad_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.importe_mensualidad_c'}));
        }
        if (elemento.fecha_primera_mensualidad_c == null || elemento.fecha_primera_mensualidad_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.fecha_primera_mensualidad_c'}));
        }
        if (elemento.importe_primera_mensualidad == null || elemento.importe_primera_mensualidad == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.importe_primera_mensualidad'}));
        }
        if (elemento.titular == null  || elemento.titular == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'elemento.titular'}));
        }*/
        if (elemento.forma_pago_c == null || elemento.forma_pago_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{
                'elemento.forma_pago_c'
            }));
        }
        if (elemento.tipo_presupuesto == null || elemento.tipo_presupuesto == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{
                'elemento.tipo_presupuesto'
            }));
        }
        //validateContratante(elemento.contratante);
    }
	
    // Validations that should apply to contratante and beneficiario
    public static void validateContratante(AccountWrapper contratante) {
        /*if (contratante.first_name == null  || contratante.last_name == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.first_name'}));
        }
        if (contratante.last_name == null || contratante.last_name == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.last_name'}));
        }
        if (contratante.last_name2 == null || contratante.last_name2 == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.last_name2'}));
        }
        if (contratante.email_address == null || contratante.email_address == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.email_address'}));
        }
        if (contratante.phone_work == null || contratante.phone_work == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.phone_work'}));
        }
        if (contratante.phone_mobile == null || contratante.phone_mobile == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.phone_mobile'}));
        }
        if (contratante.primary_address_street_type_c == null || contratante.primary_address_street_type_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_street_type_c'}));
        }
        if (contratante.primary_address_street == null || contratante.primary_address_street == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_street'}));
        }
        if (contratante.primary_address_city == null || contratante.primary_address_city == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_city'}));
        }
        if (contratante.primary_address_state == null || contratante.primary_address_state == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_state'}));
        }
        if (contratante.primary_address_postalcode == null || contratante.primary_address_postalcode == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_postalcode'}));
        }
        if (contratante.primary_address_country == null || contratante.primary_address_country == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_country'}));
        }
        if (contratante.primary_address_number_c == null || contratante.primary_address_number_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_number_c'}));
        }
        if (contratante.primary_address_door_c == null || contratante.primary_address_door_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_door_c'}));
        }
        if (contratante.primary_address_floor_c == null || contratante.primary_address_floor_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.primary_address_floor_c'}));
        }
        if (contratante.birthdate == null || contratante.birthdate == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.birthdate'}));
        }
        if (contratante.document_type_c == null || contratante.document_type_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{'contratante.document_type_c'}));
        }*/
        if (contratante.document_number_c == null || contratante.document_number_c == '') {
            throw new ONE_ElectiumSmartWebServiceException(String.format(Label.FieldIsMandatory, new List<String>{
                'contratante.document_number_c'
            }));
        }
    }
	
    // Data structure definition for the request
    @TestVisible
    private class RequestBody {
        public Integer numero_elementos { get; set; }
        public List<Elemento> elementos { get; set; }
    }
	
    // Data structure definition for elemento array
    @TestVisible
    private class Elemento { 
        public String codigo_preventiva { get; set; }
        public String mes_contrato { get; set; }
        public String fecha_cobro { get; set; }
        public String titular { get; set; }
        public String entidad_bancaria { get; set; }
        public String iban { get; set; }
        public String tipo_impositivo { get; set; }
        public String base_imponible { get; set; }
        public String parentesco_c { get; set; }
        public String forma_pago_c { get; set; }
        public String numero_mensualidades_c { get; set; }
        public String importe_mensualidad_c { get; set; }
        public String fecha_primera_mensualidad_c { get; set; }
        public String tipo_presupuesto { get; set; }
        public String tipo_servicio { get; set; }
        public String tipo_sepelio { get; set; }
        public String pais_repatriacion { get; set; }
        public String aeropuerto { get; set; }
        public String importe_primera_mensualidad { get; set; }
        public AccountWrapper contratante { get; set; }
        public AccountWrapper beneficiario { get; set; }
        public String aditional_data { get; set; }
        public List<FileWrapper> documentos { get; set; }
        public AddressWrapper address { get; set; }
    }

    @TestVisible
    private class FileWrapper {
        public String filename { get; set; }
        public String content { get; set; }
    }

    // Data structure definition for the request
    @TestVisible
    private class AccountWrapper {
        public String first_name { get; set; }
        public String last_name { get; set; }
        public String last_name2 { get; set; }
        public String email_address { get; set; }
        public String phone_work { get; set; }
        public String phone_mobile { get; set; }
        public String primary_address_street_type_c { get; set; }
        public String primary_address_street { get; set; }
        public String primary_address_city { get; set; }
        public String primary_address_state { get; set; }
        public String primary_address_postalcode { get; set; }
        public String primary_address_country { get; set; }
        public String primary_address_number_c { get; set; }
        public String primary_address_door_c { get; set; }
        public String primary_address_floor_c { get; set; }
        public String birthdate { get; set; }
        public String document_number_c { get; set; }
        public String document_type_c { get; set; }
    }
	
    //Data structure definition for the Address in the request JSON
    @TestVisible
    private class AddressWrapper {
        public String primary_address_street_type_c { get; set; }
        public String primary_address_street { get; set; }
        public String primary_address_city { get; set; }
        public String primary_address_state { get; set; }
        public String primary_address_postalcode { get; set; }
        public String primary_address_country { get; set; }
        public String primary_address_number_c { get; set; }
        public String primary_address_door_c { get; set; }
        public String primary_address_floor_c { get; set; }
    }
	
    //Data structure definition for the Address in the request JSON
    @TestVisible
    private class ResponseItem {
        public Boolean error { get; set; }
        public String codigo_preventiva { get; set; }
        public String id_contrato { get; set; }
        public String id_contratante { get; set; }
        public String id_beneficiario { get; set; }
        public String numero_contrato { get; set; }
        public List<DocumentosResponseWrapper> documentos { get; set; }
        public String message { get; set; }

        public ResponseItem(Boolean error, String codigo_preventiva, String id_contrato, String message, String id_contratante, String id_beneficiario, String numero_contrato) {
            this.error = error;
            this.codigo_preventiva = codigo_preventiva;
            this.id_contrato = id_contrato;
            this.message = message;
            this.id_contratante = id_contratante;
            this.id_beneficiario = id_beneficiario;
            this.numero_contrato = numero_contrato;
        }
    }
	
    //Data structure for the response JSON in the document structure
    @TestVisible
    private class DocumentosResponseWrapper {
        public String codigo_documento { get; set; }
        public String titulo_documento { get; set; }

        public DocumentosResponseWrapper(String titulo, String codigo) {
            titulo_documento = titulo;
            codigo_documento = codigo;
        }
    }

    //Data structure for the response JSON
    @TestVisible
    private class ElementoWrapper {
        public Elemento elemento { get; set; }
        public ResponseItem responseItem { get; set; }
        public Boolean insertContract { get; set; }
        public Boolean insertContratante { get; set; }
        public Boolean insertBeneficiario { get; set; }
        public Id contratanteId { get; set; }
        public Id beneficiarioId { get; set; }
        public Id contratoId { get; set; }
        public Boolean error {
            get {
                return (responseItem != null) && responseItem.error;
            }
        }

        public ElementoWrapper(Elemento elemento, ResponseItem responseItem, Boolean insertContract, Boolean insertContratante, Boolean insertBeneficiario) {
            this.elemento = elemento;
            this.responseItem = responseItem;
            this.insertBeneficiario = insertBeneficiario;
            this.insertContract = insertContract;
            this.insertContratante = insertContratante;
        }
    }

    public class ONE_ElectiumSmartWebServiceException extends Exception {
    }
}
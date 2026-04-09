/**
 * Created by mbujak003 on 11.06.2021.
 */

/*
* Billing Companies controller
*/
public without sharing class ONE_BCController {
    public static final Map<String, String> fieldType2inputType = new Map<String, String> {
        'ADDRESS' => 'text',
        'BOOLEAN' => 'checkbox',
        'CURRENCY' => 'number',
        'DATE' => 'date',
        'DATETIME' => 'datetime',
        'DOUBLE' => 'number',
        'EMAIL' => 'email',
        'ID' => 'search',
        'INTEGER' => 'number',
        'LONG' => 'number',
        'PERCENT' => 'number',
        'PHONE' => 'tel',
        'PICKLIST' => '',
        'REFERENCE' => 'search',
        'STRING' => 'text',
        'TEXTAREA' => 'text',
        'TIME' => 'time',
        'URL' => 'url'
    };

    public static final Set<String> likeFilters = new Set<String> {
        'ADDRESS', 'EMAIL', 'PHONE', 'PICKLIST', 'STRING', 'TEXTAREA', 'URL', 'text'
    };
    static final String ALLOWED_DOCUMENTS_CB_CONFIGURATION_DEV_NAME = 'Allowed_Documents_To_Be_Send';
    static final String ALLOWED_DOCUMENTS_CB_CONFIGURATION_SEPARATOR = ';';
    static final Boolean DO_NOT_INCLUDE_FACTURA_FILES = true;
    static final Boolean DO_INCLUDE_FACTURA_FILES = false;

    public static Map<String, Set<String>> prepareRequiredDocuments() {
        Map<String, Set<String>> insuranceFormat2RequiredDocuments = new Map<String, Set<String>>();

        for(ONE_BillingCompanies_Configuration__mdt config : [
            SELECT Id, ONE_Formato_Documentos__c , ONE_Documentos_Requeridos__c FROM ONE_BillingCompanies_Configuration__mdt
        ]) {
            insuranceFormat2RequiredDocuments.put(config.ONE_Formato_Documentos__c, new Set<String>(config.ONE_Documentos_Requeridos__c.split(';')));
        }
        return insuranceFormat2RequiredDocuments;
    }
    @AuraEnabled
    public static Map<String,String> invokeIntegration(String odventaId, String ficheroData, String ficheroName){
        System.debug('PRE LLAMADA');
        Map<String,String> resultsIntegration=ONE_FacturacionOCASOWS.createRequest(odventaId, ficheroData, ficheroName);
        System.debug('POST LLAMADA');
        if(resultsIntegration.get('statusCode')=='200' && resultsIntegration.get('codigoError')=='0'){
            System.debug('PRE MSG');
            System.debug('idDocumentum'+resultsIntegration.get('idDocumentum'));
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { UserInfo.getUserEmail() };
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Memora - Comunicación');
            mail.setSubject('Envío de Factura');
            mail.setPlainTextBody('Factura enviada a OCASO ');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('factura.pdf');
            efa.setBody(EncodingUtil.base64Decode(String.valueOf(ficheroData)));
            efa.setContentType('application/pdf');
            System.debug('efa');
            System.debug(efa);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            Messaging.SendEmailResult[] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            for(Messaging.SendEmailResult r : res) {
                System.debug(r);
            }
            System.debug('POST MSG');
            ONE_Orden_De_Venta__c odv=[SELECT Id,ONE_idDocumentum__c, ONE_Estado_envio_Documentacion_Asegur__c,ONE_Fecha_envio_documentacion_asegurad__c from ONE_Orden_De_Venta__c where Id=:odventaId];
            if(odv.ONE_Estado_envio_Documentacion_Asegur__c=='Enviado'){
                odv.ONE_Estado_envio_Documentacion_Asegur__c='Reenviado';
            }else{
                odv.ONE_Estado_envio_Documentacion_Asegur__c='Enviado';
                
            }
            odv.ONE_Fecha_envio_documentacion_asegurad__c=System.now();
            odv.ONE_idDocumentum__c=resultsIntegration.get('idDocumentum');
            update odv;
            System.debug('POST UPDATE');
        }
        return resultsIntegration;
    }
    @AuraEnabled
    public static String fetchRecords(Map<String, Object> filters) {
        System.debug('JSON.serialize(filters)');
        System.debug(JSON.serialize(filters));
        Map<String, Set<String>> insuranceFormat2RequiredDocuments = prepareRequiredDocuments();

        Map<String, FieldWrapper> obj2FieldMapWithTypes = new Map<String, FieldWrapper>();

        for(FieldWrapper fw : (List<FieldWrapper>)JSON.deserialize(fetchSearchFields(), List<FieldWrapper>.class)) {
            obj2FieldMapWithTypes.put(fw.fieldName, fw);
        }

        String expQuery = '';

        Map<String, Object> extendedFilters = new Map<String, Object> {
                'ONE_Pagador_Compania__r.Name' => null,
                'ONE_Pagador_Compania__c' => filters.get('insuranceCompanyVal'),
                'ONE_Estado_envio_Documentacion_Asegur__c' => filters.get('estadoFacturaVal'),
                'ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c' => filters.get('sociedadGrupoMemoraVal'),
                'ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c' => filters.get('codigoCompaniaVal'),
                'ONE_Servicio__r.ONE_Numero_de_Siniestro__c' => filters.get('numeroSiniestroVal'),
                'ONE_Servicio__r.ONE_Numero_de_Poliza__c' => filters.get('numeroPolizaVal'),
                'ONE_Servicio__r.ONE_Nombre_Apellidos_Del_Difunto__c' => null,
                'ONE_Fecha_envio_documentacion_asegurad__c' => null,
                'ONE_Fecha_De_Facturacion__c' => null
        };

        System.debug(JSON.serialize(extendedFilters));

        String fieldsToQuery = 'SELECT Id, ONE_Importe_Total__c, ONE_Pagador_Compania__r.ONE_Forma_de_envio_de_los_documentos__c, ' +
            'ONE_Importe_Neto_Suplido__c, (SELECT Title, ContentUrl FROM AttachedContentDocuments), Name, ' +
            'ONE_Servicio__r.Name, ONE_Servicio__c, ONE_Numero_de_factura__c, ONE_PagadorCompaniaOcaso__c, ';
        String conditions = 'WHERE ';
        System.debug(extendedFilters);
        for(String field : extendedFilters.keySet()) {
            fieldsToQuery += field +', ';

            if(extendedFilters.get(field) != null && extendedFilters.get(field) != '') {
                String fieldType = obj2FieldMapWithTypes.get(field)?.type;
                if(!likeFilters.contains(fieldType)) {
                    if(fieldType != 'BOOLEAN') {
                        conditions += field + ' = \'' + extendedFilters.get(field) + '\' AND ';
                    } else {
                        conditions += field + ' = ' + extendedFilters.get(field) + ' AND ';
                    }
                } else {
                    conditions += field + ' LIKE \'%' + extendedFilters.get(field) + '%\' AND ';
                }
            }
        }

        if(filters.get('fechaFacturaDesdeVal') != null) {
            String desdeVal = String.valueOf(filters.get('fechaFacturaDesdeVal'));
            if (doesConditionNotEndsWithWhereAndAndKeyword(conditions)) {
                conditions += ' AND ';
            }
            conditions += 'ONE_Fecha_De_Facturacion__c >= ' + String.valueOf(((DateTime)JSON.deserialize('"' + desdeVal + '"', DateTime.class)).dateGmt());
        }
        
        if (filters.get('insuranceCompanyVal') != null) {
            if (doesConditionNotEndsWithWhereAndAndKeyword(conditions)) {
                conditions += ' AND ';
            }
            conditions += 'ONE_Pagador_Compania__r.ONE_Compania_Billing_Companies__c = TRUE ';
        }

        if(filters.get('fechafacturaHastaVal') != null) {
            String hastaVal = String.valueOf(filters.get('fechafacturaHastaVal'));
            if (doesConditionNotEndsWithWhereAndAndKeyword(conditions)) {
                conditions += ' AND ';
            }
            conditions += 'ONE_Fecha_De_Facturacion__c <= ' + String.valueOf(((DateTime)JSON.deserialize('"' + hastaVal + '"', DateTime.class)).dateGmt());
        }


        fieldsToQuery = fieldsToQuery.removeEnd(', ');
        if(conditions.endsWith(' AND ')) {
            conditions = conditions.removeEnd(' AND ');
        } else {
            conditions = conditions.removeEnd('WHERE ');
        }

        expQuery = fieldsToQuery + ' FROM ONE_Orden_De_Venta__c ' +  conditions + ' Order by ONE_Servicio__r.Name desc ';
        System.debug(expQuery);
        List<ONE_Orden_De_Venta__c> ordens = Database.query(expQuery);
        Map<Id, ONE_Orden_De_Venta__c> ordenIds2Ordens = new Map<Id, ONE_Orden_De_Venta__c>(ordens);
        Set<Id> serviceIds = new Set<Id>();
        for(ONE_Orden_De_Venta__c ord : ordens) {
            serviceIds.add(ord.ONE_Servicio__c);
        }

        Map<String, List<ContentVersion>> ordenId2ContentVersions = fetchContentVersions(ordenIds2Ordens.keySet(), DO_INCLUDE_FACTURA_FILES);
        ordenId2ContentVersions.putAll(fetchContentVersions(serviceIds, DO_INCLUDE_FACTURA_FILES));
        List<Map<String, Object>> objs = new List<Map<String, Object>>();
        for(ONE_Orden_De_Venta__c odv : ordenIds2Ordens.values()) {

            String missingDocuments = '';
            Boolean documentsComplete = true;
            Set<Id> invoiceDuplicates = new Set<Id>();

            Map<String, ContentVersion> docTitle2Doc = new Map<String, ContentVersion>();
            System.debug('1');
            if(ordenId2ContentVersions.containsKey(odv.Id)) {
                for(ContentVersion acd : ordenId2ContentVersions.get(odv.Id)) {
                    if (!invoiceDuplicates.contains(acd.ContentDocumentId)) {
                        docTitle2Doc.put(acd.TagCsv, acd);
                    }
                    invoiceDuplicates.add(acd.ContentDocumentId);
                }
            if(ordenId2ContentVersions.containsKey(odv.ONE_Servicio__c)) {
                for(ContentVersion acd : ordenId2ContentVersions.get(odv.ONE_Servicio__c)) {
                    if (!invoiceDuplicates.contains(acd.ContentDocumentId)) {
                        docTitle2Doc.put(acd.TagCsv, acd);
                    }
                    invoiceDuplicates.add(acd.ContentDocumentId);
                }
            }

                System.debug(docTitle2Doc);
                if(odv?.ONE_Pagador_Compania__r?.ONE_Forma_de_envio_de_los_documentos__c != null &&
                    insuranceFormat2RequiredDocuments.get(odv?.ONE_Pagador_Compania__r?.ONE_Forma_de_envio_de_los_documentos__c) != null) {

                    Boolean suplidoRequired = odv.ONE_Importe_Neto_Suplido__c != null && odv.ONE_Importe_Neto_Suplido__c != 0;

                    for(String docType : insuranceFormat2RequiredDocuments.get(odv?.ONE_Pagador_Compania__r?.ONE_Forma_de_envio_de_los_documentos__c)) {
                        System.debug(docType);
                        System.debug(docTitle2Doc.keySet());
                        if(!docTitle2Doc.containsKey(docType)) {
                            if(docType.equalsIgnoreCase(ONE_CommonConstants.DOCUMENT_TAG_SUPLIDOS) && !suplidoRequired) {
                                continue;
                            }
                            documentsComplete = false;
                            missingDocuments += docType + ', ';

                        }
                    }
                } else {
                    documentsComplete = false;
                    missingDocuments = 'NULL forma de envio de los documentos';
                }
            } else {
                documentsComplete = false;
                String forma = odv?.ONE_Pagador_Compania__r?.ONE_Forma_de_envio_de_los_documentos__c;
                if(forma != null) {
                    if(insuranceFormat2RequiredDocuments.containsKey(forma)) {
                        for(String str : insuranceFormat2RequiredDocuments.get(forma)) {
                            missingDocuments += str + ', ';
                        }
                    }
                } else {
                    missingDocuments = 'NULL forma de envio de los documentos';
                }
            }

            if(missingDocuments.endsWith(', ')) {
                missingDocuments = missingDocuments.removeEnd(', ');
            }

            objs.add(new Map<String, Object> {
                    'Id' => odv.Id,
                    'ONE_Servicio__r.Name' => odv.ONE_Servicio__r.Name,
                    'ONE_Servicio__c' => odv.ONE_Servicio__c,
                    'ONE_Pagador_Compania__r.Name' => odv.ONE_Pagador_Compania__r.Name,
                    'ONE_Estado_envio_Documentacion_Asegur__c' => odv.ONE_Estado_envio_Documentacion_Asegur__c,
                    'ONE_Numero_de_factura__c' => odv.ONE_Numero_de_factura__c,
                    'ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c' => odv.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                    'ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c' => odv.ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c,
                    'ONE_Fecha_De_Facturacion__c' => odv.ONE_Fecha_De_Facturacion__c,
                    'ONE_Importe_Total__c' => odv.ONE_Importe_Total__c,
                    'ONE_Servicio__r.ONE_Numero_de_Siniestro__c' => odv.ONE_Servicio__r.ONE_Numero_de_Siniestro__c,
                    'ONE_Servicio__r.ONE_Numero_de_Poliza__c' => odv.ONE_Servicio__r.ONE_Numero_de_Poliza__c,
                    'ONE_Servicio__r.ONE_Nombre_Apellidos_Del_Difunto__c' => odv.ONE_Servicio__r.ONE_Nombre_Apellidos_Del_Difunto__c,
                    'ONE_Fecha_envio_documentacion_asegurad__c' => odv.ONE_Fecha_envio_documentacion_asegurad__c,
                    'AttachedContentDocuments' => odv.AttachedContentDocuments,
                    'Docflag' => documentsComplete == true ? 'yes' : 'no',
                    'MissingDocs' => missingDocuments,
                    'ServicioUrl' => '/' + odv.ONE_Servicio__c,
                    'IsOCASO'=>odv.ONE_PagadorCompaniaOcaso__c
            });
        }

        System.debug(objs);
        return JSON.serialize(objs);
    }

    static Boolean doesConditionNotEndsWithWhereAndAndKeyword(String conditions) {
        return !conditions.endsWith('WHERE ') && !conditions.endsWith('AND ');
    }

    @AuraEnabled
    public static String fetchSearchFields() {
        List<FieldWrapper> wraps = new List<FieldWrapper> {
                new FieldWrapper('ONE_Servicio__r.Name', 'Servicio', 'STRING'),
                new FieldWrapper('ONE_Pagador_Compania__r.Name', 'Compañía aseguradora', 'STRING'),
                new FieldWrapper('ONE_Estado_envio_Documentacion_Asegur__c', 'Estado factura', 'PICKLIST'),
                new FieldWrapper('ONE_Numero_de_factura__c', 'Número de Factura', 'STRING'),
                new FieldWrapper('ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c', 'Sociedad grupo memora', 'STRING'),
                new FieldWrapper('ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c', 'Código compañía', 'STRING'),
                new FieldWrapper('ONE_Fecha_De_Facturacion__c', 'Fecha factura', 'date'),
                new FieldWrapper('ONE_Servicio__r.ONE_Numero_de_Siniestro__c', 'Nº Siniestro', 'STRING'),
                new FieldWrapper('ONE_Servicio__r.ONE_Numero_de_Poliza__c', 'Nº Poliza', 'STRING'),
                new FieldWrapper('ONE_Servicio__r.ONE_Nombre_Apellidos_Del_Difunto__c', 'Difunto', 'STRING'),
                new FieldWrapper('ONE_Importe_Total__c', 'Importe', 'STRING'),
                new FieldWrapper('ONE_Fecha_envio_documentacion_asegurad__c', 'Fecha último envío', 'date')
        };
        return JSON.serialize(wraps);
    }

    @AuraEnabled
    public static String fetchInsuranceCompanies() {
        List<InsuranceCompanyWrapper> insuranceCompanies = new List<InsuranceCompanyWrapper>{new InsuranceCompanyWrapper('', '')};
        for(Account acc : [
                SELECT Id, Name
                FROM Account
                WHERE ONE_Compania_Billing_Companies__c = TRUE
                ORDER BY Name
        ]) {
            insuranceCompanies.add(new InsuranceCompanyWrapper(acc.Name, acc.Id));
        }
        System.debug('insuranceCompanies');
        System.debug(insuranceCompanies);
        return JSON.serialize(insuranceCompanies);
    }

    @AuraEnabled
    public static String fetchDocumentsForSingleOrden(String ordenIdJson) {
        return fetchDocuments(ordenIdJson);
    }

    @AuraEnabled
    public static String fetchDocuments(String ordenIdsJson) {
        List<String> ordenIds = (List<String>)JSON.deserialize(ordenIdsJson, List<String>.class);

        Map<String, String> ordenId2ServiceId = new Map<String, String>();
        Map<Id, ONE_Orden_De_Venta__c> ordens = new Map<Id, ONE_Orden_De_Venta__c>([
                SELECT Id, Name, ONE_Servicio__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_CIF__c,
                        ONE_Estado_De_La_Orden_de_Venta__c,
                        ONE_Numero_de_factura__c, ONE_Servicio__r.ONE_Numero_de_Poliza__c, ONE_Servicio__r.ONE_Difunto__r.Name,
                        ONE_Servicio__r.ONE_Numero_de_Siniestro__c, ONE_Pagador_Compania__r.ONE_Forma_de_envio_de_los_documentos__c
                FROM ONE_Orden_De_Venta__c
                WHERE Id IN: ordenIds
                /*AND ONE_Estado_De_La_Orden_de_Venta__c != :ONE_CommonConstants.ESTADO_ABONADO*/ //Las ordenes de venta en estado abonado no se envian
        ]);

        Map<String, String> ordenId2ZipFileName = new Map<String, String>();
        Map<String, String> ordenId2ConcatFileName = new Map<String, String>();
        Map<String, String> ordenId2SubjectName = new Map<String, String>();
        Map<String, String> ordenId2Body = new Map<String, String>();

        Set<String> servIds = new Set<String>();
        for(ONE_Orden_De_Venta__c odv : ordens.values()) {
            servIds.add(odv.ONE_Servicio__c);
            ordenId2ServiceId.put(odv.Id, odv.ONE_Servicio__c);
            ordenId2Body.put(odv.Id,
                String.format(
                    '{0}_{1}_{2}',
                    new List<String> {
                        odv.ONE_Numero_de_factura__c,
                        odv.ONE_Servicio__r.ONE_Numero_de_Siniestro__c,
                        odv.ONE_Servicio__r.ONE_Difunto__r.Name
                    }
                )
            );
            ordenId2SubjectName.put(odv.Id,
                String.format(
                    '{0}_{1}',
                    new List<String> {
                        odv.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_CIF__c,
                        odv.ONE_Servicio__r.ONE_Numero_de_Siniestro__c
                    }
                )
            );
            ordenId2ZipFileName.put(odv.Id, odv.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_CIF__c);
            ordenId2ConcatFileName.put(
                odv.Id,
                String.format(
                    '{0} {1}',
                    new List<String> {
                        odv.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_CIF__c,
                        odv.ONE_Servicio__r.ONE_Numero_de_Siniestro__c
                    }
                )
            );
        }

        Map<Id, ONE_Expediente__c> expedientes = new Map<Id, ONE_Expediente__c>([
            SELECT Id, ONE_Compania__r.ONE_Forma_de_envio_de_los_documentos__c, Name
            FROM ONE_Expediente__c
            WHERE Id IN: ordenId2ServiceId.values()
        ]);

        Map<String, DocumentsAttachmentConfig> expedienteId2Config = new Map<String, DocumentsAttachmentConfig>();

        Map<String, ONE_BillingCompanies_Configuration__mdt> formatName2Config = new Map<String, ONE_BillingCompanies_Configuration__mdt>();
        for(ONE_BillingCompanies_Configuration__mdt config : [
            SELECT Id, ONE_Formato_Documentos__c , ONE_Documentos_Requeridos__c, ONE_Documentos_Concadenados__c,
                ONE_Documentos_Individuales__c, ONE_Documentos_ZIP__c
            FROM ONE_BillingCompanies_Configuration__mdt
        ]) {
            formatName2Config.put(config.ONE_Formato_Documentos__c, config);
        }

        for(ONE_Orden_De_Venta__c exp : ordens.values()) {
            if(exp?.ONE_Pagador_Compania__r?.ONE_Forma_de_envio_de_los_documentos__c != null &&
                    formatName2Config.containsKey(exp?.ONE_Pagador_Compania__r?.ONE_Forma_de_envio_de_los_documentos__c)) {
                ONE_BillingCompanies_Configuration__mdt cfgMdt = formatName2Config.get(exp?.ONE_Pagador_Compania__r?.ONE_Forma_de_envio_de_los_documentos__c);
                DocumentsAttachmentConfig cfg = new DocumentsAttachmentConfig();
                cfg.concatTags = new List<String>();
                cfg.individualTags = new List<String>();
                cfg.zippedTags = new List<String>();
                if(String.isNotEmpty(cfgMdt.ONE_Documentos_Concadenados__c)) {
                    cfg.concatTags = cfgMdt.ONE_Documentos_Concadenados__c.split(';');
                }
                if(String.isNotEmpty(cfgMdt.ONE_Documentos_Individuales__c)) {
                    cfg.individualTags = cfgMdt.ONE_Documentos_Individuales__c.split(';');
                }
                if(String.isNotEmpty(cfgMdt.ONE_Documentos_ZIP__c)) {
                    cfg.zippedTags = cfgMdt.ONE_Documentos_ZIP__c.split(';');
                }

                expedienteId2Config.put(exp.ONE_Servicio__c, cfg);
            }
        }

        Map<String, List<ContentVersion>> expId2ContentVersions = fetchContentVersions(expedientes.keySet(), DO_NOT_INCLUDE_FACTURA_FILES);
        Map<String, List<ContentVersion>> ordenId2ContentVersions = fetchContentVersions(ordens.keySet(), DO_INCLUDE_FACTURA_FILES);

        List<ServiceDocumentsPayload> sdps = new List<ServiceDocumentsPayload>();
        Set<Id> ordenDocumentsDuplicateSet = new Set<Id>();

        System.debug(expId2ContentVersions.keySet());
        System.debug(ordenId2ContentVersions.keySet());

        for (String ordenId : ordenId2ContentVersions.keySet()) {
            for (ContentVersion cv : ordenId2ContentVersions.get(ordenId)) {
                ordenDocumentsDuplicateSet.add(cv.ContentDocumentId);
            }
        }

        for (String serviceId : expedientes.keySet()) {
            ServiceDocumentsPayload sdp = new ServiceDocumentsPayload();
            List<DocumentWrapper> serviceDocs = new List<DocumentWrapper>();
            if (expId2ContentVersions.containsKey(serviceId)) {
                for (ContentVersion cv : expId2ContentVersions.get(serviceId)) {
                    if (!ordenDocumentsDuplicateSet.contains(cv.ContentDocumentId)) {
                        serviceDocs.add(new DocumentWrapper(cv.Title, cv.TagCsv, cv.Id, cv.ContentSize));
                    }
                }   
            }
            sdp.serviceId = serviceId;
            sdp.serviceName = expedientes.get(serviceId).Name;
            sdp.serviceDocuments = serviceDocs;
            sdp.attConfig = expedienteId2Config.get(serviceId);
            for(String ordenId : ordenId2ContentVersions.keySet()) {
                System.debug(ordenId2ServiceId.get(ordenId));
                System.debug(serviceId);
                if(ordenId2ServiceId.get(ordenId) == serviceId) {
                    List<DocumentWrapper> ordenDocs = new List<DocumentWrapper>();
                    for(ContentVersion cv : ordenId2ContentVersions.get(ordenId)) {
                        ordenDocs.add(new DocumentWrapper(cv.Title, cv.TagCsv, cv.Id, cv.ContentSize));
                    }
                    OrdenDocumentsPayload odp = new OrdenDocumentsPayload();
                    odp.ordenId = ordenId;
                    odp.ordenDocuments = ordenDocs;
                    if(sdp.ordenPayload == null) {
                        sdp.ordenPayload = new List<OrdenDocumentsPayload> { odp };
                    } else {
                        sdp.ordenPayload.add(odp);
                    }
                    if(ordenId2ZipFileName.containsKey(ordenId)) {
                        odp.zipFileName = ordenId2ZipFileName.get(ordenId) + '.zip';
                    } else {
                        odp.zipFileName = 'zip_'+ordenId+'.zip';
                    }
                    if(ordenId2ConcatFileName.containsKey(ordenId)) {
                        odp.concatFileName = ordenId2ConcatFileName.get(ordenId) + '.pdf';
                    } else {
                        odp.concatFileName = 'concat_' + ordenId + '.pdf';
                    }
                    if(ordenId2SubjectName.containsKey(ordenId)) {
                        odp.emailSubject = ordenId2SubjectName.get(ordenId);
                    } else {
                        odp.emailSubject = 'null subject';
                    }
                    if(ordenId2Body.containsKey(ordenId)) {
                        odp.emailBody = ordenId2Body.get(ordenId);
                    } else {
                        odp.emailBody = 'null body';
                    }
                }
            }
            sdps.add(sdp);
        }
       for(ServiceDocumentsPayload p : sdps ){
          for(DocumentWrapper d : p.serviceDocuments){
              System.debug(d);
          }
       }
    	System.debug('sdps' +sdps);
        System.debug('serialize' +JSON.serialize(sdps));
        return JSON.serialize(sdps);
    }

    @AuraEnabled
    public static String fetchContentVersion(String cvId) {
        System.debug(cvId);
        String retStr = '';
        List<ContentVersion> cv = [SELECT VersionData FROM ContentVersion WHERE Id =: cvId];

        if(!cv.isEmpty() && cv[0].VersionData != null ) {
            retStr = EncodingUtil.base64Encode(cv[0].VersionData);
        }

        return retStr;
    }

    @AuraEnabled
    public static void sendEmail(String title, String body, List<Object> attachments, string emailInfo) {
        System.debug('sendEmail');
        System.debug(title);
        System.debug(body);

        List<AttachmentWrapper> parsedAttachments = (List<AttachmentWrapper>)JSON.deserialize(JSON.serialize(attachments), List<AttachmentWrapper>.class);

        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { UserInfo.getUserEmail() };
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject(title);
        mail.setPlainTextBody(body);
        mail.setBccSender(false);
        mail.setUseSignature(false);

        List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
        for (Integer i = 0; i < parsedAttachments.size(); i++) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(parsedAttachments[i].fileName);
            System.debug(String.valueOf(parsedAttachments[i]));
            efa.setBody(EncodingUtil.base64Decode(String.valueOf(parsedAttachments[i].data)));
            efa.setContentType('application/pdf');
            atts.add(efa);
            System.debug('efa');
            System.debug(efa);
        }
        mail.setFileAttachments(atts);

        Messaging.SendEmailResult[] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        for(Messaging.SendEmailResult r : res) {
            System.debug(r);
        }
        if(emailInfo != null && emailInfo.length() > 50){
            id orderID= emailInfo.substring(emailInfo.indexOf('ordenId')+10, emailInfo.indexOf('ordenId') + 28);       
            System.debug('ORDER ID TO UPDATE STATUS-->' +orderID);
            updateEstado(orderID); 
        }

    }

    @AuraEnabled
    public static void updateEstado(String ordenId) {
        //List<String> ordenIds = (List<String>)JSON.deserialize(ordenIdsJs, List<String>.class);

        List<ONE_Orden_De_Venta__c> ordensToUpdate = [
            SELECT ONE_Estado_envio_Documentacion_Asegur__c,  ONE_Fecha_envio_documentacion_asegurad__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id =:ordenId
        ];

        for (ONE_Orden_De_Venta__c ov : ordensToUpdate ) {
            if (ov.ONE_Estado_envio_Documentacion_Asegur__c == ONE_CommonConstants.ESTADO_ENVIADO) {
                ov.ONE_Estado_envio_Documentacion_Asegur__c = ONE_CommonConstants.ESTADO_REENVIADO;
            } else if(ov.ONE_Estado_envio_Documentacion_Asegur__c == ONE_CommonConstants.ESTADO_PENDIENTE) {
                ov.ONE_Estado_envio_Documentacion_Asegur__c = ONE_CommonConstants.ESTADO_ENVIADO;
            }
            ov.ONE_Fecha_envio_documentacion_asegurad__c = Datetime.now();
        }

        update ordensToUpdate;
    }

    public Class AttachmentWrapper {
        public String data { get; set; }
        public String fileName { get; set; }
    }

    public static Map<String, List<ContentVersion>> fetchContentVersions(Set<Id> entityIds, Boolean doNotIncludeFactura) {
        if(entityIds.isEmpty()) {
            return new Map<String, List<ContentVersion>>();
        }
        System.debug('entityIds');
        System.debug(entityIds);
        Set<String> contentDocumentIds = new Set<String>();

        Map<String, String> cdId2leId = new Map<String, String>();

        List<ContentDocumentLink> cdls = [
            SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: entityIds
        ];
        System.debug(cdls);

        for(ContentDocumentLink cdl : cdls) {
            contentDocumentIds.add(cdl.ContentDocumentId);
            cdId2leId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }

        Map<String, List<ContentVersion>> retMap = new Map<String, List<ContentVersion>>();
        List<String> allowedTags = getAllowedTagThatCanBeSendViaEmail();
        for (ContentVersion cv : [SELECT Id, TagCsv, Title, ContentDocumentId, ContentSize FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds]) {
            if (!allowedTags.contains(cv.TagCsv) || (doNotIncludeFactura && cv.TagCsv == ONE_CommonConstants.DOCUMENT_TAG_FACTURA_COMERCIAL)) {
                continue;
            }
            if(!retMap.containsKey(cdId2leId.get(cv.ContentDocumentId))) {
                retMap.put(cdId2leId.get(cv.ContentDocumentId), new List<ContentVersion> { cv });
            } else {
                retMap.get(cdId2leId.get(cv.ContentDocumentId)).add(cv);
            }
        }
        return retMap;
    }

    static List<String> getAllowedTagThatCanBeSendViaEmail() {
        return [SELECT ONE_Documentos_Requeridos__c FROM ONE_BillingCompanies_Configuration__mdt WHERE DeveloperName = :ALLOWED_DOCUMENTS_CB_CONFIGURATION_DEV_NAME]
                .ONE_Documentos_Requeridos__c.split(ALLOWED_DOCUMENTS_CB_CONFIGURATION_SEPARATOR);
    }

    public class ServiceDocumentsPayload {
        public String serviceId { get; set; }
        public String serviceName { get; set; }
        public List<DocumentWrapper> serviceDocuments { get; set; }
        public List<OrdenDocumentsPayload> ordenPayload { get; set; }
        public DocumentsAttachmentConfig attConfig { get; set; }
    }

    public class DocumentsAttachmentConfig {
        public List<String> individualTags { get; set; }
        public List<String> zippedTags { get; set; }
        public List<String> concatTags { get; set; }
    }

    public class OrdenDocumentsPayload {
        public String ordenId { get; set; }
        public List<DocumentWrapper> ordenDocuments { get; set; }
        public String zipFileName { get; set; }
        public String concatFileName { get; set; }
        public String emailBody { get; set; }
        public String emailSubject { get; set; }
    }

    public class DocumentWrapper {
        public String title;
        public String tag;
        public String contentVersionId;
        public Integer contentSize;

        public DocumentWrapper(String title, String tag, String contentVersionId, Integer contentSize) {
            this.title = title;
            this.tag = tag;
            this.contentVersionId = contentVersionId;
            this.contentSize = contentSize;
        }
    }

    public class InsuranceCompanyWrapper {
        public String Name;
        public String Id;
        public InsuranceCompanyWrapper(String Name, String Id) {
            this.Name = Name;
            This.Id = Id;
        }
    }

    public class FieldWrapper {
        public String fieldName { get; set; }
        public String label { get; set; }
        public String type { get; set; }

        public FieldWrapper(String fname, String flabel, String ftype) {
            fieldName = fname;
            label = flabel;
            type = fieldType2inputType.containsKey(ftype) ? fieldType2inputType.get(ftype) : ftype;
        }
    }
}
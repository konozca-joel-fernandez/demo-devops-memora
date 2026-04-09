/**
 * Created by mbujak003 on 02.03.2021.
 * Remaked by Miguel Serrat on 04.09.2023.
 * 
 * LOGs:
 * -------------------------------------------
 * DATE       USER            CHANGE
 * 23.02.23   Miguel Serrat   ORI-2525 // ORI-4867 : app data validation
 * 18.04.23   Miguel Serrat   ORI-5053 : Send service RecordType to APP
 * 19.04.23   Miguel Serrat   ORI-5053 : If service => ONE_Servicio_Consulta_De_Presupuesto do not check restrictions
 * 03.07.23   Miguel Serrat   ORI-4281 : Catálogos a fecha de creación de presupuesto envío del campo a la app
 * 14.10.24   Marc Pàmies	  ORI-6202 : Creación de SLI CB para productos de CB contratados des de la app
 * 15.04.25   Marc Pàmies	  ORI-6944 : Evitado devolver error 406 cuando es servicio simulación CIA
 * 08.05.25   Marc Pàmies	  ORI-6431 : Se añaden las flores de precio libre a la lista de productos sin completar para lanzar error 406
 * 20.05.25	  Marc Pàmies	  ORI-6884 : Se añade que en el campo de música
 * -------------------------------------------
 */

 //Integration service class endpoint used for the comercial app to send all information back to SF 
 //once the process is finish in the APP

@RestResource(UrlMapping='/synchronize')
global with sharing class ONE_SynchronizeWebService {
    
    private static List<SliDTO> appSLIs;
    private static Map<Decimal, ONE_Expediente_Line_Item__c> sliNumber2SLI;
    
    @HttpPost
    global static void synchronize() {
        String jsonStr = null;

        appSLIs = new List<SliDTO>();
        sliNumber2SLI = new Map<Decimal, ONE_Expediente_Line_Item__c>();

        if(RestContext.request.requestBody == null){
            RestContext.request.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('Body is missing!');
            RestContext.response.statusCode = 400;
            return;
        }

        jsonStr = RestContext.request.requestBody.toString();

        ServiceDTO appService = null;
        Savepoint sp = null;

        try {
            sp = Database.setSavepoint();
            appService = (ServiceDTO)JSON.deserialize(jsonStr, ServiceDTO.class);

            String codeError = upsertAppService(appService);

            if (codeError != '200'){
                if(codeError.contains('410')){
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf('DISCONTINUED PRODUCTS ' + codeError);
                    RestContext.response.statusCode = 410;
                    Database.rollback(sp);
                    return;
                }
                
                if(codeError.contains('406')){
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf('UNCOMPLETED PRODUCTS ' + codeError);
                    RestContext.response.statusCode = 406;
                    Database.rollback(sp);
                    return;
                } 
            }

            //pintamos el nuevo valor del id de las sli creadas.
            for(SliDTO appSLI : appSLIs) {
                //if (appSLI.Id != null) {
                    appSLI.Id = sliNumber2SLI.get(appSLI.SLINumber).Id;
                //}
            }
			
            for(QuoteDTO appQuote : appService.quotes) {
                if(appQuote.Id == appService.actualQuote) {
                    appQuote.SLI = appSLIs;
                    break;
                }
            }

            appService.clearImages();

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(appService));
            RestContext.response.statusCode = 200;

        } catch (Exception ex) {
            Map<String, String> responseBody = new Map<String, String> {
                'RequestBody' => jsonStr,
                'ErrorMessage' => ex.getMessage() + '\n' + ex.getStackTraceString()
            };
            System.debug('ERR: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            Database.rollback(sp);

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
            RestContext.response.statusCode = 400;

            /*
                ONE_IntegrationLog integrationLog = new ONE_IntegrationLog(
                    'SynchronizeWebService',
                    jsonStr,
                    JSON.serialize(responseBody),
                    'POST',
                    '/synchronize',
                    ONE_IntegrationLog.Direction.OUTBOUND
                );
                System.debug(ex.getMessage() + '\n' + ex.getStackTraceString());
                ONE_IntegrationLog.commitLog(integrationLog, true);
             */

        }
    }

    //tendría que ser update ¿?
    public static String upsertAppService(ServiceDTO appService) {

        ONE_Expediente__c service = mapService(appService);
        
        //Account deceased = mapDeceased(appService.); 
        //realmente es necesario ? no se tocan datos del difunto, por lo que llega = desde la app...
        //se podria añadir a la función de map service
        if (appService.IdDeceased != null && appService.IdDeceased != ''){
            service.ONE_Difunto__c = appService.IdDeceased;
        }

        upsert service;
        appService.Id = service.Id;

        //no se actualizan interlocutores en la app por lo que 
        //no se actualizan cuentas ni interlocutores

        //Solo actualizamos la quote que esta activa en la app
        QuoteDTO appActualQuote;
        ONE_Presupuesto__c actualQuote;
        
        if (!(appService.quotes == null || appService.quotes.isEmpty())) {
            for (QuoteDTO q : appService.quotes) {
                if (q.Id == appService.actualQuote){
                    appActualQuote = q;
                }
            }

            actualQuote = mapQuote(appActualQuote, service.Id);
            upsert actualQuote;
        }

        //no actualizamos docId de los interlocutores => docNumber2Interlocutor
        
        List<SignatureDTO> signatures = new List<SignatureDTO>();
        
        signatures = appActualQuote.Signatures;

        if(!signatures.isEmpty()) {
            buildFiles(actualQuote.Id, signatures);
        }

        Map<Integer, SliDTO> tempId2SliDTO2 = new Map<Integer, SliDTO>();

        Integer tempSliId = 1000;
        if(service.Id != null && actualQuote.Id != null) {
            if(appActualQuote.SLI != null) {
                for(SliDTO appSLI : appActualQuote.SLI) {
                    tempId2SliDTO2.put(tempSliId, appSLI);
                    tempSliId++;
                }
            }
        }

        if(!tempId2SliDTO2.isEmpty()) {
            System.debug('NOT EMPTY: ' + tempId2SliDTO2);
            Map<Integer, ONE_Expediente_Line_Item__c> index2Sli = new Map<Integer, ONE_Expediente_Line_Item__c>();
            Map<Integer, List<SignatureDTO>> index2Attachments = new Map<Integer, List<SignatureDTO>>();
            
            Set<String> productIds = new Set<String>();
            Set<String> typologyIds = new Set<String>();
            Map<String, Map<String, ONE_Atributo__c>> typologyAttbs = new Map<String, Map<String, ONE_Atributo__c>>();

            Map<String, String> discontinuedProducts = new Map<String,String>();
            Map<String, ONE_Producto__c> allProducts = new Map<String,ONE_Producto__c>();
            
            //GET all the products Ids from the quote that are not cancelled
            for (SliDTO appSLI : tempId2SliDTO2.values()){
                if (appSLI.status != 'Cancelado') productIds.add(appSLI.productId);
            }
            System.debug('Product IDS: ' + productIds);

            //GET from the products in the quote all the info of all of them and those that are discontinued. And the Typologies used.
            for (ONE_Producto__c prod : [SELECT Id, ONE_Descripcion_En_Castellano__c, ONE_Estado__c, ONE_Tipologia_De_Producto_Lookup__c, ONE_C_digo_CB__c 
                                         FROM ONE_Producto__c 
                                         WHERE Id IN :productIds]){
                if (prod.ONE_Estado__c == 'Descatalogado') {
                    discontinuedProducts.put(prod.Id, prod.ONE_Descripcion_En_Castellano__c);
                }
                allProducts.put(prod.Id, prod);
                typologyIds.add(prod.ONE_Tipologia_De_Producto_Lookup__c);
            }
            System.debug('ALL PRODUCTS: ' + allProducts);

            //GET all the attributes from the typologies
            for (ONE_Atributo__c attb : [
                SELECT Id, ONE_Tipologia_De_Producto__c, ONE_Requerido__c, ONE_Campo_En_SF__c 
                FROM ONE_Atributo__c 
                WHERE ONE_Tipologia_De_Producto__c IN :typologyIds]) {
                if (typologyAttbs.get(attb.ONE_Tipologia_De_Producto__c) != null) {
                    typologyAttbs.get(attb.ONE_Tipologia_De_Producto__c).put(attb.ONE_Campo_En_SF__c, attb);
                } else {
                    Map<String, ONE_Atributo__c> aux = new Map<String, ONE_Atributo__c>();
                    aux.put(attb.ONE_Campo_En_SF__c, attb);
                    typologyAttbs.put(attb.ONE_Tipologia_De_Producto__c, aux);
                }
            }

            List<String> discontinuedProductNamesToReturn = new List<String>();
            Set<String> uncompletedProductNamesToReturn = new Set<String>();
            Set<String> allSliIds = new Set<String>();

            //esto no se usa realmente
            List<SliDTO> parentSLIs = new List<SliDTO>();
            List<SliDTO> childSLIs = new List<SliDTO>();
                
            //FLORES A COMPROBAR SI SON PRECIO LIBRE
            List<Id> flowerIdProducts = new List<Id>();
            Id flowerTypoId = [SELECT Id FROM ONE_Tipologia_Producto__c WHERE Name = 'Flores' LIMIT 1].Id;

            for(SliDTO appSLI : tempId2SliDTO2.values()) {
                //LIMPIAMOS ID SI VEMOS QUE ES ID CREADO POR APP
                if (appSLI.Id != null && appSLI.Id.contains('newSLI')) {
                    appSLI.Id = null;
                }

                //COGER LOS ID QUE EXISTEN
                allSliIds.add(appSLI.Id);
                appSLIs.add(appSLI);

                //CLASIFICACIÓN PADRE-HIJO
                if (appSLI.parentSLINumber == null) {
                    parentSLIs.add(appSLI);
                } else {
                    childSLIs.add(appSLI);
                }                
                
                //CONTROL DE RESTRICCIONES
                
                if (appSLI.status != 'Cancelado' ){
                    if (discontinuedProducts.keyset().contains(appSLI.productId)){
                        System.debug('PRODUCTO DESCATALOGADO ' + appSLI.productId);
                        discontinuedProductNamesToReturn.add(discontinuedProducts.get(appSLI.productId));
                    }
                    String typo = allProducts.get(appSLI.productId).ONE_Tipologia_De_Producto_Lookup__c;
                    Boolean comentariosEmpty = false;
     				//the app checks the if part but not the else 
                    if (appSLI.Atributos.size() > 0) {
                        for (AtributoDTO attb : appSLI.Atributos){
                            Boolean exceptionRequired = false;
                            if (typologyAttbs.get(typo).get(attb.APIName).ONE_Requerido__c && attb.Value == null){
                                if(attb.APIName == 'ONE_Texto_Banda_O_Lazo__c'){
                                    for(AtributoDTO attb2 : appSLI.Atributos){
                                        if(attb2.APIName == 'ONE_Tarjeta_O_Lazo__c' && attb2.Value == '_Sin dedicatoria'){
                                            exceptionRequired = true;
                                        }
                                    }
                                }
                                if(!exceptionRequired){
                                    uncompletedProductNamesToReturn.add(allProducts.get(appSLI.productId).ONE_Descripcion_En_Castellano__c);
                                }   
                            }
                            if(attb.APIName == 'ONE_Comentarios__c' && attb.Value == null){
                                    comentariosEmpty = true;
                            }
                        }
                    }
                    else {
                        Boolean hasRequirements = false;
                        integer i = 0;
                        if(!typologyAttbs.isEmpty() && typologyAttbs.containsKey(typo)){
                            List<ONE_Atributo__c> attbs = typologyAttbs.get(typo).values();
                            while (!hasRequirements && i < typologyAttbs.get(typo).size()){
                                if (attbs[i].ONE_Requerido__c){
                                    hasRequirements = true;
                                    uncompletedProductNamesToReturn.add(allProducts.get(appSLI.productId).ONE_Descripcion_En_Castellano__c);
                                }
                                ++i;
                            }
                        }
                    }
                    if (typo == flowerTypoId && !uncompletedProductNamesToReturn.contains(allProducts.get(appSLI.productId).ONE_Descripcion_En_Castellano__c) && comentariosEmpty){
                        flowerIdProducts.add(appSLI.productId);
                    }
                }
            }

            uncompletedProductNamesToReturn.addAll(checkFreePriceFlowers(flowerIdProducts));

            if (!discontinuedProductNamesToReturn.isEmpty()){	
                String discontinuedList = string.join(discontinuedProductNamesToReturn,'#$#');	
                return '410 |' + discontinuedList;	
            }

            if (appService.serviceRecordType != 'ONE_Servicio_Consulta_De_Presupuesto' && appService.serviceRecordType != 'ONE_Servicio_Compania' && !uncompletedProductNamesToReturn.isEmpty()){	
                String uncompletedList = string.join(new List<String>(uncompletedProductNamesToReturn),'#$#');	
                return '406 |' + uncompletedList;	
            }         
            
            for(SliDTO appSLI : tempId2SliDTO2.values()) {
                allSliIds.add(appSLI.Id);
            }

            List<ONE_Expediente_Line_Item__c> SLIs = new List<ONE_Expediente_Line_Item__c>();

            for(Integer appSliId : tempId2SliDTO2.keySet()) {

                SliDTO appSLI = tempId2SliDTO2.get(appSliId);
                ONE_Expediente_Line_Item__c newsli = mapSLI(appSLI, actualQuote.Id, service.Id);

                SLIs.add(newsli);
                //index2Attachments.put(localIndex, sdto.Attachment);

                index2Sli.put(appSliId-1000, newsli);
            }

            upsert SLIs;
            
            if (appService.centroCementiris!= null && appService.centroCementiris == true) {
                createSLICB(SLIs);
            }
            
            for(ONE_Expediente_Line_Item__c sli : SLIs){
                sliNumber2SLI.put(sli.ONE_Numero_SLI__c, sli);
            }
        }

        return '200';
    }

    public static List<String> checkFreePriceFlowers(List<Id> flowerIdProducts){
        List<String> freePriceFlowers = new List<String>();
        for (ONE_Producto__c prod : [SELECT Id, ONE_Descripcion_En_Castellano__c FROM ONE_Producto__c WHERE Id IN :flowerIdProducts AND ONE_Precio_Libre__c = true]){
            freePriceFlowers.add(prod.ONE_Descripcion_En_Castellano__c);
        }
        return freePriceFlowers;
    }
    
    public static void createSLICB(List<ONE_Expediente_Line_Item__c> SLIs){
        //DECLARACIÓN
        Boolean sendMail = false;
        ONE_Presupuesto__c presupuesto;
        List<String> productsWithCBCode = new List<String>();
        List<String> allProductsIds = new List<String>();
		List<ONE_SLI_Producto_CB__c> productToSLICBList = new List<ONE_SLI_Producto_CB__c>();
        List<ONE_Producto__c> allProductsList = new List<ONE_Producto__c>();
        List<ONE_Producto__c> cbProducts = new List<ONE_Producto__c>();
        List<ONE_SLI_Producto_CB__c> SLICBToCreate = new List<ONE_SLI_Producto_CB__c>();
        List<ONE_SLI_Producto_CB__c> SLICBToDelete = new List<ONE_SLI_Producto_CB__c>();
        Map<Id,Id> productCBToSLICBMap = new Map<Id,Id>();
        Map<String, ONE_Producto__c> AllProductsMap = new Map <String, ONE_Producto__c>();
        Map<String, String> codigoCBToProdCBId = new Map<String, String>();
        //ASIGNACIÓN
        presupuesto = [SELECT Id, Name, Owner.Email, Productos_Recuperados_CB__c, ONE_Codigo_Titular_CB__r.Id FROM ONE_Presupuesto__c WHERE Id = :SLIs[0].ONE_Presupuesto__c];
        productToSLICBList = [SELECT ONE_Producto__c, Id, Name FROM ONE_SLI_Producto_CB__c WHERE ONE_Presupuesto__c = :SLIs[0].ONE_Presupuesto__c AND ONE_Producto__c != NULL];
        for (ONE_Expediente_Line_Item__c SLI : SLIs){
            allProductsIds.add(SLI.ONE_Producto__c);
        }
        allProductsList = [SELECT Id, ONE_C_digo_CB__c FROM ONE_Producto__c WHERE Id IN :allProductsIds];
        for(ONE_SLI_Producto_CB__c SLICB : productToSLICBList){
            productCBToSLICBMap.put(SLICB.ONE_Producto__c, SLICB.Id);
        }
        for (ONE_Producto__c p : allProductsList){
            AllProductsMap.put(p.Id, p);
            if (p.ONE_C_digo_CB__c != null){
                productsWithCBCode.add(p.ONE_C_digo_CB__c);
            }
        }
        cbProducts = [SELECT Id, ONE_Codigo_Comercial__c FROM ONE_Producto__c WHERE ONE_Codigo_Comercial__c IN :productsWithCBCode AND ONE_Cementiris_De_Barcelona__c = true];
        for (ONE_Producto__c cbProd : cbProducts){
            codigoCBToProdCBId.put(cbProd.ONE_Codigo_Comercial__c, cbProd.Id);
        }
        //LÓGICA
        for (ONE_Expediente_Line_Item__c SLI : SLIs){
            ONE_Producto__c auxProd = AllProductsMap.get(SLI.ONE_Producto__c);
            if (SLI.ONE_Estado__c == 'Cancelado' && productCBToSLICBMap.get(codigoCBToProdCBId.get(auxProd.ONE_C_digo_CB__c)) != null) {
                ONE_SLI_Producto_CB__c auxCB = new ONE_SLI_Producto_CB__c(
                	Id = productCBToSLICBMap.get(codigoCBToProdCBId.get(auxProd.ONE_C_digo_CB__c))
                );
                SLICBToDelete.add(auxCB);
                sendMail = true;
            }
            else if (auxProd != null && SLI.ONE_Estado__c != 'Cancelado'){
                if (auxProd.ONE_C_digo_CB__c != null && auxProd.ONE_C_digo_CB__c != ''){
                    ONE_SLI_Producto_CB__c auxSLICB = new ONE_SLI_Producto_CB__c();
                    auxSLICB.Id = productCBToSLICBMap.get(codigoCBToProdCBId.get(auxProd.ONE_C_digo_CB__c));
                    auxSLICB.ONE_Presupuesto__c = SLI.ONE_Presupuesto__c;
                    auxSLICB.ONE_Producto__c = codigoCBToProdCBId.get(auxProd.ONE_C_digo_CB__c);
                    auxSLICB.ONE_Titular_SLI_CB__c = presupuesto.ONE_Codigo_Titular_CB__r.Id;
                    auxSLICB.ONE_Unidades__c = SLI.ONE_Cantidad__c;
                    auxSLICB.ONE_Porcentaje_IVA__c = SLI.ONE_Impuesto__c;
                    auxSLICB.ONE_Importe_Base__c = SLI.ONE_Suplido__C ? SLI.ONE_Importe_Neto__c : SLI.ONE_Importe_Base__c;
                    auxSLICB.ONE_Importe_IVA__c = SLI.ONE_Importe_Impuesto__c;
                    auxSLICB.ONE_Importe_Neto_Total__c = SLI.ONE_Importe_Neto__c;
                    SLICBToCreate.add(auxSLICB);
                    if (!sendMail && auxSLICB.Id == null){
                        sendMail = true;
                    }
                }
            }
        }
        upsert SLICBToCreate;
        delete SLICBToDelete;
        if (sendMail){
            sendCBMail(presupuesto);
        }
    }
    
    public static void sendCBMail(ONE_Presupuesto__c presupuesto){
        //if (presupuesto.Productos_Recuperados_CB__c)
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new String[] { presupuesto.Owner.Email });
        mail.setSenderDisplayName('Salesforce Support');
        mail.setUseSignature(false);
        mail.setBccSender(false);
        
        mail.setSubject('Se han realizado cambios en los productos de cementiris');
        String resourceURL = URL.getOrgDomainUrl().toExternalForm() + '/' + presupuesto.Id;
        mail.setPlainTextBody('Es necesario reenviar el presupuesto ' + presupuesto.Name + ' al sistema de SFB: ' + resourceURL);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        if (results[0].success)
        {
            System.debug('The email was sent successfully.');
        }
        else
        {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
    public static String nvlId(String toCheck) {
        return toCheck == null || toCheck == '' ? null : toCheck;
    }
    //DateTime parser method
     public static DateTime buildDateTime(String dateString) {
        if(dateString == null || dateString == '') {
            return null;
        }
        String dtString = dateString;
        try {
            if(dtString.containsIgnoreCase('T')) {
                dtString = dateString.replace('T', ' ');
                dtString += ':0';
            } else {
                return Datetime.newInstanceGmt(buildDate(dateString), Time.newInstance(0, 0, 0, 0));
            }

            return Datetime.valueOfGmt(dtString);
        } catch (Exception ex) {
            throw new SynchronizationException('bad date/time format');
        }
    }
	//Data parser method
    public static Date buildDate(String dateString) {
        if(dateString == null || dateString == '') {
            return null;
        }
        try {
            return Date.valueOf(dateString);
        } catch (Exception ex) {
            throw new SynchronizationException('bad date format');
        }
    }
	//Boolean parser method
    public static Boolean buildBoolean(String booleanString) {
        if(booleanString == null || booleanString == '' || booleanString == 'false') {
            return false;
        }
        else {
            return true;
        }
    }

    //Build expedient register using request information
    public static ONE_Expediente__c mapService(ServiceDTO appService) {
        ONE_Expediente__c service;
        
        System.debug('appService.Id: '+ appService.Id);

        if(appService.Id != null && appService.Id != ''){
            service = new ONE_Expediente__c(Id = appService.Id);
        } /*else {
            //OBSOLETA, ya que actualmente no se pueden crear servicios desde la app
            service = new ONE_Expediente__c();
            service.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.EXPEDIENTE, ONE_CommonConstants.EXP_RT_SERVICIO_DEFUNC);
            Integer genId = generateId();
            tempId2ServiceDTO.put(genId, appService);
            tempId2ServiceRec.put(genId, service);
        }*/

        //service.ONE_Tipo_De_Difunto__c = appService.deceasedType;
        //service.ONE_Servicio__c = appService.clientType;
        //service.ONE_Tipo_De_Servicio__c = appService.serviceType;
        //service.ONE_Capital__c = appService.capital;
        //service.ONE_Segmento_Seleccionado__c = nvlId(appService.SegmenttId);
        //service.ONE_Acuerdo_Comercial__c = nvlId(appService.AgreementId);
        //service.ONE_Segmentacion__c = appService.segmentType;
        //service.ONE_Catalogo_De_Precios__c = nvlId(appService.priceParticularId);
        //service.ONE_Catalogo_De_Precios_Acuerdo__c = nvlId(appService.priceAgreementId);
        //service.ONE_Idioma__c = appService.language;
        //service.ONE_Lugar_De_Velacion__c = nvlId(appService.IdVelacion);
        //service.ONE_Inicio_Velacion__c = buildDateTime(appService.StartVelacion);
        //service.ONE_Fin_Velacion__c = buildDateTime(appService.EndVelacion);
        //service.ONE_Direccion_Velacion__c = appService.AddressVelacion;
        //service.ONE_Codigo_Postal_Velacion__c = appService.PostalCodeVelacion;
        //service.ONE_Municipio_Velacion__c = appService.CityVelacion;
        //service.ONE_Provincia_Velacion__c = appService.ProvinceVelacion;
        //service.ONE_Pais_Velacion__c = appService.CountryVelacion;
        //service.ONE_Lugar_Ceremonia__c = nvlId(appService.IdCeremonia);
        //service.ONE_Inicio_Ceremonia__c = buildDateTime(appService.StartCeremonia);
        //service.ONE_Fin_Ceremonia__c = buildDateTime(appService.EndCeremonia);
        //service.ONE_Direccion_Ceremonia__c = appService.AddressCeremonia;
        //service.ONE_Codigo_Postal_Ceremonia__c = appService.PostalCodeCeremonia;
        //service.ONE_Municipio_Ceremonia__c = appService.CityCeremonia;
        //service.ONE_Provincia_Ceremonia__c = appService.ProvinceCeremonia;
        //service.ONE_Pais_Ceremonia__c = appService.CountryCeremonia;
        //service.ONE_Lugar_Incineracion__c = nvlId(appService.IdCrematorio);
        //service.ONE_Inicio_Incineracion__c = buildDateTime(appService.StartCrematorio);
        //service.ONE_Fin_Incineracion__c = buildDateTime(appService.EndCrematorio);
        //service.ONE_Direccion_Incineracion__c = appService.AddressCrematorio;
        //service.ONE_Codigo_Postal_Incineracion__c = appService.PostalCodeCrematorio;
        //service.ONE_Municipio_Incineracion__c = appService.CityCrematorio;
        //service.ONE_Priovincia_Incineracion__c = appService.ProvinceCrematorio;
        //service.ONE_Pais_Incineracion__c = appService.CountryCrematorio;
        //service.ONE_Destino_Final__c = nvlId(appService.IdFinalDestination);
        //service.ONE_Hora_Destino_Final__c = buildDateTime(appService.StartFinalDestination);
        //service.ONE_Direccion_Destino_Final__c = appService.AddressFinalDestination;
        //service.ONE_Codigo_Postal_Destino_Final__c = appService.PostalCodeFinalDestination;
        //service.ONE_Municipio_Destino_Final__c = appService.CityFinalDestination;
        //service.ONE_Provincia_De_Defuncion__c = appService.ProvinceDeceasedPlace;
        //service.ONE_Pais_De_Defuncion__c = appService.CountryDeceasedPlace;
        //service.ONE_Numero_de_Siniestro__c = appService.SiniestroNumber;
        //service.ONE_Numero_de_Poliza__c = appService.PolizaNumber;
        //service.ownerId = nvlId(appService.IdServiceOwner);
        //service.ONE_Codigo_Postal_De_Defuncion__c = appService.PostalCodeDeceasedPlace;
        //service.ONE_Municipio_De_Defuncion__c = appService.CityFinalDeceasedPlace;
        //service.ONE_Centro_Del_Expediente__c = nvlId(appService.IdServiceWorkPLace);
        //service.ONE_Lugar_De_Defuncion__c = nvlId(appService.IdDeceasedPlace);
        //service.ONE_Direccion_De_Defuncion__c = appService.AddressDeceasedPlace;
        //service.ONE_Pais_Destino_Final__c = appService.CountryFinalDestination;
        service.ONE_Contador_SLI__c = appService.SLICounter;

        return service;
    }

    public static ONE_Presupuesto__c mapQuote(QuoteDTO appQuote, String serviceId) {
        //NO SE PUEDEN CREAR PRESUPUESTOS DESDE LA APP
        ONE_Presupuesto__c quote;
        
       	if(appQuote.Id != null && appQuote.Id != ''){
            quote = new ONE_Presupuesto__c(Id = appQuote.Id);
        } 
        
        //no aplica ya que no se pueden cambiar los interlocutores
        //no haría falta actualizarlo
        if (appQuote.interlocutorId != null && appQuote.interlocutorId != '') {
            quote.ONE_Interlocutor__c = appQuote.interlocutorId;
        } /*else {
            if(numberId2InterlocutorId.containsKey(qdto.interlocutorDocNumber)) {
                quote.ONE_Interlocutor__c = numberId2InterlocutorId.get(qdto.interlocutorDocNumber);
            }
        }*/

        quote.ONE_Tipo_De_Presupuesto__c = appQuote.quoteType;
        quote.ONE_Estado__c = appQuote.status;
        quote.ONE_Expediente__c = serviceId;
        quote.ONE_Total_Importe_Presupuesto__c = appQuote.totalAmount;
        quote.ONE_Tipo_De_Venta__c = appQuote.salesType;
        quote.ONE_Tipo_De_Contrato__c = appQuote.typeOfContract;
        quote.ONE_Metodo_De_Pago__c = appQuote.paymentMethod;
        quote.ONE_Presupuesto_preconfigurado__c = appQuote.preconfigured;
        quote.ONE_Tipo_De_Descuento_De_Cabecera__c = appQuote.discountType;
        quote.ONE_Valor_Del_Descuento__c = appQuote.valueDiscount;
        quote.ONE_Importe_Descuento_Cabecera__c = appQuote.freeprice;
        quote.ONE_Motivo_Del_Descuento__c = appQuote.discountReason;
        quote.ONE_Creation_Date__c = buildDate(appQuote.CreatedDate);
        quote.ONE_Importe_Base__c = appQuote.BaseAmount;
        if (appQuote.QuoteOwner != null && appQuote.QuoteOwner != '') {
            quote.OwnerId = appQuote.QuoteOwner;
        }
        quote.ONE_Importe_Base_21__c = appQuote.BaseAmount21;
        quote.ONE_Importe_Base_10__c = appQuote.BaseAmount10;
        quote.ONE_Importe_Base_4__c = appQuote.BaseAmount4;
        quote.ONE_Importe_Base_0__c = appQuote.BaseAmount0;
        quote.ONE_Importe_Base_3__c = appQuote.BaseAmount3;
        quote.ONE_Importe_Base_Suplido__c = appQuote.BaseAmountSuplido;
        quote.ONE_Importe_Impuesto_21__c = appQuote.TaxAmount21;
        quote.ONE_Importe_Impuesto_10__c = appQuote.TaxAmount10;
        quote.ONE_Importe_Impuesto_4__c = appQuote.TaxAmount4;
        quote.ONE_Importe_Impuesto_0__c = appQuote.TaxAmount0;
        quote.ONE_Importe_Impuesto_3__c = appQuote.TaxAmount3;
        quote.ONE_Importe_Impuesto_Suplido__c = appQuote.TaxAmountSuplido;
        quote.ONE_Importe_Neto_21__c = appQuote.NetAmount21;
        quote.ONE_Importe_Neto_10__c = appQuote.NetAmount10;
        quote.ONE_Importe_Neto_4__c = appQuote.NetAmount4;
        quote.ONE_Importe_Neto_0__c = appQuote.NetAmount0;
        quote.ONE_Importe_Neto_3__c = appQuote.NetAmount3;
        quote.ONE_Importe_Neto_Suplido__c = appQuote.NetAmountSuplido;

        return quote;
    }

    public static ONE_Expediente_Line_Item__c mapSLI(SliDTO appSLI, String activeQuoteId, String serviceId){

        ONE_Expediente_Line_Item__c newsli;

        if(appSLI.Id != null && appSLI.Id != ''){
            newsli = new ONE_Expediente_Line_Item__c(Id = appSLI.Id);
        } else {
            newsli = new ONE_Expediente_Line_Item__c();
        }

        newsli.ONE_Producto__c = nvlId(appSLI.productId);
        newsli.ONE_Presupuesto__c = activeQuoteId;
        newsli.ONE_Expediente__c = serviceId;
        newsli.ONE_Cantidad__c = appSLI.quantity;
        newsli.ONE_Estado__c = appSLI.status;
        newsli.ONE_Entrada_De_Precio__c = nvlId(appSLI.pricelisEntryId);
        newsli.ONE_Modelo__c = nvlId(appSLI.modelId);
        newsli.ONE_Tipo_De_Descuento_De_Posicion__c = appSLI.discountType;
        newsli.ONE_Valor_Del_Descuento_Posicion__c = appSLI.discountvalue;
        newsli.ONE_Importe_Descuento_Posicion__c = appSLI.freePrice;
        newsli.ONE_Motivo_Del_Descuento_De_Linea__c = appSLI.discountReason;
        newsli.ONE_Importe_Base__c = appSLI.Suplido? 0 : appSLI.basePrice;
        newsli.ONE_Importe_Impuesto__c = appSLI.taxPrice;
        newsli.ONE_Importe_Neto__c = appSLI.netPrice;
        newsli.ONE_Precio__c = appSLI.PriceList;
        newsli.ONE_Impuesto__c = appSLI.tax;
        newsli.ONE_Importe_Descuento_Posicion__c = appSLI.discountPrice != '' && appSLI.discountPrice != null ? Decimal.valueOf(appSLI.discountPrice) : 0;        
        newsli.ONE_Categorizacion_De_Linea__c = appSLI.lineCategory;
        newsli.ONE_Suplido__c = appSLI.Suplido;
        newsli.ONE_Categorizacion_De_Linea__c = appSLI.lineCategory;
        newsli.ONE_Suplido__c = appSLI.Suplido;
        newsli.ONE_No_Servir__c = appSLI.NoServir == true ? true : false;
        newsli.ONE_Mejora_De_Compania__c = appSLI.MejoraCompania == true ? true : false;
        newsli.ONE_Asesor_Responsable_De_La_Venta__c = appSLI.OwnerSLI == null || appSLI.OwnerSLI == '' ? UserInfo.getUserId() : appSLI.OwnerSLI;
        newsli.ONE_Numero_SLI__c = appSLI.SLINumber;
        newsli.ONE_Numero_SLI_Padre__c = appSLI.parentSLINumber;
        newsli.ONE_PosicionCB__c = appSLI.posicionCB != null ? appSLI.posicionCB : false;

        //ATRIBUTOS:
        SObjectType r = ((SObject)(Type.forName('Schema.'+ONE_CommonConstants.EXPEDIENTE_LINE_ITEM).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();

        if(appSLI.Atributos != null) {
            for(AtributoDTO appAttribute : appSLI.Atributos) {
                Type t;
                try {
                    t = ONE_CommonUtils.dispType2Type.get(d.fields.getMap().get(appAttribute.APIName).getDescribe().getType());
                } catch(Exception ex) {
                    throw new SynchronizationException(String.format(
                        'Cannot map value {0} to field {1} on object {2}',
                        new List<String> { appAttribute.Value, appAttribute.APIName, 'ONE_Expediente_Line_Item__c'}
                    ));
                }
                if(t == Datetime.class) {
                    newsli.put(appAttribute.APIName, buildDateTime(appAttribute.Value));
                } else if(t == Date.class) {
                    newsli.put(appAttribute.APIName, buildDate(appAttribute.Value));
                } else if(t == Boolean.class) {
                    newsli.put(appAttribute.APIName, buildBoolean(appAttribute.Value));
                } else {
                    if (appAttribute.APIName == 'ONE_Piezas_Seleccionadas__c'){
                        if (appAttribute.Value != null) newsli.put(appAttribute.APIName, String.valueOf('<p>' + appAttribute.Value.substring(0, appAttribute.Value.length() - 1)).replace('\n', '</p><p>'));
                    }
                    else {
                        newsli.put(appAttribute.APIName, JSON.deserialize(JSON.serialize(appAttribute.Value), t));
                    }
                }
            }
        }

        return newsli;
    }

    //Build signature image for the contract and documents sign
    public static void buildFiles(Id recordId, List<SignatureDTO> relatedFiles) {
        Map<Integer, ContentVersion> index2ContentVersion = new Map<Integer, ContentVersion>();
        Map<Integer, ContentDocumentLink> index2ContentDocumentLink = new Map<Integer, ContentDocumentLink>();
        
        for(Integer index = 0; index < relatedFiles.size(); index++) {
            SignatureDTO sdto = relatedFiles[index];
            if((sdto.DocName == null || sdto.DocName == '' || sdto.Bas64Content == null || sdto.Bas64Content == Blob.valueOf(''))) {
                continue;
            }
            
            index2ContentVersion.put(index, new ContentVersion(
                ContentLocation = 'S',
                VersionData = sdto.Bas64Content,
                Title = sdto.DocName,
                PathOnClient = sdto.DocName
            ));
            
            index2ContentDocumentLink.put(index, new ContentDocumentLink(
                ShareType = 'I',
                LinkedEntityId = recordId
            ));
        }
        
        insert index2ContentVersion.values();
        Map<Id, ContentVersion> Id2CV = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: index2ContentVersion.values()]);

        for(Integer index : index2ContentDocumentLink.keySet()) {
            index2ContentDocumentLink.get(index).ContentDocumentId = Id2CV.get(index2ContentVersion.get(index).Id).ContentDocumentId;
        }
        insert index2ContentDocumentLink.values();
    }

    /* ---------------------------------------------------------------------------------- */

    //Difunto data structure object definition
    public class DifuntoDTO {
        public String Id { get; set; }
        public String nameDeceased { get; set; }
        public String surnameDeceased { get; set; }
        public String typeDoc { get; set; }
        public String numberDoc { get; set; }
        public String birthDate { get; set; }
        public String deceasedDate { get; set; }
    }
	//Interlocutor data structure object definition
    public class InterlocutorDTO {
        public String interlocutorId { get; set; }
        public String IdContact { get; set; }
        public String ServiceId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public Boolean Declarante { get; set; }
        public String AddressInterlocutor { get; set; }
        public String PostalCodeInterlocutor { get; set; }
        public String CityInterlocutor { get; set; }
        public String ProvinceInterlocutor { get; set; }
        public String CountryInterlocutor { get; set; }
        public String relation { get; set; }
        public String clasification { get; set; }
        public String DocTypeInterlocutor { get; set; }
        public String EmailInterlocutor { get; set; }
        public String PhoneInterlocutor { get; set; }
        public String NumberId { get; set; }
    }
	//Quote data structure object definition
    public class QuoteDTO {
        public String Id { get; set; }
        public String interlocutorDocNumber { get; set; }
        public String ServiceId { get; set; }
        public String QuoteNumber { get; set; }
        public String quoteType { get; set; }
        public String status { get; set; }
        public Decimal BaseAmount { get; set; }
        public Decimal totalAmount { get; set; }
        public String salesType { get; set; }
        public String interlocutorId { get; set; }
        public String typeOfContract { get; set; }
        public String paymentMethod { get; set; }
        public Boolean preconfigured { get; set; }
        public String discountType { get; set; }
        public Decimal valueDiscount { get; set; }
        public Decimal freeprice { get; set; }
        public String discountReason { get; set; }
        public String CreatedDate { get; set; }
        public String QuoteOwner { get; set; }
        public Decimal BaseAmount21 { get; set; }
        public Decimal BaseAmount10 { get; set; }
        public Decimal BaseAmount4 { get; set; }
        public Decimal BaseAmount0 { get; set; }
        public Decimal BaseAmount3 { get; set; }
        public Decimal BaseAmountSuplido { get; set; }
        public Decimal TaxAmount21 { get; set; }
        public Decimal TaxAmount10 { get; set; }
        public Decimal TaxAmount4 { get; set; }
        public Decimal TaxAmount0 { get; set; }
        public Decimal TaxAmount3 { get; set; }
        public Decimal TaxAmountSuplido { get; set; }
        public Decimal NetAmount21 { get; set; }
        public Decimal NetAmount10 { get; set; }
        public Decimal NetAmount4 { get; set; }
        public Decimal NetAmount0 { get; set; }
        public Decimal NetAmount3 { get; set; }
        public Decimal NetAmountSuplido { get; set; }
        public List<SignatureDTO> Signatures { get; set; }
        public List<SliDTO> SLI { get; set; }
        public Boolean CapitalExceeded { get; set; }
        public Boolean validateCapital { get; set; }
        public Boolean usesOriginalPricecatalog { get; set; }
		
        public void clearImages() {
            if(Signatures != null) {
                for(SignatureDTO sigDTO : Signatures) {
                    sigDTO.clearImage();
                }
            }
            if(SLI != null) {
                for(SliDTO sDTO : SLI) {
                    sDTO.clearImages();
                }
            }
        }
    }
	//Atributo data structure object definition
    public class AtributoDTO {
        public String APIName { get; set; }
        public String Value { get; set; }
    }
	//Signature data structure object definition
    public class SignatureDTO {
        public String DocName { get; set; }
        public Blob Bas64Content { get; set; }
        public SignatureDTO(String dName, String b64) {
            DocName = dName;
            Bas64Content = Blob.valueOf(b64);
        }
        public SignatureDTO() {}
        public void clearImage() {
            this.Bas64Content = null;
        }
    }
	//Service line item data structure object definition
    public class SliDTO {
        public String Id { get; set; }
        public String productId { get; set; }
        public String modelId { get; set; }
        public Decimal quantity { get; set; }
        public String status { get; set; }
        public String pricelisEntryId { get; set; }
        public String discountType { get; set; }
        public Decimal discountvalue { get; set; }
        public Decimal freePrice { get; set; }
        public String discountReason { get; set; }
        public Decimal basePrice { get; set; }
        public Decimal taxPrice { get; set; }
        public String discountPrice { get; set; }
        public Decimal netPrice { get; set; }
        public Decimal PriceList { get; set; }
        public Decimal tax { get; set; }
        public String lineCategory { get; set; }
        public String OwnerSLI { get; set; }
        public Boolean Suplido { get; set; }
        public Boolean NoServir { get; set; }
        public Boolean MejoraCompania { get; set; }
        public List<AtributoDTO> Atributos { get; set; }
        public List<SignatureDTO> Attachment { get; set; }
        public Boolean queryStock { get; set; }
        public Boolean hasStock { get; set; }
        public Decimal SLINumber { get; set; }
        public Decimal parentSLINumber { get; set; }
        public Boolean posicionCB { get; set; }

        public void clearImages() {
            if(Attachment != null) {
                for(SignatureDTO sigDTO : Attachment) {
                    sigDTO.clearImage();
                }
            }
        }
    }
	//Service data structure object definition
    public class ServiceDTO {
        public String Id { get; set; }
        public String actualQuote { get; set; }
        public String nServicio { get; set; }
        public String IdDeceased { get; set; }
        public String deceasedType { get; set; }
        public String clientType { get; set; }
        public String serviceType { get; set; }
        public String company { get; set; }
        public Decimal capital { get; set; }
        public String SegmenttId { get; set; }
        public String SegmentName { get; set; }
        public String AgreementId { get; set; }
        public String AgreementName { get; set; }
        public String segmentType { get; set; }
        public String priceParticularId { get; set; }
        public String priceParticularName { get; set; }
        public String priceAgreementId { get; set; }
        public String priceAgreementName { get; set; }
        public String language { get; set; }
        public String taxes { get; set; }
        public String IdVelacion { get; set; }
        public String namePlaceVelacion { get; set; }
        public String StartVelacion { get; set; }
        public String EndVelacion { get; set; }
        public String AddressVelacion { get; set; }
        public String PostalCodeVelacion { get; set; }
        public String CityVelacion { get; set; }
        public String ProvinceVelacion { get; set; }
        public String CountryVelacion { get; set; }
        public String IdCeremonia { get; set; }
        public String namePlaceCeremonia { get; set; }
        public String StartCeremonia { get; set; }
        public String EndCeremonia { get; set; }
        public String AddressCeremonia { get; set; }
        public String PostalCodeCeremonia { get; set; }
        public String CityCeremonia { get; set; }
        public String ProvinceCeremonia { get; set; }
        public String CountryCeremonia { get; set; }
        public String IdCrematorio { get; set; }
        public String StartCrematorio { get; set; }
        public String EndCrematorio { get; set; }
        public String AddressCrematorio { get; set; }
        public String PostalCodeCrematorio { get; set; }
        public String CityCrematorio { get; set; }
        public String ProvinceCrematorio { get; set; }
        public String CountryCrematorio { get; set; }
        public String IdFinalDestination { get; set; }
        public String NamePlaceFinalDestination { get; set; }
        public String StartFinalDestination { get; set; }
        public String AddressFinalDestination { get; set; }
        public String PostalCodeFinalDestination { get; set; }
        public String CityFinalDestination { get; set; }
        public String CountryFinalDestination { get; set; }
        public String IdServiceOwner { get; set; }
        public String ServiceOwnerName { get; set; }
        public String ServiceOwnerSurname { get; set; }
        public String IdServiceWorkPLace { get; set; }
        public String ServiceWorkPlaceName { get; set; }
        public String IdDeceasedPlace { get; set; }
        public String NameDeceasedPlace { get; set; }
        public String AddressDeceasedPlace { get; set; }
        public String PostalCodeDeceasedPlace { get; set; }
        public String CityFinalDeceasedPlace { get; set; }
        public String ProvinceDeceasedPlace { get; set; }
        public String CountryDeceasedPlace { get; set; }
        public String SiniestroNumber { get; set; }
        public String PolizaNumber { get; set; }
        public DifuntoDTO Difunto { get; set; }
        public List<InterlocutorDTO> interlocutors { get; set; }
        public List<QuoteDTO> quotes { get; set; }
        public Decimal pvaStretch1 { get; set; }
        public Decimal pvaStretch2 { get; set; }
        public String serviceRecordType { get; set; }
        public Decimal SLICounter { get; set; }
        public Boolean centroCementiris { get; set; }

        public void clearImages() {
            if(quotes != null && !quotes.isEmpty()) {
                for(QuoteDTO qDTO : quotes) {
                    qDTO.clearImages();
                }
            }
        }
    }

    public class SynchronizationException extends Exception {}
}
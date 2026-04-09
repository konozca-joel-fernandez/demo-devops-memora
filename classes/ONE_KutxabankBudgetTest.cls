@IsTest
private class ONE_KutxabankBudgetTest {

    @IsTest
    static void testControllerAndBatch() {
        
        ONE_InsuranceIntegrationCredentials__c cred = new ONE_InsuranceIntegrationCredentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Name = ONE_CommonConstants.CM_KUTXABANK,
            ONE_Username__c = 'testUser',
            ONE_Password__c = 'testPassword'
        );
        insert cred;

        Id rtId = Schema.SObjectType.ONE_Caso__c.getRecordTypeInfosByDeveloperName().get('ONE_Avisos_M1').getRecordTypeId();
        ONE_Caso__c caso = new ONE_Caso__c(
            ONE_Numero_De_Siniestro_Texto__c = '12345',
            ONE_Tipo__c = 'Kutxabank',
            RecordTypeId = rtId
        );
        insert caso;

        Account centro = new Account(
            Name = 'Centro Test',
            ONE_Tipo_De_Impuesto__c = 'IVA'

        );
        insert centro;

        Id rtId2 = Schema.SObjectType.ONE_Expediente__c.getRecordTypeInfosByDeveloperName().get('ONE_Servicio_M1').getRecordTypeId();
        ONE_Expediente__c servicio = new ONE_Expediente__c(
            ONE_Caso__c = caso.Id,
            ONE_Centro_Del_Expediente__c = centro.Id,
            RecordTypeId = rtId2
        );
        insert servicio;

        ONE_Orden_De_Venta__c orden = new ONE_Orden_De_Venta__c(
            ONE_Servicio__c = servicio.Id,
            ONE_Numero_de_factura__c = 'F0001',
            ONE_Fecha_De_Facturacion__c = Date.today(),
            ONE_Importe_Base__c = 200,
            ONE_Importe_Base_21__c = 100,
            ONE_Importe_Base_10__c = 100,
            ONE_Importe_Impuesto_21__c = 21,
            ONE_Importe_Impuesto_10__c = 10,
            ONE_Importe_Impuesto_4__c = 0,
            ONE_Importe_Total__c = 231,
            ONE_Importe_Neto_21__c = 121,
            ONE_Importe_Neto_10__c = 110,
            ONE_Estado_De_La_Orden_de_Venta__c = 'Facturado'
        );
        insert orden;
        
        ONE_Orden_De_Venta__c orden2 = new ONE_Orden_De_Venta__c(
            ONE_Servicio__c = servicio.Id,
            ONE_Numero_de_factura__c = 'F0002',
            ONE_Fecha_De_Facturacion__c = Date.today(),
            ONE_Importe_Base__c = 200,
            ONE_Importe_Base_21__c = 100,
            ONE_Importe_Base_10__c = 100,
            ONE_Importe_Impuesto_21__c = 21,
            ONE_Importe_Impuesto_10__c = 10,
            ONE_Importe_Impuesto_4__c = 0,
            ONE_Importe_Total__c = 231,
            ONE_Importe_Neto_21__c = 121,
            ONE_Importe_Neto_10__c = 110,
            ONE_Estado_De_La_Orden_de_Venta__c = 'Facturado',
            ONE_KBSErrorFlag__c = true
        );
        insert orden2;

        ONE_Expediente_Line_Item__c sli = new ONE_Expediente_Line_Item__c(
            ONE_Orden_De_Venta__c = orden.Id,
            ONE_TrasladoM1__c = true,
            ONE_Importe_Base__c = 100,
            ONE_Importe_Impuesto__c = 21,
            ONE_Importe_Neto__c = 121,
            ONE_Impuesto__c = 21,
            ONE_Expediente__c = servicio.Id,
            ONE_Estado__c = 'Facturado'
        );
        insert sli;
        
        ONE_Expediente_Line_Item__c sli2 = new ONE_Expediente_Line_Item__c(
            ONE_Orden_De_Venta__c = orden.Id,
            ONE_TrasladoM1__c = false,
            ONE_Importe_Base__c = 100,
            ONE_Importe_Impuesto__c = 10,
            ONE_Importe_Neto__c = 110,
            ONE_Impuesto__c = 10,
            ONE_Expediente__c = servicio.Id,
            ONE_Estado__c = 'Facturado'
        );
        insert sli2;

        ContentVersion cv = new ContentVersion(
            Title = 'Nº Factura SAP: F0001',
            VersionData = Blob.valueOf('PDF TEST'),
            PathOnClient = 'test.pdf'
        );
        insert cv;

        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        insert new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = orden.Id,
            ShareType = 'V'
        );

        Test.setMock(HttpCalloutMock.class, new SimpleKutxabankMock());

        ONE_KutxabankBudgetController.FlowInputs finput = new ONE_KutxabankBudgetController.FlowInputs();
        finput.ordenDeVentaId = orden.Id;
        finput.batchProcess = true;
		
        Test.startTest();
        List<ONE_KutxabankBudgetController.FlowOutputs> response =
            ONE_KutxabankBudgetController.invokeIntegration(new List<ONE_KutxabankBudgetController.FlowInputs>{finput});
        
        ONE_KutxabankBudgetBatch batch = new ONE_KutxabankBudgetBatch();
        Database.executeBatch(batch, 10);

        ONE_KutxabankBudgetScheduler sch = new ONE_KutxabankBudgetScheduler();
        sch.execute(null);
        Test.stopTest();
        
        System.assertNotEquals(null, response);
        System.assert(response[0].success);
    }

    private class SimpleKutxabankMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"resultado":{"Expediente":"TEST (12345)"}}');
            return res;
        }
    }
    
    private class ErrorKutxabankMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"resultado":{"Message":"TEST (12345)","Mensaje":"Mensaje personalizado","Detalles":"Detalles adicionales"}}');            
            return res;
        }
    }
    
    @IsTest
    static void testFacturaAbonado() {
    
        ONE_InsuranceIntegrationCredentials__c cred = new ONE_InsuranceIntegrationCredentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Name = ONE_CommonConstants.CM_KUTXABANK,
            ONE_Username__c = 'testUser',
            ONE_Password__c = 'testPassword'
        );
        insert cred;
    
        Id rtId = Schema.SObjectType.ONE_Caso__c.getRecordTypeInfosByDeveloperName().get('ONE_Avisos_M1').getRecordTypeId();
        ONE_Caso__c caso = new ONE_Caso__c(
            ONE_Numero_De_Siniestro_Texto__c = '5555',
            ONE_Tipo__c = 'Kutxabank',
            RecordTypeId = rtId
        );
        insert caso;
    
        Account centro = new Account(
            Name = 'Centro Test',
            ONE_Tipo_De_Impuesto__c = 'IVA'
        );
        insert centro;
    
        ONE_Expediente__c servicio = new ONE_Expediente__c(
            ONE_Caso__c = caso.Id,
            ONE_Centro_Del_Expediente__c = centro.Id
        );
        insert servicio;
    
        ONE_Orden_De_Venta__c orden = new ONE_Orden_De_Venta__c(
            ONE_Servicio__c = servicio.Id,
            ONE_Estado_De_La_Orden_de_Venta__c = 'Abonado',
            ONE_Numero_Abono_Factura__c = 'A0001',
            ONE_Fecha_Hora_Del_Abono_Factura__c = Datetime.now(),
            ONE_Importe_Base__c = 100,
            ONE_Importe_Base_21__c = 100,
            ONE_Importe_Impuesto_21__c = 21,
            ONE_Importe_Impuesto_10__c = 0,
            ONE_Importe_Impuesto_4__c = 0,
            ONE_Importe_Total__c = 121,
            ONE_Importe_Neto_21__c = 121
        );
        insert orden;
        
        ONE_Expediente_Line_Item__c sli = new ONE_Expediente_Line_Item__c(
            ONE_Orden_De_Venta__c = orden.Id,
            ONE_TrasladoM1__c = true,
            ONE_Importe_Base__c = 100,
            ONE_Importe_Impuesto__c = 21,
            ONE_Importe_Neto__c = 121,
            ONE_Impuesto__c = 21,
            ONE_Expediente__c = servicio.Id
        );
        insert sli;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Nº Abono A0001',
            VersionData = Blob.valueOf('PDF TEST'),
            PathOnClient = 'test.pdf'
        );
        insert cv;

        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        insert new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = orden.Id,
            ShareType = 'V'
        );
    
        Test.setMock(HttpCalloutMock.class, new ErrorKutxabankMock());
        
        ONE_KutxabankBudgetController.FlowInputs finput = new ONE_KutxabankBudgetController.FlowInputs();
        finput.ordenDeVentaId = orden.Id;
        finput.batchProcess = false;
    
        Test.startTest();
            List<ONE_KutxabankBudgetController.FlowOutputs> response =
                ONE_KutxabankBudgetController.invokeIntegration(
                    new List<ONE_KutxabankBudgetController.FlowInputs>{
                        finput
                            }
                );
        Test.stopTest();
    
        System.assertEquals(false, response[0].success);
    }

}
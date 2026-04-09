@IsTest
private class ONE_AltaSiniestroKBSTest {

    private class KutxabankHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(201);
            res.setBody('{"resultado": {"Expediente": "KBS12345"}}');
            return res;
        }
    }

    private class KutxabankErrorHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            res.setBody('{"resultado": {"Message": "Error interno del servidor"}}');
            return res;
        }
    }

    @IsTest
    static void testBatchKutxabankSuccess() {
        
        ONE_InsuranceIntegrationCredentials__c cred = new ONE_InsuranceIntegrationCredentials__c(
            Name = ONE_CommonConstants.CM_KUTXABANK,
            ONE_Username__c = 'testUser',
            ONE_Password__c = 'testPass'
        );
        insert cred;
        
        Id rtId = Schema.SObjectType.ONE_Caso__c.getRecordTypeInfosByDeveloperName().get('ONE_Avisos_M1').getRecordTypeId();
        ONE_Caso__c caso = new ONE_Caso__c(
            ONE_Tipo__c = 'Kutxabank',
            RecordTypeId = rtId,
            ONE_Numero_De_Poliza_texto__c = 'test'
        );
        
        ONE_Caso__c caso2 = new ONE_Caso__c(
            ONE_Tipo__c = 'Kutxabank',
            RecordTypeId = rtId
        );
        
        List<ONE_Caso__c> casosList = new List<ONE_Caso__c>{caso, caso2};
        
        insert casosList;

        Test.setMock(HttpCalloutMock.class, new KutxabankHttpMock());

        Test.startTest();
        Database.executeBatch(new ONE_AltaSiniestroKBSBatch(), 10);
        Test.stopTest();

        ONE_Caso__c updatedCaso = [
            SELECT ONE_Numero_De_Siniestro_Texto__c 
            FROM ONE_Caso__c 
            WHERE Id = :caso.Id
        ];
        System.assertEquals(
            'KBS12345', 
            updatedCaso.ONE_Numero_De_Siniestro_Texto__c,
            'El número de siniestro debe haberse actualizado correctamente'
        );
    }
    
    @IsTest
    static void testAltaSiniestroKutxabankSuccess() {
        
        ONE_InsuranceIntegrationCredentials__c cred = new ONE_InsuranceIntegrationCredentials__c(
            Name = ONE_CommonConstants.CM_KUTXABANK,
            ONE_Username__c = 'testUser',
            ONE_Password__c = 'testPass'
        );
        insert cred;
        
        Id rtId = Schema.SObjectType.ONE_Caso__c.getRecordTypeInfosByDeveloperName().get('ONE_Avisos_M1').getRecordTypeId();
        ONE_Caso__c caso = new ONE_Caso__c(
            ONE_Tipo__c = 'Kutxabank',
            RecordTypeId = rtId,
            ONE_Numero_De_Poliza_texto__c = 'test'
        );
        
        insert caso;

        Test.setMock(HttpCalloutMock.class, new KutxabankHttpMock());

        ONE_OpenLifeClaimIntegrationService.FlowInputs input = new ONE_OpenLifeClaimIntegrationService.FlowInputs();
        input.casoId = caso.Id;
        input.service = 'kutxabank';
    
        List<ONE_OpenLifeClaimIntegrationService.FlowInputs> inputs = new List<ONE_OpenLifeClaimIntegrationService.FlowInputs>{input};
    
        Test.startTest();
    
        List<ONE_OpenLifeClaimIntegrationService.FlowOutputs> outputs = ONE_OpenLifeClaimIntegrationService.invokeIntegration(inputs);
    
        Test.stopTest();
    
        System.assertEquals(1, outputs.size());
        ONE_OpenLifeClaimIntegrationService.FlowOutputs output = outputs.get(0);
    }

    @IsTest
    static void testSchedulerExecutesBatch() {
        Test.startTest();
        ONE_AltaSiniestroKBSScheduler scheduler = new ONE_AltaSiniestroKBSScheduler();
        String jobId = System.schedule('Test Scheduler', '0 0 12 * * ?', scheduler);
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'El jobId del scheduler no debe ser nulo');
    }

    @IsTest
    static void testBatchKutxabankErrorResponse() {
        
        ONE_InsuranceIntegrationCredentials__c cred = new ONE_InsuranceIntegrationCredentials__c(
            Name = ONE_CommonConstants.CM_KUTXABANK,
            ONE_Username__c = 'testUser',
            ONE_Password__c = 'testPass'
        );
        insert cred;
        
        Id rtId = Schema.SObjectType.ONE_Caso__c.getRecordTypeInfosByDeveloperName().get('ONE_Avisos_M1').getRecordTypeId();
        ONE_Caso__c caso = new ONE_Caso__c(
            ONE_Tipo__c = 'Kutxabank',
            RecordTypeId = rtId,
            ONE_Numero_De_Poliza_texto__c = 'test'
        );
        insert caso;

        Test.setMock(HttpCalloutMock.class, new KutxabankErrorHttpMock());

        Test.startTest();
        Database.executeBatch(new ONE_AltaSiniestroKBSBatch(), 10);
        Test.stopTest();

        ONE_Caso__c updatedCaso = [
            SELECT ONE_Numero_De_Siniestro_Texto__c 
            FROM ONE_Caso__c 
            WHERE Id = :caso.Id
        ];
        System.assertEquals(
            null, 
            updatedCaso.ONE_Numero_De_Siniestro_Texto__c,
            'El número de siniestro no debe actualizarse en caso de error'
        );
    }
}
@isTest
public with sharing class ONE_GetQRWebServiceTest {

    @TestSetup
    static void setupTestData() {

        RecordType rtPersonaParticular = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Person_Accout_Particular'];

        Account difuntoAsociado = new Account(
            FirstName = 'Test', 
            LastName = 'Asociado',
            ONE_QR_Asociado__c = true,
            RecordTypeId = RTPersonaParticular.Id
        );
        insert difuntoAsociado;

        Account difuntoNoAsociado = new Account(
            FirstName = 'Test', 
            LastName = 'No Asociado',
            ONE_QR_Asociado__c = false,
            RecordTypeId = RTPersonaParticular.Id
        );
        insert difuntoNoAsociado;

        ONE_Caso__c aviso = new ONE_Caso__c(ONE_Difunto__c = difuntoAsociado.Id);
        insert aviso;

        ONE_Tarea__c tarea = new ONE_Tarea__c(Name = 'Test Tarea', ONE_Aviso__c = aviso.Id);
        insert tarea;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'PDF QR Code',
            PathOnClient = 'qrcode.pdf',
            VersionData = Blob.valueOf('QR Code PDF Data'),
            CodigoQR__c = true
        );
        insert contentVersion;

        ContentDocumentLink contentLink = new ContentDocumentLink(
            LinkedEntityId = difuntoAsociado.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            ShareType = 'I'
        );
        insert contentLink;
    }

    @IsTest
    static void testGetQRWithValidId() {
        // Set up a mock request with a valid Tarea Id
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ONE_getQR/' + [SELECT Id FROM ONE_Tarea__c LIMIT 1].Id;
        req.httpMethod = 'GET';
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the web service method
        Test.startTest();
        ONE_GetQRWebService.getQR();
        Test.stopTest();

        // Assert the response
        System.assertEquals(200, RestContext.response.statusCode, 'Status code should be 200');

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals(true, responseJson.get('success'), 'Success field should be true');
    }

    @IsTest
    static void testGetQRWithInvalidId() {
        // Set up a mock request with an invalid Tarea Id
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ONE_getQR/InvalidId';
        req.httpMethod = 'GET';
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the web service method
        Test.startTest();
        ONE_GetQRWebService.getQR();
        Test.stopTest();

        // Assert the response
        System.assertEquals(400, RestContext.response.statusCode, 'Status code should be 400');

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals(false, responseJson.get('success'), 'Success field should be false');
    }

    @IsTest
    static void testGetQRWithNoAccount() {

        ONE_Tarea__c tarea = new ONE_Tarea__c(Name = 'Test Tarea');
        insert tarea;

        // Set up a mock request with this tarea
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ONE_getQR/' + tarea.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the web service method
        Test.startTest();
        ONE_GetQRWebService.getQR();
        Test.stopTest();

        // Assert the response
        System.assertEquals(402, RestContext.response.statusCode, 'Status code should be 402');

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals(false, responseJson.get('success'), 'Success field should be false');
    }

    @IsTest
    static void testGetQRWithQRAsociatedButNotFound() {

        String difuntoId = [SELECT Id FROM Account WHERE ONE_QR_Asociado__c = true LIMIT 1].Id;


        ContentDocumentLink contentLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :difuntoId LIMIT 1];
        // Delete ContentDocumentLink to simulate no QR associated
        delete contentLink;

        // Set up a mock request with a valid Tarea Id
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ONE_getQR/' + [SELECT Id FROM ONE_Tarea__c LIMIT 1].Id;
        req.httpMethod = 'GET';
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the web service method
        Test.startTest();
        ONE_GetQRWebService.getQR();
        Test.stopTest();

        // Assert the response
        System.assertEquals(500, RestContext.response.statusCode, 'Status code should be 500');

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals(false, responseJson.get('success'), 'Success field should be false');
    }

    @IsTest
    static void testGetQRWithNoQRAsociated() {

        String difuntoId = [SELECT Id FROM Account WHERE ONE_QR_Asociado__c = false LIMIT 1].Id;

        ONE_Caso__c aviso = new ONE_Caso__c(ONE_Difunto__c = difuntoId);
        insert aviso;

        ONE_Tarea__c tarea = new ONE_Tarea__c(Name = 'Test Tarea No Asociado', ONE_Aviso__c = aviso.Id);
        insert tarea;

        // Set up a mock request with a valid Tarea Id
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ONE_getQR/' + tarea.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the web service method
        Test.startTest();
        ONE_GetQRWebService.getQR();
        Test.stopTest();

        // Assert the response
        System.assertEquals(404, RestContext.response.statusCode, 'Status code should be 404');

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals(false, responseJson.get('success'), 'Success field should be false');
    }
}
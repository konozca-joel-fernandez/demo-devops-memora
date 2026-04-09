/**
* File Name: ONE_GeneracionQREsquelasControllerTest
* Description: 	Test for ONE_Generacion_QR_Esquelas_Controller
* Date: 18/09/2024
*
* Copyright: Konozca Consulting
* @author: Marc Pàmies
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		19/09/2025		Marc Pàmies  		Class creation
* ===================================================================================================================
*/
@IsTest
private class ONE_GeneracionQREsquelasControllerTest {
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('nombres_difuntos_urls')) {
                res.setStatusCode(200);
                res.setBody('[{"view_node": "https://test.memora.es/juanperez"}]');
            } else {
                res.setStatusCode(500);
                res.setBody('Error');
            }
            return res;
        }
    }
    
    @TestSetup
    static void setupData() {
        Id rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ONE_Person_Accout_Particular').getRecordTypeId();
        Account difunto = new Account(FirstName = 'Juan', LastName = 'Perez', RecordTypeId = rtAccount);
        insert difunto;
        
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = difunto.Id
        );
        insert expediente;
        
        // Creamos una Tarea vinculada al expediente
        ONE_Tarea__c tarea = new ONE_Tarea__c(
            Name = 'Tarea de esquela',
            ONE_Expediente__c = expediente.Id
        );
        insert tarea;
    }
    
    @IsTest
    static void testSaveAndLinkQrEsquelaWithTarea() {
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c LIMIT 1];
        
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code'));
        
        Test.startTest();
        String contentVersionId = ONE_Generacion_QR_Esquelas_Controller.saveAndLinkQrEsquela(qrCodeBase64, tarea.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, contentVersionId, 'El ContentVersion debería haberse creado');
    }
    
    @IsTest
    static void testSaveAndLinkQrEsquelaWithExpediente() {
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Otro Dummy QR Code'));
        
        Test.startTest();
        String contentVersionId = ONE_Generacion_QR_Esquelas_Controller.saveAndLinkQrEsquela(qrCodeBase64, expediente.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, contentVersionId, 'El ContentVersion debería haberse creado para el expediente');
    }
    
    @IsTest
    static void testGenerateLinkForQrCode() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        List<String> difuntos = new List<String>{'Juan Perez'};
        
        Test.startTest();
        List<String> result = ONE_Generacion_QR_Esquelas_Controller.generateLinkForQrCode(difuntos);
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Debe devolver un enlace');
        System.assert(result[0].contains('https://test.memora.es/juanperez'), 'El enlace debe contener la URL mockeada');
    }
    
    @IsTest
    static void testObtenerUrlEsquelaWithBlank() {
        Test.startTest();
        String url = ONE_Generacion_QR_Esquelas_Controller.obtenerUrlEsquela('');
        Test.stopTest();
        
        System.assertEquals('', url, 'Debe devolver vacío si el nombre está en blanco');
    }
}
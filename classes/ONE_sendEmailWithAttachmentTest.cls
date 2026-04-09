@isTest
public class ONE_sendEmailWithAttachmentTest {
    
    @isTest
    static void testSendEmail(){
        
        Test.startTest();
        
        ONE_sendEmailWithAttachment.sendEmailWithAttachmentRequest request = new ONE_sendEmailWithAttachment.sendEmailWithAttachmentRequest();
        request.title = 'Enviar PDF Test';
        request.enchancedBody = true;
        request.body = 'Ha recibido un documento de Orden de Servicio ' + '<a href=' + '"https://memora--devmemora.sandbox.lightning.force.com/lightning/r/ONE_Documentos__c/' + 'a0v5r000002td8eAAA' + '/view"' + '>' + 'S-0000331' + '</a>';
        request.attachments = new List<Id>();
        request.directions = 'pau.galindo@konozca.com, manuel.albacete@konozca.com';
        
        List<ONE_sendEmailWithAttachment.sendEmailWithAttachmentRequest> requests = new List<ONE_sendEmailWithAttachment.sendEmailWithAttachmentRequest>();
        requests.add(request);
        
    	List<ONE_sendEmailWithAttachment.sendEmailWithAttachmentResult> results = ONE_sendEmailWithAttachment.sendEmailWithAttachment(requests);
        
        Boolean success = true;
        
        for(ONE_sendEmailWithAttachment.sendEmailWithAttachmentResult result : results){
            success = success && result.success;
        }
        
        Test.stopTest();
        
        System.debug(success);
        System.assert(success);
        
    }
}
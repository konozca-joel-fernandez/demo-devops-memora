/*****************************************************************************************************************************************
Apex class Name:  	ONE_sendEmailWithAttForGuestUsersTest.cls
Version:            1.0
Created Date:       12/04/2024
Function:           Test class for ONE_sendEmailWithAttachmentForGuestUsers
Author:             Marc Cervilla
Company:            Konozca

History: 
<Date>                  <Dev Name>                              <Change Description>
12/04/2024              Marc Cervilla	                 		Class creation

*****************************************************************************************************************************************/

@isTest
public class ONE_sendEmailWithAttForGuestUsersTest {

    @TestSetup
    private static void testSetup() {
        // Create test data
        Account acc = new Account(
            Name = 'Tanatori Test'
        );
        insert acc;
    }
    
    @isTest
    static void testSendEmail(){

        Account tanatori = [SELECT Id, Name FROM Account LIMIT 1];
        
        Test.startTest();
        
        ONE_sendEmailWithAttachmentForGuestUsers.sendEmailWithAttachmentForGuestUsersRequest request = new ONE_sendEmailWithAttachmentForGuestUsers.sendEmailWithAttachmentForGuestUsersRequest();
        request.title = 'Enviar Justificante Test';
        request.enchancedBody = true;
        request.body = 'Le adjuntamos el certificado de empresa solicitado a través de nuestro terminal autoservicio del tanatorio.';
        request.attachments = new List<Id>();
        request.directions = 'marc.cervilla@konozca.com';
        request.tanatorioName = tanatori.Name;
        request.senderEmail = 'tanatorisanchoavila@memora.es';
        
        List<ONE_sendEmailWithAttachmentForGuestUsers.sendEmailWithAttachmentForGuestUsersRequest> requests = new List<ONE_sendEmailWithAttachmentForGuestUsers.sendEmailWithAttachmentForGuestUsersRequest>();
        requests.add(request);
        
    	List<ONE_sendEmailWithAttachmentForGuestUsers.sendEmailWithAttachmentForGuestUsersResult> results = ONE_sendEmailWithAttachmentForGuestUsers.sendEmailWithAttachmentForGuestUsers(requests);
        
        Boolean success = true;
        
        for(ONE_sendEmailWithAttachmentForGuestUsers.sendEmailWithAttachmentForGuestUsersResult result : results){
            success = success && result.success;
        }
        
        Test.stopTest();
        
        System.debug(success);
        System.assert(success, 'El envío de mail ha resultado erroneo');
        
    }
}
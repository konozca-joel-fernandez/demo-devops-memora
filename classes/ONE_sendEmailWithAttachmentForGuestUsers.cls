global class ONE_sendEmailWithAttachmentForGuestUsers {
    
    @invocableMethod (label = 'sendEmailWithAttachmentForGuestUsers')
    global static List<sendEmailWithAttachmentForGuestUsersResult> sendEmailWithAttachmentForGuestUsers(List<sendEmailWithAttachmentForGuestUsersRequest> requests) {
        List<sendEmailWithAttachmentForGuestUsersResult> results = new List<sendEmailWithAttachmentForGuestUsersResult>();
        for (sendEmailWithAttachmentForGuestUsersRequest request : requests){
            results.add(sendEmail(request));
        }
        return results;
    }
    
    global static sendEmailWithAttachmentForGuestUsersResult sendEmail(sendEmailWithAttachmentForGuestUsersRequest request){
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
        emails[0] = generateEmailMessage(request);
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emails);
        
        sendEmailWithAttachmentForGuestUsersResult result = new sendEmailWithAttachmentForGuestUsersResult();
        result.success = true;
        
        for(Messaging.SendEmailResult sendResult : sendResults){
            result.success = result.success && sendResult.isSuccess();
        }
        
        return result;
    }

    static Messaging.SingleEmailMessage generateEmailMessage(sendEmailWithAttachmentForGuestUsersRequest request){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setSubject(request.title);

        System.debug('request :' + request);
        System.debug('title :' + request.title);
        System.debug('body :' + request.body);
        System.debug('enchancedBody :' + request.enchancedBody);
        System.debug('directions :' + request.directions);
        System.debug('attachments :' + request.attachments);
        System.debug('tanatorioName :' + request.tanatorioName);
        System.debug('senderEmail :' + request.senderEmail);

        List<OrgWideEmailAddress> lstEmailAddress = [select Id from OrgWideEmailAddress WHERE Address = :request.senderEmail LIMIT 1];

        if(lstEmailAddress.size() > 0){
            email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
        } else{
            throw new CustomException('No se ha encontrado el correo para ' + request.senderEmail);
        }
        
        
        if (request.enchancedBody != null && request.enchancedBody){
            email.setHtmlBody(request.body);
        } else {
            email.setPlainTextBody(request.body);
        }
        
        email.setToAddresses(getAddresses(request.directions));
        
        if (request.attachments != null && !request.attachments.isEmpty()){
            email.setEntityAttachments(request.attachments);
        }
        
        return email;        
    }
    
    static List<String> getAddresses(String addresses){
        List<String> result = new List<String>();
        
        while (addresses.length() > 0){
            
            if (addresses.indexOf(',') != -1){
                if (addresses.substring(0, addresses.indexOf(',')).length() > 0) result.add(addresses.substring(0, addresses.indexOf(',')));
                addresses = addresses.substring(addresses.indexOf(',') + 1);
            } else {
                if (addresses.length() > 0) result.add(addresses);
                addresses = '';
            }

        }
        system.debug(result);
        return result;
    }
    
    global class sendEmailWithAttachmentForGuestUsersRequest {
        @InvocableVariable(label = 'Asunto')
        global string title;
        
        @InvocableVariable(label = 'Cuerpo')
        global string body;
        
        @InvocableVariable(label = 'Cuerpo con formato HTML')
        global boolean enchancedBody;
        
        @InvocableVariable(label = 'Direcciones' description = 'Las direcciones de correo separadas por ;')
        global string directions;
        
        @InvocableVariable(label = 'Archivos Adjuntos' description = 'Colección de IDs de archivos')
        global List<Id> attachments;

        @InvocableVariable(label = 'Nombre Tanatorio' description = 'Nombre del tanatorio seleccionado')
        global String tanatorioName;

        @InvocableVariable(label = 'Email Origen' description = 'Email del remitente')
        global String senderEmail;
    }
    
    global class sendEmailWithAttachmentForGuestUsersResult {
        @InvocableVariable
        global boolean success;
    }

    private class CustomException extends Exception {
    }

}
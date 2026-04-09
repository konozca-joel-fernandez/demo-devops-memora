global class ONE_sendEmailWithAttachment {
    
    @invocableMethod (label = 'sendEmailWithAttachment')
    global static List<sendEmailWithAttachmentResult> sendEmailWithAttachment(List<sendEmailWithAttachmentRequest> requests) {
        List<sendEmailWithAttachmentResult> results = new List<sendEmailWithAttachmentResult>();
        for (sendEmailWithAttachmentRequest request : requests){
            results.add(sendEmail(request));
        }
        return results;
    }
    
    global static sendEmailWithAttachmentResult sendEmail(sendEmailWithAttachmentRequest request){
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
        emails[0] = generateEmailMessage(request);
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emails);
        
        sendEmailWithAttachmentResult result = new sendEmailWithAttachmentResult();
        result.success = true;
        
        for(Messaging.SendEmailResult sendResult : sendResults){
            result.success = result.success && sendResult.isSuccess();
        }
        
        return result;
    }
    
    static Messaging.SingleEmailMessage generateEmailMessage(sendEmailWithAttachmentRequest request){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setSubject(request.title);
        
        if (request.enchancedBody){
            email.setHtmlBody(request.body);
        } else {
            email.setPlainTextBody(request.body);
        }
        
        email.setToAddresses(getAddresses(request.directions));
        
        if (!request.attachments.isEmpty()){
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
    
    global class sendEmailWithAttachmentRequest {
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
    }
    
    global class sendEmailWithAttachmentResult {
        @InvocableVariable
        global boolean success;
    }

}
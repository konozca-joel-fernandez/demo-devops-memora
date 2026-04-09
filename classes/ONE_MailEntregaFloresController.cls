public class ONE_MailEntregaFloresController {
	@InvocableMethod(label= 'Send Mail Entrega Flores')
    public static List<String> sendMail(List<Id> tareaIds){
        ONE_MailEntregaFloresBuilder builder = new ONE_MailEntregaFloresBuilder(tareaIds[0]);
 		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        
        mail.setToAddresses(new String[] { builder.getTarget() });
        mail.setOrgWideEmailAddressId(builder.getOrgAddress());
        //mail.setSenderDisplayName('Salesforce Support');
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setWhatId(tareaIds[0]);
        mail.setSaveAsActivity(true);
		
        mail.setSubject(builder.getSubject());
        mail.setHtmlBody(builder.buildHTML());
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        if (results[0].success)
         {
             builder.confirmarEnvio();
          	 System.debug('The email was sent successfully.');
             return new List<String>{'success'};
         }
        else
         {
             System.debug('The email failed to send: ' + results[0].errors[0].message);
             return new List<String>{results[0].errors[0].message};
         }
    }
}
public class ONE_sendMailPendienteZonaQueueable implements Queueable {

    private Id templateId;
    private Id queueId;
    private Id casoId;
    private String orgWideAddress;

    public ONE_sendMailPendienteZonaQueueable(Id templateId, Id queueId, Id casoId, String orgWideAddress) {
        this.templateId = templateId;
        this.queueId = queueId;
        this.casoId = casoId;
        this.orgWideAddress = orgWideAddress;
    }

    public void execute(QueueableContext context) {

        Group queue = [SELECT Id, Name, Email, DoesSendEmailToMembers FROM Group WHERE Id = :queueId LIMIT 1];
        
        Id owaId = null;

        if(orgWideAddress != 'currentUser') {
            owaId = [SELECT Id, address FROM OrgWideEmailAddress where Address = :this.orgWideAddress LIMIT 1].Id;
        }

        ONE_sendMailPendienteZonaBuilder builder = new ONE_sendMailPendienteZonaBuilder(this.templateId, this.casoId);

        List<GroupMember> members = [
            SELECT UserOrGroupId, UserOrGroup.Email
            FROM GroupMember
            WHERE GroupId = :queueId
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        if (queue.Email != null) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { queue.Email });
            email.setWhatId(this.casoId);
            if (owaId != null) email.setOrgWideEmailAddressId(owaId);
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setSaveAsActivity(!queue.DoesSendEmailToMembers);
            email.setSubject(builder.getSubject());
            email.setHtmlBody(builder.getBody());
            emails.add(email);
        }
        if(queue.DoesSendEmailToMembers || queue.Email == null) {
            List<String> userEmails = new List<String>();
            for (GroupMember gm : members) {
                if (String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                    userEmails.add(gm.UserOrGroup.Email);
                }
                else { System.enqueueJob(new ONE_sendMailPendienteZonaQueueable(this.templateId, gm.UserOrGroupId, this.casoId, this.orgWideAddress)); }
            }
            //Boolean first = true && queue.Email == null;
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(userEmails);
            email.setWhatId(this.casoId);
            if (owaId != null) email.setOrgWideEmailAddressId(owaId);
            email.setSaveAsActivity(true);
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setSubject(builder.getSubject());
            email.setHtmlBody(builder.getBody());
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails, false);
            if (results[0].success)
             {
                System.debug('The email was sent successfully.');
             }
            else
             {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
             }
        }
    }
}
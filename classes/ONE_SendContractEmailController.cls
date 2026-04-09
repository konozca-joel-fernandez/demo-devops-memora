public class ONE_SendContractEmailController {
    
       private String tipoPresupuesto;
        private String presupuestoId;
        private String titularEmail;
        private String servicioId;
    	private String bodyEmail;
    	private String asuntoEmail;
        
       
    public ONE_SendContractEmailController(List<FlowInput> flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.tipoPresupuesto = flowInput.tipoPresupuesto;
        this.presupuestoId = flowInput.presupuestoId;
        this.titularEmail = flowInput.titularEmail;
        this.servicioId = flowInput.servicioId;
        this.bodyEmail=flowInput.bodyEmail;
        this.asuntoEmail=flowInput.asuntoEmail;
       
    }
    
    @InvocableMethod
    public static List<FlowOutput> sendContractByEmail(List<FlowInput> flowInputs) {
		Boolean success=false;
        String contentVersionId='';
        ONE_SendContractEmailController contract = new ONE_SendContractEmailController(flowInputs);
        try{
            
          	List<ContentDocumentLink> contentDocList;
              
             if(contract.tipoPresupuesto != 'Oportunidad Olympia' || contract.servicioId == null || contract.servicioId == '' ){          
           
                contentDocList =[SELECT Id, LinkedEntityId, ContentDocument.title, ContentDocument.LatestPublishedVersion.TagCsv, ContentDocument.LatestPublishedVersionId 
                              FROM ContentDocumentLink 
                              WHERE LinkedEntityId=:contract.presupuestoId 
                              ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate desc];
             }else{
                List<ONE_Documentos__c> aux = [SELECT Id  
                              FROM ONE_Documentos__c 
                              WHERE ONE_Servicio__c =: contract.servicioId AND RecordType.DeveloperName =: 'Autorizaci_n_para_Cesi_n_de_Datos'  
                              ORDER BY CreatedDate desc LIMIT 1];
                system.debug('docu +  ' + aux );
                contentDocList =[SELECT Id, LinkedEntityId, ContentDocument.title, ContentDocument.LatestPublishedVersion.TagCsv, ContentDocument.LatestPublishedVersionId 
                                 FROM ContentDocumentLink 
                                 WHERE LinkedEntityId=: aux[0].Id
                                 ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate desc];
             }

            for(ContentDocumentLink cdlink : contentDocList){
                if(contract.tipoPresupuesto=='Particular' && cdlink.ContentDocument.LatestPublishedVersion.TagCsv=='CONTRATO_COMERCIAL'){
                    contentVersionId =cdlink.ContentDocument.LatestPublishedVersionId;
                    break; 
                }else if(contract.tipoPresupuesto=='Hoja de servicio' && cdlink.ContentDocument.LatestPublishedVersion.TagCsv=='HOJA_SERVICIO'){
                    contentVersionId =cdlink.ContentDocument.LatestPublishedVersionId;
                    break; 
                }else{
                    contentVersionId =cdlink.ContentDocument.LatestPublishedVersionId;
                    break;
                }
            }
            
            if (!String.isBlank(contentVersionId) || contract.tipoPresupuesto == 'Oportunidad Olympia') {
                
                String body = contract.bodyEmail;
                String idAsignado;
                String userId = UserInfo.getUserId();
                

                if(!String.isBlank(contract.servicioId)){
                        idAsignado = contract.servicioId;
                }else if(!String.isBlank(contract.presupuestoId)){
                        idAsignado = contract.presupuestoId;
                }

                Messaging.reserveSingleEmailCapacity(2);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[]{contract.titularEmail});
                mail.setSubject(contract.asuntoEmail);
                mail.setHtmlBody(body);
                mail.setWhatId(idAsignado);
                mail.setSaveAsActivity(true);
                
                try{
                    ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
                    mail.setEntityAttachments(new List<String>{cv.Id});
                    ContentDocumentLink cdAdjunto = new ContentDocumentLink(
                        ContentDocumentId = cv.ContentDocumentId,
                        LinkedEntityId = idAsignado,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    );
                    insert cdAdjunto;
                } catch (Exception e) {
                    System.debug('Invalid ContentVersionId: ' + e.getMessage());
                }

                TwoFactorMethodsInfo tfmi = [SELECT UserId, HasUserVerifiedEmailAddress FROM TwoFactorMethodsInfo WHERE UserId=:userId LIMIT 1];

                if(tfmi.HasUserVerifiedEmailAddress == false){
                     system.debug('email no verificado');
                     return new List<FlowOutput>{new FlowOutput(false)};
                }
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                success = true;
            } else {
                success = false;
            }
            
        }catch(Exception e){
            success=false;
        }
        return new List<FlowOutput>{new FlowOutput(success)};
    }
    
 	public virtual class FlowInput {
        @InvocableVariable
        public String tipoPresupuesto;
        @InvocableVariable
        public String presupuestoId;
        @InvocableVariable
        public String titularEmail;
        @InvocableVariable
        public String servicioId;
        @InvocableVariable
        public String bodyEmail;
        @InvocableVariable
        public String asuntoEmail;
        
    }
    
    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
       
        public FlowOutput(Boolean success) {
            this.success = success;
            
        }
    }
}
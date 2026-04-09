public class ONE_PedidoMarmolistaPdfService {
    private Id pedidoProveedorId;
    private List<FlowInput> inputs;
     
    
    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_PedidoMarmolistaPdfService service = new ONE_PedidoMarmolistaPdfService(inputs);
        return service.createAndLinkPdf(ONE_PdfGeneratorHelper.getTitleLabel('Pedido_Marmolista'));
    }
    
    public ONE_PedidoMarmolistaPdfService(List<FlowInput> inputs) { 
        this.inputs = inputs;
    }
    
    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.pedidoProveedorId = datosInput.pedidoProveedorId;
        String language = datosInput.language;
        
        PageReference pageRef = Page.ONE_PedidoMarmolistaPdf;
        
        pageRef.getParameters().put('pedidoProveedorId', pedidoProveedorId);
        pageRef.getParameters().put('language', language);
        
        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }
    
    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(String fileName) {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.pedidoProveedorId, fileName, ONE_CommonConstants.DOCUMENT_TAG_PEDIDO_MARMOLISTA);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.pedidoProveedorId);
            ONE_Pedido_De_Proveedor__c pedidoProveedor = [SELECT ONE_Email_Proveedor__c,
                                                          	  ONE_Email_De_Remitente__c,
                                                              ONE_Proveedor__r.Name,
                                                              ONE_Expediente__r.Name,
                                                              Name,
                                                              ONE_Expediente__r.ONE_Difunto__r.FirstName,
                                                              ONE_Expediente__r.ONE_Difunto__r.LastName
                                                          	
                                                          FROM ONE_Pedido_De_Proveedor__c 
                                                          WHERE ID =: pedidoProveedorId Limit 1];
        	System.debug('pedidoProveedorMarmolista --> ' + pedidoProveedor);
			EmailTemplate template =              
                input.language == 'CA'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_MARMOLISTA_MEDICO_GESTORIA_CA]:
            	input.language == 'EU'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_MARMOLISTA_MEDICO_GESTORIA_EU]:
            	[SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_MARMOLISTA_MEDICO_GESTORIA_ES];  
                               
            System.debug('template' + template);
            //Generate email with attachment
            System.debug('setupEmailWithAttachment');
            Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(template.ID, null, null);
 			emailMessage.toAddresses = new List<String>{pedidoProveedor.ONE_Email_Proveedor__c};
            emailMessage.WhatId=pedidoProveedorId;
            //Obtain task to get attachment
            ONE_Tarea__c tarea = [SELECT id from ONE_Tarea__c where ONE_Pedido_De_Proveedor__c =:pedidoProveedorId];
            List<id> ContentDocumentids = new List<id>();    
            
            System.debug('Tarea ID -->' + tarea.id);
            for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:tarea.id]) 
            {
                ContentDocumentids.add(CDLink.ContentDocumentid);  
            }

            System.debug('ContentDocumentids-->' + ContentDocumentids);
            List<ContentVersion> ContentVersions = new List<ContentVersion>([SELECT title,PathOnClient, FileType,
                                 versiondata 
                                 FROM contentversion 
                                 WHERE ContentDocumentId IN :ContentDocumentids  
                                ]); 
            
            System.debug('ContentVersions-->' + ContentVersions);
            
            //Set task attachment to the email
			List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            for(ContentVersion CV :ContentVersions){
                Blob Data = CV.VersionData;
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                

                if(Data.size()>0)
                {
                    efa.setBody(Data);
                    efa.setFileName(Cv.PathOnClient);
                    attachments.add(efa);
                }    
            }
            
            //Set generated Marmolista document attachment to the email
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            
            efa.setFileName(fileName);
            efa.setBody(pdfContent);
            attachments.add(efa);
            
            //Set attachment
            emailMessage.setFileAttachments(attachments);

			System.debug('setSubject');
            //Set subject
            emailMessage.setSubject(pedidoProveedor.ONE_Proveedor__r.Name + ' - ' +
                                   	pedidoProveedor.ONE_Expediente__r.Name + ' - ' +
                                   	pedidoProveedor.Name
                                   );
            
       		//Set wide email address
       		if(!Test.isRunningTest()){
            	emailMessage.setOrgWideEmailAddressId([select Id from OrgWideEmailAddress where Address =: pedidoProveedor.ONE_Email_De_Remitente__c].Id);
            }
            //Set bbc address
            System.debug('set bccAddress');
            List<String> bccAddress = new List<String>();
            bccAddress.add(pedidoProveedor.ONE_Email_De_Remitente__c);
            emailMessage.setBccAddresses(bccAddress);
            //Set body
            System.debug('setBody');
            emailMessage.setPlainTextBody(ONE_PdfGeneratorHelper.setupEmailBodyForMarmolistaMedicoGestoria(template.Body, pedidoProveedor)); 
            //Send email
            System.debug('sendEmail');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
            System.debug('Email Send');
            System.debug('emailMessage--> ' + emailMessage);
            
        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
                }
        return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
            }
    
    public virtual class FlowInput {
        @InvocableVariable
        public Id pedidoProveedorId;
        @InvocableVariable
        public String language;
    }
    
}
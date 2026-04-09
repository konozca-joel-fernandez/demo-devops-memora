public class ONE_PedidoGestoriaPdfService {
    private Id pedidoProveedorId;
    private List<FlowInput> inputs;
    
    
    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_PedidoGestoriaPdfService service = new ONE_PedidoGestoriaPdfService(inputs);
        return service.createAndLinkPdf(ONE_PdfGeneratorHelper.getTitleLabel('Pedido_Gestoria'));
    }
    
    public ONE_PedidoGestoriaPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }
    
    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.pedidoProveedorId = datosInput.pedidoProveedorId;
        String language = datosInput.language;
        
        PageReference pageRef = Page.ONE_PedidoGestoriaPdf;
        
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
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.pedidoProveedorId, fileName,ONE_CommonConstants.DOCUMENT_TAG_PEDIDO_GESTORIA);
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
            EmailTemplate template =              
                input.language == 'CA'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_MARMOLISTA_MEDICO_GESTORIA_CA]:
            	input.language == 'EU'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_MARMOLISTA_MEDICO_GESTORIA_EU]:
            	[SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_MARMOLISTA_MEDICO_GESTORIA_ES]; 
            //Generate email with attachment
            Messaging.SingleEmailMessage emailMessage = ONE_PdfGeneratorHelper.setupEmailWithAttachment(
                pdfContent,
                pedidoProveedor.ONE_Email_Proveedor__c,
                fileName,
                template.ID
            );
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
            List<String> bccAddress = new List<String>();
            bccAddress.add(pedidoProveedor.ONE_Email_De_Remitente__c);
            emailMessage.setBccAddresses(bccAddress);
            emailMessage.WhatId=pedidoProveedorId;
            //Set body
            emailMessage.setPlainTextBody(ONE_PdfGeneratorHelper.setupEmailBodyForMarmolistaMedicoGestoria(template.Body, pedidoProveedor));           
            //Send email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
            
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
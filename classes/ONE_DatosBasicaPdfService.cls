public with sharing class ONE_DatosBasicaPdfService extends ONE_PdfServiceBase { 
    private EmailTemplate template;
    private Id pedidoId;
    private ONE_Pedido_De_Proveedor__c pedido;
    
    @InvocableMethod
    public static List<FlowOutput> sendEmailWithPdf(List<FlowInput> inputs) {
        ONE_DatosBasicaPdfService service = new ONE_DatosBasicaPdfService(inputs);
        return service.sendEmailWithPdf(ONE_PdfGeneratorHelper.getTitleLabel(label.ONE_Doc_Datos_Basica_File_Name));
    }
    
    public ONE_DatosBasicaPdfService(List<FlowInput> inputs) {
        super(inputs);
        FlowInput input = inputs.get(0);
        template =                 
            input.language == 'CA'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_DATOS_BASICA_DEV_NAME_CA]:
        	input.language == 'EU'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_DATOS_BASICA_DEV_NAME_EU]:
        	[SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_DATOS_BASICA_DEV_NAME_ES];  
        templateId =  template.Id;
        pedido = ONE_PedidoDeProveedorSelector.selectPedidoDeProveedorForEmail(input.pedidoId);
        emailProveedor = pedido.ONE_Email_Proveedor__c;
    }
    
    protected override Blob buildPdfContent(ONE_PdfServiceBase.FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.pedidoId = datosInput.pedidoId;
        String language = datosInput.language;
        
        PageReference pageRef = Page.ONE_DatosBasicaPdf;
        
        pageRef.getParameters().put('pedidoId', pedidoId);
        pageRef.getParameters().put('language', language);
        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }        
        return pageRef.getContentAsPDF();
    }
    
    protected override Messaging.SingleEmailMessage setupEmail(Blob pdfContent, String toEmail, String fileName) {
        Messaging.SingleEmailMessage emailMessage = super.setupEmail(pdfContent, toEmail, fileName);
        emailMessage.subject = setupEmailSubject(template.Subject, pedido);
        emailMessage.setPlainTextBody(setupEmailBody(template.Body, pedido));
        //Set wide email address
        if(!Test.isRunningTest())
        	emailMessage.setOrgWideEmailAddressId([select Id from OrgWideEmailAddress where Address =: pedido.ONE_Email_De_Remitente__c].Id);
        //Set bbc address
        List<String> bccAddress = new List<String>();
        bccAddress.add(pedido.ONE_Email_De_Remitente__c);
        emailMessage.setBccAddresses(bccAddress);
        return emailMessage;
    }
    
    private String setupEmailSubject(String templateSubject, ONE_Pedido_De_Proveedor__c pedido) {
        templateSubject = templateSubject.replace('[ONE_Pedido_De_Proveedor__c.ONE_Proveedor__r.Name]', pedido.ONE_Proveedor__r.Name);
        templateSubject = templateSubject.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.Name]', pedido.ONE_Expediente__r.Name);
        templateSubject = templateSubject.replace('[ONE_Pedido_De_Proveedor__c.Name]', pedido.Name);
        
        return templateSubject;
    }
    
    private String setupEmailBody(String templateBody, ONE_Pedido_De_Proveedor__c pedido) {
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.Name]', pedido.Name);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.FirstName]', pedido.ONE_Expediente__r.ONE_Difunto__r.FirstName);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.LastName]', pedido.ONE_Expediente__r.ONE_Difunto__r.LastName);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.Name]', pedido.ONE_Expediente__r.Name);
    
        return templateBody;
    }
}
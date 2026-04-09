public with sharing class ONE_PedidoMesaFirmasPdfService extends ONE_PdfServiceBase {

    private EmailTemplate template;
    private Id pedidoId;
    private ONE_Pedido_De_Proveedor__c pedido; 

    @InvocableMethod
    public static List<FlowOutput> sendEmailWithPdf(List<FlowInput> inputs) {
        ONE_PedidoMesaFirmasPdfService service = new ONE_PedidoMesaFirmasPdfService(inputs);
        return service.sendEmailWithPdf(ONE_PdfGeneratorHelper.getTitleLabel('Pedido Mesa Firmas')); 
    }

    public ONE_PedidoMesaFirmasPdfService(List<FlowInput> inputs) {
        super(inputs);
        FlowInput input = inputs.get(0);
        template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName ='ONE_Pedido_Mesa_Firmas'];                  
        templateId =  template.Id;
        pedido = ONE_PedidoDeProveedorSelector.selectPedidoDeProveedorForEmail(input.pedidoId);
        emailProveedor = pedido.ONE_Email_Proveedor__c;
    }

    protected override Blob buildPdfContent(ONE_PdfServiceBase.FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.pedidoId = datosInput.pedidoId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_PedidoMesaFirmas;

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
        //relate mail to pedido
        emailMessage.WhatId=pedidoId;
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
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.FirstName]', pedido.ONE_Expediente__r?.ONE_Difunto__r?.FirstName != null? pedido.ONE_Expediente__r?.ONE_Difunto__r?.FirstName:'');
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.LastName]', pedido.ONE_Expediente__r?.ONE_Difunto__r?.LastName != null? pedido.ONE_Expediente__r?.ONE_Difunto__r?.LastName:'');
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.Name]', pedido.ONE_Expediente__r.Name);

        return templateBody;
    }

    public class MesaFirmasData {

        public String language {public get; private set;}
        public HeaderData headerData {public get; private set;}
        public String logoUrl {public get; public set;}
        public String documentCode {public get; public set;}
        public TareaData tarea {public get; public set;}
        public List<SLIData> slisFloresData {public get; public set;}
        public List<SLIData> slisRecordatoriosData {public get; public set;}
        public Boolean floresEmpty {public get; public set;}
        public Boolean recordatorioEmpty {public get; public set;}
        public MomentosData momentosData {public get; public set;}
        
        public MesaFirmasData(String language, HeaderData headerData) {
            this.language = language;
            this.headerData = headerData;
        }
    }

    public class MomentosData {

        public String lugarDespedida {public get; public set;}
        public String fechaHoraDespedida {public get; public set;}

    }

    public class TareaData {

        public String producto {public get; public set;}
        public Decimal cantidad {public get; public set;}
        public String comentarios {public get; public set;}

    }

    public class SLIData {

        public String productoSLI {get; set;}
        public Decimal cantidadSLI {get; set;}
        public String comentariosSLI {get; set;}

    }

}
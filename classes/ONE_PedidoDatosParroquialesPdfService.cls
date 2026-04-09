public with sharing class ONE_PedidoDatosParroquialesPdfService extends ONE_PdfServiceBase {

    private EmailTemplate template;
    private Id pedidoId;
    private ONE_Pedido_De_Proveedor__c pedido;

    @InvocableMethod
    public static List<FlowOutput> sendEmailWithPdf(List<FlowInput> inputs) {
        ONE_PedidoDatosParroquialesPdfService service = new ONE_PedidoDatosParroquialesPdfService(inputs);
        return service.sendEmailWithPdf('PedidoDatosParroquiales.pdf');
    }

    public ONE_PedidoDatosParroquialesPdfService(List<FlowInput> inputs) {
        super(inputs);
        FlowInput input = inputs.get(0);
        template =                 
            input.language == 'CA'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_DATOS_PARROQUIALES_DEV_NAME_ES]:
        	input.language == 'EU'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_DATOS_PARROQUIALES_DEV_NAME_CA]:
        	[SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_DATOS_PARROQUIALES_DEV_NAME_ES];         
        templateId =  template.Id;
        pedido = ONE_PedidoDeProveedorSelector.selectPedidoDeProveedorForEmail(input.pedidoId);
        emailProveedor = pedido.ONE_Email_Proveedor__c;
    }

    protected override Blob buildPdfContent(ONE_PdfServiceBase.FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.pedidoId = datosInput.pedidoId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_PedidoDatosParroquialesPdf;

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
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.FirstName]', pedido.ONE_Expediente__r.ONE_Difunto__r.FirstName);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.LastName]', pedido.ONE_Expediente__r.ONE_Difunto__r.LastName);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.Name]', pedido.ONE_Expediente__r.Name);

        return templateBody;
    }

    public class DatosParroquialesData {
        public String language {public get; private set;}
        public HeaderData headerData {public get; private set;}
        public String logoUrl {public get; public set;}
        public String documentCode {public get; public set;}
        public String comentarios {public get; public set;}
        public DatosDelDifunto difunto {public get; public set;}
        public DatosDeLaDefuncion defuncion {public get; public set;}
        public DatosDeLaCeremoniaDestino ceremoniaDestino {public get; public set;}
        public ReciboCeremonia reciboCeremonia {public get; public set;}

        public DatosParroquialesData(String language, HeaderData headerData) {
            this.language = language;
            this.headerData = headerData;
        }
    }

    public class DatosDelDifunto {
        public String nombre {get; set;}
        public String nombreColoquial {get; set;}
        public String fechaNacimiento {get; set;}
        public Decimal edad {get; set;}
        public String nacionalidad {get; set;}
        public String lugarNacimiento {get; set;}
        public String nombrePadres {get; set;}
        public String domicilio {get; set;}
        public String estadoCivil {get; set;}
        public String conyuge {get; set;}
        public String hijos {get; set;}
        public String declarante {get; set;}
        public String parentesco {get; set;}
        public String telDeclarante {get; set;}
    }

    public class DatosDeLaDefuncion {
        public String fecha {get; set;}
        public String lugar  {get; set;}
        public String poblacion {get; set;}
    }

    public class DatosDeLaCeremoniaDestino {
        public String domicilioMortuorio {get; set;}
        public String pob {get; set;}
        public String ceremoniaEn {get; set;}
        public String pob2 {get; set;}
        public String fecha  {get; set;}
        public String tipoCeremonia {get; set;}
        public String idioma {get; set;}
        public String cementerioCrematorio {get; set;}
        public String fecha2 {get; set;}
    }

    public class ReciboCeremonia {
        public String nServicio {get; set;}
        public String reciboDe {get; set;}
        public String laCantidadDe {get; set;}
        public String enConcepto {get; set;}
        public String enFecha {get; set;}
        public String realizadaEn {get; set;}
    }
}
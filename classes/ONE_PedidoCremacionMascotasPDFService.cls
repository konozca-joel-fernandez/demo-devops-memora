public with sharing class ONE_PedidoCremacionMascotasPDFService extends ONE_PdfServiceBase {

    private EmailTemplate template;
    private Id pedidoId;
    private ONE_Pedido_De_Proveedor__c pedido;
    
        @InvocableMethod
    public static List<FlowOutput> sendEmailWithPdf(List<FlowInput> inputs) {
        ONE_PedidoCremacionMascotasPDFService service = new ONE_PedidoCremacionMascotasPDFService(inputs);
        return service.sendEmailWithPdf(ONE_PdfGeneratorHelper.getTitleLabel('Pedido Cremación Mascotas')); 
    }
    
    public ONE_PedidoCremacionMascotasPDFService(List<FlowInput> inputs) {
        super(inputs);
        FlowInput input = inputs.get(0);       
        template =[SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName ='ONE_Pedido_Cremacion_Mascotas'];                 
        templateId =  template.Id;
        pedido = ONE_PedidoDeProveedorSelector.selectPedidoDeProveedorForEmail(input.pedidoId);
        emailProveedor = pedido.ONE_Email_Proveedor__c;
    }
     protected override Blob buildPdfContent(ONE_PdfServiceBase.FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.pedidoId = datosInput.pedidoId;
        String language = datosInput.language;

         PageReference pageRef = Page.ONE_PedidoCremacionMascotas;

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
        templateSubject = templateSubject.replace('[ONE_Pedido_De_Proveedor__c.Name]', pedido?.Name);
        return templateSubject;
    }

    private String setupEmailBody(String templateBody, ONE_Pedido_De_Proveedor__c pedido) {
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.Name]', pedido?.Name);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.Name]', pedido?.ONE_Expediente__r?.Name !=null? pedido.ONE_Expediente__r.Name : '');
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Nombre_Mascota__c]', pedido?.ONE_Expediente__r?.ONE_Nombre_Mascota__c !=null? pedido.ONE_Expediente__r.ONE_Nombre_Mascota__c:'');
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Tipo_de_Mascota__c]', pedido?.ONE_Expediente__r?.ONE_Tipo_de_Mascota__c !=null? pedido.ONE_Expediente__r.ONE_Tipo_de_Mascota__c :'');
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Peso__c]', String.valueof(pedido?.ONE_Expediente__r?.ONE_Peso__c)!=null ? String.valueof(pedido.ONE_Expediente__r.ONE_Peso__c):'');
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Tipo_de_Incineracion__c]', pedido?.ONE_Expediente__r?.ONE_Tipo_de_Incineracion__c !=null? pedido.ONE_Expediente__r.ONE_Tipo_de_Incineracion__c : '');
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Observaciones__c]', pedido?.ONE_Expediente__r?.ONE_Observaciones__c !=null?  pedido.ONE_Expediente__r.ONE_Observaciones__c: '');
        
        return templateBody;
    }
    
        public class MascotasData {
            
        public String logoUrl {public get; public set;}
        public String documentCode {public get; public set;}
        public String asesor {public get; public set;}
        public Date fecha {public get; public set;}
        public String nombreMascota {public get; public set;}
        public String tipoMascota {public get; public set;}
        public String razaMascota {public get; public set;}
		public String edadMascota {public get; public set;}
        public Decimal pesoMascota {public get; public set;}
        public String microchip {public get; public set;}
        public String fechaDefuncion {public get; public set;}
        public String direccion {public get; public set;}
        public String codigoPostal {public get; public set;}
        public String municipio {public get; public set;}
        public String provincia {public get; public set;}
        public String nameDeclarante {public get; public set;}
        public String telefonoDeclarante {public get; public set;}
        public String direccionDeclarante {public get; public set;}
        public String codigoPostalDeclarante {public get; public set;}
        public String municipioDeclarante {public get; public set;}
        public String provinciaDeclarante {public get; public set;}
        public String observaciones {public get; public set;}
        public String tipoCremacion {public get; public set;}
        public String nServicio {public get; public set;}
        public String nPedido {public get; public set;}
        public String fechaPedido {public get; public set;}
        public String proveedor {public get; public set;}
        public String centro {public get; public set;}
            
        public MascotasData(String logoUrl,String documentCode,String asesor,Date fecha,String nombreMascota,String tipoMascota,String razaMascota,String edadMascota,
        Decimal pesoMascota,String microchip ,String fechaDefuncion,String direccion,String codigoPostal,String municipio,String provincia,String nameDeclarante,String telefonoDeclarante,
        String direccionDeclarante,String codigoPostalDeclarante,String municipioDeclarante,String provinciaDeclarante,String observaciones,String tipoCremacion,String nServicio,
        String nPedido,String fechaPedido,String proveedor, String centro) {
  
            this.logoUrl=logoUrl;
            this.documentCode=documentCode;
            this.asesor=asesor;
            this.fecha=fecha;
            this.nombreMascota=nombreMascota;
            this.tipoMascota=tipoMascota;
            this.razaMascota=razaMascota;
            this.edadMascota=edadMascota;
            this.pesoMascota=pesoMascota;
            this.microchip=microchip;
            this.fechaDefuncion=fechaDefuncion;
            this.direccion=direccion; 
            this.codigoPostal=codigoPostal;
            this.municipio=municipio;
            this.provincia=provincia;
            this.nameDeclarante=nameDeclarante;
            this.telefonoDeclarante=telefonoDeclarante;
            this.direccionDeclarante=direccionDeclarante;
            this.codigoPostalDeclarante=codigoPostalDeclarante;
            this.municipioDeclarante=municipioDeclarante;
            this.provinciaDeclarante=provinciaDeclarante;
            this.observaciones=observaciones;
            this.tipoCremacion=tipoCremacion;
            this.nServicio=nServicio;
            this.nPedido=nPedido;
            this.fechaPedido=fechaPedido;
            this.proveedor=proveedor;
            this.centro=centro;
        }
    }


    
}
/**
* File Name: ONE_PedidoRecordatorioPdfService
* Description: 	PdfService for Recordatorios
* Date: 02/04/2025
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: ONE_PedidoRecordatorioPdfControllerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		02/04/2025		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

public with sharing class ONE_PedidoRecordatorioPdfService extends ONE_PdfServiceBase{

    private EmailTemplate template;
    private Id pedidoId;
    private ONE_Pedido_De_Proveedor__c pedido; 

    @InvocableMethod
    public static List<FlowOutput> sendEmailWithPdf(List<FlowInput> inputs) {
        ONE_PedidoRecordatorioPdfService service = new ONE_PedidoRecordatorioPdfService(inputs);
        return service.sendEmailWithPdf(ONE_PdfGeneratorHelper.getTitleLabel(label.ONE_Doc_Pedido_Recordatorio_File_Name));
    }

    public ONE_PedidoRecordatorioPdfService(List<FlowInput> inputs) {
        super(inputs);
        FlowInput input = inputs.get(0);  
        template =                 
            input.language == 'CA'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_CATERING_FLORES_MUSICA_VEHICULO_DEV_NAME_CA]:
        	input.language == 'EU'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_CATERING_FLORES_MUSICA_VEHICULO_DEV_NAME_EU]:
        	[SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_CATERING_FLORES_MUSICA_VEHICULO_DEV_NAME_ES];                 
        templateId =  template.Id;
        pedido = ONE_PedidoDeProveedorSelector.selectPedidoDeProveedorForEmail(input.pedidoId);
        emailProveedor = pedido.ONE_Email_Proveedor__c;
    }

    protected override Blob buildPdfContent(ONE_PdfServiceBase.FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.pedidoId = datosInput.pedidoId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_PedidoRecordatorioPdf;

        pageRef.getParameters().put('pedidoId', pedidoId);
        pageRef.getParameters().put('language', language);
        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    protected override Messaging.SingleEmailMessage setupEmail(Blob pdfContent, String toEmail, String fileName) {
        Messaging.SingleEmailMessage emailMessage = super.setupEmail(pdfContent, toEmail, fileName);
        
        // Add all atachments
        List<Messaging.EmailFileAttachment> attachments = emailMessage.getFileAttachments();
        if (attachments == null) {
            attachments = new List<Messaging.EmailFileAttachment>();
        }
        // Get related documents
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :pedidoId
        ];

        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink link : docLinks) {
            contentDocIds.add(link.ContentDocumentId);
        }

        if (!contentDocIds.isEmpty()) {
            List<ContentVersion> contentVersions = [
                SELECT Title, VersionData, PathOnClient FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocIds
                AND IsLatest = true
            ];
    
            for (ContentVersion cv : contentVersions) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv.PathOnClient);
                attachment.setBody(cv.VersionData);
                attachments.add(attachment);
            }
        }
    
        // Set attachments
        emailMessage.setFileAttachments(attachments);

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
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.FirstName]', pedido.ONE_Expediente__r.ONE_Difunto__r.FirstName);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.LastName]', pedido.ONE_Expediente__r.ONE_Difunto__r.LastName);
        templateBody = templateBody.replace('[ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.Name]', pedido.ONE_Expediente__r.Name);

        return templateBody;
    }

    public class RecordatorioData {
        public String language {public get; private set;}
        public HeaderData headerData {public get; private set;}
        public String logoUrl {public get; public set;}
        public String documentCode {public get; public set;}
        public MomentosData momentosData {public get; public set;}
        public List<TareaData> tareaData {public get; public set;}

        public RecordatorioData(String language, HeaderData headerData) {
            this.language = language;
            this.headerData = headerData;
        }
    }

    public class MomentosData {

        public String lugarDespedida {public get; public set;}
        public String fechaHoraDespedida {public get; public set;}
        public String lugarDeposito {public get; public set;}
        public String fechaHoraDeposito {public get; public set;}

    }

    public class TareaData {

        public Integer id {get; set;}
        public String lugarDeEntrega {get; set;}
        public String sala {get; set;}
        public String materialContratado {get; set;}
        public Decimal unidades {get; set;}
        public String fecha {get; set;}
        public String observaciones {get; set;}

    }
}
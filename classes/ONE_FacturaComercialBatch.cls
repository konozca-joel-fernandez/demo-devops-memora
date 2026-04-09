/**
 * Created by msulek003 on 29.04.2021.
 */

public with sharing class ONE_FacturaComercialBatch implements Database.Batchable<sObject> {
    List<ContentDocumentLink> contentDocumentLinks;

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ONE_Tipo_De_Factura__c, ONE_Enviar_Factura_a_Cliente__c, ONE_Factura_Enviada_a_Cliente__c, ONE_Numero_de_factura__c,'+
            'ONE_Numero_Abono_Factura__c, ONE_Servicio__r.ONE_Declarante__r.ONE_Email__c, ONE_Servicio__r.ONE_Declarante__r.PersonEmail, ONE_El_Pagador_Es_El_Difunto__c, ONE_Estado_De_La_Orden_de_Venta__c, ONE_Pagador_Particular__c,  ONE_Pagador_Particular__r.ONE_Contacto__r.PersonEmail,'+
            'ONE_Resultado_Batch__c, ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Email__c, ONE_Pagador_Compania__c, ONE_Pagador_Compania__r.ONE_Email__c, ONE_Idioma_de_la_factura__c '+
            ' FROM ONE_Orden_De_Venta__c'+
            ' WHERE ONE_Enviar_Factura_a_Cliente__c = true'+
            ' AND ONE_Factura_Enviada_a_Cliente__c = false'+
            ' AND ONE_Numero_de_factura__c != null' +
            ' AND ONE_Numero_Abono_Factura__c = null'+
            ' AND ONE_Estado_De_La_Orden_de_Venta__c = \'Facturado\''+
            ' AND ONE_Resultado_Batch__c = null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ONE_Orden_De_Venta__c> ordenDeVentaList){
        EmailTemplate template;
        contentDocumentLinks = new List<ContentDocumentLink>();
        System.debug('ordenDeVenta from query -->' + ordenDeVentaList);
        for(ONE_Orden_De_Venta__c ordenDeVenta: ordenDeVentaList) {
            template =                 
                ordenDeVenta?.ONE_Idioma_de_la_factura__c == 'CA'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_FACTURA_PDF_DEV_NAME_CA]:
            	ordenDeVenta?.ONE_Idioma_de_la_factura__c == 'EU'? [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_FACTURA_PDF_DEV_NAME_EU]:
            	[SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_FACTURA_PDF_DEV_NAME_ES]; 
            
            System.debug('ordenDeVenta ID to send PDF -->' + ordenDeVenta);
            System.debug('template -->' + template); 
            if (ordenDeVenta.ONE_Tipo_De_Factura__c == '02') {
                System.debug('sendSimpifiedFactura');
                sendSimpifiedFactura(ordenDeVenta, template);
            } else if (ordenDeVenta.ONE_Tipo_De_Factura__c == '01') {
                System.debug('sendFactura');
                sendFactura(ordenDeVenta, template);
            } else {
                System.debug('No tipo de factura');
            }
        }

        insert contentDocumentLinks;
        update ordenDeVentaList;
    }

    public void finish(Database.BatchableContext BC){
    }

    private void sendSimpifiedFactura (ONE_Orden_De_Venta__c ordenDeVenta, EmailTemplate template) {
        String emailAddress = setEmailAddress(ordenDeVenta);
        if(emailAddress == null) {
            ordenDeVenta.ONE_Resultado_Batch__c = label.ONE_Doc_No_Email_Message;
            return;
        }

        List<ONE_PdfServiceBase.FlowOutput> outputs = sendEmailWithPdf(ONE_PdfGeneratorHelper.getTitleLabel(label.ONE_Doc_Factura_Simplificada_Comercial_File_Name),
            ordenDeVenta?.ONE_Idioma_de_la_factura__c, ordenDeVenta.Id, Page.ONE_FacturaSimplificadaComercialPdf, emailAddress, template.Id, ONE_CommonConstants.DOCUMENT_TAG_FACTURA_COMERCIAL_SIMPLIFICADA);
        processResults(ordenDeVenta, outputs.get(0), emailAddress);
    }

    private void sendFactura (ONE_Orden_De_Venta__c ordenDeVenta, EmailTemplate template) {
        String emailAddress = setEmailAddress(ordenDeVenta);
        if(emailAddress == null) {
            ordenDeVenta.ONE_Resultado_Batch__c = label.ONE_Doc_No_Email_Message;
            return;
        }

        List<ONE_PdfServiceBase.FlowOutput> outputs = sendEmailWithPdf(ONE_PdfGeneratorHelper.getTitleLabel(label.ONE_Doc_Factura_Comercial_File_Name),
        ordenDeVenta?.ONE_Idioma_de_la_factura__c, ordenDeVenta.Id, Page.ONE_FacturaComercialPdf, emailAddress, template.Id,  ONE_CommonConstants.DOCUMENT_TAG_FACTURA_COMERCIAL);
        processResults(ordenDeVenta, outputs.get(0), emailAddress);
    }

    private String setEmailAddress (ONE_Orden_De_Venta__c ordenDeVenta) {
        if(ordenDeVenta.ONE_El_Pagador_Es_El_Difunto__c == true){
            return (ordenDeVenta?.ONE_Servicio__r?.ONE_Declarante__r?.ONE_Email__c != null) ? 
            ordenDeVenta?.ONE_Servicio__r?.ONE_Declarante__r?.ONE_Email__c : ordenDeVenta?.ONE_Servicio__r?.ONE_Declarante__r?.PersonEmail;
        }
        if(ordenDeVenta.ONE_Pagador_Particular__c != null
            && ordenDeVenta.ONE_Pagador_Particular__r.ONE_Contacto__r.PersonEmail != null) {
            return ordenDeVenta.ONE_Pagador_Particular__r.ONE_Contacto__r.PersonEmail;
            
        } else if(ordenDeVenta.ONE_Pagador_Particular__c != null
            && ordenDeVenta.ONE_Pagador_Particular__r.ONE_Contacto__r.PersonEmail == null) {
            return ordenDeVenta.ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Email__c;       
                
        } else if(ordenDeVenta.ONE_Pagador_Compania__c != null
            && ordenDeVenta.ONE_Pagador_Compania__r.ONE_Email__c != null) {
            return ordenDeVenta.ONE_Pagador_Compania__r.ONE_Email__c;
        } else {
            return null;
        }
    }


        private void processResults (ONE_Orden_De_Venta__c ordenDeVenta, ONE_PdfServiceBase.FlowOutput output, String emailAddress) {
        if(output.success == true) {
            ordenDeVenta.ONE_Resultado_Batch__c =  label.ONE_Doc_Email_Sent + emailAddress;
            ordenDeVenta.ONE_Factura_Enviada_a_Cliente__c = true;
        } else {
            ordenDeVenta.ONE_Resultado_Batch__c = output.errorMessage;
        }
    }

    private List<ONE_PdfServiceBase.FlowOutput> sendEmailWithPdf (String fileName, String language, String ordenDeVentaId, PageReference pageReference,
    String emailAddress, String emailTemplate, String documentTAG) {
        System.debug('sendEmailWithPdf');
        System.debug('language-->' + language);
        try {
            Blob pdfContent = buildPdfContent(language, ordenDeVentaId, pageReference);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, ordenDeVentaId, fileName, documentTAG);
            contentDocumentLinks.add(
                new ContentDocumentLink(ContentDocumentId = pdfId, LinkedEntityId = ordenDeVentaId));
            Messaging.SingleEmailMessage emailMessage = ONE_PdfGeneratorHelper.setupEmailWithAttachment(
                pdfContent, emailAddress, fileName, emailTemplate);

            Id servicioId = [SELECT ONE_Servicio__c FROM ONE_Orden_De_Venta__c WHERE Id =:ordenDeVentaId].ONE_Servicio__c;
            
            

            
            if(servicioId != null){

                emailMessage.setWhatId(servicioId);
                contentDocumentLinks.add(new ContentDocumentLink(
                    ContentDocumentId = pdfId, 
                    LinkedEntityId = servicioId,
                    ShareType = 'V'));

            } 

            //Search for external ID in order to know wich email we need to set as a sender
            String externalID = [Select ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_External_ID__c 
                                 from ONE_Orden_De_Venta__c 
                                 where id =:ordenDeVentaId ].ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_External_ID__c;
            
            //With the eternal ID find the corresponding email, in case we don't find any email we will use the default one                    
            List<ONE_Correos_Electronicos__mdt> emailList = new List <ONE_Correos_Electronicos__mdt>();
            String email;
            if(externalID != null){
                emailList = [Select ONE_Email__c, ONE_ExternalID__c from ONE_Correos_Electronicos__mdt where ONE_ExternalID__c =:externalID ]; 
                if(emailList.size()>0)
                    email =emailList[0].ONE_Email__c;
                else{
                    email = [Select ONE_Email__c, ONE_ExternalID__c from ONE_Correos_Electronicos__mdt where ONE_ExternalID__c ='XXXXXX'].ONE_Email__c;
                }                                            
            }else{
                email = [Select ONE_Email__c, ONE_ExternalID__c from ONE_Correos_Electronicos__mdt where ONE_ExternalID__c ='XXXXXX'].ONE_Email__c;
            }

            System.debug('externalID-->' + externalID);                      
            System.debug('email-->' + email);
            emailMessage.setOrgWideEmailAddressId([Select id, Address from OrgWideEmailAddress where Address =:email].id);                                                        
            //Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
            if (results != null && results[0].isSuccess()) {
                // Buscar el EmailMessage más reciente asociado al Servicio y destinatario
                List<EmailMessage> recentMessages = [
                    SELECT Id, Subject, CreatedDate 
                    FROM EmailMessage 
                    WHERE RelatedToId = :servicioId
                    AND ToAddress = :emailAddress
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ];

                if (!recentMessages.isEmpty()) {
                    Id emailMessageId = recentMessages[0].Id;

                    try {
                        insert new ContentDocumentLink(
                            ContentDocumentId = pdfId,
                            LinkedEntityId = emailMessageId,
                            ShareType = 'V',
                            Visibility = 'AllUsers'
                        );
                        System.debug('Email sent and file linked to EmailMessage: ' + emailMessageId);
                    } catch (Exception docErr) {
                        System.debug('Error linking file to EmailMessage: ' + docErr.getMessage());
                    }
                } else {
                    System.debug('No EmailMessage record found after sending email');
                }
            }

            
        } catch (Exception ex) {
            System.debug('catch');
            return new List<ONE_PdfServiceBase.FlowOutput>{
                new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
        }
        return new List<ONE_PdfServiceBase.FlowOutput>{
            new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
    }

    private Blob buildPdfContent(String language, String ordenDeVentaId, PageReference pageReference) {
        System.debug('buildPdfContent');
        System.debug('language-->' + language);
        System.debug('ordenDeVentaId-->' + ordenDeVentaId);
        System.debug('pageReference-->' + pageReference);

        pageReference.getParameters().put('ordenDeVentaId', ordenDeVentaId);
        pageReference.getParameters().put('language', language);

        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageReference.getContentAsPDF();
    }


}
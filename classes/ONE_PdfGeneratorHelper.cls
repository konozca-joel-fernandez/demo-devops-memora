/**
 * Created by msulek003 on 07.04.2021.
 * Last Modified by Alex Climent
 */

public with sharing class ONE_PdfGeneratorHelper {

    public static String getTitleLabel(String titleLabel) {
        String dateTimeString = Datetime.now().format('dd/MM/yyyy HH:mm');
        return titleLabel + '(' + dateTimeString + ').pdf';
    }

    public static Id savePdf(Blob pdfContent, Id parentId, String fileName, String documentTAG) {
        ContentVersion versionData = new ContentVersion();
        versionData.ContentLocation = 'S';
        versionData.VersionData = pdfContent;
        versionData.Title = fileName;
        versionData.PathOnClient = fileName;
        versionData.TagCsv = documentTAG;
        insert versionData;

        Id contentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :versionData.Id
        ].ContentDocumentId;
        return contentDocumentId;
    }

    public static void linkWithParent(Id contentDocumentId, Id parentId) {
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = contentDocumentId;
        conDocLink.LinkedEntityId = parentId;
        insert conDocLink;
    }

    public static void linkWithPersonaParticular(Id contentDocumentId, Id parentId) {
        ONE_Documentos__c documentos = [SELECT Id, ONE_Persona_Particular__c FROM ONE_Documentos__c WHERE Id = :parentId];
        if (documentos.ONE_Persona_Particular__c != null) {
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentDocumentId;
            conDocLink.LinkedEntityId = documentos.ONE_Persona_Particular__c;
            insert conDocLink;
        }
    }

    public static void linkWithServico(Id contentDocumentId, Id parentId) {
        ONE_Documentos__c documentos = [SELECT Id, ONE_Servicio__c FROM ONE_Documentos__c WHERE Id = :parentId];
        if (documentos.ONE_Servicio__c != null) {
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentDocumentId;
            conDocLink.LinkedEntityId = documentos.ONE_Servicio__c;
            insert conDocLink;
        }

    }

    public static void linkWithServicoFromOrdenDeVenta(Id contentDocumentId, Id parentId) {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id, ONE_Servicio__c FROM ONE_Orden_De_Venta__c WHERE Id = :parentId];
        if (ordenDeVenta.ONE_Servicio__c != null) {
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentDocumentId;
            conDocLink.LinkedEntityId = ordenDeVenta.ONE_Servicio__c;
            insert conDocLink;
        }

    }
    
    
    
      public static void linkWithOpportunity(Id contentDocumentId, Id documentoId) {
         
        
        ONE_Documentos__c documento = [ // consultamos el documento para obtener la oportunidad relacionada
            SELECT Id, ONE_Oportunidad__c 
            FROM ONE_Documentos__c
            WHERE Id = :documentoId
            LIMIT 1
        ];
        

               
        if (documento.ONE_Oportunidad__c != null) { 
            
            ONE_Oportunidad__c oportunidad = [ 
                SELECT Id
                FROM ONE_Oportunidad__c
                WHERE Id = :documento.ONE_Oportunidad__c
                LIMIT 1
            ];
            
            oportunidad.ONE_CheckPdf__c = true;
            update oportunidad;
            
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentDocumentId;
            conDocLink.LinkedEntityId = documento.ONE_Oportunidad__c;
    
            if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) { 
                insert conDocLink;
            } else {
                System.debug('No se pudo crear el enlace con la Oportunidad por permisos insuficientes.');
            }
        } else {
            System.debug('El Documento no tiene una Oportunidad asociada.');
        }
    }

    public static Messaging.SingleEmailMessage setupEmailWithAttachment(Blob pdfContent, String toEmail, String fileName, Id templateId) {
        Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(templateId, null, null);
        emailMessage.toAddresses = new List<String>{
            toEmail
        };
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(pdfContent);
        attachments.add(efa);
        emailMessage.setFileAttachments(attachments);
        return emailMessage;
    }

    public static String setupEmailBodyForMarmolistaMedicoGestoria(String templateBody, ONE_Pedido_De_Proveedor__c pedido) {

        templateBody = templateBody.replace('ONE_Pedido_De_Proveedor__c.Name', pedido.Name);
        templateBody = templateBody.replace('ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.Name', pedido?.ONE_Expediente__r?.Name);
        templateBody = templateBody.replace('ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.FirstName', 
                                             pedido?.ONE_Expediente__r?.ONE_Difunto__r?.FirstName != null ?
                                          	 pedido?.ONE_Expediente__r?.ONE_Difunto__r?.FirstName:
                                             '');
        templateBody = templateBody.replace('ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.LastName', 
                                            pedido?.ONE_Expediente__r?.ONE_Difunto__r?.LastName != null ?
                                           	pedido?.ONE_Expediente__r?.ONE_Difunto__r?.LastName:
                                            '');

        return templateBody;
    }

    public static String getDateString() {
        return Datetime.now().format('dd/MM/yyyy HH:mm');
    }

    public static String buildCommonLabel(Id presupuestoId, String prefix) {
        ONE_Presupuesto__c presupuesto = [SELECT Id, Name, ONE_Expediente__r.Name FROM ONE_Presupuesto__c WHERE Id = :presupuestoId];
        String label = prefix + ' ' + presupuesto.Name;
        label += presupuesto.ONE_Expediente__r.Name != null ? ' / Nº Servicio: ' + presupuesto.ONE_Expediente__r.Name : ' / Nº Servicio: ';
        label += ' / ' + getDateString();
        label += '.pdf';
        return label;
    }
    
    public static String buildCommonLabelM1(Id ordenDeVentaId) {
        ONE_Orden_De_Venta__c ov = [SELECT Id, Name, ONE_Servicio__r.Name FROM ONE_Orden_De_Venta__c WHERE Id = :ordenDeVentaId];
        String label = 'Nº Orden De Venta: ' + ov.Name;
        label += ov.ONE_Servicio__r.Name != null ? ' / Nº Servicio: ' + ov.ONE_Servicio__r.Name : ' / Nº Servicio: ';
        label += ' / ' + getDateString();
        label += '.pdf';
        return label;
    }

    public static String buildCommonExtendedLabel(Id ordenDeVentaId, Boolean isSimpl) {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id, Name, ONE_Numero_de_factura__c,ONE_Presupuesto__r.Name, ONE_Servicio__r.Name,ONE_Tipo_De_Pagador__c,ONE_Fecha_Hora_Del_Abono_Factura__c,ONE_Fecha_De_Facturacion__c FROM ONE_Orden_De_Venta__c WHERE Id = :ordenDeVentaId];
        String label = ordenDeVenta.ONE_Numero_de_factura__c != null ? 'Nº Factura SAP: ' + ordenDeVenta.ONE_Numero_de_factura__c : 'Nº Factura SAP: ';
        label += ordenDeVenta.ONE_Presupuesto__r.Name != null ? ' / Nº Contrato: ' + ordenDeVenta.ONE_Presupuesto__r.Name : '/ Nº Contrato: ';
        label += ordenDeVenta.ONE_Servicio__r.Name != null ? ' / Nº Servicio: ' + ordenDeVenta.ONE_Servicio__r.Name : ' / Nº Servicio: ' ;
        label += ordenDeVenta.ONE_Fecha_De_Facturacion__c != null ? ' / ' + ordenDeVenta.ONE_Fecha_De_Facturacion__c.format() : '';
        if (!isSimpl) {
            label += ordenDeVenta.ONE_Tipo_De_Pagador__c != null ? ' / Pagador: ' + ordenDeVenta.ONE_Tipo_De_Pagador__c : ' / Pagador: ';
        }
        label += '.pdf';
        return label;
    }

    public static String getNameOrNombreFiscalDeLaCuenta(ONE_Orden_De_Venta__c orden) {
        if (orden?.ONE_Pagador_Compania__r?.RecordType.DeveloperName == ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS) {
            if( orden?.ONE_Pagador_Compania__r?.ONE_Nombre_Anexo__c == null) {
                return orden?.ONE_Pagador_Compania__r?.ONE_Nombre_Fiscal_De_La_Cuenta__c;
            }else{
            String nombreFiscal = orden?.ONE_Pagador_Compania__r?.ONE_Nombre_Fiscal_De_La_Cuenta__c + '-' + orden?.ONE_Pagador_Compania__r?.ONE_Nombre_Anexo__c;
            return nombreFiscal;
            }
        } else {
            return orden?.ONE_Pagador_Compania__r.Name;
        }
    }

    public static String getNameOrNombreFiscalDeLaCuenta(ONE_Presupuesto__c presupuesto) {
        if (presupuesto?.ONE_Pagador_Compania__r?.RecordType.DeveloperName == ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS) {
            return presupuesto?.ONE_Pagador_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c;
        } else {
            return presupuesto?.ONE_Pagador_Compania__r.Name;
        }
    }
}
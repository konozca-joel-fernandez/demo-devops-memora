/**
 * Created by msulek003 on 06.04.2021. 
 */
//Class to define all the queries that will get all the apropiate data to generate the PDF
public with sharing class ONE_SolicitudDeIncineracionDataFactory {
    //Get all the data and store in the Data object created
    public static ONE_SolicitudDeIncineracionData buildSolicitudDeIncineracionData(String documentosId, String language) {
        ONE_Documentos__c documentosRecord = selectDocumentosForPdfGeneration(documentosId);
        String signatureUrl = getSignatureImgUrl(documentosId);

        System.debug('Document query: ' + documentosRecord);

		ONE_SolicitudDeIncineracionData.CheckboxFields checkboxFields = new ONE_SolicitudDeIncineracionData.CheckBoxFields(documentosRecord.ONE_Custodia_Familiar__c, documentosRecord.ONE_Renuncia_Cenizas__c, documentosRecord.ONE_AUTORIZO_al_contacto_Checkbox__c);
        
        string logo = documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? documentosRecord?.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        
        ONE_SolicitudDeIncineracionData.DocumentData docData = new ONE_SolicitudDeIncineracionData.DocumentData(
        	logo, 
            getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_SOLICITUD_INCINERACION), 
            documentosRecord.ONE_Servicio__r?.Name, 
            documentosRecord.ONE_CREMATORIO__c, 
			documentosRecord.ONE_Solicitante__c, 
            documentosRecord.ONE_Poblacion__c,
            documentosRecord.ONE_Direccion__c, 
            documentosRecord.ONE_Telefono__c, 
			documentosRecord.ONE_SOLICITA_la_incineracion_de__c, 
            documentosRecord.ONE_Lugar_de_Fallecimiento__c, 
            documentosRecord.ONE_Fallecido_en_fecha__c, 
			documentosRecord.Sociedad__c, 
            documentosRecord.ONE_Documento_de_Identidad_Subscriptor__c, 
			documentosRecord.ONE_Documento_de_Identidad_Difunto__c, 
            documentosRecord.ONE_Codigo_Postal__c, 
            documentosRecord.ONE_Provincia2__c, 
			documentosRecord.ONE_Parentesco__c, 
            documentosRecord.ONE_Marcapasos_PickList__c, 
            documentosRecord.ONE_Inhumacion_en_el_Cementerio__c, 
			documentosRecord.ONE_Que_el_esparcimiento_de_las_cenizas__c, 
            documentosRecord.ONE_AUTORIZO_al_contacto__c, 
			documentosRecord.ONE_Custodia_en_las_instalaciones__c, 
            documentosRecord.ONE_Destino_de_las_flores__c, 
			documentosRecord.ONE_Asistencia_Incineracion__c, 
            documentosRecord.ONE_Observaciones__c, 
            documentosRecord?.ONE_En_Lugar__r?.Name, 
			documentosRecord.ONE_Fecha_Now__c, 
            signatureUrl, 
            documentosRecord.ONE_Municipio__c,
			ONE_CommonUtils.changeNullToBlank(documentosRecord.ONE_Fecha_Hora_Cremacion__c?.format())
        );
        
        ONE_SolicitudDeIncineracionData.FooterData footerData = new ONE_SolicitudDeIncineracionData.FooterData(
            documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c
        );
        
        ONE_SolicitudDeIncineracionData data = new ONE_SolicitudDeIncineracionData(
            language, 
            docData,
            checkboxFields, 
            footerData
        );

        System.debug('DATA: ' + data);
        return data;
    }

	//Query document data 
    public static ONE_Documentos__c selectDocumentosForPdfGeneration(Id documentosId) {
        
        return [
            SELECT Id, ONE_Servicio__r.Name, ONE_Fecha_Hora_Cremacion__c, ONE_CREMATORIO__c, ONE_Solicitante__c, ONE_Poblacion__c, ONE_Direccion__c, ONE_Telefono__c, ONE_SOLICITA_la_incineracion_de__c,
                ONE_Lugar_de_Fallecimiento__c, ONE_Fallecido_en_fecha__c, ONE_Funeraria__c, Sociedad__c, ONE_Documento_de_Identidad_Subscriptor__c, ONE_Codigo_Postal__c,
                toLabel(ONE_Provincia2__c), ONE_Parentesco__c, ONE_Marcapasos_PickList__c, ONE_Inhumacion_en_el_Cementerio__c, ONE_Que_el_esparcimiento_de_las_cenizas__c,
                ONE_Custodia_Familiar__c, ONE_Renuncia_Cenizas__c, ONE_Custodia_en_las_instalaciones__c, toLabel(ONE_Destino_de_las_flores__c), toLabel(ONE_Asistencia_Incineracion__c),
                ONE_Observaciones__c, ONE_En_Lugar__r.Name, ONE_Fecha_Now__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c, 
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c, 
            	ONE_Municipio__c,ONE_Documento_de_Identidad_Difunto__c,
            	ONE_AUTORIZO_al_contacto_Checkbox__c, ONE_AUTORIZO_al_contacto__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c
            FROM ONE_Documentos__c
            WHERE Id = :documentosId
            
        ];
    }
	//Query document code from a custom metada type to display it in the PDF header   
    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }
	//Query signature image to display it in the PDF footer
    private static String getSignatureImgUrl(Id documentosId) {
        List<Attachment> attachments = new List<Attachment>([
            SELECT Id
            FROM Attachment
            WHERE ParentId = :documentosId AND Name = 'Signature.png'
            ORDER BY CreatedDate DESC
        ]);

        if (attachments.isEmpty()) {
            return '';
        } else {
            /*String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
            fileURL = fileURL.replace('visualforce.com','documentforce.com');
            fileURL += '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;
            System.debug('Signature url: ' + fileURL);
            return fileURL;*/
 
            String fileURL = '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;
            System.debug('Signature url: ' + fileURL);
            return fileURL;
        }
    }
}
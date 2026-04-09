/**
 * Created by msulek003 on 29.03.2021. 
 */

public with sharing class ONE_ProtteccionDatosDataFactory {
    public static ONE_ProtteccionDatosData buildProtteccionDatosData(String documentosId, String language) {
        ONE_Documentos__c documentosRecord = selectDocumentosForPdfGeneration(documentosId);
        String signatureUrl = getSignatureImgUrl(documentosId);
		ONE_ProtteccionDatosData data;
        
        
        
        /*
        string logo = documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;

*/
        if(documentosRecord?.ONE_Oportunidad__c == null && documentosRecord?.ONE_Parentesco_Tratamiento__c == null){
                string logo = documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
                    ? documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
                    : documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
            
            data = new ONE_ProtteccionDatosData(
                logo, language,
                getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PROTECCION_DATOS), documentosRecord.El_que_subscribe_Tratamiento__c,
                documentosRecord.Documento_de_Identidad_Tratamiento__c, documentosRecord.ONE_Domicialiado_en_Poblacion__c,
                documentosRecord.ONE_Parentesco_Tratamiento__c, documentosRecord.ONE_Provincia2__c, documentosRecord.ONE_Calle__c,
                documentosRecord.ONE_Telefono_de_Contacto__c, documentosRecord.ONE_Email__c, documentosRecord.ONE_CheckAutoriza__c,
                documentosRecord.ONE_En_Lugar__r?.Name, documentosRecord.ONE_Fecha_Now__c, signatureUrl, documentosRecord.ONE_Municipio__c,
                documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name, 
                documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
                '', '', '', '', '', '',''
            );
        }
        
        	
        //else if (documentosRecord?.ONE_Funeraria__c!= null &&  documentosRecord?.ONE_Pagador__c != null){ 
        else if (documentosRecord?.ONE_Funeraria__c!= null &&  documentosRecord?.ONE_auxPagador__c!= null && documentosRecord?.ONE_Sala_N__c != null){
            
            data = new ONE_ProtteccionDatosData(
                '', language,
                getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PROTECCION_DATOS), documentosRecord.El_que_subscribe_Tratamiento__c,
                documentosRecord.Documento_de_Identidad_Tratamiento__c, documentosRecord.ONE_Domicialiado_en_Poblacion__c,
                documentosRecord.ONE_Parentesco_Tratamiento__c, documentosRecord.ONE_Provincia2__c, documentosRecord.ONE_Calle__c,
                documentosRecord.ONE_Telefono_de_Contacto__c, documentosRecord.ONE_Email__c, documentosRecord.ONE_CheckAutoriza__c,
                documentosRecord.ONE_En_Lugar__r?.Name, documentosRecord.ONE_Fecha_Now__c, signatureUrl, documentosRecord.ONE_Municipio__c,
                documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name, 
                documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
                '', '', '', '', '', '',''
            );
        }
        
        else{
            string logo =  documentosRecord?.ONE_Oportunidad__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
                data = new ONE_ProtteccionDatosData(
                logo, language,
                getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PROTECCION_DATOS), documentosRecord.El_que_subscribe_Tratamiento__c,
                documentosRecord.Documento_de_Identidad_Tratamiento__c, documentosRecord.ONE_Domicialiado_en_Poblacion__c,
                documentosRecord.ONE_Parentesco_Tratamiento__c, documentosRecord.ONE_Provincia2__c, documentosRecord.ONE_Calle__c,
                documentosRecord.ONE_Telefono_de_Contacto__c, documentosRecord.ONE_Email__c, documentosRecord.ONE_CheckAutoriza__c,
                documentosRecord.ONE_En_Lugar__r?.Name, documentosRecord.ONE_Fecha_Now__c, signatureUrl, documentosRecord.ONE_Municipio__c,
                documentosRecord.ONE_Oportunidad__r.ONE_Sociedad2__r.Name, 
                documentosRecord.ONE_Oportunidad__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
                documentosRecord.ONE_Cliente__c, documentosRecord.ONE_NIF_NIE__c, 
                documentosRecord.ONE_Telefono__c,
                documentosRecord.Correo_electronico__c, 
                documentosRecord.Sociedad__c,
                documentosRecord.CIF__c,
                documentosRecord.ONE_Oportunidad__r?.ONE_Sociedad2__r?.ONE_Direccion__c
        );
        }


        System.debug('DATA: ' + data);
        return data;
    }


    public static ONE_Documentos__c selectDocumentosForPdfGeneration(Id documentosId) {
        return [
            SELECT Id, El_que_subscribe_Tratamiento__c, Documento_de_Identidad_Tratamiento__c, ONE_Domicialiado_en_Poblacion__c, ONE_Parentesco_Tratamiento__c,
                toLabel(ONE_Provincia2__c), ONE_Calle__c,  ONE_Telefono_de_Contacto__c, ONE_Email__c, ONE_CheckAutoriza__c, ONE_En_Lugar__r.Name, ONE_Fecha_Now__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,  ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c, ONE_Municipio__c, ONE_Cliente__c, ONE_NIF_NIE__c, ONE_Telefono__c, ONE_Oportunidad__r.ONE_Sociedad2__r.ONE_URL_logo__c, ONE_Oportunidad__r.ONE_Sociedad2__r.Name,ONE_Oportunidad__r.ONE_Sociedad2__r.ONE_Direccion__c,  ONE_Oportunidad__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c, Correo_electronico__c, Sociedad__c, CIF__c,  ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c, ONE_Funeraria__c, ONE_auxPagador__c, ONE_Sala_N__c
            FROM ONE_Documentos__c
            WHERE Id = :documentosId
        ];
    }

    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }

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
            String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
            fileURL = fileURL.replace('visualforce.com','documentforce.com');
            fileURL += '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;
            System.debug('Signature url: ' + fileURL);
            return fileURL;
        }
    }

}
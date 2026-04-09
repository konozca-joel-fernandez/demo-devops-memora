public class ONE_SolicitudDeExhumacionDataFactory {

    
	//Get all the data and store in the Data object created
    public static ONE_SolicitudDeExhumacionData buildSolicitudDeExhumacionData(String documentosId, String language) {
        ONE_Documentos__c aux = [SELECT Id, Name, Funeraria__c, ONE_auxPagador__c FROM ONE_Documentos__c WHERE Id =: documentosId];
        

        
            ONE_Documentos__c documentosRecord = selectDocumentosForPdfGeneration(documentosId);
            String signatureUrl = getSignatureImgUrl(documentosId);
            
            
            
            System.debug('DOCUMENTO: ' + selectDocumentosForPdfGeneration(documentosId));
            ONE_SolicitudDeExhumacionData data = new ONE_SolicitudDeExhumacionData(
                getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_SOLICITUD_EXHUMACION),
                documentosRecord,
                signatureUrl,
                language
            );
            
            System.debug('DATA: ' + data);
            return data;
    }
    
    
    
    public static ONE_Documentos__c selectDocumentosForPdfGenerationSalaExterna(Id documentosId) {
        return [        
            Select
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            ONE_Documentos__c.ONE_El_que_subscribe__c,
            ONE_Documentos__c.ONE_Domicialiado_en_Poblacion__c,
            ONE_Documentos__c.ONE_Poblacion__c,
            ONE_Documentos__c.ONE_Documento_de_Identidad_Subscriptor__c,
            ONE_Documentos__c.ONE_Email_Texto__c,
            ONE_Documentos__c.ONE_Codigo_Postal__c,
            toLabel(ONE_Documentos__c.ONE_Provincia2__c),
            ONE_Documentos__c.NombreDifunto__c,
            ONE_Documentos__c.ONE_Telefono__c,
            ONE_Documentos__c.ONE_Difunto__c,
            ONE_Documentos__c.ONE_Fallecido_en_fecha__c,
            ONE_Documentos__c.ONE_Cad_ver_exhumado__c,
            ONE_Documentos__c.ONE_Restos_Exhumacion__c,
            ONE_Documentos__c.ONE_Cenizas_Exhumacion__c,
            ONE_Documentos__c.ONE_Cementerio__c,
            ONE_Documentos__c.ONE_Unidad_de_Exhumacion__c,
            ONE_Documentos__c.ONE_Localizaci_n_Unidad_Exhumaci_n__c,
            ONE_Documentos__c.Fecha__c,
            ONE_Documentos__c.Presente_en_Exhumaci_n__c,
            ONE_Documentos__c.ONE_Destrucci_n_de_la_L_pida__c,
            ONE_Documentos__c.ONE_Destino_Ornamentaci_n__c,
            ONE_Documentos__c.ONE_Finalidad_Exhumaci_n__c,
            ONE_Documentos__c.ONE_Datos_de_la_unidad__c,
            ONE_Documentos__c.ONE_Observaciones_Exhumacion__c,
            ONE_Documentos__c.ONE_Fotocopia_DNI_solicitante__c,
            ONE_Documentos__c.ONE_Copia_recibo_tasa_conserva__c,
            ONE_Documentos__c.ONE_T_tulo_original_concesi_n__c,
            ONE_Documentos__c.ONE_Otros_documentos_adjuntos__c,
            ONE_Documentos__c.ONE_Municipio__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio__r.Name,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
    		ONE_Documentos__c.ONE_Municipio_Exhumaci_n__c,
            ONE_Documentos__c.ONE_Fecha_Now__c
            from
            ONE_Documentos__c 
            where
            id =: documentosId
        ];
    }
    
    //Query document data  
    public static ONE_Documentos__c selectDocumentosForPdfGeneration(Id documentosId) {
        return [        
            Select
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            ONE_Documentos__c.ONE_El_que_subscribe__c,
            ONE_Documentos__c.ONE_Domicialiado_en_Poblacion__c,
            ONE_Documentos__c.ONE_Poblacion__c,
            ONE_Documentos__c.ONE_Documento_de_Identidad_Subscriptor__c,
            ONE_Documentos__c.ONE_Email_Texto__c,
            ONE_Documentos__c.ONE_Codigo_Postal__c,
            toLabel(ONE_Documentos__c.ONE_Provincia2__c),
            ONE_Documentos__c.NombreDifunto__c,
            ONE_Documentos__c.ONE_Telefono__c,
            ONE_Documentos__c.ONE_Difunto__c,
            ONE_Documentos__c.ONE_Fallecido_en_fecha__c,
            ONE_Documentos__c.ONE_Cad_ver_exhumado__c,
            ONE_Documentos__c.ONE_Restos_Exhumacion__c,
            ONE_Documentos__c.ONE_Cenizas_Exhumacion__c,
            ONE_Documentos__c.ONE_Cementerio__c,
            ONE_Documentos__c.ONE_Unidad_de_Exhumacion__c,
            ONE_Documentos__c.ONE_Localizaci_n_Unidad_Exhumaci_n__c,
            ONE_Documentos__c.Fecha__c,
            ONE_Documentos__c.Presente_en_Exhumaci_n__c,
            ONE_Documentos__c.ONE_Destrucci_n_de_la_L_pida__c,
            ONE_Documentos__c.ONE_Destino_Ornamentaci_n__c,
            ONE_Documentos__c.ONE_Finalidad_Exhumaci_n__c,
            ONE_Documentos__c.ONE_Datos_de_la_unidad__c,
            ONE_Documentos__c.ONE_Observaciones_Exhumacion__c,
            ONE_Documentos__c.ONE_Fotocopia_DNI_solicitante__c,
            ONE_Documentos__c.ONE_Copia_recibo_tasa_conserva__c,
            ONE_Documentos__c.ONE_T_tulo_original_concesi_n__c,
            ONE_Documentos__c.ONE_Otros_documentos_adjuntos__c,
            ONE_Documentos__c.ONE_Municipio__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio__r.Name,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
    		ONE_Documentos__c.ONE_Municipio_Exhumaci_n__c,
            ONE_Documentos__c.ONE_Fecha_Now__c
            from
            ONE_Documentos__c 
            where
            id =: documentosId
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
            
            String fileURL = '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;
            System.debug('Signature url: ' + fileURL);
            return fileURL;
        }
    }

}
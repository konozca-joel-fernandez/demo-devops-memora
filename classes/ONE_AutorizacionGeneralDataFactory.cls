//Class to define all the queries that will get all the apropiate data to generate the PDF
public class ONE_AutorizacionGeneralDataFactory { 

    //Get all the data and store in the Data object created
    public static ONE_AutorizacionGeneralData buildAutorizacionGeneralData(String documentosId, String language) {
        ONE_Documentos__c documentosRecord = selectDocumentosForPdfGeneration(documentosId);
        String signatureUrl = getSignatureImgUrl(documentosId);
        System.debug('Signature: '+signatureUrl);
        System.debug('Document query: ' + documentosRecord);
        
        string logo = documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? documentosRecord?.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : documentosRecord?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        
        ONE_AutorizacionGeneralData data = new ONE_AutorizacionGeneralData(
            logo,
            getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_AUTORIZACION_GENERAL),
            documentosRecord.ONE_El_que_subscribe__c,
            documentosRecord.ONE_Documento_de_Identidad_Subscriptor__c,
            documentosRecord.ONE_Parentesco__c,
            documentosRecord.ONE_Difunto__c,
            documentosRecord.ONE_Documento_de_Identidad_Difunto__c,
            documentosRecord.ONE_Fallecido_en_fecha__c,
            documentosRecord.ONE_Lugar_de_Fallecimiento__c,
            documentosRecord.ONE_La_retirada_del_cuerpo_de__c,
            documentosRecord.ONE_Tanatorio_dom_mortuorio__c,
            documentosRecord.ONE_El_traslado_a__c,
            documentosRecord.Inhumaci_n_en__c,
            documentosRecord.Incineraci_n_en__c,
            documentosRecord.ONE_Si_1__c,
            documentosRecord.ONE_Si_2__c,
            documentosRecord.ONE_Si_3__c,
            documentosRecord.ONE_Si_4__c,
            documentosRecord.ONE_No_1__c,
            documentosRecord.ONE_No_2__c,
            documentosRecord.ONE_No_3__c,
            documentosRecord.ONE_No_4__c,
            documentosRecord.ONE_Fecha_Now__c,
            signatureUrl,
            documentosRecord.ONE_En_Lugar__r.Name,
            language,
            documentosRecord.ONE_Municipio__c,
            documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
			documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
            buildLabelSociedad(documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_External_ID_Sociedad__c, language),
            buildLabelConfidencialidad(documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_External_ID_Sociedad__c, language),
            buildConsentimientoData(
                buildLabelRealizacionFuneral(documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_External_ID_Sociedad__c, language),
                documentosRecord.ONE_InArboriam__c,
                documentosRecord.ONE_Si_5__c,
                documentosRecord.ONE_No_5__c,
                documentosRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                language
            )
        );
        
        System.debug('DATA: ' + data);
        return data;
    }
    
    public static ONE_AutorizacionGeneralData.ConsentimientoData buildConsentimientoData(String labelRealizacionFuneral,String InArboriam,Boolean Si_5,Boolean No_5,String sociedad, String language){
        return new ONE_AutorizacionGeneralData.ConsentimientoData(labelRealizacionFuneral,
                                                                  Label.get('', 'ONE_AltaUnaVidaParaRecordar', language)+ ' '+sociedad+' '+Label.get('', 'ONE_ColaboracionNextlive', language),
                                                                  Label.get('', 'ONE_Participar_In_Arborian', language)+ ' '+sociedad+' '+Label.get('', 'ONE_TreeForMemory', language),
                                                                  Si_5,
                                                                  No_5);
    }
     
    public static string buildLabelRealizacionFuneral(String sociedad, String language){
        String labelName;
        System.debug('sociedad: '+sociedad);
        switch on sociedad {
            when '0500' {labelName = 'ONE_Doc_Realizacion_Funeral'; }
            when '2000' {labelName = 'ONE_Doc_Realizacion_Funeral_Asistea'; }
            when '2030' {labelName = 'ONE_Doc_Realizacion_Funeral_Remedios'; }
            when '2010' {labelName = 'ONE_Doc_Realizacion_Funeral_Funeuskadi'; }
            when '1540' {labelName = 'ONE_Doc_Realizacion_Funeral_FdelCamp'; }
            when '1704' {labelName = 'ONE_Doc_Realizacion_Funeral_Baztan'; }
            when '1160' {labelName = 'ONE_Doc_Realizacion_Funeral_Serfunle'; }
            when '1131' {labelName = 'ONE_Doc_Realizacion_Funeral_LasPalmas'; }
            when '1702' {labelName = 'ONE_Doc_Realizacion_Funeral_Tabisa'; }
            when '1703' {labelName = 'ONE_Doc_Realizacion_Funeral_Zarautz'; }
            when '1150' {labelName = 'ONE_Doc_Realizacion_Funeral_SE30'; }
            when '1310' {labelName = 'ONE_Doc_Realizacion_Funeral_SFB'; }
            when '1620' {labelName = 'ONE_Doc_Realizacion_Funeral_Montero'; }
            when '1111' {labelName = 'ONE_Doc_Realizacion_Funeral_SLaAntigua'; }
            when '1701' {labelName = 'ONE_Doc_Realizacion_Funeral_Donostialdea'; }
            when '1121' {labelName = 'ONE_Doc_Realizacion_Funeral_Torrero'; }
            when '1200' {labelName = 'ONE_Doc_Realizacion_Funeral_FGaditanas'; }
            when '2050' {labelName = 'ONE_Doc_Realizacion_Funeral_Funcantabria'; }
            when '2040' {labelName = 'ONE_Doc_Realizacion_Funeral_Merino'; }
            when '1600' {labelName = 'ONE_Doc_Realizacion_Funeral_Soria'; }
            when else {labelName = 'ONE_Doc_Realizacion_Funeral'; } 
        }
        return Label.get('', labelName, language);
         
     }
    public static string buildLabelConfidencialidad(String sociedad, String language){
        String labelName;
        switch on sociedad {
            when '1160' {labelName = 'ONE_Doc_Datos_Confidencialidad_Serfunle'; }
            when '1600' {labelName = 'ONE_Doc_Datos_Confidencialidad_Soria'; }
            when '1121' {labelName = 'ONE_Doc_Datos_Confidencialidad_Torrero'; }
            when else {labelName = 'ONE_Doc_Datos_Confidencialidad'; }
        }
        return Label.get('', labelName, language);
    }
    
    public static string buildLabelSociedad(String sociedad, String language) {
        String labelName;
        switch on sociedad {
            when '0500' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '2000' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Asistea'; }
            when '2030' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Remedios'; }
            when '2010' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Funeuskadi'; }
            when '1540' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '1704' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Baztan'; }
            when '1160' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Serfunle'; }
            when '1131' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '1702' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Tabisa'; }
            when '1703' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '1150' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '1310' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '1620' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Montero'; }
            when '1111' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '1701' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Vascongada'; }
            when '1121' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Torrero'; }
            when '1200' {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
            when '2050' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Funcantabria'; }
            when '2040' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Merino'; }
            when '1600' {labelName = 'ONE_Doc_Publicacion_Datos_Web_Soria'; }
            when else {labelName = 'ONE_Doc_Publicacion_Datos_Web'; }
        }
        return Label.get('', labelName, language);
    }

    //Query document data    
    public static ONE_Documentos__c selectDocumentosForPdfGeneration(Id documentosId) {
        return [            
            Select
               ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
               ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
               ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
               ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
               ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_External_ID_Sociedad__c,
               ONE_Documentos__c.ONE_El_que_subscribe__c,
               ONE_Documentos__c.ONE_Documento_de_Identidad_Subscriptor__c,
               ONE_Documentos__c.ONE_Parentesco__c,
               ONE_Documentos__c.ONE_Difunto__c,
               ONE_Documentos__c.ONE_Documento_de_Identidad_Difunto__c,
               ONE_Documentos__c.ONE_Fallecido_en_fecha__c,
               ONE_Documentos__c.ONE_Lugar_de_Fallecimiento__c,
               ONE_Documentos__c.ONE_La_retirada_del_cuerpo_de__c,
               ONE_Documentos__c.ONE_Tanatorio_dom_mortuorio__c,
               ONE_Documentos__c.ONE_El_traslado_a__c,
               ONE_Documentos__c.Inhumaci_n_en__c,
               ONE_Documentos__c.Incineraci_n_en__c,
               ONE_Documentos__c.ONE_Si_1__c,
               ONE_Documentos__c.ONE_Si_2__c,
               ONE_Documentos__c.ONE_Si_3__c,
               ONE_Documentos__c.ONE_Si_4__c,
               ONE_Documentos__c.ONE_Si_5__c,
               ONE_Documentos__c.ONE_No_1__c,
               ONE_Documentos__c.ONE_No_2__c,
               ONE_Documentos__c.ONE_No_3__c,
               ONE_Documentos__c.ONE_No_4__c,
               ONE_Documentos__c.ONE_No_5__c,
               ONE_Documentos__c.ONE_En_Lugar__r.Name,
               ONE_Documentos__c.ONE_Fecha_Now__c,
               ONE_Documentos__c.ONE_Municipio__c,
               ONE_Documentos__c.ONE_InArboriam__c
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
           /* String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
            fileURL = fileURL.replace('visualforce.com','documentforce.com');
            fileURL += '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;*/
            String fileURL = '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;
            System.debug('Signature url: ' + fileURL);
            return fileURL;
        }
    }
}
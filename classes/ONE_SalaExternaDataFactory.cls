public class ONE_SalaExternaDataFactory {

    
    	//Get all the data and store in the Data object created
    public static ONE_SalaExternaData buildSalaExternaData(String documentosId, String language) {
        ONE_Documentos__c aux = [SELECT Id, Name, Funeraria__c, ONE_auxPagador__c FROM ONE_Documentos__c WHERE Id =: documentosId];
        //if (aux?.Funeraria__c!= null &&  aux?.ONE_Pagador__c != null)
        //{
            ONE_Documentos__c documentosRecord = selectDocumentosForPdfGenerationSalaExterna(documentosId);
            String signatureUrl = getSignatureImgUrl(documentosId);
            
            
            
            //System.debug('DOCUMENTO: ' + selectDocumentosForPdfGeneration(documentosId));
            ONE_SalaExternaData data = new ONE_SalaExternaData(
                getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_SOLICITUD_INHUMACION),
                documentosRecord,
                signatureUrl,
                language
            );
            
            System.debug('DATA: ' + data);
            return data;

            

        //}
        
        
        
        /*
        
        else{
            ONE_Documentos__c documentosRecord = selectDocumentosForPdfGeneration(documentosId);
            String signatureUrl = getSignatureImgUrl(documentosId);
            
            
            
            System.debug('DOCUMENTO: ' + selectDocumentosForPdfGeneration(documentosId));
            ONE_SalaExternaData data = new ONE_SalaExternaData(
                getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_SOLICITUD_INHUMACION),
                documentosRecord,
                signatureUrl,
                language
            );
            
            System.debug('DATA: ' + data);
            return data;
        }

*/
    }
    
    
    
    public static ONE_Documentos__c selectDocumentosForPdfGenerationSalaExterna(Id documentosId) {
        return [        
            Select
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            ONE_Documentos__c.Lugar_de_velacion__c,
            ONE_Documentos__c.N_Servicio__c,
            ONE_Documentos__c.ONE_Sala_N__c,
            ONE_Documentos__c.ONE_Fecha_Reserva__c,
            ONE_Documentos__c.ONE_Atendido_por__c,
            ONE_Documentos__c.NombreDifunto__c,
            ONE_Documentos__c.DNI__c,
            ONE_Documentos__c.ONE_Judicial__c,
            ONE_Documentos__c.ONE_N_Juzgado__c,
            ONE_Documentos__c.ONE_Ultimo_Domicilio__c,
            ONE_Documentos__c.ONE_LugarDefuncion__c,
            ONE_Documentos__c.Nombre__c,
            ONE_Documentos__c.ONE_Direccion__c,
            ONE_Documentos__c.DNI_Tanatopractor__c,
            ONE_Documentos__c.Correo_electronico__c,
            ONE_Documentos__c.ONE_Autoriza_Pantallas__c,
            ONE_Documentos__c.ONE_Autoriza_Pantallas_Checkbox__c,
            ONE_Documentos__c.ONE_Autoriza_Web__c,
            ONE_Documentos__c.ONE_Autoriza_Web_Checkbox__c,
            ONE_Documentos__c.ONE_Servicio_Sala__c,
            ONE_Documentos__c.ONE_Exposici_n_F_retro__c,
            ONE_Documentos__c.ONE_Fecha_Hora_Entrada_Sala__c,
            ONE_Documentos__c.ONE_Fecha_Hora_Salida_Sala__c,
            ONE_Documentos__c.ONE_Despedida_Familiar__c,
            ONE_Documentos__c.ONE_Estancia_en_c_maras__c,
            ONE_Documentos__c.Libro_de_firmas__c,
            ONE_Documentos__c.ONE_Sala_preparaci_n__c,
            ONE_Documentos__c.ONE_Ceremonia_religiosa__c,
            ONE_Documentos__c.ONE_Preparaci_n_fallecido_a__c,
            ONE_Documentos__c.ONE_Ceremonia_laica__c,
            ONE_Documentos__c.ONE_Catering_n_mero__c,
            ONE_Documentos__c.ONE_M_sica_interpretes_n_mero__c,
            ONE_Documentos__c.ONE_Hora__c,
            ONE_Documentos__c.ONE_Custodia_Manipulaci_n_flores__c,
            ONE_Documentos__c.Lugar_ceremonia__r.Name,
            ONE_Documentos__c.Fecha_hora_ceremonia_2__c,
            ONE_Documentos__c.Destino__c,
            ONE_Documentos__c.Fecha_hora_destino_final__c,
            ONE_Documentos__c.Observaciones2__c,
            ONE_Documentos__c.NIF__c,
            ONE_Documentos__c.ONE_auxPagador__c,
            ONE_Documentos__c.ONE_Tratamiento_Datos_Personales_Reserva__c,
            ONE_Documentos__c.ONE_Fdo__c,
            ONE_Documentos__c.ONE_Empresa__c,            
            ONE_Documentos__c.ONE_El_que_subscribe__c,
            ONE_Documentos__c.ONE_Domicialiado_en_Poblacion__c,
            ONE_Documentos__c.ONE_Poblacion__c,
            ONE_Documentos__c.ONE_Documento_de_Identidad_Subscriptor__c,
            ONE_Documentos__c.ONE_Email_Texto__c,
            ONE_Documentos__c.ONE_Codigo_Postal__c,
            toLabel(ONE_Documentos__c.ONE_Provincia2__c),
            ONE_Documentos__c.ONE_Parentesco__c,
            ONE_Documentos__c.ONE_Telefono__c,
            ONE_Documentos__c.ONE_Tipo_de_Difunto__c,
            ONE_Documentos__c.ONE_Difunto__c,
            ONE_Documentos__c.ONE_Documento_de_Identidad_Difunto__c,
            ONE_Documentos__c.ONE_Lugar_de_Fallecimiento__c,
            ONE_Documentos__c.ONE_Fallecido_en_fecha__c,
            ONE_Documentos__c.ONE_Estado_del_difunto__c,
            ONE_Documentos__c.ONE_Edad_Difunto__c,
            ONE_Documentos__c.ONE_Domicilio_Mortuorio__c,
            ONE_Documentos__c.ONE_Funeraria__c,
            ONE_Documentos__c.ONE_Feretro_Caracteristicas__c,
            ONE_Documentos__c.ONE_Largo_ext__c,
            ONE_Documentos__c.ONE_Ancho_ext__c,
            ONE_Documentos__c.ONE_Alto_ext__c,
            ONE_Documentos__c.ONE_SOLICITA_la_incineracion_de__c,
            ONE_Documentos__c.ONE_Causas_de_Defuncion__c,
            ONE_Documentos__c.ONE_Fecha_Now__c,
            ONE_Documentos__c.Responso_en_el_cementerio__c,
            ONE_Documentos__c.ONE_Concesion__c,
            ONE_Documentos__c.ONE_Tipo_de_enterramiento__c,
            ONE_Documentos__c.ONE_Temporalidad__c,
            ONE_Documentos__c.ONE_Datos_de_la_unidad__c,
            ONE_Documentos__c.ONE_Donde_se_encuentra__c,
            ONE_Documentos__c.ONE_Observaciones__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_1__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_1__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_2__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_2__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_3__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_3__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_4__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_4__c,
            ONE_Documentos__c.ONE_Se_dispone_de_t_tulo_funerario__c,
            ONE_Documentos__c.ONE_Se_conocen_las_tasas_de_conservacion__c,
            ONE_Documentos__c.ONE_Vinculadacion_al_difunto_por_razon__c,
            ONE_Documentos__c.ONE_Grado_de_consanguinidad__c,
            ONE_Documentos__c.ONE_Grado_de_afinidad__c,
            ONE_Documentos__c.ONE_En_Lugar__c,
            ONE_Documentos__c.ONE_En_Lugar__r.Name,
            ONE_Documentos__c.ONE_La_familia_solicita__c,
            ONE_Documentos__c.ONE_Se_encuentra_inhumado__c,
            ONE_Documentos__c.ONE_Municipio__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_de_solicitud__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Observaciones_Destino_Final__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Difunto__r.ONE_Municipio__pc,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio__r.Name,
            ONE_Documentos__c.ONE_Heredero__c,
            ONE_Documentos__c.ONE_Titular__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Velacion__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Lugar_De_Velacion__r.Name,
            ONE_Documentos__c.Fecha_inhumacion_Unidad_Enterramiento__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
            ONE_Documentos__c.ONE_Lugar_Exhumacion__c,
			ONE_Documentos__c.ONE_Inicio_Exhumaci_n__c,
    		ONE_Documentos__c.ONE_Municipio_Exhumaci_n__c,
			ONE_Documentos__c.ONE_Fin_Exhumaci_n__c,
         	ONE_Documentos__c.ONE_Restos_de__c,
			ONE_Documentos__c.ONE_C_digo_postal_Exhumaci_n__c,
   			ONE_Documentos__c.ONE_Localizaci_n_Unidad_Exhumaci_n__c,
    		ONE_Documentos__c.Presente_en_Exhumaci_n__c ,
   			ONE_Documentos__c.ONE_Unidad_de_Exhumacion__c,
			ONE_Documentos__c.ONE_Destrucci_n_de_la_L_pida__c,
    		ONE_Documentos__c.ONE_Observaciones_Exhumacion__c,
    		ONE_Documentos__c.ONE_Destino_Ornamentaci_n__c,
    		ONE_Documentos__c.ONE_Finalidad_Exhumaci_n__c
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
            ONE_Documentos__c.Lugar_de_velacion__c,
            ONE_Documentos__c.N_Servicio__c,
            ONE_Documentos__c.ONE_Sala_N__c,
            ONE_Documentos__c.ONE_Fecha_Reserva__c,
            ONE_Documentos__c.ONE_Atendido_por__c,
            ONE_Documentos__c.ONE_El_que_subscribe__c,
            ONE_Documentos__c.ONE_Domicialiado_en_Poblacion__c,
            ONE_Documentos__c.ONE_Poblacion__c,
            ONE_Documentos__c.ONE_Documento_de_Identidad_Subscriptor__c,
            ONE_Documentos__c.ONE_Email_Texto__c,
            ONE_Documentos__c.ONE_Codigo_Postal__c,
            toLabel(ONE_Documentos__c.ONE_Provincia2__c),
            ONE_Documentos__c.ONE_Parentesco__c,
            ONE_Documentos__c.ONE_Telefono__c,
            ONE_Documentos__c.ONE_Tipo_de_Difunto__c,
            ONE_Documentos__c.ONE_Difunto__c,
            ONE_Documentos__c.ONE_Documento_de_Identidad_Difunto__c,
            ONE_Documentos__c.ONE_Lugar_de_Fallecimiento__c,
            ONE_Documentos__c.ONE_Fallecido_en_fecha__c,
            ONE_Documentos__c.ONE_Estado_del_difunto__c,
            ONE_Documentos__c.ONE_Edad_Difunto__c,
            ONE_Documentos__c.ONE_Domicilio_Mortuorio__c,
            ONE_Documentos__c.ONE_Funeraria__c,
            ONE_Documentos__c.ONE_Feretro_Caracteristicas__c,
            ONE_Documentos__c.ONE_Largo_ext__c,
            ONE_Documentos__c.ONE_Ancho_ext__c,
            ONE_Documentos__c.ONE_Alto_ext__c,
            ONE_Documentos__c.ONE_SOLICITA_la_incineracion_de__c,
            ONE_Documentos__c.ONE_Causas_de_Defuncion__c,
            ONE_Documentos__c.ONE_Fecha_Now__c,
            ONE_Documentos__c.Responso_en_el_cementerio__c,
            ONE_Documentos__c.ONE_Concesion__c,
            ONE_Documentos__c.ONE_Tipo_de_enterramiento__c,
            ONE_Documentos__c.ONE_Temporalidad__c,
            ONE_Documentos__c.ONE_Datos_de_la_unidad__c,
            ONE_Documentos__c.ONE_Donde_se_encuentra__c,
            ONE_Documentos__c.ONE_Observaciones__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_1__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_1__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_2__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_2__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_3__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_3__c,
            ONE_Documentos__c.ONE_Nombre_y_apellidos_4__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_4__c,
            ONE_Documentos__c.ONE_Se_dispone_de_t_tulo_funerario__c,
            ONE_Documentos__c.ONE_Se_conocen_las_tasas_de_conservacion__c,
            ONE_Documentos__c.ONE_Vinculadacion_al_difunto_por_razon__c,
            ONE_Documentos__c.ONE_Grado_de_consanguinidad__c,
            ONE_Documentos__c.ONE_Grado_de_afinidad__c,
            ONE_Documentos__c.ONE_En_Lugar__c,
            ONE_Documentos__c.ONE_En_Lugar__r.Name,
            ONE_Documentos__c.ONE_La_familia_solicita__c,
            ONE_Documentos__c.ONE_Se_encuentra_inhumado__c,
            ONE_Documentos__c.ONE_Municipio__c,
            ONE_Documentos__c.ONE_Fecha_de_Inhumacion_de_solicitud__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Observaciones_Destino_Final__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Difunto__r.ONE_Municipio__pc,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio__r.Name,
            ONE_Documentos__c.ONE_Heredero__c,
            ONE_Documentos__c.ONE_Titular__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Velacion__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Lugar_De_Velacion__r.Name,
            ONE_Documentos__c.Fecha_inhumacion_Unidad_Enterramiento__c,
            ONE_Documentos__c.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
            ONE_Documentos__c.ONE_Lugar_Exhumacion__c,
			ONE_Documentos__c.ONE_Inicio_Exhumaci_n__c,
    		ONE_Documentos__c.ONE_Municipio_Exhumaci_n__c,
			ONE_Documentos__c.ONE_Fin_Exhumaci_n__c,
         	ONE_Documentos__c.ONE_Restos_de__c,
			ONE_Documentos__c.ONE_C_digo_postal_Exhumaci_n__c,
   			ONE_Documentos__c.ONE_Localizaci_n_Unidad_Exhumaci_n__c,
    		ONE_Documentos__c.Presente_en_Exhumaci_n__c ,
   			ONE_Documentos__c.ONE_Unidad_de_Exhumacion__c,
			ONE_Documentos__c.ONE_Destrucci_n_de_la_L_pida__c,
    		ONE_Documentos__c.ONE_Observaciones_Exhumacion__c,
    		ONE_Documentos__c.ONE_Destino_Ornamentaci_n__c,
    		ONE_Documentos__c.ONE_Finalidad_Exhumaci_n__c
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
            /*String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
            fileURL = fileURL.replace('visualforce.com','documentforce.com');
            fileURL += '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;*/
            String fileURL = '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;
            System.debug('Signature url: ' + fileURL);
            return fileURL;
        }
    }
}
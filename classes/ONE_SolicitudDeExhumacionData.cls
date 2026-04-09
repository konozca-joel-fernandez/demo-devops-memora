public class ONE_SolicitudDeExhumacionData{

    public String logoUrl {public get; private set;}
    public String documentCode {public get; private set;} 
    public String ONE_El_que_subscribe {public get; private set;} 
    public String ONE_Domicialiado_en_Poblacion {public get; private set;} 
    public String ONE_Poblacion {public get; private set;} 
    public String ONE_Documento_de_Identidad_Subscriptor {public get; private set;} 
    public String ONE_Email_Texto {public get; private set;} 
    public String ONE_Codigo_Postal {public get; private set;} 
    public String ONE_Provincia {public get; private set;}
    public String ONE_Nombre_Difunto {public get; private set;}  
    public String ONE_Telefono {public get; private set;}  
    public String ONE_Difunto {public get; private set;}   
    public String ONE_Cadaver_Exhumado {public get; private set;}
    public String ONE_Restos_Exhumados {public get; private set;}
    public String ONE_Cenizas_Exhumadas {public get; private set;}
    public String ONE_Fallecido_en_fecha {public get; private set;}     
    public String ONE_Fecha_Now {public get; private set;}    
    public String Fecha {public get; private set;}
    public String ONE_Cementerio {public get; private set;}
    public String ONE_Datos_de_la_unidad {public get; private set;}
    public String ONE_Copia_DNI_check {public get; private set;}
    public String ONE_Copia_recibo_tasa_conserva_check {public get; private set;}
    public String ONE_Titulo_original_concesion_check {public get; private set;}
    public String ONE_Otros_documentos {public get; private set;}
    public String ONE_Municipio_Exhumacion {public get; private set;}
    public String capturaDeFirmaUrl {public get; private set;}
    public Boolean isSignatureEmpty {public get; private set;}
    public String language {public get; private set;}
    public String ONE_Municipio {public get; private set;}
    public String sociedad {public get; private set;}
    public String footerInformation {public get; private set;}
    public String ONE_Localizacion_Unidad_Exhumacion  {public get; private set;}
    public String ONE_Presente_En_Exhumacion  {public get; private set;}
    public String ONE_Tipo_De_Unidad {public get; private set;}
    public String ONE_Destruccion_De_La_Lapida {public get; private set;}
    public String ONE_Observaciones_Exhumacion {public get; private set;}
    public String ONE_Destino_Ornamentaci_n {public get; private set;}
    public String ONE_Finalidad_Exhumacion {public get; private set;}
    public String ONE_Restos_de {public get; public set;}
        

	//Set all query variable to the corresponding PDF variables	
    public ONE_SolicitudDeExhumacionData(String docCode, ONE_Documentos__c documento, String signatureUrl, String language ) {
			
            logoUrl = documento.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
                ? documento.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
                : documento.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
            documentCode = docCode; 
            ONE_El_que_subscribe = documento.ONE_El_que_subscribe__c;
            ONE_Domicialiado_en_Poblacion = documento.ONE_Domicialiado_en_Poblacion__c;
            ONE_Poblacion = documento.ONE_Poblacion__c;
            ONE_Documento_de_Identidad_Subscriptor = documento.ONE_Documento_de_Identidad_Subscriptor__c;
            ONE_Email_Texto = documento.ONE_Email_Texto__c;
            ONE_Codigo_Postal = documento.ONE_Codigo_Postal__c;
            ONE_Provincia = documento.ONE_Provincia2__c;
            ONE_Nombre_Difunto = documento.NombreDifunto__c;
            ONE_Telefono = documento.ONE_Telefono__c;
            ONE_Difunto = documento.ONE_Difunto__c;
            ONE_Fallecido_en_fecha = documento.ONE_Fallecido_en_fecha__c != null? documento.ONE_Fallecido_en_fecha__c.format() :'';
            ONE_Fecha_Now = documento.ONE_Fecha_Now__c != null? documento.ONE_Fecha_Now__c.format() :'';
            ONE_Cadaver_Exhumado = documento.ONE_Cad_ver_exhumado__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            ONE_Restos_Exhumados = documento.ONE_Restos_Exhumacion__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            ONE_Cenizas_Exhumadas = documento.ONE_Cenizas_Exhumacion__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            Fecha = documento.Fecha__c != null? documento.Fecha__c.format() :'';
            ONE_Cementerio = documento.ONE_Cementerio__c;
            ONE_Datos_de_la_unidad = documento.ONE_Datos_de_la_unidad__c;
        	ONE_Municipio = documento.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Municipio__r?.Name;
            this.capturaDeFirmaUrl = signatureUrl;
            this.isSignatureEmpty = capturaDeFirmaUrl == '' ? true : false;
        	this.language = language;
        	this.sociedad = documento?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name != null 
                ? documento.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name
                : '';
        	this.footerInformation = documento.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Pie_de_pagina__c != null 
                ? documento.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Pie_de_pagina__c
                : '';
    		ONE_Municipio_Exhumacion = documento.ONE_Municipio_Exhumaci_n__c;
   			ONE_Localizacion_Unidad_Exhumacion  = documento.ONE_Localizaci_n_Unidad_Exhumaci_n__c;
    		ONE_Presente_En_Exhumacion  = documento.Presente_en_Exhumaci_n__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
   			ONE_Tipo_De_Unidad = documento.ONE_Unidad_de_Exhumacion__c;
			ONE_Destruccion_De_La_Lapida = documento.ONE_Destrucci_n_de_la_L_pida__c  ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
    		ONE_Observaciones_Exhumacion = documento.ONE_Observaciones_Exhumacion__c;
    		ONE_Destino_Ornamentaci_n = documento.ONE_Destino_Ornamentaci_n__c;
    		ONE_Finalidad_Exhumacion = documento.ONE_Finalidad_Exhumaci_n__c;
            ONE_Copia_DNI_check = documento.ONE_Fotocopia_DNI_solicitante__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            ONE_Copia_recibo_tasa_conserva_check = documento.ONE_Copia_recibo_tasa_conserva__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            ONE_Titulo_original_concesion_check = documento.ONE_T_tulo_original_concesi_n__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            ONE_Otros_documentos = documento.ONE_Otros_documentos_adjuntos__c;
        	
    }

}
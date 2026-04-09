public class ONE_AutorizacionGeneralData { 

    public String logoUrl {public get; private set;}
    public String documentCode {public get; private set;}
    public String El_que_subscribe {public get; private set;}
    public String Documento_de_Identidad_Subscriptor {public get; private set;}
    public String Parentesco {public get; private set;}
    public String Difunto {public get; private set;}
    public String Documento_de_Identidad_Difunto {public get; private set;}
    public String Fallecido_en_fecha {public get; private set;}
    public String Lugar_de_Fallecimiento {public get; private set;}
    public String La_retirada_del_cuerpo_de {public get; private set;}
    public String Tanatorio_dom_mortuorio {public get; private set;}
    public String El_traslado_a {public get; private set;}
    public String Inhumaci_n_en {public get; private set;}
    public String Incineraci_n_en {public get; private set;}
    public String Si_1 {public get; private set;}
    public String Si_2 {public get; private set;}
    public String Si_3 {public get; private set;}
    public String Si_4 {public get; private set;}
    public String No_1 {public get; private set;}
    public String No_2 {public get; private set;}
    public String No_3 {public get; private set;}
    public String No_4 {public get; private set;}
    public String En_Lugar {public get; private set;}
    public String Fecha_Now {public get; private set;}
    public String capturaDeFirmaUrl {public get; private set;}
    public Boolean isSignatureEmpty {public get; private set;}
    public String language {public get; private set;}
    public String municipio {public get; private set;}
	public String sociedad {public get; private set;}
    public String footerInformation {public get; private set;}
    public String labelPublicacionDatosWeb {public get; private set;}
    public String labelConfidencialidad {public get; private set;}
    public ConsentimientoData consentimiento {public get; private set;}
    
	
    public ONE_AutorizacionGeneralData(
        String logoUrl, 
        String documentCode, 
        String El_que_subscribe,
        String Documento_de_Identidad_Subscriptor,
        String Parentesco,
        String Difunto,
        String Documento_de_Identidad_Difunto,
        Datetime Fallecido_en_fecha,
        String Lugar_de_Fallecimiento,
        String La_retirada_del_cuerpo_de,
        String Tanatorio_dom_mortuorio,
        String El_traslado_a,
        String Inhumaci_n_en,
        String Incineraci_n_en,
        Boolean Si_1,
        Boolean Si_2,
        Boolean Si_3,
        Boolean Si_4,
        Boolean No_1,
        Boolean No_2,
        Boolean No_3,
        Boolean No_4,
        Datetime Fecha_Now , 
        String signatureUrl,
    	String Lugar,
    	String language,
    	String municipio,
    	String sociedad, 
        String footerInformation,
        String labelPublicacionDatosWeb,
        String labelConfidencialidad,
        ConsentimientoData consentimiento
		) {
            this.logoUrl = logoUrl;
            this.documentCode = documentCode;
            this.El_que_subscribe = El_que_subscribe;
            this.Documento_de_Identidad_Subscriptor = Documento_de_Identidad_Subscriptor;
            this.Parentesco = Parentesco;
            this.Difunto = Difunto;
            this.Documento_de_Identidad_Difunto = Documento_de_Identidad_Difunto;
            this.Fallecido_en_fecha = Fallecido_en_fecha != null? Fallecido_en_fecha.format() :'';
            this.Lugar_de_Fallecimiento = Lugar_de_Fallecimiento;
            this.La_retirada_del_cuerpo_de = La_retirada_del_cuerpo_de;
            this.Tanatorio_dom_mortuorio = Tanatorio_dom_mortuorio;
            this.El_traslado_a = El_traslado_a;
            this.Inhumaci_n_en = Inhumaci_n_en;
            this.Incineraci_n_en = Incineraci_n_en;
            this.Si_1 = Si_1 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.Si_2 = Si_2 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.Si_3 = Si_3 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.Si_4 = Si_4 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.No_1 = No_1 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.No_2 = No_2 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.No_3 = No_3 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.No_4 = No_4 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.En_Lugar = Lugar;
            this.Fecha_Now = Fecha_Now.format('dd/MM/yyyy HH:mm');
            this.capturaDeFirmaUrl = signatureUrl;
            this.isSignatureEmpty = capturaDeFirmaUrl == '' ? true : false;
            this.language = language;
            this.municipio = municipio;
            this.sociedad = sociedad;
			this.footerInformation = footerInformation;
            this.labelPublicacionDatosWeb=labelPublicacionDatosWeb;
            this.labelConfidencialidad=labelConfidencialidad;
            this.consentimiento=consentimiento;
            
            
            
    }

public class ConsentimientoData {
        public String labelRealizacionFuneral {public get; private set;}
        public String Nextlives {public get; private set;}
        public String InArboriam {public get; private set;}
        public String Si_5 {public get; private set;}
        public String No_5 {public get; private set;}

        public ConsentimientoData(String labelRealizacionFuneral,String Nextlives,String InArboriam,Boolean Si_5,Boolean No_5) {
            this.labelRealizacionFuneral=labelRealizacionFuneral;
            this.Nextlives=Nextlives;
            this.InArboriam=InArboriam;
            this.Si_5 = Si_5 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
            this.No_5 = No_5 ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
         }
}
}
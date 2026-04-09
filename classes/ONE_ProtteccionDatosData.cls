/**
 * Created by msulek003 on 29.03.2021. 
 */

public with sharing class ONE_ProtteccionDatosData {
    public String logoUrl {public get; private set;}
    public Boolean isLogoEmpty {public get; private set;}
    public String documentCode {public get; private set;}
    public String suspcriptor {public get; private set;}
    public String docNif {public get; private set;}
    public String domicilio {public get; private set;}
    public String relacionDifunto {public get; private set;}
    public String provincia {public get; private set;}
    public String calle {public get; private set;}
    public String telefono {public get; private set;}
    public String correoElectionico {public get; private set;}
    public String siAutorizaImgSrc {public get; private set;}
    public String enLugar {public get; private set;}
    public String fetcha {public get; private set;}
    public String capturaDeFirmaUrl {public get; private set;}
    public Boolean isSignatureEmpty {public get; private set;}
    public String language {public get; private set;}
    public String municipio {public get; private set;}
    public String sociedad {public get; private set;}
    public String footerInformation {public get; private set;}
    public String cliente {public get; private set;}
    public String NIFNIE {public get; private set;}
    public String telf {public get; private set;}
    public String mail {public get; private set;}
    public String tanatorio {public get; private set;}
    public String cif {public get; private set;}
    public String direccion {public get; private set;}


    public ONE_ProtteccionDatosData(String logoUrl, String language, String documentCode, String suspcriptor, String docNif, String domicilio, String relacionDifunto,
        String provincia, String calle, String telefono, String correoElectionico, Boolean siAutoriza, String enLugar, Datetime fetcha, String signatureUrl, String municipio, String sociedad, String footerInformation, String cliente, String NIFNIE, String telf, String mail, String tanatorio, String cif, String direccion) {
        this.logoUrl = logoUrl == null ? '' : logoUrl;
        this.isLogoEmpty = logoUrl == null ? true : false;
        this.language = language;
        this.documentCode = documentCode;
        this.docNif = docNif;
        this.domicilio = domicilio;
        this.relacionDifunto = relacionDifunto;
        this.provincia = provincia;
        this.calle = calle;
        this.telefono = telefono;
        this.correoElectionico = correoElectionico;
        this.siAutorizaImgSrc = siAutoriza ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
        this.enLugar = enLugar;
        this.fetcha = fetcha.format('dd/MM/yyyy HH:mm');
        this.suspcriptor = suspcriptor;
        this.capturaDeFirmaUrl = signatureUrl;
        this.isSignatureEmpty = capturaDeFirmaUrl == '' ? true : false;
        this.municipio = municipio;
		this.sociedad = sociedad;
		this.footerInformation = footerInformation;
        this.cliente = cliente;
        this.NIFNIE = NIFNIE;
        this.telf = telf;
        this.mail = mail;
        this.tanatorio = tanatorio;
        this.cif = cif;
        this.direccion = direccion;
    }
}
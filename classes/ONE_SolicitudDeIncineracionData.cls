/**
 * Created by msulek003 on 06.04.2021. 
 */

public with sharing class ONE_SolicitudDeIncineracionData {

	//Variables needed to store the data that will be show in the PDF    
	public String logoUrl { public get; private set; }
	public String documentCode { public get; private set; }
	public String servico { public get; private set; }
	public String crematorio { public get; private set; }
	public String subscribe { public get; private set; }
	public String poblacion { public get; private set; }
	public String direccion { public get; private set; }
	public String telefono { public get; private set; }
	public String solicitaIncineracion { public get; private set; }
	public String lugarDeFallecimiento { public get; private set; }
	public String fallecidoEnFecha { public get; private set; }
	public String funeraria { public get; private set; }
	public String documentoIdentidadSubscriptor { public get; private set; } 
	public String documentoIdentidadIncinerado { public get; private set; }
	public String codigoPostal { public get; private set; }
	public String provincia { public get; private set; }
	public String parentesco { public get; private set; }
	public String marcapasos { public get; private set; }
	public String inhumacionCementerio { public get; private set; }
	public String esparcimientoCenizas { public get; private set; }
	public Boolean custodiaFamiliar { public get; private set; }
	public Boolean renunciaCenizas { public get; private set; }
	public Boolean autorizoContacto { public get; private set; }
	public String autorizoContactoText { public get; private set; }
	public String custodiaInstalaciones { public get; private set; }
	public String destinoDeFlores { public get; private set; } 
	public String asistenciaIncineracion { public get; private set; }
	public String observaciones { public get; private set; }
	public String lugar { public get; private set; }
	public String fetchaNow { public get; private set; }
	public String capturaDeFirmaUrl { public get; private set; }
	public Boolean isSignatureEmpty { public get; private set; }
	public String language { public get; private set; }
	public String ONE_Municipio { public get; private set; }
	public String dataCremacion { public get; private set; }
    public String sociedad { public get; private set; }
    public String footerInformation { public get; private set; }

  //Set all query variable to the corresponding PDF variables
	public ONE_SolicitudDeIncineracionData(String language, DocumentData docData, CheckboxFields checkboxFields, FooterData footerData) {
		this.dataCremacion = docData.dataCremacion;
		this.logoUrl = docData.logoUrl == null 
            ? '' 
            : docData.logoUrl;
		this.language = language;
		this.documentCode = docData.documentCode;
		this.servico = docData.servico;
		this.crematorio = docData.crematorio;
		this.subscribe = docData.subscribe?.length() < 55 
            ? docData.subscribe 
            : docData.subscribe?.substring(0, 55);
		this.poblacion = docData.poblacion;
		this.direccion = docData.direccion?.length() < 70 
            ? docData.direccion 
            : docData.direccion?.substring(0, 70);
		this.telefono = docData.telefono;
		this.solicitaIncineracion = docData.solicitaIncineracion?.length() < 55 
            ? docData.solicitaIncineracion 
            : docData.solicitaIncineracion?.substring(0, 55);
		this.lugarDeFallecimiento = docData.lugarDeFallecimiento?.length() < 160 
            ? docData.lugarDeFallecimiento 
            : docData.lugarDeFallecimiento?.substring(0, 160);
		this.fallecidoEnFecha = docData.fallecidoEnFecha != null 
            ? docData.fallecidoEnFecha.format('dd/MM/yyyy HH:mm') 
            : '';
		this.funeraria = docData.funeraria;
		this.documentoIdentidadSubscriptor = docData.documentoIdentidadSubscriptor;
		this.codigoPostal = docData.codigoPostal;
		this.provincia = docData.provincia;
		this.parentesco = docData.parentesco;
		this.marcapasos = docData.marcapasos;
        this.inhumacionCementerio = docData.inhumacionCementerio;
		this.esparcimientoCenizas = docData.esparcimientoCenizas?.length() < 45 
            ? docData.esparcimientoCenizas 
            : docData.esparcimientoCenizas?.substring(0, 45);
		this.custodiaFamiliar = checkboxFields.custodiaFamiliar;
		this.renunciaCenizas = checkboxFields.renunciaCenizas;
		this.autorizoContacto = checkboxFields.autorizoContacto;
		this.autorizoContactoText = docData.autorizoContactoText;
		this.custodiaInstalaciones = docData.custodiaInstalaciones?.length() < 45 
            ? docData.custodiaInstalaciones 
            : docData.custodiaInstalaciones?.substring(0, 45);
		this.destinoDeFlores = docData.destinoDeFlores;
		this.asistenciaIncineracion = docData.asistenciaIncineracion;
		this.observaciones = docData.observaciones?.length() < 300 
            ? docData.observaciones 
            : docData.observaciones?.substring(0, 300);
		this.lugar = docData.lugar;
		this.fetchaNow = docData.fetchaNow.format('dd/MM/yyyy HH:mm');
		this.capturaDeFirmaUrl = docData.signatureUrl;
		this.isSignatureEmpty = capturaDeFirmaUrl == '' 
            ? true 
            : false;
		this.ONE_Municipio = docData.municipio;
		this.documentoIdentidadIncinerado = docData.documentoIdentidadIncinerado;
        this.sociedad = footerData.sociedad;
        this.footerInformation = footerData.footerInformation;
	}

	public class CheckboxFields {
		//public Boolean marcapasos {public get; private set;}
		public Boolean custodiaFamiliar {public get; private set; }
		public Boolean renunciaCenizas {public get; private set; }
		public Boolean autorizoContacto {public get; private set; }

		//public CheckboxFields(Boolean marcapasos, Boolean custodiaFamiliar, Boolean renunciaCenizas, Boolean autorizoContacto) {
		public CheckboxFields(Boolean custodiaFamiliar, Boolean renunciaCenizas, Boolean autorizoContacto) {
			//this.marcapasos = marcapasos;
			this.custodiaFamiliar = custodiaFamiliar;
			this.renunciaCenizas = renunciaCenizas;
			this.autorizoContacto = autorizoContacto;
		}
	}
    
	public class DocumentData {
		public String logoUrl { public get; private set; }
		public String documentCode { public get; private set; }
		public String servico { public get; private set; }
		public String crematorio { public get; private set; }
		public String subscribe { public get; private set; }
		public String poblacion { public get; private set; }
		public String direccion { public get; private set; }
		public String telefono { public get; private set; }
		public String solicitaIncineracion { public get; private set; }
		public String lugarDeFallecimiento { public get; private set; }
		public Datetime fallecidoEnFecha { public get; private set; }
		public String funeraria { public get; private set; }
		public String documentoIdentidadSubscriptor { public get; private set; }
		public String documentoIdentidadIncinerado { public get; private set; }
		public String codigoPostal { public get; private set; }
		public String provincia { public get; private set; }
		public String parentesco { public get; private set; }
		public String marcapasos { public get; private set; }
		public String inhumacionCementerio { public get; private set; }
		public String esparcimientoCenizas { public get; private set; }
		public String autorizoContactoText { public get; private set; }
		public String custodiaInstalaciones { public get; private set; }
		public String destinoDeFlores { public get; private set; }
		public String asistenciaIncineracion { public get; private set; }
		public String observaciones { public get; private set; }
		public String lugar { public get; private set; }
		public Datetime fetchaNow { public get; private set; }
		public String signatureUrl { public get; private set; }
		public String isSignatureEmpty { public get; private set; }
		public String municipio { public get; private set; }
		public String dataCremacion { public get; private set; }

		public DocumentData(
			String logoUrl, String documentCode, String servico, String crematorio, 
			String subscribe, String poblacion, String direccion, String telefono, 
			String solicitaIncineracion, String lugarDeFallecimiento, Datetime fallecidoEnFecha, 
			String funeraria, String documentoIdentidadSubscriptor, 
			String documentoIdentidadIncinerado, String codigoPostal, String provincia, 
			String parentesco, String marcapasos, String inhumacionCementerio, 
			String esparcimientoCenizas, String autorizoContactoText, 
			String custodiaInstalaciones, String destinoDeFlores, 
			String asistenciaIncineracion, String observaciones, String lugar, 
			Datetime fetchaNow, String signatureUrl, String municipio, String dataCremacion) {
			this.logoUrl = logoUrl;
			this.documentCode = documentCode;
			this.servico = servico;
			this.crematorio = crematorio;
			this.subscribe = subscribe;
			this.poblacion = poblacion;
			this.direccion = direccion;
			this.telefono = telefono;
			this.solicitaIncineracion = solicitaIncineracion;
			this.lugarDeFallecimiento = lugarDeFallecimiento;
			this.fallecidoEnFecha = fallecidoEnFecha;
			this.funeraria = funeraria;
			this.documentoIdentidadSubscriptor = documentoIdentidadSubscriptor;
			this.documentoIdentidadIncinerado = documentoIdentidadIncinerado;
			this.codigoPostal = codigoPostal;
			this.provincia = provincia;
			this.provincia = provincia;
			this.provincia = provincia;
			this.parentesco = parentesco;
			this.marcapasos = marcapasos;
			this.inhumacionCementerio = inhumacionCementerio;
			this.esparcimientoCenizas = esparcimientoCenizas;
			this.autorizoContactoText = autorizoContactoText;
			this.custodiaInstalaciones = custodiaInstalaciones;
			this.destinoDeFlores = destinoDeFlores;
			this.asistenciaIncineracion = asistenciaIncineracion;
			this.observaciones = observaciones;
			this.lugar = lugar;
			this.fetchaNow = fetchaNow;
			this.signatureUrl = signatureUrl;
			this.municipio = municipio;
			this.dataCremacion = dataCremacion;
		}
	}
    
    public class FooterData {
		public String sociedad {public get; private set; }
		public String footerInformation {public get; private set; }
        
		public FooterData(String sociedad, String footerInformation) {
			this.sociedad = sociedad;
			this.footerInformation = footerInformation;
		}
	}
}
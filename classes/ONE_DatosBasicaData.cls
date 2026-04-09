public with sharing class ONE_DatosBasicaData { 
    //Variables needed to store the data that will be show in the PDF    
    public String logoUrl {public get; private set;}
    public Boolean isLogoEmpty {public get; private set;}
    public String documentCode {public get; private set;}
    public String sociedad2Name {public get; private set;}
    public String compania {public get; private set;}
    public String nPoliza {public get; private set;}
    public String centro {public get; private set;}
    public String nServicio {public get; private set;}
    public String asesor {public get; private set;}
    public String difunto {public get; private set;}
    public String pedidoName {public get; private set;}
    public String fetchaPedido {public get; private set;}
    public String proveedor {public get; private set;}
    public DatosDelDifunto datosDelDifunto {public get; private set;}
    public DatosDelContacto datosDelContacto {public get; private set;}
    public DatosDeDfuncion datosDeDfuncion {public get; private set;}
    public Velatorio velatorio {public get; private set;}
    public Despedida despedida {public get; private set;}
    public Ceremonia ceremonia {public get; private set;}
    public Finilizacion finilizacion {public get; private set;}
    public String language {public get; private set;}
    //Added for ORI-6053
    public String footerInformation {public get; private set;}

    //Set all query variable to the corresponding PDF variables	
	public ONE_DatosBasicaData(String logoUrl, String language, String documentCode, String sociedad2Name,String compania,String nPoliza, String centro, String nServicio,
        String asesor, String difunto, String pedidoName, Date fetchaPedido, String proveedor, DatosDeDfuncion datosDeDfuncion, DatosDelDifunto datosDelDifunto,
        DatosDelContacto datosDelContacto, Velatorio velatorio, Despedida despedida, Ceremonia ceremonia, Finilizacion finilizacion, String footerInformation) {
        this.logoUrl = logoUrl == null ? '' : logoUrl;
        this.isLogoEmpty = logoUrl == null ? true : false;
        this.language = language;
        this.documentCode = documentCode;
        this.sociedad2Name = sociedad2Name;
        this.compania=compania;
        this.nPoliza=nPoliza;
        this.centro = centro;
        this.nServicio = nServicio;
        this.asesor = asesor;
        this.difunto = difunto;
        this.pedidoName = pedidoName;
        this.fetchaPedido = fetchaPedido?.format();
        this.difunto = difunto;
        this.proveedor = proveedor;
        this.datosDelDifunto = datosDelDifunto;
        this.datosDelContacto = datosDelContacto;
        this.velatorio = velatorio;
        this.despedida = despedida;
        this.ceremonia = ceremonia;
        this.finilizacion = finilizacion;
        this.datosDeDfuncion = datosDeDfuncion;
        this.footerInformation = footerInformation;
    }
    //Set all query variable to the corresponding PDF variables	
    public class DatosDelDifunto {
        public String nombreYApellidos {public get; private set;}
        public String nombreColoquial {public get; private set;}
        public String nif {public get; private set;}
        public String nacionalidad {public get; private set;}
        public String lugarDeNacimiento {public get; private set;}
        public String edad {public get; private set;}
        public String altura {public get; private set;}
        public String peso {public get; private set;}
        public String nombreDelPadre {public get; private set;}
        public String nombreDeLaMadre {public get; private set;}
        public String estadoCivil {public get; private set;}
        public String hijos {public get; private set;}
        public String conyuge {public get; private set;}
        public String domicilio {public get; private set;}
        public String paisYCp {public get; private set;}
        public String fNacimiento {public get; private set;}
        public String provinciaNacimiento {public get; private set;}

        

        public DatosDelDifunto(String nombreYApellidos, String nombreColoquial, String nif, String nacionalidad, String lugarDeNacimiento, String edad,
            String altura, String peso, String nombreDelPadre, String nombreDeLaMadre, String estadoCivil, String hijos, String conyuge,
            String domicilio, String paisYCp, String fNacimiento, String provinciaNacimiento) {
            this.nombreYApellidos = nombreYApellidos;
            this.nombreColoquial = nombreColoquial;
            this.nif = nif;
            this.nacionalidad = nacionalidad;
            this.lugarDeNacimiento = lugarDeNacimiento;
            this.edad = edad;
            this.altura = altura;
            this.peso = peso;
            this.nombreDelPadre = nombreDelPadre;
            this.nombreDeLaMadre = nombreDeLaMadre;
            this.estadoCivil = estadoCivil;
            this.hijos = hijos;
            this.conyuge = conyuge;
            this.domicilio = domicilio;
            this.paisYCp = paisYCp;
            this.fNacimiento = fNacimiento;
            this.provinciaNacimiento = provinciaNacimiento;

        }
    }

    public class DatosDelContacto {
        public String nombreYApellidos {public get; private set;}
        public String parentesco {public get; private set;}
        public String nif {public get; private set;}
        public String telefono {public get; private set;}
        public String email {public get; private set;}
        public String direccion {public get; private set;}

        public DatosDelContacto(String nombreYApellidos, String parentesco, String nif, String telefono, String email, String direccion) {
            this.nombreYApellidos = nombreYApellidos;
            this.parentesco = parentesco;
            this.nif = nif;
            this.telefono = telefono;
            this.email=email;
            this.direccion=direccion;
        }
    }

    public class DatosDeDfuncion {
        public String tipoDeLugar {public get; private set;}
        public String nombreLugar {public get; private set;}
        public String lugar {public get; private set;}
        public String fechaDeDefuncion {public get; private set;}
        public String causasDeDefuncion {public get; private set;}
        public String municipioDeDefuncion {public get; private set;}
        
        public DatosDeDfuncion(String tipoDeLugar,String nombreLugar,String lugar, String fechaDeDefuncion, String causasDeDefuncion, String municipioDeDefuncion) {
            this.tipoDeLugar=tipoDeLugar;
            this.nombreLugar=nombreLugar;
            this.lugar = lugar;
            this.fechaDeDefuncion = fechaDeDefuncion;
            this.causasDeDefuncion = causasDeDefuncion;
            this.municipioDeDefuncion = municipioDeDefuncion;
        }
    }

    public class Velatorio {
        public String lugar {public get; private set;}
        public String fechaDeEntrada {public get; private set;}
        public String fechaDeSalida {public get; private set;}
        public String sala {public get; private set;}
        public String observacionesVelacion {public get; private set;}
        
        public Velatorio(String lugar, String fechaDeEntrada, String fechaDeSalida, String sala, String observacionesVelacion) {
            this.lugar = lugar;
            this.fechaDeEntrada = fechaDeEntrada;
            this.fechaDeSalida = fechaDeSalida;
            this.sala = sala;
            this.observacionesVelacion = observacionesVelacion;
        }
    }

    
    public class Despedida {
        public String lugar {public get; private set;}
        public String fechaDeEntrada {public get; private set;}
        public String tipoRito {public get; private set;}
        public String sala {public get; private set;}
        public String observacionesDespedida {public get; private set;}
        
        public Despedida(String lugar, String fechaDeEntrada, String tipoRito, String sala, String observacionesDespedida) {
            this.lugar = lugar;
            this.fechaDeEntrada = fechaDeEntrada;
            this.tipoRito = tipoRito;
            this.sala = sala;
            this.observacionesDespedida = observacionesDespedida;
        }
    }
    
    
    public class Ceremonia {
        public String lugar {public get; private set;}
        public String fechaDeEntrada {public get; private set;}
        public String tipoRito {public get; private set;}
        public String sala {public get; private set;}
        public String observacionesCeremonia {public get; private set;}
        
        public Ceremonia(String lugar, String fechaDeEntrada, String tipoRito, String sala, String observacionesCeremonia) {
            this.lugar = lugar;
            this.fechaDeEntrada = fechaDeEntrada;
            this.tipoRito = tipoRito;
            this.sala = sala;
            this.observacionesCeremonia = observacionesCeremonia;
        }
    }

    public class Finilizacion {
        public String crematorio {public get; private set;}
        public String cementerioDe {public get; private set;}
        public String transladoA {public get; private set;}
        public String lodp {public get; private set;}
        public Boolean inhumacion {public get; private set;}
        public Boolean incineracion {public get; private set;}
        public Boolean traslado {public get; private set;}
        public String fechaIncineracion {public get; private set;}
        public String fechaInhumacion {public get; private set;}
        public String ubicacion{public get; private set;}
        public Boolean FamilyInFinalDestination {public get; private set;}
        public String fechaTraslado{public get; private set;}
        public String ambitoTraslado{public get; private set;}
        public String funeraria{public get; private set;}
        public String observacionesTraslado {public get; private set;}
        public String paisTraslado {public get; private set;}
        public String destinoFinalTraslado {public get; private set;}
        public String fechaHoraCompromisoLlegada {public get; private set;}


    
        public Finilizacion(String crematorio, String cementerioDe, String transladoA, String lodp, Boolean inhumacion, Boolean incineracion, Boolean traslado,String fechaIncineracion,
        String fechaInhumacion,String ubicacion, Boolean familyInFinalDestination, String fechaTraslado,String ambitoTraslado,String funeraria,String observacionesTraslado, String paisTraslado, String destinoFinalTraslado, String fechaHoraCompromisoLlegada) {
            this.cementerioDe = cementerioDe;
            this.crematorio = crematorio;
            this.lodp = lodp;
            this.transladoA = transladoA;
            this.inhumacion=inhumacion;
            this.incineracion=incineracion;
            this.traslado=traslado;
            this.fechaIncineracion=fechaIncineracion;
            this.fechaInhumacion=fechaInhumacion;
            this.ubicacion=ubicacion;
            this.familyInFinalDestination = familyInFinalDestination;
            this.fechaTraslado=fechaTraslado;
            this.ambitoTraslado=ambitoTraslado;
            this.funeraria=funeraria;
            this.observacionesTraslado = observacionesTraslado;
            this.paisTraslado = paisTraslado;
            this.destinoFinalTraslado = destinoFinalTraslado;
            this.fechaHoraCompromisoLlegada = fechaHoraCompromisoLlegada;
        }
    }
}
/**
  * Created by msulek003 on 12.04.2021.   
 */

//Prepare data structure for presupuesto comercial PDF documentos, this is used for the front end cominucation to generate the contenf of the PDF using the VFP

public with sharing class ONE_PresupuestoComercialData {
    public String headerLogoUrl { public get; private set; }
    public String footerLogoUrl { public get; private set; }
    public Boolean isLogoEmpty { public get; private set; }
    public String footerInformation { public get; private set; }
    public String taxLabel { public get; private set; }
    public String signatureUrl { public get; private set; }
    public String conditionsSignatureUrl { public get; private set; }
    public String finalPricing { public get; private set; }
    public HeaderData headerData { public get; private set; }
    public DifuntoData difuntoData { public get; private set; }
    public ServicioData servicioData { public get; private set; }
    public MomentoListData momentoListData { public get; private set; }
    public List<ONE_MomentoData> descuentosList { public get; private set; }
    public Boolean descuentosListHeader { public get; private set; }
    public List<ONE_MomentoData> suplidosList { public get; private set; }
    public Boolean suplidosListHeader { public get; private set; }
    public List<ImpuestosData> impuestosList { public get; private set; }
    public String defaultCurrency { public get; private set; }
    public String language { public get; private set; }
    public Boolean isFacturaMejora { public get; private set; }
    public Boolean isPresupuestoServicioCompleto { public get; private set; }
    public Boolean isNumeroDeCuentaBancariaShown { public get; private set; }
    public String numeroDeCuentaBancaria { public get; private set; }
    public String generateSerfunle { public get; private set; }
    public String recordtypeName { public get; private set; }
    public String tipoContrato { public get; private set; }
    public String metodoPago { public get; private set; }

   


    
    public ONE_PresupuestoComercialData(String logoUrl, String language, String footerLogoUrl, String taxLabel, String footerInformation, Decimal finalPricing, HeaderData headerData,
        DifuntoData difuntoData, ServicioData servicioData, MomentoListData momentoListData, Map<List<ONE_MomentoData>, Boolean> descuentosList, Map<List<ONE_MomentoData>, Boolean> suplidosList,
        List<ImpuestosData> impuestosList, String signatureUrl, String conditionsSignatureUrl, Boolean isFacturaMejora, Boolean isPresupuestoServicioCompleto,
        Boolean isNumeroDeCuentaBancariaShown, String numeroDeCuentaBancaria, String generateSerfunle,String recordtypeName, String tipoContrato,String metodoPago) {
        this.headerLogoUrl = logoUrl == null ? '' : logoUrl;
        this.language = language;
        this.footerLogoUrl = footerLogoUrl == null ? '' : footerLogoUrl;
        this.isLogoEmpty = logoUrl == null ? true : false;
        this.taxLabel = taxLabel;
        this.footerInformation = footerInformation;
        this.finalPricing = finalPricing == null ? '0' : finalPricing.format();
        this.headerData = headerData;
        this.difuntoData = difuntoData;
        this.servicioData = servicioData;
        this.momentoListData = momentoListData;
        this.descuentosList = descuentosList.keySet().iterator().next();
        this.descuentosListHeader = descuentosList.values().get(0);
        this.suplidosList = suplidosList.keySet().iterator().next();
        this.suplidosListHeader = suplidosList.values().get(0);
        this.impuestosList = impuestosList;
        this.signatureUrl = signatureUrl;
        this.conditionsSignatureUrl = conditionsSignatureUrl;
        this.defaultCurrency = '€';
        this.isFacturaMejora = isFacturaMejora;
        this.isPresupuestoServicioCompleto = isPresupuestoServicioCompleto;
        this.isNumeroDeCuentaBancariaShown = isNumeroDeCuentaBancariaShown;
        this.numeroDeCuentaBancaria = numeroDeCuentaBancaria;
        this.generateSerfunle = generateSerfunle;
        this.recordtypeName = recordtypeName;
        this.tipoContrato = tipoContrato;
        this.metodoPago = metodoPago;
        
            
    }

    public class HeaderData {
        public String sociedad { public get; private set; }
        public String direccion { public get; private set; }
        public String provinciaCP { public get; private set; }
        public String telefono { public get; private set; }
        public String fax { public get; private set; }
        public String webMemora { public get; private set; }
        public String fecha { public get; private set; }
        public String presupestoName { public get; private set; }
        public String abonoNumber { public get; private set; }
        public String facturaNumber { public get; private set; }
        public Boolean isCentroMemora { public get; private set; }
        public String nombreFiscalDeLaCuentaCentro { public get; private set; }
        public String direccionCentro { public get; private set; }
        public String addressCentro { public get; private set; }
        public String cif { public get; private set; }
        public String tipoFactura { public get; private set; }
        public String tipoDocumento { public get; private set; }
        public String idTBAI { public get; private set; }
        public String qrTBAI { public get; private set; }
        public Boolean isPresupuestoSegundaVenta {public get; private set;}
        public Boolean containConcesiones {public get; private set;}

        public HeaderData(String sociedad, String direccion, String provinciaCP, String telefono, String fax,
            String webMemora, String presupestoName, String abonoNumber, String facturaNumber, Boolean isCentroMemora,
            String nombreFiscalDeLaCuentaCentro, String direccionCentro, String addressCentro,Date fetcha,String cif,String tipoFactura, String tipoDocumento,
            String idTBAI, String qrTBAI, Boolean isPresupuestoSegundaVenta, Boolean containConcesiones) {

            this.sociedad = sociedad;
            this.direccion = direccion;
            this.provinciaCP = provinciaCP;
            this.telefono = telefono;
            this.fax = fax;
            this.fecha = fetcha != null ? fetcha.format() : Date.today().format();
            this.presupestoName = presupestoName;
            this.abonoNumber = abonoNumber;
            this.facturaNumber = facturaNumber;
            this.isCentroMemora = isCentroMemora;
            this.nombreFiscalDeLaCuentaCentro = nombreFiscalDeLaCuentaCentro;
            this.direccionCentro = direccionCentro;
            this.addressCentro = addressCentro;
            this.cif = cif;
            this.webMemora= webMemora;
            this.tipoFactura=tipoFactura;
            this.tipoDocumento=tipoDocumento;
            this.idTBAI=idTBAI;
            this.qrTBAI=qrTBAI;
            this.isPresupuestoSegundaVenta = isPresupuestoSegundaVenta;
            this.containConcesiones = containConcesiones;
        }
    }


    public class DifuntoData {
        public String nombreDifunto { public get; private set; }
        public String DNI { public get; private set; }
        public String lugarDeDefuncion { public get; private set; }
        public String numeroServico { public get; private set; }
        public String numeroPoliza { public get; private set; }
        public String numeroSinestra { public get; private set; }
        public String pagador { public get; private set; }
        public String direccion { public get; private set; }
        public String ConDNI { public get; private set; }
        public Boolean isDNI { public get; private set; }
        public String provinciaCPMunicipio { public get; private set; }
        public String fechaDefuncion {public get; private set; }

        public DifuntoData(String nombreDifunto, String DNI, String lugarDeDefuncion, String numeroServico, String numeroPoliza,
                String numeroSinestra, String pagador, String direccion, String ConDNI, Boolean isDNI, String provinciaCPMunicipio, String fechaDefuncion) {
            this.nombreDifunto = nombreDifunto;
            this.DNI = DNI;
            this.lugarDeDefuncion = lugarDeDefuncion;
            this.numeroServico = numeroServico;
            this.numeroPoliza = numeroPoliza;
            this.numeroSinestra = numeroSinestra;
            this.pagador = pagador;
            this.direccion = direccion;
            this.ConDNI = ConDNI;
            this.isDNI = isDNI;
            this.provinciaCPMunicipio = provinciaCPMunicipio;
            this.fechaDefuncion = fechaDefuncion == null ? '' : fechaDefuncion;
                    
        }
        

    }

    public class ServicioData {
        public String velacionDate { public get; private set; }
        public String velacionPlace { public get; private set; }
        public String velacionStreet { public get; private set; }
        public String velacionCity { public get; private set; }
        public String ceremoniaDate { public get; private set; }
        public String ceremoniaPlace { public get; private set; }
        public String ceremoniaStreet { public get; private set; }
        public String ceremoniaCity { public get; private set; }
        public String incineracionDate { public get; private set; }
        public String incineracionPlace { public get; private set; }
        public String incineracionStreet { public get; private set; }
        public String incineracionCity { public get; private set; }
        public String inhumacionDate { public get; private set; }
        public String inhumacionPlace { public get; private set; }
        public String inhumacionStreet { public get; private set; }
        public String inhumacionCity { public get; private set; }
        public String recordtype { public get; private set; }
        public String nombreMascota	{ public get; private set; }
        public String microchip { public get; private set; }
        public String tipoMascota { public get; private set; }

        public ServicioData(Datetime velacionDate, String velacionPlace, String velacionStreet, String velacionCity,
            Datetime ceremoniaDate, String ceremoniaPlace,  String ceremoniaStreet, String ceremoniaCity, 
            Datetime incineracionDate, String incineracionPlace, String incineracionStreet, String incineracionCity, 
            Datetime inhumacionDate, String inhumacionPlace, String inhumacionStreet, String inhumacionCity,String recordtype,
            String nombreMascota, String microchip, String tipoMascota) {
            
            this.velacionDate = velacionDate == null ? '' : date.newinstance(velacionDate.year(), velacionDate.month(), velacionDate.day()).format();
            this.velacionPlace = velacionPlace;
            this.velacionStreet = velacionStreet;
            this.velacionCity = velacionCity;
            this.ceremoniaDate = ceremoniaDate == null ? '' : date.newinstance(ceremoniaDate.year(), ceremoniaDate.month(), ceremoniaDate.day()).format();
            this.ceremoniaPlace = ceremoniaPlace;
            this.ceremoniaStreet = ceremoniaStreet;
            this.ceremoniaCity = ceremoniaCity;
            this.incineracionDate = incineracionDate == null ? '' : date.newinstance(incineracionDate.year(), incineracionDate.month(), incineracionDate.day()).format();
            this.incineracionPlace = incineracionPlace;
            this.incineracionStreet = incineracionStreet;
            this.incineracionCity = incineracionCity;
            this.inhumacionDate = inhumacionDate == null ? '' : date.newinstance(inhumacionDate.year(), inhumacionDate.month(), inhumacionDate.day()).format();
            this.inhumacionPlace = inhumacionPlace;
            this.inhumacionStreet = inhumacionStreet;
            this.inhumacionCity = inhumacionCity;
            this.recordtype=recordtype;
            this.nombreMascota=nombreMascota;
            this.microchip=microchip;
            this.tipoMascota=tipoMascota;
        }
    }

    public class MomentoListData {
        public List<ONE_MomentoData> prestracionList { public get; private set; }
        public List<ONE_MomentoData> velacionList { public get; private set; }
        public List<ONE_MomentoData> ceremoniaList { public get; private set; }
        public List<ONE_MomentoData> arteFloralList { public get; private set; }
        public List<ONE_MomentoData> productosRecurdoList { public get; private set; }
        public List<ONE_MomentoData> trasladosList { public get; private set; }
        public List<ONE_MomentoData> seguimosAcompanandoteList { public get; private set; }
        public List<ONE_MomentoData> comunicacionList { public get; private set; }
        public List<ONE_MomentoData> destinoIncineracionList { public get; private set; }
        public List<ONE_MomentoData> destinoInhumacionList { public get; private set; }
        public List<ONE_MomentoData> serviciosCompaniasList { public get; private set; }

        public String prestracionSum { public get; private set; }
        public String velacionSum { public get; private set; }
        public String ceremoniaSum { public get; private set; }
        public String arteFloralSum { public get; private set; }
        public String productosRecurdoSum { public get; private set; }
        public String trasladosSum { public get; private set; }
        public String seguimosAcompanandoteSum { public get; private set; }
        public String comunicacionSum { public get; private set; }
        public String destinoIncineracionSum { public get; private set; }
        public String destinoInhumacionSum { public get; private set; }
        public String serviciosCompaniasSum { public get; private set; }

        public Boolean prestracionDescuentosHeader { public get; private set; }
        public Boolean velacionDescuentosHeader { public get; private set; }
        public Boolean ceremoniaDescuentosHeader { public get; private set; }
        public Boolean arteFloralDescuentosHeader { public get; private set; }
        public Boolean productosRecurdoDescuentosHeader { public get; private set; }
        public Boolean trasladosDescuentosHeader { public get; private set; }
        public Boolean seguimosAcompanandoteDescuentosHeader { public get; private set; }
        public Boolean comunicacionDescuentosHeader { public get; private set; }
        public Boolean destinoIncineracionDescuentosHeader { public get; private set; }
        public Boolean destinoInhumacionDescuentosHeader { public get; private set; }
        public Boolean serviciosCompaniasDescuentosHeader { public get; private set; }

        public MomentoListData(List<ONE_MomentoData> prestracionList, Decimal prestracionSum,
            List<ONE_MomentoData> velacionList, Decimal velacionSum,
            List<ONE_MomentoData> ceremoniaList, Decimal ceremoniaSum,
            List<ONE_MomentoData> arteFloralList, Decimal arteFloralSum,
            List<ONE_MomentoData> productosRecurdoList, Decimal productosRecurdoSum,
            List<ONE_MomentoData> trasladosList, Decimal trasladosSum,
            List<ONE_MomentoData> seguimosAcompanandoteList, Decimal seguimosAcompanandoteSum,
            List<ONE_MomentoData> comunicacionList, Decimal comunicacionSum,
            List<ONE_MomentoData> destinoIncineracionList, Decimal destinoIncineracionSum,
            List<ONE_MomentoData> destinoInhumacionList, Decimal destinoInhumacionSum,
            List<ONE_MomentoData> serviciosCompaniasList, Decimal serviciosCompaniasSum
        ) {
            this.prestracionList = prestracionList;
            this.prestracionSum = prestracionSum.format();
            this.prestracionDescuentosHeader = checkIfDescuentosApplied(prestracionList);
            this.velacionList = velacionList;
            this.velacionSum = velacionSum.format();
            this.velacionDescuentosHeader = checkIfDescuentosApplied(velacionList);
            this.ceremoniaList = ceremoniaList;
            this.ceremoniaSum = ceremoniaSum.format();
            this.ceremoniaDescuentosHeader = checkIfDescuentosApplied(ceremoniaList);
            this.arteFloralList = arteFloralList;
            this.arteFloralSum = arteFloralSum.format();
            this.arteFloralDescuentosHeader = checkIfDescuentosApplied(arteFloralList);
            this.productosRecurdoList = productosRecurdoList;
            this.productosRecurdoSum = productosRecurdoSum.format();
            this.productosRecurdoDescuentosHeader = checkIfDescuentosApplied(productosRecurdoList);
            this.trasladosList = trasladosList;
            this.trasladosSum = trasladosSum.format();
            this.trasladosDescuentosHeader = checkIfDescuentosApplied(trasladosList);
            this.seguimosAcompanandoteList = seguimosAcompanandoteList;
            this.seguimosAcompanandoteSum = seguimosAcompanandoteSum.format();
            this.seguimosAcompanandoteDescuentosHeader = checkIfDescuentosApplied(seguimosAcompanandoteList);
            this.comunicacionList = comunicacionList;
            this.comunicacionSum = comunicacionSum.format();
            this.comunicacionDescuentosHeader = checkIfDescuentosApplied(comunicacionList);
            this.destinoIncineracionList = destinoIncineracionList;
            this.destinoIncineracionSum = destinoIncineracionSum.format();
            this.destinoIncineracionDescuentosHeader = checkIfDescuentosApplied(destinoIncineracionList);
            this.destinoInhumacionList = destinoInhumacionList;
            this.destinoInhumacionSum = destinoInhumacionSum.format();
            this.destinoInhumacionDescuentosHeader = checkIfDescuentosApplied(destinoInhumacionList);
            this.serviciosCompaniasList = serviciosCompaniasList;
            this.serviciosCompaniasSum = serviciosCompaniasSum.format();
            this.serviciosCompaniasDescuentosHeader = checkIfDescuentosApplied(serviciosCompaniasList);
        }

        private Boolean checkIfDescuentosApplied(List<ONE_MomentoData> momentoData) {
            for (ONE_MomentoData momento : momentoData) {
                if (!momento.descuento.equals('0')) {
                    return true;
                }
            }
            return false;
        }
    }

    public class ImpuestosData {
        public String impuestoName { public get; private set; }
        public String importeBase { public get; private set; }
        public String importeImpuesto { public get; private set; }
        public String importeNeto { public get; private set; }


        public ImpuestosData(String impuestoName, Decimal importeBase, Decimal importeImpuesto, Decimal importeNeto) {
            this.impuestoName = impuestoName;
            this.importeBase = formatWithTwoDecimalPlaces(importeBase);
            this.importeImpuesto = formatWithTwoDecimalPlaces(importeImpuesto);
            this.importeNeto = formatWithTwoDecimalPlaces(importeNeto);
        }

        private String formatWithTwoDecimalPlaces(Decimal d) {
            if (d == null || d == 0) {
                return '0';
            }

            String output = d.setScale(2).format();
            if (output.contains(',')) {
                if (output.indexOf(',') == output.length() - 2) {
                    return output + '0';
                } else {
                    return output;
                }
            } else {
                return output + ',00';
            }
        }
    }
}
public class ONE_SuplidoSegurCaixaData {

    public String logoUrl {public get; private set;}
    public String documentCode {public get; private set;}
    public String sociedadCentroMemora {public get; private set;}
    public String CIFsociedadCentroMemora {public get; private set;}
    public String nombreServicio {public get; private set;}
    public String numeroFactura {public get; private set;}
    public String fechaFacturacion {public get; private set;}
    public String nombreDifunto {public get; private set;}
    public String numeropPoliza {public get; private set;}
    public String capturaDeFirmaUrl {public get; private set;}
    public String nombreFirmante {public get; private set;}
    public String direccionCentroMemora {public get; private set;}
    public String Fecha_Now {public get; private set;}
    public String companyaAseguradora {public get; private set;} 
	public String cifCompanyaAseguradora {public get; private set;}
    public String provincia {public get; private set;} 
	public List<ONE_Expediente_Line_Item__c> lineasContratadas {get;set;} 
    public Decimal totalContrato {public get; private set;} 

    
    public class TareaData {

        public Integer id {get; set;}
        public String materialContratado {get; set;}
        public Decimal cantidad {get; set;}
        public String precio {get; set;}

    }
	
    public ONE_SuplidoSegurCaixaData(ONE_Orden_De_Venta__c	ordenDeVenta) {
        
        logoUrl = ordenDeVenta.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null 
            ? ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c;
        documentCode = 'F-PR-07-AD-007.01/B1';
        sociedadCentroMemora = ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.name;
        CIFsociedadCentroMemora = ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_CIF__c;
        nombreServicio = ordenDeVenta.ONE_Servicio__r.Name;
        numeroFactura = ordenDeVenta.ONE_Numero_de_factura__c;
        fechaFacturacion = ordenDeVenta.ONE_Fecha_De_Facturacion__c.format();
        nombreDifunto = ordenDeVenta.ONE_Servicio__r.ONE_Difunto__r.Name;
        numeropPoliza = ordenDeVenta.ONE_Servicio__r.ONE_Numero_de_Poliza__c;
        capturaDeFirmaUrl = PageReference.forResource('FirmaRafaelRosell').getUrl();
        nombreFirmante = 'Rafael';
        direccionCentroMemora = ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Direccion__c + ', ' +ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Codigo_Postal__c+ ' '+ 
        ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Municipio_Direccion__c +' ('+ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Provincia__c+').';
        companyaAseguradora = 'SEGURCAIXA CENTRAL';
        cifCompanyaAseguradora = 'A28011864';
        Fecha_Now = system.today().format();
        provincia=ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Provincia__c;
        
		lineasContratadas = [
            SELECT 
                   Id,
                   ONE_Producto__c,
            	   ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
            	   ONE_Modelo__r.Name,
                   ONE_Importe_Neto__c,
                   ONE_Cantidad__c
                  
            FROM ONE_Expediente_Line_Item__c WHERE ONE_Orden_De_Venta__c = :ordenDeVenta.ID and one_suplido__c = true
        ];
        
        totalContrato = 0.0;
        for(ONE_Expediente_Line_Item__c linea:lineasContratadas){
            totalContrato = totalContrato + linea.ONE_Importe_Neto__c;
        }
    }


}
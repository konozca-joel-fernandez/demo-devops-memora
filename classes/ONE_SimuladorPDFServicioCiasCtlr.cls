public class ONE_SimuladorPDFServicioCiasCtlr {
 	public Id presupuestoId {public get; private set;}
    public String language {public get; private set;}
    public Id servicioId {public get; private set;}
    public String validityYear {public get; private set;}
    public String cliente {public get; private set;}
    public String newAcuerdoName {public get; private set;}
    public String logo {public get; private set;}
    public PresupuestoCiasData data {public get; private set;}
    
    
     public ONE_SimuladorPDFServicioCiasCtlr() {
        presupuestoId = ApexPages.currentPage().getParameters().get('presupuestoId');
        language = ApexPages.currentPage().getParameters().get('language');
        servicioId=ApexPages.currentPage().getParameters().get('servicioId');
        validityYear=(ApexPages.currentPage().getParameters().get('validityYear')).replace('.','');
        cliente=ApexPages.currentPage().getParameters().get('cliente');
        newAcuerdoName=ApexPages.currentPage().getParameters().get('newAcuerdoName');
        logo=ApexPages.currentPage().getParameters().get('logo');
        data=setupData();
    }
	//Add data to the PDF content
    public PresupuestoCiasData setupData() {
        Map<String,List<Product>> momentsWithProducts=new Map<String,List<Product>>() ;
        List<Product> productxmoment=new List<Product>();
        List <Moment> momentList= new List <Moment>();
        for(ONE_Expediente_Line_Item__c sli: [SELECT Id,ONE_Producto__c,ONE_Entrada_De_Precio__c,ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Orden__c, ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.name,ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_CAT__c,ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_EUS__c,
                                              ONE_Producto__r.ONE_Codigo_Comercial__c,ONE_Entrada_De_Precio__r.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Castellano__c,ONE_Entrada_De_Precio__r.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Catalan__c, ONE_Entrada_De_Precio__r.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Euskera__c,
                                              ONE_Unidades__c,ONE_Precio__c,ONE_Producto__r.ONE_Tipo_Impositivo__c,ONE_Suplido__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Tipo_De_Impuesto__c,
                                              ONE_Producto__r.ONE_Descripcion_En_Castellano__c,ONE_Producto__r.ONE_Descripcion_En_Catalan__c, ONE_Producto__r.ONE_Descripcion_En_Euskera__c,ONE_Importe_Descuento_Posicion__c
                                              FROM ONE_Expediente_Line_Item__c  
                                              WHERE ONE_Presupuesto__c =:presupuestoId AND ONE_Estado__c='Confirmado' 
                                              ORDER BY ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Orden__c ASC,
                                                            ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Orden__c ASC,
                                                            ONE_Producto__r.ONE_Categoria__r.ONE_Orden__c ASC,
                                                            ONE_Producto__r.CreatedDate ASC]){
                                                  
          
          Product producto=new Product(sli.ONE_Producto__r.ONE_Codigo_Comercial__c,
                              buildProductName(sli.ONE_Entrada_De_Precio__c,sli.ONE_Entrada_De_Precio__r.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Castellano__c,sli.ONE_Entrada_De_Precio__r.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Catalan__c,sli.ONE_Entrada_De_Precio__r.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Euskera__c, sli.ONE_Producto__r.ONE_Descripcion_En_Castellano__c,sli.ONE_Producto__r.ONE_Descripcion_En_Catalan__c,sli.ONE_Producto__r.ONE_Descripcion_En_Euskera__c,language),
                              Integer.valueOf(sli.ONE_Unidades__c),
                              sli.ONE_Precio__c,
                              sli.ONE_Producto__r.ONE_Tipo_Impositivo__c,
                              sli.ONE_Suplido__c,
                              sli.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Tipo_De_Impuesto__c == 'IGIC'? true:false,
                              language =='es'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.name :language =='ca'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_CAT__c:language =='eu'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_EUS__c:sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,
                              language,
                              sli.ONE_Importe_Descuento_Posicion__c);
                                                  
          
          if(momentsWithProducts.containsKey(language =='es'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.name :language =='ca'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_CAT__c:language =='eu'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_EUS__c:sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name)){
            productxmoment=momentsWithProducts.get(language =='es'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.name :language =='ca'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_CAT__c:language =='eu'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_EUS__c:sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name);
            productxmoment.add(producto);
          }else{
            productxmoment=new List<Product>();  
			productxmoment.add(producto);
			momentsWithProducts.put(language =='es'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.name :language =='ca'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_CAT__c:language =='eu'?sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Nombre_EUS__c:sli.ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,productxmoment);             
          }
                                                  
		                                                  
        }
       
        System.debug('momentsWithProducts'+momentsWithProducts);
        for (String key : momentsWithProducts.keySet()) {
             Decimal totalamount=0;
            for(Product producto: momentsWithProducts.get(key)){
               totalamount+=producto.rate;
            }
           Moment momento = new Moment(key,totalamount,momentsWithProducts.get(key));
           momentList.add(momento);
        }
        System.debug('momentList'+momentList);
        ONE_Presupuesto__c presupuesto=[SELECT ONE_Importe_Base_21__c,ONE_Importe_Base_10__c,ONE_Importe_Base_3__c,
                                        ONE_Importe_Impuesto_21__c,ONE_Importe_Impuesto_10__c,ONE_Importe_Impuesto_3__c,
                                        ONE_Importe_Neto_21__c,ONE_Importe_Neto_10__c,ONE_Importe_Neto_3__c,ONE_Importe_Neto_Suplido__c,
                                        ONE_Total_Importe_Presupuesto__c,ONE_Observaciones__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
                                        FROM ONE_Presupuesto__c WHERE Id=:presupuestoId LIMIT 1];

        System.debug('LOGO: ' + presupuesto.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null ? presupuesto.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c : logo != null ? logo : '/resource/MemoraLogo');
        
        return new PresupuestoCiasData(language,validityYear,cliente,newAcuerdoName, presupuesto.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null ? presupuesto.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c : logo != null ? logo : '/resource/MemoraLogo',momentList,String.valueOf(presupuesto.ONE_Importe_Base_21__c),
                                      String.valueOf(presupuesto.ONE_Importe_Impuesto_21__c),String.valueOf(presupuesto.ONE_Importe_Neto_21__c),String.valueOf(presupuesto.ONE_Importe_Base_10__c),
                                      String.valueOf(presupuesto.ONE_Importe_Impuesto_10__c),String.valueOf(presupuesto.ONE_Importe_Neto_10__c),String.valueOf(presupuesto.ONE_Importe_Base_3__c),
                                      String.valueOf(presupuesto.ONE_Importe_Impuesto_3__c),String.valueOf(presupuesto.ONE_Importe_Neto_3__c),String.valueOf(presupuesto.ONE_Importe_Neto_Suplido__c),
                                      String.valueOf(presupuesto.ONE_Total_Importe_Presupuesto__c), language=='es'?System.Label.ONE_Observaciones_Acuerdo:language=='ca'?Label.get('', 'ONE_Observaciones_Acuerdo', 'ca'):language=='eu'?Label.get('', 'ONE_Observaciones_Acuerdo', 'ca'):System.Label.ONE_Observaciones_Acuerdo,
                                      String.valueOf(presupuesto.ONE_Observaciones__c)!=null?String.valueOf(presupuesto.ONE_Observaciones__c) : '');
    }
    
    public static string buildProductName(string entradaPrecio, String eProductoEs, String eProductoCat, String eProductoEu, String nameProductoEs, String nameProductoCat, String nameProductoEu, String language){
        if(entradaPrecio!=null){
        	return language =='es'? eProductoEs :language =='ca'?eProductoCat :language =='eu'?eProductoEu : eProductoEs ;           
        }else{
            return language =='es'? nameProductoEs :language =='ca'?nameProductoCat :language =='eu'?nameProductoEu : nameProductoEs ;           
        }
        
    }
    
    public class Product {
    	public String code {public get; private set;}
        public String name {public get; private set;}
        public Integer units {public get; private set;}
        public Decimal unitRate {public get; private set;}
        public Decimal rate {public get; private set;}
        public String rateString {public get; private set;}
        public Decimal vatRate {public get; private set;}
        public String vatRateString {public get; private set;}
        public Decimal vatAmount {public get; private set;}
        public String vatAmountString {public get; private set;}
        public Decimal price {public get; private set;}
        public String priceString {public get; private set;}
        public Boolean supplied {public get; private set;}
        public String suppliedString {public get; private set;}
        public String momentoName {public get; private set;}
        public Decimal discount {public get; private set;}
        
        public Product(String code, String name, Integer units, Decimal unitRate, String tipoImpositivo, Boolean supplied, Boolean igic, String momentoName,String language, Decimal discount) {
            this.code = code;
            this.name = name;
            this.units = units != null ? units : 1;
            this.unitRate = unitRate;
            this.supplied = supplied;
            this.suppliedString = this.supplied && language=='es'? 'Suplido' : this.supplied && language=='ca'? 'Suplert' :this.supplied && language=='eu'? 'Ordezkatua' :'';
            
            if (this.supplied) {
                this.vatRateString = '0%';
                this.vatRate = 0.00;
            }
            else {
                switch on tipoImpositivo {
                    when 'Normal' {
                        if (igic) {
                            this.vatRateString = '3%';
                            this.vatRate = 0.03;
                        }
                        else {
                            this.vatRateString = '21%';
                            this.vatRate = 0.21;
                        }
                    }
                    when 'Reducido' {
                        if (igic) {
                            this.vatRateString = '3%';
                            this.vatRate = 0.03;
                        }
                        else {
                            this.vatRateString = '10%';
                            this.vatRate = 0.10;
                        }
                    }
                    when 'Superreducido' {
                        if (igic) {
                            this.vatRateString = '3%';
                            this.vatRate = 0.03;
                        }
                        else {
                            this.vatRateString = '4%';
                            this.vatRate = 0.04;
                        }
                    }
                    when 'Exento' {
                        this.vatRateString = '0%';
                        this.vatRate = 0.00;
                    }
                    when else {
                        this.vatRateString = '0%';
                        this.vatRate = 0.00;
                    }
                }
            }
            
            this.rate = discount!=null || discount!=0 ?(this.unitRate.setScale(2) * this.units)-discount:this.unitRate.setScale(2) * this.units;
            this.rateString = getFormattedAmountString(this.rate.setScale(2));
            this.vatAmount = (this.rate * this.vatRate).setScale(2);
            this.price = (this.rate + this.vatAmount).setScale(2);
            this.vatAmountString = getFormattedAmountString(this.vatAmount.setScale(2));
            this.priceString = getFormattedAmountString(this.price.setScale(2));
            this.momentoName=momentoName;
            this.discount=discount;
        }
    }
    
    public class Moment {
    	public String name {public get; private set;}
        public String nameUppercased {public get; private set;}
        public Decimal amount {public get; private set;}
        public String amountString {public get; private set;}
        public List<Product> products {public get; private set;}
        
        public Moment(String name, Decimal amount, List<Product> products) {
            this.name = (name != null ? name : '');
            this.nameUppercased = this.name.toUpperCase();
            this.amount = amount;
            this.amountString = getFormattedAmountString(this.amount);
            this.products = products;
        }
    }
   
    
    
    public class PresupuestoCiasData {
        public String language { public get; private set; }
        public String validityYear { public get; private set; }
        public String cliente { public get; private set; }
        public String newAcuerdoName { public get; private set; }
        public String logo { public get; private set; }
        public List<Moment> moments {public get; private set;}
        public String base21Rate {get; private set;}
        public String base21VatAmount {get; private set;}
        public String base21Price {get; private set;}
        public String base10Rate {get; private set;}
        public String base10VatAmount {get; private set;}
        public String base10Price {get; private set;}
        public String base3Rate {get; private set;}
        public String base3VatAmount {get; private set;}
        public String base3Price {get; private set;}
        public String suppliedPrice {get; private set;}
        public String total {get; private set;}
        public String defaultObservations {get; private set;}
        public String observations {get; private set;}        
    
        public PresupuestoCiasData(String language,String validityYear,String cliente,String newAcuerdoName, String logo,List<Moment> moments,String base21Rate, String base21VatAmount, String base21Price,
                                  String base10Rate, String base10VatAmount, String base10Price,String base3Rate, String base3VatAmount, String base3Price,String suppliedPrice, String total, String defaultObservations, String observations){
            this.language = language;
            this.validityYear=validityYear;
            this.cliente=cliente;
            this.newAcuerdoName=newAcuerdoName;
            this.logo=logo;
            this.moments=moments;
      		this.base21Rate=base21rate;
            this.base21VatAmount=base21VatAmount;
            this.base21Price=base21Price;
            this.base10Rate=base10rate;
            this.base10VatAmount=base10VatAmount;
            this.base10Price=base10Price;
            this.base3Rate=base3rate;
            this.base3VatAmount=base3VatAmount;
            this.base3Price=base3Price;
            this.suppliedPrice=suppliedPrice;
            this.total=total;
            this.defaultObservations=defaultObservations;
            this.observations=observations;
        }
    }
    public static String getFormattedAmountString(Decimal value) {
        
        String amountString = value.format();
        if (amountString.contains(',')) {
            Integer integerPlaces = amountString.indexOf(',');
            Integer decimalPlaces = amountString.length() - integerPlaces - 1;
            if (decimalPlaces == 1) {
                amountString += '0';
            }
        }
        else {
            amountString += ',00';
        }
        
        return amountString;
    }
}
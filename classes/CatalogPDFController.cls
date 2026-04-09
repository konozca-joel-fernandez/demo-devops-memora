public without sharing class CatalogPDFController {
    
    public class CatalogPDFControllerException extends Exception {} 
    
    public String validityYear {public get; private set;}
    public String sysdate {public get; private set;}
    public String logo {public get; private set;}
    public String catalogId {public get; private set;}
    public String accountId {public get; private set;}
    public String validityDate {public get; private set;}
    public String delegationId {public get; private set;}
    public String operationalZoneId {public get; private set;}
    public String operationalAreaId {public get; private set;}
    public String delegation {public get; private set;}
    public String operationalZone {public get; private set;}
    public String operationalArea {public get; private set;}
    public String centerId {public get; private set;}
    public String language {public get; private set;}
    Map<Id, Catalog> catalogMapAux = new Map<Id, Catalog>();
    public List<Catalog> catalogs {get; private set;}
    public List<Moment> moments {get; private set;}
    
    public CatalogPDFController() {

        sysdate = DateTime.now().format('dd/MM/yyyy HH:mm');
        logo = ApexPages.currentPage().getParameters().get('logo').escapeHtml4();
        if (String.isBlank(logo)) {
            logo = '/resource/MemoraLogo';
        }
        catalogId = ApexPages.currentPage().getParameters().get('catalogId').escapeHtml4();
        accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();
        validityDate = ApexPages.currentPage().getParameters().get('validityDate').escapeHtml4();
		delegationId = ApexPages.currentPage().getParameters().get('delegationId').escapeHtml4();
        operationalZoneId = ApexPages.currentPage().getParameters().get('operationalZoneId').escapeHtml4();
        operationalAreaId = ApexPages.currentPage().getParameters().get('operationalAreaId').escapeHtml4();
		delegation = ApexPages.currentPage().getParameters().get('delegation').escapeHtml4();
        operationalZone = ApexPages.currentPage().getParameters().get('operationalZone').escapeHtml4();
        operationalArea = ApexPages.currentPage().getParameters().get('operationalArea').escapeHtml4();
        centerId = ApexPages.currentPage().getParameters().get('centerId').escapeHtml4();
        language=ApexPages.currentPage().getParameters().get('language').escapeHtml4();
        validityYear=String.valueOf(Date.parse(validityDate).year());
        getCatalogs();
    }
    
    public void getCatalogs() {

        List<ONE_Catalogo_De_Precios__c> catalogRecords = new List<ONE_Catalogo_De_Precios__c>();
        
        if (String.isBlank(catalogId)) {

            List<ONE_Lugar__c> places = new List<ONE_Lugar__c>();
            if (String.isBlank(delegationId)) {
                places = [SELECT Id FROM ONE_Lugar__c];
            }
            else if (String.isBlank(operationalZoneId)) {
                places = [SELECT Id FROM ONE_Lugar__c
                        WHERE Id = :delegationId OR ONE_Lugar_Superior__c = :delegationId OR ONE_Lugar_Superior__r.ONE_Lugar_Superior__c = :delegationId];
            }
            else if (String.isBlank(operationalAreaId)) {
                places = [SELECT Id FROM ONE_Lugar__c
                        WHERE Id = :operationalZoneId OR ONE_Lugar_Superior__c = :operationalZoneId];
            }
            else {
                places = [SELECT Id FROM ONE_Lugar__c
                        WHERE Id = :operationalAreaId];
            }

            List<Account> accounts = new List<Account>();
            if (String.isBlank(accountId)) {
                accounts = [SELECT Id FROM Account
                            WHERE RecordType.DeveloperName = 'ONE_Otras_Cuentas'
                            AND ONE_Nivel_Jerarquia_Cuentas__c != null];
            }
            else {
                accounts = [SELECT Id FROM Account
                            WHERE Id = :accountId];
            }

            Date validityDateAux = Date.parse(validityDate);

            

            if (String.isBlank(centerId)) {
                catalogRecords = [
                    SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                    FROM ONE_Catalogo_De_Precios__c
                    WHERE ONE_Validez_Desde__c != null AND ONE_Compania__c != NULL 
                    AND ONE_Compania__c IN :accounts AND (ONE_Lugar__c IN :places OR ONE_Centro__r.ONE_Lugar__c IN :places) AND ONE_Validez_Desde__c <= :validityDateAux AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
                    ORDER BY Delegacion__c ASC, Zona_Operativa__c ASC, Area_Operativa__c ASC
                ];
            }
            else {
                catalogRecords = [
                    SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                    FROM ONE_Catalogo_De_Precios__c
                    WHERE ONE_Validez_Desde__c != null AND ONE_Compania__c != NULL
                    AND ONE_Compania__c IN :accounts AND ONE_Centro__c = :centerId AND ONE_Validez_Desde__c <= :validityDateAux AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
                    ORDER BY Delegacion__c ASC, Zona_Operativa__c ASC, Area_Operativa__c ASC
                ];
            }
        }
        else {
            catalogRecords = [
                SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                FROM ONE_Catalogo_De_Precios__c
                WHERE Id = :catalogId
            ];
        }

        Map<Id, Boolean> catalogIgicMap = new Map<Id, Boolean>();

        for (ONE_Catalogo_De_Precios__c catalogRecord : catalogRecords) {

            Boolean igic = (catalogRecord.ONE_Lugar__r.ONE_Tipo_De_Impuesto__c != null && catalogRecord.ONE_Lugar__r.ONE_Tipo_De_Impuesto__c == 'IGIC');
            catalogIgicMap.put(catalogRecord.Id, igic);
            String year = String.valueOf(catalogRecord.ONE_Validez_Desde__c.year());
            String centroName = catalogRecord.ONE_Centro__r.Name;
            String centroAddress = catalogRecord.ONE_Centro__r.ONE_Direccion__c;
            String centroPostalCode = catalogRecord.ONE_Centro__r.ONE_Codigo_Postal__c;
            String centroCity = catalogRecord.ONE_Centro__r.ONE_Municipio_Direccion__c;
            String centroProvince = catalogRecord.ONE_Centro__r.ONE_Provincia__c;
            String delegationName = '';
            String operationalZoneName = '';
            String operationalAreaName = '';
            if (catalogRecord.ONE_Lugar__r.ONE_Nivel_Jerarquico__c == 'delegacion') {
                delegationName = catalogRecord.ONE_Lugar__r.Name;
            }
            else if (catalogRecord.ONE_Lugar__r.ONE_Nivel_Jerarquico__c == 'zona_operativa') {
                delegationName = catalogRecord.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
                operationalZoneName = catalogRecord.ONE_Lugar__r.Name;
            }
            else if (catalogRecord.ONE_Lugar__r.ONE_Nivel_Jerarquico__c == 'area_operativa') {
                delegationName = catalogRecord.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name;
                operationalZoneName = catalogRecord.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
                operationalAreaName = catalogRecord.ONE_Lugar__r.Name;
            }
            Catalog catalog = new Catalog(catalogRecord.Name, year, catalogRecord.ONE_Compania__r.Name, delegationName, operationalZoneName, operationalAreaName, moments, centroName, centroAddress, centroPostalCode, centroCity, centroProvince);
            catalogMapAux.put(catalogRecord.Id, catalog);
        }
		
        Date validityDateAux = Date.parse(validityDate);
        Map<Id, List<ONE_Entrada_De_Precio__c>> catalogProductsMap = new Map<Id, List<ONE_Entrada_De_Precio__c>>();
        for (ONE_Entrada_De_Precio__c productForCatalog : [ SELECT ONE_Catalogo_De_Precios__c, ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name, ONE_Concepto_Comercial__r.ONE_Categoria__r.Name, ONE_Concepto_Comercial__r.ONE_Codigo_Comercial__c, ONE_Concepto_Comercial__r.Name, ONE_Precio__c, ONE_Concepto_Comercial__r.ONE_Tipo_Impositivo__c,ONE_Concepto_Comercial__r.ONE_Descripcion_En_Catalan__c,ONE_Concepto_Comercial__r.ONE_Descripcion_En_Euskera__c
                                                            FROM ONE_Entrada_De_Precio__c
                                                            WHERE ONE_Catalogo_De_Precios__c != null AND ONE_Catalogo_De_Precios__c IN :catalogMapAux.keySet() AND
                                                                  ONE_Vigente_Desde__c <= :validityDateAux AND (ONE_Vigente_Hasta__c >= :validityDateAux OR ONE_Vigente_Hasta__c = null)
                                                            ORDER BY
                                                                ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Orden__c ASC,
                                                                ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Orden__c ASC,
                                                                ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Orden__c ASC,
                                                                ONE_Concepto_Comercial__r.CreatedDate ASC])
        {
            List<ONE_Entrada_De_Precio__c> catalogProducts = catalogProductsMap.get(productForCatalog.ONE_Catalogo_De_Precios__c);
            if (catalogProducts == null) {
                catalogProducts = new List<ONE_Entrada_De_Precio__c>();
            }
            catalogProducts.add(productForCatalog);
            catalogProductsMap.put(productForCatalog.ONE_Catalogo_De_Precios__c, catalogProducts);
        }

        Map<Id, Map<String, List<ONE_Entrada_De_Precio__c>>> catalogMomentsMap = new Map<Id, Map<String, List<ONE_Entrada_De_Precio__c>>>();
        for (Id catalogId : catalogMapAux.keySet()) {

            if (catalogProductsMap.get(catalogId) != null) {

                Map<String, List<ONE_Entrada_De_Precio__c>> momentoProductMap = new Map<String, List<ONE_Entrada_De_Precio__c>>();
                for (ONE_Entrada_De_Precio__c productForCatalog : catalogProductsMap.get(catalogId)) {
                    
                    List<ONE_Entrada_De_Precio__c> products = momentoProductMap.get(productForCatalog.ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name);
                    if (products == null) {
                        products = new List<ONE_Entrada_De_Precio__c>();
                    }
                    products.add(productForCatalog);
                    momentoProductMap.put(productForCatalog.ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name, products);
                }
                catalogMomentsMap.put(catalogId, momentoProductMap);
            }
        }

        catalogs = new List<Catalog>();
        for (Id catalogId : catalogMomentsMap.keySet()) {
            List<Moment> moments = new List<Moment>();
            for (String momentName : catalogMomentsMap.get(catalogId).keySet()) {
                List<Product> products = new List<Product>();
                String productName;
                for (ONE_Entrada_De_Precio__c productForCatalog : catalogMomentsMap.get(catalogId).get(momentName)) {
                    if(language=='Catalan'){
                        productName=productForCatalog.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Catalan__c;
                    }else if(language=='Euskera'){
                        productName=productForCatalog.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Euskera__c;
                    }else{
                        productName=productForCatalog.ONE_Concepto_Comercial__r.Name;
                    }
                    Product product = new Product(  productForCatalog.ONE_Concepto_Comercial__r.ONE_Codigo_Comercial__c,
                                                    productName,
                                                    productForCatalog.ONE_Precio__c,
                                                    productForCatalog.ONE_Concepto_Comercial__r.ONE_Tipo_Impositivo__c,
                                                    catalogIgicMap.get(catalogId));
                    products.add(product);
                }
                Moment moment = new Moment(momentName, products);
                moments.add(moment);
            }
            Catalog catalog = catalogMapAux.get(catalogId);
            catalog.moments = moments;
            catalogs.add(catalog);
        }
    }
    
    public class Product {
    	public String code {public get; private set;}
        public String name {public get; private set;}
        public Decimal rate {public get; private set;}
        public String rateString {public get; private set;}
        public Decimal vatRate {public get; private set;}
        public String vatRateString {public get; private set;}
        public Decimal vatAmount {public get; private set;}
        public String vatAmountString {public get; private set;}
        public Decimal price {public get; private set;}
        public String priceString {public get; private set;}
        
        public Product(String code, String name, Decimal rate, String tipoImpositivo, Boolean igic) {
            this.code = code;
            this.name = name;
            this.rate = rate;
            
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
            
            this.rateString = getFormattedAmountString(this.rate);
            this.vatAmount = (this.rate * this.vatRate).setScale(2);
            this.price = this.rate + this.vatAmount;
            this.vatAmountString = getFormattedAmountString(this.vatAmount);
            this.priceString = getFormattedAmountString(this.price);
        }
    }

    public class Moment {
    	public String name {public get; private set;}
        public String nameUppercased {public get; private set;}
        public List<Product> products {public get; private set;}
        
        public Moment(String name, List<Product> products) {
            this.name = (name != null ? name : '');
            this.nameUppercased = this.name.toUpperCase();
            this.products = products;
        }
    }
    
    public class Catalog {
    	public String name {public get; private set;}
        public String year {public get; private set;}
        public String accountName {public get; private set;}
        public String delegation {public get; private set;}
        public String operationalZone {public get; private set;}
        public String operationalArea {public get; private set;}
        public String nameUppercased {public get; private set;}
        public String accountNameUppercased {public get; private set;}
        public String centerName {public get; private set;}
        public String centerAddress {public get; private set;}
        public String centerPostalCode {public get; private set;}
        public String centerCity {public get; private set;}
        public String centerProvince {public get; private set;}
        public List<Moment> moments {public get; private set;}
        
        public Catalog(String name, String year, String accountName, String delegationName, String operationalZoneName, String operationalAreaName, List<Moment> moments, String centerName, String centerAddress, String centerPostalCode, String centerCity, String centerProvince) {
            this.name = (name != null ? name : '');
            this.year = (year != null ? year : '');
            this.nameUppercased = this.name.toUpperCase();
            this.accountName = (accountName != null ? accountName : '');
            this.accountNameUppercased = this.accountName.toUpperCase();
            
            this.delegation = (delegationName != null ? delegationName : '');
            this.operationalZone = (operationalZoneName != null ? operationalZoneName : '');
            this.operationalArea = (operationalAreaName != null ? operationalAreaName : '');

            this.centerName = (centerName != null ? centerName : '');
            this.centerAddress = (centerAddress != null ? centerAddress : '');
            this.centerPostalCode = (centerPostalCode != null ? centerPostalCode : '');
            this.centerCity = (centerCity != null ? centerCity : '');
            this.centerProvince = (centerProvince != null ? centerProvince : '');

            this.moments = moments;
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
public class ONE_PDFCompaniasController {
 public class ONE_PDFCompaniasControllerException extends Exception {} 
    
    public String sysdate {public get; private set;}
    public String logo {public get; private set;}
    public String catalogo {public get; private set;}
    public String companias {public get; private set;}
    public String accountId {public get; private set;}
    public String accountNameForPdf {public get; private set;}
    public String validityDate {public get; private set;}
    public String delegationId {public get; private set;}
    public String operationalZoneId {public get; private set;}
    public String operationalAreaId {public get; private set;}
    public String delegation {public get; private set;}
    public String operationalZone {public get; private set;}
    public String operationalArea {public get; private set;}
    public String centerId {public get; private set;}
    Map<Id, Agreement> agreementMapAux = new Map<Id, Agreement>();
    Map<Id, Agreement> agreementMap = new Map<Id, Agreement>();
    Map<Id, Id> agreementPriceCatalogMap = new Map<Id, Id>();
    public List<Agreement> agreements {get; private set;}
    public List<Moment> moments {get; private set;}
    public List<String> status {get; private set;}
    
    public ONE_PDFCompaniasController() {
        sysdate = DateTime.now().format('dd/MM/yyyy HH:mm');
        logo = ApexPages.currentPage().getParameters().get('logo').escapeHtml4();
        if (String.isBlank(logo)) {
            logo = '/resource/MemoraLogo';
        }
        catalogo = ApexPages.currentPage().getParameters().get('catalogoId').escapeHtml4();
        accountNameForPdf = ApexPages.currentPage().getParameters().get('accountNameForPdf').escapeHtml4();
        validityDate = ApexPages.currentPage().getParameters().get('validityDate').escapeHtml4();
		delegationId = ApexPages.currentPage().getParameters().get('delegationId').escapeHtml4();
        operationalZoneId = ApexPages.currentPage().getParameters().get('operationalZoneId').escapeHtml4();
        operationalAreaId = ApexPages.currentPage().getParameters().get('operationalAreaId').escapeHtml4();
		delegation = ApexPages.currentPage().getParameters().get('delegation').escapeHtml4();
        operationalZone = ApexPages.currentPage().getParameters().get('operationalZone').escapeHtml4();
        operationalArea = ApexPages.currentPage().getParameters().get('operationalArea').escapeHtml4();
        centerId = ApexPages.currentPage().getParameters().get('centerId').escapeHtml4();
        companias = ApexPages.currentPage().getParameters().get('companias').escapeHtml4();
        System.debug('ValidityDate in AgreementPDFController'+validityDate);
        status = ApexPages.currentPage().getParameters().get('status').escapeHtml4().split(',');
        getAgreements();
         
    }  
    
    public void getAgreements() {

        List<ONE_Segmentacion_Acuerdo__c> agreementRecords = new List<ONE_Segmentacion_Acuerdo__c>();
        List<ONE_Catalogo_De_Precios__c> catalogos=new List<ONE_Catalogo_De_Precios__c>();

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
        List<String> companiasList = companias.split(';');
        List<Account> accounts =[SELECT Id FROM Account WHERE Id IN :companiasList];
        Date validityDateAux = Date.parse(validityDate);
        
        if (String.isBlank(centerId)) {
            if (accounts.size() < 0){
                catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                       FROM ONE_Catalogo_De_Precios__c 
                       WHERE ONE_Validez_Desde__c <= :validityDateAux 
                           AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
                           AND ONE_Validez_Desde__c != null 
                           AND ONE_Compania__c != NULL 
                           AND ONE_Compania__c IN :accounts 
                           AND (ONE_Lugar__c IN :places OR ONE_Centro__r.ONE_Lugar__c IN :places)
                           AND ONE_Estado__c IN :status];
            } else {
            	catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                       FROM ONE_Catalogo_De_Precios__c 
                       WHERE ONE_Validez_Desde__c <= :validityDateAux 
                           AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
                           AND ONE_Validez_Desde__c != null 
                           AND ONE_Compania__c != NULL
                           AND (ONE_Lugar__c IN :places OR ONE_Centro__r.ONE_Lugar__c IN :places)
                           AND ONE_Estado__c IN :status];   
            }
        } else {
            if (accounts.size() < 0){
                catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                       FROM ONE_Catalogo_De_Precios__c 
                       WHERE ONE_Validez_Desde__c <= :validityDateAux 
                           AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
                           AND ONE_Validez_Desde__c != null 
                           AND ONE_Compania__c IN :accounts 
                           AND ONE_Centro__c = :centerId 
                           AND ONE_Estado__c IN :status];
            } else {
                catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                       FROM ONE_Catalogo_De_Precios__c 
                       WHERE ONE_Validez_Desde__c <= :validityDateAux 
                           AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
                           AND ONE_Validez_Desde__c != null 
                           AND ONE_Compania__c != null
                           AND ONE_Centro__c = :centerId 
                           AND ONE_Estado__c IN :status];
            }
        }
        
        List<String> catalogosIds=new List<String>();
            for(ONE_Catalogo_De_Precios__c cat:catalogos){
                catalogosIds.add(cat.Id);
        }
        
        agreementRecords = [SELECT Name, ONE_Vigencia_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Catalogo_De_Precios__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), Observaciones__c, ONE_Ajuste_Necesario__c, ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                            FROM ONE_Segmentacion_Acuerdo__c
                            WHERE ONE_Vigencia_Desde__c <= :validityDateAux 
                            	AND (ONE_Vigencia_Hasta__c >= :validityDateAux OR ONE_Vigencia_Hasta__c = null) 
                            	AND ONE_No_Imprimir__c = false
                            	AND ONE_Vigencia_Desde__c != null 
                            	AND ONE_Compania__c != NULL 
                            	AND ONE_Catalogo_De_Precios__c =:catalogo];
            
        System.debug('Agreements records: '+agreementRecords);
        
        if (agreementRecords.isEmpty()) {
            throw new ONE_PDFCompaniasControllerException('No se han encontrado acuerdos.');
        }
    	List<ONE_Producto__c> adjustmentProductList = new List<ONE_Producto__c>();
        adjustmentProductList = [SELECT ONE_Codigo_Comercial__c, Name, ONE_Tipo_Impositivo__c
                                FROM ONE_Producto__c
                                WHERE ONE_Codigo_Comercial__c = '400001933'
                                LIMIT 1];

        Map<Id, Boolean> agreementIgicMap = new Map<Id, Boolean>();
        Date validityDateAux2 = Date.parse(validityDate);
        for (ONE_Segmentacion_Acuerdo__c agreementRecord : agreementRecords) {

            Boolean igic = (agreementRecord.ONE_Lugar__r.ONE_Tipo_De_Impuesto__c != null && agreementRecord.ONE_Lugar__r.ONE_Tipo_De_Impuesto__c == 'IGIC');
            agreementIgicMap.put(agreementRecord.Id, igic);
            String year = String.valueOf(validityDateAux2.year());
            String centroName = agreementRecord.ONE_Centro__r.Name;
            String centroAddress = agreementRecord.ONE_Centro__r.ONE_Direccion__c;
            String centroPostalCode = agreementRecord.ONE_Centro__r.ONE_Codigo_Postal__c;
            String centroCity = agreementRecord.ONE_Centro__r.ONE_Municipio_Direccion__c;
            String centroProvince = agreementRecord.ONE_Centro__r.ONE_Provincia__c;
            String delegationName = '';
            String operationalZoneName = '';
            String operationalAreaName = '';
            String accountName = '';
            String observations = String.isBlank(agreementRecord.Observaciones__c) ? 'Los precios de unidades de enterramiento, crematorios y tasas municipales están sujetas a las variaciones aprobadas por cada Ayuntamiento.' : agreementRecord.Observaciones__c.replace('\r\n', '<br/>').replace('\n', '<br/>');
            Decimal adjustment = agreementRecord.ONE_Ajuste_Necesario__c;
            if (agreementRecord.ONE_Lugar__r.ONE_Nivel_Jerarquico__c == 'delegacion') {
                delegationName = agreementRecord.ONE_Lugar__r.Name;
            }
            else if (agreementRecord.ONE_Lugar__r.ONE_Nivel_Jerarquico__c == 'zona_operativa') {
                delegationName = agreementRecord.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
                operationalZoneName = agreementRecord.ONE_Lugar__r.Name;
            }
            else if (agreementRecord.ONE_Lugar__r.ONE_Nivel_Jerarquico__c == 'area_operativa') {
                delegationName = agreementRecord.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name;
                operationalZoneName = agreementRecord.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
                operationalAreaName = agreementRecord.ONE_Lugar__r.Name;
            }
            if (String.isNotBlank(accountNameForPdf)) {
                accountName = accountNameForPdf;
            }
            else if (String.isNotBlank(agreementRecord.ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c)) {
                accountName = agreementRecord.ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c;
            }
            else {
                accountName = agreementRecord.ONE_Compania__r.Name;
            }
            Agreement agreement = new Agreement(agreementRecord.Name, year, accountName, delegationName, operationalZoneName, operationalAreaName, agreementRecord.ONE_Catalogo_De_Precios__c, null, null, null, null, null, null, null, null, null, null, null, null, observations, centroName, centroAddress, centroPostalCode, centroCity, centroProvince, adjustment);
            agreementMapAux.put(agreementRecord.Id, agreement);
            agreementPriceCatalogMap.put(agreementRecord.Id, agreementRecord.ONE_Catalogo_De_Precios__c);
        }
        System.debug('MAP with catalog: '+agreementPriceCatalogMap);
        Map<Id, Map<Id, Integer>> agreementProductsMap = new Map<Id, Map<Id, Integer>>();
        Map<Id, Map<Id, Boolean>> agreementProductsSuppliedMap = new Map<Id, Map<Id, Boolean>>();
        for (ONE_Segmentacion_De_Linea__c productForAgreement : [SELECT ONE_Producto__c, ONE_Unidades__c, ONE_Suplido__c, ONE_Segmentacion_Acuerdo__c
                                                                 FROM ONE_Segmentacion_De_Linea__c
                                                                 WHERE ONE_Segmentacion_Acuerdo__c IN :agreementMapAux.keySet()
                                                                     AND ONE_Segmentacion_Acuerdo__c != null
                                                                     AND ONE_Producto__c != null
                                                                     AND (ONE_Comportamiento__c = '01' OR (ONE_Comportamiento__c = '02' AND (ONE_Producto__r.Name LIKE 'AG.%' OR ONE_Producto__r.Name LIKE 'AG -%')))])
        {
            Map<Id, Integer> productUnitsMap;
            Map<Id, Boolean> productSuppliedMap;
            productUnitsMap = agreementProductsMap.get(productForAgreement.ONE_Segmentacion_Acuerdo__c);
            productSuppliedMap = agreementProductsSuppliedMap.get(productForAgreement.ONE_Segmentacion_Acuerdo__c);
            if (productUnitsMap == null) {
                productUnitsMap = new Map<Id, Integer>();
            }
            if (productSuppliedMap == null) {
                productSuppliedMap = new Map<Id, Boolean>();
            }
            productUnitsMap.put(productForAgreement.ONE_Producto__c, productForAgreement.ONE_Unidades__c != null ? Integer.valueOf(productForAgreement.ONE_Unidades__c) : 1);
            productSuppliedMap.put(productForAgreement.ONE_Producto__c, productForAgreement.ONE_Suplido__c);
            agreementProductsMap.put(productForAgreement.ONE_Segmentacion_Acuerdo__c, productUnitsMap);
            agreementProductsSuppliedMap.put(productForAgreement.ONE_Segmentacion_Acuerdo__c, productSuppliedMap);
        }
        System.debug('agreementProductsMap'+agreementProductsMap);
        Set<Id> priceCatalogIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        for (Id agreementId : agreementMapAux.keySet()) {

            Id priceCatalogId = agreementPriceCatalogMap.get(agreementId);
            Set<Id> agreementProductIds = agreementProductsMap.get(agreementId)?.keySet();

            if (priceCatalogId != null) {
                priceCatalogIds.add(priceCatalogId);
            }
            if (agreementProductIds != null) {
                productIds.addAll(agreementProductIds);
            }
        }
        System.debug('ValidityDate:'+validityDate);
        List<ONE_Entrada_De_Precio__c> priceEntries = [ SELECT Id, ONE_Catalogo_De_Precios__c, ONE_Momento__c, ONE_Concepto_Comercial__c, ONE_Concepto_Comercial__r.ONE_Codigo_Comercial__c, ONE_Concepto_Comercial__r.Name, ONE_Precio__c, ONE_Concepto_Comercial__r.ONE_Tipo_Impositivo__c
                                                        FROM ONE_Entrada_De_Precio__c
                                                        WHERE ONE_Catalogo_De_Precios__c IN :priceCatalogIds AND ONE_Concepto_Comercial__c IN :productIds 
                                                        AND ONE_Vigente_Desde__c <= :validityDateAux AND (ONE_Vigente_Hasta__c >= :validityDateAux OR ONE_Vigente_Hasta__c = null)  
                                                       ORDER BY
                                                            ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.ONE_Orden__c ASC,
                                                            ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Orden__c ASC,
                                                            ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Orden__c ASC,
                                                            ONE_Concepto_Comercial__r.CreatedDate ASC];
        System.debug('priceEntries'+priceEntries);

        for (Id agreementId : agreementMapAux.keySet()) {

            Id priceCatalogId = agreementPriceCatalogMap.get(agreementId);
            Set<Id> agreementProductIds = new Set<Id>();
            agreementProductIds = agreementProductsMap.get(agreementId)?.keySet();
            
            Agreement agreement = agreementMapAux.get(agreementId);
            
            Map<String, Moment> momentsMap = new Map<String, Moment>();
            
            String base21Rate;
            String base21VatAmount;
            String base21Price;
            String base10Rate;
            String base10VatAmount;
            String base10Price;
            String base3Rate;
            String base3VatAmount;
            String base3Price;
            String suppliedPrice;
            String total;
            String observations;
            Decimal base21RateDecimal = 0.00;
            Decimal base10RateDecimal = 0.00;
            Decimal base3RateDecimal = 0.00;
            Decimal suppliedPriceDecimal = 0.00;
            
            List<ONE_Entrada_De_Precio__c> agreementPriceEntries = new List<ONE_Entrada_De_Precio__c>();

            for (ONE_Entrada_De_Precio__c priceEntry: priceEntries) {

                if (priceEntry.ONE_Catalogo_De_Precios__c == priceCatalogId && agreementProductIds != null && agreementProductIds.contains(priceEntry.ONE_Concepto_Comercial__c)) {
                    agreementPriceEntries.add(priceEntry);
                }
            }

            for (ONE_Entrada_De_Precio__c priceEntry : agreementPriceEntries) {

                String momentName = priceEntry.ONE_Momento__c != null ? priceEntry.ONE_Momento__c : '';
                Integer units = agreementProductsMap.get(agreementId).get(priceEntry.ONE_Concepto_Comercial__c);
                Boolean supplied = agreementProductsSuppliedMap.get(agreementId).get(priceEntry.ONE_Concepto_Comercial__c);
                String taxRate;
                if (supplied) {
                    taxRate = 'Exento';
                    suppliedPriceDecimal += priceEntry.ONE_Precio__c * units;
                }
                else {
                    taxRate = priceEntry.ONE_Concepto_Comercial__r.ONE_Tipo_Impositivo__c;
                    switch on taxRate {
                        when 'Normal' {
                            if (agreementIgicMap.get(agreementId)) {
                                base3RateDecimal += priceEntry.ONE_Precio__c * units;
                            }
                            else {
                                base21RateDecimal += priceEntry.ONE_Precio__c * units;
                            }
                        }
                        when 'Reducido' {
                            if (agreementIgicMap.get(agreementId)) {
                                base3RateDecimal += priceEntry.ONE_Precio__c * units;
                            }
                            else {
                                base10RateDecimal += priceEntry.ONE_Precio__c * units;
                            }
                        }
                    }
                }
                List<Product> products;
                Moment moment = momentsMap.get(momentName);
                if (moment != null) {
                    moment.amount += (priceEntry.ONE_Precio__c * units).setScale(2);
                    products = moment.products;
                    products.add(new Product(priceEntry.ONE_Concepto_Comercial__r.ONE_Codigo_Comercial__c, priceEntry.ONE_Concepto_Comercial__r.Name, units, priceEntry.ONE_Precio__c.setScale(2), taxRate, supplied, agreementIgicMap.get(agreementId)));
                    moment = new Moment(momentName, moment.amount, products);
                    
                }
                else {
                    products = new List<Product>();
                    products.add(new Product(priceEntry.ONE_Concepto_Comercial__r.ONE_Codigo_Comercial__c, priceEntry.ONE_Concepto_Comercial__r.Name, units, priceEntry.ONE_Precio__c.setScale(2), taxRate, supplied, agreementIgicMap.get(agreementId)));
                    moment = new Moment(momentName, priceEntry.ONE_Precio__c * units, products);
                }
                momentsMap.put(momentName, moment);
            }
            
            Decimal adjustmentAmount = agreementMapAux?.get(agreementId)?.adjustment;
            if (adjustmentAmount != null && adjustmentAmount != 0 && !adjustmentProductList.isEmpty()) {

                ONE_Producto__c adjustmentProduct = adjustmentProductList.get(0);
                List<Product> adjustmentProducts = new List<Product>();
                adjustmentProducts.add(new Product(adjustmentProduct.ONE_Codigo_Comercial__c, adjustmentProduct.Name, 1, adjustmentAmount, adjustmentProduct.ONE_Tipo_Impositivo__c, false, agreementIgicMap.get(agreementId)));
                Moment moment = new Moment(' ', adjustmentAmount, adjustmentProducts);
                momentsMap.put(' ', moment);
                switch on adjustmentProduct.ONE_Tipo_Impositivo__c {
                    when 'Normal' {
                        if (agreementIgicMap.get(agreementId)) {
                            base3RateDecimal += adjustmentAmount;
                        }
                        else {
                            base21RateDecimal += adjustmentAmount;
                        }
                    }
                    when 'Reducido' {
                        if (agreementIgicMap.get(agreementId)) {
                            base3RateDecimal += adjustmentAmount;
                        }
                        else {
                            base10RateDecimal += adjustmentAmount;
                        }
                    }
                }
            }

            moments = momentsMap.values();
            
            base21Rate = getFormattedAmountString(base21RateDecimal);
            base21VatAmount = getFormattedAmountString((base21RateDecimal * 0.21).setScale(2));
            Decimal base21PriceDecimal = base21RateDecimal + (base21RateDecimal * 0.21).setScale(2);
            base21Price = getFormattedAmountString(base21PriceDecimal.setScale(2));
            base10Rate = getFormattedAmountString(base10RateDecimal.setScale(2));
            base10VatAmount = getFormattedAmountString((base10RateDecimal * 0.10).setScale(2));
            Decimal base10PriceDecimal = base10RateDecimal + (base10RateDecimal * 0.10).setScale(2);
            base10Price = getFormattedAmountString(base10PriceDecimal.setScale(2));
            base3Rate = getFormattedAmountString(base3RateDecimal.setScale(2));
            base3VatAmount = getFormattedAmountString((base3RateDecimal * 0.03).setScale(2));
            Decimal base3PriceDecimal = base3RateDecimal + (base3RateDecimal * 0.03).setScale(2);
            base3Price = getFormattedAmountString(base3PriceDecimal.setScale(2));
            suppliedPrice = getFormattedAmountString(suppliedPriceDecimal.setScale(2));
            total = getFormattedAmountString(base21PriceDecimal.setScale(2) + base10PriceDecimal.setScale(2) + base3PriceDecimal.setScale(2) + suppliedPriceDecimal.setScale(2));
        
        	agreement = new Agreement(agreement.name, agreement.year, agreement.accountName, agreement.delegation, agreement.operationalZone, agreement.operationalArea, agreement.priceCatalog, moments, base21Rate, base21VatAmount, base21Price, base10Rate, base10VatAmount, base10Price, base3Rate, base3VatAmount, base3Price, suppliedPrice, total, agreement.observations, agreement.centerName, agreement.centerAddress, agreement.centerPostalCode, agreement.centerCity, agreement.centerProvince, agreement.adjustment);
            agreementMap.put(agreementId, agreement);
            
            agreements = agreementMap.values();
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
        
        public Product(String code, String name, Integer units, Decimal unitRate, String tipoImpositivo, Boolean supplied, Boolean igic) {
            this.code = code;
            this.name = name;
            this.units = units != null ? units : 1;
            this.unitRate = unitRate;
            this.supplied = supplied;
            this.suppliedString = this.supplied ? 'Suplido' : '';
            
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
            
            this.rate = this.unitRate.setScale(2) * this.units;
            this.rateString = getFormattedAmountString(this.rate.setScale(2));
            this.vatAmount = (this.rate * this.vatRate).setScale(2);
            this.price = (this.rate + this.vatAmount).setScale(2);
            this.vatAmountString = getFormattedAmountString(this.vatAmount.setScale(2));
            this.priceString = getFormattedAmountString(this.price.setScale(2));
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
    
    public class Agreement {
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
        public Id place {public get; private set;}
        public Id priceCatalog {public get; private set;}
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
        public String observations {get; private set;}

        public Decimal adjustment {get; private set;}
        
        public Agreement(String name, String year, String accountName, String delegationName, String operationalZoneName, String operationalAreaName, Id priceCatalog, List<Moment> moments, String base21Rate, String base21VatAmount, String base21Price, String base10Rate, String base10VatAmount, String base10Price, String base3Rate, String base3VatAmount, String base3Price, String suppliedPrice, String total, String observations, String centerName, String centerAddress, String centerPostalCode, String centerCity, String centerProvince, Decimal adjustment) {
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
            
            this.place = place;
            this.priceCatalog = priceCatalog;
            this.moments = moments;
            
            this.base21Rate = base21Rate;
            this.base21VatAmount = base21VatAmount;
            this.base21Price = base21Price;
            this.base10Rate = base10Rate;
            this.base10VatAmount = base10VatAmount;
            this.base10Price = base10Price;
            this.base3Rate = base3Rate;
            this.base3VatAmount = base3VatAmount;
            this.base3Price = base3Price;
            this.suppliedPrice = suppliedPrice;
            this.total = total;
            this.observations = (observations != null ? observations : '');

            this.adjustment = adjustment;
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
public class ONE_CatalogoParticularPDFController {
	public class CatalogPDFControllerException extends Exception {} 
    
    //INPUTS
    public String catalogId {public get; private set;}
    public String sysdate {public get; private set;}
    
    public String validityYear {public get; private set;}
    public String validityDate {public get; private set;}
    
    public String delegationId {public get; private set;}
    public String operationalZoneId {public get; private set;}
    public String operationalAreaId {public get; private set;}
    public String delegation {public get; private set;}
    public String operationalZone {public get; private set;}
    public String operationalArea {public get; private set;}
    public String centerId {public get; private set;}
    
    public String logo {public get; private set;}
    
    public String language {public get; private set;}
    
    public Boolean showIDCol {public get; private set;}
    public Boolean showBasePriceCol {public get; private set;}
    public Boolean showTaxTypeCol {public get; private set;}
    
    public Boolean showColTitles {public get; private set;}
        
    public Boolean showGeneralConditions {public get; private set;}
    public String dateGeneralConditions {public get; private set;}
                
    //VARS
    Map<Id, Catalog> catalogMapAux = new Map<Id, Catalog>();
    public List<Catalog> catalogs {get; private set;}
    public List<Moment> moments {get; private set;}
    public List<String> titles {get; private set;}
    public List<String> columnSizes {get; private set;}
    public List<String> momentLogos {get; private set;}
    public Integer numberOfColumns {get; private set;}
    public List<String> generalConditions {get; private set;}
    
    public List<List<Moment>> momentMatrix {get; private set;}
    
    public ONE_CatalogoParticularPDFController() {
		
        catalogId = ApexPages.currentPage().getParameters().get('catalogId').escapeHtml4();
        sysdate = DateTime.now().format('dd/MM/yyyy HH:mm');
        
        validityDate = ApexPages.currentPage().getParameters().get('validityDate').escapeHtml4();
        validityYear = String.valueOf(Date.parse(validityDate).year());
        
        delegationId = ApexPages.currentPage().getParameters().get('delegationId').escapeHtml4();
        operationalZoneId = ApexPages.currentPage().getParameters().get('operationalZoneId').escapeHtml4();
        operationalAreaId = ApexPages.currentPage().getParameters().get('operationalAreaId').escapeHtml4();
		delegation = ApexPages.currentPage().getParameters().get('delegation').escapeHtml4();
        operationalZone = ApexPages.currentPage().getParameters().get('operationalZone').escapeHtml4();
        operationalArea = ApexPages.currentPage().getParameters().get('operationalArea').escapeHtml4();
        centerId = ApexPages.currentPage().getParameters().get('centerId').escapeHtml4();
        
        logo = ApexPages.currentPage().getParameters().get('logo').escapeHtml4();
        if (String.isBlank(logo)) {
            logo = '/resource/MemoraLogo';
        }
        
        language = ApexPages.currentPage().getParameters().get('language').escapeHtml4();      
        fillTitles(language);
        
        numberOfColumns = 2;
        showIDCol = ApexPages.currentPage().getParameters().get('showIDCol').escapeHtml4() == 'true';
        if (showIDCol) {numberOfColumns++;}
        showBasePriceCol = ApexPages.currentPage().getParameters().get('showBasePriceCol').escapeHtml4() == 'true';
        if (showBasePriceCol) {numberOfColumns++;}
        showTaxTypeCol = ApexPages.currentPage().getParameters().get('showTaxTypeCol').escapeHtml4() == 'true';
        if (showTaxTypeCol) {numberOfColumns++;}
        calulateColumnSizes();
        
        showColTitles = ApexPages.currentPage().getParameters().get('showColTitles').escapeHtml4() == 'true';
        
        showGeneralConditions = ApexPages.currentPage().getParameters().get('showGeneralConditions').escapeHtml4() == 'true';
        dateGeneralConditions = ApexPages.currentPage().getParameters().get('dateGeneralConditions').escapeHtml4();
        
        translateGeneralConditions();

        getCatalogs();
    }
    
    void fillTitles(string lang) {
        if (lang == 'Castellano') {
            this.titles = new List<String>{
                'CATALOGO DE PRECIOS', 
				'Cliente', 
                'ID', 
                'Nombre del Producto', 
                'P. Base', 
                'Tipo IVA/IGIC', 
                'PVP'};
        } else if (lang == 'Catalan') {
            this.titles = new List<String>{
                'CATALAG DE PREUS', 
                'Client', 
                'ID', 
                'Nom del Producte', 
                'P. Base', 
                'Tipus IVA/IGIC', 
                'PVP'};
        } else if (lang == 'Euskera'){
            this.titles = new List<String>{
                'CATALOGO DE PRECIOS EUS', 
                'Cliente EUS', 'ID EUS', 
                'Nombre del Producto EUS', 
                'P. Base EUS', 
                'Tipo IVA/IGIC EUS', 
                'PVP EUS'};
        }
    }
    
    void translateGeneralConditions(){
        switch on language {
            when 'Castellano' {
                generalConditions = new List<String>{
                    'CONDICIONES GENERALES',
                    'Este catálogo de precios incluye el Impuesto de Valor Añadido que establece la legislación vigente.',
                    'Este catálogo de precios es de aplicación a partir del día '+dateGeneralConditions+' y vigente hasta que no sea modificado.',
                    'Mémora se reserva el derecho de modificar estos servicios, incluir o eliminar conceptos así como modificar la cantidad de los mismos amb l’objectiu de millorar el servei.',
                    'Otros;',
                    'Catálogo de precios de las tasas de cementerio: se aplicarán a los catálogos de precios vigentes del cementerio correspondiente.',
                    'Catálogo de precios de les tasas de sanidad: se aplicarán a los catálogos de precios vigentes que dicte el Departamento de Salud.',
                    'Cualquier otra alternativa a consultar.'
                };
            }
            when 'Catalan' {
                generalConditions = new List<String>{
                    'CONDICIONS GENERALS',
                    'Aquest catàleg de preus inclou l’Impost del Valor Afegit que estableix la legislació vigent.',
                    'Aquest catàleg de preus es d’aplicació a partir del dia '+dateGeneralConditions+' i vigent fins que no sigui modificat.',
                    'Mémora es reserva el dret de modificar aquests serveis, incloure o eliminar conceptes així como modificar la cantidad de los mismos con el objetivo de mejorar el servicio.',
                    'Altres;',
                    'Catàleg de preus de les taxes de cementiri: s’aplicaran els catàlegs de preus vigents del cementiri corresponent.',
                    'Catàleg de preus de les taxes de sanitat: s’aplicaran els catàlegs de preus vigents que dicti el Departament de Salut.',
                    'Qualsevol altra alternativa consultar.'
                };
            }
            when 'Euskera' {
                generalConditions = new List<String>{
                    'BALDINTZA OROKORRAK',
                    'Prezioen katalogo honek indarrean dagoen legeriak ezarritako Balio Erantsiaren gaineko Zerga jasotzen du.',
                    'Prezio-katalogo hau '+dateGeneralConditions+' egunetik hasita dago aplikagarri eta baliozkoa da aldatzen den arte.',
                    'Mémorak eskubidea du zerbitzu hauek aldatzeko, kontzeptuak barneratzeko edo ezabatzeko eta haien kopurua aldatzeko, zerbitzua handitzeko helburuarekin.',
                    'Beste batzuk;',
                    'Hilerriko tasen prezioen katalogoa: dagokion hilerriko prezioen katalogoei aplikatuko zaizkie.',
                    'Osasun tasen prezioen katalogoa: Osasun Sailak igorritako egungo prezio katalogoetan aplikatuko dira.',
                    'Kontsultatzeko beste edozein alternatiba.'
                };
            }
        }
    }
    
    void calulateColumnSizes(){
        
        //spacer - ID - Name - Base Price - Tax Type - PVP
        
        columnSizes = new List<String>{'5%','15%','30%','15%','15%','15%','5%'};
        if(!showIDCol) {
            if(!showBasePriceCol) {
                if(!showTaxTypeCol) {
                    columnSizes = new List<String>{'5%','0%','60%','0%','0%','30%','5%'};
                } else {
                    columnSizes = new List<String>{'5%','0%','50%','0%','20%','20%','5%'};
                }
            } else {
                if(!showTaxTypeCol) {
                    columnSizes = new List<String>{'5%','0%','50%','20%','0%','20%','5%'};
                } else {
                    columnSizes = new List<String>{'5%','0%','45%','15%','15%','15%','5%'};
                }
            }
        } else {
            if(!showBasePriceCol) {
                if(!showTaxTypeCol) {
                    columnSizes = new List<String>{'5%','20%','50%','0%','0%','20%','5%'};
                } else {
                    columnSizes = new List<String>{'5%','15%','45%','0%','15%','15%','5%'};
                }
            } else {
                if(!showTaxTypeCol) {
                    columnSizes = new List<String>{'5%','15%','45%','15%','0%','15%','5%'};
                } 
            }
        }
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

            Date validityDateAux = Date.parse(validityDate);

            if (String.isBlank(centerId)) {
                catalogRecords = [
                    SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                    FROM ONE_Catalogo_De_Precios__c
                    WHERE ONE_Validez_Desde__c != null AND ONE_Compania__c = NULL AND ONE_Lugar__c != NULL
                    AND ONE_Lugar__c IN :places AND ONE_Validez_Desde__c <= :validityDateAux AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
                    ORDER BY Delegacion__c ASC, Zona_Operativa__c ASC, Area_Operativa__c ASC
                ];
            }
            else {
                catalogRecords = [
                    SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                    FROM ONE_Catalogo_De_Precios__c
                    WHERE ONE_Validez_Desde__c != null AND ONE_Compania__c = NULL AND ONE_Lugar__c != NULL
                    AND ONE_Lugar__c IN :places AND ONE_Centro__c = :centerId AND ONE_Validez_Desde__c <= :validityDateAux AND (ONE_Validez_Hasta__c >= :validityDateAux OR ONE_Validez_Hasta__c = null)
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
        for (ONE_Entrada_De_Precio__c productForCatalog : [ SELECT 
                                                           		ONE_Catalogo_De_Precios__c,
                                                           		ONE_Concepto_Comercial__r.ONE_Imprimible__c, 
                                                           		ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,
                                                           		ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                                                           		ONE_Concepto_Comercial__r.ONE_Categoria__r.Name, 
                                                           		ONE_Concepto_Comercial__r.ONE_Codigo_Comercial__c, 
                                                           		ONE_Concepto_Comercial__r.Name, ONE_Precio__c, 
                                                           		ONE_Concepto_Comercial__r.ONE_Tipo_Impositivo__c,
                                                           		ONE_Concepto_Comercial__r.ONE_Descripcion_En_Catalan__c,
                                                           		ONE_Concepto_Comercial__r.ONE_Descripcion_En_Euskera__c
                                                            FROM ONE_Entrada_De_Precio__c
                                                            WHERE ONE_Catalogo_De_Precios__c != null AND ONE_Concepto_Comercial__r.ONE_Imprimible__c=true AND ONE_Catalogo_De_Precios__c IN :catalogMapAux.keySet() AND 
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

        Map<String, List<String>> momentOrder = new Map<String, List<String>>{
            '1.Prestación del Servicio'+'%%'+
            '1.Prestació del servei'+'%%'+
            '1.Zerbitzua ematea' => new List<String>{'Prestación del servicio'},
            '2.Velatorio'+'%%'+
            '2.Vetlla'+'%%'+
            '2.Beila' => new List<String>{'Velatorio'},
            '3.Ceremonia'+'%%'+
            '3.Cerimònia'+'%%'+
            '3.Ekitaldia' => new List<String>{'Ceremonia'},
            '4.Comunicación'+'%%'+
            '4.Comunicació'+'%%'+
            '4.Komunikazioa' => new List<String>{'Comunicación'},
            '5.Arte Floral'+'%%'+
            '5.Art Floral'+'%%'+
            '5.Lore-artea' => new List<String>{'Arte Floral'},
            '6.1.Destino Final: Incineración/Inhumación/Traslado'+'%%'+
            '6.1.Destí Final: Incineració/Inhumació/Trasllat'+'%%'+
            '6.1.Azken Helmuga: Errausketa/Ehorzketa/Lekualdaketak' => new List<String>{'Destino Final Incineración%%Incineración%%D. final incineración concesiones', 'Destino final inhumación','Traslados'},
            '6.2.Destino Final Incineración: Urnas y Relicarios'+'%%'+
            '6.2.Destí Final Incineració: Urnes i relicaris'+'%%'+
            '6.2.Azken Helmugako Errausketa: Urnak eta Erlikuarioak' => new List<String>{'Destino Final Incineración%%Urnas%%Relicarios'},    
            '7.Servicios Post'+'%%'+
            '7.Serveis Post'+'%%'+
            '7.Posta zerbitzuak' => new List<String>{'Seguimos acompañándote'},
            '8.Productos del recuerdo'+'%%'+
            '8.Productes del record'+'%%'+
            '8.Oroitzapenaren produktuak' => new List<String>{'Productos del recuerdo'}
        };
            
        momentLogos = new List<String>{
            //prestación del servicio
            PageReference.forResource('IconoPrestacionDelServicio').getUrl(),
            //Velación
            PageReference.forResource('IconoVelacion').getUrl(),
			//Ceremonia
            PageReference.forResource('IconoCeremonia').getUrl(),
            //Comunicación
            PageReference.forResource('IconoComunicacion').getUrl(),
            //Arte Floral
            PageReference.forResource('IconoArteFloral').getUrl(),
            //Dest. Fin. Inh./Inc./Tras.
            PageReference.forResource('IconoDestinoFinal').getUrl(),
            //Dest. Fin. Urnas y Relicarios
            PageReference.forResource('IconoDestinoFinal').getUrl(),
            //Servicios Post
            PageReference.forResource('IconoServiciosPost').getUrl(),
            //Productos recuerdo
            PageReference.forResource('IconoProductosDelRecuerdo').getUrl()
        };
        
        catalogs = new List<Catalog>();
        for (Id catalogId : catalogMomentsMap.keySet()) {
            List<Moment> moments = new List<Moment>();
            Integer i = 0;
            for (String momentPDFName : momentOrder.keySet()) {
                Integer translateIndex = language == 'Catalan' ? 1 : language == 'Euskera' ? 2 : 0;
                String momentPDFNameTranslated = momentPDFName.split('%%')[translateIndex];
                for(String mo : momentOrder.get(momentPDFName)){
                    List<String> momentAgrupations = mo.split('%%');
                    String momentName = momentAgrupations[0];
                    momentAgrupations.remove(0);
                    List<Product> products = new List<Product>();
                 
                    String productName;
                    if(catalogMomentsMap.get(catalogId).containsKey(momentName)){
                        for (ONE_Entrada_De_Precio__c productForCatalog : catalogMomentsMap.get(catalogId).get(momentName)) {
                            if(momentAgrupations.size() > 0 && !momentAgrupations.contains(productForCatalog.ONE_Concepto_Comercial__r.ONE_Categoria__r.ONE_Agrupacion__r.Name)){
                                //do nothing
                            } else {
                                if(language == 'Catalan' && productForCatalog.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Catalan__c != null){
                                    productName = productForCatalog.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Catalan__c;
                                }else if(language == 'Euskera' && productForCatalog.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Euskera__c != null){
                                    productName = productForCatalog.ONE_Concepto_Comercial__r.ONE_Descripcion_En_Euskera__c;
                                }else{
                                    productName  =productForCatalog.ONE_Concepto_Comercial__r.Name;
                                }
                                Product product = new Product(  productForCatalog.ONE_Concepto_Comercial__r.ONE_Codigo_Comercial__c,
                                                              productName,
                                                              productForCatalog.ONE_Precio__c,
                                                              productForCatalog.ONE_Concepto_Comercial__r.ONE_Tipo_Impositivo__c,
                                                              catalogIgicMap.get(catalogId));
                                products.add(product);
                            }
                        }
                    
                        if (products.size() > 0){
                           Moment moment = new Moment(momentPDFNameTranslated, products, momentLogos[i]);
                        	moments.add(moment); 
                        }                        
                    }
            	}
                ++i;
            }
            Catalog catalog = catalogMapAux.get(catalogId);
            catalog.moments = moments;
            catalogs.add(catalog);
            
            momentMatrix = new List<List<Moment>>{new List<Moment>(), new List<Moment>(), new List<Moment>()};
            Decimal nCols = 3;
            integer ind = 0;
            Decimal ceil = Math.ceil(catalog.moments.size() / nCols);
            
            System.debug('S: ' + catalog.moments.size() + ' nCols: ' + nCols + ' => div: ' + catalog.moments.size() / nCols + 'ceil: ' + Math.ceil(catalog.moments.size() / nCols) + '; floor: ' + Math.floor(catalog.moments.size() / nCols));
            
            for(Moment m : catalog.moments){
                
                if (ind < ceil){
                    momentMatrix[0].add(m);
                } else if (ind < 2 * ceil) {
                    momentMatrix[1].add(m);
                } else {
                    momentMatrix[2].add(m);
                }
                ++ind;
            }
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
            if(this.rate!=null){
                this.rateString = getFormattedAmountString(this.rate);
                this.vatAmount = (this.rate * this.vatRate).setScale(2);
                this.price = this.rate + this.vatAmount;
                this.vatAmountString = getFormattedAmountString(this.vatAmount);
                this.priceString = getFormattedAmountString(this.price);
            }else{
                this.rateString ='';
                this.vatAmount =null;
                this.price = null;
                this.vatAmountString ='';
                this.priceString = '';
            }
           
        }
    }

    public class Moment {
    	public String name {public get; private set;}
        public String nameUppercased {public get; private set;}
        public List<Product> products {public get; private set;}
        public String momentLogo {public get; private set;}
        
        public Moment(String name, List<Product> products, String momentLogo) {
            this.name = (name != null ? name : '');
            this.nameUppercased = this.name.toUpperCase();
            this.products = products;
            this.momentLogo = momentLogo;
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
/*
 * PRICING WEB SERVICE
 */
@RestResource(UrlMapping='/pricing')
global with sharing class ONE_PricingWebService {

    global static final String ERR_NO_PARAMETER = 'Parameter {0} or {1} is missing!';
    global static final String ERR_EXPEDIENTE_NOT_FOUND = 'Service not found!';
    global static final String ERR_PRESUPUESTO_NOT_FOUND = 'Quote not found!';
    global static final Integer ERR_CODE_NO_PARAMETER = 400;
    global static final Integer ERR_CODE_NOTFOUND = 404;

    global static final String PARAM_SERVICEID = 'serviceId';
    global static final String PARAM_QUOTEID = 'quoteId';
    
    global static Map<Id, ONE_Imagen__c> centerPDFs;

    @HttpGet
    global static void getPricing() {
        String serviceId = RestContext.request.params.get(PARAM_SERVICEID);
        String quoteId = RestContext.request.params.get(PARAM_QUOTEID);
        WebServiceError error;

        if(serviceId == null || serviceId == '' || quoteId == null || quoteId == '') {
            error = new WebServiceError(ERR_CODE_NO_PARAMETER, String.format(ERR_NO_PARAMETER, new List<String> { PARAM_SERVICEID, PARAM_QUOTEID }));
        } else {

            ONE_Expediente__c expediente = [
                SELECT 
                    Id, 
                    Name, 
                    ONE_Catalogo_De_Precios__c, 
                    ONE_Catalogo_De_Precios_Acuerdo__c, 
                    ONE_Segmento_Seleccionado__c, 
                    ONE_Centro_Del_Expediente__c,
                    ONE_Acuerdo_Comercial__c
                FROM ONE_Expediente__c
                WHERE Id =: serviceId
                LIMIT 1
            ];

            ONE_Presupuesto__c presupuesto = [
                SELECT 
                    Id, 
                    CreatedDate,
                    ONE_Expediente__c,
                    ONE_precios_creaci_n_presupuesto_APP__c,
                    ONE_Tipo_De_Contrato__c
                FROM ONE_Presupuesto__c
                WHERE Id =: quoteId
                LIMIT 1
            ];
            if(expediente != null){
                if (presupuesto != null && presupuesto.ONE_Expediente__c == expediente.Id) {
                    fillCenterPDFs(expediente);

                    PricingObject po;
                    if(isCompanyService(expediente) && presupuesto.ONE_Tipo_De_Contrato__c != 'Particular') {
                        po = handleCompanyService(expediente, presupuesto);
                    } else {
                        po = handleOtherService(expediente, presupuesto);
                    }

                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(po, false));

                } else {
                    error = new WebServiceError(ERR_CODE_NOTFOUND, ERR_PRESUPUESTO_NOT_FOUND);
                }
            } else {
                error = new WebServiceError(ERR_CODE_NOTFOUND, ERR_EXPEDIENTE_NOT_FOUND);
            }
        }

        if(error != null) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(error.message);
            RestContext.response.statusCode = error.status;
            return;
        }
    }

    private static void fillCenterPDFs(ONE_Expediente__c expediente){
        Set<Id> productIds = new Set<Id>();
        
        for (ONE_Entrada_De_Precio__c e : [
            SELECT ONE_Concepto_Comercial__c 
            FROM ONE_Entrada_De_Precio__c 
            WHERE ONE_Activo_Vigencia__c = true AND
                  (ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios_Acuerdo__c OR 
                   ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios__c)
        ]) {
            productIds.add(e.ONE_Concepto_Comercial__c);
        }
        centerPDFs = new Map<Id, ONE_Imagen__c>();
        for (ONE_Imagen__c doc : [
            						SELECT Id, ONE_Producto__c, ONE_URL_Imagen__c
                                    FROM ONE_Imagen__c
                                    WHERE RecordType.Name = 'Documento' AND ONE_Producto__c IN :productIds
                                 ]){
         	centerPDFs.put(doc.ONE_Producto__c, doc);
        }    
    }

    private static Boolean isCompanyService(ONE_Expediente__c expediente){
        return
            expediente.ONE_Catalogo_De_Precios__c != null &&
            expediente.ONE_Catalogo_De_Precios_Acuerdo__c != null &&
            expediente.ONE_Acuerdo_Comercial__c != null
        ;
    }



    private static Map<Id, List<ONE_Entrada_De_Precio__c>> buildProductsWithEntradas(
        Map<Id, ONE_Entrada_De_Precio__c> entradasDePrecioId2EntradaRecord,
        Map<Id, ONE_Entrada_De_Precio__c> entradasDePrecioAcuerdoId2EntradaRecord
    ) {
        Map<String, List<ONE_Entrada_De_Precio__c>> productId2Entradas = new Map<String, List<ONE_Entrada_De_Precio__c>>();

        for(ONE_Entrada_De_Precio__c entrada : entradasDePrecioId2EntradaRecord.values()) {
            if(!productId2Entradas.containsKey(entrada.ONE_Concepto_Comercial__c)) {
                productId2Entradas.put(entrada.ONE_Concepto_Comercial__c, new List<ONE_Entrada_De_Precio__c> { entrada });
            } else {
                productId2Entradas.get(entrada.ONE_Concepto_Comercial__c).add(entrada);
            }
        }

        for(ONE_Entrada_De_Precio__c entrada : entradasDePrecioAcuerdoId2EntradaRecord.values()) {
            if(!productId2Entradas.containsKey(entrada.ONE_Concepto_Comercial__c)) {
                productId2Entradas.put(entrada.ONE_Concepto_Comercial__c, new List<ONE_Entrada_De_Precio__c> { entrada });
            } else {
                productId2Entradas.get(entrada.ONE_Concepto_Comercial__c).add(entrada);
            }
        }

        Map<Id, List<ONE_Entrada_De_Precio__c>> prodId2Entrada = new Map<Id, List<ONE_Entrada_De_Precio__c>>();

        List<ONE_Producto__c> allProducts = [
            SELECT Id, (
                SELECT Id, ONE_Producto_Incluido__c, ONE_Tipo_De_Relacion__c
                FROM Relaciones_de_productos__r
                WHERE ONE_Tipo_De_Relacion__c = 'Agrupación' OR 
                      ONE_Tipo_De_Relacion__c = 'Pack'
            )
            FROM ONE_Producto__c
            WHERE Id IN: productId2Entradas.keySet()
        ];

        for(ONE_Producto__c prod : allProducts) {
            if(!prod.Relaciones_de_productos__r.isEmpty()) {
                Boolean isPack = false;
                for(ONE_Relacion_De_Productos__c rel : prod.Relaciones_de_productos__r) {
                    if(prodId2Entrada.containsKey(rel.ONE_Producto_Incluido__c) && rel.ONE_Tipo_De_Relacion__c != 'Pack') {
                        //prod.Id ?? y no rel.ONE_Producto_Incluido__c
                        prodId2Entrada.get(rel.ONE_Producto_Incluido__c).addAll(productId2Entradas.get(prod.Id));
                    } else {
                        //prod.Id ?? y no rel.ONE_Producto_Incluido__c
                        if (rel.ONE_Tipo_De_Relacion__c != 'Pack') {
                            prodId2Entrada.put(rel.ONE_Producto_Incluido__c, productId2Entradas.get(prod.Id));
                        }
                        else{
                            if(productId2Entradas.get(rel.ONE_Producto_Incluido__c) == null) prodId2Entrada.put(rel.ONE_Producto_Incluido__c, null);
                            isPack = true;
                        }
                    }
                }
                if(isPack){
                    if(prodId2Entrada.containsKey(prod.Id)) {
                        prodId2Entrada.get(prod.Id).addAll(productId2Entradas.get(prod.Id));
                    } else {
                        prodId2Entrada.put(prod.Id, productId2Entradas.get(prod.Id));
                    }
                }
            } else {
                if(prodId2Entrada.containsKey(prod.Id)) {
                    prodId2Entrada.get(prod.Id).addAll(productId2Entradas.get(prod.Id));
                } else {
                    prodId2Entrada.put(prod.Id, productId2Entradas.get(prod.Id));
                }
            }
        }
        return prodId2Entrada;
    }

    private static Map<String, ONE_Segmentacion_De_Linea__c> buildProductsWithComportamiento(ONE_Expediente__c expedient) {
        Map<String, ONE_Segmentacion_De_Linea__c> productId2Segmentacion = new Map<String, ONE_Segmentacion_De_Linea__c>();

        for(ONE_Segmentacion_De_Linea__c seg : [
            SELECT Id, ONE_Producto__c, ONE_Segmentacion_Acuerdo__c, ONE_Comportamiento__c, ONE_Unidades__c
            FROM ONE_Segmentacion_De_Linea__c
            WHERE  ONE_Segmentacion_Acuerdo__c =: expedient.ONE_Segmento_Seleccionado__c
                OR ONE_Segmentacion_Acuerdo__c =: expedient.ONE_Acuerdo_Comercial__c
        ]) {
            if(expedient.ONE_Acuerdo_Comercial__c != null) {
                if(seg.ONE_Segmentacion_Acuerdo__c != expedient.ONE_Acuerdo_Comercial__c) {
                    continue;
                } else {
                    productId2Segmentacion.put(seg.ONE_Producto__c, seg);
                }
            } else {
                productId2Segmentacion.put(seg.ONE_Producto__c, seg);
            }
        }

        List<ONE_Producto__c> allProducts = [
            SELECT Id, (
                SELECT Id, ONE_Producto_Incluido__c, ONE_Tipo_De_Relacion__c, ONE_Preseleccionado_Agrupacion__c
                FROM Relaciones_de_productos__r
                WHERE ONE_Tipo_De_Relacion__c = 'Agrupación'
            )
            FROM ONE_Producto__c
            WHERE Id IN: productId2Segmentacion.keySet()
        ];

        Map<String, ONE_Segmentacion_De_Linea__c> prodId2Comportamiento = new Map<String, ONE_Segmentacion_De_Linea__c>();

        for(ONE_Producto__c prod : allProducts) {
            if(!prod.Relaciones_de_productos__r.isEmpty()) {
                for(ONE_Relacion_De_Productos__c rel : prod.Relaciones_de_productos__r) {
                    if(rel.ONE_Preseleccionado_Agrupacion__c) {
                        prodId2Comportamiento.put(rel.ONE_Producto_Incluido__c, new ONE_Segmentacion_De_Linea__c(ONE_Comportamiento__c = '01'));
                    } else {
                        prodId2Comportamiento.put(rel.ONE_Producto_Incluido__c, productId2Segmentacion.get(prod.Id));
                    }
                }
            } else {
                prodId2Comportamiento.put(prod.Id, productId2Segmentacion.get(prod.Id));
            }
        }
        return prodId2Comportamiento;
    }

    private static Map<Id, List<ONE_Modelo__c>> buildProductsWithModels(ONE_Expediente__c expedient, List<ONE_Entrada_De_Precio__c> entradaDePrecios) {

        Map<Id, List<ONE_Modelo__c>> productId2EntradaModelos = new Map<Id, List<ONE_Modelo__c>>();
        Map<Id, List<ONE_Entrada_De_Modelo__c>> productId2EntradaModelosExceptions = new Map<Id, List<ONE_Entrada_De_Modelo__c>>();

        for (ONE_Entrada_De_Modelo__c exc : [
            SELECT Id, ONE_Producto__c, ONE_Modelo__r.ONE_Nombre_ESP__c, ONE_Modelo__r.ONE_Nombre_CAT__c, ONE_Modelo__r.ONE_Nombre_EUS__c, ONE_Modelo__r.ONE_Modelo_por_defecto__c
            FROM ONE_Entrada_De_Modelo__c
            WHERE ONE_Catalogo_De_Precios__c =: expedient.ONE_Catalogo_De_Precios__c
                OR ONE_Catalogo_De_Precios__c =: expedient.ONE_Catalogo_De_Precios_Acuerdo__c
        ]) {
            if(!productId2EntradaModelosExceptions.containsKey(exc.ONE_Producto__c)) {
                productId2EntradaModelosExceptions.put(exc.ONE_Producto__c, new List<ONE_Entrada_De_Modelo__c> {exc});
            } else {
                productId2EntradaModelosExceptions.get(exc.ONE_Producto__c).add(exc);
            }
        }

        Set<Id> allProds = new Set<Id>();

        for(ONE_Entrada_De_Precio__c entradaDePrecio : entradaDePrecios) {
            allProds.add(entradaDePrecio.ONE_Concepto_Comercial__c);
        }

        List<ONE_Producto__c> allProducts = [
            SELECT Id, (
                SELECT Id, ONE_Producto_Incluido__c, ONE_Tipo_De_Relacion__c
                FROM Relaciones_de_productos__r
                WHERE ONE_Tipo_De_Relacion__c = 'Agrupación'
            )
            FROM ONE_Producto__c
            WHERE Id IN: allProds
        ];

        Set<ID> allProdsWithoutGroups = new Set<ID>();
        for(ONE_Producto__c prod : allProducts) {
            if(!prod.Relaciones_de_productos__r.isEmpty()) {
                for(ONE_Relacion_De_Productos__c rel : prod.Relaciones_de_productos__r) {
                    allProdsWithoutGroups.add(rel.ONE_Producto_Incluido__c);
                }
            } else {
                allProdsWithoutGroups.add(prod.Id);
            }
        }

        for(ONE_Producto__c prod : [
            SELECT Id,
            (
                SELECT Id, ONE_Nombre_ESP__c, ONE_Nombre_CAT__c, ONE_Nombre_EUS__c, ONE_Modelo_por_defecto__c
                FROM Modelos__r
            )
            FROM ONE_Producto__c
            WHERE Id IN: allProdsWithoutGroups
        ]) {
            if(!productId2EntradaModelos.containsKey(prod.Id)) {
                productId2EntradaModelos.put(prod.Id, new List<ONE_Modelo__c>(prod.Modelos__r));
            } else {
                productId2EntradaModelos.get(prod.Id).addAll(prod.Modelos__r);
            }
        }

        for(Id keyId : productId2EntradaModelosExceptions.keySet()) {
            List<ONE_Modelo__c> modelos = new List<ONE_Modelo__c>();
            for(ONE_Entrada_De_Modelo__c entradaModelo : productId2EntradaModelosExceptions.get(keyId)) {
                modelos.add(entradaModelo.ONE_Modelo__r);
            }
            productId2EntradaModelos.put(keyId, modelos);
        }

        return productId2EntradaModelos;
    }

    private static PricingObject handleCompanyService(ONE_Expediente__c expediente, ONE_Presupuesto__c presupuesto) {
        System.debug('handleCompanyService');
        Map<Id, ONE_Entrada_De_Precio__c> entradasDePrecioId2EntradaRecord;
        Map<Id, ONE_Entrada_De_Precio__c> entradasDePrecioAcuerdoId2EntradaRecord;
        
        date quoteCreationDate = date.newinstance(presupuesto.CreatedDate.year(), presupuesto.CreatedDate.month(), presupuesto.CreatedDate.day());

        //System.debug('HCS - select entradas');
        if (presupuesto.ONE_precios_creaci_n_presupuesto_APP__c) {
            entradasDePrecioId2EntradaRecord = new Map<Id, ONE_Entrada_De_Precio__c>([
                SELECT Id, ONE_Concepto_Comercial__c, ONE_Precio__c, ONE_Concepto_Comercial__r.Name
                FROM ONE_Entrada_De_Precio__c
                WHERE ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios__c
                		AND
                    ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios__c
                		AND 
            		ONE_Vigente_Desde__c <= :quoteCreationDate
            			AND 
                    (ONE_Vigente_Hasta__c >= :quoteCreationDate
                        OR 
                     ONE_Vigente_Hasta_Relleno__c = false)
            ]);

            entradasDePrecioAcuerdoId2EntradaRecord = new Map<Id, ONE_Entrada_De_Precio__c>([
                SELECT Id, ONE_Concepto_Comercial__c, ONE_Precio__c, ONE_Concepto_Comercial__r.Name
                FROM ONE_Entrada_De_Precio__c
                WHERE ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios_Acuerdo__c
                		AND
                    ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios__c
                		AND 
            		ONE_Vigente_Desde__c <= :quoteCreationDate
            			AND 
                    (ONE_Vigente_Hasta__c >= :quoteCreationDate
                        OR 
                     ONE_Vigente_Hasta_Relleno__c = false)
            ]);
        } else {
            entradasDePrecioId2EntradaRecord = new Map<Id, ONE_Entrada_De_Precio__c>([
                SELECT Id, ONE_Concepto_Comercial__c, ONE_Precio__c, ONE_Concepto_Comercial__r.Name
                FROM ONE_Entrada_De_Precio__c
                WHERE ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios__c
                    AND ONE_Activo_Vigencia__c = TRUE
            ]);

            entradasDePrecioAcuerdoId2EntradaRecord = new Map<Id, ONE_Entrada_De_Precio__c>([
                SELECT Id, ONE_Concepto_Comercial__c, ONE_Precio__c, ONE_Concepto_Comercial__r.Name
                FROM ONE_Entrada_De_Precio__c
                WHERE ONE_Catalogo_De_Precios__c = :expediente.ONE_Catalogo_De_Precios_Acuerdo__c
                    AND ONE_Activo_Vigencia__c = TRUE
            ]);
        }

        List<ONE_Entrada_De_Precio__c> allEntradaDePrecios = new List<ONE_Entrada_De_Precio__c>();
        allEntradaDePrecios.addAll(entradasDePrecioId2EntradaRecord.values());
        allEntradaDePrecios.addAll(entradasDePrecioAcuerdoId2EntradaRecord.values());

        Set<Id> productIdsWithEntrada = new Set<Id>();
        for(ONE_Entrada_De_Precio__c ent : allEntradaDePrecios){
            productIdsWithEntrada.add(ent.ONE_Concepto_Comercial__c);
            //System.debug('HCS - ent ' + ent.ONE_Concepto_Comercial__c + ' ' + ent.ONE_Concepto_Comercial__r.Name);
        }

        Map<Id, List<ONE_Entrada_De_Precio__c>> prodId2Entrada = buildProductsWithEntradas(entradasDePrecioId2EntradaRecord, entradasDePrecioAcuerdoId2EntradaRecord);
        
        Map<String, ONE_Segmentacion_De_Linea__c> productId2Comportamiento = buildProductsWithComportamiento(expediente);
        Map<Id, List<ONE_Modelo__c>> productId2EntradaModelos = buildProductsWithModels(expediente, allEntradaDePrecios);

        List<Producto> products = new List<Producto>();

        //System.debug('HSC --------------- ');
        for(Id productId : prodId2Entrada.keySet()) {
            //System.debug('HSC >>>>>> ');
            //System.debug('HSC - ' + prodId2Entrada.get(productId));
            List<ONE_Entrada_De_Precio__c> entradas = prodId2Entrada.get(productId);

            List<Price> particularPrices = new List<Price>();
            List<Price> companyPrices = new List<Price>();
			
            if (entradas != null){
                //por cada entrada para el producto
                for(ONE_Entrada_De_Precio__c entrada : entradas) {
                    //Si tiene modelos
                    System.debug('HSC - ' + entrada);
                    List<ONE_Modelo__c> models = productId2EntradaModelos.get(productId);
    
                    List<Model> modelsToDTO = new List<Model>();
                    if(models != null) {
                        System.debug('HSC - ent w/ models' + models);
                        for(ONE_Modelo__c model : models) {
                            modelsToDTO.add(new Model(
                                model.Id,
                                model.ONE_Nombre_ESP__c,
                                model.ONE_Nombre_CAT__c,
                                model.ONE_Nombre_EUS__c,
                                model.ONE_Modelo_por_defecto__c
                            ));
                        }
                    }
                    
                    //precio de la entrada
                    Price pr = new Price(
                        entrada.Id,
                        String.valueOf(entrada.ONE_Precio__c) + ' EUR',
                        modelsToDTO
                    );
                    //System.debug('HSC - price ' + pr);
    
                    //entrada particular
                    if(entradasDePrecioId2EntradaRecord.containsKey(entrada.Id)) {
                        particularPrices.add(pr);
                        //System.debug('HSC - particular ');
                    }
    
                    //entrada de acuerdo
                    if(entradasDePrecioAcuerdoId2EntradaRecord.containsKey(entrada.Id)) {
                        companyPrices.add(pr);
                        //System.debug('HSC - acuerdo ');
                    }
                }
            }

            Producto prod = new Producto(
                productId,
                companyPrices,
                particularPrices,
                productId2Comportamiento.get(productId)?.ONE_Comportamiento__c,
                centerPDFs.containsKey(productId) ? centerPDFs.get(productId).ONE_URL_Imagen__c : ''
            );
            if(productId2Comportamiento.get(productId)?.ONE_Comportamiento__c == '01') {
                Decimal unidades = productId2Comportamiento.get(productId)?.ONE_Unidades__c != null ? productId2Comportamiento.get(productId).ONE_Unidades__c : 1;
                for(Integer i = 0; i < Integer.valueOf(unidades); i++) {
                    products.add(prod);
                }
            } else {
                products.add(prod);
            }
        }

        String seg = expediente.ONE_Segmento_Seleccionado__c != null ? expediente.ONE_Segmento_Seleccionado__c : expediente.ONE_Acuerdo_Comercial__c;
        if(seg != null && seg != '') {
            List<ONE_Producto__c> adjustProd = [
                SELECT Id FROM ONE_Producto__c WHERE ONE_Codigo_Comercial__c = '400001933'
            ];

            List<ONE_Segmentacion_Acuerdo__c> adjustSeg  = [
                SELECT Id, ONE_Ajuste_Necesario__c FROM ONE_Segmentacion_Acuerdo__c WHERE Id =: seg
            ];

            if(adjustSeg[0].ONE_Ajuste_Necesario__c != 0 && adjustSeg[0].ONE_Ajuste_Necesario__c != null) {
                Price adjustPrice = new Price(
                    '',
                    String.valueOf(adjustSeg[0].ONE_Ajuste_Necesario__c),
                    new List<Model>()
                );

                Producto adjustProdDTO = new Producto(
                    adjustProd[0].Id,
                    new List<Price> { adjustPrice },
                    new List<Price>(),
                    '01',
                    centerPDFs.containsKey(adjustProd[0].Id) ? centerPDFs.get(adjustProd[0].Id).ONE_URL_Imagen__c : ''
                );
                products.add(adjustProdDTO);
            }
        }

        PricingObject PO = new PricingObject(
            expediente.Id,
            expediente.Name,
            expediente.ONE_Catalogo_De_Precios__c,
            expediente.ONE_Catalogo_De_Precios_Acuerdo__c,
            seg,
            expediente.ONE_Acuerdo_Comercial__c,
            products
        );

        return PO;
    }

    private static PricingObject handleOtherService(ONE_Expediente__c expedient, ONE_Presupuesto__c presupuesto) {
        //fetch particular products and prices
        Map<Id, ONE_Entrada_De_Precio__c> entradasDePreciosentradaId2EntradaRecord = new Map<Id, ONE_Entrada_De_Precio__c>([
            SELECT Id, ONE_Concepto_Comercial__c, ONE_Precio__c
            FROM ONE_Entrada_De_Precio__c
            WHERE ONE_Catalogo_De_Precios__c =: expedient.ONE_Catalogo_De_Precios__c
                AND ONE_Activo_Vigencia__c = TRUE
        ]);

        List<ONE_Entrada_De_Precio__c> allEntradaDePrecios = new List<ONE_Entrada_De_Precio__c>();
        allEntradaDePrecios.addAll(entradasDePreciosentradaId2EntradaRecord.values());

        Map<Id, List<ONE_Entrada_De_Precio__c>> prodId2Entrada = buildProductsWithEntradas(entradasDePreciosentradaId2EntradaRecord, new Map<Id, ONE_Entrada_De_Precio__c>());
        Map<String, ONE_Segmentacion_De_Linea__c> productId2Comportamiento = buildProductsWithComportamiento(expedient);
        Map<Id, List<ONE_Modelo__c>> productId2EntradaModelos = buildProductsWithModels(expedient, allEntradaDePrecios);

        List<Producto> products = new List<Producto>();

        for(Id productId : prodId2Entrada.keySet()) {
            List<ONE_Entrada_De_Precio__c> entradas = prodId2Entrada.get(productId);

            List<Price> particularPrices = new List<Price>();
            List<Price> companyPrices = new List<Price>();
            if(entradas != null){
                for(ONE_Entrada_De_Precio__c entrada : entradas) {
                    List<ONE_Modelo__c> models = productId2EntradaModelos.get(entrada.ONE_Concepto_Comercial__c);

                    List<Model> modelsToDTO = new List<Model>();
                    if(models != null) {
                        for(ONE_Modelo__c model : models) {
                            modelsToDTO.add(new Model(
                                model.Id,
                                model.ONE_Nombre_ESP__c,
                                model.ONE_Nombre_CAT__c,
                                model.ONE_Nombre_EUS__c,
                                model.ONE_Modelo_por_defecto__c
                            ));
                        }
                    }
                    Price pr = new Price(
                        entrada.Id,
                        String.valueOf(entrada.ONE_Precio__c) + ' EUR',
                        modelsToDTO
                    );
                    particularPrices.add(pr);
                }
            }

            Producto prod = new Producto(
                productId,
                companyPrices,
                particularPrices,
                productId2Comportamiento.get(productId)?.ONE_Comportamiento__c,
                centerPDFs.containsKey(productId) ? centerPDFs.get(productId).ONE_URL_Imagen__c : ''
            );
            
            if(productId2Comportamiento.get(productId)?.ONE_Comportamiento__c == '01') {
                Decimal unidades = productId2Comportamiento.get(productId)?.ONE_Unidades__c != null ? productId2Comportamiento.get(productId).ONE_Unidades__c : 1;

                for(Integer i = 0; i < Integer.valueof(unidades); i++) {
                    products.add(prod);
                }
            } else {
                products.add(prod);
            }
        }

        String seg = expedient.ONE_Segmento_Seleccionado__c != null ? expedient.ONE_Segmento_Seleccionado__c : expedient.ONE_Acuerdo_Comercial__c;
        if(seg != null && seg != '') {
            List<ONE_Producto__c> adjustProd = [
                SELECT Id FROM ONE_Producto__c WHERE ONE_Codigo_Comercial__c = '400001933'
            ];

            List<ONE_Segmentacion_Acuerdo__c> adjustSeg  = [
                SELECT Id, ONE_Ajuste_Necesario__c FROM ONE_Segmentacion_Acuerdo__c WHERE Id =: seg
            ];

            if(adjustSeg[0].ONE_Ajuste_Necesario__c != 0 && adjustSeg[0].ONE_Ajuste_Necesario__c != null) {
                Price adjustPrice = new Price(
                    '',
                    String.valueOf(adjustSeg[0].ONE_Ajuste_Necesario__c),
                    new List<Model>()
                );

                Producto adjustProdDTO = new Producto(
                    adjustProd[0].Id,
                    new List<Price> (),
                    new List<Price> { adjustPrice },
                    '01',
                    centerPDFs.containsKey(adjustProd[0].Id) ? centerPDFs.get(adjustProd[0].Id).ONE_URL_Imagen__c : ''
                );
                products.add(adjustProdDTO);
            }
        }
        
        PricingObject PO = new PricingObject(
            expedient.Id,
            expedient.Name,
            expedient.ONE_Catalogo_De_Precios__c,
            expedient.ONE_Catalogo_De_Precios_Acuerdo__c,
            expedient.ONE_Segmento_Seleccionado__c,
            expedient.ONE_Acuerdo_Comercial__c,
            products
        );

        return PO;
    }

    public class PricingObject {
        public String Id { get; private set; }
        public String Name { get; private set; }
        public String CatalogoDePrecio { get; private set; }
        public String CatalogoDePreciosAcuerdo { get; private set; }
        public String SegmentoSeleccionado { get; private set; }
        public String AcuerdoComercial { get; private set; }
        public List<Producto> products { get; private set; }

        public PricingObject(
            String newId,
            String newName,
            String newCatalogoDePrecio,
            String newCatalogoDePreciosAcuerdo,
            String newSegmentoSeleccionado,
            String newAcuerdoComercial,
            List<Producto> newProducts
        ) {
            Id = newId;
            Name = newName;
            CatalogoDePrecio = newCatalogoDePrecio;
            CatalogoDePreciosAcuerdo = newCatalogoDePreciosAcuerdo;
            SegmentoSeleccionado = newSegmentoSeleccionado;
            AcuerdoComercial = newAcuerdoComercial;
            products = newProducts;
        }
    }

    public class Producto {
        public String Id { get; private set; }
        public List<Price> companyPrices { get; private set; }
        public List<Price> particularPrices { get; private set; }
        public String Comportamiento { get; private set; }
        public String pdfURL { get; private set; }

        public Producto(String newId, List<Price> newCompanyPrices, List<Price> newParticularPrices, String newComportamiento, String newPdfURL) {
            Id = newId;
            companyPrices = newCompanyPrices;
            particularPrices = newParticularPrices;
            Comportamiento = newComportamiento;
			pdfURL = newPdfURL;
        }
    }

    public class Price {
        public String Id { get; private set; }
        public String Precio { get; private set; }
        public List<Model> models { get; private set; }

        public Price(String newId, String newPrecio, List<Model> newModels) {
            Id = newId;
            Precio = newPrecio;
            models = newModels;
        }
    }

    public class Model {
        public String Id { get; private set; }
        public String NombreESP { get; private set; }
        public String NombreCAT { get; private set; }
        public String NombreEUS { get; private set; }
        public Boolean porDefecto { get; private set; }


        public Model(String newId, String newNombreESP, String newNombreCAT, String newNombreEUS, Boolean porDefecto) {
            Id = newId;
            NombreESP = newNombreESP;
            NombreCAT = newNombreCAT;
            NombreEUS = newNombreEUS;
            this.porDefecto = porDefecto;
        }
    }

    public class WebServiceError {
        public Integer status;
        public String message;

        public WebServiceError(Integer newStatus, String newMessage) {
            status = newStatus;
            message = newMessage;
        }
    }
}
/**
 * Created by mbujak003 on 16.02.2021.
 */

@RestResource(UrlMapping='/offline-pricing')
global with sharing class ONE_OfflinePricesWebService {

    @HttpGet
    global static void getOfflinePrices() {
        Map<Id, ONE_Catalogo_De_Precios__c> catalogId2Catalog = new Map<Id, ONE_Catalogo_De_Precios__c>([
            SELECT Id, Name, ONE_Activo_Vigencia__c, ONE_Compania__r.Name, ONE_Tipo_De_Tarifa__c
            FROM ONE_Catalogo_De_Precios__c
            WHERE ONE_Activo_Vigencia__c = TRUE
            LIMIT 50
        ]);

        Map<Id, List<ONE_Entrada_De_Precio__c>> prodId2Entrada = buildProdId2Entradas(catalogId2Catalog);

        Map<Id, ONE_Catalogo_De_Precios__c> entradaId2Catalog = new Map<Id, ONE_Catalogo_De_Precios__c>();
        List<ONE_Entrada_De_Precio__c> entradaDePrecios = new List<ONE_Entrada_De_Precio__c>();
        for(List<ONE_Entrada_De_Precio__c> entradasList : prodId2Entrada.values()) {
            for(ONE_Entrada_De_Precio__c entrada : entradasList) {
                if(!entradaId2Catalog.containsKey(entrada.Id)) {
                    entradaId2Catalog.put(entrada.Id, entrada.ONE_Catalogo_De_Precios__r);
                }
                entradaDePrecios.add(entrada);
            }
        }
        Map<Id, Set<ONE_Modelo__c>> productId2Models = buildProductsWithModels(catalogId2Catalog.keySet(), entradaDePrecios);
        Map<Id, Map<Id, Set<ONE_Modelo__c>>> productId2ModelsExceptions = buildProductsWithModelExceptions(catalogId2Catalog.keySet(), entradaDePrecios);

        Map<Id, PriceCatalogueOffline> catalogueId2PriceCatalogueDTO = new Map<Id, PriceCatalogueOffline>();
        for(Id productId : prodId2Entrada.keySet()) {
            for(ONE_Entrada_De_Precio__c entrada : prodId2Entrada.get(productId)) {
                ONE_Catalogo_De_Precios__c catalog = entradaId2Catalog.get(entrada.Id);
                Set<ONE_Modelo__c> models = new Set<ONE_Modelo__c>();

                if(productId2ModelsExceptions.containsKey(catalog.Id) && productId2ModelsExceptions.get(catalog.Id).containsKey(productId)) {
                    models = productId2ModelsExceptions.get(catalog.Id).get(productId);
                } else {
                    models = productId2Models.get(productId);
                }

                Set<Line> linesDto = new Set<Line>();
                Set<Model> modelsDto = new Set<Model>();

                for(ONE_Modelo__c mod : models) {
                    modelsDto.add(
                        new Model(mod, entrada.Id)
                    );
                }
                linesDto.add(new Line(entrada, modelsDto, productId));
                if(catalogueId2PriceCatalogueDTO.containsKey(catalog.Id)) {
                    PriceCatalogueOffline pc = catalogueId2PriceCatalogueDTO.get(catalog.Id);
                    pc.Lines.addAll(linesDto);
                } else {
                    catalogueId2PriceCatalogueDTO.put(catalog.Id, new PriceCatalogueOffline(catalog, linesDto));
                }

            }
        }

        List<PriceCatalogueOffline> priceCataluges = new List<PriceCatalogueOffline>();

        for(String catalogId : catalogueId2PriceCatalogueDTO.keySet()) {
            priceCataluges.add(catalogueId2PriceCatalogueDTO.get(catalogId));
        }
        DTO dto = new DTO(priceCataluges);

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(dto, false));
    }

    private static Map<Id, Map<Id, Set<ONE_Modelo__c>>> buildProductsWithModelExceptions(Set<Id> catalogIds, List<ONE_Entrada_De_Precio__c> entradaDePrecios) {

        Map<Id, Map<Id, Set<ONE_Modelo__c>>> catalogId2productId2EntradaModelosExceptions = new Map<Id, Map<Id, Set<ONE_Modelo__c>>>();

        for (ONE_Entrada_De_Modelo__c exc : [
            SELECT Id, ONE_Producto__c, ONE_Modelo__r.ONE_Nombre_ESP__c, ONE_Modelo__r.ONE_Nombre_CAT__c, ONE_Modelo__r.ONE_Nombre_EUS__c, ONE_Catalogo_De_Precios__c
            FROM ONE_Entrada_De_Modelo__c
            WHERE ONE_Catalogo_De_Precios__c IN: catalogIds
        ]) {

            if(!catalogId2productId2EntradaModelosExceptions.containsKey(exc.ONE_Catalogo_De_Precios__c)) {
                catalogId2productId2EntradaModelosExceptions.put(exc.ONE_Catalogo_De_Precios__c, new Map<Id, Set<ONE_Modelo__c>>() );
            }
            if(!catalogId2productId2EntradaModelosExceptions.get(exc.ONE_Catalogo_De_Precios__c).containsKey(exc.ONE_Producto__c)) {
                catalogId2productId2EntradaModelosExceptions.get(exc.ONE_Catalogo_De_Precios__c).put(exc.ONE_Producto__c, new Set<ONE_Modelo__c> {exc.ONE_Modelo__r});
            } else {
                catalogId2productId2EntradaModelosExceptions.get(exc.ONE_Catalogo_De_Precios__c).get(exc.ONE_Producto__c).add(exc.ONE_Modelo__r);
            }
        }
        return catalogId2productId2EntradaModelosExceptions;
    }

    public static Map<Id, Set<ONE_Modelo__c>> buildProductsWithModels(Set<Id> catalogIds, List<ONE_Entrada_De_Precio__c> entradaDePrecios) {
        Map<Id, Set<ONE_Modelo__c>> productId2EntradaModelos = new Map<Id, Set<ONE_Modelo__c>>();
        Map<Id, List<ONE_Entrada_De_Modelo__c>> productId2EntradaModelosExceptions = new Map<Id, List<ONE_Entrada_De_Modelo__c>>();

        for (ONE_Entrada_De_Modelo__c exc : [
            SELECT Id, ONE_Producto__c, ONE_Modelo__r.ONE_Nombre_ESP__c, ONE_Modelo__r.ONE_Nombre_CAT__c, ONE_Modelo__r.ONE_Nombre_EUS__c, ONE_Catalogo_De_Precios__c
            FROM ONE_Entrada_De_Modelo__c
            WHERE ONE_Catalogo_De_Precios__c IN: catalogIds
        ]) {
            System.debug(exc);
            if(!productId2EntradaModelosExceptions.containsKey(exc.ONE_Producto__c)) {
                productId2EntradaModelosExceptions.put(exc.ONE_Producto__c, new List<ONE_Entrada_De_Modelo__c> { exc });
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
                SELECT Id, ONE_Nombre_ESP__c, ONE_Nombre_CAT__c, ONE_Nombre_EUS__c
                FROM Modelos__r
            )
            FROM ONE_Producto__c
            WHERE Id IN: allProdsWithoutGroups
        ]) {
            if(!productId2EntradaModelos.containsKey(prod.Id)) {
                productId2EntradaModelos.put(prod.Id, new Set<ONE_Modelo__c>(prod.Modelos__r));
            } else {
                productId2EntradaModelos.get(prod.Id).addAll(prod.Modelos__r);
            }
        }

        return productId2EntradaModelos;
    }

    private static Map<Id, List<ONE_Entrada_De_Precio__c>> buildProdId2Entradas(Map<Id, ONE_Catalogo_De_Precios__c> catalogId2Catalog) {

        Map<String, List<ONE_Entrada_De_Precio__c>> catalogId2EntradasDePrecio = new Map<String, List<ONE_Entrada_De_Precio__c>>();
        Map<Id, ONE_Entrada_De_Precio__c> precioId2Precio = new Map<Id, ONE_Entrada_De_Precio__c>([
            SELECT Id, ONE_Catalogo_De_Precios__c, ONE_Concepto_Comercial__c, ONE_Precio__c, ONE_Catalogo_De_Precios__r.Name,
                ONE_Catalogo_De_Precios__r.ONE_Activo_Vigencia__c, ONE_Catalogo_De_Precios__r.ONE_Compania__r.Name,
                ONE_Catalogo_De_Precios__r.ONE_Tipo_De_Tarifa__c
            FROM ONE_Entrada_De_Precio__c
            WHERE ONE_Catalogo_De_Precios__c IN: catalogId2Catalog.keySet()
                AND ONE_Activo_Vigencia__c = TRUE
        ]);
        Map<String, List<ONE_Entrada_De_Precio__c>> productId2Entradas = new Map<String, List<ONE_Entrada_De_Precio__c>>();

        for(ONE_Entrada_De_Precio__c entrada : precioId2Precio.values()) {
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
                WHERE ONE_Tipo_De_Relacion__c = 'Agrupación'
            )
            FROM ONE_Producto__c
            WHERE Id IN: productId2Entradas.keySet()
        ];

        for(ONE_Producto__c prod : allProducts) {
            if(!prod.Relaciones_de_productos__r.isEmpty()) {
                for(ONE_Relacion_De_Productos__c rel : prod.Relaciones_de_productos__r) {
                    if(!prodId2Entrada.containsKey(rel.ONE_Producto_Incluido__c)) {
                        prodId2Entrada.put(rel.ONE_Producto_Incluido__c, productId2Entradas.get(prod.Id) );
                    } else {
                        prodId2Entrada.get(rel.ONE_Producto_Incluido__c).addAll(productId2Entradas.get(prod.Id));
                    }
                }
            } else {
                if(!prodId2Entrada.containsKey(prod.Id)) {
                    prodId2Entrada.put(prod.Id, productId2Entradas.get(prod.Id) );
                } else {
                    prodId2Entrada.get(prod.Id).addAll(productId2Entradas.get(prod.Id));
                }
            }
        }
        
        return prodId2Entrada;
    }

    public class DTO {
        public List<PriceCatalogueOffline> priceCataloguesOffline { get; set; }
        public DTO(List<PriceCatalogueOffline> newPriceCataloguesOffline) {
            priceCataloguesOffline = newPriceCataloguesOffline;
        }
    }

    public class PriceCatalogueOffline {
        public String Id { get; set; }
        public String name { get; set; }
        public String company { get; set; }
        public String catalogueType { get; set; }
        public Boolean active { get; set; }
        public Set<Line> Lines { get; set; }

        public PriceCatalogueOffline(ONE_Catalogo_De_Precios__c catalog, Set<Line> newLines) {
            Id = catalog.Id;
            name = catalog.Name;
            company = catalog.ONE_Compania__r.Name;
            catalogueType = catalog.ONE_Tipo_De_Tarifa__c;
            active = catalog.ONE_Activo_Vigencia__c;
            Lines = newLines;
        }
    }

    public class Line {
        public String Id { get; set; }
        public String productId { get; set; }
        public String price { get; set; }
        public Set<Model> models { get; set; }

        public Line(ONE_Entrada_De_Precio__c entradaDePrecio, Set<Model> newModels, String prodId) {
            Id = entradaDePrecio.Id;
            productId = prodId;
            //productId = entradaDePrecio.ONE_Concepto_Comercial__c;
            price = String.valueOf(entradaDePrecio.ONE_Precio__c + ' EUR');
            models = newModels;
        }
    }

    public class Model {
        public String Id { get; set; }
        public String priceEntry { get; set; }
        public String NombreESP { get; set; }
        public String NombreCAT { get; set; }
        public String NombreEUS { get; set; }

        public Model(ONE_Modelo__c model, String newPriceEntry) {
            Id = model?.Id;
            NombreCAT = model?.ONE_Nombre_CAT__c;
            NombreESP = model?.ONE_Nombre_ESP__c;
            NombreEUS = model?.ONE_Nombre_EUS__c;
            priceEntry = newPriceEntry;
        }
    }

}
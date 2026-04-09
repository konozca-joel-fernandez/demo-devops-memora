/**
 * Created by mbujak003 on 27.04.2021.
 */
//Price recalculation batch to update price entries
public with sharing class ONE_PricesRecalculationBatch implements Schedulable, Database.Batchable<SObject> {
    private static final Integer BATCH_SIZE = 1;
	//Query to get all segmentation that need price recalculation
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, ONE_Catalogo_De_Precios__c, ONE_Importe_Conjunto__c, ONE_Necesita_Recalculo__c, ONE_Ajuste_Necesario__c, ONE_Tipo_De_Recalculo__c
            FROM ONE_Segmentacion_Acuerdo__c
            WHERE ONE_Necesita_Recalculo__c = true AND ONE_Activo_Vigencia__c=true
        ]);
    }
	//Execute batch method with SchedulableContext input parameter
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new ONE_PricesRecalculationBatch(), BATCH_SIZE);
    }
	//Execute batch method with ONE_Segmentacion_Acuerdo__c input parameter	
    public void execute(Database.BatchableContext bc, List<ONE_Segmentacion_Acuerdo__c> records) {
        Map<Id, ONE_Segmentacion_Acuerdo__c> segId2SegRecord = new Map<Id, ONE_Segmentacion_Acuerdo__c>(records); //Store register from ID
        Map<String, ProductRecalculation> preselectedProducts = findPreselectedProducts(segId2SegRecord.keySet());
        Map<Id, ONE_Entrada_De_Precio__c> prodId2PriceEntry = fetchPricesInCatalog(segId2SegRecord.keySet()); //Store register from ID
        Map<Id, ONE_Segmentacion_Acuerdo__c> segmentacionsToUpdate = new Map<Id, ONE_Segmentacion_Acuerdo__c>();
		//For each product ID, get related segmentation and get prod recalculation.
        for(Id prodId : prodId2PriceEntry.keySet()) {
            if(preselectedProducts.containsKey(prodId) && prodId2PriceEntry.containsKey(prodId)) {
                ProductRecalculation prodRecalc = preselectedProducts.get(prodId);
                ONE_Entrada_De_Precio__c priceEntry = prodId2PriceEntry.get(prodId);
				
                Decimal price = prodRecalc.units * priceEntry.ONE_Precio__c;
                Decimal difference;
                Decimal ajusteNecesarioAux;
                Decimal importeConjuntoAux;
                ONE_Segmentacion_Acuerdo__c processedSeg;
                //If we got an agreement (Acuerdo comercial)
                if(segmentacionsToUpdate.containsKey(prodRecalc.agreementId)) {
                    processedSeg = segmentacionsToUpdate.get(prodRecalc.agreementId);
                    if (segId2SegRecord.get(prodRecalc.agreementId).ONE_Tipo_De_Recalculo__c == 'Recálculo de ajuste') {
                        /*ajusteNecesarioAux = processedSeg.ONE_Ajuste_Necesario__c == null ? 0 : processedSeg.ONE_Ajuste_Necesario__c;
                        difference = ajusteNecesarioAux - price; 
                        processedSeg.ONE_Ajuste_Necesario__c = difference;*/
                    }
                    else { // Tipo de recálculo is 'Recálculo de importe' or empty
                        difference = processedSeg.ONE_Importe_Conjunto__c + price;
                        processedSeg.ONE_Importe_Conjunto__c = difference;
                    }
                } else { // no agreement
                    if (segId2SegRecord.get(prodRecalc.agreementId).ONE_Tipo_De_Recalculo__c == 'Recálculo de ajuste') {
                        importeConjuntoAux = segId2SegRecord.get(prodRecalc.agreementId).ONE_Importe_Conjunto__c == null ? 0 : segId2SegRecord.get(prodRecalc.agreementId).ONE_Importe_Conjunto__c;
                        difference = segId2SegRecord.get(prodRecalc.agreementId).ONE_Importe_Conjunto__c - price; // Get differente from importe conjunto
                        
                    }
                    else {  // Tipo de recálculo is 'Recálculo de importe' or empty
                        System.debug(segId2SegRecord.get(prodRecalc.agreementId));
                        System.debug('ONE_Ajuste_Necesario__c = '+segId2SegRecord.get(prodRecalc.agreementId).ONE_Ajuste_Necesario__c);
                        ajusteNecesarioAux = segId2SegRecord.get(prodRecalc.agreementId).ONE_Ajuste_Necesario__c == null ? 0 : segId2SegRecord.get(prodRecalc.agreementId).ONE_Ajuste_Necesario__c;
                        difference = ajusteNecesarioAux + price;
                        processedSeg = new ONE_Segmentacion_Acuerdo__c(
                            Id = prodRecalc.agreementId,
                            ONE_Importe_Conjunto__c = difference
                            //ONE_Necesita_Recalculo__c = false
                        );
                    }
                }

                segmentacionsToUpdate.put(
                    prodRecalc.agreementId,
                    processedSeg
                );
            }
        }

        for (Id segmentacionId : segmentacionsToUpdate.keySet()) {
            if (segId2SegRecord.get(segmentacionId).ONE_Tipo_De_Recalculo__c == 'Recálculo de ajuste' && segmentacionsToUpdate.get(segmentacionId).ONE_Ajuste_Necesario__c > 0) {
                ONE_Segmentacion_Acuerdo__c updatedSegmentacion = segmentacionsToUpdate.get(segmentacionId);
                updatedSegmentacion.ONE_Ajuste_Necesario__c = 0;
                segmentacionsToUpdate.put(
                    segmentacionId,
                    updatedSegmentacion
                );
            }
        }

        upsert segmentacionsToUpdate.values();
    }
	//Method to obtain prices using input agreement ID's
    public static Map<Id, ONE_Entrada_De_Precio__c> fetchPricesInCatalog(Set<Id> agreementIds) {
        
        Map<Id, ONE_Segmentacion_Acuerdo__c> catalogId2Catalog = new Map<Id, ONE_Segmentacion_Acuerdo__c>([
            SELECT ONE_Catalogo_De_Precios__c FROM ONE_Segmentacion_Acuerdo__c WHERE Id IN: agreementIds
        ]);
        Set<Id> catalogIds = new Set<Id>();

        for(ONE_Segmentacion_Acuerdo__c seg : catalogId2Catalog.values()) {
            catalogIds.add(seg.ONE_Catalogo_De_Precios__c);
        }

        Map<Id, ONE_Entrada_De_Precio__c> prodId2Entrada = new Map<Id, ONE_Entrada_De_Precio__c>();
        for(ONE_Entrada_De_Precio__c entrada : [
            SELECT ONE_Concepto_Comercial__c, ONE_Precio__c, ONE_Catalogo_De_Precios__c
            FROM ONE_Entrada_De_Precio__c
            WHERE ONE_Activo_Vigencia__c = TRUE
                AND ONE_Catalogo_De_Precios__c IN: catalogIds
        ]) {
            prodId2Entrada.put(entrada.ONE_Concepto_Comercial__c, entrada);
        }
		
        List<ONE_Relacion_De_Productos__c> relacions = [
            SELECT ONE_Producto_Comercial_Padre__c, ONE_Producto_Incluido__c, ONE_Tipo_De_Relacion__c
            FROM ONE_Relacion_De_Productos__c
            WHERE (ONE_Tipo_De_Relacion__c = 'Agrupación' OR ONE_Tipo_De_Relacion__c = 'Complemento')
                AND ONE_Producto_Comercial_Padre__c IN: prodId2Entrada.keySet()
        ];

        for(ONE_Relacion_De_Productos__c relacion : relacions) {
            if(relacion.ONE_Producto_Incluido__c != null && relacion.ONE_Producto_Comercial_Padre__c != null) {
                prodId2Entrada.put(relacion.ONE_Producto_Incluido__c, prodId2Entrada.get(relacion.ONE_Producto_Comercial_Padre__c));
            }
        }
        return prodId2Entrada;
    }

	//Get preselected products using agreement input ID
    public static Map<String, ProductRecalculation> findPreselectedProducts(Set<Id> agreementIds) {
        Map<String, ProductRecalculation> prodId2ProdRecalc = new Map<String, ProductRecalculation>();
        Map<String, ProductRecalculation> prodId2ProdRecalcRecommended = new Map<String, ProductRecalculation>();
        List<ONE_Segmentacion_De_Linea__c> segLineas = fetchProductsForAgreements(agreementIds);
        //Check segmentation line to know if the price recalculation is recomended os mandatory
        for(ONE_Segmentacion_De_Linea__c segLinea : segLineas) {
            System.debug(segLinea.Id);
            if(segLinea.ONE_Comportamiento__c == '01') {
                prodId2ProdRecalc.put(segLinea.ONE_Producto__c, new ProductRecalculation(segLinea));
            } else {
                prodId2ProdRecalcRecommended.put(segLinea.ONE_Producto__c, new ProductRecalculation(segLinea));
            }
        }
        List<ONE_Relacion_De_Productos__c> relacions = fetchProductsForGroups(prodId2ProdRecalc.keySet());
        List<ONE_Relacion_De_Productos__c> relacionsPreselected = fetchProductsForGroups(prodId2ProdRecalcRecommended.keySet());
		
        relacions.addAll(relacionsPreselected);
        for(ONE_Relacion_De_Productos__c relacion : relacions) {
            if(relacion.ONE_Producto_Incluido__c != null && relacion.ONE_Producto_Comercial_Padre__c != null) {
                if(relacion.ONE_Tipo_De_Relacion__c != 'Agrupación') {
                    prodId2ProdRecalc.put(
                        relacion.ONE_Producto_Incluido__c,
                        prodId2ProdRecalc.get(relacion.ONE_Producto_Comercial_Padre__c) != null ?
                            prodId2ProdRecalc.get(relacion.ONE_Producto_Comercial_Padre__c) :
                            prodId2ProdRecalcRecommended.get(relacion.ONE_Producto_Comercial_Padre__c)
                    );
                } else {
                    prodId2ProdRecalc.put(
                        relacion.ONE_Producto_Incluido__c,
                        prodId2ProdRecalc.get(relacion.ONE_Producto_Comercial_Padre__c) != null ?
                            prodId2ProdRecalc.get(relacion.ONE_Producto_Comercial_Padre__c) :
                            prodId2ProdRecalcRecommended.get(relacion.ONE_Producto_Comercial_Padre__c)
                    );
                }
            }
        }

        return prodId2ProdRecalc;
    }
	//Helper method to get fetch product relation from products ID's
    private static List<ONE_Relacion_De_Productos__c> fetchProductsForGroups(Set<String> productIds) {
        return [
            SELECT ONE_Producto_Comercial_Padre__c, ONE_Producto_Incluido__c, ONE_Preseleccionado_Agrupacion__c,
                ONE_Tipo_De_Relacion__c
            FROM ONE_Relacion_De_Productos__c
            WHERE ONE_Tipo_De_Relacion__c = 'Agrupación'
                AND ONE_Preseleccionado_Agrupacion__c = TRUE
                AND ONE_Producto_Comercial_Padre__c IN: productIds
        ];
    }
	//Helper method to fetch products from agreement ID's
    private static List<ONE_Segmentacion_De_Linea__c> fetchProductsForAgreements(Set<Id> agreementIds) {
        return [
            SELECT Id, ONE_Producto__c, ONE_Comportamiento__c, ONE_Segmentacion_Acuerdo__c, ONE_Unidades__c
            FROM ONE_Segmentacion_De_Linea__c
            WHERE ONE_Segmentacion_Acuerdo__c =: agreementIds
        ];
    }
	//Finish batch method
    public void finish(Database.BatchableContext bc) {}
	
    //Product recalculation  data model definiton
    private class ProductRecalculation {
        public String productId { get; private set; }
        public Integer units { get; private set; }
        public String segmentId { get; private set; }
        public String agreementId { get; private set; }

        public ProductRecalculation(ONE_Segmentacion_De_Linea__c segmentation) {
            productId = segmentation.ONE_Producto__c;
            units = Integer.valueOf(segmentation.ONE_Unidades__c == null ? 1 : segmentation.ONE_Unidades__c);
            segmentId = segmentation.Id;
            agreementId = segmentation.ONE_Segmentacion_Acuerdo__c;
        }
    }
}
/**
 * Created by Miguel Serrt on 03.05.2023.
 * 
 * LOGs:
 * -------------------------------------------
 * DATE       USER            CHANGE
 * -------------------------------------------
 */

@RestResource(UrlMapping='/queryStock')
global with sharing class ONE_SynchronizeStockWebService {
    public static String PARAM_FILTER = '$filter';
    public static String FILTER_MATNR = 'Matnr';
    public static String FILTER_CENTRO = 'Centro';
    
    @HttpPost
    global static void checkStock() {
        StockData data = null;
        String jsonStr = null;
        
		//Check non empty request and return error in case it apply
        if(null == RestContext.request.requestBody) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('Body is missing!');
            RestContext.response.statusCode = 400;
            return;
        }
        
        jsonStr = RestContext.request.requestBody.toString();
        
        Set<String> allContractedProductsIds = new Set<String>();
        Set<String> allContractedModelsIds = new Set<String>();

		List<String> uncompletedProductNamesToReturn = new List<String>();
            
        ONE_StockIntegrationService.FlowInputs fi = new ONE_StockIntegrationService.FlowInputs();
        List<ONE_StockIntegrationService.FlowOutputs> fo = new List<ONE_StockIntegrationService.FlowOutputs>();
               
        try {
            data = (StockData)JSON.deserialize(jsonStr, StockData.class);
            fi.centro = [SELECT ONE_Centro_Memora_Codigo_SAP__c FROM Account WHERE Id = :data.workplace LIMIT 1].ONE_Centro_Memora_Codigo_SAP__c;
        	fi.matnr = new List<String>();
            
            for(ProductStockData psa : data.products){
                if(!(psa.model == null || psa.model == '')){
                    allContractedModelsIds.add(psa.model);
                } else {
                    allContractedProductsIds.add(psa.id);
                }               
            }
            
            
            List<ONE_Modelo__c> models = [SELECT Id, ONE_SKU__c, ONE_Producto_Comercial__c
                                          FROM ONE_Modelo__c   
                                          WHERE ONE_Producto_Comercial__r.ONE_Stockable__c = true 
                                          		AND Id IN :allContractedModelsIds];
            List<ONE_Producto__c> prods = [SELECT Id, ONE_SKU__c 
                                           FROM ONE_Producto__c  
                                           WHERE ONE_Stockable__c = true 
                                           		AND Id IN :allContractedProductsIds];
            
            // SKU - product or model
            Map<String, ONE_Modelo__c> mModels = new Map<String, ONE_Modelo__c>();
            Map<String, ONE_Producto__c> mProducts = new Map<String, ONE_Producto__c>();
            
            Map<String, sObject> withOutSKU = new Map<String, sObject>();
            
            for(ONE_Modelo__c m : models){
                if(m.ONE_SKU__c == null){
                    withOutSKU.put('M' + m.Id, m);
                } else {
                    fi.matnr.add(m.ONE_SKU__c);
                	mModels.put(m.ONE_SKU__c, m);
                }
            }
            for(ONE_Producto__c p : prods){
                if(p.ONE_SKU__c == null){
                    withOutSKU.put('P' + p.Id, p);
                } else {
                    fi.matnr.add(p.ONE_SKU__c);
                	mProducts.put(p.ONE_SKU__c, p);
                }
            }
            
            List<SAPData> stocks = new List<SAPData>();
            
            if(fi.matnr.size() > 0){
                fo = ONE_StockIntegrationService.invokeIntegration(
                    new List<ONE_StockIntegrationService.FlowInputs> { fi }
                );
                           
                List<SAPData> sapList = new List<SAPData>();
                String jsnons = fo[0].modeloTableJson.substring( 1, fo[0].modeloTableJson.length() - 1 );
                System.debug('ERR ' + fo[0].errorMessage);
                List<String> jsonStrings = jsnons.split('},');
                
                for(String js : jsonStrings){
                    if(js != ''){
                        js += '}';
                        System.debug('+++ ' + js);
                        SAPData stk = (SAPData)JSON.deserialize(js, SAPData.class);
                        
                        if (mModels.containsKey(stk.SKU)){
                            ONE_Modelo__c m = mModels.get(stk.SKU);
                            stk.Model = m.Id;
                            stk.Id = m.ONE_Producto_Comercial__c;
                        }
                        if (mProducts.containsKey(stk.SKU)){
                            ONE_Producto__c p = mProducts.get(stk.SKU);
                            stk.Id = p.Id;
                        }
                        
                        stocks.add(stk);
                    }
                }
            }
            
            if(withOutSKU.isEmpty()){
                RestContext.response.addHeader('Content-Type', 'application/json');
            	RestContext.response.responseBody = Blob.valueOf(JSON.serialize(stocks));
            	RestContext.response.statusCode = 200;
            } else {
                for(String soId : withOutSKU.keySet()){
                    if (soId.startsWith('M')){
                        sObject m = withOutSKU.get(soId);
                        SAPData d = new SAPData();
                        //d.Id = m.ONE_Producto_Comercial__c;
                        d.Model = m.Id;
                        stocks.add(d);
                    } else {
                        sObject p = withOutSKU.get(soId);
                        SAPData d = new SAPData();
                        d.Id = p.Id;
                        stocks.add(d);
                    }
                }
                RestContext.response.addHeader('Content-Type', 'application/json');
            	RestContext.response.responseBody = Blob.valueOf(JSON.serialize(stocks));
            	RestContext.response.statusCode = 200;
            }
            
         
        } catch (Exception ex) {
            Map<String, String> responseBody = new Map<String, String> {
                'RequestBody' => jsonStr,
                'ErrorMessage' => ex.getMessage() + '\n' + ex.getStackTraceString()
            };
            
            System.debug('ERR: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
            RestContext.response.statusCode = 400;

        }
    }
    
    public class StockData {
        public String workplace { get; set; }
        public ProductStockData[] products { get; set; }
    }
    public class ProductStockData {
        public String id { get; set; }
        public String model { get; set; }
    }
    public class SAPData {
        public string Id { get; set; }
        public string Model { get; set; }
        public integer Unidades { get; set; }
        public string SKU { get; set; }
        //public string Proveedor { get; set; }
        //public string NombreCentro { get; set; }
        //public string Nombre { get; set; }
        //public string Centro { get; set; }
        //public string Almacen { get; set; }
    }
    
    public class SynchronizationException extends Exception {}
}
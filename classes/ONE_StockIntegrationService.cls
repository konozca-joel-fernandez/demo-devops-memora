/**
 * Created by mbujak003 on 19.01.2021.
 */

//Consult Stock integration service class
public with sharing class ONE_StockIntegrationService {
	//Static variable definition
    public static String PARAM_FILTER = '$filter';
    public static String FILTER_MATNR = 'Matnr';
    public static String FILTER_CENTRO = 'Centro';
	
    public class StockIntegrationCallout extends ONE_SAPCallout {
        public StockIntegrationCallout(String filters) {
            super(ONE_CommonConstants.CM_SAP_CONSULTASTOCKS, ONE_Integration.RestMethod.GET, ONE_CommonConstants.SAPSCOPE_STOCK); // Use father class to generate basic SAP request

            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(filters); //obtain parameter from the view
			
            //Populate request parameter
            List<String> matnrList = ((string)parsedParams.get(FILTER_MATNR.toLowerCase())).split(',');
            String centro = (string)parsedParams.get(FILTER_CENTRO.toLowerCase());

            String filter = FILTER_CENTRO + ' eq ' + formatFilter(centro) + ' and (Matnr eq ' + formatFilter(matnrList[0]);

            for (Integer i = 1;  i < matnrList.size(); i++) {
                filter += ' or Matnr eq ' + formatFilter(matnrList[i]);
            }
            filter += ')';

            putParam(PARAM_FILTER, EncodingUtil.urlEncode(filter, ONE_Integration.ENCODING_UTF8));
        }
		//Build endopint using integration custom metada and add the corrsponding values for the GET call
//        public override String buildEndpoint() {
//            String endpoint = super.buildEndpoint();
//            System.debug('endpoint: ' + endpoint);
//            if(!params.isEmpty()) {
//                String paramString = '?';
//                for(String key : params.keySet()) {
//                    paramString += String.format('{0}={1}&', new List<String>{ key, String.valueOf(params.get(key)) });
//                }
//                endpoint += paramString.removeEnd('&');
//            }
//            return endpoint;
//        }

        private String formatFilter(String filter) {
            return '\'' + filter + '\'';
        }
    }
	//Invocable methos so we can use this integration via flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        String matnrString = String.join(inputs[0].matnr, ',');
        String filters = JSON.serialize(new Map<String, String> {
                FILTER_MATNR.toLowerCase() => matnrString,
                FILTER_CENTRO.toLowerCase() => inputs[0].centro
        });

        StockIntegrationCallout callout = new StockIntegrationCallout(filters);

        String responseBody = callout.invokeCallout().getBody(); // Call integration

        String errVal = '';
        
        //Parse resposne
        Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        FlowOutputs fo = new FlowOutputs();

        if(respObject.containsKey('d')) { // If OK resposne
            Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
            List<Object> objects = (List<Object>)innerObject.get('results');

            Map<String, String> skuToName = new Map<String, String>();
            List<ONE_TableHeadersClass> tableRows = new List<ONE_TableHeadersClass>();

            String nombreCentro = '';
            
            for(Object obj : objects) {

                Map<String, Object> stockItemProperty2Value = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));

                if (String.isEmpty(nombreCentro)) {
                    String codigoCentro = String.valueOf(stockItemProperty2Value.get('Centro'));
                    try {
                        Account centro = [SELECT Name FROM Account WHERE ONE_Centro_Memora_Codigo_SAP__c = :codigoCentro LIMIT 1];
                        nombreCentro = centro.Name;
                    } catch(System.QueryException e) {
                        nombreCentro = '';
                    }
                }

                ONE_TableHeadersClass row = new ONE_TableHeadersClass(
                        '',
                        String.valueOf(stockItemProperty2Value.get('Material')),
                        String.valueOf(stockItemProperty2Value.get('Centro')),
                        nombreCentro,
                        String.valueOf(stockItemProperty2Value.get('Almacen')),
                        String.valueOf(stockItemProperty2Value.get('Proveedor')),
                        Integer.valueOf(stockItemProperty2Value.get('StockLibre'))
                );
                skuToName.put(String.valueOf(stockItemProperty2Value.get('Material')), null);
                tableRows.add(row);
            }

            List<ONE_Modelo__c> modeloList = [SELECT Name, ONE_SKU__c FROM ONE_Modelo__c WHERE ONE_SKU__c IN :skuToName.keySet()];
            if (!modeloList.isEmpty()) {
                for (ONE_Modelo__c m : modeloList) {
                    skuToName.put(m.ONE_SKU__c, m.Name);
                }
                fo.tableHeader = Label.Modelo_Table;
            } else {
                List<ONE_Producto__c> productoList = [SELECT Name, ONE_SKU__c FROM ONE_Producto__c WHERE ONE_SKU__c IN :skuToName.keySet()];
                if (!productoList.isEmpty()) {
                    for (ONE_Producto__c p : productoList) {
                        skuToName.put(p.ONE_SKU__c, p.Name);
                    }
                    fo.tableHeader = Label.Producto_Table;
                }
            }

            for (ONE_TableHeadersClass r : tableRows) {
                r.Nombre = skuToName.get(r.SKU);
            }

            fo.modeloTableJson = Json.serialize(tableRows);

        } else { // If KO response
            if(respObject.containsKey('error')) {
                Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('error');
                Map<String, Object> message = (Map<String, Object>)innerObject.get('message');
                fo.errorMessage = String.valueOf(message.get('value'));
            } else {
                fo.errorMessage = 'Unexpected error';
            }
        }

        return new List<FlowOutputs> { fo };
    }

	//Flow input variable definiton
    public class FlowInputs{
        @InvocableVariable
        public List<String> matnr;
        @InvocableVariable
        public String centro;
    }
	//Flow output variable definiton
    public class FlowOutputs {
        @InvocableVariable
        public String modeloTableJson;
        @InvocableVariable
        public String tableHeader;
        @InvocableVariable
        public String errorMessage;
    }
}
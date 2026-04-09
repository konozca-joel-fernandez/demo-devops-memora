//Consulta stock SAP integration from the tarea's object
public with sharing class ONE_StockIntegrationServiceTarea {
    //Static variable definition
    public static String PARAM_FILTER = '$filter';
    public static String FILTER_MATNR = 'Matnr';
    public static String FILTER_CENTRO = 'Centro';

    public class StockIntegrationCallout extends ONE_SAPCallout {
        public StockIntegrationCallout(String filters) {
            super(ONE_CommonConstants.CM_SAP_CONSULTASTOCKS, ONE_Integration.RestMethod.GET, ONE_CommonConstants.SAPSCOPE_STOCK);

            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(filters);

            List<String> matnrList = ((String)parsedParams.get(FILTER_MATNR.toLowerCase())).split(',');
            String centro = (String)parsedParams.get(FILTER_CENTRO.toLowerCase());
			//Prepare filters to addd it to the URL (this integration use GET Method)
            String filter = FILTER_CENTRO + ' eq ' + formatFilter(centro) + ' and (Matnr eq ' + formatFilter(matnrList[0]);

            for (Integer i = 1;  i < matnrList.size(); i++) {
                filter += ' or Matnr eq ' + formatFilter(matnrList[i]);
            }
            filter += ')';
			
            putParam(PARAM_FILTER, EncodingUtil.urlEncode(filter, ONE_Integration.ENCODING_UTF8));
        }
		//Build endpoint using custom metada integration endpoint define and filter for the GET Method
//        public override String buildEndpoint() {
//            String endpoint = super.buildEndpoint();
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
	//Invocable method so we can call this integration via flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        String matnrString = String.join(inputs[0].matnr, ',');
        String filters = JSON.serialize(new Map<String, String> {
                FILTER_MATNR.toLowerCase() => matnrString,
                FILTER_CENTRO.toLowerCase() => inputs[0].centro
        });

        StockIntegrationCallout callout = new StockIntegrationCallout(filters);

        String responseBody = callout.invokeCallout().getBody(); // Callout

        String errVal = '';
        
        //Response parse
        Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        FlowOutputs fo = new FlowOutputs();

        if(respObject.containsKey('d')) { // If OK response
            Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
            List<Object> objects = (List<Object>)innerObject.get('results');

            Map<String, ONE_TableHeadersClass> modeloTableResults = new Map<String, ONE_TableHeadersClass>();

            String nombreCentro = '';

            Map<String, Account> codigoCentroAccountMap = new Map<String, Account>();
            for(Account centro : [SELECT Name, ONE_Centro_Memora_Codigo_SAP__c FROM Account WHERE ONE_Centro_Memora_Codigo_SAP__c != NULL]) {
                codigoCentroAccountMap.put(centro.ONE_Centro_Memora_Codigo_SAP__c, centro);
            }

            for(Object obj : objects) {
                Map<String, Object> stockItemProperty2Value = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));

                if (String.isEmpty(nombreCentro)) {
                    String codigoCentro = String.valueOf(stockItemProperty2Value.get('Centro'));
                    nombreCentro = codigoCentroAccountMap.get(codigoCentro)?.Name != null ? codigoCentroAccountMap.get(codigoCentro).Name : '';
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
                modeloTableResults.put(String.valueOf(stockItemProperty2Value.get('Material')),row);
            }
			//Get models
            List<ONE_Modelo__c> modeloList = [SELECT Name, ONE_SKU__c FROM ONE_Modelo__c WHERE ONE_SKU__c IN :modeloTableResults.keySet()];
            if (!modeloList.isEmpty()) {
                for (ONE_Modelo__c m : modeloList) {
                    modeloTableResults.get(m.ONE_SKU__c).Nombre = m.Name;
                }
                fo.tableHeader = Label.Modelo_Table;
            } else {
                List<ONE_Producto__c> productoList = [SELECT Name, ONE_SKU__c FROM ONE_Producto__c WHERE ONE_SKU__c IN :modeloTableResults.keySet()];
                if (!productoList.isEmpty()) {
                    for (ONE_Producto__c p : productoList) {
                        modeloTableResults.get(p.ONE_SKU__c).Nombre = p.Name;
                    }
                    fo.tableHeader = Label.Producto_Table;
                }
            }

            fo.modeloTableJson = Json.serialize(modeloTableResults.values());

        } else { // IF KO Response
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
	//Flow input variable definition
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
/**
 * Created by mbujak003 on 01.02.2021.
 */
//Stock consumption SAP integration definition 
public with sharing class ONE_StockConsumptionIntegrationService {
	//Static variable definiton 
    public static String FILTER_EXPEDIENTE = 'Expediente';
    public static String FILTER_IMBLNR = 'IMblnr';
    public static String FILTER_IMJAHR = 'IMjahr';


    public class StockConsumptionCallout extends ONE_SAPCallout {
        //This is executed from the view stock consuption view
        public StockConsumptionCallout(String filters) {
            super(ONE_CommonConstants.CM_SAP_CONSUMOS, ONE_Integration.RestMethod.GET, ONE_CommonConstants.SAPSCOPE_CONSUMOS);
	
            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(filters); // Get parameters from the frontend
			//SAP parameter requirement getting
            String Expediente = (String)parsedParams.get(FILTER_EXPEDIENTE.toLowerCase());
            String IMblnr = (String)parsedParams.get(FILTER_IMBLNR.toLowerCase());
            String IMjahr = (String)parsedParams.get(FILTER_IMJAHR.toLowerCase());
			
            String filter = String.format(
                '({0}={1},{2}={3},{4}={5})',
                new List<String> {
                    FILTER_EXPEDIENTE,
                    formatFilter(Expediente),
                    FILTER_IMBLNR,
                    formatFilter(IMblnr),
                    FILTER_IMJAHR,
                    formatFilter(IMjahr)
                }
            );
            putParam('', filter);
        }
        //Build endpoint using integration endpoint custom metadata and adding new parametes for the GET request
        public override String buildEndpoint() {
            return super.buildEndpoint().remove('?=');
        }

        private String formatFilter(String filter) {
            return '\'' + filter + '\'';
        }
    }
	//Invocable method so we can call this integration via flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        //Request parameter are taken from the flow
        String filters = JSON.serialize(new Map<String, Object> {
            FILTER_EXPEDIENTE.toLowerCase() => inputs[0].Expediente,
            FILTER_IMBLNR.toLowerCase() => inputs[0].IMblnr,
            FILTER_IMJAHR.toLowerCase() => inputs[0].IMjahr
        });

        StockConsumptionCallout callout = new StockConsumptionCallout(filters);

        String responseBody = callout.invokeCallout().getBody(); //Call integration
		
        //Response parte
        Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        System.debug(responseBody);
        FlowOutputs fo = new FlowOutputs();

        if(respObject.containsKey('d')) { //If response is OK
            Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');

            fo.Result = innerObject.containsKey('Result') ? (String)innerObject.get('Result') : null;
            fo.EMblnrAnulres = innerObject.containsKey('EMblnrAnulres') ? (String)innerObject.get('EMblnrAnulres') : null;
            fo.EMajhrAnulres = innerObject.containsKey('EMajhrAnulres') ? (String)innerObject.get('EMajhrAnulres') : null;
            fo.EMblnrConsigna = innerObject.containsKey('EMblnrConsigna') ? (String)innerObject.get('EMblnrConsigna') : null;
            fo.EMjahrConsigna = innerObject.containsKey('EMjahrConsigna') ? (String)innerObject.get('EMjahrConsigna') : null;
            fo.EMblnrConsumo = innerObject.containsKey('EMblnrConsumo') ? (String)innerObject.get('EMblnrConsumo') : null;
            fo.EMjahrConsumo = innerObject.containsKey('EMjahrConsumo') ? (String)innerObject.get('EMjahrConsumo') : null;

        } else { //In case we got any errors
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
        public String Expediente;
        @InvocableVariable
        public String IMblnr;
        @InvocableVariable
        public String IMjahr;
    }
	//Flow output variable definition
    public class FlowOutputs {
        @InvocableVariable
        public String Result;
        @InvocableVariable
        public String EMblnrAnulres;
        @InvocableVariable
        public String EMajhrAnulres;
        @InvocableVariable
        public String EMblnrConsigna;
        @InvocableVariable
        public String EMjahrConsigna;
        @InvocableVariable
        public String EMblnrConsumo;
        @InvocableVariable
        public String EMjahrConsumo;
        @InvocableVariable
        public String errorMessage;
    }
}
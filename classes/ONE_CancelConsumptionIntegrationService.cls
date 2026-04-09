/**
 * Created by mbujak003 on 01.02.2021.
 */
//Class for the Cancel Consumption SAP integration
public with sharing class ONE_CancelConsumptionIntegrationService {

    public static String FILTER_IMBLNR = 'IMblnr'; // Hardcode parameter always the same
    public static String FILTER_IMJAHR = 'IMjahr'; // Hardcode parameter always the same

    public class CancelConsumptionCallout extends ONE_SAPCallout {
        public CancelConsumptionCallout(String filters) {
            super(ONE_CommonConstants.CM_SAP_CANCELCONSUMO, ONE_Integration.RestMethod.GET, ONE_CommonConstants.SAPSCOPE_CANCELCONSUMO); // Call SAP father class with integration call method

            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(filters);

            //Fullfill parameter for the request
            String IMblnr = (String)parsedParams.get(FILTER_IMBLNR.toLowerCase()); 
            String IMjahr = (String)parsedParams.get(FILTER_IMJAHR.toLowerCase());

            String filter = String.format(
                '({0}={1},{2}={3})',
                new List<String> {
                    FILTER_IMBLNR,
                    formatFilter(IMblnr),
                    FILTER_IMJAHR,
                    formatFilter(IMjahr)
                }
            );
            putParam('', filter);
        }
		
        //Build endpoint
        public override String buildEndpoint() {
            return super.buildEndpoint().remove('?=');
        }

        private String formatFilter(String filter) {
            return '\'' + filter + '\'';
        }
    }
	
    //invocable method to call integration from a flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        String filters = JSON.serialize(new Map<String, Object> {
            FILTER_IMBLNR.toLowerCase() => inputs[0].IMblnr,
            FILTER_IMJAHR.toLowerCase() => inputs[0].IMjahr
        });

        CancelConsumptionCallout callout = new CancelConsumptionCallout(filters);

        HTTPResponse resp = callout.invokeCallout();
        System.debug(resp);
        String responseBody = resp.getBody();

        //Parse flow output variables using responsre frin the integration
        Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
	
        FlowOutputs fo = new FlowOutputs();
		
        if(respObject.containsKey('d')) {
            Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
            System.debug(responseBody);
            fo.Result = innerObject.containsKey('EResult') ? (String)innerObject.get('EResult') : null;
            fo.EMblnr = innerObject.containsKey('EMblnr') ? (String)innerObject.get('EMblnr') : null;
            fo.EMajhr = innerObject.containsKey('EMjahr') ? (String)innerObject.get('EMjahr') : null;

        } else {
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
	//Input flow variable definition
    public class FlowInputs{
        @InvocableVariable
        public String IMblnr;
        @InvocableVariable
        public String IMjahr;
    }
    
    //Output flow variable definition
    public class FlowOutputs {
        @InvocableVariable
        public String Result;
        @InvocableVariable
        public String EMblnr;
        @InvocableVariable
        public String EMajhr;
        @InvocableVariable
        public String errorMessage;
    }
}
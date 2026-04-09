/**
 * Created by mbujak003 on 01.02.2021.
 */
//Stock reservation SAP integration callout
public with sharing class ONE_StockReservationIntegrationService {
	//Satic variable definition
    public static String FILTER_IZZAUFNR = 'IZzaufnr'; 
    public static String FILTER_IWERKS = 'IWerks';
    public static String FILTER_IMATNR = 'IMatnr';
    public static String FILTER_IMENGE = 'IMenge';
    public static String FILTER_IMEINS = 'IMeins';
    public static String FILTER_IXFUERZAWERKS = 'IXfuerzawerks';

    public class StockReservationCallout extends ONE_SAPCallout {
        public StockReservationCallout(String filters) {
            super(ONE_CommonConstants.CM_SAP_RESERVA_STOCK, ONE_Integration.RestMethod.GET, ONE_CommonConstants.SAPSCOPE_STOCK);

            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(filters);
			//Filter parameter population
            String IZzaufnr = (String)parsedParams.get(FILTER_IZZAUFNR.toLowerCase());
            String IWerks = (String)parsedParams.get(FILTER_IWERKS.toLowerCase());
            String IMatnr = (String)parsedParams.get(FILTER_IMATNR.toLowerCase());
            Integer IMenge = Integer.valueOf(parsedParams.get(FILTER_IMENGE.toLowerCase()));
            String IMeins = (String)parsedParams.get(FILTER_IMEINS.toLowerCase());
			Boolean IXfuerzawerks = Boolean.valueOf(parsedParams.get(FILTER_IXFUERZAWERKS.toLowerCase())!=null?parsedParams.get(FILTER_IXFUERZAWERKS.toLowerCase()):false);
			//Filter string creation
            String filter = String.format(
                '({0}={1},{2}={3},{4}={5},{6}={7},{8}={9},{10}={11})',
                new List<String> {
                    FILTER_IZZAUFNR,
                    formatFilter(IZzaufnr),
                    FILTER_IWERKS,
                    formatFilter(IWerks),
                    FILTER_IMATNR,
                    formatFilter(IMatnr),
                    FILTER_IMENGE,
                    String.valueOf(IMenge),
                    FILTER_IMEINS,
                    formatFilter(IMeins),
                    FILTER_IXFUERZAWERKS,
                    String.valueOf(IXfuerzawerks)
                }
            );
            putParam('',filter);
        }
		//Build endpoint using custom metada and created filter for the GET request
//        public override String buildEndpoint() {
//            String endpoint = super.buildEndpoint();
//            if(!params.isEmpty()) {
//                endpoint += params.values()[0];
//            }
//            return endpoint;
//        }

        public override String buildEndpoint() {
            return super.buildEndpoint().remove('?=');
        }

        private String formatFilter(String filter) {
            return '\'' + filter + '\'';
        }
    }
	//Invocable methos so we can call this integartion via flor
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        List<FlowOutputs> fouts = new List<FlowOutputs>();

        for(FlowInputs fi : inputs) {//Get filter parameter from flow input
            String filters = JSON.serialize(new Map<String, Object> {
                FILTER_IZZAUFNR.toLowerCase() => fi.IZzaufnr,
                FILTER_IWERKS.toLowerCase() => fi.IWerks,
                FILTER_IMATNR.toLowerCase() => fi.IMatnr,
                FILTER_IMENGE.toLowerCase() => fi.IMenge,
                FILTER_IMEINS.toLowerCase() => fi.IMeins,
                FILTER_IXFUERZAWERKS.toLowerCase() => fi.IXfuerzawerks
            });
            StockReservationCallout callout = new StockReservationCallout(filters);

            String responseBody = callout.invokeCallout().getBody(); //Make callout

            Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            System.debug(responseBody);
            FlowOutputs fo = new FlowOutputs();
            if(respObject.containsKey('d')) { // OK Response treatment
                Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
                if(innerObject != null) {
                    fo.EResult = innerObject.containsKey('EResult') ? (String)innerObject.get('EResult') : null;
                    fo.EMblnr = innerObject.containsKey('EMblnr') ? (String)innerObject.get('EMblnr') : null;
                    fo.EMjahr = innerObject.containsKey('EMjahr') ? (String)innerObject.get('EMjahr') : null;
                    fo.EWerks = innerObject.containsKey('EWerks') ? (String)innerObject.get('EWerks') : null;
                    fo.ELgort = innerObject.containsKey('ELgort') ? (String)innerObject.get('ELgort') : null;
                    fo.ELifnr = innerObject.containsKey('ELifnr') ? (String)innerObject.get('ELifnr') : null;
                }
            } else { // KO Response treatment
                if(respObject.containsKey('error')) {
                    Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('error');
                    Map<String, Object> message = (Map<String, Object>)innerObject.get('message');
                    System.debug(message);
                    fo.errorMessage = String.valueOf(message.get('value'));
                } else {
                    fo.errorMessage = 'Unexpected error';
                }
            }
            fouts.add(fo);
        }
        return fouts;
    }
	//Flow input variable definition
    public class FlowInputs {
        @InvocableVariable
        public String IZzaufnr;
        @InvocableVariable
        public String IWerks;
        @InvocableVariable
        public String IMatnr;
        @InvocableVariable
        public Decimal IMenge;
        @InvocableVariable
        public String IMeins;
        @InvocableVariable
        public Boolean IXfuerzawerks;
    }
	//Flow output variable definition
    public class FlowOutputs {
        @InvocableVariable
        public String EResult;
        @InvocableVariable
        public String EMblnr;
        @InvocableVariable
        public String EMjahr;
        @InvocableVariable
        public String EWerks;
        @InvocableVariable
        public String ELgort;
        @InvocableVariable
        public String ELifnr;
        @InvocableVariable
        public String errorMessage;
    }
}
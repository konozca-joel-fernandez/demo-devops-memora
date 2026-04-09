/**
 * Created by mbujak003 on 15.02.2021.
 * Last Edited by AlexCliment on 12.04.2023
 */
//SAP Saldo integraton call
public with sharing class ONE_SaldoIntegrationService {
    //Static variable definitino
    public static String PARAM_CLIENTE = 'Cliente';
    public static String PARAM_CONTRATO = 'ContratoElectium';
    public static String PARAM_SOCIEDAD = 'Sociedad';
    public static String PARAM_SOCIEDAD_1140 = '1140';
	//Extend SAP callout to get basic request
    public class SaldoCallout extends ONE_SAPCallout {
        public SaldoCallout(String params) {
            super(ONE_CommonConstants.CM_SAP_ZONE_ELECTIUM, ONE_Integration.RestMethod.GET, ONE_CommonConstants.SAPSCOPE_ELECTIUM);
			system.debug('bbb');
            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(params);
			//Populate integration call hardcode parameter
            String Cliente = (String)parsedParams.get(PARAM_CLIENTE.toLowerCase());
            String ContratoElectium = (String)parsedParams.get(PARAM_CONTRATO.toLowerCase());
            String Sociedad = (String)parsedParams.get(PARAM_SOCIEDAD.toLowerCase());
			system.debug('ccc parsedparams ' + parsedParams);
            String filter = String.format(
                '({0}={1},{2}={3},{4}={5})',
                new List<String> {
                    PARAM_CLIENTE,
                    formatFilter(Cliente),
                    PARAM_SOCIEDAD,
                    formatFilter(Sociedad),
                    PARAM_CONTRATO,
                    formatFilter(ContratoElectium)
                }
            );
            putParam('',filter);
            system.debug('ddd');
        }
		//Get endpoint basic data and add parameters
        public override String buildEndpoint() {
            return super.buildEndpoint().remove('?=');
        }

        private String formatFilter(String filter) {
            return '\'' + EncodingUtil.urlEncode(filter, ONE_Integration.ENCODING_UTF8) + '\'';
        }
    }
	//Get filter parameter to add to the GET request
    private static Map<String, Object> prepareFilters(String contratoId) {
        ONE_Contrato__c contrato = [
            SELECT Id, ONE_Contratante__r.ONE_ID_Cliente_SAP__pc, Name
            FROM ONE_Contrato__c
            WHERE Id =: contratoId
        ];

        Map<String, Object> filters = new Map<String, Object> {
            PARAM_CLIENTE.toLowerCase() => contrato.ONE_Contratante__r.ONE_ID_Cliente_SAP__pc,
            PARAM_SOCIEDAD.toLowerCase() => PARAM_SOCIEDAD_1140,
            PARAM_CONTRATO.toLowerCase() => contrato.Name
        };
        return filters;
    }
	//invocable method to call integration
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        String filters = JSON.serialize(prepareFilters(inputs[0].contratoId));
        system.debug('filters + ' + filters);
        
        SaldoCallout callout = new SaldoCallout(filters);
		system.debug('callout + ' + callout);
        
        String responseBody = callout.invokeCallout(false).getBody();
        system.debug('responseBody + ' + responseBody);

        Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
		
        system.debug('respObject + ' + respObject);
        system.debug('innerObject + ' + innerObject);
        
        system.debug('Se invoca correctamente la clase');
        
        FlowOutputs fo = new FlowOutputs();
        if(innerObject != null) {
            system.debug('Hay inner object ');
            fo.Importe = innerObject.containsKey('Importe') ? (String)innerObject.get('Importe') : null;
            fo.ImporteCobrado = innerObject.containsKey('ImporteCobrado') ? (String)innerObject.get('ImporteCobrado') : null;
            fo.EResult = innerObject.containsKey('EResult') ? (String)innerObject.get('EResult') : null;
            fo.TotalCuotasImpagadas = innerObject.containsKey('TotalCuotasImpagadas') ? (String)innerObject.get('TotalCuotasImpagadas') : null;
            fo.TotalImporteImpagado = innerObject.containsKey('TotalImporteImpagado') ? (String)innerObject.get('TotalImporteImpagado') : null;
        }
        system.debug('FlowOutputs ' + fo);
        return new List<FlowOutputs> { fo };
            
    }
	//Flowinput variable definitnion
    public class FlowInputs {
        @InvocableVariable
        public String contratoId;
    }
	//Flow output variable definitio
    public class FlowOutputs {
        @InvocableVariable
        public String Importe;
        @InvocableVariable
        public String ImporteCobrado;
        @InvocableVariable
        public String EResult;
        @InvocableVariable
        public String TotalCuotasImpagadas;
        @InvocableVariable
        public String TotalImporteImpagado;
    }
}
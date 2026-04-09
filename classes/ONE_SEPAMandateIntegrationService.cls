/**
 * Created by mbujak003 on 03.02.2021.
 */
//SEPA Mandate SAP integration service callout class
public with sharing class ONE_SEPAMandateIntegrationService {
	//Extend SAP Callout for basic request structure
    public class SEPAMandateCallout extends ONE_SAPCallout {
        public SEPAMandateCallout(SEPAMandateCalloutRequest orderRequest) {
            super(ONE_CommonConstants.CM_SAP_SEPAMANDATE, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_SEPA);
            setBody(JSON.serialize(orderRequest).replace('null', '""').replace('x_number', 'number').replace('x_return', 'return'));
        }
    }
	//Invocable method to call SEPA integration from the flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        Map<Id, SEPAMandateCalloutRequest> accId2PurchaseOrderRequest = prepareDTORequests(flowInputs[0].ordenDeVentaId); // Prepare request
        SEPAMandateCallout callout = new SEPAMandateCallout(accId2PurchaseOrderRequest.values()[0]);
        HttpResponse resp = callout.invokeCallout(); // Do callout

        System.debug('@@@@@Body');
        System.debug(resp.getBody());
        FlowOutputs fo = new FlowOutputs();
		//Try response parser
        try {
            Map<String, Object> responseKey2Value = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            fo.success = false;
            if(responseKey2Value.containsKey('d')) { // If OK response
                Map<String, Object> innerObjectKey2Value = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseKey2Value.get('d')));
                Map<String, Object> resultKey2Value = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(innerObjectKey2Value.get('return')));
                if(resultKey2Value.containsKey('Result') && resultKey2Value.get('Result') == 'S') {
                    fo.success = true;
                }
            }
        } catch(Exception ex) {
            fo.success = false;
        }
        System.debug( fo );
        return new List<FlowOutputs> { fo };
    }
	//Flow input variable definition
    public class FlowInputs {
        @InvocableVariable
        public String ordenDeVentaId;
    }
	//Flow output variable definition
    public class FlowOutputs {
        @InvocableVariable
        public Boolean success;
    }
	//SEPA mandate request data population
    public static Map<Id, SEPAMandateCalloutRequest> prepareDTORequests(String ordenDeVentaId) {
        Map<Id, SEPAMandateCalloutRequest> ordenId2PurchaseOrderRequest = new Map<Id, SEPAMandateCalloutRequest>();
        ONE_Orden_De_Venta__c ordenDeVenta = [
            SELECT Id, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.BillingCity,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.BillingStreet,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.BillingPostalCode,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.BillingCountry,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio_Direccion__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Pais__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_Postal__c,
                ONE_IBAN__c, ONE_Pagador_Particular__r.ONE_Contacto__r.RecordTypeId,
                ONE_Reference_Id_Mandato_SEPA__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id =: ordenDeVentaId
        ];
        SEPAMandateCalloutRequest request = new SEPAMandateCalloutRequest(ordenDeVenta);
        ordenId2PurchaseOrderRequest.put(ordenDeVenta.Id, request);
        return ordenId2PurchaseOrderRequest;
    }
	//SEPA mandate request data structure definition
    public class SEPAMandateCalloutRequest {
        public String referenceId { get; set; }
        public String citySign { get; set; }
        public String creditorNumber { get; set; }
        public String sapIdC { get; set; }
        public String name { get; set; }
        public String primaryAddressStreet { get; set; }
        public String primaryAddressNumberC { get; set; }
        public String primaryAddressPostalcode { get; set; }
        public String primaryAddressCity { get; set; }
        public String primaryAddressCountry { get; set; }
        public String ibanC { get; set; }
        public String swiftBicC { get; set; }
        public String societyId { get; set; }
        public String societyName { get; set; }
        public String streetName { get; set; }
        public String x_number { get; set; }
        public String postalCode { get; set; }
        public String cityRec { get; set; }
        public String countryId { get; set; }
        public List<String> messageReturn { get; set; }
        public Map<String, String> x_return { get; set; }
		//Create request data factory
        public SEPAMandateCalloutRequest(ONE_Orden_De_Venta__c ordenDeVenta) {
            referenceId = ordenDeVenta?.ONE_Reference_Id_Mandato_SEPA__c;
            citySign = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Municipio_Direccion__c?.toUpperCase();
            creditorNumber = '';

            if(ordenDeVenta?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.RecordTypeId ==
                ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS)) {
                sapIdC = ordenDeVenta?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase();
            } else {
                sapIdC = ordenDeVenta?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();
            }

            name = '';
            primaryAddressStreet = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Direccion__c?.toUpperCase();
            primaryAddressNumberC = '';
            primaryAddressPostalcode = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_Postal__c?.toUpperCase();
            primaryAddressCity = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.BillingCity?.toUpperCase();
            primaryAddressCountry = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Pais__c?.toUpperCase();
            ibanC = ordenDeVenta.ONE_IBAN__c?.toUpperCase();
            swiftBicC = '';
            societyId = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad__c?.toUpperCase();
            societyName = '';
            streetName = '';
            x_number = '';
            postalCode = '';
            cityRec = '';
            countryId = ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Pais__c?.toUpperCase();
            messageReturn = new List<String>();
            x_return = new Map<String, String> { 'Result' => '' };
        }
    }
}
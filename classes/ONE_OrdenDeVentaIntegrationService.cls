/**
 * Created by jgabryeniak on 26.08.2021.
 */

public with sharing class ONE_OrdenDeVentaIntegrationService {
    //Static variable definiton
    public static final String INTERLOCUTOR_ID = '200000005';
	//Extend SAP callout
    public class TpvPaymentCallout extends ONE_SAPCallout {
        public TpvPaymentCallout(TpvPaymentRequest tpvRequest) {
            super(ONE_CommonConstants.CM_SAP_TPV_PAYMENT, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_PAYMENT);
            setBody(JSON.serialize(tpvRequest).replaceAll('x_', ''));
        }
    }
	//Invocable method definition
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        Map<Id, TpvPaymentRequest> ordenId2RequestMap = prepareDtoRequest(inputs[0].ordenId);
        TpvPaymentCallout callout = new TpvPaymentCallout(ordenId2RequestMap .values()[0]);
        HttpResponse resp = callout.invokeCallout(); // SAP Callout

        String responseBody = resp.getBody(); // Get body from the request

        Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        System.debug(respObject);
        Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');

        FlowOutputs fo = new FlowOutputs();
        System.debug(JSON.serialize(innerObject));
        try {
            //Set output values from the response
            Map<String, Object>  ret = (Map<String, Object>)innerObject.get('messageReturn');
            List<Object> results = (List<Object>)ret.get('results');

            fo.type = String.valueOf(((Map<String, Object>)results[0]).get('Type'));
            fo.tpvId = String.valueOf(((Map<String, Object>)results[0]).get('Id'));
            fo.tpvNumero = String.valueOf(((Map<String, Object>)results[0]).get('Number'));
            fo.message = String.valueOf(((Map<String, Object>)results[0]).get('Message'));

        } catch(Exception ex) {
            fo.message = 'error';
            fo.tpvId = '';
            fo.tpvNumero ='';
            fo.type = '';
        }

        return new List<FlowOutputs> { fo };
    }

    public static Map<Id,TpvPaymentRequest> prepareDtoRequest(String ordenId) {
        //Get information from sales order
        List<ONE_Orden_De_Venta__c> orden = [
                SELECT ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c,
                        ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c, ONE_Tipo_De_Factura__c,
                        ONE_Pagador_Compania__c, ONE_Pagador_Particular__c, ONE_TPV_Datafono__r.Name,
                        ONE_Pagador_Particular__r.ONE_Contacto__r.RecordTypeId, ONE_Importe_Total__c,
                        ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__c, ONE_Moneda__c,
                        ONE_Numero_de_factura__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                        ONE_TPV_Datafono__r.ONE_Codigo_Cuenta_Contable_SAP__c, ONE_Pagador_Particular__r.ONE_Contacto__c
                FROM ONE_Orden_De_Venta__c
                WHERE Id = :ordenId
        ];

        String recordTypeName =
            Schema.getGlobalDescribe().get(ONE_CommonConstants.ACCOUNT).getDescribe().getRecordTypeInfosById().get(orden[0].ONE_Pagador_Particular__r.ONE_Contacto__r.RecordTypeId).getName();

        TpvPaymentRequest tpv = new TpvPaymentRequest(orden[0], recordTypeName);
        Map<Id, TpvPaymentRequest> tpr = new Map<Id, TpvPaymentRequest>();
        tpr.put(ordenId, tpv);
        return tpr;
    }
	//Flow input variable definiton
    public class FlowInputs {
        @InvocableVariable
        public String ordenId;
    }
	//Flow output variable definiton
    public class FlowOutputs {
        @InvocableVariable
        public String type;
        @InvocableVariable
        public String tpvId;
        @InvocableVariable
        public String tpvNumero;
        @InvocableVariable
        public String message;
    }
	//TPV Payment request data model definiton
    public class TpvPaymentRequest {
        public String operatingCenterId { get; private set; }
        public String sapInterlocutorId { get; private set; }
        public String asignacion { get; private set; }
        public String amount { get; private set; }
        public String invoiceNumber { get; private set; }
        public String societyId { get; private set; }
        public String currencyId { get; private set; }
        public String accountNumber { get; private set; }
        public List<String> x_messageReturn { get; set; }
        //public String { get; private set; }

        public TpvPaymentRequest(ONE_Orden_De_Venta__c orden, String recordTypeName) {
            x_messageReturn = new List<String>();
            operatingCenterId = orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c;
            sapInterlocutorId = '';
            asignacion = orden.ONE_TPV_Datafono__r.Name;
            amount = String.valueOf(orden.ONE_Importe_Total__c);
            invoiceNumber = orden.ONE_Numero_de_factura__c;
            societyId = orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c;
            currencyId = orden.ONE_Moneda__c;
            accountNumber = orden.ONE_TPV_Datafono__r.ONE_Codigo_Cuenta_Contable_SAP__c;

            if (orden.ONE_Tipo_De_Factura__c == '01') {
                if (String.isNotEmpty(orden.ONE_Pagador_Compania__c)) {
                    sapInterlocutorId = orden.ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c;
                } else if (recordTypeName == ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS
                    || recordTypeName == ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)
                    {
                    sapInterlocutorId = orden.ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__c;
                }
            } else if (orden.ONE_Tipo_De_Factura__c == '02'){
                sapInterlocutorId = INTERLOCUTOR_ID;
            }
        }
    }
}
//Stock consumption SAP integration definition 
 public with sharing class ONE_StockMovementIntegrationService {

    public class StockMovementCallout extends ONE_SAPCallout {

        public StockMovementCallout(StockMovementRequest stockMovementRequest) {

            super(ONE_CommonConstants.CM_SAP_STOCKMOVEMENT, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_TRASLADOSMAT);
            setBody(JSON.serialize(stockMovementRequest).replaceAll('x_', ''));
        }
    }

    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {

        Map<Id, StockMovementRequest> tareaId2RequestMap = prepareDtoRequest(inputs[0].tareaId);
        StockMovementCallout callout = new StockMovementCallout(tareaId2RequestMap.values()[0]);
        HttpResponse resp = callout.invokeCallout(); // SAP Callout

        System.debug('@@@@@Body');
        System.debug(resp.getBody());
        FlowOutputs fo = new FlowOutputs();
        
        Map<String, Object> responseKey2Value = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

        if (responseKey2Value.containsKey('error')) {

            try {
                Map<String, Object> error = (Map<String, Object>) responseKey2Value.get('error');
                Map<String, Object> innerError = (Map<String, Object>) error.get('innererror');
                List<Object> errorDetails = (List<Object>) innerError.get('errordetails');
                String msgString = '';

                for (Object obj : errorDetails) {
                    Map<String, Object> errorDetailItem = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                    msgString += errorDetailItem.containsKey('message') && String.isNotEmpty((String) errorDetailItem.get('message')) ? errorDetailItem.get('message') + ' | ' : '';
                }

                if (msgString.endsWith(' | ')) {
                    msgString = msgString.removeEnd(' | ');
                }

                fo.Result = 'SAP ERROR';
                fo.message = 'Error de SAP: '+ msgString + '. Contacte con un administrador.';

            } catch (Exception ex) {

                fo.message = 'APEX EXCEPTION: ' + ex.getTypeName() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
                fo.Result = JSON.serialize(responseKey2Value);
            }

            return new List<FlowOutputs>{
                fo
            };
        }

        else if (responseKey2Value.containsKey('d')) {

            try {
                Map<String, Object> innerObject = (Map<String, Object>) responseKey2Value.get('d');
                Map<String, Object> result = (Map<String, Object>) innerObject.get('result');
    
                fo.Result = (String) result.get('Result');
                Map<String, Object> returnSet = (Map<String, Object>) innerObject.get('ReturnSet');
                List<Object> results = (List<Object>) returnSet.get('results');
    
                if (fo.Result == 'S') {
                    String messageV1 = '';
                    String messageV2 = '';
                    for (Object obj : results) {
                        Map<String, Object> singleObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                        messageV2 = (String) singleObject.get('MessageV2');
                        if (messageV2.startsWith('344')) {
                            fo.reservationNumber = (String) singleObject.get('MessageV1');
                            break;
                        }
                    }
                }
                else {
                    String msgString = '';
                    for (Object obj : results) {
                        Map<String, Object> singleObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                        if ((singleObject.containsKey('Type') && singleObject.get('Type') == 'E')) {
                            msgString += singleObject.containsKey('Message') && String.isNotEmpty((String) singleObject.get('Message')) ?
                                singleObject.get('Message') + ' | ' : '';
                        }
                    }
                    if (msgString.endsWith(' | ')) {
                        msgString = msgString.removeEnd(' | ');
                    }
                    fo.message = msgString + '. Contacte con un administrador.';
                }
            }
            catch (Exception ex) {
                fo.message = 'APEX EXCEPTION: ' + ex.getTypeName() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
                fo.Result = JSON.serialize(responseKey2Value);
            }
        }

        return new List<FlowOutputs>{
            fo
        };
    }

    public static Map<Id,StockMovementRequest> prepareDtoRequest(String tareaId) {

        //Get information from Tarea
        List<ONE_Tarea__c> tarea = [
                SELECT
                    ONE_Centro_De_Reserva__c,
                    ONE_Almacen__c,
                    ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c,
                    ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_ID_Almacen_SAP__C,
                    ONE_Cantidad__c,
                    ONE_Expediente__r.Name,
                    ONE_SKU__c,
                    ONE_Proveedor_Consigna__c
                FROM ONE_Tarea__c
                WHERE Id = :tareaId
        ];

        StockMovementRequest stockMovementRequest = new StockMovementRequest(tarea[0]);
        Map<Id, StockMovementRequest> stockMovementRequestMap = new Map<Id, StockMovementRequest>();
        stockMovementRequestMap.put(tareaId, stockMovementRequest);
        return stockMovementRequestMap;
    }

	//Flow input variable definiton
    public class FlowInputs {

        @InvocableVariable
        public String tareaId;
    }

	//Flow output variable definiton
    public class FlowOutputs {

        @InvocableVariable
        public String Result;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public String reservationNumber;
    }

    //Stock Movement request data model definiton
    public class ResultObject {
        public String Result { get; private set; }

        public ResultObject() {
            Result = '';
        }
    }

	//Stock Movement request data model definiton
    public class StockMovementRequest {

        public String AlmDestino { get; private set; }
        public String AlmOrigen { get; private set; }
        public String Cantidad { get; private set; }
        public String CenDestino { get; private set; }
        public String CenOrigen { get; private set; }
        public String Expediente { get; private set; }
        public String Material { get; private set; }
        public String Proveedor { get; private set; }
        public ResultObject result { get; private set; }
        public List<Object> ReturnSet { get; private set; }

        public StockMovementRequest(ONE_Tarea__c tarea) {

            AlmDestino = tarea.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_ID_Almacen_SAP__c != null ? tarea.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_ID_Almacen_SAP__c : '';
            AlmOrigen = tarea.ONE_Almacen__c != null ? tarea.ONE_Almacen__c : '';
            Cantidad = String.valueOf(tarea.ONE_Cantidad__c);
            CenDestino = tarea.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c  != null ? tarea.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c : '';
            CenOrigen = tarea.ONE_Centro_De_Reserva__c  != null ? tarea.ONE_Centro_De_Reserva__c : '';
            Expediente = tarea.ONE_Expediente__r.Name  != null ? tarea.ONE_Expediente__r.Name : '';
            Material = tarea.ONE_SKU__c  != null ? tarea.ONE_SKU__c : '';
            Proveedor = tarea.ONE_Proveedor_Consigna__c  != null ? tarea.ONE_Proveedor_Consigna__c : '';
            result = new ResultObject();
            ReturnSet = new List<Object>{
                new Map<String, Object>()
            };
        }
    }
}
/**
 * Created by mbujak003 on 25.01.2021.
 */
//Class to call purchase order (Orden de compra) SAP integration services
public with sharing class ONE_PurchaseOrderIntegrationService {

    public static Integer count = 1;
    
    public class customException extends Exception {}

	//Extend SAP basic integartion method for authentication call and basic request structure
    public class PurchaseOrderCallout extends ONE_SAPCallout {
        public PurchaseOrderCallout(PurchaseOrderRequest orderRequest) {
            super(ONE_CommonConstants.CM_SAP_PURCHASEORDER, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_PURCHASEORDER);
            setBody(JSON.serialize(orderRequest).replace('null', '""'));
        }
    }
	//Invocable method definition so we can call the integraton from Flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        
       Map<String, String> fis = new Map<String, String>();
        //Get integration inputs from flow inputs
        for(FlowInputs fi : flowInputs) {
            fis.put(fi.pedidoDeProvedoorId, fi.code);
        }
        Map<Id, PurchaseOrderRequest> tareaId2PurchaseOrderRequest = flowInputs[0].M1 ? prepareM1DTORequests(fis) : prepareDTORequests(fis);
        PurchaseOrderCallout callout = new PurchaseOrderCallout(tareaId2PurchaseOrderRequest.values()[0]);
        HttpResponse resp = callout.invokeCallout(); // Integration callout

        Map<String, Object> returnObject = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody()); // deserialize object

        if(returnObject.get('error') != null){
            Map<String, Object> errorMsg = (Map<String, Object>)returnObject.get('error');
            Map<String, Object> errorMsgValue = (Map<String, Object>)errorMsg.get('message');
            throw new customException('No se ha recibido una respuesta exitosa desde SAP: ' + (String)errorMsgValue.get('value'));
        }

        Map<String, Object> innerObject = (Map<String, Object>)returnObject.get('d');// d in case we got a success response
        Map<String, Object> result = (Map<String, Object>)innerObject.get('result');

        FlowOutputs fo = new FlowOutputs(); // Prepare flow output variable

        Boolean wasSuccess = (String)result.get('Result') != 'E';


        Map<String, Object> msgReturn = (Map<String, Object>)innerObject.get('messageReturn');
        List<Object> results = (List<Object>)msgReturn.get('results');

        String msgString = '';
        //Parse message response to store all error message and warnings
        for(Object obj : results) {
            Map<String, Object> singleObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            if((singleObject.containsKey('Type') && singleObject.get('Type') == 'E' && !wasSuccess) ||
                (singleObject.containsKey('Type') && singleObject.get('Type') == 'S' && wasSuccess)) {
                msgString += singleObject.containsKey('Message') && String.isNotEmpty((String)singleObject.get('Message')) ?
                    singleObject.get('Message') + ' | ' : '';
            }
        }
        if(msgString.endsWith(' | ')) {
            msgString = msgString.removeEnd(' | ');
        }

        fo.message = msgString;
        fo.EResult = (String)result.get('EResult');

        return new List<FlowOutputs> { fo };
    }
	//Flow input variabe definition
    public class FlowInputs {
        @InvocableVariable
        public String pedidoDeProvedoorId;
        @InvocableVariable
        public String code;
        @InvocableVariable
        public Boolean M1;
    }
	//Flow output variabe definition
    public class FlowOutputs {
        @InvocableVariable
        public String message;
        @InvocableVariable
        public String EResult;
    }
	//Prepare request structure for the purchase order
    public static Map<Id, PurchaseOrderRequest> prepareDTORequests(Map<String, String> pedidoDeProveedorId2Code) {
        Map<Id, PurchaseOrderRequest> pedidoDeProveedor2PurchaseOrderRequest = new Map<Id, PurchaseOrderRequest>();

        Map<String, List<ONE_Tarea__c>> pedidoId2Tareas = new Map<String, List<ONE_Tarea__c>>();

        for(ONE_Tarea__c tarea : ONE_TareaHelper.fetchTareasByPedidoId(pedidoDeProveedorId2Code.keySet())) {
            if (!pedidoId2Tareas.containsKey(tarea.ONE_Pedido_De_Proveedor__c)) {
                pedidoId2Tareas.put(tarea.ONE_Pedido_De_Proveedor__c, new List<ONE_Tarea__c> { tarea });
            } else {
                pedidoId2Tareas.get(tarea.ONE_Pedido_De_Proveedor__c).add(tarea);
            }
        }
        for(String key : pedidoId2Tareas.keySet()) {
            List<POItem> poItems = new List<POItem>();
            for(ONE_Tarea__c tarea : pedidoId2Tareas.get(key)) {
                poItems.add(new POItem(tarea));
            }

            PurchaseOrderRequest request = new PurchaseOrderRequest(
                pedidoId2Tareas.get(key)[0],
                new POHeader(pedidoId2Tareas.get(key)[0]),
                poItems,
                new List<POReturn> { new POReturn() },
                new List<POProcess> { new POProcess(pedidoId2Tareas.get(key)[0]) }
            );
            pedidoDeProveedor2PurchaseOrderRequest.put(key, request);
        }


        return pedidoDeProveedor2PurchaseOrderRequest;
    }
    //Prepare M1 request structure for the purchase order
    public static Map<Id, PurchaseOrderRequest> prepareM1DTORequests(Map<String, String> pedidoDeProveedorId2Code) {
        Map<Id, PurchaseOrderRequest> pedidoDeProveedor2PurchaseOrderRequest = new Map<Id, PurchaseOrderRequest>();
		List<ONE_Expediente_Line_Item__c> SLIS = [SELECT Id, ONE_Pedido_de_Proveedor_M1__r.Name, ONE_Pedido_de_Proveedor_M1__c,
                                           ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c, 
                                           ONE_Pedido_de_Proveedor_M1__r.ONE_Proveedor__r.ONE_ID_Proveedor_SAP__c,
                                           ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Organizacion_De_Compras__c,
                                           ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Moneda__c,
                                           ONE_Pedido_de_Proveedor_M1__r.ONE_Fecha__c, ONE_Pedido_de_Proveedor_M1__r.ONE_Fecha_contabilizaci_n__c,
                                           ONE_Expediente__r.Name, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c, ONE_Importe_Base__c,
                                           ONE_Cantidad__c, ONE_Producto__r.ONE_Codigo_SAP__c, ONE_Producto__r.Name, ONE_Pedido_de_Proveedor_M1__r.ONE_Codigo_Retorno_SAP__c,
                                           ONE_Pedido_de_Proveedor_M1__r.ONE_Mensaje_Respuesta_SAP__c, ONE_Suplido__c, ONE_Importe_Neto__c
                                           FROM ONE_Expediente_Line_Item__c 
                                           WHERE ONE_Pedido_de_Proveedor_M1__c IN :pedidoDeProveedorId2Code.keySet() AND ONE_Estado__c != 'Cancelado'];
        List<POItem> poItems = new List<POItem>();
            for(ONE_Expediente_Line_Item__c SLI : SLIS) {
                poItems.add(new POItem(SLI));
            }
        PurchaseOrderRequest request = new PurchaseOrderRequest(
            SLIS,
            new POHeader(SLIS[0]),
            poItems,
            new List<POReturn> { new POReturn() },
            new List<POProcess> { new POProcess(SLIS[0]) }
        );
        pedidoDeProveedor2PurchaseOrderRequest.put(SLIS[0].ONE_Pedido_de_Proveedor_M1__c, request);
        return pedidoDeProveedor2PurchaseOrderRequest;
    }
	//Helper method to build date in the expected SAP format
    public static String buildDate(Date dateToProcess) {
        return String.format(
            '\\/Date({0})\\/',
            new List<String> {
                String.valueOf(Datetime.newInstanceGmt(dateToProcess.year(), dateToProcess.month(), dateToProcess.day()).getTime())
            }
        );
    }
	//Purchase order header data structure definition
    public class POHeader {
        public String orderId { get; private set; }
        public String societyId { get; private set; }
        public String providerId { get; private set; }
        public String areaId { get; private set; }
        public String currencyId { get; private set; }
        public String orderDate { get; private set; }
        public String fechaCont { get; private set; }
        public String expedientId { get; private set; }

        public POHeader(ONE_Tarea__c tarea) {
            orderId = tarea?.ONE_Pedido_De_Proveedor__r?.Name?.toUpperCase();
            societyId = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Expediente__c != null ?
                        tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad__c?.toUpperCase() :
                        tarea?.ONE_Aviso__r?.ONE_Centro_del_Servicio__r?.ONE_Sociedad__c?.toUpperCase();
            providerId = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Proveedor__r?.ONE_ID_Proveedor_SAP__c?.toUpperCase();
            areaId = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Expediente__c != null ?
                     tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Organizacion_De_Compras__c?.toUpperCase() :
                     tarea?.ONE_Aviso__r?.ONE_Centro_del_Servicio__r?.ONE_Organizacion_De_Compras__c?.toUpperCase();
            currencyId = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Expediente__c != null?
                         tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Moneda__c?.toUpperCase() :
                         tarea?.ONE_Aviso__r?.ONE_Centro_del_Servicio__r?.ONE_Moneda__c?.toUpperCase();
            orderDate = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Fecha__c!= null ? buildDate(tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Fecha__c):buildDate(date.today());
            fechaCont = tarea.ONE_Pedido_De_Proveedor__r?.ONE_Fecha_contabilizaci_n__c != null ? buildDate(tarea.ONE_Pedido_De_Proveedor__r.ONE_Fecha_contabilizaci_n__c) : buildDate(date.today());
            expedientId = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Expediente__r?.Name?.toUpperCase();
        }
        
        public POHeader(ONE_Expediente_Line_Item__c SLI){
            orderId = SLI?.ONE_Pedido_de_Proveedor_M1__r?.Name?.toUpperCase();
            societyId = SLI?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad__c?.toUpperCase();
            providerId = SLI?.ONE_Pedido_de_Proveedor_M1__r?.ONE_Proveedor__r?.ONE_ID_Proveedor_SAP__c?.toUpperCase();
            areaId = SLI?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Organizacion_De_Compras__c?.toUpperCase();
            currencyId = SLI?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Moneda__c?.toUpperCase();
            orderDate = SLI?.ONE_Pedido_de_Proveedor_M1__r?.ONE_Fecha__c!= null ? buildDate(SLI?.ONE_Pedido_de_Proveedor_M1__r.ONE_Fecha__c):buildDate(date.today());
            fechaCont = SLI?.ONE_Pedido_de_Proveedor_M1__r?.ONE_Fecha_contabilizaci_n__c != null ? buildDate(SLI?.ONE_Pedido_de_Proveedor_M1__r.ONE_Fecha_contabilizaci_n__c) : buildDate(date.today());
            expedientId = SLI?.ONE_Expediente__r?.Name?.toUpperCase();
        }
    }
	//Purchase order linte item data structure definition
    public class POItem {
        public String orderId { get; private set; }
        public String positionId { get; private set; }
        public String packProductDesc { get; private set; }
        public String sapReference { get; private set; }
        public String operatingCenterId { get; private set; }
        public String warehouseId { get; private set; }
        public String providerMaterialCode { get; private set; }
        public String quantity { get; private set; }
        public String measure { get; private set; }
        public String grossValue { get; private set; }
        public String employeeSapReferenceId { get; private set; }
        public String accountNumber { get; private set; }

        public POItem(ONE_Expediente_Line_Item__c SLI) {
            orderId = SLI?.ONE_Pedido_de_Proveedor_M1__r?.Name;
            //packProductDesc = SLI?.ONE_Producto__r?.Name;
            packProductDesc =SLI?.ONE_Producto__r?.Name.length() < 39 ?SLI?.ONE_Producto__r?.Name : SLI?.ONE_Producto__r?.Name.substring(0,38);
            sapReference = SLI?.ONE_Suplido__c == true ? '200000511' /* (SAP CERR) '200000530' */: SLI?.ONE_Producto__r?.ONE_Codigo_SAP__c;
            quantity = String.valueOf(SLI?.ONE_Cantidad__c);
            grossValue = SLI?.ONE_Suplido__c == true ? String.valueOf(SLI?.ONE_Importe_Neto__c) : String.valueOf(SLI?.ONE_Importe_Base__c);
            operatingCenterId = String.valueOf(SLI?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_De_Centro__c);
            positionId = String.valueOf(count);
            count = count + 1;
        }
        
        public POItem(ONE_Tarea__c tarea) {
            orderId = tarea?.ONE_Pedido_De_Proveedor__r?.Name;
            //packProductDesc = tarea?.ONE_Producto__r?.Name;
            packProductDesc =tarea?.ONE_Producto__r?.Name.length() < 39 ?tarea?.ONE_Producto__r?.Name : tarea?.ONE_Producto__r?.Name.substring(0,38);
            sapReference = tarea?.ONE_Producto__r?.ONE_Codigo_SAP__c;
            quantity = String.valueOf(tarea?.ONE_Cantidad__c);
            grossValue = String.valueOf(tarea?.ONE_Precio_De_Compra__c);
            operatingCenterId = tarea?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_De_Centro__c != null ?
                                String.valueOf(tarea?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_De_Centro__c) :
                                String.valueOf(tarea?.ONE_Aviso__r?.ONE_Centro_del_Servicio__r?.ONE_Codigo_De_Centro__c);
            positionId = String.valueOf(tarea?.ONE_Posicion_Pedido__c);
        }
    }

    public class POReturn {
        //empty class -> no documentation info about this object
    }
	//Purchase order data structure response definition
    public class POProcess {
        public String orderId { get; private set; }
        public String code { get; private set; }
        public String message { get; private set; }

        public POProcess(ONE_Expediente_Line_Item__c SLI) {
            orderId = SLI?.ONE_Pedido_de_Proveedor_M1__r?.Name;
            code = SLI?.ONE_Pedido_de_Proveedor_M1__r?.ONE_Codigo_Retorno_SAP__c;
            message = SLI?.ONE_Pedido_de_Proveedor_M1__r?.ONE_Mensaje_Respuesta_SAP__c;
        }
        
        public POProcess(ONE_Tarea__c tarea) {
            orderId = tarea?.ONE_Pedido_De_Proveedor__r?.Name;
            code = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Codigo_Retorno_SAP__c;
            message = tarea?.ONE_Pedido_De_Proveedor__r?.ONE_Mensaje_Respuesta_SAP__c;
        }
    }
	//Purchase order request data structure definition
    public class PurchaseOrderRequest {
        public String orderId { get; private set; }
        public POHeader POHeaderData { get; private set; }
        public List<POItem> POItemDataSet { get; private set; }
        public List<POReturn> messageReturn { get; private set; }
        public List<POProcess> ProcessSet { get; private set; }
        public Map<String, String> result { get; private set; }
        public PurchaseOrderRequest(
            List<ONE_Expediente_Line_Item__c> SLI,
            POHeader newPOHeaderData,
            List<POItem> newPOItemDataSet,
            List<POReturn> newMessageReturn,
            List<POProcess> newProcessSet) {
            orderId = SLI[0]?.ONE_Pedido_de_Proveedor_M1__r?.Name;
            POHeaderData = newPOHeaderData;
            POItemDataSet = newPOItemDataSet;
            messageReturn = newMessageReturn;
            ProcessSet = newProcessSet;
            result = new Map<String, String> {
                'EResult' => '',
                'Result' => ''
            };
        }
        public PurchaseOrderRequest(
            ONE_Tarea__c tarea,
            POHeader newPOHeaderData,
            List<POItem> newPOItemDataSet,
            List<POReturn> newMessageReturn,
            List<POProcess> newProcessSet) {
            orderId = tarea?.ONE_Pedido_De_Proveedor__r?.Name;
            POHeaderData = newPOHeaderData;
            POItemDataSet = newPOItemDataSet;
            messageReturn = newMessageReturn;
            ProcessSet = newProcessSet;
            result = new Map<String, String> {
                'EResult' => '',
                'Result' => ''
            };
        }
    }
}
/**
 * Created by mbujak003 on 03.03.2021.
 * 
 * Mod:
 * Overwrite SAP Id when SLI has ONE_Sobreescribir_Codigo_Sap__c filled on 24.05.24 by Miguel Serrat
 */

public with sharing class ONE_SalesOrderIntegrationService {
    private static String CLASS_NAME = 'ONE_SalesOrderIntegrationService';

    private static Map<Id, String> userId2CodigoUsuarioSAP;

 
    public class SalesOrderCallout extends ONE_SAPCallout {
        public SalesOrderCallout(SalesOrderCalloutRequest orderRequest) {
            super(ONE_CommonConstants.CM_SAP_SALESORDER, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_SALESORDER);
            setBody(JSON.serialize(orderRequest).replace('null', '""').replace('x_', ''));
        }
    }

    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        Map<Id, SalesOrderCalloutRequest> accId2PurchaseOrderRequest;
        try {
            accId2PurchaseOrderRequest = prepareDTORequests(flowInputs[0].ordenDeVentaId);
        } catch (CustomValidationException ex) {
            FlowOutputs fo = new FlowOutputs();
            fo.Result = 'E';
            fo.message = ex.getMessage();
            return new List<FlowOutputs>{
                fo
            };
        }

        if (accId2PurchaseOrderRequest.isEmpty()) {
            FlowOutputs fo = new FlowOutputs();
            fo.Result = 'E';
            fo.message = 'No valid records to send';
            return new List<FlowOutputs>{
                fo
            };
        }
        SalesOrderCallout callout = new SalesOrderCallout(accId2PurchaseOrderRequest.values()[0]);
        HttpResponse resp = callout.invokeCallout();

        System.debug('@@@@@Body');
        System.debug(resp.getBody());
        FlowOutputs fo = new FlowOutputs();

        Map<String, Object> responseKey2Value = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

        if (responseKey2Value.containsKey('error')) {

            try {
                String numeroFactura;
                Map<String, Object> error = (Map<String, Object>) responseKey2Value.get('error');
                Map<String, Object> innerError = (Map<String, Object>) error.get('innererror');
                List<Object> errorDetails = (List<Object>) innerError.get('errordetails');
                
                for (Object obj : errorDetails) {
                    Map<String, Object> errorDetailItem = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                    if (errorDetailItem.containsKey('code') && errorDetailItem.get('code') == 'VF/050' && errorDetailItem.containsKey('message')) {
                        Pattern pat = Pattern.compile('([0-9]+)');
                        Matcher matcher = pat.matcher((String) errorDetailItem.get('message'));
                        Boolean matches = matcher.find();
                        if (matches) {
                            numeroFactura = matcher.group(1);
                            break;
                        }
                    }
                }
                if (String.isBlank(numeroFactura)) {
                    fo.Result = 'SAP ERROR';
                    fo.message = JSON.serialize(responseKey2Value);
                }
                else { // OK response
                    fo.Result = 'S';
                    fo.invoiceNumber = numeroFactura;
                }

            } catch (Exception ex) {
                fo.message = 'APEX EXCEPTION: ' + ex.getTypeName() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
                fo.Result = JSON.serialize(responseKey2Value);
            }

            return new List<FlowOutputs>{
                fo
            };
        }

        try {
            Map<String, Object> innerObject = (Map<String, Object>) responseKey2Value.get('d');
            Map<String, Object> result = (Map<String, Object>) innerObject.get('result');

            fo.Result = (String) result.get('Result');
            fo.EResult = (String) result.get('EResult');

            if (fo.Result == 'S') {
                fo.invoiceNumber = (String) innerObject.get('invoiceNumber');
                fo.idTBAI = (String) innerObject.get('ID_TBAI');
                fo.qrTBAI = (String) innerObject.get('URL_QR');
            }

            Map<String, Object> msgReturn = (Map<String, Object>) innerObject.get('messageReturn');
            List<Object> results = (List<Object>) msgReturn.get('results');

            String msgString = '';
            for (Object obj : results) {
                Map<String, Object> singleObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                if ((singleObject.containsKey('Type') && (singleObject.get('Type') == 'E' || singleObject.get('Type') == 'W') && fo.Result != 'S') ||
                    (singleObject.containsKey('Type') && singleObject.get('Type') == 'S' && fo.Result == 'S')) {
                    String numberString = singleObject.containsKey('Number') && String.isNotEmpty((String) singleObject.get('Number')) ?
                        singleObject.get('Number') + ' - ' : '';
                    msgString += singleObject.containsKey('Message') && String.isNotEmpty((String) singleObject.get('Message')) ?
                        numberString + singleObject.get('Message') + ' | ' : '';
                }
            }
            if (msgString.endsWith(' | ')) {
                msgString = msgString.removeEnd(' | ');
            }
            fo.message = msgString;

            if (fo.Result == 'E' && messageShowsClientError(fo)) {
                fo.Result = 'Client Error';
                fo.clientIDSO = fo.message.splitByCharacterTypeCamelCase().get(4);
            }
        } catch (Exception ex) {
            fo.message = 'APEX EXCEPTION: ' + ex.getTypeName() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
            fo.Result = JSON.serialize(responseKey2Value);
        }

        return new List<FlowOutputs>{
            fo
        };
    }

    public class FlowInputs {
        @InvocableVariable
        public String ordenDeVentaId;
    }

    public class FlowOutputs {
        @InvocableVariable
        public String Result;
        @InvocableVariable
        public String EResult;
        @InvocableVariable
        public String invoiceNumber;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public String clientIDSO;
        @InvocableVariable
        public String idTBAI;
        @InvocableVariable
        public String qrTBAI;
    }

    private static Boolean validateDate(ONE_Orden_De_Venta__c ordenDeVenta) {
        Boolean isToday = Date.today() == ordenDeVenta.ONE_Fecha_De_Facturacion__c;
        Integer monthNum = (Date.today().month() - 1) != 0 ? Date.today().month() - 1 : 12;
        Boolean isLastDayOfPastMonth = ordenDeVenta.ONE_Fecha_De_Facturacion__c.day() ==
            Date.daysInMonth(ordenDeVenta.ONE_Fecha_De_Facturacion__c.year(), monthNum);


        return (isToday || isLastDayOfPastMonth);
    }

    public static String buildDate(Date dateToProcess) {
        if (dateToProcess == null) {
            return '';
        }
        return String.format(
            '\\/Date({0})\\/',
            new List<String>{
                String.valueOf(Datetime.newInstance(dateToProcess, Time.newInstance(0, 0, 0, 0)).getTime())
            }
        );
    }

    public static String buildDate(Datetime dateToProcess) {
        if (dateToProcess == null) {
            return '';
        }
        return String.format(
            '\\/Date({0})\\/',
            new List<String>{
                String.valueOf(dateToProcess.getTime())
            }
        );
    }

    public static Map<Id, SalesOrderCalloutRequest> prepareDTORequests(String ordenDeVentaId) {
        Map<Id, SalesOrderCalloutRequest> ordenId2PurchaseOrderRequest = new Map<Id, SalesOrderCalloutRequest>();
        ONE_Orden_De_Venta__c ordenDeVenta = [
            SELECT Id, 
            	ONE_Servicio__r.ONE_Difunto__r.FirstName, 
            	ONE_Servicio__r.ONE_Difunto__r.LastName, 
            	ONE_ContractNumberSAP__c,
                ONE_Tipo_De_Contratacion_SAP__c, 
            	ONE_Moneda__c, 
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c,
                ONE_Servicio__r.ONE_Inicio_Ceremonia__c, 
            	ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.RecordTypeId, 
            	ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__pc,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c, 
            	ONE_Servicio__r.Name, 
            	ONE_Forma_De_Pago__c, 
            	ONE_Ceremony_Date_SAP__c,
                ONE_Tipo_De_Factura__c, 
            	ONE_Presupuesto__r.ONE_Creation_Date__c, 
            	ONE_Fecha_De_Facturacion__c, 
            	ONE_InvoiceNumberPedidoSAP__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c, ONE_Codigo_Interlocutor_Id_SAP__c,
                ONE_Presupuesto__r.OwnerId, OwnerId, ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__c, ONE_Fecha_De_Entrega_SAP_OV__c,
                ONE_Servicio__r.ONE_Numero_de_Poliza__c, ONE_Servicio__r.ONE_Numero_de_Siniestro__c, ONE_Presupuesto__r.Name,
                Recordtype.Developername,

            (
                SELECT Id, ONE_Producto__r.ONE_Codigo_Comercial__c, ONE_Producto__r.ONE_Codigo_SAP__c, ONE_Importe_Neto__c,
                    ONE_Cantidad__c, ONE_Impuesto__c, ONE_Supplied_SAP__c, ONE_Importe_Base__c, ONE_Importe_Impuesto__c,
                    ONE_Codigo_Impuesto_SAP__c, ONE_Producto__r.Name, ONE_Precio__c, ONE_Importe_Descuento_Posicion__c,
                    ONE_InterlocutorCodeSAPSuplido__c, ONE_Proveedor_Suplido__r.ONE_ID_Proveedor_SAP__c, ONE_Sobreescribir_Codigo_Sap__c,
                    ONE_Producto__r.ONE_Imputaciones_Linea_Negocio__c, ONE_Expediente__r.Name, ONE_Presupuesto__r.Name, ONE_Presupuesto__r.ONE_Nombre_Y_Apellidos_Del_Difunto__c
                FROM Lineas_del_servicio__r
                WHERE ONE_Importe_Neto__c != 0 AND ONE_Estado__c != 'Eliminado'
            )

            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
        ];
        SalesOrderCalloutRequest request = new SalesOrderCalloutRequest(ordenDeVenta);

        if (validateDate(ordenDeVenta)) {
            ordenId2PurchaseOrderRequest.put(ordenDeVenta.Id, request);
        } else {
            throw new CustomValidationException(Label.ONE_Fecha_Incorrecta_Facturacion);
        }

        return ordenId2PurchaseOrderRequest;
    }

    private static String getUsuarioSAP(Id accId) {
        if (userId2CodigoUsuarioSAP == null) {
            prepareUsuarioSAP();
        }
        return userId2CodigoUsuarioSAP.get(accId);
    }

    private static void prepareUsuarioSAP() {
        userId2CodigoUsuarioSAP = new Map<Id, String>();
        for (User u : [SELECT Id, ONE_Codigo_Usuario_SAP__c FROM User WHERE IsActive = true]) {
            userId2CodigoUsuarioSAP.put(u.Id, u.ONE_Codigo_Usuario_SAP__c);
        }
    }

    private static Boolean messageShowsClientError(FlowOutputs fo) {
        String start = 'El deudor ';
        String middle1 = 'no se ha creado para área de ventas';
        String middle2 = 'existe, pero no ha sido creada en la sociedad';
        return fo.message.startsWithIgnoreCase(start) && (fo.message.containsIgnoreCase(middle1) || fo.message.containsIgnoreCase(middle2));
    }

    public class HeaderData {
        public String contractNumber { get; set; }
        public String deceasedName { get; set; }
        public String hiringTypeId { get; set; }
        public String x_currency { get; set; }
        public String operatingCenterId { get; set; }
        public String ceremonyDate { get; set; }
        public String interlocutorId { get; set; }
        public String societyId { get; set; }
        public String expedientId { get; set; }

        public HeaderData(ONE_Orden_De_Venta__c ordenDeVenta) {
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            //deceasedName = (ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.FirstName + ' ' + ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.LastName)?.toUpperCase();
			String firstName;
            String lastName;
            
            hiringTypeId = ordenDeVenta?.ONE_Tipo_De_Contratacion_SAP__c;
            x_currency = ordenDeVenta?.ONE_Moneda__c;
            ceremonyDate = buildDate(ordenDeVenta?.ONE_Ceremony_Date_SAP__c);

            if (ordenDeVenta?.ONE_Tipo_De_Factura__c == '01' && ordenDeVenta?.ONE_Pagador_Compania__c != null) {
                interlocutorId = ordenDeVenta?.ONE_Pagador_Compania__r?.ONE_ID_Cliente_SAP__c;
            } else if (ordenDeVenta?.ONE_Tipo_De_Factura__c == '01' && ordenDeVenta?.ONE_Pagador_Particular__c != null) {
                if (ordenDeVenta?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.RecordTypeId ==
                    ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS)) {
                    interlocutorId = ordenDeVenta?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c;
                } else {
                    interlocutorId = ordenDeVenta?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc;
                }
            } else if (ordenDeVenta.ONE_Tipo_De_Factura__c == '02') {
                interlocutorId = '200000005';
            }
            if(ordenDeVenta.RecordType.Developername !='ONE_OrdendeVenta_Gestoria'){
                societyId = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad__c;
            	expedientId = ordenDeVenta?.ONE_Servicio__r?.Name;
                firstName = ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.FirstName?.length() < 19 ?
                ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.FirstName :
                ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.FirstName.substring(0, 19);
            	lastName = ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.LastName?.length() < 19 ?
                ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.LastName :
                ordenDeVenta?.ONE_Servicio__r?.ONE_Difunto__r?.LastName.substring(0, 19);
            	deceasedName = ((firstName != null ? firstName : '') + (lastName != null ? (' ' + lastName) : ''))?.toUpperCase();
            	operatingCenterId = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_De_Centro__c;
            }else{
                societyId =System.label.SociedadAsisteaCodigo;
                expedientId='S-GESTORIA';
                deceasedName='DIFUNTO GESTORIA';
                operatingCenterId=System.label.CentroAsisteaCodigo;
                
            }
            
        }
    }

    public class BusinessData {
        public String contractNumber { get; set; }
        public String areaId { get; set; }
        public String paymentMethodId { get; set; }
        public String interlocutorId { get; set; }
        public String budgetDate { get; set; }
        public String invoiceDate { get; set; }
        public String ceremonyDate { get; set; }
        public String zonaGeografica { get; set; }

        public BusinessData(ONE_Orden_De_Venta__c ordenDeVenta) {
            Datetime invoiceDateFromSalesOrder = ordenDeVenta.ONE_Fecha_De_Facturacion__c;
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            areaId = '';
            paymentMethodId = ordenDeVenta.ONE_Forma_De_Pago__c;
            interlocutorId = ordenDeVenta?.ONE_Codigo_Interlocutor_Id_SAP__c;
            //budgetDate = buildDate(ordenDeVenta.ONE_Presupuesto__r.ONE_Creation_Date__c);
            invoiceDate = buildDate(invoiceDateFromSalesOrder?.addHours(3));
            //invoiceDate = buildDate(ordenDeVenta.ONE_Fecha_De_Facturacion__c);
            ceremonyDate = buildDate(ordenDeVenta?.ONE_Ceremony_Date_SAP__c);
            zonaGeografica = '';
             if(ordenDeVenta.RecordType.Developername != 'ONE_OrdendeVenta_Gestoria' && ordenDeVenta.ONE_Presupuesto__r.ONE_Creation_Date__c != null){
                 budgetDate = buildDate(ordenDeVenta.ONE_Presupuesto__r.ONE_Creation_Date__c);
             }else{
                 budgetDate = buildDate(System.today());
             }
        }
    }

    public class ItemDataSet {
        public String contractNumber { get; set; }
        public String positionNumber { get; set; }
        public String productId { get; set; }
        public String commentId { get; set; }
        public String productSubfamilyId { get; set; }
        public String operatingCenterId { get; set; }
        public String finalProductPrice { get; set; }
        public String productQuantity { get; set; }
        public String warehouseId { get; set; }
        public String iva { get; set; }
        public String supplied { get; set; }
        public String beneficianCenterId { get; set; }
        public String adviserReference { get; set; }

        public ItemDataSet(ONE_Orden_De_Venta__c ordenDeVenta, ONE_Expediente_Line_Item__c eli, Integer index) {
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            positionNumber = String.valueOF(index).leftPad(6, '0');
            productId = eli?.ONE_Sobreescribir_Codigo_Sap__c == null
                ? eli?.ONE_Producto__r?.ONE_Codigo_SAP__c
                : eli.ONE_Sobreescribir_Codigo_Sap__c;
            productSubfamilyId = '';
           
            finalProductPrice = String.valueOf(eli?.ONE_Precio__c);
            productQuantity = String.valueOf(eli?.ONE_Cantidad__c);
            warehouseId = '';
            iva = '0'; //eli.ONE_Impuesto__c != null ? String.valueOf(eli.ONE_Impuesto__c) : '';
            supplied = eli?.ONE_Supplied_SAP__c;
            beneficianCenterId = eli?.ONE_Producto__r?.ONE_Imputaciones_Linea_Negocio__c;
            adviserReference = getUsuarioSAP(ordenDeVenta?.ONE_Presupuesto__r?.OwnerId != null 
            	? ordenDeVenta?.ONE_Presupuesto__r?.OwnerId 
                : ordenDeVenta.OwnerId
            );
            if(ordenDeVenta.RecordType.Developername !='ONE_OrdendeVenta_Gestoria'){
                  operatingCenterId = ordenDeVenta?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Centro_Memora_Codigo_SAP__c;
             	  commentId = eli?.ONE_Producto__r.Name.length() < 39 ? eli?.ONE_Producto__r.Name : eli?.ONE_Producto__r.Name.substring(0, 38);
            }else{
                  operatingCenterId =System.label.CentroAsisteaCodigo;
                if(eli?.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c != null){
                    commentId = (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c).length() < 39 
                        ? eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c 
                        : (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c).substring(0, 38);
                } else {
                    commentId = (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.Name + '- SIN DIFUNTO').length() < 39 
                        ? eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.Name + ' - SIN DIFUNTO' 
                        : (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_Presupuesto__r?.Name + ' - SIN DIFUNTO').substring(0, 38);
                }
            }
        }
    }

    public class ScheduleLineDataSet {
        public String contractNumber { get; set; }
        public String positionNumber { get; set; }
        public String deliverDate { get; set; }
        public String productQuantity { get; set; }

        public ScheduleLineDataSet(ONE_Orden_De_Venta__c ordenDeVenta, ONE_Expediente_Line_Item__c eli, Integer index) {
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            positionNumber = String.valueOf(index).leftPad(6, '0');
            deliverDate = buildDate(ordenDeVenta?.ONE_Fecha_De_Entrega_SAP_OV__c);
            productQuantity = String.valueOf(eli?.ONE_Cantidad__c);
        }
    }

    public class ConditionsSet {
        public String contractNumber { get; set; }
        public String positionNumber { get; set; }
        public String productPrice { get; set; }
        public String clientDiscount { get; set; }
        public String localDiscount { get; set; }
        public String especialDiscount { get; set; }
        public String productDiscountValue { get; set; }
        public String iva { get; set; }
        public String importeIva { get; set; }
        public String mwsk1 { get; set; }
        public String globalDiscount { get; set; }
        public String globalDiscountValue { get; set; }

        public ConditionsSet(ONE_Orden_De_Venta__c ordenDeVenta, ONE_Expediente_Line_Item__c eli, Integer index) {
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            positionNumber = String.valueOF(index).leftPad(6, '0');
            productPrice = String.valueOf(eli?.ONE_Precio__c);
            clientDiscount = '';
            localDiscount = '';

            if (ordenDeVenta.ONE_Tipo_De_Contratacion_SAP__c == 'ZCOM') {
                especialDiscount = String.valueOf(eli?.ONE_Importe_Descuento_Posicion__c);
            } else {
                especialDiscount = '';
            }

            if (ordenDeVenta.ONE_Tipo_De_Contratacion_SAP__c == 'ZPAR' || ordenDeVenta.ONE_Tipo_De_Contratacion_SAP__c == 'ZB3') {
                productDiscountValue = String.valueOf(eli?.ONE_Importe_Descuento_Posicion__c);
            } else {
                productDiscountValue = '';
            }

            iva = eli.ONE_Impuesto__c != null ? String.valueOf(eli.ONE_Impuesto__c) : '';
            importeIva = eli.ONE_Importe_Impuesto__c != null ? String.valueOf(eli.ONE_Importe_Impuesto__c) : '';
            mwsk1 = eli.ONE_Codigo_Impuesto_SAP__c;
            globalDiscount = '';
            globalDiscountValue = '';
        }
    }

    public class PartnerSet {
        public String contractNumber { get; set; }
        public String interlocutorPosition { get; set; }
        public String interlocutorCode { get; set; }
        public String interlocutorId { get; set; }

        public PartnerSet(ONE_Orden_De_Venta__c ordenDeVenta, ONE_Expediente_Line_Item__c eli, Integer index) {
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            interlocutorPosition = String.valueOF(index).leftPad(6, '0');
            interlocutorCode = eli?.ONE_InterlocutorCodeSAPSuplido__c;
            interlocutorId = eli?.ONE_Proveedor_Suplido__r?.ONE_ID_Proveedor_SAP__c;
        }
    }

    public class ProcessSet {
        public String contractNumber { get; set; }
        public String code { get; set; }
        public String message { get; set; }

        public ProcessSet(ONE_Orden_De_Venta__c ordenDeVenta) {
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            code = 'E7';
            message = '';
        }
    }

    public class CommentSet {
        public String contractNumber { get; set; }
        public String positionNumber { get; set; }
        public String clustd { get; set; }

        public CommentSet(ONE_Orden_De_Venta__c ordenDeVenta, Integer index) {
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            positionNumber = String.valueOF(index).leftPad(6, '0');
            clustd = 'true';
        }
    }

    public class SalesOrderCalloutRequest {
        public String contractNumber { get; set; }
        /*public String invoiceNumber { get; set; }*/
        public String numPoliza { get; set; }
        public String siniestro { get; set; }
        public HeaderData headerData { get; set; }
        public BusinessData businessData { get; set; }
        public List<ItemDataSet> itemDataSet { get; set; }
        public List<ScheduleLineDataSet> scheduleLineDataSet { get; set; }
        public List<ConditionsSet> conditionsSet { get; set; }
        public List<PartnerSet> partnerSet { get; set; }
        public List<ProcessSet> processSet { get; set; }
        public List<CommentSet> commentSet { get; set; }
        public Map<String, String> result { get; set; }
        public List<Map<String, Object>> messageReturn { get; set; }

        public SalesOrderCalloutRequest(ONE_Orden_De_Venta__c ordenDeVenta) {
            numPoliza = ordenDeVenta?.ONE_Servicio__r?.ONE_Numero_de_Poliza__c;
            siniestro = ordenDeVenta?.ONE_Servicio__r?.ONE_Numero_de_Siniestro__c;
            contractNumber = ordenDeVenta?.ONE_ContractNumberSAP__c;
            /*invoiceNumber = ordenDeVenta?.ONE_InvoiceNumberPedidoSAP__c;*/
            headerData = new HeaderData(ordenDeVenta);
            businessData = new BusinessData(ordenDeVenta);
            itemDataSet = new List<ItemDataSet>();
            scheduleLineDataSet = new List<ScheduleLineDataSet>();
            conditionsSet = new List<ConditionsSet>();
            partnerSet = new List<PartnerSet>();
            processSet = new List<ProcessSet>();
            commentSet = new List<CommentSet>();

            for (Integer i = 0; i < ordenDeVenta.Lineas_del_servicio__r.size(); i++) {
                Integer itemIndex = i + 1;
                ONE_Expediente_Line_Item__c eli = ordenDeVenta.Lineas_del_servicio__r[i];
                itemDataSet.add(new ItemDataSet(ordenDeVenta, eli, itemIndex));
                scheduleLineDataSet.add(new ScheduleLineDataSet(ordenDeVenta, eli, itemIndex));
                conditionsSet.add(new ConditionsSet(ordenDeVenta, eli, itemIndex));
                partnerSet.add(new PartnerSet(ordenDeVenta, eli, itemIndex));
                processSet.add(new ProcessSet(ordenDeVenta));
                commentSet.add(new CommentSet(ordenDeVenta, itemIndex));
            }

            result = new Map<String, String>{
                'Result' => '',
                'EResult' => ''
            };
            messageReturn = new List<Map<String, Object>>{
                new Map<String, Object>()
            };
        }
    }

    public class CustomValidationException extends Exception {

    }
}
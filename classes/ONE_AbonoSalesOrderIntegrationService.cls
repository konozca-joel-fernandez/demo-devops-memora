/**
 * Created by bjaworski002 on 19.05.2022.
 */

public with sharing class ONE_AbonoSalesOrderIntegrationService {

    private static String codigoUsuario;
    private static String contract;

    public class AbonoSalesOrderCallout extends ONE_SAPCallout {
        public AbonoSalesOrderCallout(AbonoSalesOrderCalloutRequest orderRequest) {
            super(ONE_CommonConstants.CM_SAP_SALESORDER, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_SALESORDER);
            setBody(JSON.serialize(orderRequest).replace('null', '""').replace('x_', ''));
        }
    }

    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        Map<Id, AbonoSalesOrderCalloutRequest> accId2PurchaseOrderRequest;
        try {
            accId2PurchaseOrderRequest = prepareDTORequests(flowInputs.get(0).abonoParcialId);
        } catch (CustomValidationException ex) {
            FlowOutputs fo = new FlowOutputs();
            fo.Result = 'E';
            fo.message = ex.getMessage() + ' | ' + ex.getStackTraceString();
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
        AbonoSalesOrderCallout callout = new AbonoSalesOrderCallout(accId2PurchaseOrderRequest.values().get(0));
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
                if ((singleObject.containsKey('Type') && (singleObject.get('Type') == 'E'  || singleObject.get('Type') == 'W') && fo.Result != 'S') ||
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
        } catch (Exception ex) {
            fo.message = 'APEX EXCEPTION: ' + ex.getTypeName() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
            fo.Result = JSON.serialize(responseKey2Value);
        }

        return new List<FlowOutputs>{
            fo
        };
    }

    public static Map<Id, AbonoSalesOrderCalloutRequest> prepareDTORequests(String abonoParcialId) {
        Map<Id, AbonoSalesOrderCalloutRequest> ordenId2PurchaseOrderRequest = new Map<Id, AbonoSalesOrderCalloutRequest>();
        ONE_Abono_Parcial__c abonoParcial = [
            SELECT Id, ONE_Contract_NumberAP_SAP__c, ONE_Fecha_De_Facturacion_Rectificativa__c,
                ONE_Moneda_AP__c, ONE_Numero_de_factura_rectificativa__c, ONE_Tipo_De_Contratacion_SAP_AP__c,
                ONE_Presupuesto_AP__r.OwnerId, ONE_Presupuesto_AP__r.ONE_Creation_Date__c,
                ONE_Orden_de_venta_AP__r.ONE_Forma_De_Pago__c, ONE_Orden_de_venta_AP__r.ONE_Fecha_De_Entrega_SAP_OV__c,
                ONE_Orden_de_venta_AP__r.ONE_Numero_de_factura__c,
                ONE_Orden_de_venta_AP__r.ONE_Pagador_Compania__c, ONE_Orden_de_venta_AP__r.ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c,
                ONE_Orden_de_venta_AP__r.ONE_Pagador_Particular__c,
                ONE_Orden_de_venta_AP__r.ONE_Pagador_Particular__r.ONE_Contacto__r.RecordTypeId,
                ONE_Orden_de_venta_AP__r.ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__c,
            	ONE_Orden_de_venta_AP__r.OwnerId,ONE_Orden_de_venta_AP__r.RecordType.DeveloperName,
                ONE_Orden_de_venta_AP__r.ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__pc,
                ONE_Orden_de_venta_AP__r.ONE_Tipo_De_Factura__c, ONE_Orden_de_venta_AP__r.ONE_Ceremony_Date_SAP__c,
           		ONE_Orden_de_venta_AP__r.ONE_Presupuesto__r.ONE_Creation_Date__c,
                ONE_Servicio_AP__r.Name, ONE_Servicio_AP__r.ONE_Inicio_Ceremonia__c,
                ONE_Servicio_AP__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c,
                ONE_Servicio_AP__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                ONE_Servicio_AP__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c,
                ONE_Servicio_AP__r.ONE_Difunto__r.FirstName, ONE_Servicio_AP__r.ONE_Difunto__r.LastName, (
                    SELECT Id, ONE_Cantidad__c, ONE_Codigo_Impuesto_SAP__c,
                        ONE_Impuesto__c, ONE_Importe_Impuesto__c, ONE_Importe_Descuento_Posicion__c,
                        ONE_InterlocutorCodeSAPSuplido__c, ONE_Precio__c, ONE_Supplied_SAP__c,
                        ONE_Proveedor_Suplido__r.ONE_ID_Proveedor_SAP__c,
                        ONE_Producto__r.Name, ONE_Producto__r.ONE_Codigo_SAP__c,
                        ONE_Producto__r.ONE_Imputaciones_Linea_Negocio__c,
                    	ONE_Expediente__r.Name, ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r.Name, ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r.ONE_Nombre_Y_Apellidos_Del_Difunto__c
                    FROM L_neas_del_servicio__r
                    WHERE ONE_Importe_Neto__c != 0
                )
                FROM ONE_Abono_Parcial__c
                WHERE Id = :abonoParcialId
        ];

        codigoUsuario = [SELECT ONE_Codigo_Usuario_SAP__c FROM User WHERE Id = :abonoParcial.ONE_Orden_de_venta_AP__r.OwnerId].ONE_Codigo_Usuario_SAP__c;
        contract = abonoParcial.ONE_Contract_NumberAP_SAP__c;

        if (validateDate(abonoParcial.ONE_Fecha_De_Facturacion_Rectificativa__c)) {
            ordenId2PurchaseOrderRequest.put(abonoParcial.Id, new AbonoSalesOrderCalloutRequest(abonoParcial));
        } else {
            throw new CustomValidationException(Label.ONE_Fecha_Incorrecta_Facturacion);
        }

        return ordenId2PurchaseOrderRequest;
    }

    public static String buildDate(Date dateToProcess) {
        if (dateToProcess == null) {
            return '';
        }

        return buildDate(Datetime.newInstanceGmt(dateToProcess, Time.newInstance(0, 0, 0, 0)));
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

    private static Boolean validateDate(Date dt) {
        Date today = Date.today();
        if (today == dt) {
            return true;
        }
        Integer lastMonth = today.addMonths(-1).month();
        return dt.day() == Date.daysInMonth(dt.year(), lastMonth) && dt.month() == lastMonth;
    }


    public class AbonoSalesOrderCalloutRequest {
        public String contractNumber { get; set; }
        public String invoiceNumber { get; set; }
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

        public AbonoSalesOrderCalloutRequest(ONE_Abono_Parcial__c abonoParcial) {
            contractNumber = contract;
            invoiceNumber = abonoParcial?.ONE_Numero_de_factura_rectificativa__c;
            headerData = new HeaderData(abonoParcial);
            businessData = new BusinessData(abonoParcial);
            itemDataSet = new List<ItemDataSet>();
            scheduleLineDataSet = new List<ScheduleLineDataSet>();
            conditionsSet = new List<ConditionsSet>();
            partnerSet = new List<PartnerSet>();
            processSet = new List<ProcessSet>();
            commentSet = new List<CommentSet>();

            ProcessSet process = new ProcessSet();

            for (Integer i = 0; i < abonoParcial.L_neas_del_servicio__r.size(); i++) {
                String itemIndex = String.valueOf(i + 1).leftPad(6, '0');
                ONE_Expediente_Line_Item__c eli = abonoParcial.L_neas_del_servicio__r[i];
                itemDataSet.add(new ItemDataSet(abonoParcial, eli, itemIndex));
                scheduleLineDataSet.add(new ScheduleLineDataSet(abonoParcial, eli, itemIndex));
                conditionsSet.add(new ConditionsSet(abonoParcial, eli, itemIndex));
                partnerSet.add(new PartnerSet(eli, itemIndex));
                processSet.add(process);
                commentSet.add(new CommentSet(itemIndex));
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
        public String correctedInvoice { get; set; }

        public HeaderData(ONE_Abono_Parcial__c abonoParcial) {
            ONE_Expediente__c servicio = abonoParcial?.ONE_Servicio_AP__r;
            ONE_Orden_De_Venta__c ordenDeVenta = abonoParcial?.ONE_Orden_de_venta_AP__r;
            
               if (ordenDeVenta.ONE_Tipo_De_Factura__c == '01') {
                if (ordenDeVenta.ONE_Pagador_Compania__c != null) {
                    interlocutorId = ordenDeVenta.ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c;
                } else if (ordenDeVenta.ONE_Pagador_Particular__c != null) {
                    Account contact = ordenDeVenta.ONE_Pagador_Particular__r.ONE_Contacto__r;
                    if (contact?.RecordTypeId == ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS)) {
                        interlocutorId = contact?.ONE_ID_Cliente_SAP__c;
                    } else if (contact?.RecordTypeId == ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)) {
                        interlocutorId = contact?.ONE_ID_Cliente_SAP__pc;
                    }
                }
            } else if (ordenDeVenta.ONE_Tipo_De_Factura__c == '02') {
                interlocutorId = '200000005';
            }
            
                ceremonyDate = buildDate(ordenDeVenta.ONE_Ceremony_Date_SAP__c);
            	hiringTypeId = abonoParcial?.ONE_Tipo_De_Contratacion_SAP_AP__c;
                x_currency = abonoParcial?.ONE_Moneda_AP__c;
            	correctedInvoice = ordenDeVenta?.ONE_Numero_de_factura__c;
			if(ordenDeVenta.RecordType.Developername !='ONE_OrdendeVenta_Gestoria'){
                
                contractNumber = contract;
                deceasedName = (servicio?.ONE_Difunto__r?.FirstName?.left(18) + ' ' + servicio?.ONE_Difunto__r?.LastName)?.left(38);
                operatingCenterId = servicio?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_De_Centro__c;
                societyId = servicio?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad__c;
                expedientId = servicio?.Name;
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

        public BusinessData(ONE_Abono_Parcial__c abonoParcial) {
            contractNumber = contract;
            paymentMethodId = abonoParcial?.ONE_Orden_de_venta_AP__r.ONE_Forma_De_Pago__c;
            interlocutorId = 'Z1';
             if(abonoParcial?.ONE_Orden_de_venta_AP__r.RecordType.Developername !='ONE_OrdendeVenta_Gestoria'){
                 budgetDate = buildDate(abonoParcial?.ONE_Orden_de_venta_AP__r?.ONE_Presupuesto__r?.ONE_Creation_Date__c);
             }else{
                 budgetDate = buildDate(System.today());
             }
            invoiceDate = buildDate(abonoParcial?.ONE_Fecha_De_Facturacion_Rectificativa__c);
            ceremonyDate = buildDate(abonoParcial?.ONE_Orden_de_venta_AP__r.ONE_Ceremony_Date_SAP__c);
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

        public ItemDataSet(ONE_Abono_Parcial__c abonoParcial, ONE_Expediente_Line_Item__c eli, String index) {
            ONE_Producto__c producto = eli?.ONE_Producto__r;

            contractNumber = contract;
            positionNumber = index;
            productId = producto?.ONE_Codigo_SAP__c;
            finalProductPrice = String.valueOf(eli?.ONE_Precio__c);
            productQuantity = String.valueOf(eli?.ONE_Cantidad__c);
            iva = '0';
            supplied = eli?.ONE_Supplied_SAP__c;
            beneficianCenterId = producto?.ONE_Imputaciones_Linea_Negocio__c;
            adviserReference = codigoUsuario;
            if(abonoParcial?.ONE_Orden_de_venta_AP__r.RecordType.Developername !='ONE_OrdendeVenta_Gestoria'){
                  operatingCenterId = abonoParcial?.ONE_Servicio_AP__r?.ONE_Centro_Del_Expediente__r?.ONE_Centro_Memora_Codigo_SAP__c;
             	 commentId = producto.Name.left(38);
            }else{
                  operatingCenterId =System.label.CentroAsisteaCodigo;
                if(eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c!=null){
                 	commentId = (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c).length() < 39 ? eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c : (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.ONE_Nombre_Y_Apellidos_Del_Difunto__c).substring(0, 38);   
                }else{
                 	commentId = (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.Name + ' - ' + 'SIN DIFUNTO').length() < 39 ? eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.Name + ' - SIN DIFUNTO'  : (eli?.ONE_Expediente__r?.Name + ' - ' + eli?.ONE_SLI_Relacionado_Abono_Parcial__r.ONE_Presupuesto__r?.Name + ' - SIN DIFUNTO').substring(0, 38);      
                }
            }
        }
    }

    public class ScheduleLineDataSet {
        public String contractNumber { get; set; }
        public String positionNumber { get; set; }
        public String deliverDate { get; set; }
        public String productQuantity { get; set; }

        public ScheduleLineDataSet(ONE_Abono_Parcial__c abonoParcial, ONE_Expediente_Line_Item__c eli, String index) {
            contractNumber = contract;
            positionNumber = index;
            deliverDate = buildDate(abonoParcial?.ONE_Orden_de_venta_AP__r?.ONE_Fecha_De_Entrega_SAP_OV__c);
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

        public ConditionsSet(ONE_Abono_Parcial__c abonoParcial, ONE_Expediente_Line_Item__c eli, String index) {
            contractNumber = contract;
            positionNumber = index;
            productPrice = String.valueOf(eli?.ONE_Precio__c);
            iva = String.valueOf(eli.ONE_Impuesto__c);
            importeIva = String.valueOf(eli.ONE_Importe_Impuesto__c);
            mwsk1 = eli.ONE_Codigo_Impuesto_SAP__c;

            switch on abonoParcial.ONE_Tipo_De_Contratacion_SAP_AP__c {
                when 'ZACO' {
                    especialDiscount = String.valueOf(eli?.ONE_Importe_Descuento_Posicion__c);
                }
                when 'ZAPA' {
                    productDiscountValue = String.valueOf(eli?.ONE_Importe_Descuento_Posicion__c);
                }
                when 'ZB3' {
                    productDiscountValue = String.valueOf(eli?.ONE_Importe_Descuento_Posicion__c);
                }
            }
        }
    }

    public class PartnerSet {
        public String contractNumber { get; set; }
        public String interlocutorPosition { get; set; }
        public String interlocutorCode { get; set; }
        public String interlocutorId { get; set; }

        public PartnerSet(ONE_Expediente_Line_Item__c eli, String index) {
            contractNumber = contract;
            interlocutorPosition = index;
            interlocutorCode = eli?.ONE_InterlocutorCodeSAPSuplido__c;
            interlocutorId = eli?.ONE_Proveedor_Suplido__r?.ONE_ID_Proveedor_SAP__c;
        }
    }

    public class ProcessSet {
        public String contractNumber { get; set; }
        public String code { get; set; }
        public String message { get; set; }

        public ProcessSet() {
            contractNumber = contract;
            code = 'E7';
        }
    }

    public class CommentSet {
        public String contractNumber { get; set; }
        public String positionNumber { get; set; }
        public String clustd { get; set; }

        public CommentSet(String index) {
            contractNumber = contract;
            positionNumber = index;
            clustd = 'true';
        }
    }

    public class FlowInputs {
        @InvocableVariable
        public String abonoParcialId;
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
        public String idTBAI;
        @InvocableVariable
        public String qrTBAI;
    }

    public class CustomValidationException extends Exception {

    }
}
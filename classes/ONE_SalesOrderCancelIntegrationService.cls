/**
 * Created by mbujak003 on 02.02.2021.
 */

public with sharing class ONE_SalesOrderCancelIntegrationService {
	//Static variable definition
    public static String FILTER_IFKDAT = 'IFkdat';
    public static String FILTER_IVBELN = 'IVbeln';
    static final String ERROR_VALIDITITY_CRITICAL = 'E';
	//Extend SAP callout for basic request structure and authentication
    public class InvoiceCancellationService extends ONE_SAPCallout {
        public InvoiceCancellationService(String filters) {
            super(ONE_CommonConstants.CM_SAP_CANCELINVOICE, ONE_Integration.RestMethod.GET, ONE_CommonConstants.SAPSCOPE_CANCELINVOICE);

            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(filters); // parse input parameters
			//Get parameters from the flow inputs
            String IFkdat = (String)parsedParams.get(FILTER_IFKDAT.toLowerCase());
            String IVbeln = (String)parsedParams.get(FILTER_IVBELN.toLowerCase());
			
            String filter = String.format(
                '({0}={1},{2}={3})',
                new List<String> {
                    FILTER_IFKDAT,
                    IFkdat,
                    FILTER_IVBELN,
                    formatFilter(IVbeln)
                }
            );
            putParam('',filter);
        }
		//Build endpoint using integration endpoint custom metadata and adding new parametes for the GET request
        public override String buildEndpoint() {
            return super.buildEndpoint().remove('?=');
        }

		//Format filters for the GET request
        private String formatFilter(String filter) {
            return '\'' + filter + '\'';
        }
    }
    //Validate is the payment is today or last day of the past month
    private static Boolean isPaymentDateTodayOrLastDayOfPreviousMonth(Datetime invoicePaymentDate) {
        Boolean isToday = Date.today() == invoicePaymentDate.date();
        Integer monthNum = (Date.today().month() - 1) != 0 ? Date.today().month() - 1 : 12;
        Boolean isLastDayOfPastMonth = invoicePaymentDate.day() == Date.daysInMonth(invoicePaymentDate.year(), monthNum);
        return (isToday || isLastDayOfPastMonth);
    }
    //Filfer structure creation
    private static Map<String, Object> prepareFilters(ONE_Orden_De_Venta__c salesOrder) {
        return new Map<String, Object> {
                FILTER_IFKDAT.toLowerCase() => 'datetime\'' + String.valueOf(salesOrder.ONE_Fecha_Hora_Del_Abono_Factura__c).replace(' ', 'T') + '\'',
                FILTER_IVBELN.toLowerCase() => salesOrder.ONE_Numero_de_factura__c
        };
    }
	//In case of error, prepare structure for the flow output
    static List<FlowOutputs> getErrorFlowOutput(String errorValidity, String errorMessage) {
        FlowOutputs fo = new FlowOutputs();
        fo.EResult = errorValidity;
        fo.errorMessage = errorMessage;
        return new List<FlowOutputs>{fo};
    }
    //Invocable method definition for calling the integration via workflow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {
        ONE_Orden_De_Venta__c salesOrder = [SELECT Id, ONE_Numero_de_factura__c, ONE_Fecha_Hora_Del_Abono_Factura__c FROM ONE_Orden_De_Venta__c WHERE Id = :inputs[0].ordernDeVentaId];
        if (!isPaymentDateTodayOrLastDayOfPreviousMonth(salesOrder.ONE_Fecha_Hora_Del_Abono_Factura__c)) { //Validate date
            return getErrorFlowOutput(ERROR_VALIDITITY_CRITICAL, Label.ONE_Fecha_Incorrecta_Facturacion_Cancellation); // in case of date validatin errro return error
        } else {
            String filters = JSON.serialize(prepareFilters(salesOrder));
            HttpResponse resp = new InvoiceCancellationService(filters).invokeCallout();
            System.debug('response: ' + resp);
            Map<String, Object> respObject = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            FlowOutputs fo = new FlowOutputs();

            if (respObject.containsKey('d')) { // In case we got OK response
                Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
                if (innerObject != null) {
                    Datetime dt;
                    if(innerObject.containsKey('EFkdatAnul') && innerObject.get('EFkdatAnul')!=null) {
                        String unixTimestamp = String.valueOf(innerObject.get('EFkdatAnul')).replaceAll('[^0-9]', '');
                        dt = Datetime.newInstance(long.valueOf(unixTimestamp));
                        fo.EFkdatAnul = dt;
                    } else {
                        fo.EFkdatAnul = null;
                    }
                    fo.ESfakn = innerObject.containsKey('ESfakn') ? (String)innerObject.get('ESfakn') : null;
                    fo.EResult = innerObject.containsKey('EResult') ? (String)innerObject.get('EResult') : null;
                    fo.idTBAI = innerObject.containsKey('ID_TBAI') ? (String) innerObject.get('ID_TBAI') : null;
                    fo.qrTBAI = innerObject.containsKey('URL_QR') ? (String) innerObject.get('URL_QR') : null;

                    if (innerObject.containsKey('messageReturn')) {
                        Map<String, Object> msgReturn = (Map<String, Object>) innerObject.get('messageReturn');
                        List<Object> results = (List<Object>) msgReturn.get('results');
    
                        String msgString = '';
                        for (Object obj : results) {
                            Map<String, Object> singleObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                            if ((singleObject.containsKey('Type') && (singleObject.get('Type') == 'E' || singleObject.get('Type') == 'W') && fo.EResult != 'S')) {
                                String numberString = singleObject.containsKey('Number') && String.isNotEmpty((String) singleObject.get('Number')) ?
                                    singleObject.get('Number') + ' - ' : '';
                                msgString += singleObject.containsKey('Message') && String.isNotEmpty((String) singleObject.get('Message')) ?
                                    numberString + singleObject.get('Message') + ' | ' : '';
                            }
                        }
                        if (msgString.endsWith(' | ')) {
                            msgString = msgString.removeEnd(' | ');
                        }
                        fo.errorMessage = msgString;
                    }
                }
            } else {//In case we got error
                if (respObject.containsKey('error')) {

                    try {
                        String numeroAbono;
                        Map<String, Object> error = (Map<String, Object>) respObject.get('error');
                        Map<String, Object> innerError = (Map<String, Object>) error.get('innererror');
                        List<Object> errorDetails = (List<Object>) innerError.get('errordetails');
                        
                        for (Object obj : errorDetails) {
                            Map<String, Object> errorDetailItem = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                            if (errorDetailItem.containsKey('code') && errorDetailItem.get('code') == 'VF/050' && errorDetailItem.containsKey('message')) {
                                Pattern pat = Pattern.compile('([0-9]+)');
                                Matcher matcher = pat.matcher((String) errorDetailItem.get('message'));
                                Boolean matches = matcher.find();
                                if (matches) {
                                    numeroAbono = matcher.group(1);
                                    break;
                                }
                            }
                        }
                        if (String.isBlank(numeroAbono)) {
                            Map<String, Object> message = (Map<String, Object>) error.get('message');
                            fo.errorMessage = String.valueOf(message.get('value'));
                        }
                        else { // OK response
                            fo.ESfakn = numeroAbono;
                            fo.EResult = 'S';
                        }
        
                    } catch (Exception ex) {
                        fo.errorMessage = 'APEX EXCEPTION: ' + ex.getTypeName() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
                        fo.EResult = JSON.serialize(respObject);
                    }

                } else {
                    fo.errorMessage = 'Unexpected error';
                }
            }

            return new List<FlowOutputs> { fo };
        }
    }
	//Flow input definition
    public class FlowInputs {
        @InvocableVariable
        public String ordernDeVentaId;
    }
	//Flow output definition
    public class FlowOutputs {
        @InvocableVariable
        public Datetime EFkdatAnul;
        @InvocableVariable
        public String ESfakn;
        @InvocableVariable
        public String EResult;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String idTBAI;
        @InvocableVariable
        public String qrTBAI;
    }
}
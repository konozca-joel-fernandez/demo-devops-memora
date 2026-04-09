/**
 * Created by bjaworski002 on 20.05.2022.
 */

public with sharing class ONE_AbonoCancelIntegrationService {
    //Static variable definition
    public static String FILTER_IFKDAT = 'IFkdat';
    public static String FILTER_IVBELN = 'IVbeln';
    static final String ERROR_VALIDITITY_CRITICAL = 'E';
    //Extend SAP callout for basic request structure and authentication
    public class AbonoCancellationService extends ONE_SAPCallout {
        public AbonoCancellationService(String filters) {
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

    private static Boolean validateDate(Date dt) {
        Date today = Date.today();
        if (today == dt) {
            return true;
        }
        Integer lastMonth = today.addMonths(-1).month();
        return dt.day() == Date.daysInMonth(dt.year(), lastMonth) && dt.month() == lastMonth;
    }

    //Filfer structure creation
    private static Map<String, Object> prepareFilters(ONE_Abono_Parcial__c abonoParcial) {
        return new Map<String, Object> {
                FILTER_IFKDAT.toLowerCase() => 'datetime\'' + String.valueOf(abonoParcial.ONE_Fecha_Abono_Factura_Rectificativa__c).replace(' ', 'T') + '\'',
                FILTER_IVBELN.toLowerCase() => abonoParcial.ONE_Numero_de_factura_rectificativa__c
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
        ONE_Abono_Parcial__c abonoParcial = [
            SELECT ONE_Fecha_Abono_Factura_Rectificativa__c, ONE_Numero_de_factura_rectificativa__c
            FROM ONE_Abono_Parcial__c
            WHERE Id = :inputs.get(0).abonoParcialId];
        if (!validateDate(abonoParcial.ONE_Fecha_Abono_Factura_Rectificativa__c.date())) { //Validate date
            return getErrorFlowOutput(ERROR_VALIDITITY_CRITICAL, Label.ONE_Fecha_Incorrecta_Facturacion_Cancellation); // in case of date validatin errro return error
        } else {
            String filters = JSON.serialize(prepareFilters(abonoParcial));
            Map<String, Object> respObject = (Map<String, Object>)JSON.deserializeUntyped(new AbonoCancellationService(filters).invokeCallout().getBody());
            FlowOutputs fo = new FlowOutputs();

            if (respObject.containsKey('d')) { // In case we got OK response
                Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
                if (innerObject != null) {
                    Datetime dt;
                    if(innerObject.containsKey('EFkdatAnul') && innerObject.get('EFkdatAnul') != null) {
                        String unixTimestamp = String.valueOf(innerObject.get('EFkdatAnul')).replaceAll('[^0-9]', '');
                        dt = Datetime.newInstance(Long.valueOf(unixTimestamp));
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
                if(respObject.containsKey('error')) {

                    try {
                        String numeroFactura;
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
                                    numeroFactura = matcher.group(1);
                                    break;
                                }
                            }
                        }
                        if (String.isBlank(numeroFactura)) {
                            Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('error');
                            Map<String, Object> message = (Map<String, Object>)innerObject.get('message');
                            fo.errorMessage = String.valueOf(message.get('value'));
                        }
                        else { // OK response
                            fo.EResult = 'S';
                            fo.ESfakn = numeroFactura;
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
        public String abonoParcialId;
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
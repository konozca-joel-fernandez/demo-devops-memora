/**
 * Created by kmotyka005 on 13.10.2021.
 */
//
public with sharing class ONE_InsuranceBudgetUpdateController {
	//Invocable method for the insurance budget flow call integration
    @InvocableMethod(Label='Update budgets')
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        FlowOutputs fo = new FlowOutputs();
        ONE_Orden_De_Venta__c ordenRecord = getOrdenRecord(flowInputs[0].ordenDeVentaId); // Obtain sales order from input ID

        try {
            String response = '';
            RequestTemplate requestTemplate = buildTemplate(flowInputs[0].ordenDeVentaId);
            Map<String, Object> parsedParams = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(requestTemplate));
            String integrationType = String.valueOf(parsedParams.get('integrationType')).toLowerCase();
            parsedParams.remove('integrationType');
            Object obj = parsedParams.remove('deleteTmp');
            parsedParams.put('delete', obj);
            obj = parsedParams.remove('updateTmp');
            parsedParams.put('update', obj);
			//Check right integration endpoint to call
            if (integrationType.equalsIgnoreCase('G')) {
                response = new ONE_InsuranceIntegrationCallout.GeneraliEditBudgetCallout(parsedParams).invokeCallout(true).getBody(); //Call Generali integration
            } else {
                response = new ONE_InsuranceIntegrationCallout.CajamarEditBudgetCallout(parsedParams).invokeCallout(true).getBody(); //Call Cajamar integration
            }
			
            System.debug(response);
            
            //Parse response
            Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(response);
            fo.codeError = (String) deserialized.get('codeError');
			
            if (deserialized.containsKey('errorMessages')) {//If we got any error get message string
                for (Object err : (List<Object>) deserialized.get('errorMessages')) {
                    fo.errorMessages.add((String) err);
                }
            }
            if (fo.codeError.contains('000')) {//OK response
                List<ScaleResponse> scList = new List<ScaleResponse>();
                if (deserialized.containsKey('scales')) {
                    for (Object o : (List<Object>) deserialized.get('scales')) {
                        scList.add(new ScaleResponse((String) o));

                    }

                    ordenRecord.ONE_Historial_Errores__c = Datetime.now() + ' - El envío del presupuesto se realizado correctamente';

                    clearScaleId(getDeleteRecords(ordenRecord.Id));
                    setScaleId(getAddRecords(ordenRecord.Id), scList);

                }
            } else {//Store error in text field to have to log available always
                ordenRecord.ONE_Historial_Errores__c += '\n';
                for (String s : fo.errorMessages) {
                    ordenRecord.ONE_Historial_Errores__c += Datetime.now() + ' - ' + s + ', ';
                }
            }
            System.debug(fo);

        } catch (Exception ex) {
            System.debug(ex);
            System.debug(ex.getLineNumber());

        }

        return new List<FlowOutputs>{
            fo
        };

    }
	//Build request template using input sales order
    public static RequestTemplate buildTemplate(Id ordenDeVentaId) {
        ONE_Orden_De_Venta__c ordenRecord = getOrdenRecord(ordenDeVentaId);
        RequestTemplate requestTemplate = new RequestTemplate(ordenRecord.ONE_budgetNumber__c,
            getScaleAddTemplates(ordenDeVentaId), getScaleUpdateTemplates(ordenDeVentaId), getScaleDeleteTemplates(ordenDeVentaId), ordenRecord.ONE_GeneraliOCajamar__c);
        return requestTemplate;

    }
	//Helper to query ONE_Orden_De_Venta__c object based on input ID
    public static ONE_Orden_De_Venta__c getOrdenRecord(Id ordenDeVentaId) {
        return [
            SELECT Id, Name, ONE_Servicio__r.ONE_Numero_de_Siniestro__c,ONE_Numero_de_factura__c, ONE_Tipo_Tasa__c, ONE_GeneraliOCajamar__c, ONE_Servicio__c, ONE_budgetNumber__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
            WITH SECURITY_ENFORCED
        ];
    }
	
    public static List<ScaleAddTemplate> getScaleAddTemplates(Id ordenDeVentaId) {
        List<ScaleAddTemplate> scales = new List<ScaleAddTemplate>();
        for (ONE_Lineas_Factura__c lf : getAddRecords(ordenDeVentaId)) {
            if (String.isBlank(lf.ONE_Identificador_Linea__c)) {
                System.debug(lf);
                scales.add(new ScaleAddTemplate('FU', lf?.ONE_tipo__c =='SE' ? '101' : '201', lf?.ONE_tipo__c, lf?.ONE_Precio__c, 1, Integer.valueOf(lf?.ONE_Tipo_Impositivo__c.removeEnd('%')), '-'));
            }

        }
        return scales;
    }
	//Helper to get invoiced lines
    public static List<ONE_Lineas_Factura__c> getAddRecords(Id ordenDeVentaId) {
        return [
            SELECT Id, ONE_tipo__c, ONE_Tipo_Impositivo__c, ONE_Codigo__c, ONE_Precio__c, ONE_Identificador_Linea__c
            FROM ONE_Lineas_Factura__c
            WHERE ONE_Orden_de_venta__c = :ordenDeVentaId AND ONE_Anulada__c = FALSE
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<ScaleUpdateTemplate> getScaleUpdateTemplates(Id ordenDeVentaId) {
        List<ScaleUpdateTemplate> scales = new List<ScaleUpdateTemplate>();
        for (ONE_Lineas_Factura__c lf : getUpdateRecords(ordenDeVentaId)) {
            if (String.isNotBlank(lf.ONE_Identificador_Linea__c)) {
                scales.add(new ScaleUpdateTemplate(lf.ONE_Identificador_Linea__c, 'FU', lf.ONE_tipo__c =='SE' ? '101' : '201', lf.ONE_tipo__c, lf.ONE_Precio__c, 1, Integer.valueOf(lf.ONE_Tipo_Impositivo__c.removeEnd('%')), '-'));
            }
        }
        return scales;
    }
	//Helper to get invoice lines that are not canceled
    public static List<ONE_Lineas_Factura__c> getUpdateRecords(Id ordenDeVentaId) {
        return [
            SELECT ONE_tipo__c, ONE_Tipo_Impositivo__c, ONE_Codigo__c, ONE_Precio__c, ONE_Identificador_Linea__c
            FROM ONE_Lineas_Factura__c
            WHERE ONE_Orden_de_venta__c = :ordenDeVentaId
            AND ONE_Anulada__c = FALSE
            WITH SECURITY_ENFORCED
        ];
    }
	
    public static List<String> getScaleDeleteTemplates(Id ordenDeVentaId) {
        List<String> scales = new List<String>();
        for (ONE_Lineas_Factura__c lf : getDeleteRecords(ordenDeVentaId)) {
            if (String.isNotBlank(lf.ONE_Identificador_Linea__c)) {
                scales.add(lf.ONE_Identificador_Linea__c);
            }

        }
        return scales;
    }
	//Get deleted invoiced lines
    public static List<ONE_Lineas_Factura__c> getDeleteRecords(Id ordenDeVentaId) {
        return [
            SELECT Id,ONE_Identificador_Linea__c
            FROM ONE_Lineas_Factura__c
            WHERE ONE_Orden_de_venta__c = :ordenDeVentaId AND ONE_Anulada__c = TRUE
            WITH SECURITY_ENFORCED
        ];
    }

    public static void clearScaleId(List<ONE_Lineas_Factura__c> lfList) {
        List<ONE_Lineas_Factura__c> tmpList = new List<ONE_Lineas_Factura__c>();
        for (ONE_Lineas_Factura__c lf : lfList) {
            if (String.isNotBlank(lf.ONE_Identificador_Linea__c)) {
                tmpList.add(lf);
            }
        }
        for (ONE_Lineas_Factura__c lf : tmpList) {
            lf.ONE_Identificador_Linea__c = '';
        }
        update tmpList;
    }
    public static void setScaleId(List<ONE_Lineas_Factura__c> lfList, List<ScaleResponse> scList) {
        List<ONE_Lineas_Factura__c> tmpList = new List<ONE_Lineas_Factura__c>();
        for (ONE_Lineas_Factura__c lf : lfList) {
            if (String.isBlank(lf.ONE_Identificador_Linea__c)) {
                tmpList.add(lf);
            }
        }

        for (Integer i = 0; i < scList.size(); i++) {
            tmpList[i].ONE_Identificador_Linea__c = scList[i].scaleId;
        }
        update tmpList;

    }
	//Flow input variable definition
    public class FlowInputs {
        @InvocableVariable
        public String ordenDeVentaId;
    }
	//Flow output variable definition
    public class FlowOutputs {
        @InvocableVariable
        public String codeError;

        @InvocableVariable
        public List<String> errorMessages;

        @InvocableVariable
        public List<BudgetResponse> budgets;
    }
	//Request template data structure
    public class RequestTemplate {
        public String budgetNumber { get; set; }
        public List<ScaleAddTemplate> add { get; set; }
        public List<ScaleUpdateTemplate> updateTmp { get; set; }
        public List<String> deleteTmp { get; set; }
        public String integrationType { get; set; }

        public RequestTemplate(String budgetNumber, List<ScaleAddTemplate> add, List<ScaleUpdateTemplate> updateTmp, List<String> deleteTmp, String integrationType) {
            this.budgetNumber = budgetNumber;
            this.add = add;
            this.updateTmp = updateTmp;
            this.deleteTmp = deleteTmp;
            this.integrationType = integrationType;
        }

    }
	//Request scale data structure
    public class ScaleAddTemplate {
        public String typeScale { get; set; }
        public String code { get; set; }
        public String type { get; set; }
        public Decimal price { get; set; }
        public Decimal amount { get; set; }
        public Decimal tax { get; set; }
        public String comment { get; set; }

        public ScaleAddTemplate(String typeScale, String code, String type, Decimal price, Decimal amount, Decimal tax, String comment) {
            this.typeScale = typeScale;
            this.code = code;
            this.type = type;
            this.price = price;
            this.amount = amount;
            this.tax = tax;
            this.comment = comment;

        }
    }
	//Request scale update data structure
    public class ScaleUpdateTemplate {
        public String scaleId { get; set; }
        public String typeScale { get; set; }
        public String code { get; set; }
        public String type { get; set; }
        public Decimal price { get; set; }
        public Decimal amount { get; set; }
        public Decimal tax { get; set; }
        public String comment { get; set; }

        public ScaleUpdateTemplate(String scaleId, String typeScale, String code, String type, Decimal price, Decimal amount, Decimal tax, String comment) {
            this.scaleId = scaleId;
            this.typeScale = typeScale;
            this.code = code;
            this.type = type;
            this.price = price;
            this.amount = amount;
            this.tax = tax;
            this.comment = comment;
        }
    }
	//Request scale delete data structure
    public class ScaleDeleteTemplate {
        public String scaleId { get; set; }
        public ScaleDeleteTemplate(String scaleId) {
            this.scaleId = scaleId;
        }
    }
	//Request budget data structure
    public class BudgetResponse {
        public String budgetNumber { get; set; }
        public List<ScaleResponse> scales { get; set; }

        public BudgetResponse(String budgetNumber, List<ScaleResponse> scales) {
            this.budgetNumber = budgetNumber;
            this.scales = scales;
        }
    }
	//Request scale response data structure
    public class ScaleResponse {
        public String scaleId { get; set; }

        public ScaleResponse(String scaleId) {
            this.scaleId = scaleId;
        }
    }

}
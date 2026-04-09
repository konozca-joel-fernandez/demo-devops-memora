/**
 * Created by kmotyka005 on 11.10.2021.
 */

public with sharing class ONE_InsuranceBudgetController {

	//Invocable method for the Generali and Cajamar budget creation integration
    @InvocableMethod(Label='Create budgets')
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        Boolean existePrincipal=false;
        String tipoFacturaM1=null;
        FlowOutputs fo = new FlowOutputs();
        fo.errorMessages = new List<String>();
        //Get sales order using input flow ID
        ONE_Orden_De_Venta__c ordenRecord = getOrdenRecord(flowInputs[0].ordenDeVentaId);
        List< ONE_Orden_De_Venta__c> ordenesdeVentaOfService=[SELECT ONE_Tipo_De_Factura_M1__c,ONE_Estado_De_La_Orden_de_Venta__c,ONE_GeneraliOCajamar__c,ONE_estado__c 
                                                              FROM ONE_Orden_De_Venta__c 
                                                              WHERE Id!=:ordenRecord.Id AND ONE_Servicio__c=:ordenRecord.ONE_Servicio__c];
        if(ordenesdeVentaOfService.size()>0){
            for(ONE_Orden_De_Venta__c orden: ordenesdeVentaOfService){
                if(orden.ONE_Tipo_De_Factura_M1__c=='Principal' && orden.ONE_Estado_De_La_Orden_de_Venta__c!='Abonado' && orden.ONE_GeneraliOCajamar__c!=null && orden.ONE_estado__c=='A'){
                    existePrincipal=true;
                }
            }
        }else{
            existePrincipal=false;
        }
        System.debug('Existe principal : '+existePrincipal);
        tipoFacturaM1=[SELECT ONE_Tipo_De_Factura_M1__c FROM ONE_Orden_De_Venta__c WHERE Id=:flowInputs[0].ordenDeVentaId].ONE_Tipo_De_Factura_M1__c;
        System.debug('tipoFacturaM1 : '+tipoFacturaM1);
        //Get factured lines using sales order
        List<ONE_Expediente_Line_Item__c> lineasFacturasList = getFacturaLineas(flowInputs[0].ordenDeVentaId);

        try {
            String response = '';
            requestTemplate requestTemplate = buildTemplate(flowInputs[0].ordenDeVentaId, existePrincipal,tipoFacturaM1); // get basic request template
            Map<String, Object> parsedParams = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(requestTemplate));//obtain parameter
            String integrationType = String.valueOf(parsedParams.get('integrationType')).toLowerCase();
            parsedParams.remove('integrationType');
            if (integrationType.equalsIgnoreCase('G')) {//Check type to know the right endpoint
                response = new ONE_InsuranceIntegrationCallout.GeneraliCreateBudgetCallout(parsedParams).invokeCallout(true).getBody(); // Generali callout
            } else {
                response = new ONE_InsuranceIntegrationCallout.CajamarCreateBudgetCallout(parsedParams).invokeCallout(true).getBody(); // Generali Cajamar
            }
			//Parse response
            System.debug(response);
            Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(response);
            fo.codeError = (String) deserialized.get('codeError');

            if (deserialized.containsKey('errorMessages')) { // In case we got any error in the response
                for (Object err : (List<Object>) deserialized.get('errorMessages')) {
                    fo.errorMessages.add((String) err);//Get error message
                }
            }
            if (fo.codeError.contains('000')) {// In case we got an OK response
                fo.budgets = new List<BudgetResponse>();
                for (Object instance : (List<Object>) deserialized.get('budgets')) {
                    Map<String, Object> m = (Map<String, Object>) instance;
                    BudgetResponse br = new BudgetResponse((String) m.get('budgetNumber'), new List<ScaleResponse>());
                    for (Object o : (List<Object>) m.get('scales')) {
                        Map<String, Object> mm = (Map<String, Object>) o;
                        br.scales.add(new ScaleResponse((String) mm.get('scaleId')));
                    }
                    fo.budgets.add(br);
                }
                ordenRecord.ONE_Historial_Errores__c = Datetime.now() + ' - El envío del presupuesto se realizado correctamente';
                ordenRecord.ONE_budgetNumber__c = fo.budgets[0].budgetNumber;
                for (Integer i = 0; i < fo.budgets[0].scales.size(); i++) {
                    lineasFacturasList[i].ONE_Identificador_Linea_Factura__c = fo.budgets[0].scales[i].scaleId;
                }
                update lineasFacturasList;
            } else {
                ordenRecord.ONE_Historial_Errores__c += '\n';
                for (String s : fo.errorMessages) {
                    ordenRecord.ONE_Historial_Errores__c += Datetime.now() + ' - ' + s + ', ';
                }

            }
            update ordenRecord;
            System.debug(fo);
        } catch (Exception ex) { // Error handler for the response parser
            System.debug(ex);
            System.debug(ex.getLineNumber());
            System.debug(ex.getStackTraceString());

        }

        return new List<FlowOutputs>{
            fo
        };

    }
 	//Basic request template builder
    public static requestTemplate buildTemplate(Id ordenDeVentaId,Boolean existePrincipal,String tipoFacturaM1) {
        ONE_Orden_De_Venta__c ordenRecord = getOrdenRecord(ordenDeVentaId);
        requestTemplate requestTemplate = new requestTemplate(ordenRecord.ONE_Servicio__r.ONE_Numero_de_Siniestro__c, buildBudgetTemplate(ordenRecord,existePrincipal,tipoFacturaM1), ordenRecord.ONE_GeneraliOCajamar__c);

        return requestTemplate;
    }
	//Basic request budget template builder
    public static List<BudgetTemplate> buildBudgetTemplate(ONE_Orden_De_Venta__c ordenDeVenta,Boolean existePrincipal,String tipoFacturaM1) {
        List<BudgetTemplate> budgetsList = new List<BudgetTemplate>();
        budgetsList.add(new BudgetTemplate(
            ordenDeVenta.Id, buildInvoiceFileList(ordenDeVenta,existePrincipal,tipoFacturaM1), '-', '-', '-', '-',
            '-', '-', '-', '-',
            getTaxType(ordenDeVenta.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c), '-', buildScalesList(ordenDeVenta)
        ));
        System.debug('ordenDeVenta.ONE_Tipo_Tasa__c'+ordenDeVenta.ONE_Tipo_Tasa__c);
		System.debug('REQUEST-DEBUG'+ budgetsList);
        return budgetsList;
    }
	//Scale list builder
    public static List<ScaleTemplate> buildScalesList(ONE_Orden_De_Venta__c ordenDeVenta) {
        List<ONE_Expediente_Line_Item__c> lineasFacturasList = getFacturaLineas(ordenDeVenta.Id);
        List<ScaleTemplate> scalesList = new List<ScaleTemplate>();
        for (ONE_Expediente_Line_Item__c lf : lineasFacturasList) {
            
            scalesList.add(
                new ScaleTemplate('FU', lf.ONE_TrasladoM1__c ? '201' : '101', lf.ONE_TrasladoM1__c ? 'TR' : 'SE', lf.ONE_Precio__c, 1,
                    Integer.valueOf(lf.ONE_Impuesto__c), '-')
            );
        }

        return scalesList;
    }
    
    public static String getTaxType(String tipoDeImpuesto){
        switch on tipoDeImpuesto {
            when 'IVA' {
				return '1';
            }	
            when 'IPSI' {
				return '2';
            }
            when 'IGIC' {
				return '3';
            }
            when else {
				return null;
            }
        }
    }
    
	//Build invoice file list
    public static List<InvoiceFileTemplate> buildInvoiceFileList(ONE_Orden_De_Venta__c ordenDeVenta, Boolean existePrincipal,String tipoFacturaM1) {
        List<InvoiceFileTemplate> invoiceFiles = new List<InvoiceFileTemplate>();
        invoiceFiles.add(new InvoiceFileTemplate(getInvoiceFile(ordenDeVenta.ONE_Servicio__c, existePrincipal,tipoFacturaM1), 'FOT', 'Facturacion_' + ordenDeVenta.Name + '.pdf'));
        return invoiceFiles;
    }

	//Method to query sales order based oninput ID
    public static ONE_Orden_De_Venta__c getOrdenRecord(Id ordenDeVentaId) {
        System.debug(ordenDeVentaId);
        return [
            SELECT Id, Name, ONE_Servicio__r.ONE_Numero_de_Siniestro__c,ONE_Numero_de_factura__c, ONE_Tipo_Tasa__c, ONE_GeneraliOCajamar__c, ONE_Servicio__c, ONE_Historial_Errores__c,ONE_budgetNumber__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
            WITH SECURITY_ENFORCED
        ];
    }
	//Method to query sales order based on input ID
    public static List<ONE_Expediente_Line_Item__c> getFacturaLineas(Id ordenDeVentaId) {
        return [
            SELECT Id, ONE_TrasladoM1__c, ONE_Precio__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c, ONE_Identificador_Linea_Factura__c, ONE_Impuesto__c
            FROM ONE_Expediente_Line_Item__c
            WHERE ONE_Orden_de_venta__c = :ordenDeVentaId AND (ONE_Estado__c = 'Facturado' OR ONE_Estado__c = 'Confirmado')
            WITH SECURITY_ENFORCED
        ];
    }
	//Obtain factura document
    public static Blob getInvoiceFile(Id expedienteId, Boolean existePrincipal, String tipoFacturaM1) {
        Blob invoiceFile = null;
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :expedienteId];
        Set<Id>contentDocumentLinksSet = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentLinksSet.add(cdl.ContentDocumentId);
        }
        List<ContentVersion> contentVersions = [SELECT Id,TagCsv,VersionData FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinksSet];
        for (ContentVersion cv : contentVersions) {
            if ((cv.TagCsv == 'DOCUMENTACION_CIA' && tipoFacturaM1=='Principal')|| (cv.TagCsv == 'DOCUMENTACION_ADICIONAL_CIA' && tipoFacturaM1=='Complementaria')){
                invoiceFile = cv.VersionData;
                System.debug ('TAGCSV '+cv.TagCsv);
                System.debug ('existePrincipal '+existePrincipal);
                System.debug ('tipoFacturaM1 '+tipoFacturaM1);
            }
        }
        System.debug('invoiceFile: '+invoiceFile);
        return invoiceFile;
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
	//Budget temaplte data model definition
    public class BudgetTemplate {
        public String refProvider { get; set; }
        public List<InvoiceFileTemplate> invoiceFiles { get; set; }
        public String originLocality { get; set; }
        public String originProvince { get; set; }
        public String originCountry { get; set; }
        public String originPlace { get; set; }
        public String destinationLocality { get; set; }
        public String destinationProvince { get; set; }
        public String destinationCountry { get; set; }
        public String destinationPlace { get; set; }
        public String taxType { get; set; }
        public String observations { get; set; }
        public List<ScaleTemplate> scales { get; set; }

		//Budget template data factory
        public BudgetTemplate(String refProvider, List<InvoiceFileTemplate> invoiceFiles, String originLocality, String originProvince, String originCountry, String originPlace,
            String destinationLocality, String destinationProvince, String destinationCountry, String destinationPlace,
            String taxType, String observations, List<ScaleTemplate> scales) {

            this.refProvider = refProvider ;
            this.originLocality = originLocality ;
            this.originProvince = originProvince ;
            this.originCountry = originCountry ;
            this.originPlace = originPlace;
            this.destinationLocality = destinationLocality;
            this.destinationProvince = destinationProvince ;
            this.destinationCountry = destinationCountry;
            this.destinationPlace = destinationPlace;
            this.taxType = taxType;
            this.observations = observations ;
            this.scales = scales;
            this.invoiceFiles = invoiceFiles;
        }

    }
	//Scale template data model definition
    public class ScaleTemplate {
        public String typeScale { get; set; }
        public String code { get; set; }
        public String type { get; set; }
        public Decimal price { get; set; }
        public Decimal amount { get; set; }
        public Decimal tax { get; set; }
        public String comment { get; set; }

        public ScaleTemplate(String typeScale, String code, String type, Decimal price, Decimal amount, Decimal tax, String comment) {
            this.typeScale = typeScale;
            this.code = code;
            this.type = type;
            this.price = price;
            this.amount = amount;
            this.tax = tax;
            this.comment = comment;
        }
    }
	//Invoice template data model definition
    public class InvoiceFileTemplate {
        public Blob invoiceFile { get; set; }
        public String invoiceFileType { get; set; }
        public String invoiceFileName { get; set; }

        public InvoiceFileTemplate(Blob invoiceFile, String invoiceFileType,
            String invoiceFileName) {
            this.invoiceFile = invoiceFile ;
            this.invoiceFileType = invoiceFileType;
            this.invoiceFileName = invoiceFileName;
        }
    }
	//Request template data model definition
    public class requestTemplate {
        public String claimNumber { get; set; }
        public List<BudgetTemplate> budgets { get; set; }
        public String integrationType { get; set; }

        public requestTemplate(String claimNumber, List<BudgetTemplate> budgets, String integrationType) {
            this.claimNumber = claimNumber;
            this.budgets = budgets;
            this.integrationType = integrationType;
        }

    }
	//Budget response template data model definition
    public class BudgetResponse {
        public String budgetNumber { get; set; }
        public List<ScaleResponse> scales { get; set; }

        public BudgetResponse(String budgetNumber, List<ScaleResponse> scales) {
            this.budgetNumber = budgetNumber;
            this.scales = scales;
        }
    }
	//Scale response template data model definition
    public class ScaleResponse {
        public String scaleId { get; set; }

        public ScaleResponse(String scaleId) {
            this.scaleId = scaleId;
        }
    }

}
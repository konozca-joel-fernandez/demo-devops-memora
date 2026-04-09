/**
 * Created by mchruscick001 on 17.11.2021 08:19.
 */

public with sharing class ONE_OrdenInvoice {
	//Invocable method to call orden invoice via flow
    @InvocableMethod
    public static List<InvoiceCalloutResponse> invokeIntegrationWithOrderUpdate(List<Id> salesOrderIds) {
        return processOrders(new List<ONE_Orden_De_Venta__c>{ONE_OrdenDeVentaSelector.selectSalesOrders(salesOrderIds)[0]});
    }
    //Method to invoke integration and update sales order register based on the response
    public static List<InvoiceCalloutResponse> processOrders(List<ONE_Orden_De_Venta__c> ordenDeVentaList) {
        List<InvoiceCalloutResponse> invoiceCalloutResponses = invokeIntegrations(ordenDeVentaList); // Call integration
        updateSalesOrdersFromResponse(invoiceCalloutResponses);// Parse response
        return invoiceCalloutResponses;
    }
    //Integration request call method
    static List<InvoiceCalloutResponse> invokeIntegrations(List<ONE_Orden_De_Venta__c> salesOrders) {
        List<InvoiceCalloutResponse> invoiceCalloutResponses = new List<InvoiceCalloutResponse>();
        Map<String, Blob> invoiceFilesPrincipal = ONE_OrdenInvoice.getInvoiceFilesPrincipal(getExtractServiceIds(salesOrders, 'Principal'));
        Map<String, Blob> invoiceFilesComplementaria = ONE_OrdenInvoice.getInvoiceFilesComplementaria(getExtractServiceIds(salesOrders, 'Complementaria'));
        for (ONE_Orden_De_Venta__c salesOrder : salesOrders) {
            for (String serviceId : invoiceFilesPrincipal.keySet()) {
                if (salesOrder.ONE_Servicio__c == serviceId) {
                    invoiceCalloutResponses.add(ONE_OrdenInvoice.invokeIntegration(
                            ONE_OrdenInvoice.buildTemplate(salesOrder, ONE_OrdenInvoice.buildInvoiceFileTemplate(salesOrder, invoiceFilesPrincipal.get(serviceId))),
                            salesOrder)
                    );
                }
            }
            for (String serviceId : invoiceFilesComplementaria.keySet()) {
                if (salesOrder.ONE_Servicio__c == serviceId) {
                    invoiceCalloutResponses.add(ONE_OrdenInvoice.invokeIntegration(
                            ONE_OrdenInvoice.buildTemplate(salesOrder, ONE_OrdenInvoice.buildInvoiceFileTemplate(salesOrder, invoiceFilesComplementaria.get(serviceId))),
                            salesOrder)
                    );
                }
            }
        }
        return invoiceCalloutResponses;
    }
    //Obtain service ID from sales order input list
    static Set<Id> getExtractServiceIds(List<ONE_Orden_De_Venta__c> salesOrders,String tipodeOrdendeVenta) { 
        Set<Id> expedienteIdsPrincipal = new Set<Id>();
        Set<Id> expedienteIdsComplementaria = new Set<Id>();
        for (ONE_Orden_De_Venta__c salesOrder : salesOrders) {
            System.debug('TIPO: '+salesOrder.ONE_Tipo_De_Factura_M1__c + 'Servicio: '+salesOrder.ONE_Servicio__c);
            if(salesOrder.ONE_Tipo_De_Factura_M1__c=='Principal'){
                expedienteIdsPrincipal.add(salesOrder.ONE_Servicio__c);
        	}
            if(salesOrder.ONE_Tipo_De_Factura_M1__c=='Complementaria'){
                expedienteIdsComplementaria.add(salesOrder.ONE_Servicio__c);
        	}
        }
		if(tipodeOrdendeVenta=='Principal'){
            System.debug('expedienteIdsPrincipal: '+expedienteIdsPrincipal);
    		return expedienteIdsPrincipal;
        }else if(tipodeOrdendeVenta=='Complementaria'){
            System.debug('expedienteIdsComplementaria: '+expedienteIdsComplementaria);
            return expedienteIdsComplementaria;
        } 
        
        return null;
    }
    //Update sales order information
    static void updateSalesOrdersFromResponse(List<InvoiceCalloutResponse> InvoiceCalloutResponse) {
        update getExtractOrdersFromResponse(InvoiceCalloutResponse);
    }
    //Parse response to obtain sales order
    static List<ONE_Orden_De_Venta__c> getExtractOrdersFromResponse(List<InvoiceCalloutResponse> InvoiceCalloutResponse) {
        System.debug('~~ ' + InvoiceCalloutResponse);
        List<ONE_Orden_De_Venta__c> salesOrders = new List<ONE_Orden_De_Venta__c>();
        for (InvoiceCalloutResponse responseError : InvoiceCalloutResponse) {
            salesOrders.add(responseError.salesOrder);
        }
        return salesOrders;
    }
    //Call integration and obtain response
    static InvoiceCalloutResponse invokeIntegration(RequestTemplate requestTemplate, ONE_Orden_De_Venta__c ordenRecord) {
        InvoiceCalloutResponse bo = new InvoiceCalloutResponse();
        try { // Try parse response
            String response = '';
            Map<String, Object> parsedParams = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(requestTemplate));
            String integrationType = String.valueOf(parsedParams.get('integrationType')).toLowerCase();
            parsedParams.remove('integrationType');
            //Check the endpoint to call Generali/Cajamar
            if (integrationType.equalsIgnoreCase('G')) {
                response = new ONE_InsuranceIntegrationCallout.GeneraliInvoiceCallout(parsedParams).invokeCallout(true).getBody();
            } else {
                response = new ONE_InsuranceIntegrationCallout.CajamarInvoiceCallout(parsedParams).invokeCallout(true).getBody();
            }

            System.debug(response);
            Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(response);
            bo.codeError = (String) deserialized.get('codeError');

            if (deserialized.containsKey('errorMessages')) { // Get error message in case we got any
                bo.errorMessages = new List<String>();
                for (Object err : (List<Object>) deserialized.get('errorMessages')) {
                    bo.errorMessages.add((String) err);
                }
            }
            if (bo.codeError.contains('000')) { // 000 code means an OK response
                ordenRecord.ONE_Historial_Errores__c += addNewLineIfHistoryFieldNotEmpty(ordenRecord.ONE_Historial_Errores__c) + (Datetime.now() + ' - El envío de la factura se ha realizado correctamente');
                ordenRecord.ONE_Facturado_Generali__c = true;

            } else {
                ordenRecord.ONE_Historial_Errores__c += '\n';
                for (String s : bo.errorMessages) {
                    ordenRecord.ONE_Historial_Errores__c += Datetime.now() + ' - ' + s + ', ';
                }
            }
            bo.salesOrder = ordenRecord;
            return bo;
        } catch (Exception ex) { // In case of error
            System.debug(ex);
            System.debug(ex.getLineNumber());
            System.debug(ex.getStackTraceString());
            return bo;
        }
    }

    static String addNewLineIfHistoryFieldNotEmpty(String historicalErrorsField) {
        return String.isNotBlank(historicalErrorsField) ? '\n' : '';
    }
    
    static Map<String, Blob> getInvoiceFilesPrincipal(Set<Id> expedienteIds) {
        Map<String, String> contentDocumentIdForExpediente = new Map<String, String>();
        Map<String, Blob> expedienteForFiles = new Map<String, Blob>();
        if(expedienteIds.size()!=0){
            List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :expedienteIds LIMIT 50000];
            Set<Id>contentDocumentLinksSet = new Set<Id>();
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                contentDocumentLinksSet.add(cdl.ContentDocumentId);
                contentDocumentIdForExpediente.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
            List<ContentVersion> contentVersions = [SELECT Id,TagCsv,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinksSet];
            for (ContentVersion cv : contentVersions) {
                if (cv.TagCsv == 'DOCUMENTACION_CIA') {
                    expedienteForFiles.put(contentDocumentIdForExpediente.get(cv.ContentDocumentId), cv.VersionData);
                }
            }
        }
        return expedienteForFiles;
    }

     static Map<String, Blob> getInvoiceFilesComplementaria(Set<Id> expedienteIds) {
         
        Map<String, String> contentDocumentIdForExpediente = new Map<String, String>();
        Map<String, Blob> expedienteForFiles = new Map<String, Blob>();
  		if(expedienteIds.size()!=0){
            List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :expedienteIds LIMIT 50000];
            Set<Id>contentDocumentLinksSet = new Set<Id>();
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                contentDocumentLinksSet.add(cdl.ContentDocumentId);
                contentDocumentIdForExpediente.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
             
            List<ContentVersion> contentVersions = [SELECT Id,TagCsv,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinksSet];
            for (ContentVersion cv : contentVersions) {
                if (cv.TagCsv == 'DOCUMENTACION_ADICIONAL_CIA') {
                    expedienteForFiles.put(contentDocumentIdForExpediente.get(cv.ContentDocumentId), cv.VersionData);
                }
            } 
         }
       

        return expedienteForFiles;
    }

    static InvoiceFileTemplate buildInvoiceFileTemplate(ONE_Orden_De_Venta__c ordenRecord, Blob file) {
        return new InvoiceFileTemplate(file, 'PDF', 'Facturacion_' + ordenRecord.Name + '.pdf');
    }

    static RequestTemplate buildTemplate(ONE_Orden_De_Venta__c ordenRecord, InvoiceFileTemplate ift) {
        return new RequestTemplate(ordenRecord.ONE_budgetNumber__c, ordenRecord.ONE_Numero_de_factura__c, ordenRecord.ONE_Fecha_De_Facturacion__c, new List<InvoiceFileTemplate>{
                ift
        }, ordenRecord.ONE_GeneraliOCajamar__c);
    }
	//Request data builder definition
    class RequestTemplate {
        public String budgetNumber { get; set; }
        public String refProvider { get; set; }
        public Date invoiceDate { get; set; }
        public List<InvoiceFileTemplate> invoiceFiles { get; set; }
        public String integrationType { get; set; }

        public RequestTemplate(String budgetNumber, String refProvider, Date invoiceDate, List<InvoiceFileTemplate> invoiceFiles, String integrationType) {
            this.budgetNumber = budgetNumber;
            this.refProvider = refProvider;
            this.invoiceDate = invoiceDate;
            this.invoiceFiles = invoiceFiles;
            this.integrationType = integrationType;
        }
    }

    class InvoiceFileTemplate {
        public Blob invoiceFile { get; set; }
        public String invoiceFileType { get; set; }
        public String invoiceFileName { get; set; }

        public InvoiceFileTemplate(Blob invoiceFile, String invoiceFileType, String invoiceFileName) {
            this.invoiceFile = invoiceFile ;
            this.invoiceFileType = invoiceFileType;
            this.invoiceFileName = invoiceFileName;
        }
    }
    //Flow variable definition
    public class InvoiceCalloutResponse {
        @InvocableVariable
        public String codeError;
        @InvocableVariable
        public List<String> errorMessages;
        @InvocableVariable
        public ONE_Orden_De_Venta__c salesOrder;
    }
}
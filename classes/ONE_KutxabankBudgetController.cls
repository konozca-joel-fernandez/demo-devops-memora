/**
* File Name: ONE_KutxabankBudgetController
* Description: 	Class to handle the creation of budgets for Kutxabank orders
* Date: 31/07/2025
*
* Copyright: Konozca Consulting
* @author: Marc Pàmies
* Test: ONE_KutxabankBudgetTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		31/07/2025		Marc Pàmies  		Class creation
* ===================================================================================================================
*/

public with sharing class ONE_KutxabankBudgetController {

    @InvocableMethod(Label='Create Kutxabank budgets manually')
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        List<ONE_Orden_De_Venta__c> ordenesdeVentaOfService=[SELECT ONE_Servicio__r.ONE_Caso__r.ONE_Numero_De_Siniestro_Texto__c, ONE_Numero_de_factura__c,
                                                              ONE_Fecha_De_Facturacion__c, ONE_Importe_Base__c, ONE_Importe_Base_3__c, ONE_Importe_Base_4__c,
                                                              ONE_Importe_Base_10__c, ONE_Importe_Base_21__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                                                              ONE_Importe_Impuesto_3__c, ONE_Importe_Impuesto_4__c, ONE_Importe_Impuesto_10__c, ONE_Numero_Abono_Factura__c,
                                                              ONE_Importe_Impuesto_21__c, ONE_Importe_Total__c, ONE_Importe_Neto_0__c, ONE_Importe_Neto_3__c,
                                                              ONE_Importe_Neto_4__c, ONE_Importe_Neto_10__c, ONE_Importe_Neto_21__c, ONE_Importe_Neto_Suplido__c, ONE_Estado_De_La_Orden_de_Venta__c,
                                                              ONE_Identificador_TBAI_Abono__c, ONE_Identificador_TBAI_Factura__c, ONE_Fecha_Hora_Del_Abono_Factura__c
                                                              FROM ONE_Orden_De_Venta__c 
                                                              WHERE Id = :flowInputs[0].ordenDeVentaId];
        List<ContentDocumentLink> cdlFactura = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :flowInputs[0].ordenDeVentaId];
        String documentTitle;
        String errorMsg;
        if (ordenesdeVentaOfService[0].ONE_Estado_De_La_Orden_de_Venta__c == 'Facturado'){
            documentTitle = 'Nº Factura SAP: ' + ordenesdeVentaOfService[0].ONE_Numero_de_factura__c + '%';
            errorMsg = 'No se ha encontrado el pdf para la factura asociada a la orden de venta';
        }
        else {
            documentTitle = 'Nº Abono ' + ordenesdeVentaOfService[0].ONE_Numero_Abono_Factura__c + '%';
            errorMsg = 'No se ha encontrado el pdf para el abono asociado a la orden de venta';
        }
        if (!cdlFactura.isEmpty()) {
            List<Id> cdlIds = new List<Id>();
            for (ContentDocumentLink cdl : cdlFactura) {
                cdlIds.add(cdl.ContentDocumentId);
            }
            List<ContentVersion> cvFactura = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId IN :cdlIds AND IsLatest = true AND Title LIKE :documentTitle ORDER BY CreatedDate DESC];
            if (!cvFactura.isEmpty()) {
                BudgetRequest budgetRequest = buildBudgetRequest(ordenesdeVentaOfService[0], EncodingUtil.base64Encode(cvFactura[0].VersionData), documentTitle.remove('%'));
                if (flowInputs[0].batchProcess == true) {
                    return parseResponse(new ONE_InsuranceIntegrationCallout.KutxabankBatchCreateBudgetCallout(budgetRequest).invokeCallout());
                } else {
                     return parseResponse(new ONE_InsuranceIntegrationCallout.KutxabankCreateBudgetCallout(budgetRequest).invokeCallout());
                }
            }
        }
        FlowOutputs fo = new FlowOutputs();
        fo.success = false;
        fo.returnValue = errorMsg;
        fo.customError = true;
        return new List<FlowOutputs>{
            fo
        };
    }

    public static List<FlowOutputs> parseResponse(HttpResponse resp) {
        System.debug('Response: ' + resp.getBody());

        FlowOutputs fo = new FlowOutputs();
        Map<String, Object> parsed;
        
        try {
            parsed = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        } catch (Exception e) {
            fo.success = false;
            fo.returnValue = resp.getBody();
            fo.customError = false;
            return new List<FlowOutputs>{ fo };
        }
        if (resp.getStatusCode() == 201) {
            fo.success = true;
            fo.customError  = false;
            Map<String, Object> resultadoMap = (Map<String, Object>) parsed.get('resultado');
            String result = resultadoMap != null ? (String) resultadoMap.get('Expediente') : null;

            if (result != null) {
                Pattern p = Pattern.compile('\\((\\d+)\\)');
                Matcher m = p.matcher(result);
                if (m.find()) {
                    fo.returnValue = m.group(1);
                } else {
                    fo.success = false;
                    fo.customError = true;
                    fo.returnValue = 'No se ha encontrado el número de factura en: ' + result;
                }
            } else {
                fo.success = false;
                fo.customError = true;
                fo.returnValue = 'Número de factura no encontrado en la respuesta';
            }
        } else {
            fo.errorCode = resp.getStatusCode();
            fo.success = false;
            fo.customError = false;

            if (fo.errorCode == 503) {
                fo.returnValue = 'Servicio de Kutxabank no disponible en este momento. Inténtelo de nuevo más tarde.';
                return new List<FlowOutputs>{ fo };
            }

            Object resultadoObj = parsed.get('resultado');
            if (resultadoObj != null) {
                if (resultadoObj instanceof String) {
                    fo.returnValue = (String) resultadoObj;
                } else if (resultadoObj instanceof Map<String, Object>) {
                    Map<String, Object> resMap = (Map<String, Object>) resultadoObj;
                    fo.returnValue = resMap.containsKey('Message') ? String.valueOf(resMap.get('Message')) : '';
                    fo.returnValue = resMap.containsKey('Mensaje') ? String.valueOf(resMap.get('Mensaje')) : '';
                    fo.returnValue += resMap.containsKey('Detalles') ? ': ' + String.valueOf(resMap.get('Detalles')) : '';
                    if (fo.returnValue == '') {
                        fo.returnValue = String.valueOf(resMap);
                    }
                } else if (resultadoObj instanceof List<Object>) {
                    fo.returnValue = String.valueOf((List<Object>) resultadoObj);
                } else {
                    fo.returnValue = String.valueOf(resultadoObj);
                }
            } else {
                fo.returnValue = resp.getBody();
            }

            System.debug(LoggingLevel.ERROR, 'Error: ' + fo.returnValue);
        }

        return new List<FlowOutputs>{ fo };
    }

    public static BudgetRequest buildBudgetRequest(ONE_Orden_De_Venta__c orden, String factura, String nombreFactura) {
        BudgetRequest budgetRequest = new BudgetRequest();
        budgetRequest.NumeroSiniestro = orden.ONE_Servicio__r.ONE_Caso__r.ONE_Numero_De_Siniestro_Texto__c;
        budgetRequest.NumeroFactura = orden.ONE_Numero_de_factura__c;
        if (orden.ONE_Estado_De_La_Orden_de_Venta__c == 'Abonado') {
            budgetRequest.FechaFactura = orden.ONE_Fecha_Hora_Del_Abono_Factura__c.format('yyyy-MM-dd');
        } else {
            Time timeFactura = Time.newInstance(0, 0, 0, 0);
            Datetime fechaFactura = Datetime.newInstance(orden.ONE_Fecha_De_Facturacion__c, timeFactura);
            budgetRequest.FechaFactura = fechaFactura.format('yyyy-MM-dd');
        }
        budgetRequest.BaseImponible = orden.ONE_Importe_Base__c;
        budgetRequest.TipoImpuesto = orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c == 'IVA' ? '1' : orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c == 'IGIC' ? '2' : '3';
        budgetRequest.ImporteImpuesto = getImporteImpuesto(orden);
        budgetRequest.ImporteExentoIVA = (orden.ONE_Importe_Neto_0__c != null && orden.ONE_Importe_Neto_0__c != 0) ? orden.ONE_Importe_Neto_0__c : orden.ONE_Importe_Neto_Suplido__c != null ? orden.ONE_Importe_Neto_Suplido__c : 0;
        budgetRequest.ImporteTotal = orden.ONE_Importe_Total__c;
        budgetRequest.IdHacienda = orden.ONE_Estado_De_La_Orden_de_Venta__c == 'Abonado'? orden.ONE_Identificador_TBAI_Abono__c : orden.ONE_Identificador_TBAI_Factura__c;
        budgetRequest.Servicios = new List<Servicios>();
        List<Servicios> servicios = buildServicios(orden);
        budgetRequest.Servicios = servicios;
        budgetRequest.Documentos = new List<Documentos>();
        Documentos documento = new Documentos();
        documento.TipoDocumento = '0001';
        documento.Nombre = nombreFactura.replace(':','') + '.pdf';
        documento.Formato = 'pdf';
        documento.Documento = factura;
        budgetRequest.Documentos.add(documento);
        if(orden.ONE_Estado_De_La_Orden_de_Venta__c == 'Abonado') return tratamientoAbono(budgetRequest, orden.ONE_Numero_Abono_Factura__c);
        return budgetRequest;
    }

    public static BudgetRequest tratamientoAbono(BudgetRequest budgetRequest, String numeroAbonoFactura) {
        budgetRequest.NumeroFactura = numeroAbonoFactura;
        budgetRequest.BaseImponible = -budgetRequest.BaseImponible;
        budgetRequest.ImporteImpuesto = -budgetRequest.ImporteImpuesto;
        budgetRequest.ImporteExentoIVA = -budgetRequest.ImporteExentoIVA;
        budgetRequest.ImporteTotal = -budgetRequest.ImporteTotal;
        for (Servicios servicio : budgetRequest.Servicios) {
            servicio.BaseImponible = -servicio.BaseImponible;
            servicio.ImporteImpuesto = -servicio.ImporteImpuesto;
            servicio.ImporteTotal = -servicio.ImporteTotal;
        }
        return budgetRequest;
    }

    public static Decimal getImporteImpuesto(ONE_Orden_De_Venta__c orden) {
        Decimal importeImpuesto = 0;
        if (orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c == 'IVA') {
            importeImpuesto = orden.ONE_Importe_Impuesto_21__c + orden.ONE_Importe_Impuesto_10__c + orden.ONE_Importe_Impuesto_4__c;
        } else {
            importeImpuesto = orden.ONE_Importe_Impuesto_3__c;
        }
        return importeImpuesto;
    }

    public static List<Servicios> buildServicios(ONE_Orden_De_Venta__c orden) {
        Map<Decimal, List<ONE_Expediente_Line_Item__c>> taxRateToTraslado = new Map<Decimal, List<ONE_Expediente_Line_Item__c>>();
        Set<Decimal> taxRateToService = new Set<Decimal>();
        String estado = orden.ONE_Estado_De_La_Orden_de_Venta__c == 'Abonado' ? 'Cancelado' : 'Facturado';
        for(ONE_Expediente_Line_Item__c sli : [SELECT ONE_Importe_Base__c, ONE_Importe_Neto__c, ONE_Impuesto__c, ONE_Importe_Impuesto__c, ONE_TrasladoM1__c
                                                    FROM ONE_Expediente_Line_Item__c
                                                    WHERE ONE_Orden_De_Venta__c = :orden.Id AND ONE_Estado__c = :estado]) {
            if (sli.ONE_TrasladoM1__c == true){
                if(taxRateToTraslado.containsKey(sli.ONE_Impuesto__c)){
                    List<ONE_Expediente_Line_Item__c> existingList = taxRateToTraslado.get(sli.ONE_Impuesto__c);
                    existingList.add(sli);
                    taxRateToTraslado.put(sli.ONE_Impuesto__c, existingList);
                }
                else{
                    List<ONE_Expediente_Line_Item__c> newList = new List<ONE_Expediente_Line_Item__c>{sli};
                    taxRateToTraslado.put(sli.ONE_Impuesto__c, newList);
                }
            }
            else {
                if(taxRateToService.contains(sli.ONE_Impuesto__c)){
                    continue;
                }
                else{
                    taxRateToService.add(sli.ONE_Impuesto__c);
                }
            }
        }

        List<Servicios> servicios = new List<Servicios>();

        if (orden.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c == 'IVA'){
            if (orden.ONE_Importe_Neto_21__c != null && orden.ONE_Importe_Neto_21__c > 0) {
                servicios.addAll(buildServicioByTax(taxRateToService.contains(21.00) ? true : false, taxRateToTraslado.containsKey(21.00) ? taxRateToTraslado.get(21.00) : new List<ONE_Expediente_Line_Item__c>(), 21, orden.ONE_Importe_Base_21__c, orden.ONE_Importe_Impuesto_21__c, orden.ONE_Importe_Neto_21__c));
            } if (orden.ONE_Importe_Neto_10__c != null && orden.ONE_Importe_Neto_10__c > 0) {
                servicios.addAll(buildServicioByTax(taxRateToService.contains(10.00) ? true : false, taxRateToTraslado.containsKey(10.00) ? taxRateToTraslado.get(10.00) : new List<ONE_Expediente_Line_Item__c>(), 10, orden.ONE_Importe_Base_10__c, orden.ONE_Importe_Impuesto_10__c, orden.ONE_Importe_Neto_10__c));
            } if (orden.ONE_Importe_Neto_4__c != null && orden.ONE_Importe_Neto_4__c > 0) {
                servicios.addAll(buildServicioByTax(taxRateToService.contains(4.00) ? true : false, taxRateToTraslado.containsKey(4.00) ? taxRateToTraslado.get(4.00) : new List<ONE_Expediente_Line_Item__c>(), 4, orden.ONE_Importe_Base_4__c, orden.ONE_Importe_Impuesto_4__c, orden.ONE_Importe_Neto_4__c));
            }            
        } else {
            if (orden.ONE_Importe_Neto_3__c != null && orden.ONE_Importe_Neto_3__c > 0) {
                servicios.addAll(buildServicioByTax(taxRateToService.contains(3.00) ? true : false, taxRateToTraslado.containsKey(3.00) ? taxRateToTraslado.get(3.00) : new List<ONE_Expediente_Line_Item__c>(), 3, orden.ONE_Importe_Base_3__c, orden.ONE_Importe_Impuesto_3__c, orden.ONE_Importe_Neto_3__c));
            }
        }
        if ((orden.ONE_Importe_Neto_0__c != null && orden.ONE_Importe_Neto_0__c > 0) || (orden.ONE_Importe_Neto_Suplido__c != null && orden.ONE_Importe_Neto_Suplido__c > 0)) {
            servicios.addAll(buildServicioByTax(taxRateToService.contains(0.00) ? true : false, taxRateToTraslado.containsKey(0.00) ? taxRateToTraslado.get(0.00) : new List<ONE_Expediente_Line_Item__c>(), 0, orden.ONE_Importe_Neto_0__c != null && orden.ONE_Importe_Neto_0__c > 0 ? orden.ONE_Importe_Neto_0__c : orden.ONE_Importe_Neto_Suplido__c, 0, orden.ONE_Importe_Neto_0__c != null && orden.ONE_Importe_Neto_0__c > 0 ? orden.ONE_Importe_Neto_0__c : orden.ONE_Importe_Neto_Suplido__c));
        }
        return servicios;
    }

    public static List<Servicios> buildServicioByTax(Boolean hasServicios, List<ONE_Expediente_Line_Item__c> traslados, Decimal taxRate, Decimal baseTotal, Decimal impuestoTotal, Decimal importeTotal) {
        Decimal baseTotalTraslado = 0;
        Decimal impuestoTotalTraslado = 0;
        Decimal importeTotalTraslado = 0;
        List<Servicios> serviciosResult = new List<Servicios>();
        if (!traslados.isEmpty()) {
            for (ONE_Expediente_Line_Item__c traslado : traslados) {
                baseTotalTraslado += traslado.ONE_Importe_Base__c;
                impuestoTotalTraslado += traslado.ONE_Importe_Impuesto__c;
                importeTotalTraslado += traslado.ONE_Importe_Neto__c;
            }
            Servicios servicio = new Servicios();
            servicio.TipoIVA = taxRate == 0 ? '0' : (taxRate == 3 || taxRate == 4 || taxRate == 10) ? '1' : '2';
            servicio.PorcentajeImpuesto = taxRate;
            servicio.BaseImponible = taxRate == 0 ? importeTotalTraslado : baseTotalTraslado;
            servicio.ImporteImpuesto = impuestoTotalTraslado;
            servicio.ImporteTotal = importeTotalTraslado;
            servicio.ServicioID = '003';
            serviciosResult.add(servicio);
        }
        if(hasServicios) {
            Servicios servicio = new Servicios();
            servicio.TipoIVA = taxRate == 0 ? '0' : (taxRate == 3 || taxRate == 4 || taxRate == 10) ? '1' : '2';
            servicio.PorcentajeImpuesto = taxRate;
            servicio.BaseImponible = taxRate == 0 ? importeTotal - importeTotalTraslado : baseTotal - baseTotalTraslado;
            servicio.ImporteImpuesto = impuestoTotal - impuestoTotalTraslado;
            servicio.ImporteTotal = importeTotal - importeTotalTraslado;
            servicio.ServicioID = '001';
            serviciosResult.add(servicio);
        }
        return serviciosResult;
    }

    public static Map<Id, FlowOutputs> sendOrders(List<Id> ordenDeVentaIds) {
        Map<Id, FlowOutputs> resultados = new Map<Id, FlowOutputs>();

        for (Id ordenId : ordenDeVentaIds) {
            try {
                FlowInputs input = new FlowInputs();
                input.ordenDeVentaId = ordenId;
                input.batchProcess = true;

                List<FlowOutputs> result = invokeIntegration(new List<FlowInputs>{ input });

                resultados.put(ordenId, result[0]);
            } catch (Exception e) {
                FlowOutputs errorOutput = new FlowOutputs();
                errorOutput.success = false;
                errorOutput.returnValue = 'Error procesando orden ' + ordenId + ': ' + e.getMessage();
                resultados.put(ordenId, errorOutput);
            }
        }

        return resultados;
    }

    public class BudgetRequest {
        public String NumeroSiniestro;
        public String NumeroFactura;
        public String FechaFactura;
        public Decimal BaseImponible;
        public String TipoImpuesto;
        public Decimal ImporteImpuesto;
        public Decimal ImporteExentoIVA;
        public Decimal ImporteTotal;
        public String IdHacienda;
        public List<Servicios> Servicios;
        public List<Documentos> Documentos;
    }

    public class Servicios {
        public String ServicioID;
        public String TipoIVA;
        public Decimal PorcentajeImpuesto;
        public Decimal BaseImponible;
        public Decimal ImporteImpuesto;
        public Decimal ImporteTotal;
    }

    public class Documentos {
        public String TipoDocumento;
        public String Nombre;
        public String Documento;
        public String Formato;
        public String Observaciones;
    }

    public class FlowInputs {
        @InvocableVariable
        public String ordenDeVentaId;

        public Boolean batchProcess;
    }
    
    public class FlowOutputs {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String returnValue;

        @InvocableVariable
        public Boolean customError;

        @InvocableVariable
        public Integer errorCode;
    }
}
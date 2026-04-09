/**
* File Name: ONE_LineasPlanificacionExportAction.cls
* Description: 	Service class to handle Lineas de Planificación exportation to SharePoint
* Date: 06/02/2026
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Test: ONE_LineasPlanificacionExportActionTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		06/02/2026		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
public with sharing class ONE_LineasPlanificacionExportAction {

    @InvocableMethod(label='Exportar Lineas de Planificación a SharePoint') 
    public static List<FlowOutputs> exportarLineasPlanificacion(List<FlowInputs> flowInputs) {

        FlowOutputs output = new FlowOutputs();
        output.success = true;

        // Validar que se han pasado los IDs de las Lineas de Planificación
        if (flowInputs == null || flowInputs.isEmpty() || 
            flowInputs[0] == null || 
            flowInputs[0].lineas == null || 
            flowInputs[0].lineas.isEmpty()) {

            output.success = false;
            return new List<FlowOutputs>{ output };
        }

        FlowInputs input = flowInputs[0];
        List<ONE_LineaPlanificacion__c> lineas = input.lineas;

        // Extraer Ids desde las líneas recibidas del Flow
        Set<Id> lpIds = new Set<Id>();
        for (ONE_LineaPlanificacion__c linea : lineas) {
            if (linea != null && linea.Id != null) {
                lpIds.add(linea.Id);
            }
        }

        if (lpIds.isEmpty()) {
            output.success = false;
            return new List<FlowOutputs>{ output };
        }

        // Filtrar solo servicio defuncion
        List<ONE_LineaPlanificacion__c> lineasServicioDefuncion = [
            SELECT Id, ONE_Zona_Operativa_Centro__c
            FROM ONE_LineaPlanificacion__c
            WHERE Id IN :lpIds
            AND ONE_Servicio__r.RecordType.DeveloperName = 'ONE_Servicio_Defuncion'
        ];

        // Agrupar lineas por zona
        Map<String, List<Id>> lineasPlanificacionPorZona = new Map<String, List<Id>>();
        for (ONE_LineaPlanificacion__c linea : lineasServicioDefuncion) {
            String zonaName = linea.ONE_Zona_Operativa_Centro__c;

            if (String.isBlank(zonaName)) {
                continue;
            }

            if (!lineasPlanificacionPorZona.containsKey(zonaName)) {
                lineasPlanificacionPorZona.put(zonaName, new List<Id>());
            }
            lineasPlanificacionPorZona.get(zonaName).add(linea.Id);
        }

        if (lineasPlanificacionPorZona.isEmpty()) {
            output.success = true;
            return new List<FlowOutputs>{ output };
        }

        // Exportar por zona: 
        Boolean anyFailed = false;
        for (String zonaName : lineasPlanificacionPorZona.keySet()) {
            List<Id> ids = lineasPlanificacionPorZona.get(zonaName);
            try {
                Boolean ok = ONE_SharePointFileService.exportarLineasPlanificacion(zonaName, ids);
                if (!ok) anyFailed = true;
            } catch (Exception e) {
                anyFailed = true;
                System.debug(LoggingLevel.ERROR, 'Export failed for zona=' + zonaName + ' error=' + e.getMessage());
            }
        }

        output.success = !anyFailed;
        return new List<FlowOutputs>{ output };
    }
    
    public class FlowInputs {
        @InvocableVariable
        public List<ONE_LineaPlanificacion__c> lineas;
    }

    public class FlowOutputs {
        @InvocableVariable(label='Success')
        public Boolean success;
    }
}
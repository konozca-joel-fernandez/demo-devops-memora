/**
* File Name: ONE_LineasPlanificacionCsvBuilder.cls
* Description: 	Csv builder class for Lineas de Planificación
* Date: 12/02/2026
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Test: ONE_LineasPlanificacionCsvBuilderTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		12/02/2026		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
public with sharing class ONE_LineasPlanificacionCsvBuilder {

    public static Blob build(List<String> headers, List<ONE_LineaPlanificacion__c> lps) {

        String csv = buildHeader(headers);

        if (lps != null && !lps.isEmpty()) {
            for (ONE_LineaPlanificacion__c lp : lps) { 
                for (String h : headers) {
                    csv += getFieldValue(lp, h) + ',';
                }
                csv = csv.substring(0, csv.length() - 1) + '\n';
            }
        }

        return Blob.valueOf(csv);
    }

    //Header Line
    private static String buildHeader(List<String> headers) { 
        String headerLine = ''; 
        for (String h : headers) { 
            headerLine += h + ','; 
        } 
        return headerLine.substring(0, headerLine.length() - 1) + '\n'; 
    }

    // Get field value as string and escape for CSV (supports relationship paths)
    private static String getFieldValue(ONE_LineaPlanificacion__c lp, String fieldPath) {

        if (lp == null || String.isBlank(fieldPath)) return '';

        Object rawValue;

        //Separamos por '.' para soportar campos de relación
        if (fieldPath.contains('.')) {

            List<String> parts = fieldPath.split('\\.');
            SObject current = lp;

            // Recorremos relaciones intermedias
            for (Integer i = 0; i < parts.size() - 1; i++) {
                if (current == null) break;
                current = current.getSObject(parts[i]);
            }

            // Último campo
            rawValue = (current == null) ? null : current.get(parts[parts.size() - 1]);

        } else {
            rawValue = lp.get(fieldPath);
        }

        if (rawValue == null) return '';

        String value = String.valueOf(rawValue);

        // Escape CSV
        Boolean mustWrap = value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r');
        value = value.replace('"', '""');

        return mustWrap ? '"' + value + '"' : value;
    }
}
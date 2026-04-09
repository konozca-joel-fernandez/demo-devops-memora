/**
* File Name: ONE_MonitorDocumentosHelper
* Description: 	Auxiliar class and functions for ONE_MonitorDocumentosController
* Date: 11/11/2024
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: 
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		11/11/2024		Marc Cervilla  		Class creation
* ===================================================================================================================
*/


public with sharing class ONE_MonitorDocumentosHelper {

    public class LineasWrapper {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public String soqlQuery {get;set;}
        public List<SObject> lineas {get;set;}
        //public List<SObject> allLineas {get;set;}
    }

    // Map used in getSortField()
    private static final Map<String, String> SORT_FIELD_MAP = new Map<String, String>{
        // Expediente
        'Name' => 'Name',
        'servicioURL'=> 'Name',
        'ONE_Difunto__c' => 'ONE_Difunto__c',
        'ONE_Fecha_De_Defuncion__c' => 'ONE_Fecha_De_Defuncion__c',
        'ONE_Estado__c' => 'ONE_Estado__c',


        // Tarea
        'tareaURL' => 'Name',
        'ONE_Expediente__c' => 'ONE_Expediente__c'
    };

    // Map used to get Fecha API Name field
    private static final Map<String, String> FECHAS_MAP = new Map<String, String>{
        'Defunción' => 'ONE_Fecha_De_Defuncion__c',
        'Velación' => 'ONE_Inicio_Velacion__c',
        'Ceremonia' => 'ONE_Inicio_Ceremonia__c',
        'Destino final' => 'ONE_Hora_Destino_Final__c',
        'Traslado' => 'ONE_Fecha_Salida_Traslado__c',
        'Depósito' => 'ONE_Inicio_Deposito__c'
        
    };

    public static LineasWrapper createWrapper(List<SObject> lineasPag, Integer pageSize, Integer pageNumber, String soql, Integer totalRecords, Integer recordEnd, Integer offset) {
        LineasWrapper wrapper = new LineasWrapper();
        wrapper.pageSize = pageSize;
        wrapper.pageNumber = pageNumber;
        if (totalRecords > 0) {
            wrapper.recordStart = offset+1;
        }
        else {
            wrapper.recordStart = offset;
        }
        wrapper.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapper.totalRecords = totalRecords;
        wrapper.soqlQuery = soql;

        wrapper.lineas = lineasPag;
        //wrapper.allLineas = lineas;

        return wrapper;
    }

    // Get Field Names for dataTable
    public static List<String> getTableFields(String tipoDatos) {

        switch on tipoDatos {
            when 'ONE_Expediente__c' {

                return new List<String> {
                    'Id',
                    'Name',
                    'ONE_Difunto__c',
                    'ONE_Difunto__r.Name',
                    'ONE_Documentos_en_el_Servicio__c',
                    'ONE_Estado__c',
                    'ONE_Centro_Del_Expediente__r.Name',
                    'ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Name',
                    'ONE_Fecha_De_Defuncion__c',
                    'ONE_Inicio_Velacion__c',
                    'ONE_Inicio_Ceremonia__c',
                    'ONE_Hora_Destino_Final__c',
                    'ONE_Fecha_Salida_Traslado__c',
                    'ONE_Inicio_Deposito__c'
                };

            }
            when else {
                throw new CalloutException('Ha ocurrido un error con el tipo de datos en la obtención de campos.');
            }
        }

    }

    // Get Filters for Expediente dataTable
    public static List<String> getTableFiltersExp(Map<String, Object> input) {
        
        // Get input filters
        List<String> servicioIdList = castToStringList(input.get('servicioIdList'));
        String lugarId = (String) input.get('lugarId');
        List<String> centroIdList = castToStringList(input.get('centroIdList'));
        List<String> estadosServicio = castToStringList(input.get('estadosServicio'));
        String campoFecha = (String) input.get('campoFecha');
        String periodoFecha = (String) input.get('periodoFecha');
        String fechaIni = '';
        String fechaFin = '';
        String contieneTarea = (String) input.get('contieneTarea');

        List<String> filters = new List<String>();

        // ** Default filter - SOLO APARECERAN SERVICIOS DEFUNCION **
        String servicioRT = 'ONE_Servicio_Defuncion';
        filters.add('RecordType.DeveloperName = \'ONE_Servicio_Defuncion\'');

        // Servicios
        if (!servicioIdList.isEmpty()) {
            filters.add('Id IN :servicioIdList');
        }

        // Lugar
        if (String.isNotBlank(lugarId)) {
            filters.add('(ONE_Centro_Del_Expediente__r.ONE_Lugar__c = :lugarId  OR ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_superior__c = :lugarId  OR ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_superior__r.ONE_Lugar_superior__c = :lugarId OR ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_superior__r.ONE_Lugar_superior__r.ONE_Lugar_superior__c = :lugarId )');
        }

        // Centros
        if (!centroIdList.isEmpty()) {
            filters.add('ONE_Centro_Del_Expediente__c IN :centroIdList');
        }

        // Estados servicio

        if (!estadosServicio.isEmpty()) {
            filters.add('ONE_Estado__c IN :estadosServicio');
        }

        // Check if Servicio contains Tarea of type 'contieneTarea'
        if (String.isNotBlank(contieneTarea)) {
            filters.add('Id IN (SELECT ONE_Expediente__c FROM ONE_Tarea__c WHERE RecordType.DeveloperName = :contieneTarea AND ONE_Estado__c != \'Cancelado\')');
        }

        //** FILTROS FECHA **

        if (String.isNotBlank(campoFecha) && campoFecha != 'Cualquiera') {
            String campoFechaAPI = FECHAS_MAP.containsKey(campoFecha) ? FECHAS_MAP.get(campoFecha) : 'ONE_Fecha_De_Defuncion__c';
            
            System.debug('FILTRO FECHA CAMPO: ' + campoFechaAPI + ' PERIODO ' + periodoFecha);

            switch on periodoFecha {
                when 'Todos' {
                    //nothing
                }
                when 'Hoy' {
                    filters.add(campoFechaAPI + ' = TODAY ');
                }
                when 'Semana actual' {
                    filters.add(campoFechaAPI + ' = THIS_WEEK ');
                }
                when 'Semana anterior' {
                    filters.add(campoFechaAPI + ' = LAST_WEEK ');
                }
                when 'Mes actual' {
                    filters.add(campoFechaAPI + ' = THIS_MONTH ');
                }
                when 'Mes anterior' {
                    filters.add(campoFechaAPI + ' = LAST_MONTH ');
                }
                when 'Intérvalo de fechas' {

                    fechaIni = (String) input.get('fechaIni');
                    fechaFin = (String) input.get('fechaFin');
                    if (String.isNotBlank(fechaIni) && String.isNotBlank(fechaFin)) {
                        fechaIni = fechaIni + 'T00:00:00+01:00';
                        fechaFin = fechaFin + 'T00:00:00+01:00';
        
                        System.debug('fechas inputs: ' + periodoFecha + ' ' + fechaIni + ' ' + fechaFin);
        
                        filters.add(campoFechaAPI + ' >= '+ fechaIni + ' AND ' + campoFechaAPI + ' <= '+ fechaFin);
                    }
                }
                when else {
                    throw new CalloutException('Ha ocurrido un error con el periodo de fecha seleccionado');
                }
            }
        }

        //** FECHA CUALQUIERA **

        if (String.isNotBlank(campoFecha) && campoFecha == 'Cualquiera') {
            
            //Get API name fields
            List<String> camposFechaAPI = FECHAS_MAP.values();
            
            List<String> subFilters = new List<String>();
            
            System.debug('FILTRO FECHA CAMPOS: ' + camposFechaAPI + ' PERIODO ' + periodoFecha);

            switch on periodoFecha {
                when 'Todos' {
                    //nothing
                }
                when 'Hoy' {
                    for (String campo : camposFechaAPI) {
                        subFilters.add(campo + ' = TODAY');
                    }
                }
                when 'Semana actual' {
                    for (String campo : camposFechaAPI) {
                        subFilters.add(campo + ' = THIS_WEEK');
                    }
                }
                when 'Semana anterior' {
                    for (String campo : camposFechaAPI) {
                        subFilters.add(campo + ' = LAST_WEEK');
                    }
                }
                when 'Mes actual' {
                    for (String campo : camposFechaAPI) {
                        subFilters.add(campo + ' = THIS_MONTH');
                    }
                }
                when 'Mes anterior' {
                    for (String campo : camposFechaAPI) {
                        subFilters.add(campo + ' = LAST_MONTH');
                    }
                }
                when 'Intérvalo de fechas' {

                    fechaIni = (String) input.get('fechaIni');
                    fechaFin = (String) input.get('fechaFin');
                    if (String.isNotBlank(fechaIni) && String.isNotBlank(fechaFin)) {
                        fechaIni = fechaIni + 'T00:00:00+01:00';
                        fechaFin = fechaFin + 'T00:00:00+01:00';
        
                        System.debug('fechas inputs: ' + periodoFecha + ' ' + fechaIni + ' ' + fechaFin);
        
                        for (String campo : camposFechaAPI) {
                            subFilters.add('(' + campo + ' >= '+ fechaIni + ' AND ' + campo + ' <= '+ fechaFin + ')');
                        }

                    }
                }
                when else {
                    throw new CalloutException('Ha ocurrido un error con el periodo de fecha seleccionado');
                }
            }

            // Combine subFilters with OR logic
            if (!subFilters.isEmpty()) {
                filters.add('(' + String.join(subFilters, ' OR ') + ')');
            }
        }

        return filters;
    }

    // NOT USED
    /*
    public static List<String> getTableFiltersTarea(Map<String, Object> input) {

        List<String> filters = new List<String>();
        // Default filter
        filters.add('Name <> null');

        return filters;
    }*/


    // Get SortField
    public static String getSortField(String sortBy) {
    
        String sortField = SORT_FIELD_MAP.containsKey(sortBy) ? SORT_FIELD_MAP.get(sortBy) : 'Name';

        return sortField;
    }

    //QUERY BUILDERS

    public static String buildSOQLCount(String tipoDatos, List<String> filters) {
        return String.format('SELECT COUNT(Id) ct FROM {0} WHERE ({1})', 
            new List<String> { tipoDatos, String.join(filters, ' AND ') });
    }

    public static String buildSOQL(String tipoDatos, List<String> fields, List<String> filters, String sortField, String sortDirection) {
        return String.format('SELECT {0} FROM {1} WHERE ({2}) ORDER BY {3} {4} NULLS LAST', 
            new List<String> { String.join(fields, ', '), tipoDatos, String.join(filters, ' AND '), sortField, sortDirection });
    }

    public static String buildSOQLPagination(String tipoDatos, List<String> fields, List<String> filters, String sortField, String sortDirection, Integer pageSize, Integer offset) {
        return String.format('SELECT {0} FROM {1} WHERE ({2}) ORDER BY {3} {4} NULLS LAST LIMIT {5} OFFSET {6}', 
            new List<String> { String.join(fields, ', '), tipoDatos, String.join(filters, ' AND '), sortField, sortDirection, String.valueOf(pageSize), String.valueOf(offset) });
    }
    
    // List of Objects to List of Strings
    public static List<String> castToStringList(Object inputList) {
        List<String> result = new List<String>();
        if (inputList instanceof List<Object>) {
            for (Object item : (List<Object>) inputList) {
                result.add((String) item);
            }
        }
        return result;
    }

}
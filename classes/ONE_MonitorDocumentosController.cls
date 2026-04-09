/**
* File Name: ONE_MonitorDocumentosController
* Description: 	Controller for LWC oneMonitorDocumentos
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

public with sharing class ONE_MonitorDocumentosController {


    @AuraEnabled(cacheable=true)
    public static String getLineas(Map<String, Object> input) {
        
        System.debug('GET LINEAS INPUTS: ' + input);


        // Get inputs
        String tipoDatos = (String) input.get('tipoDatos'); // 'ONE_Expediente__c', 'ONE_Tarea__c'
        String sortBy = (String) input.get('sortBy');
        String sortDirection = (String) input.get('sortDirection');
        Integer pageSize = Integer.valueOf( input.get('pageSize') );
        Integer pageNumber = Integer.valueOf( input.get('pageNumber') );

        // Binding Variable for query
        List<String> servicioIdList = ONE_MonitorDocumentosHelper.castToStringList(input.get('servicioIdList'));
        String lugarId = (String) input.get('lugarId');
        List<String> centroIdList = ONE_MonitorDocumentosHelper.castToStringList(input.get('centroIdList'));
        List<String> estadosServicio = ONE_MonitorDocumentosHelper.castToStringList(input.get('estadosServicio'));
        String contieneTarea = (String) input.get('contieneTarea');


        String jsonDT = '';
        List<SObject> lineas = new List<SObject>();
        List<SObject> lineasPag = new List<SObject>();
        List<AggregateResult> counter = new List<AggregateResult>();
        

        // Get datatable fields
        List<String> fields = ONE_MonitorDocumentosHelper.getTableFields(tipoDatos);

        // Get datatable filters
        List<String> filters = new List<String>();
        if (tipoDatos == 'ONE_Expediente__c') {
            filters = ONE_MonitorDocumentosHelper.getTableFiltersExp(input);
        }
        /*
        else {
            //NOT USED
            filters = ONE_MonitorDocumentosHelper.getTableFiltersTarea(input);
        }
        */

        Integer offset = (pageNumber - 1) * pageSize;
        if (pageNumber == 0) {
            offset = 0;
            pageNumber = 1;
        }

        // Get sortField
        String sortField = ONE_MonitorDocumentosHelper.getSortField(sortBy);


        // BUILD SOQLS
        
        String soqlCounter = ONE_MonitorDocumentosHelper.buildSOQLCount(tipoDatos, filters);
        String soql = ONE_MonitorDocumentosHelper.buildSOQL(tipoDatos, fields, filters, sortField, sortDirection);
        String soqlPagination = ONE_MonitorDocumentosHelper.buildSOQLPagination(tipoDatos, fields, filters, sortField, sortDirection, pageSize, offset);

        System.debug('SOQL Inputs:');
        System.debug('-tipoDatos: '+tipoDatos);
        System.debug('-fields: '+fields);
        System.debug('-filters: '+filters);
        System.debug('-sortField: '+sortField);
        System.debug('-sortDirection: '+sortDirection);
        System.debug('-pageSize: '+pageSize);
        System.debug('-offset: '+offset);  

        System.debug('soqlCounter :: '+soqlCounter);
        System.debug('soql :: '+soql);
        System.debug('soqlPagination :: '+soqlPagination);

        counter = Database.query(soqlCounter);
        System.debug(counter);
        if ((decimal)counter[0].get('ct') > 30000) {
            CalloutException e = new CalloutException();
            e.setMessage('Este filtro tiene demasiados registros como resultado. Por favor, añade más filtros para realizar una búsqueda más óptima');
            System.debug(e);
            throw e;
        } 

        lineas = Database.query(soql);
        lineasPag = Database.query(soqlPagination);

        System.debug ('SOQL: ' + soql);
        System.debug ('SOQL PAG: '+ soqlPagination);
        //System.debug ('centroIdList: '+ centroIdList);

        Integer totalRecords = lineas.size();
        Integer recordEnd = pageSize * pageNumber;

        ONE_MonitorDocumentosHelper.LineasWrapper paginationLineas = ONE_MonitorDocumentosHelper.createWrapper(lineasPag, pageSize, pageNumber, soql, totalRecords, recordEnd, offset);

        jsonDT = JSON.serialize(paginationLineas);
        System.debug('JSON is:' + jsonDT);
        return jsonDT;
    }

    //Filter by Servicio
    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> servicioSearch(String searchTerm) {
        
        System.debug('SEARCHTERM: ' + searchTerm);

        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                ONE_Expediente__c(
                    Id, Name, ONE_Centro_Del_Expediente__r.Name, ONE_Difunto__r.Name
                    WHERE RecordType.DeveloperName = 'ONE_Servicio_Defuncion'
                )
        ];


        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Servicios & convert them into LookupSearchResult
        String servicioIcon = 'custom:custom15';
        ONE_Expediente__c[] servicios = (List<ONE_Expediente__c>) searchResults[0];
        for (ONE_Expediente__c servicio : servicios) {
            String subtitle = servicio.ONE_Difunto__r.Name + ' • ' + servicio.ONE_Centro_Del_Expediente__r.Name;
            results.add(new LookupSearchResult(servicio.Id, 'ONE_Expediente__c', servicioIcon, servicio.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    // Filter by Lugar
    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> lugarSearch(String searchTerm) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
            ONE_Lugar__c(
                    Id, Name
                )
        ];

        System.debug('SEARCH RESULTS: '+ searchResults);

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Servicios & convert them into LookupSearchResult
        String lugarIcon = 'custom:custom24';   
        ONE_Lugar__c[] lugares = (List<ONE_Lugar__c>) searchResults[0];
        for (ONE_Lugar__c lugar : lugares) {
            String subtitle = lugar.Id + ' • '; //+ lugar.Account_r.Name;
            results.add(new LookupSearchResult(lugar.Id, 'ONE_Lugar__c', lugarIcon, lugar.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();
        System.debug('results: '+ results);
        return results;
    }


    // Filter by Centro
    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> centroSearch(String searchTerm) {
        
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                Account(
                    Id, Name, ONE_Centro_Memora_Codigo_SAP__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name
                    WHERE RecordType.DeveloperName = 'ONE_Centro_Memora'
                )
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitle = account.ONE_Centro_Memora_Codigo_SAP__c + ' • ' + account.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<Map<String, String>> getTareaTypes() {

        List<String> tareaTypes = new List<String>();

        List<RecordType> recordTypes = [
            SELECT DeveloperName, Name
            FROM RecordType
            WHERE SObjectType = 'ONE_Tarea__c'
        ];

        // Transform record types into a list of maps for the LWC
        List<Map<String, String>> recordTypeOptions = new List<Map<String, String>>();
        for (RecordType rt : recordTypes) {
            recordTypeOptions.add(new Map<String, String>{
                'label' => rt.Name,
                'value' => rt.DeveloperName
            });
        }

        System.debug ('recordTypeOptions: ' + recordTypeOptions);

        return recordTypeOptions;
    }

}
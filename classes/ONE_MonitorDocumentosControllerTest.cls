/**
* File Name: ONE_MonitorDocumentosControllerTest
* Description: 	Test class for ONE_MonitorDocumentosController
* Date: 27/11/2024
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: 
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		27/11/2024		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

@isTest
public class ONE_MonitorDocumentosControllerTest {

    @testSetup
    static void dataSetup() {

        // Lugares
        ONE_Lugar__c deleg = new ONE_Lugar__c(
            Name = 'Lugar Delegacion'
        );
        insert deleg;
        
        ONE_Lugar__c zonaOp = new ONE_Lugar__c(
            Name = 'Lugar Zona Operativa',
            ONE_Lugar_Superior__c = deleg.Id
        );
        insert zonaOp;

        ONE_Lugar__c areaOp = new ONE_Lugar__c(
            Name = 'Lugar Area Operativa',
            ONE_Lugar_Superior__c = zonaOp.Id
        );
        insert areaOp;

        // Centro
        Account centro = new Account(
            Name = 'Centro Test',
            ONE_Lugar__c = areaOp.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_CENTRO_MEMORA)
        );
        insert centro;

        // Difuntos
        Account difunto1 = ONE_TestDataFactory.createPersonAccount(null, true);
        Account difunto2 = ONE_TestDataFactory.createPersonAccount(null, true);

        // Servicios
        ONE_Expediente__c servicio1 = new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = centro.Id,
            ONE_Estado__c = 'Nuevo',
            ONE_Difunto__c = difunto1.Id,
            ONE_Fecha_De_Defuncion__c = Date.today(),
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.EXPEDIENTE, ONE_CommonConstants.EXP_RT_SERVICIO_DEFUNC)
        );

        ONE_Expediente__c servicio2 = new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = centro.Id,
            ONE_Estado__c = 'Nuevo',
            ONE_Difunto__c = difunto2.Id,
            ONE_Fecha_De_Defuncion__c = Date.today(),
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.EXPEDIENTE, ONE_CommonConstants.EXP_RT_SERVICIO_DEFUNC)
        );

        List<ONE_Expediente__c> servicios = new List<ONE_Expediente__c>{ servicio1, servicio2 };
        insert servicios;


    }

    @isTest
    static void testGetLineas1() {
        Map<String, Object> input = new Map<String, Object>{
            'tipoDatos' => 'ONE_Expediente__c',
            'sortBy' => 'Name',
            'sortDirection' => 'DESC',
            'pageSize' => 10,
            'pageNumber' => 1,
            'servicioId' => null,
            'lugarId' => null,
            'centroIdList' => null,
            'estadosServicio' => null,
            'contieneTarea' => null
        };

        Test.startTest();
        String result = ONE_MonitorDocumentosController.getLineas(input);
        System.assertNotEquals(null, result, 'Expected result to not be null.');
        Test.stopTest();
    }

    @isTest
    static void testGetLineas2() {
        Map<String, Object> input = new Map<String, Object>{
            'tipoDatos' => 'ONE_Expediente__c',
            'sortBy' => 'Name',
            'sortDirection' => 'DESC',
            'pageSize' => 10,
            'pageNumber' => 1,
            'servicioId' => null,
            'lugarId' => null,
            'centroIdList' => null,
            'estadosServicio' => null,
            'contieneTarea' => null
        };

        Integer totalServicios = [SELECT COUNT() FROM ONE_Expediente__c];

        Test.startTest();
        String result = ONE_MonitorDocumentosController.getLineas(input);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Integer totalRecords = (Integer) resultMap.get('totalRecords');
        System.assertEquals(totalServicios, totalRecords, 'Expected to get all Servicios count');
        Test.stopTest();
    }

    @isTest
    static void testGetLineasFiltros() {

        ONE_Expediente__c servicio = [SELECT Id, ONE_Centro_Del_Expediente__r.Id, ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Id, 
                                            ONE_Estado__c, ONE_Difunto__c, ONE_Fecha_De_Defuncion__c FROM ONE_Expediente__c LIMIT 1];

    
        Map<String, Object> input = new Map<String, Object>{
            'tipoDatos' => 'ONE_Expediente__c',
            'sortBy' => 'Name',
            'sortDirection' => 'DESC',
            'pageSize' => 10,
            'pageNumber' => 1,
            'servicioId' => servicio.Id,
            'lugarId' => servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Id,
            'centroIdList' => new List<Object>{servicio.ONE_Centro_Del_Expediente__r.Id},
            'estadosServicio' => new List<Object>{servicio.ONE_Estado__c},
            'contieneTarea' => null
        };


        Test.startTest();
        String result = ONE_MonitorDocumentosController.getLineas(input);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Integer totalRecords = (Integer) resultMap.get('totalRecords');
        System.assert(totalRecords >= 1, 'Expected totalRecords to be at least 1.');
        Test.stopTest();
    }

    //*** FECHA FILTERS TESTS ***

    // Private class to execute Tests with fecha filters
    private static void testGetLineasFiltrosFecha(String campoFecha, String periodoFecha, String fechaIni, String fechaFin) {
        
        Map<String, Object> input = new Map<String, Object>{
            'tipoDatos' => 'ONE_Expediente__c',
            'sortBy' => 'Name',
            'sortDirection' => 'DESC',
            'pageSize' => 10,
            'pageNumber' => 1,
            'campoFecha' => campoFecha,
            'periodoFecha' => periodoFecha,
            'fechaIni' => fechaIni,
            'fechaFin' => fechaFin
        };

        Test.startTest();
        String result = ONE_MonitorDocumentosController.getLineas(input);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Integer totalRecords = (Integer) resultMap.get('totalRecords');
        System.assert(totalRecords >= 0, 'Expected totalRecords to be at least 0.');
        Test.stopTest();
    }


    @isTest
    static void testGetLineasFiltrosFecha1() {
        testGetLineasFiltrosFecha('ONE_Fecha_De_Defuncion__c', 'Hoy', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha2() {
        testGetLineasFiltrosFecha('ONE_Fecha_De_Defuncion__c', 'Semana actual', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha3() {
        testGetLineasFiltrosFecha('ONE_Fecha_De_Defuncion__c', 'Semana anterior', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha4() {
        testGetLineasFiltrosFecha('ONE_Fecha_De_Defuncion__c', 'Mes actual', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha5() {
        testGetLineasFiltrosFecha('ONE_Fecha_De_Defuncion__c', 'Mes anterior', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha6() {
        testGetLineasFiltrosFecha('ONE_Fecha_De_Defuncion__c', 'Intérvalo de fechas', '2024-01-01', '2024-01-31');
    }
    
    @isTest
    static void testGetLineasFiltrosFecha7() {
        testGetLineasFiltrosFecha('Cualquiera', 'Hoy', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha8() {
        testGetLineasFiltrosFecha('Cualquiera', 'Semana actual', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha9() {
        testGetLineasFiltrosFecha('Cualquiera', 'Semana anterior', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha10() {
        testGetLineasFiltrosFecha('Cualquiera', 'Mes actual', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha11() {
        testGetLineasFiltrosFecha('Cualquiera', 'Mes anterior', null, null);
    }
    
    @isTest
    static void testGetLineasFiltrosFecha12() {
        testGetLineasFiltrosFecha('Cualquiera', 'Intérvalo de fechas', '2024-01-01', '2050-01-01');
    }


    @isTest
    static void testServicioSearch() {

        ONE_Expediente__c servicio = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.EXPEDIENTE, ONE_CommonConstants.EXP_RT_SERVICIO_DEFUNC)
        );
        insert servicio;

        // To test SOSL
        Test.setFixedSearchResults(new List<Id>{servicio.Id});

        Test.startTest();
        List<LookupSearchResult> results = ONE_MonitorDocumentosController.servicioSearch('S-');
        System.assertNotEquals(0, results.size(), 'Expected to find at least one servicio.');
        Test.stopTest();
    }

    @isTest
    static void testLugarSearch() {

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar Test'
        );
        insert lugar;

        // To test SOSL
        Test.setFixedSearchResults(new List<Id>{lugar.Id});

        Test.startTest();
        List<LookupSearchResult> results = ONE_MonitorDocumentosController.lugarSearch('Lugar');
        System.assertNotEquals(0, results.size(), 'Expected to find at least one lugar.');
        Test.stopTest();
    }

    @isTest
    static void testCentroSearch() {

        // Centro
        Account centro = new Account(
            Name = 'Centro Test',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_CENTRO_MEMORA)
        );
        insert centro;

        // To test SOSL
        Test.setFixedSearchResults(new List<Id>{centro.Id});

        Test.startTest();
        List<LookupSearchResult> results = ONE_MonitorDocumentosController.centroSearch('Centro');
        System.assertNotEquals(0, results.size(), 'Expected to find at least one centro.');
        Test.stopTest();
    }

    @isTest
    static void testGetTareaTypes() {
        Test.startTest();
        List<Map<String, String>> results = ONE_MonitorDocumentosController.getTareaTypes();
        System.assertNotEquals(0, results.size(), 'Expected to retrieve at least one tarea type.');
        Test.stopTest();
    }
}
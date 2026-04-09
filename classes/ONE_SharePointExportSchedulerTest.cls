/**
* File Name: ONE_SharePointExportSchedulerTest.cls
* Description: 	Test class for ONE_SharePointExportScheduler, which handles the scheduled exportation of Lineas de Planificación to SharePoint
* Date: 26/02/2026
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		26/02/2026		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
@IsTest
public with sharing class ONE_SharePointExportSchedulerTest {

    @IsTest
    static void testSchedulerExecution() {
        Test.startTest();
        String cronExp = '0 0 12 1 1 ? 2027'; 
        System.schedule('Test SharePoint Export Scheduler', cronExp, new ONE_SharePointExportScheduler());
        Test.stopTest();
    }
}
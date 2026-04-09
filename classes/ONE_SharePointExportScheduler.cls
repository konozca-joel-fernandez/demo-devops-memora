/**
* File Name: ONE_SharePointExportScheduler.cls
* Description: 	Scheduler class to execute the exportation of Lineas de Planificación to SharePoint on a scheduled basis
* Date: 11/02/2026
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Test: ONE_SharePointExportSchedulerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		11/02/2026		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
global without sharing class ONE_SharePointExportScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        System.enqueueJob(new ONE_SharePointExportQueueable());
    }
}
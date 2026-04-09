/**
* File Name: ONE_AltaSiniestroKBSScheduler
* Description: 	Scheduler for batch class ONE_AltaSiniestroKBSBatch
* Date: 10/10/2025
*
* Copyright: Konozca Consulting
* @author: Marc Pàmies
* Test: ONE_AltaSiniestroKBSTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		10/10/2025		Marc Pàmies  		Class creation
* ===================================================================================================================
*/

global class ONE_AltaSiniestroKBSScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        ONE_AltaSiniestroKBSBatch batch = new ONE_AltaSiniestroKBSBatch();
        Database.executeBatch(batch, 10);
    }
}
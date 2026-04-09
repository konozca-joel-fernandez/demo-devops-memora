/**
* File Name: ONE_DeleteOldFilesBatchScheduler
* Description: 	Scheduler for batch class ONE_DeleteOldFilesBatch
* Date: 25/04/2025
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: ONE_DeleteOldFilesBatchSchedulerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		252/04/2025		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

global class ONE_DeleteOldFilesBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        ONE_DeleteOldFilesBatch batch = new ONE_DeleteOldFilesBatch();
        Database.executeBatch(batch, 500);
    }
}
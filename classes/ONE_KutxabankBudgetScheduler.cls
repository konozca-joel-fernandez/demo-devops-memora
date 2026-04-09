/**
* File Name: ONE_KutxabankBudgetScheduler
* Description: 	Scheduler for batch class ONE_KutxabankBudgetBatch
* Date: 04/08/2025
*
* Copyright: Konozca Consulting
* @author: Marc Pàmies
* Test: ONE_KutxabankBudgetTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		04/08/2025		Marc Pàmies  		Class creation
* ===================================================================================================================
*/

global class ONE_KutxabankBudgetScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        ONE_KutxabankBudgetBatch batch = new ONE_KutxabankBudgetBatch();
        Database.executeBatch(batch, 10);
    }
}
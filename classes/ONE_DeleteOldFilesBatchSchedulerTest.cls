@isTest
public class ONE_DeleteOldFilesBatchSchedulerTest {

    @isTest
    static void testSchedulerExecution() {
        Test.startTest();

        // Programar el job (esto lo ejecutará dentro del test)
        String cronExp = '0 0 12 1 1 ? 2026'; // cualquier fecha futura válida
        System.schedule('Test ONE_DeleteOldFilesBatchScheduler', cronExp, new ONE_DeleteOldFilesBatchScheduler());

        Test.stopTest();
    }
}
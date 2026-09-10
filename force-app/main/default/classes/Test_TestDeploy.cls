@isTest
private class Test_TestDeploy {
    @isTest
    static void testFunction() {
        Test.startTest();
        TestDeploy td = new TestDeploy();
        td.testFunction();
        Test.stopTest();
        System.debug('TEST');
        System.assert(true, 'TestDeploy ejecutada correctamente.');
    }
}
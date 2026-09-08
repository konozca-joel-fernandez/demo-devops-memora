public with sharing class TestDeploy {
    public void testFunction() {
        System.debug('TestDeploy: testFunction');
        List<Account> accsList = [SELECT Id, Name FROM Account WITH USER_MODE LIMIT 10];
    }
}
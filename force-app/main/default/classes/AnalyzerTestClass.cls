public with sharing class AnalyzerTestClass {
    public static void runBadPractices() {
        String accountId = '001000000000000AAA';

        for (Integer i = 0; i < 500; i++) {
            List<Account> accs = [SELECT Id, Name FROM Account WHERE Id = :accountId WITH USER_MODE];
        }
    }
}
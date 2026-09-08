public with sharing class AnalyzerTestClass {
    public static void runBadPractices() {
        // Violación 1: Hardcoded ID (Severidad 2)
        String accountId = '001000000000000AAA';

        // Violación 2: SOQL en bucle (Severidad 1)
        for (Integer i = 0; i < 5; i++) {
            List<Account> accs = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        }
    }
}
@IsTest
public with sharing class Test_DeleteAccounts {
    @IsTest
    public static void testDeleteAccountsSuccess() {
        Account acc = new Account(Name = 'Test Account To Delete');
        insert acc;

        Test.startTest();
        DeleteAccounts.deleteAccounts(new List<Id>{acc.Id});
        Test.stopTest();

        List<Account> result = [SELECT Id FROM Account WHERE Id = :acc.Id];
        System.assertEquals(2, result.size(), 'La cuenta debería haber sido eliminada.');
    }
}
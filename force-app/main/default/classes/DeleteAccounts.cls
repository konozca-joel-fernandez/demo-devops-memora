public with sharing class DeleteAccounts {
    
    @InvocableMethod(label='Delete Accounts')
    public static void deleteAccounts(List<Id> accountIds) {
        if (accountIds != null && !accountIds.isEmpty()) {
            delete [SELECT Id FROM Account WHERE Id IN :accountIds];
        }
    }
}
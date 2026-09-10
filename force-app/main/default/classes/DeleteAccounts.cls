public with sharing class DeleteAccounts {
    @InvocableMethod(label='Delete Accounts')
    public static void deleteAccounts(List<Id> accountIds) {
        if (accountIds != null && !accountIds.isEmpty()) {
            List<Account> accountsToDelete = [SELECT Id, Name FROM Account WHERE Id IN :accountIds WITH USER_MODE];
            if (!accountsToDelete.isEmpty() && Schema.sObjectType.Account.isDeletable()) {
                delete accountsToDelete;
            }
        }
    }
}
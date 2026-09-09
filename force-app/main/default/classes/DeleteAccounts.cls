public with sharing class DeleteAccounts {
    
    @InvocableMethod(label='Delete Accounts')
    public static void deleteAccounts(List<Id> accountIds) {
        if (accountIds != null && !accountIds.isEmpty()) {
            delete [SELECT Id FROM Account WHERE Id IN :accountIds];
        }
    }

    @InvocableMethod(label='Delete Accounts With Contacts')
    public static void deleteAccountsWithContacts(List<Id> accountIds) {
        if (accountIds != null && !accountIds.isEmpty()) {
            delete [SELECT Id FROM Account WHERE Id IN :accountIds AND Id NOT IN (SELECT AccountId FROM Contact)];
        }
    }
}
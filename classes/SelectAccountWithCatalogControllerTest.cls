@isTest
public with sharing class SelectAccountWithCatalogControllerTest {

    @testSetup
    private static void testSetup() {

        Account account = new Account(
            Name = 'Company',
            ONE_Nivel_Jerarquia_Cuentas__c = 'Agrupación Salesforce',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS)
        );
        insert account;

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar'
        );
        insert lugar;

        ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = account.Id
        );
        insert catalogo;
    }

    @isTest
    private static void getAccountsWithCatalog() {

        Test.startTest();
        Map<Id, String> accountMap = SelectAccountWithCatalogController.getAccountsWithCatalog();
        Test.stopTest();

        System.assertEquals(1, accountMap.size());
    }
}
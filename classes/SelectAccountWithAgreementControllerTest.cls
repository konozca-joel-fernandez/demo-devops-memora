@isTest
public with sharing class SelectAccountWithAgreementControllerTest {

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
            ONE_Validez_Desde__c = Date.today().addDays(-1)
        );
        insert catalogo;

        ONE_Segmentacion_Acuerdo__c acuerdo = new ONE_Segmentacion_Acuerdo__c(
            ONE_Vigencia_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = account.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Lugar__c = lugar.Id
        );
        insert acuerdo;
    }

    @isTest
    private static void getAccountsWithAgreement() {

        Test.startTest();
        Map<Id, String> accountMap = SelectAccountWithAgreementController.getAccountsWithAgreement();
        Test.stopTest();

        System.assertEquals(1, accountMap.size());
    }
}
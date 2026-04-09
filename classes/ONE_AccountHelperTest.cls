/**
 * Created by mbujak003 on 31.01.2021.
 */

@IsTest
public with sharing class ONE_AccountHelperTest {

    private static final String nDocumento = 'ABCDEF';

    @IsTest
    public static void testFetchAccountsByDocumento() {
        Test.startTest();
        ONE_TestDataFactory.createPersonAccount(new Account(ONE_N_Documento__pc = nDocumento), true);
        Test.stopTest();

        Account acc = [SELECT Id, ONE_N_Documento__pc FROM Account];

        System.assertEquals(nDocumento, acc.ONE_N_Documento__pc);
    }

    @IsTest
    public static void test2() {
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'op1', StageName='New', CloseDate=Date.today());
        insert opp;
        Test.stopTest();
    }
     @IsTest
    public static void testAccountHelper() {
        Test.startTest();
        Account ac2 = ONE_TestDataFactory.createPersonAccount(null, false);
        ac2.ONE_Tipo_de_documento__pc='97';
        ac2.ONE_N_Documento__pc='19199040C';
        insert ac2;
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'C';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Beneficiario_1__c=ac2.Id;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;
        ONE_AccountHelper.fetchAccountsByContractId(contrato.Id);
        ONE_AccountHelper.fetchAccountsByDocumento('19199040C');
        Test.stopTest();
    }
}
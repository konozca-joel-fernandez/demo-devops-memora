/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_ContactSearchControllerTest {

    @TestSetup
    public static void dataSetup() {
        ONE_TestDataFactory.createNonCompAccount(new Account(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)
        ), true);
    }

    @IsTest
    public static void fetchAccountsDataTest1() {
        Map<String, String> filtersMap = new Map<String, String> {
            'documento' => 'test',
            'cuenta' => 'test',
            'difundo' => 'test'
        };

        String jsn = '';
        Test.startTest();
        jsn = ONE_ContactSearchController.fetchAccountsData(filtersMap);
        ONE_ContactSearchController.AccountWrapper ac= new ONE_ContactSearchController.AccountWrapper('accountId',  'accountName',  'companiaAseguradoraName', 12,  System.now(),  'documentName',  'contractName');
        Test.stopTest();

        System.assertEquals(
            0,
            ((List<ONE_ContactSearchController.AccountWrapper>)JSON.deserialize(jsn, List<ONE_ContactSearchController.AccountWrapper>.class)).size()
        );

    }
    @IsTest
    public static void fetchAccountsDataTest2() {
        Map<String, String> filtersMap = new Map<String, String> {
            'difundo' => [SELECT Id, Name FROM Account LIMIT 1].Name
        };

        String jsn = '';
        Test.startTest();
        jsn = ONE_ContactSearchController.fetchAccountsData(filtersMap);
        Test.stopTest();

        
    }
     @IsTest
    public static void fetchAccountsDataTest3() {
        Map<String, String> filtersMap = new Map<String, String> {
            'cuenta' => 'electium'
        };
		
        String jsn = '';
        Test.startTest();
        jsn = ONE_ContactSearchController.fetchAccountsData(filtersMap);
        Test.stopTest();

        
    }
}
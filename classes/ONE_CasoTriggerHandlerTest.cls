@isTest
private class ONE_CasoTriggerHandlerTest {

    @testSetup
    private static void setup() {

        Account difunto = ONE_TestDataFactory.FuncionTest1(new Account(LastName = 'Pepe'), true);
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.FuncionTest1(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.FuncionTest1(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.FuncionTest1(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account tanatorio = ONE_TestDataFactory.FuncionTest1(new Account(Name = 'Centro', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        
    }

    @isTest
    private static void insertCaso() {

        Account difunto = [SELECT Id FROM Account WHERE LastName = 'Pepe' LIMIT 1];
        Account tanatorio = [SELECT Id FROM Account WHERE Name = 'Centro' LIMIT 1];

        Test.startTest();

        ONE_Caso__c caso = new ONE_Caso__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion'), ONE_Centro_del_Servicio__c = tanatorio.Id, ONE_Difunto__c = difunto.Id);
        insert caso;

        Test.stopTest();
    }

    @isTest
    private static void updateCaso1() {

        Test.startTest();

        Account difunto = [SELECT Id FROM Account WHERE LastName = 'Pepe' LIMIT 1];
        Account tanatorio = [SELECT Id FROM Account WHERE Name = 'Centro' LIMIT 1];

        ONE_Caso__c caso = new ONE_Caso__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion'), ONE_Centro_del_Servicio__c = tanatorio.Id, ONE_Difunto__c = difunto.Id);
        insert caso;

        ONE_Expediente__c expediente = ONE_TestDataFactory.FuncionTest2(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = tanatorio.Id), true);

        caso.ONE_Expediente__c = expediente.Id;

        update caso;

        Test.stopTest();
    }

    @isTest
    private static void updateCaso2() {

        Test.startTest();

        Account difunto = [SELECT Id FROM Account WHERE LastName = 'Pepe' LIMIT 1];
        Account difunto2 = ONE_TestDataFactory.createPersonAccount(new Account(LastName = 'Jaime'), true);
        Account tanatorio = [SELECT Id FROM Account WHERE Name = 'Centro' LIMIT 1];

        ONE_Caso__c caso = new ONE_Caso__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion'), ONE_Centro_del_Servicio__c = tanatorio.Id, ONE_Difunto__c = difunto.Id);
        insert caso;


        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c WHERE ONE_Lugar_Superior__r.ONE_Lugar_Superior__c != null LIMIT 1];
        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 2', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);

        caso.ONE_Difunto__c = difunto2.Id;
        caso.ONE_Centro_del_Servicio__c = tanatorio2.Id;
        caso.ONE_Tipo_De_Difunto__c = '3';

        update caso;

        Test.stopTest();
    }
}
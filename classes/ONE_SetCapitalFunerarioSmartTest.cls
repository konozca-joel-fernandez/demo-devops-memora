@isTest
//Test class for ONE_SetCapitalFunerarioSmart
public with sharing class ONE_SetCapitalFunerarioSmartTest {
    @TestSetup
    //Method to create all the data for the test        
    private static void testSetup() {

        ONE_Contrato__c ctSB_Deposito = 
            new ONE_Contrato__c(ONE_Tipo_De_Presupuesto__c = 'SB', ONE_Tipo_Servicio_Smart__c = '2', ONE_Direccion_Provincia_Smart__c = '08', 
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Contrato__c.SObjectType.getDescribe().name,
            ONE_CommonConstants.CONT_RT_ELECTIUM));
        insert ctSB_Deposito;

        ONE_Contrato__c ctSB_Velatorio = 
            new ONE_Contrato__c(ONE_Tipo_De_Presupuesto__c = 'SB', ONE_Tipo_Servicio_Smart__c = '1', ONE_Direccion_Provincia_Smart__c = '08', 
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Contrato__c.SObjectType.getDescribe().name,
            ONE_CommonConstants.CONT_RT_ELECTIUM));
        insert ctSB_Velatorio;

        ONE_Contrato__c ctSP = 
            new ONE_Contrato__c(ONE_Tipo_De_Presupuesto__c = 'SP', ONE_Direccion_Provincia_Smart__c = '08', 
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Contrato__c.SObjectType.getDescribe().name,
            ONE_CommonConstants.CONT_RT_ELECTIUM));
        insert ctSP;

        ONE_Contrato__c ctSR = 
            new ONE_Contrato__c(ONE_Tipo_De_Presupuesto__c = 'SR', ONE_Pais_de_Repatriacion__c = 'DE', 
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Contrato__c.SObjectType.getDescribe().name,
            ONE_CommonConstants.CONT_RT_ELECTIUM));
        insert ctSR;


        List<ONE_Contrato__c> contratosSBSP = new List<ONE_Contrato__c>(); 
        contratosSBSP.add(ctSB_Deposito);
        contratosSBSP.add(ctSB_Velatorio);
        contratosSBSP.add(ctSP);

        List<ONE_Contrato__c> contratosSR = new List<ONE_Contrato__c>();
        contratosSR.add(ctSR);

        List<ONE_Contrato__c> contratosAModificar = new List<ONE_Contrato__c>(); 

        ONE_Precios_Electium__c precioProvinciaBcn = 
            new ONE_Precios_Electium__c (ONE_Provincia__c = '08', ONE_Capital_Funerario__c = 1000, ONE_Capital_Funerario_Deposito__c = 900 );
        insert precioProvinciaBcn;

        ONE_Precios_Electium__c precioPaisAlemania = 
            new ONE_Precios_Electium__c (ONE_Pais_Repatriacion__c = 'DE', ONE_Capital_Funerario__c = 1000);
        insert precioPaisAlemania;

        List<ONE_Precios_Electium__c> preciosProvincia = new List<ONE_Precios_Electium__c>(); 
        preciosProvincia.add(precioProvinciaBcn);

        List<ONE_Precios_Electium__c> preciosPais = new List<ONE_Precios_Electium__c>(); 
        preciosPais.add(precioPaisAlemania);
    }

    
    @IsTest
    private static void setPreciosElectium() {
        Test.startTest();
        ONE_SetCapitalFunerarioSmart preciosClass = new ONE_SetCapitalFunerarioSmart();
        Test.stopTest();

    }

}
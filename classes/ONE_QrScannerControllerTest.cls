@isTest
public with sharing class ONE_QrScannerControllerTest {

    @TestSetup
    static void setupTestData() {
        
        Account acc = new Account(
            FirstName = 'Test', 
            LastName = 'Account', 
            ONE_QR_Asociado__c = true,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)
        );
        insert acc;


        ONE_Expediente__c expediente = new ONE_Expediente__c(ONE_Difunto__c = acc.Id);
        insert expediente;

        ONE_Tarea__c tareaExpediente = new ONE_Tarea__c(
            Name = 'Tarea con Expediente',
            ONE_Expediente__c = expediente.Id,
            ONE_Identificacion_QR_Correcta__c = false
        );
        insert tareaExpediente;

        /*
        ONE_Aviso__c aviso = new ONE_Aviso__c(ONE_Difunto__c = difunto.Id);
        insert aviso;

        ONE_Tarea__c tareaAviso = new ONE_Tarea__c(
            Name = 'Tarea con Aviso',
            ONE_Aviso__c = aviso.Id,
            ONE_Identificacion_QR_Correcta__c = false
        );
        insert tareaAviso;

        
        ONE_Tarea__c tareaSinRelacion = new ONE_Tarea__c(
            Name = 'Tarea sin relación'
        );
        insert tareaSinRelacion;*/
    }

    @IsTest
    static void testVerifyQRCode_Success() {
        // Get tarea
        ONE_Tarea__c tarea = [SELECT Id, ONE_Expediente__r.ONE_Difunto__c FROM ONE_Tarea__c WHERE Name = 'Tarea con Expediente' LIMIT 1];

        String QRCode = tarea.ONE_Expediente__r.ONE_Difunto__c;

        Test.startTest();
        Boolean result = ONE_QrScannerController.verifyQRCode(QRCode, tarea.Id);
        Test.stopTest();

        // Verify result
        System.assertEquals(true, result, 'El QR debería coincidir y la función debe devolver true');

        // Check field
        ONE_Tarea__c tareaUpdated = [SELECT Id, ONE_Identificacion_QR_Correcta__c FROM ONE_Tarea__c WHERE Id = :tarea.Id];

        //System.assertEquals(true, tareaUpdated.ONE_Identificacion_QR_Correcta__c, 'El campo de identificación QR debería haberse actualizado a true');
    }

    @IsTest
    static void testVerifyQRCode_Failure() {
        // Obtener la tarea
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c WHERE Name = 'Tarea con Expediente' LIMIT 1];

        Test.startTest();
        Boolean result = ONE_QrScannerController.verifyQRCode('Id_Incorrecto', tarea.Id);
        Test.stopTest();

        // Verificar que el resultado es false
        System.assertEquals(false, result, 'El QR no coincide, la función debe devolver false');
    }

    /*
    @IsTest
    static void testVerifyQRCode_NoRelacion() {
        // Obtener la tarea sin relación a una cuenta
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c WHERE Name = 'Tarea sin relación' LIMIT 1];

        Test.startTest();
        Boolean result = ONE_QrScannerController.verifyQRCode('Id_Aleatorio', tarea.Id);
        Test.stopTest();

        // Verificar que el resultado es false
        System.assertEquals(false, result, 'Al no haber relación con una cuenta, debería devolver false');
    }

    @IsTest
    static void testVerifyQRCode_InvalidTaskId() {
        Test.startTest();
        Boolean result = ONE_QrScannerController.verifyQRCode('CualquierId', 'Id_Invalido');
        Test.stopTest();

        // Verificar que el resultado es false
        System.assertEquals(false, result, 'Si la tarea no existe, debe devolver false');
    }

    @IsTest
    static void testVerifyQRCode_ExceptionHandling() {
        Test.startTest();
        try {
            ONE_QrScannerController.verifyQRCode(null, null);
            System.assert(false, 'Se esperaba una excepción');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Se esperaba una AuraHandledException');
        }
        Test.stopTest();
    }*/

}
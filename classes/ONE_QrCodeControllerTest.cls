@IsTest
public with sharing class ONE_QrCodeControllerTest {

    @TestSetup
    static void setup() {
        // Create test data
        Account acc = new Account(
            FirstName = 'Test', 
            LastName = 'Account', 
            ONE_QR_Asociado__c = false,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)
        );
        insert acc;

        ContentVersion cv = new ContentVersion(
            Title = 'Test QR Code.png',
            PathOnClient = 'Test QR Code.png',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert cv;

        ONE_Caso__c c = new ONE_Caso__c(
            ONE_Difunto__c = acc.Id
        );
        insert c;

        ONE_Expediente__c exp = new ONE_Expediente__c(
            ONE_Difunto__c = acc.Id
        );
        insert exp;
    }

    @IsTest
    static void testCreateQRFlow() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Simulate base64
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code Data'));

        Test.startTest();
        String result = ONE_QrCodeController.createQRFlow(qrCodeBase64, acc.Id);
        Test.stopTest();

        // Check result is not null
        System.assertNotEquals(null, result, 'El resultado no debería ser nulo');
        
    }

    @IsTest
    static void testCreateQRAutoFromAccount() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Simulate base64
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code Data'));

        Test.startTest();
        String result = ONE_QrCodeController.createQRAuto(qrCodeBase64, acc.Id);
        Test.stopTest();

        // Convert json result to map
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        // Check statusCode
        System.assertEquals(2, resultMap.get('statusCode'), 'El statusCode debería ser 2');
        // Check QR is associated to account
        Account accountUpdated  = [SELECT Id, ONE_QR_Asociado__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assert(accountUpdated.ONE_QR_Asociado__c, 'El campo QR_Asociado deberia ser True');
    }

    @IsTest
    static void testCreateQRAutoFromCase() {
        
        ONE_Caso__c c = [SELECT Id, ONE_Difunto__c FROM ONE_Caso__c LIMIT 1];
        
        // Simulate base64
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code Data'));

        Test.startTest();
        String accountId = ONE_QrCodeController.getAccountId(c.Id);
        String result = ONE_QrCodeController.createQRAuto(qrCodeBase64, accountId);
        Test.stopTest();

        // Convert json result to map
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        // Check statusCode
        System.assertEquals(2, resultMap.get('statusCode'), 'El statusCode debería ser 2');
        // Check QR is associated to account
        Account accountUpdated  = [SELECT Id, ONE_QR_Asociado__c FROM Account WHERE Id = :c.ONE_Difunto__c LIMIT 1];
        System.assert(accountUpdated.ONE_QR_Asociado__c, 'El campo QR_Asociado deberia ser True');
    }

    @IsTest
    static void testCreateQRAutoFromExp() {
        
        ONE_Expediente__c exp = [SELECT Id, ONE_Difunto__c FROM ONE_Expediente__c LIMIT 1];
        
        // Simulate base64
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code Data'));

        Test.startTest();
        String accountId = ONE_QrCodeController.getAccountId(exp.Id);
        String result = ONE_QrCodeController.createQRAuto(qrCodeBase64, accountId);
        Test.stopTest();

        // Convert json result to map
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        // Check statusCode
        System.assertEquals(2, resultMap.get('statusCode'), 'El statusCode debería ser 2');
        // Check QR is associated to account
        Account accountUpdated  = [SELECT Id, ONE_QR_Asociado__c FROM Account WHERE Id = :exp.ONE_Difunto__c LIMIT 1];
        System.assert(accountUpdated.ONE_QR_Asociado__c, 'El campo QR_Asociado deberia ser True');
    }

    //TEST EXCEPTIONS

    @IsTest
    static void testCreateQRAutoAccountNotFound() {
        // Simulate base64
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code Data'));
        String invalidAccountId = '00NXXXXXXXXXXXX';
    
        Test.startTest();
        String result = ONE_QrCodeController.createQRAuto(qrCodeBase64, invalidAccountId);
        Test.stopTest();
    
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
    
        System.assertEquals(3, resultMap.get('statusCode'), 'El statusCode debería ser 3 cuando se le pasa una Id invalida.');
    }
    
    @IsTest
    static void testCreateQRAutoAccountNotFound2() {
        // Simulate base64
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code Data'));
        
        ONE_Expediente__c exp = new ONE_Expediente__c(
            ONE_Difunto__c = null
        );
        insert exp;
    
        Test.startTest();
        String result = ONE_QrCodeController.createQRAuto(qrCodeBase64, exp.Id);
        Test.stopTest();
    
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
    
        System.assertEquals(3, resultMap.get('statusCode'), 'El statusCode debería ser 3 cuando la cuenta no existe.');
    }

    @IsTest
    static void testCreateQRAutoQRAlreadyAssociated() {
        // Create account with QR associated
        Account acc = new Account(FirstName = 'Test', LastName = 'QRAlready', ONE_QR_Asociado__c = true);
        insert acc;
    
        // Simulate base64
        String qrCodeBase64 = EncodingUtil.base64Encode(Blob.valueOf('Dummy QR Code Data'));
    
        Test.startTest();
        String result = ONE_QrCodeController.createQRAuto(qrCodeBase64, acc.Id);
        Test.stopTest();
    
        // Convertir el resultado JSON en un mapa
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
    
        // Validar que el statusCode sea 1
        System.assertEquals(1, resultMap.get('statusCode'), 'El statusCode debería ser 1 cuando el QR ya está asociado.');
    }

    @IsTest
    static void testCreateQRAutoException() {
        
        Account acc = new Account(FirstName = 'Test', LastName = 'DMLException');
        insert acc;
    
        // base64 with invalid data
        String invalidBase64 = 'InvalidBase64String==nf7fpa¡¡d++';
    
        Test.startTest();
        String result = ONE_QrCodeController.createQRAuto(invalidBase64, acc.Id);
        Test.stopTest();
    
        // Convertir json result a un mapa
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
    
        // Validar que el código de error sea 0
        System.assertEquals(0, resultMap.get('statusCode'), 'El statusCode debería ser 0 por la Exception');
        System.assert(resultMap.containsKey('message'), 'Debería haber un mensaje de error');
        System.debug('Mensaje de error: ' + resultMap.get('message'));
    }


    @IsTest
    static void testGeneratePDF() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];

        // Flow input
        ONE_QrCodeController.FlowInput input = new ONE_QrCodeController.FlowInput();
        input.flowAccountId = acc.Id;
        input.flowQRContentVersionId = cv.Id;

        List<ONE_QrCodeController.FlowInput> inputs = new List<ONE_QrCodeController.FlowInput>{ input };

        Test.startTest();
        List<ONE_QrCodeController.FlowOutput> outputs = ONE_QrCodeController.generatePDF(inputs);
        Test.stopTest();

        // Verify PDF Generated
        ONE_QrCodeController.FlowOutput output = outputs[0];
        System.assert(output.success, 'El PDF debería haberse generado exitosamente');
        System.assertNotEquals(null, output.flowPDFContentVersionId, 'El ContentVersionId del PDF no debería ser nulo');
    }
}
@isTest
public with sharing class ONE_QrPDFControllerTest {

    @TestSetup
    private static void testSetup() {
        // Create test data
        Account acc = new Account(
            FirstName = 'Test', 
            LastName = 'Account', 
            ONE_QR_Asociado__c = false,
            ONE_Fecha_De_Defuncion2__c = Date.today()
        );
        insert acc;

        ContentVersion cv = new ContentVersion(
            Title = 'Test QR Code.png',
            PathOnClient = 'Test QR Code.png',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert cv;
    }

    @IsTest
    static void testQrPDFController() {

        Account acc = [SELECT Id, Name, ONE_Fecha_De_Defuncion2__c FROM Account LIMIT 1];

        // Get ContentVersionId
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        String contentVersionId = cv.Id;

        String fechaDef = acc.ONE_Fecha_De_Defuncion2__c.format('dd/MM/YYYY');

        // Simulate Visualforce parameters
        PageReference pageRef = Page.oneQrPrinted;
        pageRef.getParameters().put('accountName', acc.Name);
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('contentVersionId', contentVersionId);
        pageRef.getParameters().put('fechaDef', fechaDef);

        Test.setCurrentPage(pageRef);

        // Execute controller
        Test.startTest();
        ONE_QrPDFController controller = new ONE_QrPDFController();
        Test.stopTest();

        // Validate results
        System.assertEquals(acc.Name, controller.nombreDifunto, 'El nombre del Account debería coincidir con el parámetro de la VF Page');
        System.assertEquals(
            ONE_QrPDFController.getDownloadLink() + contentVersionId,
            controller.imageUrl,
            'La URL de descarga debería ser correcta'
        );
        
    }

    @IsTest
    static void testQrPDFControllerWithMissingParameters() {
        // Simulate Page Without parameters
        PageReference pageRef = Page.oneQrPrinted;
        Test.setCurrentPage(pageRef);

        // Execute controller
        Test.startTest();
        ONE_QrPDFController controller = new ONE_QrPDFController();
        Test.stopTest();

        // Validate results
        System.assertEquals(1, ApexPages.getMessages().size(), 'Debería haber un mensaje de error en ApexPages');
    }

}
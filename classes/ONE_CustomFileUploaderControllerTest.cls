@IsTest
public class ONE_CustomFileUploaderControllerTest {

    // Helper method to get the expected max file size
    private static Integer getExpectedMaxFileSize() {
        AppConfig__mdt config = [
            SELECT Value__c
            FROM AppConfig__mdt
            WHERE DeveloperName = 'MaxFileSizeMB'
            LIMIT 1
        ];
        return Integer.valueOf(config.Value__c);
    }

    @IsTest
    static void testGetMaxFileSizeMB() {
        Integer expected = getExpectedMaxFileSize();

        Test.startTest();
        Integer result = ONE_CustomFileUploaderController.getMaxFileSizeMB();
        Test.stopTest();

        System.assertEquals(expected, result, 'Max file size should match metadata or fallback value');
    }

    @IsTest
    static void testValidateFileSizes_validFile() {

        //small file
        ContentVersion cv = new ContentVersion(
            Title = 'ValidDoc',
            PathOnClient = 'ValidDoc.pdf',
            VersionData = Blob.valueOf('test')
        );
        insert cv;

        Test.startTest();
        ONE_CustomFileUploaderController.ValidationResult result =
            ONE_CustomFileUploaderController.validateFileSizes(new List<Id>{ cv.Id });
        Test.stopTest();

        System.assert(result.allValid, 'File should be valid');
        System.assertEquals(1, result.validDocumentIds.size());
        System.assertEquals(1, result.validVersionIds.size());
        System.assertEquals(0, result.invalidFileNames.size());
    }

    @IsTest
    static void testValidateFileSizes_invalidFile() {
        Integer maxSize = 1; // Para testing necesitamos un doc mas pequeño
        Integer tooBigSize = (maxSize + 1) * 1024 * 1024;

        // Create a blob bigger than maxSize
        Blob bigBlob = Blob.valueOf('x'.repeat(tooBigSize));

        ContentVersion cv = new ContentVersion(
            Title = 'TooBigDoc',
            PathOnClient = 'TooBigDoc.pdf',
            VersionData = bigBlob
        );
        insert cv;

        Test.startTest();
        ONE_CustomFileUploaderController.ValidationResult result =
            ONE_CustomFileUploaderController.validateFileSizes(new List<Id>{ cv.Id });
        Test.stopTest();

        System.assert(!result.allValid, 'File should be invalid');
        System.assertEquals(0, result.validDocumentIds.size());
        System.assertEquals(0, result.validVersionIds.size());
        System.assertEquals(1, result.invalidFileNames.size());
        System.assertEquals('TooBigDoc', result.invalidFileNames[0]);
    }

    @IsTest
    static void testLinkToRecord() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        ContentVersion cv = new ContentVersion(
            Title = 'ValidDoc',
            PathOnClient = 'ValidDoc.pdf',
            VersionData = Blob.valueOf('test')
        );
        insert cv;

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        Test.startTest();
        ONE_CustomFileUploaderController.linkToRecord(acc.Id, new List<String>{ docId });
        Test.stopTest();

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :acc.Id
        ];

        System.assertEquals(1, links.size(), 'File should be linked to account');
        System.assertEquals(docId, links[0].ContentDocumentId);
    }
}
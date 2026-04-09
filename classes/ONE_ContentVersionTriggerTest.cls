@IsTest
public class ONE_ContentVersionTriggerTest {

    // Helper method to get the expected max file size
    private static Integer getExpectedMaxFileSize() {
        /*AppConfig__mdt config = [
            SELECT Value__c
            FROM AppConfig__mdt
            WHERE DeveloperName = 'OrgMaxFileSizeMB'
            LIMIT 1
        ];
        return Integer.valueOf(config.Value__c);*/

        // para testing
        return 2;
    }

    @IsTest
    static void testInsertValidFile() {
        Integer maxSize = getExpectedMaxFileSize();
        
        //small file
        ContentVersion cv = new ContentVersion(
            Title = 'ValidDoc',
            PathOnClient = 'ValidDoc.pdf',
            VersionData = Blob.valueOf('test')
        );

        Test.startTest();
        insert cv;
        Test.stopTest();

        // Verificamos que se insertó correctamente
        ContentVersion insertedCv = [
            SELECT Id, Title, ContentSize
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];
        System.assertEquals('ValidDoc', insertedCv.Title);
        System.assert(insertedCv.ContentSize < (maxSize * 1024 * 1024), 'Debe estar debajo del límite');
    }

    @IsTest
    static void testInsertInvalidFile() {
        Integer maxSize = getExpectedMaxFileSize();
        Integer tooBigSize = (maxSize + 1) * 1024 * 1024;

        // Create a blob bigger than maxSize
        Blob bigBlob = Blob.valueOf('x'.repeat(tooBigSize));

        ContentVersion cv = new ContentVersion(
            Title = 'TooBigDoc',
            PathOnClient = 'TooBigDoc.pdf',
            VersionData = bigBlob
        );

        Test.startTest();
        Database.SaveResult sr = Database.insert(cv, false);
        Test.stopTest();

        // Debe haber fallado con addError del trigger
        System.assert(!sr.isSuccess(), 'El insert debería fallar por superar el límite');
        System.assert(sr.getErrors().size() > 0, 'Debe haber un error en la lista');
        System.assert(sr.getErrors()[0].getMessage().contains('supera el tamaño máximo'), 'El error debe mencionar el tamaño máximo');
    }
}
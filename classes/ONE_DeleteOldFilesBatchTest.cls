@isTest
private class ONE_DeleteOldFilesBatchTest {

    @testSetup
    static void setupData() {

        // Create Caso Aviso
        Id casoRT = Schema.SObjectType.ONE_Caso__c.getRecordTypeInfosByDeveloperName().get('ONE_Avisos_De_Defuncion').getRecordTypeId();

        ONE_Caso__c caso = new ONE_Caso__c( RecordTypeId = casoRT );
        insert caso;

        // Expedientes
        ONE_Expediente__c expediente1 = new ONE_Expediente__c();
        ONE_Expediente__c expediente2 = new ONE_Expediente__c();
        insert new List<ONE_Expediente__c>{ expediente1, expediente2 };

        // Tareas
        ONE_Tarea__c tarea1 = new ONE_Tarea__c();
        ONE_Tarea__c tarea2 = new ONE_Tarea__c();
        insert new List<ONE_Tarea__c>{ tarea1, tarea2 };

        List<ContentVersion> versions = new List<ContentVersion>();

        for (Integer i = 0; i < 5; i++) {
            ContentVersion v = new ContentVersion(
                Title = 'Identificación Difunto prueba ' + i,
                PathOnClient = 'test' + i + '.jpg',
                VersionData = Blob.valueOf('Contenido ficticio'),
                IsMajorVersion = true
            );
            versions.add(v);
        }
        insert versions;

        for (ContentVersion ver : versions) {
            Datetime timeAgo = Datetime.now().addDays(-300);
            Test.setCreatedDate(ver.Id, timeAgo);
        }

        // Get CD created
        List<ContentDocument> docs = [
            SELECT Id, Title, CreatedDate
            FROM ContentDocument
        ];
        System.debug('Registros creados: ' + docs.size());

        // Create links

        Id docTarea = docs[0].Id;
        Id docTareaServicio = docs[1].Id;
        Id docServicio = docs[2].Id;
        Id docCaso = docs[3].Id;
        Id docUnlinked = docs[4].Id;

        List<ContentDocumentLink> links = new List<ContentDocumentLink>{
            new ContentDocumentLink(
                ContentDocumentId = docTarea,
                LinkedEntityId   = tarea1.Id,
                ShareType        = 'V',
                Visibility       = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = docTareaServicio,
                LinkedEntityId   = tarea2.Id,
                ShareType        = 'V',
                Visibility       = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = docTareaServicio,
                LinkedEntityId   = expediente1.Id,
                ShareType        = 'V',
                Visibility       = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = docServicio,
                LinkedEntityId   = expediente2.Id,
                ShareType        = 'V',
                Visibility       = 'AllUsers'
            ),
            new ContentDocumentLink(
                ContentDocumentId = docCaso,
                LinkedEntityId   = caso.Id,
                ShareType        = 'V',
                Visibility       = 'AllUsers'
            )
        };
        insert links;
        
    }

    @isTest
    static void testBatchExecution() {

        // Execute batch
        Test.startTest();
        ONE_DeleteOldFilesBatch batch = new ONE_DeleteOldFilesBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify deletion and exclusion
        Integer countInc = [SELECT count() FROM ContentDocument];
        System.assertEquals(2, countInc, '2 docs should be left');

        //log generated
        Integer countLogs = [SELECT count() FROM ONE_LogIntegraciones__c];
        System.assertEquals(1, countLogs, '1 log should be generated');

    }
}
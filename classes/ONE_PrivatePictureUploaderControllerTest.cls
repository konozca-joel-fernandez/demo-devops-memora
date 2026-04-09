@IsTest
private class ONE_PrivatePictureUploaderControllerTest {
    private static final String DATA = 'SGVsbG8gdGVzdA==';
    private static final String TITLE = 'Title';
    
    @IsTest
    private static void fileSavedForTareaParent() {
        Id queueId = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = :ONE_CommonConstants.FOTO_QUEUE_NAME
                AND Type = 'Queue'
        ].Id;
        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;
        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Expediente__c = expediente.Id);
        insert tarea;
        
        Test.startTest();
        
        ONE_PrivatePictureUploaderController.saveFileData(DATA, TITLE, tarea.Id);
        
        Test.stopTest();
        
        List<ONE_Foto__c> fotos = [SELECT Id, ONE_Tarea__c, ONE_Servicio__c, OwnerId FROM ONE_Foto__c];
        System.assertEquals(1, fotos.size());
        ONE_Foto__c foto = fotos.get(0);
        System.assertEquals(tarea.Id, foto.ONE_Tarea__c);
        System.assertEquals(expediente.Id, foto.ONE_Servicio__c);
        System.assertEquals(queueId, foto.OwnerId);
        
        tarea = [SELECT ONE_Foto_A_Difunto_Realizada__c FROM ONE_Tarea__c WHERE Id = :tarea.Id];
        System.assert(tarea.ONE_Foto_A_Difunto_Realizada__c);
    }
    
    @IsTest
    private static void fileSavedForExpedienteParent() {
        Id queueId = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = :ONE_CommonConstants.FOTO_QUEUE_NAME
                AND Type = 'Queue'
        ].Id;
        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;
    
        Test.startTest();
    
        ONE_PrivatePictureUploaderController.saveFileData(DATA, TITLE, expediente.Id);
    
        Test.stopTest();
    
        List<ONE_Foto__c> fotos = [SELECT Id, ONE_Tarea__c, ONE_Servicio__c, OwnerId FROM ONE_Foto__c];
        System.assertEquals(1, fotos.size());
        ONE_Foto__c foto = fotos.get(0);
        System.assertEquals(null, foto.ONE_Tarea__c);
        System.assertEquals(expediente.Id, foto.ONE_Servicio__c);
        System.assertEquals(queueId, foto.OwnerId);
    }
}
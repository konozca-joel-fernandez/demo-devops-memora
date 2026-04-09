@isTest
public class PdfGenerationServiceBulkTest {
    
    @testSetup
    private static void testSetup() {
        // Create test records
        Account acc = new Account(
            FirstName = 'Test', 
            LastName = 'Account', 
            ONE_QR_Asociado__c = false,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)
        );
        insert acc;

        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = acc.id
        );
        insert expediente;

        List<ONE_Documentos__c> docs = new List<ONE_Documentos__c>();
        for (Integer i = 0; i < 5; i++) {
            ONE_Documentos__c doc = new ONE_Documentos__c(ONE_Servicio__c = expediente.Id);
            docs.add(doc);
        }
        insert docs;
    }

    @isTest
    static void testCreateAndLinkPdf() {
        // Retrieve test data
        List<ONE_Documentos__c> docs = [SELECT Id FROM ONE_Documentos__c LIMIT 5];
        
        // Create FlowInput
        PdfGenerationServiceBulk.FlowInput flowInput = new PdfGenerationServiceBulk.FlowInput();
        flowInput.docList = docs;
        flowInput.language = 'es';
        
        List<PdfGenerationServiceBulk.FlowInput> flowInputs = new List<PdfGenerationServiceBulk.FlowInput>{flowInput};
        
        Test.startTest();
        List<PdfGenerationServiceBulk.FlowOutput> results = PdfGenerationServiceBulk.createAndLinkPdf(flowInputs);
        Test.stopTest();

        // Validate results
        System.assert(results[0].success, 'PDF generation should be successful');
        System.assertNotEquals(null, results[0].cdList, 'ContentDocumentIds should not be null');
        System.assertEquals(results[0].cdList.size(), docs.size(),'ContentDocumentIds size should be the number of documents');
    }

    @isTest
    static void testContentDocumentLinksCreated() {
        // Retrieve test data
        List<ONE_Documentos__c> docs = [SELECT Id, ONE_Servicio__c FROM ONE_Documentos__c LIMIT 5];
    
        Set<Id> documentoIds = new Set<Id>();
        Set<Id> expedienteIds = new Set<Id>();
    
        for (ONE_Documentos__c doc : docs) {
            documentoIds.add(doc.Id);
            expedienteIds.add(doc.ONE_Servicio__c);
        }
        
        // Create FlowInput
        PdfGenerationServiceBulk.FlowInput flowInput = new PdfGenerationServiceBulk.FlowInput();
        flowInput.docList = docs;
        flowInput.language = 'es';
        
        List<PdfGenerationServiceBulk.FlowInput> flowInputs = new List<PdfGenerationServiceBulk.FlowInput>{flowInput};
        
        Test.startTest();
        List<PdfGenerationServiceBulk.FlowOutput> results = PdfGenerationServiceBulk.createAndLinkPdf(flowInputs);
        Test.stopTest();
    
        // Validate results
        System.assert(results[0].success, 'PDF generation should be successful');
    
        List<ContentDocumentLink> linksDocs = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :documentoIds];
        System.assertEquals(documentoIds.size(), linksDocs.size(), 'Each document should have a linked Documento');
    
        List<ContentDocumentLink> linksServicios = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :expedienteIds];
        System.assertEquals(documentoIds.size(), linksServicios.size(), 'Each document should have a linked Servicio');
    }
    

}
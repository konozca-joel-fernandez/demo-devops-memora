@isTest
public class ONE_DeleteDocumentControllerTest {
    
 private static testMethod void deleteDocumentTest() {
          ContentVersion contentVersion_1 = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content')
        );
        insert contentVersion_1;
         ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
    	List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
      
     	Test.startTest();
       	ONE_DeleteDocumentController.deleteDocument(documents[0].Id);
       	ONE_DeleteDocumentController.deleteDocument(documents[0].Title);
     	Test.stopTest();
        
    }
}
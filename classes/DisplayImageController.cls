public without sharing class DisplayImageController  {

    @AuraEnabled
    public static ContentVersion getContentVersion(Id contentVersionId) {
        
        List<ContentVersion> contentVersion = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id = :contentVersionId];
		
        if (contentVersion.isEmpty()) {
            return null;
        }
        else {
			return contentVersion[0];
        }
    }    
}
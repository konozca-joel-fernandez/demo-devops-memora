/**
* File Name: ONE_CustomFileUploaderController
* Description: 	Controller for LWC oneCustomFileUploader
* Date: 04/09/2025
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: ONE_CustomFileUploaderControllerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		04/09/2025		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

public with sharing class ONE_CustomFileUploaderController {

    public class ValidationResult {
        @AuraEnabled public Boolean allValid;
        @AuraEnabled public List<Id> validDocumentIds;
        @AuraEnabled public List<Id> validVersionIds;
        @AuraEnabled public List<String> invalidFileNames;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getMaxFileSizeMB() {
        AppConfig__mdt config = [
            SELECT Value__c
            FROM AppConfig__mdt
            WHERE DeveloperName = 'MaxFileSizeMB'
            LIMIT 1
        ];
        return Integer.valueOf(config.Value__c);
    }

    @AuraEnabled
    public static ValidationResult validateFileSizes(List<Id> contentVersionIds) {
        Integer maxSize = getMaxFileSizeMB();
        //Si es test ponemos un limite menor estatico
        if (Test.isRunningTest()) maxSize = 1;


        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId, ContentSize, Title
            FROM ContentVersion
            WHERE Id IN :contentVersionIds
        ];

        List<ContentDocument> toDelete = new List<ContentDocument>();
        List<Id> validDocIds = new List<Id>();
        List<Id> validVerIds = new List<Id>();
        List<String> invalidNames = new List<String>();

        for (ContentVersion cv : versions) {
            if (cv.ContentSize > maxSize * 1024 * 1024) {
                invalidNames.add(cv.Title);
                toDelete.add(new ContentDocument(Id = cv.ContentDocumentId));
            } else {
                validDocIds.add(cv.ContentDocumentId);
                validVerIds.add(cv.Id);
            }
        }

        if (!toDelete.isEmpty()) {
            delete toDelete;
            Database.emptyRecycleBin(toDelete);
        }

        ValidationResult result = new ValidationResult();
        result.allValid = toDelete.isEmpty();
        result.validDocumentIds = validDocIds;
        result.validVersionIds = validVerIds;
        result.invalidFileNames = invalidNames;
        return result;
    }



    @AuraEnabled
    public static void linkToRecord(String recordId, List<String> contentDocumentIds) {

        try {
            if (recordId == null || contentDocumentIds == null || contentDocumentIds.isEmpty()) return;

            List<ContentDocumentLink> linksList = new List<ContentDocumentLink>();

            // Link the ContentDocuments to the recordId
            for(String cdId : contentDocumentIds) {
                ContentDocumentLink newLink = new ContentDocumentLink();
                newLink.ContentDocumentId = cdId;
                newLink.LinkedEntityId = recordId;
                newLink.ShareType = 'V';
                newLink.Visibility = 'AllUsers';
                linksList.add(newLink);
            }
            insert linksList;
            
        } catch (Exception e) {
            System.debug('Error linking files to record: ' + e.getMessage());
        }
    }

}
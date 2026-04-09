/**
 * Created by mkuzak001 on 18.02.2021.
 */

public with sharing class ONE_PrivatePictureUploaderController {
    @AuraEnabled
    public static void saveFileData(String data, String title, Id parentId) {
        Savepoint sp = Database.setSavepoint();
        try {
            Id tareaId = getTareaId(parentId);
            Id expedienteId = getExpedienteId(parentId);
    
            ContentVersion versionData = createContentVersion(data, title);
    
            Id contentDocumentId = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :versionData.Id
            ].ContentDocumentId;
    
            ONE_Foto__c foto = createFoto(contentDocumentId, tareaId, expedienteId);
    
            createContentDocumentLink(contentDocumentId, foto.Id);
    
            setTareaFlag(tareaId);
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            
            throw new ONE_PrivatePictureUploaderException(ex);
        }
    }
    
    private static ContentVersion createContentVersion(String data, String title) {
        ContentVersion versionData = new ContentVersion();
        versionData.ContentLocation = 'S';
        versionData.VersionData = EncodingUtil.base64Decode(data);
        versionData.Title = title;
        versionData.PathOnClient = title;
        versionData.SharingOption = 'R';//restricted
        insert versionData;
        return versionData;
    }
    
    private static ONE_Foto__c createFoto(Id contentDocumentId, Id tareaId, Id expedienteId) {
        Id queueId = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = :ONE_CommonConstants.FOTO_QUEUE_NAME
                AND Type = 'Queue'
        ].Id;
        ONE_Foto__c foto = new ONE_Foto__c(OwnerId = queueId, FileId__c = contentDocumentId);
        foto.ONE_Tarea__c = tareaId;
        foto.ONE_Servicio__c = expedienteId;
        
        insert foto;
        return foto;
    }
    
    private static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id linkedEntityId) {
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = contentDocumentId;
        conDocLink.LinkedEntityId = linkedEntityId;
        conDocLink.ShareType = 'I';//inherited from parent
        insert conDocLink;
        return conDocLink;
    }
    
    private static Id getTareaId(Id parentId) {
        String parentType = ONE_CommonUtils.getsObjectName(parentId);
        if (parentType == ONE_Tarea__c.getSobjectType().getDescribe().getName()) {
            return parentId;
        } else {
            return null;
        }
    }
    
    private static Id getExpedienteId(Id parentId) {
        String parentType = ONE_CommonUtils.getsObjectName(parentId);
        if (parentType == ONE_Tarea__c.getSobjectType().getDescribe().getName()) {
            ONE_Tarea__c tarea = [
                SELECT ONE_Expediente__c
                FROM ONE_Tarea__c
                WHERE Id = :parentId
            ];
            return tarea.ONE_Expediente__c;
        } else {
            return parentId;
        }
    }
    
    private static void setTareaFlag(Id tareaId) {
        if (tareaId != null) {
            update new ONE_Tarea__c(ONE_Foto_A_Difunto_Realizada__c = true, Id = tareaId);
        }
    }
    
    public class ONE_PrivatePictureUploaderException extends Exception {}
}
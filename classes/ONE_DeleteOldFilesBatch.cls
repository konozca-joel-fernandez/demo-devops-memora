/**
* File Name: ONE_DeleteOldFilesBatch
* Description: 	Batch created to delete automatically images of 'identificación difunto'
* Date: 22/04/2025
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: ONE_DeleteOldFilesBatchTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		22/04/2025		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

public without sharing class ONE_DeleteOldFilesBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Integer totalRecords = 0;
    private Integer deletedRecords = 0;
    private List<String> errorMessages = new List<String>();

    // Map Document -> [Linked Entities]
    Map<Id, List<Id>> docToEntities = new Map<Id, List<Id>>();

    private Long totalSize = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, Title, CreatedDate, ContentDocumentId, ContentSize
            FROM ContentVersion
            WHERE (Title LIKE 'Identificación Difunto%' OR
                   Title LIKE 'Imagen Esquela%' OR
                   Title LIKE 'Imagen Sala%')
            AND CreatedDate < LAST_N_MONTHS:3
        ]);
    }

    public void execute(Database.BatchableContext bc, List<ContentVersion> scope) {

        Set<Id> allDocIds = new Set<Id>();
        Map<Id, Long> docSizeMap = new Map<Id, Long>();

        // First, get all CD Ids

        for (ContentVersion cv : scope) {
            allDocIds.add(cv.ContentDocumentId);
            docSizeMap.put(cv.ContentDocumentId, cv.ContentSize);
        }

        totalRecords += allDocIds.size();

        try {
            // Get all links to documents

            List<ContentDocumentLink> allLinks  = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :allDocIds
            ];


            Map<Id, List<Id>> docToEntitiesChunk = new Map<Id, List<Id>>();

            for (ContentDocumentLink link : allLinks) {
    
                /* WE ONLY DELETE DOCS RELATED TO SERVICIOS/TAREAS
                Servicio -> a0T..
                Tarea -> a0s..
                */
                if (String.valueOf(link.LinkedEntityId).startsWith('a0T') ||
                    String.valueOf(link.LinkedEntityId).startsWith('a0s')) {

                        if (!docToEntitiesChunk.containsKey(link.ContentDocumentId)) {
                            docToEntitiesChunk.put(link.ContentDocumentId, new List<Id>());
                        }
                        docToEntitiesChunk.get(link.ContentDocumentId).add(link.LinkedEntityId);
                }
            }

            Set<Id> docIdsToDelete = new Set<Id>();

            // Iterate over doc Ids and add to delete
            
            for (Id docId : docToEntitiesChunk.keySet()) {
                List<Id> linkedEntities = docToEntitiesChunk.get(docId);
            
                docIdsToDelete.add(docId);
                totalSize += docSizeMap.get(docId);

                // add key->values to global map
                docToEntities.put(docId, linkedEntities);
                    
            }

            // DELETE DOCS

            if (!docIdsToDelete.isEmpty()) {

                List<ContentDocument> docsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :docIdsToDelete];
                System.debug('Deleting files...');
                delete docsToDelete;
                deletedRecords += docsToDelete.size();
            }
            
            System.debug('Archivos totales encontrados: ' + totalRecords);
            System.debug('Eliminados: ' + deletedRecords);

        } catch (Exception e) {
            errorMessages.add('Error en la ejecución: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {

        String request = 'Batch ejecutado el ' + String.valueOf(Datetime.now());
        String logMap = '{"DocID":["ServicioID","TareaID"], ...}\n' +
                        JSON.serialize(docToEntities);

        // Set IntegrationLog
        ONE_LogIntegraciones__c log = new ONE_LogIntegraciones__c(
            ONE_Request__c = request,
            ONE_Response__c = logMap.length() > 131071 ? logMap.substring(0, 131071) : logMap,
            ONE_Endpoint__c = 'Internal batch process',
            ONE_ClassName__c = 'ONE_DeleteOldFilesBatch'
        );

        insert log;

        // Create log email attachment

        Blob fileBody = Blob.valueOf(logMap);
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('log_batch.txt');
        attachment.setBody(fileBody);
        attachment.setContentType('text/plain');

        // Set email

        Decimal totalSizeInMB = (totalSize / 1048576.0).setScale(2); // Bytes to MB

        String subject = 'Resultado del batch ONE_DeleteOldFilesBatch';
        String body = 'Batch finalizado.\n\n' +
                      'Total encontrados: ' + totalRecords + '\n' +
                      'TOTAL ELIMINADOS (relacionados a Tareas/Servicios): ' + deletedRecords + '\n';

        body += '\nEn total se han eliminado un total de ' + totalSizeInMB + ' MB.\n';

        if (!errorMessages.isEmpty()) {
            body += '\nErrores encontrados:\n' + String.join(errorMessages, '\n');
        } else {
            body += '\nBatch ejecutado correctamente sin errores.';
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        // Set email adresses from public group
        List<String> emails = new List<String>();

        List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName = 'ONE_Salesforce_Admins' LIMIT 1];

        if (!groups.isEmpty()) {
            Group g = groups[0];

            List<GroupMember> members = [
                SELECT UserOrGroupId, UserOrGroup.Email 
                FROM GroupMember 
                WHERE GroupId = :g.Id
            ];
    
            for (GroupMember gm : members) {
                if (gm.UserOrGroup.Email != null) emails.add(gm.UserOrGroup.Email);
            }
            
        } else {
            errorMessages.add('No existe el Public Group');
            System.debug('No existe el Public Group');
        }

        if (!emails.isEmpty()) {
            mail.setToAddresses(emails);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
}
/**
 * Created by bjaworski002 on 24.01.2022.
 */

public with sharing class ONE_ContentDocumentLinkSelector {

    public static ContentDocumentLink fetchContentForGeneralliByCasoId(Id casoId) {
        return [
            SELECT ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :casoId
                AND ContentDocument.LatestPublishedVersion.ONE_PDF_Compania__c = TRUE
            LIMIT 1
        ];
    }
}
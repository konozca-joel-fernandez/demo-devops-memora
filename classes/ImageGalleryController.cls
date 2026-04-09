public without sharing class ImageGalleryController  {

    public class Image {

        @AuraEnabled
        public Id id { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String url { get; set; }

        public Image(Id id, String title, String url) {
            this.id = id;
            this.title = title;
            this.url = url;
        }
    }

    @AuraEnabled
    public static String getFileURL(Id fileId) {

        String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
        //fileURL = fileURL.replace('visualforce.com','documentforce.com');
        fileURL += '/sfc/servlet.shepherd/version/download/' + fileId;

        return fileURL;
    }

    @AuraEnabled
    public static List<Image> getImages(String documentoId, String servicioId, String region, String imageType) {

        List<Image> imageList = new List<Image>();

        List<ContentVersion> cvList = new List<ContentVersion>();

        if (imageType == 'anverso') {
            cvList = [  SELECT Id, Title
                        FROM ContentVersion
                        WHERE ImagenParaRecordatorio__c = true
                        AND ImagenInteriorRecordatorio__c = false
                        AND CodigoQR__c = false
                        AND (FirstPublishLocationId = :documentoId OR FirstPublishLocationId = :UserInfo.getOrganizationId())
                        WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC];
        }
        else if (imageType == 'interior') {
            cvList = [  SELECT Id, Title
                        FROM ContentVersion
                        WHERE ImagenParaRecordatorio__c = false
                        AND ImagenInteriorRecordatorio__c = true
                        AND CodigoQR__c = false
                        AND (FirstPublishLocationId = :documentoId OR FirstPublishLocationId = :UserInfo.getOrganizationId())
                        WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC];
        }
        else if (imageType == 'codigoQR') {
            
			List<Id> cvIdList = new List<Id>();
			for (ContentDocumentLink cdl : [SELECT ContentDocument.LatestPublishedVersionId from contentdocumentlink where LinkedEntityId = :servicioId OR LinkedEntityId = :documentoId]) {
				cvIdList.add(cdl.ContentDocument.LatestPublishedVersionId);
			}
            cvList = [  SELECT Id, Title
                        FROM ContentVersion
                        WHERE ImagenParaRecordatorio__c = false
                        AND ImagenInteriorRecordatorio__c = false
                        AND CodigoQR__c = true
                      	AND Id IN :cvIdList
                        AND (FirstPublishLocationId = :servicioId OR FirstPublishLocationId = :UserInfo.getOrganizationId())
                      	WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC];
        }


        for (ContentVersion cv : cvList ) {
            imageList.add(new Image(cv.Id, cv.Title, getFileURL(cv.Id)));
            system.debug(cv);
        }

        return imageList;
    }

    @AuraEnabled
    public static void updateImageTitle(String documentoId, String imageId, String title, String imageType) {

        ContentVersion uploadedImage = new ContentVersion(Id = imageId);
        uploadedImage.Title = title;
        if (imageType == 'anverso') {
            uploadedImage.ImagenParaRecordatorio__c = true;
        }
        else if (imageType == 'interior') {
            uploadedImage.ImagenInteriorRecordatorio__c = true;
        }
        else if (imageType == 'codigoQR') {
            uploadedImage.CodigoQR__c = true;
            uploadedImage.Title = 'Código QR';
        }
        if (ContentVersion.sObjectType.getDescribe().isUpdateable()) {
            update uploadedImage;
        }
    }
    
}
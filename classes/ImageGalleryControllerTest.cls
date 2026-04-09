@isTest
public class ImageGalleryControllerTest {
    
    @testSetup
    private static void testSetup() {

    }
    
    @isTest
    public static void getImages() {

        Id recordatorioRecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Documentos__c', 'DOC018_Recordatorio');
        ONE_Documentos__c documento = new ONE_Documentos__c(RecordTypeId = recordatorioRecordTypeId);
        insert documento;
        ContentVersion cv = new ContentVersion(Title = 'ABC', ImagenParaRecordatorio__c = true, PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Test body'), FirstPublishLocationId = documento.Id);
        insert cv;
        String documentoId = documento.Id;
        String servicioId = '';
        String region = '';
        
        Test.startTest();
        String imageType = 'anverso';
        ImageGalleryController.getImages(documentoId, servicioId, region, imageType);
        
        imageType = 'interior';
        ImageGalleryController.getImages(documentoId, servicioId, region, imageType);
        
        imageType = 'codigoQR';
        ImageGalleryController.getImages(documentoId, servicioId, region, imageType);
        Test.stopTest();
    }
    
    @isTest
    public static void updateImageTitle() {

        ContentVersion cv = new ContentVersion(Title = 'ABC', PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Test body'));
        insert cv;
        String documentoId = '';
        String imageId = cv.Id;
        String title = 'ABC';
        
        Test.startTest();
        String imageType = 'anverso';
        ImageGalleryController.updateImageTitle(documentoId, imageId, title, imageType);
        
        imageType = 'interior';
        ImageGalleryController.updateImageTitle(documentoId, imageId, title, imageType);
        
        imageType = 'codigoQR';
        ImageGalleryController.updateImageTitle(documentoId, imageId, title, imageType);
        Test.stopTest();
    }
}
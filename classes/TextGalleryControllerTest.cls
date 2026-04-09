@isTest
public class TextGalleryControllerTest {
    
    @isTest
    public static void getTexts() {
        
        Test.startTest();
        TextGalleryController.getTexts('es', 'TextoRecordatorio4');
        Test.stopTest();
    }
}
@isTest
public class DisplayImageControllerTest {

    @isTest
    private static void test() {
        
        Test.startTest();
        DisplayImageController.getContentVersion(System.UserInfo.getUserId());
        Test.stopTest();
    }
}
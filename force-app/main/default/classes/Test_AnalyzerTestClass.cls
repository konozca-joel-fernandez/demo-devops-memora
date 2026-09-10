@isTest
private class Test_AnalyzerTestClass {
    
    @isTest
    static void testGoodPractices() {
        Test.startTest();
        AnalyzerTestClass.runGoodPractices();
        Test.stopTest();
        
    }
}
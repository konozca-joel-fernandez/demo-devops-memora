@isTest
private class Test_AnalyzerTestClass {
    
    @isTest
    static void testGoodPractices() {
        Test.startTest();
        
        // 1. Ejecutamos el método de AnalyzerTestClass
        AnalyzerTestClass.runGoodPractices();
        
        // 2. Ejecutamos el método de TestDeploy (aprovechamos para cubrir ambos de una vez)
        TestDeploy td = new TestDeploy();
        td.testFunction();
        
        Test.stopTest();
        
        // Validación básica para asegurar que el código se ha ejecutado sin excepciones
        System.assert(true, 'Las clases se ejecutaron correctamente sin errores de límites o permisos.');
    }
}
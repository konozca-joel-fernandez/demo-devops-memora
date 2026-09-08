/**
 * @description Clase de prueba con buenas prácticas de Apex.
 */
public with sharing class AnalyzerTestClass {
    /**
     * @description Ejecuta consultas de forma limpia, bulkificada y segura.
     */
    public static void runGoodPractices() {
        // 1. Consulta fuera del bucle, sin ID hardcodeado y en modo usuario
        List<Account> accs = [SELECT Id, Name FROM Account WITH USER_MODE LIMIT 5];
        Set<String> nameSet = new Set<String>();

        // 2. Uso explícito de la variable para evitar el warning de variable no usada
        System.debug('Total de cuentas encontradas: ' + accs.size());

        // 3. Iteración en memoria sobre los registros recuperados
        for (Account acc : accs) {
            System.debug('Procesando cuenta: ' + acc.Name);
            nameSet.add(acc.Name);
        }
    }
}
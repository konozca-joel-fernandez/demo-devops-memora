@IsTest
private class ONE_MarcadorPuntosColocacionTest {

    @testSetup
    static void setupData() {
        ONE_Expediente__c expediente = new ONE_Expediente__c(
        );
        insert expediente;

        // Linea de expediente (SLI)
        ONE_Expediente_Line_Item__c sli = new ONE_Expediente_Line_Item__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Numero_SLI__c = 1
        );
        insert sli;

        // Tarea
        ONE_Tarea__c tarea = new ONE_Tarea__c(
            Name = 'Tarea Test',
            ONE_Linea_De_Expediente__c = sli.Id
        );
        insert tarea;

        // Punto válido y seleccionado
        ONE_Punto_de_Colocacion__c puntoActivo = new ONE_Punto_de_Colocacion__c(
            Name = 'Punto Activo',
            ONE_Linea_de_servicio__c = sli.Id,
            ONE_Seleccionado__c = true,
            ONE_Invalido__c = false,
            ONE_Colocado__c = true,
            ONE_Direccion__c = 'Calle 1',
            ONE_Municipio__c = 'Madrid',
            ONE_Provincia_picklist__c = '08'
        );

        // Punto histórico (inválido)
        ONE_Punto_de_Colocacion__c puntoHistorico = new ONE_Punto_de_Colocacion__c(
            Name = 'Punto Histórico',
            ONE_Linea_de_servicio__c = sli.Id,
            ONE_Seleccionado__c = true,
            ONE_Invalido__c = true,
            ONE_Colocado__c = false,
            ONE_Direccion__c = 'Calle 2',
            ONE_Municipio__c = 'Madrid',
            ONE_Provincia_picklist__c = '08'
        );

        insert new List<ONE_Punto_de_Colocacion__c>{ puntoActivo, puntoHistorico };
    }

    @IsTest
    static void testGetPuntosDeColocacion() {
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c LIMIT 1];

        Test.startTest();
        List<ONE_Punto_de_Colocacion__c> result =
            ONE_MarcadorPuntosColocacionController.getPuntosDeColocacion(tarea.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Punto Activo', result[0].Name);
    }

    @IsTest
    static void testGetPuntosDeColocacionHistorial() {
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c LIMIT 1];

        Test.startTest();
        List<ONE_Punto_de_Colocacion__c> result =
            ONE_MarcadorPuntosColocacionController.getPuntosDeColocacionHistorial(tarea.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Punto Histórico', result[0].Name);
    }

    @IsTest
    static void testExistenReseteados_true() {
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c LIMIT 1];

        Test.startTest();
        Boolean existen =
            ONE_MarcadorPuntosColocacionController.existenReseteados(tarea.Id);
        Test.stopTest();

        System.assertEquals(true, existen);
    }

    @IsTest
    static void testResetearPuntos() {
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c LIMIT 1];

        Test.startTest();
        ONE_MarcadorPuntosColocacionController.resetearPuntos(tarea.Id);
        Test.stopTest();

        // Original debe quedar invalidado
        List<ONE_Punto_de_Colocacion__c> invalidados = [
            SELECT Id FROM ONE_Punto_de_Colocacion__c
            WHERE ONE_Invalido__c = true
        ];
        System.assert(invalidados.size() >= 2);

        // Copia nueva debe existir y no estar colocada
        List<ONE_Punto_de_Colocacion__c> nuevos = [
            SELECT Id, ONE_Colocado__c, ONE_Invalido__c
            FROM ONE_Punto_de_Colocacion__c
            WHERE ONE_Invalido__c = false
        ];
        System.assertEquals(1, nuevos.size());
    }
}
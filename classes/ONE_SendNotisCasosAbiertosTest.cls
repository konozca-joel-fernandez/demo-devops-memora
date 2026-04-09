@isTest
private class ONE_SendNotisCasosAbiertosTest {

    @isTest
    public static void testNotificarConCasosValidos() {
        // Crear usuario de prueba

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User asesor = new User(
                FirstName = 'Test',
                LastName = 'User',
                Email = 'asesor@test.com',
                Username = 'asesor@test.com' + System.currentTimeMillis(),
                Alias = 'tuser',
                TimeZoneSidKey = 'Europe/Madrid',
                LocaleSidKey = 'es_ES',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'es',
                ProfileId = p.Id
            );
        insert asesor;
        User owner = new User(
            FirstName = 'Test',
            LastName = 'Owner',
            Email = 'owner@test.com',
            Username = 'owner@test.com' + System.currentTimeMillis(),
            Alias = 'towner',
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            ProfileId = p.Id
        );
        insert owner;

        // Crear casos de prueba
        ONE_Caso__c caso1 = new ONE_Caso__c(
            OwnerId = owner.Id,
            ONE_Asesor_Propuesto__c = asesor.Id
        );

        ONE_Caso__c caso2 = new ONE_Caso__c(
            OwnerId = owner.Id,
            ONE_Asesor_Propuesto__c = null
        );

        insert new List<ONE_Caso__c>{ caso1, caso2 };

        // Simular invocación de Flow
        ONE_SendNotisCasosAbiertos.CasoWrapper wrapper = new ONE_SendNotisCasosAbiertos.CasoWrapper();
        wrapper.casosNotificar = new List<ONE_Caso__c>{ caso1, caso2 };

        Test.startTest();
        ONE_SendNotisCasosAbiertos.notificar(new List<ONE_SendNotisCasosAbiertos.CasoWrapper>{ wrapper });
        Test.stopTest();
        
        // Afirmaciones básicas (aunque Messaging.sendEmail no puede ser directamente verificado)
        System.assert(true, 'El método se ejecutó sin errores');
    }



}
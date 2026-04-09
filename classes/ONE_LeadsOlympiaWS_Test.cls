@isTest
private class ONE_LeadsOlympiaWS_Test {

    // Mock para simular la respuesta HTTP del callout
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"resultado":"ok"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testEnviarPostSuccess() {
        // Insertar datos relacionados
        Account contacto = new Account(
            FirstName = 'Prueba',
            LastName = 'Conrtacto',
            Phone = '123456789',
            RecordTypeId = [ SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Persona Particular' LIMIT 1].Id
        );
        insert contacto;

        Account cuenta = new Account(Name = 'Cuenta Prueba');
        insert cuenta;

        
        User prescriptor = new User(
            Username = 'prescriptor@pr.pr',
            LastName = 'Prueba pruebez',
            Alias = 'aaa',
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            ProfileId = [SELECT Id FROM Profile LIMIT 1].Id,
            Email = 'angel.franco@konozca.com',
            Title = 'Director',
            Department = 'Ventas'
        );
        insert prescriptor;

        // Gerencia
      //  ONE_Gerencia__c gerencia = new ONE_Gerencia__c(Name = 'Gerencia Test');
        //insert gerencia;

        // Oportunidad
        ONE_Oportunidad__c opp = new ONE_Oportunidad__c(
            ONE_Contacto__c = contacto.Id,
            ONE_Prescriptor__c = prescriptor.Id,
            //ONE_Gerencia__c = gerencia.Id,
            ONE_Localizacion_puesto__c = 'Barcelona',
            ONE_Destinatario_s_de_la_informaci_n__c = 'Destinatario X',
            ONE_Observaciones__c = 'Sin observaciones'
        );
        insert opp;

        // Preparar input
        ONE_LeadsOlympiaWS.RequestInput input = new ONE_LeadsOlympiaWS.RequestInput();
        input.opportunityId = opp.Id;
        List<ONE_LeadsOlympiaWS.RequestInput> inputs = new List<ONE_LeadsOlympiaWS.RequestInput>{input};

        // Configurar el mock HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        List<ONE_LeadsOlympiaWS.ResponseOutput> result = ONE_LeadsOlympiaWS.enviarPost(inputs);
        Test.stopTest();

        // Verificaciones
        System.assertEquals(1, result.size(), 'Debe haber una respuesta');
        System.assertEquals(true, result[0].success, 'La respuesta debe ser success=true');
    }

    @isTest
    static void testEnviarPostFailsWithException() {
        // No insertamos oportunidad válida para forzar error en el helper

        ONE_LeadsOlympiaWS.RequestInput input = new ONE_LeadsOlympiaWS.RequestInput();
        input.opportunityId = '006000000000001AAA'; // ID ficticio
        List<ONE_LeadsOlympiaWS.RequestInput> inputs = new List<ONE_LeadsOlympiaWS.RequestInput>{input};

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        List<ONE_LeadsOlympiaWS.ResponseOutput> result = ONE_LeadsOlympiaWS.enviarPost(inputs);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Debe haber una respuesta');
        System.assertEquals(false, result[0].success, 'Debe fallar y devolver success=false');
    }
}
@isTest
private class ONE_CBSA_ReservationControllerTest {

    @TestSetup
    static void setupData(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ONE_Person_Accout_Particular').getRecordTypeId();
        Account cementiri = new Account(
            ONE_Codigo_Cementerio_CB__c = '2',
            FirstName = 'Montjuic',
            LastName = 'Cementiri'
        );
        insert cementiri;    
        Account account = new Account(
            RecordTypeId = recordTypeId,
            FirstName = 'Luis',
            LastName = 'Test',
            ONE_Tipo_de_documento__pc = '97',
            ONE_N_Documento__pc = '87654321X',
            ONE_Nacionalidad__c = 'ES',
            ONE_Sexo__c = 'Hombre',
            ONE_Fecha_de_nacimiento__pc = Date.newInstance(1996, 12, 21),
            ONE_Pais__pc = 'ES',
            ONE_Provincia__pc = '28',
            ONE_Municipio__pc = 'BARCELONA',
            ONE_Codigo_postal__pc = '08001',
            ONE_Calle__pc = 'Calle de Test',
            Phone = '123456789',
            ONE_Numero_Calle__pc = '1',
            ONE_Piso_Calle__pc = '1',
            ONE_Puerta_Calle__pc = '1',
            ONE_Email__c = 'test@gmail.com'
        );
        insert account;
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__C = account.Id,
            ONE_Causas_Defuncion__c = 'Enfermedad',
            ONE_Fecha_De_Defuncion__c = DateTime.newInstance(2024, 10, 9, 15, 45, 0),
            ONE_Estado_Del_Difunto__c = 'O'
        );
        insert expediente;
    }
    
    @isTest
    static void testGetReservation() {
        Test.setMock(HttpCalloutMock.class, new MockCBSAHttpResponse());
    
        ONE_CBSA_ReservationController.FlowInputs input = new ONE_CBSA_ReservationController.FlowInputs();
        input.serviceId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        input.reservationType = 'I';
        input.cementerioInc = '2';
        input.llegadaDifunto = DateTime.newInstance(2025, 3, 30, 12, 45, 0);
        input.asistFam = 'S';
        input.inhumationDate = DateTime.newInstance(2025, 3, 31, 10, 0, 0);
    
        Test.startTest();
        List<ONE_CBSA_ReservationController.FlowOutputs> outputs =
            ONE_CBSA_ReservationController.getReservation(new List<ONE_CBSA_ReservationController.FlowInputs>{ input });
        Test.stopTest();
    
        System.assertEquals(1, outputs.size());
    }    
    
    @isTest
    static void testCancelReservation() {
        Test.setMock(HttpCalloutMock.class, new MockCBSAXHttpResponse());
    
        ONE_CBSA_ReservationController.FlowInputs input = new ONE_CBSA_ReservationController.FlowInputs();
        input.serviceId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        input.reservationType = 'X';
    
        Test.startTest();
        List<ONE_CBSA_ReservationController.FlowOutputs> outputs =
            ONE_CBSA_ReservationController.getReservation(new List<ONE_CBSA_ReservationController.FlowInputs>{ input });
        Test.stopTest();
    
        System.assertEquals(1, outputs.size());
    }

    private class MockCBSAHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{' +
                '"rcserial":324054,' +
                '"rcprosol":998,' +
                '"rcususol":"sfb-sa",' +
                '"rctipsol":"I",' +
                '"rcdifunt":1415003,' +
                '"rcnom":"LUIS",' +
                '"rccog1":"TEST",' +
                '"rcsexe":"M",' +
                '"rcjudicial":"N",' +
                '"rcpais":"ESPANYA",' +
                '"rcprovi":8,' +
                '"rcmunic":"BARCELONA",' +
                '"rccomnu":"N",' +
                '"rccaumor":"E",' +
                '"rcdatdef":"2024-10-09",' +
                '"rchordef":"15:45",' +
                '"rcestdif":"O",' +
                '"rcceminc":2,' +
                '"rcdatarr":"2025-03-30",' +
                '"rchorarr":"12:45",' +
                '"rcasistf":"S",' +
                '"rcdatinc":"2025-03-30",' +
                '"rchoricons":"10:36",' +
                '"rcestado":"C",' +
                '"missatges":"",' +
                '"rchorincdis":[{"horincdis":"12:45"},{"horincdis":"13:15"}],' +
                '"rchorinhdis":[{"horinhdis":"11:00"},{"horinhdis":"13:15"},{"horinhdis":"16:30"}]' +
            '}');
            return res;
        }
    }
        
    private class MockCBSAXHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{' +
                        '"rcserial":324054,' +
                        '"rcprosol":998,' +
                        '"rcususol":"sfb-sa",' +
                        '"rctipsol":"X",' +
                        '"rcdifunt":1415003,' +
                        '"rcestado":"C",' +
                        '"missatges":""' +
                        '}');
            return res;
        }
    }
}
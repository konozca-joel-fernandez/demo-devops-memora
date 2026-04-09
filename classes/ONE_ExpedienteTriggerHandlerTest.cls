@isTest
private class ONE_ExpedienteTriggerHandlerTest {

    @testSetup
    private static void setup() {

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id, Name = 'xxx'), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id, Name = 'xxx'), true);
        Account centro = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id, ONE_Creacion_automatica_LPs_futuras__c = true), true);
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = centro.Id), true);
    }

    @isTest
    private static void afterInsert() {

        Account difunto = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ONE_Person_Accout_Particular' LIMIT 1];
        Account centro = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ONE_Centro_Memora' LIMIT 1];

        Test.startTest();
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = centro.Id), true);
        Test.stopTest();
    }

    @isTest
    private static void afterUpdate() {

        Account difunto = [SELECT Id FROM Account LIMIT 1];
        Account difunto2 = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c WHERE ONE_Lugar_Superior__r.ONE_Lugar_Superior__c != null LIMIT 1];

        Account tanatorio = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio.Id);
        insert salaTanatorio;

        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio2 = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id);
        insert salaTanatorio2;

        Test.setMock(HttpCalloutMock.class, new Mock());

        servicio.ONE_Centro_Del_Expediente__c = tanatorio.Id;
        servicio.ONE_Difunto__c = difunto2.Id;
        servicio.ONE_Observaciones_Generales__c = 'x';
        servicio.ONE_Confirmada_Ceremonia_Externa__c = true;
        servicio.ONE_Velacion__c = true;
        servicio.ONE_Tipo_De_Lugar_De_Velacion__c = 'Interno';
        servicio.ONE_Lugar_De_Velacion__c = tanatorio.Id;
        servicio.ONE_Sala_De_Velacion__c = salaTanatorio.Id;
        servicio.ONE_Inicio_Velacion__c = Datetime.now();
        servicio.ONE_Fin_Velacion__c = Datetime.now();
        servicio.ONE_Ceremonia__c = true;
        servicio.ONE_Tipo_De_Lugar_De_Ceremonia__c = 'Interno';
        servicio.ONE_Lugar_Ceremonia__c = tanatorio.Id;
        servicio.ONE_Sala_Ceremonia__c = salaTanatorio.Id;
        servicio.ONE_Inicio_Ceremonia__c = Datetime.now();
        servicio.ONE_Fin_Ceremonia__c = Datetime.now();
        servicio.ONE_Incineracion__c = true;
        servicio.ONE_Tipo_De_Lugar_De_Incineracion__c = 'Interno';
        servicio.ONE_Lugar_Incineracion__c = tanatorio.Id;
        servicio.ONE_Inicio_Incineracion__c = Datetime.now();
        servicio.ONE_Fin_Incineracion__c = Datetime.now();
        servicio.ONE_Horno_Incineracion__c = salatanatorio.Id;
        servicio.ONE_Cementerio__c = true;
        servicio.ONE_Tipo_De_Lugar_Destino_Final__c = 'Interno';
        servicio.ONE_Destino_Final__c = tanatorio.Id;
        servicio.ONE_Hora_Destino_Final__c = Datetime.now();
        servicio.ONE_Origen_Del_Traslado__c = 'Depósito';
        servicio.ONE_Destino_Traslado__c = tanatorio.Id;
        servicio.ONE_Ambito_Traslado__c = 'Traslado provincial';
        servicio.ONE_Fecha_Salida_Traslado__c = Datetime.now();

        Test.startTest();
        update servicio;
        Test.stopTest();
    }

    @isTest
    private static void afterUpdate2() {

        Account difunto = [SELECT Id FROM Account LIMIT 1];
        Account difunto2 = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c WHERE ONE_Lugar_Superior__r.ONE_Lugar_Superior__c != null LIMIT 1];

        Account tanatorio = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio.Id);
        insert salaTanatorio;

        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio2 = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id);
        insert salaTanatorio2;

        Test.setMock(HttpCalloutMock.class, new Mock());

        servicio.ONE_Lugar_Ceremonia__c = tanatorio2.Id;
        servicio.ONE_Inicio_Ceremonia__c = Datetime.now() + 1;
        servicio.ONE_Fin_Ceremonia__c = Datetime.now() + 1;
        servicio.ONE_Inicio_Incineracion__c = Datetime.now() + 2;
        servicio.ONE_Fin_Incineracion__c = Datetime.now() + 2;
        
        Test.startTest();
        update servicio;
        Test.stopTest();
    }

    @isTest
    private static void afterUpdate3() {

        Account difunto = [SELECT Id FROM Account LIMIT 1];
        Account difunto2 = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c WHERE ONE_Lugar_Superior__r.ONE_Lugar_Superior__c != null LIMIT 1];

        Account tanatorio = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio.Id);
        insert salaTanatorio;

        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio2 = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id);
        insert salaTanatorio2;

        Test.setMock(HttpCalloutMock.class, new Mock());

        servicio.ONE_Hora_Destino_Final__c = Datetime.now() + 3;

        Test.startTest();
        update servicio;
        Test.stopTest();

        servicio.ONE_Licencia_Despachada__c = true;
        servicio.Numero_Sala_Velacion_Ext__c = '9';
        servicio.ONE_Fecha_Salida_Traslado__c = Datetime.now() + 4;

        update servicio;
    }

    @isTest
    private static void afterUpdate4() {

        Account difunto = [SELECT Id FROM Account LIMIT 1];
        Account difunto2 = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c WHERE ONE_Lugar_Superior__r.ONE_Lugar_Superior__c != null LIMIT 1];

        Account tanatorio = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio.Id);
        insert salaTanatorio;

        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Recursos_Internos__c salaTanatorio2 = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id);
        insert salaTanatorio2;

        Test.setMock(HttpCalloutMock.class, new Mock());

        servicio.ONE_Licencia_Despachada__c = true;
        servicio.Numero_Sala_Velacion_Ext__c = '9';
        servicio.ONE_Fecha_Salida_Traslado__c = Datetime.now() + 4;

        Test.startTest();
        update servicio;
        Test.stopTest();
    }

    //Response mockup for testing the call
    @TestVisible
    private class Mock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('authorize')) {
                response.setBody('{\n' +
                    '  "token": "df1574eb-ee2c-4873-9035-0800723b4ec2",\n' +
                    '  "provider": "thirdparty",\n' +
                    '  "announcements": []\n' +
                    '}'
                );
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else {
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('[\n' +
                    '    {\n' +
                    '        "id": 3804074,\n' +
                    '        "tasks": [\n' +
                    '            3822318,\n' +
                    '            3822319\n' +
                    '        ],\n' +
                    '        "isNew": true\n' +
                    '    }\n' +
                    ']'
                );
            }
            return response;
        }
    }
}
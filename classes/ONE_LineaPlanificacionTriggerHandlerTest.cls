//Test class for the Linea de Planificación handler
@IsTest
private class ONE_LineaPlanificacionTriggerHandlerTest {

    @testSetup
    private static void setup() {

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
		Account tanatorio = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 1', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Expediente__c servicio = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = tanatorio.Id), true);
        ONE_Recursos_Internos__c salaTanatorio = new ONE_Recursos_Internos__c(Name = 'Sala 1', RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio.Id);
        insert salaTanatorio;

        ONE_Caso__c caso = new ONE_Caso__c();
        insert caso;
        
        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 2', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'), true);
        ONE_Recursos_Internos__c salaTanatorio2 = new ONE_Recursos_Internos__c(Name = 'Sala 2', RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id);
        insert salaTanatorio2;
        ONE_Recursos_Internos__c salaTanatorio3 = new ONE_Recursos_Internos__c(Name = 'Sala 3', RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id, ONE_Sala_De_Ceremonia_Relacionada__c=salaTanatorio2.Id);
        insert salaTanatorio3;

        Test.setMock(HttpCalloutMock.class, new Mock());

        servicio.ONE_Observaciones_Generales__c = 'x';
        servicio.ONE_Confirmada_Ceremonia_Externa__c = true;
        servicio.ONE_Velacion__c = true;
        servicio.ONE_Tipo_De_Lugar_De_Velacion__c = 'Interno';
        servicio.ONE_Lugar_De_Velacion__c = tanatorio2.Id;
        servicio.ONE_Sala_De_Velacion__c = salaTanatorio3.Id;
        servicio.ONE_Inicio_Velacion__c = Datetime.now();
        servicio.ONE_Fin_Velacion__c = Datetime.now();
        servicio.ONE_Ceremonia__c = true;
        servicio.ONE_Tipo_De_Lugar_De_Ceremonia__c = 'Interno';
        servicio.ONE_Lugar_Ceremonia__c = tanatorio2.Id;
        servicio.ONE_Sala_Ceremonia__c = salaTanatorio2.Id;
        servicio.ONE_Inicio_Ceremonia__c = Datetime.now();
        servicio.ONE_Fin_Ceremonia__c = Datetime.now();
        servicio.ONE_Incineracion__c = true;
        servicio.ONE_Tipo_De_Lugar_De_Incineracion__c = 'Interno';
        servicio.ONE_Lugar_Incineracion__c = tanatorio.Id;
        servicio.ONE_Horno_Incineracion__c=salaTanatorio.Id;
        servicio.ONE_Inicio_Incineracion__c = Datetime.now();
        servicio.ONE_Fin_Incineracion__c = Datetime.now();
        servicio.ONE_Cementerio__c = true;
        servicio.ONE_Tipo_De_Lugar_Destino_Final__c = 'Interno';
        servicio.ONE_Destino_Final__c = tanatorio.Id;
        servicio.ONE_Hora_Destino_Final__c = Datetime.now();
        servicio.ONE_Origen_Del_Traslado__c = 'Depósito';
        servicio.ONE_Destino_Traslado__c = tanatorio.Id;
        servicio.ONE_Ambito_Traslado__c = 'Traslado provincial';
        servicio.ONE_Fecha_Salida_Traslado__c = Datetime.now();

        update servicio;

    }

    @isTest
    private static void updateLineaPlanificacion1() {

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Mock());

        ONE_LineaPlanificacion__c lineaPlanificacion = [SELECT Id FROM ONE_LineaPlanificacion__c LIMIT 1];

        //lineaPlanificacion.ONE_InicioTanatorio__c = Datetime.now() + 1;
        lineaPlanificacion.ONE_InicioCeremonia__c = Datetime.now() + 1;
        lineaPlanificacion.ONE_FinCeremonia__c = Datetime.now() + 25;
        lineaPlanificacion.ONE_CeremoniaConfirmada__c = false;
        lineaPlanificacion.ONE_ObservacionesGenerales__c = 'o';
        lineaPlanificacion.ONE_LicenciaEnterramiento__c = true;
        lineaPlanificacion.ONE_SalaVelacionExterna__c = '1';

        update lineaPlanificacion;

        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = Datetime.now() -1;

        update lineaPlanificacion;

        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'), true);
        ONE_Recursos_Internos__c salaTanatorio2 = new ONE_Recursos_Internos__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id);
        insert salaTanatorio2;

        ONE_Recursos_Internos__c salaTanatorio3 = new ONE_Recursos_Internos__c(Name = 'Sala 3', RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Recursos_Internos__c', 'ONE_Salas'), ONE_Centro__c = tanatorio2.Id, ONE_Sala_De_Ceremonia_Relacionada__c=salaTanatorio2.Id);
        insert salaTanatorio3;
        
        lineaPlanificacion.ONE_LugarDestinoFinal__c = tanatorio2.Id;
        lineaPlanificacion.ONE_LugarTanatorio__c = tanatorio2.Id;
        lineaPlanificacion.ONE_SalaTanatorio__c = salaTanatorio3.Id;
        update lineaPlanificacion;

        Test.stopTest();
    }

    @isTest
    private static void updateLineaPlanificacion2() {

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Mock());

        ONE_LineaPlanificacion__c lineaPlanificacion = [SELECT Id FROM ONE_LineaPlanificacion__c LIMIT 1];

        //lineaPlanificacion.ONE_InicioTanatorio__c = Datetime.now() + 1;
        lineaPlanificacion.ONE_InicioCeremonia__c = Datetime.now() + 1;
        lineaPlanificacion.ONE_FinCeremonia__c = Datetime.now() + 2;
        lineaPlanificacion.ONE_CeremoniaConfirmada__c = false;
        lineaPlanificacion.ONE_ObservacionesGenerales__c = 'o';
        lineaPlanificacion.ONE_LicenciaEnterramiento__c = true;

        update lineaPlanificacion;

        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = Datetime.now() -1;

        update lineaPlanificacion;

        Account tanatorio2 = [SELECT Id FROM Account WHERE Name = 'Centro 2' LIMIT 1];
        ONE_Recursos_Internos__c salaTanatorio3 = [SELECT Id FROM ONE_Recursos_Internos__c WHERE Name = 'Sala 3' LIMIT 1];

        lineaPlanificacion.ONE_LugarDestinoFinal__c = tanatorio2.Id;
        lineaPlanificacion.ONE_LugarTanatorio__c = tanatorio2.Id;
        lineaPlanificacion.ONE_SalaTanatorio__c = salaTanatorio3.Id;
        update lineaPlanificacion;

        Test.stopTest();
    }

    @isTest
    private static void updateLineaPlanificacion3() {

        Test.startTest();
        
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new Mock());

        servicio.ONE_Fecha_Salida_Traslado__c = Datetime.now()-1;

        update servicio;

        ONE_LineaPlanificacion__c lineaPlanificacion = [SELECT Id FROM ONE_LineaPlanificacion__c LIMIT 1];
        Account tanatorio2 = [SELECT Id FROM Account WHERE Name = 'Centro 2' LIMIT 1];
        ONE_Recursos_Internos__c salaTanatorio3 = [SELECT Id FROM ONE_Recursos_Internos__c WHERE Name = 'Sala 3' LIMIT 1];

        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = Datetime.now() - 2;
        lineaPlanificacion.ONE_LugarDestinoFinal__c = tanatorio2.Id;
        lineaPlanificacion.ONE_LugarTanatorio__c = tanatorio2.Id;
        lineaPlanificacion.ONE_SalaTanatorio__c = salaTanatorio3.Id;

        update lineaPlanificacion;

        Test.stopTest();
    }

    @isTest
    private static void updateLineaPlanificacion4() {
		
        Test.startTest();
        
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new Mock());

        servicio.ONE_Hora_Destino_Final__c = Datetime.now()- 3;

        update servicio;

        ONE_LineaPlanificacion__c lineaPlanificacion = [SELECT Id FROM ONE_LineaPlanificacion__c LIMIT 1];
        Account tanatorio2 = [SELECT Id FROM Account WHERE Name = 'Centro 2' LIMIT 1];
        ONE_Recursos_Internos__c  salaTanatorio3= [SELECT Id FROM ONE_Recursos_Internos__c WHERE Name = 'Sala 3' LIMIT 1];

        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = Datetime.now() -1;
        lineaPlanificacion.ONE_LugarDestinoFinal__c = tanatorio2.Id;
        lineaPlanificacion.ONE_LugarTanatorio__c = tanatorio2.Id;
        lineaPlanificacion.ONE_SalaTanatorio__c = salaTanatorio3.Id;

        update lineaPlanificacion;

        Test.stopTest();
    }
    
    @isTest
    private static void updateLineaPlanificacion5() {
		
        Test.startTest();

        ONE_LineaPlanificacion__c lineaPlanificacion = [SELECT Id FROM ONE_LineaPlanificacion__c LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new Mock());

        lineaPlanificacion.ONE_FechaProgramada__c = Date.today();
        lineaPlanificacion.ONE_HoraProgramada__c = '12:00';

        update lineaPlanificacion;

        Test.stopTest();
    }

    @isTest
    private static void updateLineaPlanificacion6() {
		
        Test.startTest();

        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
                
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        servicio.ONE_Cementerio__c = false;
        servicio.ONE_Incineracion__c = false;
        update servicio;

        ONE_LineaPlanificacion__c lineaPlanificacion = new ONE_LineaPlanificacion__c();
        lineaPlanificacion.ONE_Servicio__c = servicio.Id;
        lineaPlanificacion.ONE_CreadoManualmente__c = true;
        lineaPlanificacion.ONE_PrimerEventoDiaManual__c = Datetime.now();

        insert lineaPlanificacion;

        Account tanatorio3 = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 3', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'), true);

        lineaPlanificacion.ONE_InicioCeremonia__c = Datetime.now() + 5;
        lineaPlanificacion.ONE_FinCeremonia__c = Datetime.now() + 6;
        lineaPlanificacion.ONE_LugarCeremonia__c = tanatorio3.Id;
        lineaPlanificacion.ONE_ObservacionesGenerales__c = 'qwe';
        lineaPlanificacion.ONE_LugarTanatorio__c = tanatorio3.Id;
        //lineaPlanificacion.ONE_InicioTanatorio__c = Datetime.now() + 7;
        //lineaPlanificacion.ONE_FechaHoraInhumacion__c = Datetime.now() + 8;
        //lineaPlanificacion.ONE_FechaHoraIncineracion__c = Datetime.now() + 9;
        lineaPlanificacion.ONE_LugarDestinoFinal__c = tanatorio3.Id;
        lineaPlanificacion.ONE_CeremoniaConfirmada__c = true;
        lineaPlanificacion.ONE_LicenciaEnterramiento__c = true;
        lineaPlanificacion.ONE_Zona_Operativa_Centro__c='ZONA';

        update lineaPlanificacion;

        Test.stopTest();
    }

    @isTest
    private static void updateLineaPlanificacion7() {
		
        Test.startTest();

        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
                
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        servicio.ONE_Incineracion__c = false;
        update servicio;

        ONE_LineaPlanificacion__c lineaPlanificacion = new ONE_LineaPlanificacion__c();
        lineaPlanificacion.ONE_Servicio__c = servicio.Id;
        lineaPlanificacion.ONE_CreadoManualmente__c = true;
        lineaPlanificacion.ONE_PrimerEventoDiaManual__c = Datetime.now();

        insert lineaPlanificacion;

        Account tanatorio3 = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 3', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'), true);

        lineaPlanificacion.ONE_InicioCeremonia__c = Datetime.now() + 5;
        lineaPlanificacion.ONE_FinCeremonia__c = Datetime.now() + 6;
        lineaPlanificacion.ONE_LugarCeremonia__c = tanatorio3.Id;
        lineaPlanificacion.ONE_ObservacionesGenerales__c = 'qwe';
        lineaPlanificacion.ONE_LugarTanatorio__c = tanatorio3.Id;
        //lineaPlanificacion.ONE_InicioTanatorio__c = Datetime.now() + 7;
        //lineaPlanificacion.ONE_FechaHoraInhumacion__c = Datetime.now() + 9;
        //lineaPlanificacion.ONE_FechaHoraIncineracion__c = Datetime.now() + 8;
        lineaPlanificacion.ONE_LugarDestinoFinal__c = tanatorio3.Id;
        lineaPlanificacion.ONE_CeremoniaConfirmada__c = true;
        lineaPlanificacion.ONE_LicenciaEnterramiento__c = true;

        update lineaPlanificacion;

        Test.stopTest();
    }
   
    @isTest
    private static void deleteLineaPlanificacion() {
		      
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Mock());

        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        ONE_LineaPlanificacion__c lineaPlanificacion = [SELECT Id FROM ONE_LineaPlanificacion__c WHERE ONE_Servicio__c = :servicio.Id LIMIT 1];
        ONE_Tarea__c tarea1 = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Tarea__c', 'ONE_Tarea_De_Conduccion'), Name = 'Tarea de conducción', ONE_Expediente__c = servicio.Id, ONE_TareaActualizada__c = true), true);
        ONE_Tarea__c tarea2 = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Tarea__c', 'ONE_Tarea_De_Conduccion'), Name = 'Tarea de conducción', ONE_Expediente__c = servicio.Id, ONE_TareaActualizada__c = true), true);
        ONE_Tarea__c tarea3 = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Tarea__c', 'ONE_Tarea_De_Conduccion'), Name = 'Tarea de conducción', ONE_Expediente__c = servicio.Id, ONE_TareaActualizada__c = true), true);
        lineaPlanificacion.ONE_TareaConduccion1__c = tarea1.Id;
        lineaPlanificacion.ONE_TareaConduccion2__c = tarea2.Id;
        lineaPlanificacion.ONE_TareaConduccion3__c = tarea3.Id;
        
        update lineaPlanificacion;
        
        delete lineaPlanificacion;

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
@IsTest
private class ONE_TareaTriggerHandlerTest {
    private static final String USERNAME = 'username';
    private static final String PASSWORD = 'password';
    private static final String PROVIDER = 'provider';
    private static final String ID = '1324';
    private static final String TASK_ORIGIN = '43435';
    private static final String TASK_DESTINATION = '43243';
    
    @TestSetup
    private static void setup() {
        ONE_FrotcomCredentials__c cs = new ONE_FrotcomCredentials__c(ONE_Username__c = USERNAME, ONE_Password__c = PASSWORD,
            ONE_Provider__c = PROVIDER);
        insert cs;

        ONE_FuneflorIntegrationCredentials__c funeflorCredentials = new ONE_FuneflorIntegrationCredentials__c(ONE_Token__c = 'token');
        insert funeflorCredentials;

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account centro = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id), true);
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = centro.Id), true);
    }
    
    @IsTest
    private static void conduccionTaskSentAfterInsert() {
        Test.setMock(HttpCalloutMock.class, new Mock());

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c];
        
        Test.startTest();
        
        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_CONDUCCION)),
            true);
        
        Test.stopTest();
        
        tarea = [
            SELECT Id,ONE_ID_Tarea_Frotcom__c,ONE_ID_Task_Frotcom_Destino__c,ONE_ID_Task_Frotcom_Origen__c
            FROM ONE_Tarea__c
            WHERE Id = :tarea.Id
        ];
        System.assertEquals(ID, tarea.ONE_ID_Tarea_Frotcom__c);
        System.assertEquals(TASK_ORIGIN, tarea.ONE_ID_Task_Frotcom_Origen__c);
        System.assertEquals(TASK_DESTINATION, tarea.ONE_ID_Task_Frotcom_Destino__c);
    }
    
    @IsTest
    private static void conduccionTaskNotSentAfterUpdate() {
        Test.setMock(HttpCalloutMock.class, new Mock());

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c];
        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_CONDUCCION)),
            true);
        
        Test.startTest();
        
        tarea.ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION;
        update tarea;
        
        Test.stopTest();
    
        tarea = [
            SELECT Id,ONE_ID_Tarea_Frotcom__c,ONE_ID_Task_Frotcom_Destino__c,ONE_ID_Task_Frotcom_Origen__c
            FROM ONE_Tarea__c
            WHERE Id = :tarea.Id
        ];
        System.assertEquals(ID, tarea.ONE_ID_Tarea_Frotcom__c);
        System.assertEquals(TASK_ORIGIN, tarea.ONE_ID_Task_Frotcom_Origen__c);
        System.assertEquals(TASK_DESTINATION, tarea.ONE_ID_Task_Frotcom_Destino__c);
    }
    
    @IsTest
    private static void vehiculoWithConduccionTipoDeRecursoTaskSentAfterInsert() {
        Test.setMock(HttpCalloutMock.class, new Mock());

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c];
        
        Test.startTest();
        
        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_VEHICULO_DE_ACOMPANIAMIENTO),
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION,
            ONE_Tipo_De_Traslado__c = 'Por tarea'),
            true);
        
        Test.stopTest();
    
        tarea = [
            SELECT Id,ONE_ID_Tarea_Frotcom__c,ONE_ID_Task_Frotcom_Destino__c,ONE_ID_Task_Frotcom_Origen__c
            FROM ONE_Tarea__c
            WHERE Id = :tarea.Id
        ];
        System.assertEquals(ID, tarea.ONE_ID_Tarea_Frotcom__c);
        System.assertEquals(TASK_ORIGIN, tarea.ONE_ID_Task_Frotcom_Origen__c);
        System.assertEquals(TASK_DESTINATION, tarea.ONE_ID_Task_Frotcom_Destino__c);
    }
    
    @IsTest
    private static void vehiculoWithProveedorTipoDeRecursoTaskNotSentAfterInsert() {
        Test.setMock(HttpCalloutMock.class, new Mock());

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c];
        
        Test.startTest();
        
        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_VEHICULO_DE_ACOMPANIAMIENTO),
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR),
            true);
        
        Test.stopTest();
    
        tarea = [
            SELECT Id,ONE_ID_Tarea_Frotcom__c,ONE_ID_Task_Frotcom_Destino__c,ONE_ID_Task_Frotcom_Origen__c
            FROM ONE_Tarea__c
            WHERE Id = :tarea.Id
        ];
        System.assertEquals(null, tarea.ONE_ID_Tarea_Frotcom__c);
        System.assertEquals(null, tarea.ONE_ID_Task_Frotcom_Origen__c);
        System.assertEquals(null, tarea.ONE_ID_Task_Frotcom_Destino__c);
    }
    
    @IsTest
    private static void vehiculoTaskSentWhenTipDeRecursoUpdatedToConduccion() {
        Test.setMock(HttpCalloutMock.class, new Mock());

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c];
        
        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_VEHICULO_DE_ACOMPANIAMIENTO),
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION),
            true);
        
        Test.startTest();
        
        tarea.ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION;
        update tarea;
        
        Test.stopTest();
    
        tarea = [
            SELECT Id,ONE_ID_Tarea_Frotcom__c,ONE_ID_Task_Frotcom_Destino__c,ONE_ID_Task_Frotcom_Origen__c
            FROM ONE_Tarea__c
            WHERE Id = :tarea.Id
        ];
        System.assertEquals(ID, tarea.ONE_ID_Tarea_Frotcom__c);
        System.assertEquals(TASK_ORIGIN, tarea.ONE_ID_Task_Frotcom_Origen__c);
        System.assertEquals(TASK_DESTINATION, tarea.ONE_ID_Task_Frotcom_Destino__c);
    }

    @IsTest
    private static void sendFuneflorPedidosTest() {

        Test.setMock(HttpCalloutMock.class, new Mock());

        Account funeflorAccount = ONE_TestDataFactory.createAccount(null, false);
        funeflorAccount.ONE_Metodo_De_Contacto_De_Proveedor__c = 'Aplicacion';
        funeflorAccount.ONE_Tipo_De_Aplicacion__c = 'Funeflor';
        funeflorAccount.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS);
        insert funeflorAccount;

        ONE_Expediente__c expediente = [SELECT Id, ONE_Centro_Del_Expediente__c FROM ONE_Expediente__c];

        Test.startTest();

        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_FLORES),
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION,
            ONE_Tipo_De_Traslado__c = 'Recogida'),
            false);
        tarea.ONE_Proveedor__c = funeflorAccount.Id;
        tarea.ONE_Cantidad__c = 12.5;
        tarea.ONE_Fecha_Y_Hora__c = Date.today();

        insert tarea;

        Test.stopTest();

        ONE_Tarea__c processedTarea = [SELECT ONE_Pedido_De_Proveedor__c FROM ONE_Tarea__c WHERE Id = :tarea.Id];
        ONE_Pedido_De_Proveedor__c pedido = [
            SELECT ONE_Ya_Procesado__c
            FROM ONE_Pedido_De_Proveedor__c
            WHERE Id = :processedTarea.ONE_Pedido_De_Proveedor__c
        ];
        Task pedidoTask = [SELECT Id, Subject, WhatId FROM TASK WHERE WhatId = :pedido.Id LIMIT 1];

        System.assertEquals(true, pedido.ONE_Ya_Procesado__c);
        System.assertEquals(pedido.Id, pedidoTask.WhatId);
        System.assertEquals(Label.OrderSentToFuneflor, pedidoTask.Subject);

    }
    
    @IsTest
    private static void notifyTareaConduccionErrorTest() {

        Test.setMock(HttpCalloutMock.class, new Mock());

        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account centro = ONE_TestDataFactory.createCentro(new Account(ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = centro.Id), true);

        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_CONDUCCION)),
            true);
        
        tarea = [
            SELECT ONE_EstadoAsignacionFrotcom__c, ONE_FechaHoraPlanificada__c
            FROM ONE_Tarea__c
            WHERE Id = :tarea.Id
        ];
        
        tarea.ONE_FechaHoraPlanificada__c = Datetime.now();
		tarea.ONE_EstadoAsignacionFrotcom__c = 'Error';
        
        Test.startTest();
        update tarea;
        Test.stopTest();
    }
    
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
                    '        "id": ' + ID + ',\n' +
                    '        "tasks": [\n' +
                                TASK_ORIGIN + ',\n' +
                                TASK_DESTINATION + '\n' +
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
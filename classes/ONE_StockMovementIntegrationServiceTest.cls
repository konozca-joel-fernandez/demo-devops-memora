@IsTest
public with sharing class ONE_StockMovementIntegrationServiceTest {

    @TestSetup
    private static void setup() {
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id), true);

        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(new ONE_Producto__c(
            Name = 'Test producto',
            ONE_Tipo_De_Producto__c = 'Producto comercial'
        ), true);

        ONE_Configuracion_De_Tarea__c configuracionDeTarea = ONE_TestDataFactory.createConfiguracionDeTarea(new ONE_Configuracion_De_Tarea__c(), true);

        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(
            ONE_Expediente__c = expediente.Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_ALMACEN),
            //ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION,
            //ONE_Tipo_De_Traslado__c = 'Recogida'
            ONE_Producto__c = producto.Id,
            ONE_Configuracion_De_Tarea__c = configuracionDeTarea.Id

        ),true);
    }

    @IsTest
    public static void invokeIntegrationOK() {
        Test.setMock(HttpCalloutMock.class, new StockMovementIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', '{"d":{"result":{"Result":"S"},"ReturnSet":{"results":[{"MessageV1":"test","MessageV2":"344test"}]}}}'));

        ONE_StockMovementIntegrationService.FlowInputs fi = new ONE_StockMovementIntegrationService.FlowInputs();

        ONE_Tarea__c tarea = [
                SELECT Id, ONE_Centro_De_Reserva__c, ONE_Ejercicio_Reserva_De_Material__c,
                    ONE_Numero_De_Reserva_De_Material__c, ONE_Proveedor_Consigna__c,
                    ONE_Processed_By_Batch__c, ONE_Almacen__c
                FROM ONE_Tarea__c
        ];

        fi.tareaId = tarea.Id;

        List<ONE_StockMovementIntegrationService.FlowOutputs> fo = null;

        Test.startTest();
        fo = ONE_StockMovementIntegrationService.invokeIntegration(
            new List<ONE_StockMovementIntegrationService.FlowInputs> { fi }
        );
        Test.stopTest();
    }

    @IsTest
    public static void invokeIntegrationKOv1() {
        Test.setMock(HttpCalloutMock.class, new StockMovementIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', '{"d":{"result":{"Result":"E"},"ReturnSet":{"results":[{"Type":"E","Message":"test"}]}}}'));

        ONE_StockMovementIntegrationService.FlowInputs fi = new ONE_StockMovementIntegrationService.FlowInputs();

        ONE_Tarea__c tarea = [
                SELECT Id, ONE_Centro_De_Reserva__c, ONE_Ejercicio_Reserva_De_Material__c,
                    ONE_Numero_De_Reserva_De_Material__c, ONE_Proveedor_Consigna__c,
                    ONE_Processed_By_Batch__c, ONE_Almacen__c
                FROM ONE_Tarea__c
        ];

        fi.tareaId = tarea.Id;

        List<ONE_StockMovementIntegrationService.FlowOutputs> fo = null;

        Test.startTest();
        fo = ONE_StockMovementIntegrationService.invokeIntegration(
            new List<ONE_StockMovementIntegrationService.FlowInputs> { fi }
        );
        Test.stopTest();
    }

    @IsTest
    public static void invokeIntegrationKOv2() {
        Test.setMock(HttpCalloutMock.class, new StockMovementIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', '{"error":{"innererror":{"errordetails":[{"message":"test"}]}}}'));

        ONE_StockMovementIntegrationService.FlowInputs fi = new ONE_StockMovementIntegrationService.FlowInputs();

        ONE_Tarea__c tarea = [
                SELECT Id, ONE_Centro_De_Reserva__c, ONE_Ejercicio_Reserva_De_Material__c,
                    ONE_Numero_De_Reserva_De_Material__c, ONE_Proveedor_Consigna__c,
                    ONE_Processed_By_Batch__c, ONE_Almacen__c
                FROM ONE_Tarea__c
        ];

        fi.tareaId = tarea.Id;

        List<ONE_StockMovementIntegrationService.FlowOutputs> fo = null;

        Test.startTest();
        fo = ONE_StockMovementIntegrationService.invokeIntegration(
            new List<ONE_StockMovementIntegrationService.FlowInputs> { fi }
        );
        Test.stopTest();
    }

    @TestVisible
    private class StockMovementIntegrationMock implements HttpCalloutMock {

        protected Integer code;
        protected String status;
        protected String body;

        public StockMovementIntegrationMock(Integer code, String status, String body) {

            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            res.setBody(this.body);
            return res;
        }
    }
}
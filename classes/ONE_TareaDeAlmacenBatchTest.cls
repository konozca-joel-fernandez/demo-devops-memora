//Test definiton for the tarea de almacen batch process
@isTest
public class ONE_TareaDeAlmacenBatchTest {
	//Static variable definition
    private static final String MATNR = '300005842';
    private static final String IZZAUFNR = 'PRUEBAS';
    private static final String IWERKS = '6095';
    private static final String IMEINS = 'UN';
    private static final Decimal IMENGE = 9;
    
	//Data builder for the test
    @TestSetup
    private static void setup() {
        
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        
        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
			ONE_Difunto__c = difunto.Id,
        	ONE_Centro_Del_Expediente__c = centro.Id), true);

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
	//Test batch process
    @IsTest
    public static void batchTest() {
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c];

        Test.setMock(HttpCalloutMock.class, new StockReservationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        Test.startTest();
        Id batchId = Database.executeBatch(new ONE_TareaDeAlmacenBatch(), 1);
        Test.stopTest();
 
        ONE_Tarea__c tarea = [
                SELECT Id, ONE_Centro_De_Reserva__c, ONE_Ejercicio_Reserva_De_Material__c,
                    ONE_Numero_De_Reserva_De_Material__c, ONE_Proveedor_Consigna__c,
                    ONE_Processed_By_Batch__c, ONE_Almacen__c
                FROM ONE_Tarea__c
        ];

        System.assertEquals('6095', tarea.ONE_Centro_De_Reserva__c);
        System.assertEquals('2020', tarea.ONE_Ejercicio_Reserva_De_Material__c);
        System.assertEquals('4900567239', tarea.ONE_Numero_De_Reserva_De_Material__c);
        System.assertEquals(null, tarea.ONE_Proveedor_Consigna__c);
        System.assertEquals('A001', tarea.ONE_Almacen__c);
        System.assertEquals(true, tarea.ONE_Processed_By_Batch__c);
    }
	//Response mockup for the stock reservation call
    @TestVisible
    private class StockReservationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public StockReservationMock(Integer code, String status, String body) {
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
	//Init response data 
    private static String prepareResponse() {
        ONE_SAPResponses.StockReservationResponse resp = new ONE_SAPResponses.StockReservationResponse();
        resp.IMatnr = MATNR;
        resp.IMeins = IMEINS;
        resp.IMenge = IMENGE;
        resp.IWerks = IWERKS;
        resp.IZzaufnr = IZZAUFNR;
        resp.ELgort = 'A001';
        resp.ELifnr = '';
        resp.EMblnr = '4900567239';
        resp.EMjahr = '2020';
        resp.EResult = 'S';
        resp.EWerks = '6095';
        resp.IXfuerzawerks = 'true';
        return JSON.serialize(new ONE_SAPResponses.StockReservationResponseWrapper(resp));
    }
}
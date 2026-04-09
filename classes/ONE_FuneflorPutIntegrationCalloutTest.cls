/**
 * Created by mkuzak001 on 08.02.2021.
 */

@IsTest
@TestVisible
private class ONE_FuneflorPutIntegrationCalloutTest {
    private static final Integer ID_LIN = 1;
    private static final String PEDIDO_NAME = 'Name';
    private static final String COMENTARIOS = 'comentarios';
    private static final String TOKEN = 'token';
    private static final Date FECHA = Date.today();
    
    @TestSetup
    private static void setup() {
        ONE_FuneflorIntegrationCredentials__c cs = new ONE_FuneflorIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs;
        
        ONE_FloresMemoraIntegrationCredentials__c cs2 = new ONE_FloresMemoraIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs2;
        
        ONE_MediagenIntegrationCredentials__c cs3 = new ONE_MediagenIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs3;
    }
    
    @IsTest
    public static void validationFailsWhenTareaPosicionPedidoIsEmpty() {

        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;

        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = null, ONE_Comentarios__c = COMENTARIOS, ONE_Expediente__c = expediente.Id);
        insert tarea;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expediente.Id, Name = PEDIDO_NAME);
        insert pedido;
        
        Exception exc;
        Test.startTest();
        
        try {
            ONE_FuneflorPutIntegrationCallout callout = new ONE_FuneflorPutIntegrationCallout(ONE_CommonConstants.CM_FUNEFLOR,
                ONE_Integration.RestMethod.POST, pedido, tarea);
        } catch (Exception ex) {
            exc = ex;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, exc);
        System.assert(exc instanceof ONE_FuneflorIntegrationCallout.ONE_FuneflorIntegrationCalloutException);
        System.assertEquals(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Tarea__c.ONE_Posicion_Pedido__c'}), exc.getMessage());
    }

    @IsTest
    public static void validationFailsWhenTareaPosicionPedidoIsEmpty2() {

        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;

        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = null, ONE_Comentarios__c = COMENTARIOS, ONE_Expediente__c = expediente.Id);
        insert tarea;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expediente.Id, Name = PEDIDO_NAME);
        insert pedido;
        
        Exception exc2;
        Test.startTest();

        try {
            ONE_FuneflorPutIntegrationCallout callout2 = new ONE_FuneflorPutIntegrationCallout(ONE_CommonConstants.CM_FLORESMEMORA,
                ONE_Integration.RestMethod.POST, pedido, tarea);
        } catch (Exception ex) {
            exc2 = ex;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, exc2);
        System.assert(exc2 instanceof ONE_FuneflorIntegrationCallout.ONE_FuneflorIntegrationCalloutException);
        System.assertEquals(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Tarea__c.ONE_Posicion_Pedido__c'}), exc2.getMessage());
    }
    
    @IsTest
    public static void validationFailsWhenTareaComentariosIsEmpty() {

        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;

        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Comentarios__c = null, ONE_Centro_De_Reserva__c = 'abc', ONE_Expediente__c = expediente.Id);
        insert tarea;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expediente.Id, Name = PEDIDO_NAME);
        insert pedido;
        
        Exception exc;
        Exception exc2;
        Test.startTest();
        
        try {
            ONE_FuneflorPutIntegrationCallout callout = new ONE_FuneflorPutIntegrationCallout(ONE_CommonConstants.CM_FUNEFLOR,
                ONE_Integration.RestMethod.POST, pedido, tarea);
        } catch (Exception ex) {
            exc = ex;
        }

        Test.stopTest();
        
        System.assertNotEquals(null, exc);
        System.assert(exc instanceof ONE_FuneflorIntegrationCallout.ONE_FuneflorIntegrationCalloutException);
        System.assertEquals(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Tarea__c.ONE_Comentarios__c'}), exc.getMessage());
    }

    @IsTest
    public static void validationFailsWhenTareaComentariosIsEmpty2() {

        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;

        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Comentarios__c = null, ONE_Centro_De_Reserva__c = 'abc', ONE_Expediente__c = expediente.Id);
        insert tarea;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expediente.Id, Name = PEDIDO_NAME);
        insert pedido;
        
        Exception exc;
        Exception exc2;
        Test.startTest();

        try {
            ONE_FuneflorPutIntegrationCallout callout2 = new ONE_FuneflorPutIntegrationCallout(ONE_CommonConstants.CM_FLORESMEMORA,
                ONE_Integration.RestMethod.POST, pedido, tarea);
        } catch (Exception ex) {
            exc2 = ex;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, exc2);
        System.assert(exc2 instanceof ONE_FuneflorIntegrationCallout.ONE_FuneflorIntegrationCalloutException);
        System.assertEquals(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Tarea__c.ONE_Comentarios__c'}), exc2.getMessage());
    }
    
    @IsTest
    public static void validationSuccessfulWhenAllNecessaryDataAreSet() {

        ONE_Expediente__c expedienteWithMomentos = new ONE_Expediente__c(
            ONE_Velacion__c = true,
            ONE_Ceremonia__c = true,
            ONE_Cementerio__c = true,
            ONE_Incineracion__c = true,
            ONE_Deposito__c = true,
            ONE_Despedida__c = true,
            ONE_Inicio_Velacion__c = FECHA,
            ONE_Inicio_Ceremonia__c = FECHA,
            ONE_Hora_Destino_Final__c = FECHA,
            ONE_Inicio_Incineracion__c = FECHA,
            ONE_Inicio_Deposito__c = FECHA,
            ONE_Inicio_Despedida__c = FECHA,
            ONE_Fin_Velacion__c = FECHA,
            ONE_Fin_Ceremonia__c = FECHA,
            ONE_Fin_Incineracion__c = FECHA,
            ONE_Fin_Deposito__c = FECHA,
            ONE_Fin_Despedida__c = FECHA
        );
        insert expedienteWithMomentos;

        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Comentarios__c = COMENTARIOS, ONE_Expediente__c = expedienteWithMomentos.Id);
        insert tarea;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expedienteWithMomentos.Id, Name = PEDIDO_NAME);
        insert pedido;
        
        Test.setMock(HttpCalloutMock.class, new FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
        
        Test.startTest();
    
        ONE_FuneflorPutIntegrationCallout callout = new ONE_FuneflorPutIntegrationCallout(ONE_CommonConstants.CM_FUNEFLOR,
            ONE_Integration.RestMethod.POST, pedido, tarea);
        HttpResponse res = callout.invokeCallout();
        
        Test.stopTest();
    
        System.assertEquals(ONE_CommonConstants.HTPP_SUCCESS_CODE, res.getStatusCode());
    }

    @IsTest
    public static void validationSuccessfulWhenAllNecessaryDataAreSet2() {
        
        ONE_Expediente__c expedienteWithMomentos = new ONE_Expediente__c(
            ONE_Velacion__c = true,
            ONE_Ceremonia__c = true,
            ONE_Cementerio__c = true,
            ONE_Incineracion__c = true,
            ONE_Deposito__c = true,
            ONE_Despedida__c = true,
            ONE_Inicio_Velacion__c = FECHA,
            ONE_Inicio_Ceremonia__c = FECHA,
            ONE_Hora_Destino_Final__c = FECHA,
            ONE_Inicio_Incineracion__c = FECHA,
            ONE_Inicio_Deposito__c = FECHA,
            ONE_Inicio_Despedida__c = FECHA,
            ONE_Fin_Velacion__c = FECHA,
            ONE_Fin_Ceremonia__c = FECHA,
            ONE_Fin_Incineracion__c = FECHA,
            ONE_Fin_Deposito__c = FECHA,
            ONE_Fin_Despedida__c = FECHA
        );
        insert expedienteWithMomentos;

        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Comentarios__c = COMENTARIOS, ONE_Expediente__c = expedienteWithMomentos.Id);
        insert tarea;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expedienteWithMomentos.Id, Name = PEDIDO_NAME);
        insert pedido;
        
        Test.setMock(HttpCalloutMock.class, new FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
        
        Test.startTest();

        ONE_FuneflorPutIntegrationCallout callout2 = new ONE_FuneflorPutIntegrationCallout(ONE_CommonConstants.CM_FLORESMEMORA,
            ONE_Integration.RestMethod.POST, pedido, tarea);
        HttpResponse res2 = callout2.invokeCallout();
        
        Test.stopTest();
    
        System.assertEquals(ONE_CommonConstants.HTPP_SUCCESS_CODE, res2.getStatusCode());
    }
    
    @TestVisible
    private class FuneflorIntegrationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected Map<String, String> responseHeaders;
        
        public FuneflorIntegrationMock(Integer code, String status, Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.responseHeaders = responseHeaders;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            return res;
        }
    }
    
    
}
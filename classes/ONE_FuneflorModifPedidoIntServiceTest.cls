/**
 * Created by mkuzak001 on 09.02.2021.
 */

@IsTest
private class ONE_FuneflorModifPedidoIntServiceTest {
    private static final Integer ID_LIN = 1;
    private static final String PEDIDO_NAME = 'Name';
    private static final String COMENTARIOS = 'comentarios';
    private static final String TOKEN = 'token';
    
    @TestSetup
    private static void setup() {
        ONE_FuneflorIntegrationCredentials__c cs = new ONE_FuneflorIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs;
        
		ONE_FloresMemoraIntegrationCredentials__c cs2 = new ONE_FloresMemoraIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs2;
    }
    
    @IsTest
    static void modificacionPedidoReturnsTrueWhenSuccessfulResponse() {
        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Comentarios__c = COMENTARIOS);
        insert tarea;
    
        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;
    
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expediente.Id, Name = PEDIDO_NAME);
        insert pedido;
    
        ONE_FuneflorIntegrationService.FlowInputs input = new ONE_FuneflorIntegrationService.FlowInputs();
        input.pedido = pedido;
        input.tarea = tarea;
        input.ContactMethod = ONE_CommonConstants.CM_FUNEFLOR;
        
        Test.setMock(HttpCalloutMock.class, new ONE_FuneflorPutIntegrationCalloutTest.FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
    
        Test.startTest();
    
        List<ONE_FuneflorIntegrationService.FlowOutputs> outputs = ONE_FuneflorModificacionPedidoIntService.modificacionPedido(
            new List<ONE_FuneflorIntegrationService.FlowInputs> {input}
        );
    
        Test.stopTest();
    
        System.assert(!outputs.isEmpty());
        System.assertEquals(1, outputs.size());
        ONE_FuneflorIntegrationService.FlowOutputs output = outputs[0];
        System.assert(output.success);
    }
    
        @IsTest
    static void modificacionPedidoReturnsTrueWhenSuccessfulResponse2() {
        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Comentarios__c = COMENTARIOS);
        insert tarea;
    
        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;
    
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expediente.Id, Name = PEDIDO_NAME);
        insert pedido;
    
        ONE_FuneflorIntegrationService.FlowInputs input = new ONE_FuneflorIntegrationService.FlowInputs();
        input.pedido = pedido;
        input.tarea = tarea;
        input.ContactMethod = ONE_CommonConstants.CM_FLORESMEMORA;
        
        Test.setMock(HttpCalloutMock.class, new ONE_FuneflorPutIntegrationCalloutTest.FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
    
        Test.startTest();
    
        List<ONE_FuneflorIntegrationService.FlowOutputs> outputs = ONE_FuneflorModificacionPedidoIntService.modificacionPedido(
            new List<ONE_FuneflorIntegrationService.FlowInputs> {input}
        );
    
        Test.stopTest();
    
        System.assert(!outputs.isEmpty());
        System.assertEquals(1, outputs.size());
        ONE_FuneflorIntegrationService.FlowOutputs output = outputs[0];
        System.assert(output.success);
    }
}
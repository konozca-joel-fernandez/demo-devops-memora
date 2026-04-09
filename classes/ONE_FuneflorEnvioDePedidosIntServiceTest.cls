/**
 * Created by mkuzak001 on 09.02.2021.
 */

 @IsTest
 private class ONE_FuneflorEnvioDePedidosIntServiceTest {
     private static final Integer ID_LIN = 1;
     private static final Decimal PEDVEN = 12.5;
     private static final Date FECENT = Date.today();
     private static final Date FECHA = Date.today();
     private static final String NAME = 'Name';
     private static final String TOKEN = 'token';
     
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
     private static void envioDePedidosReturnsTrueWhenSuccessfulResponse() {
 
         ONE_Expediente__c expediente = new ONE_Expediente__c();
         insert expediente;
 
         ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Cantidad__c = PEDVEN, ONE_Fecha_Y_Hora__c = FECENT, ONE_Expediente__c = expediente.Id);
         insert tarea;
     
         ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Fecha__c = FECHA, ONE_Expediente__c = expediente.Id, Name = NAME);
         insert pedido;
         
         ONE_FuneflorIntegrationService.FlowInputs input = new ONE_FuneflorIntegrationService.FlowInputs();
         input.pedido = pedido;
         input.tarea = tarea;
         input.ContactMethod = ONE_CommonConstants.CM_FUNEFLOR;
         
         Test.setMock(HttpCalloutMock.class, new ONE_FuneflorPostIntegrationCalloutTest.FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
             new Map<String, String>{}));
         
         Test.startTest();
         
         List<ONE_FuneflorIntegrationService.FlowOutputs> outputs = ONE_FuneflorEnvioDePedidosIntService.envioDePedidos(
              tarea, pedido, ONE_CommonConstants.CM_FUNEFLOR
         );
         
         Test.stopTest();
         
         System.assert(!outputs.isEmpty());
         System.assertEquals(1, outputs.size());
         ONE_FuneflorIntegrationService.FlowOutputs output = outputs[0];
         System.assert(output.success);
     }
     
     @IsTest
     private static void envioDePedidosReturnsTrueWhenSuccessfulResponse2() {
 
         ONE_Expediente__c expediente = new ONE_Expediente__c();
         insert expediente;
 
         ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Cantidad__c = PEDVEN, ONE_Fecha_Y_Hora__c = FECENT, ONE_Expediente__c = expediente.Id);
         insert tarea;
     
         ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Fecha__c = FECHA, ONE_Expediente__c = expediente.Id, Name = NAME);
         insert pedido;
         
         ONE_FuneflorIntegrationService.FlowInputs input = new ONE_FuneflorIntegrationService.FlowInputs();
         input.pedido = pedido;
         input.tarea = tarea;
         input.ContactMethod = ONE_CommonConstants.CM_FLORESMEMORA;
         
         Test.setMock(HttpCalloutMock.class, new ONE_FuneflorPostIntegrationCalloutTest.FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
             new Map<String, String>{}));
         
         Test.startTest();
         
         List<ONE_FuneflorIntegrationService.FlowOutputs> outputs = ONE_FuneflorEnvioDePedidosIntService.envioDePedidos(
              tarea, pedido, ONE_CommonConstants.CM_FUNEFLOR
         );
         
         Test.stopTest();
         
         System.assert(!outputs.isEmpty());
         System.assertEquals(1, outputs.size());
         ONE_FuneflorIntegrationService.FlowOutputs output = outputs[0];
         System.assert(output.success);
     }
     
     @IsTest
     private static void envioDePedidosReturnsTrueWhenSuccessfulResponse3() {
 
         ONE_Expediente__c expediente = new ONE_Expediente__c();
         insert expediente;
 
         ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Posicion_Pedido__c = ID_LIN, ONE_Cantidad__c = PEDVEN, ONE_Fecha_Y_Hora__c = FECENT, ONE_Expediente__c = expediente.Id);
         insert tarea;
     
         ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(ONE_Fecha__c = FECHA, ONE_Expediente__c = expediente.Id, Name = NAME);
         insert pedido;
         
         ONE_FuneflorIntegrationService.FlowInputs input = new ONE_FuneflorIntegrationService.FlowInputs();
         input.pedido = pedido;
         input.tarea = tarea;
         input.ContactMethod = ONE_CommonConstants.CM_MEDIAGEN;
         
         Test.setMock(HttpCalloutMock.class, new ONE_FuneflorPostIntegrationCalloutTest.FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
             new Map<String, String>{}));
         
         Test.startTest();
         
         List<ONE_FuneflorIntegrationService.FlowOutputs> outputs = ONE_FuneflorEnvioDePedidosIntService.envioDePedidos(
              tarea, pedido, ONE_CommonConstants.CM_MEDIAGEN
         );
         
         Test.stopTest();
         
         System.assert(!outputs.isEmpty());
         System.assertEquals(1, outputs.size());
         ONE_FuneflorIntegrationService.FlowOutputs output = outputs[0];
         System.assert(output.success);
     }
 }
/**
 * Created by mkuzak001 on 03.02.2021.
 */

public with sharing class ONE_FuneflorBorradoPedidoIntService extends ONE_FuneflorIntegrationService  {
    @InvocableMethod
    public static List<FlowOutputs> borradoPedido(List<FlowInputs> inputs) {
        FlowInputs input = inputs[0];
        ONE_Pedido_De_Proveedor__c pedido = input.pedido;
        ONE_Tarea__c tarea = input.tarea;
        String ContactMethod = input.ContactMethod;
    
        ONE_FuneflorDeleteIntegrationCallout callout = new ONE_FuneflorDeleteIntegrationCallout(ContactMethod,
            ONE_Integration.RestMethod.DEL, pedido);
    
        return invokeIntegration(callout);
    }
}
/**
 * Created by mkuzak001 on 03.02.2021.
 */

public with sharing class ONE_FuneflorModificacionPedidoIntService extends ONE_FuneflorIntegrationService {
    @InvocableMethod
    public static List<FlowOutputs> modificacionPedido(List<FlowInputs> inputs) {
        FlowInputs input = inputs[0];
        ONE_Pedido_De_Proveedor__c pedido = input.pedido;
        ONE_Tarea__c tarea = input.tarea;
        String ContactMethod = input.ContactMethod;
    
        ONE_FuneflorPutIntegrationCallout callout = new ONE_FuneflorPutIntegrationCallout(ContactMethod,
            ONE_Integration.RestMethod.PUT, pedido, tarea);
    
        System.debug('body ' + callout.body);
        System.debug('header ' + callout.headers);
    
        return invokeIntegration(callout);
    }
}
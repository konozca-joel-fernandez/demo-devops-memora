/**
 * Created by mkuzak001 on 03.02.2021.
 */

public with sharing class ONE_FuneflorEnvioDePedidosIntService extends ONE_FuneflorIntegrationService {

    public static List<FlowOutputs> envioDePedidos(ONE_Tarea__c tarea, ONE_Pedido_De_Proveedor__c pedido, String ContactMethod) {
        ONE_FuneflorPostIntegrationCallout callout = new ONE_FuneflorPostIntegrationCallout(ContactMethod,
                ONE_Integration.RestMethod.POST, pedido, tarea);

        return invokeIntegration(callout);
    }
}
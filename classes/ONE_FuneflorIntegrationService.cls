/**
 * Created by mkuzak001 on 02.02.2021.
 */

public with sharing abstract class ONE_FuneflorIntegrationService {
    
    public static List<FlowOutputs> invokeIntegration(ONE_FuneflorIntegrationCallout callout) {
        FlowOutputs output = new FlowOutputs();
        HttpResponse res = callout.invokeCallout();
        output.success = (res.getStatusCode() == ONE_CommonConstants.HTPP_SUCCESS_CODE);
        return new List<FlowOutputs>{output};
    }
    
    public class FlowInputs{
        @InvocableVariable
        public ONE_Pedido_De_Proveedor__c pedido;
        @InvocableVariable
        public ONE_Tarea__c tarea;
        @InvocableVariable
        public String ContactMethod;
    }
    
    public class FlowOutputs {
        @InvocableVariable
        public Boolean success;
    }
}
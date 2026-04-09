/**
 * Created by mkuzak001 on 09.02.2021.
 */

@IsTest
private class ONE_FuneflorBorradoPedidoIntServiceTest {
    public static final String PEDIDO_NAME = 'name';
    private static final String TOKEN = 'token';
    private static final String ID_CLI = '2';
    
    @TestSetup
    private static void setup() {
        ONE_FuneflorIntegrationCredentials__c cs = new ONE_FuneflorIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs;
                
        ONE_FloresMemoraIntegrationCredentials__c cs2 = new ONE_FloresMemoraIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs2;
    }
    
    @IsTest
    private static void borradoPedidoReturnsTrueWhenSuccessfulResponse() {
        Account sociedad2 = ONE_TestDataFactory.createAccount(
            new Account(ONE_Numero_Cliente_Funeflor__c = ID_CLI,
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_ACCOUNT_SOCIEDADES)
            ), true
        );
    
        Account centroDelExpediente = ONE_TestDataFactory.createAccount(
            new Account(ONE_Sociedad2__c = sociedad2.Id,
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA)
            ), true
        );
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(
            new ONE_Expediente__c(ONE_Centro_Del_Expediente__c = centroDelExpediente.Id), true
        );
        ONE_Pedido_De_Proveedor__c pedido = ONE_TestDataFactory.createPedidoDeProveedor(
            new ONE_Pedido_De_Proveedor__c(Name = PEDIDO_NAME, ONE_Expediente__c = expediente.Id), true
        );
        ONE_FuneflorIntegrationService.FlowInputs input = new ONE_FuneflorIntegrationService.FlowInputs();
        input.pedido = pedido;
        input.ContactMethod = ONE_CommonConstants.CM_FUNEFLOR;
        
        Test.setMock(HttpCalloutMock.class, new ONE_FuneflorDeleteIntegrationCalloutTest.FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
    
        Test.startTest();
    
        List<ONE_FuneflorIntegrationService.FlowOutputs> outputs = ONE_FuneflorBorradoPedidoIntService.borradoPedido(
            new List<ONE_FuneflorIntegrationService.FlowInputs> {input}
        );
    
        Test.stopTest();
        
        System.assert(!outputs.isEmpty());
        System.assertEquals(1, outputs.size());
        ONE_FuneflorIntegrationService.FlowOutputs output = outputs[0];
        System.assert(output.success);
    }
    
    @IsTest
    private static void borradoPedidoReturnsTrueWhenSuccessfulResponse2() {
        Account sociedad2 = ONE_TestDataFactory.createAccount(
            new Account(ONE_Numero_Cliente_Funeflor__c = ID_CLI,
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_ACCOUNT_SOCIEDADES)
            ), true
        );
    
        Account centroDelExpediente = ONE_TestDataFactory.createAccount(
            new Account(ONE_Sociedad2__c = sociedad2.Id,
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA)
            ), true
        );
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(
            new ONE_Expediente__c(ONE_Centro_Del_Expediente__c = centroDelExpediente.Id), true
        );
        ONE_Pedido_De_Proveedor__c pedido = ONE_TestDataFactory.createPedidoDeProveedor(
            new ONE_Pedido_De_Proveedor__c(Name = PEDIDO_NAME, ONE_Expediente__c = expediente.Id), true
        );
        ONE_FuneflorIntegrationService.FlowInputs input = new ONE_FuneflorIntegrationService.FlowInputs();
        input.pedido = pedido;
        input.ContactMethod = ONE_CommonConstants.CM_FLORESMEMORA;
        
        Test.setMock(HttpCalloutMock.class, new ONE_FuneflorDeleteIntegrationCalloutTest.FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
    
        Test.startTest();
    
        List<ONE_FuneflorIntegrationService.FlowOutputs> outputs = ONE_FuneflorBorradoPedidoIntService.borradoPedido(
            new List<ONE_FuneflorIntegrationService.FlowInputs> {input}
        );
    
        Test.stopTest();
        
        System.assert(!outputs.isEmpty());
        System.assertEquals(1, outputs.size());
        ONE_FuneflorIntegrationService.FlowOutputs output = outputs[0];
        System.assert(output.success);
    }
}
/**
 * Created by mkuzak001 on 08.02.2021.
 */

@IsTest
@TestVisible
private class ONE_FuneflorDeleteIntegrationCalloutTest {
    private static final String PEDIDO_NAME = 'Name';
    private static final String TOKEN = 'token';
    private static final String ID_CLI = '1';
    private static final String FIRSTNAME = '1';
    private static final String LASTNAME = '1';
    private static final String NDOCUMENTO = '1';
    
    @TestSetup
    private static void setup() {
        ONE_FuneflorIntegrationCredentials__c cs = new ONE_FuneflorIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs;
        
        ONE_FloresMemoraIntegrationCredentials__c cs2 = new ONE_FloresMemoraIntegrationCredentials__c(ONE_Token__c = TOKEN);
        insert cs2;
    }
    
    @IsTest
    public static void validationSuccessfulWhenAllNecessaryDataAreSet() {
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
        Test.setMock(HttpCalloutMock.class, new FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
        
        Test.startTest();
        
        ONE_FuneflorDeleteIntegrationCallout callout = new ONE_FuneflorDeleteIntegrationCallout(ONE_CommonConstants.CM_FUNEFLOR,
            ONE_Integration.RestMethod.DEL, pedido);
        HttpResponse res = callout.invokeCallout();
        
        Test.stopTest();
        
        System.assertEquals(ONE_CommonConstants.HTPP_SUCCESS_CODE, res.getStatusCode());
    }
    
    @IsTest
    public static void validationSuccessfulWhenAllNecessaryDataAreSet2() {
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
        Test.setMock(HttpCalloutMock.class, new FuneflorIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>{}));
        
        Test.startTest();
        
        ONE_FuneflorDeleteIntegrationCallout callout = new ONE_FuneflorDeleteIntegrationCallout(ONE_CommonConstants.CM_FLORESMEMORA,
            ONE_Integration.RestMethod.DEL, pedido);
        HttpResponse res = callout.invokeCallout();
        
        Test.stopTest();
        
        System.assertEquals(ONE_CommonConstants.HTPP_SUCCESS_CODE, res.getStatusCode());
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
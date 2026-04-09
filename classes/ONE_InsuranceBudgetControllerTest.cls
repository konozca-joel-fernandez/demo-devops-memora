/**
 * Created by kmotyka005 on 14.10.2021.
 */
//Insurance Budget integration test class
@IsTest
public with sharing class ONE_InsuranceBudgetControllerTest {
	//Static variable definition
    private static final String CREDENTIAL_NAME = 'GENERALI';
    private static final String CREDENTIAL_COMPANY = 'K';
    private static final String CREDENTIAL_USERNAME = 'username';
    private static final String CREDENTIAL_PASSWORD = 'password';
	//Data builder for the test
    @TestSetup
    private static void setup() {
        ONE_InsuranceIntegrationCredentials__c cs = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs;
         ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        
        
		Account ac=ONE_TestDataFactory.createAccount(null, false);
        ac.Name='accountcentro';
        ac.RecordTypeId= ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_CENTRO_MEMORA);
        ac.ONE_Lugar__c=lugar.Id;
        ac.ONE_Tipo_De_Impuesto__c = 'IVA';
        insert ac;
        
        ONE_Expediente__c ex = ONE_TestDataFactory.createExpediente(null, false);
        ex.ONE_Numero_de_Siniestro__c = '123';
        ex.ONE_Centro_Del_Expediente__c=ac.Id;
        insert ex;

        ONE_Orden_De_Venta__c ordenRecord = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(
            ONE_Servicio__c = ex.Id,
            ONE_Numero_de_factura__c = '123',
            ONE_Tipo_Tasa__c = '1',
            ONE_GeneraliOCajamar__c = 'G'
        ), true);
		
        ONE_Producto__c product = new ONE_Producto__c(
        	Name = 'Servicio 0%');
        insert product;
        
        ONE_Expediente_Line_Item__c lf = new ONE_Expediente_Line_Item__c(
			ONE_Producto__c = product.Id,
            ONE_TrasladoM1__c = false,
            ONE_Expediente__c = ex.Id,
            ONE_Precio__c = 1000,
            ONE_Identificador_Linea_Factura__c = 'asd2',
            ONE_Estado__c = 'Confirmado',
            ONE_Orden_de_venta__c = ordenRecord.Id);
		insert lf;
        
        
    }
	//Test integration call
    @IsTest
    public static void invokeIntegrationTest() {
        ONE_Orden_De_Venta__c ordenRecord = [SELECT ONE_Servicio__c, Id,ONE_Numero_de_factura__c,ONE_Tipo_Tasa__c,ONE_GeneraliOCajamar__c FROM ONE_Orden_De_Venta__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new CreateInsuranceBudgetMock());

        List<ONE_InsuranceBudgetController.FlowInputs> inputs = new List<ONE_InsuranceBudgetController.FlowInputs>();
        ONE_InsuranceBudgetController.FlowInputs inp = new ONE_InsuranceBudgetController.FlowInputs();

        inp.ordenDeVentaId = ordenRecord.Id;
        inputs.add(inp);

        Test.startTest();
        List<ONE_InsuranceBudgetController.FlowOutputs> flowOutputs = ONE_InsuranceBudgetController.invokeIntegration(inputs);
        Test.stopTest();

        System.assertEquals(flowOutputs[0].codeError.replaceAll('\\s+', ''), '000');
    }
	//Mockup builder for the integration test
    @TestVisible
    private class CreateInsuranceBudgetMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('loginUserService')) {
                response.setBody('{\n' +
                    '    "codeError": "' + ONE_CommonConstants.HTPP_SUCCESS_CODE + '",\n' +
                    '    "sesion": "A4yrlp-5D9xddkWs3Pf4Zw7mHJzH_Ix1I85hLFjyw"\n' +
                    '}');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else if (endpoint.endsWith('createBudget')) {
                System.debug('enter');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('{\n' +
                    '    "codeError": "000 ",\n' +
                    '    "errorMessage":  "000 ",\n' +
                    '"budgets":[\n' +
                    '      {\n' +
                    '         "budgetNumber":"BgtwXf1fOnzklqSNVcPgmsADtCuoBBor0cqrxA5LMj5rrzO4UH",\n' +
                    '         "scales":[\n' +
                    '            {\n' +
                    '               "scaleId":"BgtwXf1fOnzklqSNVcPgmsADtCuoBBor0cqrxA5LMj505se"\n' +
                    '            },\n' +
                    '            {\n' +
                    '               "scaleId":"BgtwXf1fOnzklqSNVcPgmsADtCuoBBor0cqrxA5LMj505s"\n' +
                    '            }\n' +
                    '         ]\n' +
                    '}]}');
            }
            return response;
        }
    }
}
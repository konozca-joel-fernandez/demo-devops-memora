/**
 * Created by kmotyka005 on 15.10.2021.
 */

@IsTest
public with sharing class ONE_InsuranceBudgetUpdateControllerTest {
	//Static variable definition
    private static final String CREDENTIAL_NAME = 'GENERALI';
    private static final String CREDENTIAL_COMPANY = 'K';
    private static final String CREDENTIAL_USERNAME = 'username';
    private static final String CREDENTIAL_PASSWORD = 'password';
	//Data setup builder
    @TestSetup
    private static void setup() {
        List<ONE_Lineas_Factura__c> lfList = new List<ONE_Lineas_Factura__c>();
        ONE_InsuranceIntegrationCredentials__c cs = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs;

        ONE_Expediente__c ex = ONE_TestDataFactory.createExpediente(null, false);
        ex.ONE_Numero_de_Siniestro__c = '123';
        insert ex;

        ONE_Orden_De_Venta__c ordenRecord = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(
            ONE_Servicio__c = ex.Id,
            ONE_Numero_de_factura__c = '123',
            ONE_Tipo_Tasa__c = '1',
            ONE_GeneraliOCajamar__c = 'G'
        ), true);

        ONE_Lineas_Factura__c lf1 = new ONE_Lineas_Factura__c(
            ONE_tipo__c = 'SE',
            ONE_Tipo_de_Tasa__c = '1',
            ONE_Tipo_Impositivo__c = '0',
            ONE_Codigo__c = '23',
            ONE_Precio__c = 1000,
            ONE_Identificador_Linea__c = 'asd2',
            ONE_Orden_de_venta__c = ordenRecord.Id);

        ONE_Lineas_Factura__c lf2 = new ONE_Lineas_Factura__c(
            ONE_tipo__c = 'SE',
            ONE_Tipo_de_Tasa__c = '1',
            ONE_Tipo_Impositivo__c = '0',
            ONE_Codigo__c = '23',
            ONE_Precio__c = 1000,
            ONE_Identificador_Linea__c = '',
            ONE_Orden_de_venta__c = ordenRecord.Id);

        lfList.add(lf1);
        lfList.add(lf2);
        insert lfList;
    }
	//Test integration call
    @IsTest
    public static void invokeIntegrationTest() {
        ONE_Orden_De_Venta__c ordenRecord = [SELECT ONE_Servicio__c, Id,ONE_Numero_de_factura__c,ONE_Tipo_Tasa__c,ONE_GeneraliOCajamar__c FROM ONE_Orden_De_Venta__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new UpdateInsuranceBudgetMock());

        List<ONE_InsuranceBudgetUpdateController.FlowInputs> inputs = new List<ONE_InsuranceBudgetUpdateController.FlowInputs>();
        ONE_InsuranceBudgetUpdateController.FlowInputs inp = new ONE_InsuranceBudgetUpdateController.FlowInputs();

        inp.ordenDeVentaId = ordenRecord.Id;
        inputs.add(inp);

        Test.startTest();
        List<ONE_InsuranceBudgetUpdateController.FlowOutputs> flowOutputs = ONE_InsuranceBudgetUpdateController.invokeIntegration(inputs);
        Test.stopTest();

        System.assertEquals(flowOutputs[0].codeError.replaceAll('\\s+', ''), '000');
    }
	//Mockup builder for the integration call 
    @TestVisible
    private class UpdateInsuranceBudgetMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('loginUserService')) {
                response.setBody('{\n' +
                    '    "codeError": "' + ONE_CommonConstants.HTPP_SUCCESS_CODE + '",\n' +
                    '    "sesion": "A4yrlp-5D9xddkWs3Pf4Zw7mHJzH_Ix1I85hLFjyw"\n' +
                    '}');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else if (endpoint.endsWith('modifyBudget')) {
                System.debug('enter');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('{"codeError":"000","scales":["BMXjpTL1UEECCgw2ba5cWPBdHMgxRElHZEsVy2IwAcxrGxTOFKHP+MqMNeDJEYeRsPobWS8ej4U1wFBVk2tI/w=="]}');
            }
            return response;
        }
    }
}
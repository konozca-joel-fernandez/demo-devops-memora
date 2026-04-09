/**
 * Created by mbujak003 on 24.02.2021.
 */
//Saldo integration service test
@IsTest
public with sharing class ONE_SaldoIntegrationServiceTest {
    //Data setup for the integration test
    @TestSetup
    private static void dataSetup() {

        Account acc = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = 'someId',
            FirstName = 'a',
            LastName = 'b',
            ONE_Tipo_de_documento__pc = '97',
            ONE_N_Documento__pc = '81892506V',
            ONE_Fecha_de_nacimiento__pc = date.valueOf('1953-09-28'),
            ONE_Direccion__pc = 'DE LA HIEDRA, 396 IZD 2',
            ONE_Municipio__pc = 'ALCOBENDAS',
            ONE_Provincia__pc = '28',
            ONE_Pais__pc = 'ES',
            ONE_Codigo_Postal__pc = '28109'
        ), true);

        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(
            new ONE_Contrato__c(
                ONE_Numero_Contrato_Anexo__c = 'test',
                ONE_Contratante__c = acc.Id,
                ONE_Beneficiario_1__c=acc.Id, 
                ONE_Parentesco__c='9'
            ), true);
    }
	//Integration test SAP callout
    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new SaldoIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse())); // set mock up response
		
        ONE_SaldoIntegrationService.FlowInputs fi = new ONE_SaldoIntegrationService.FlowInputs();
        fi.contratoId = [SELECT Id FROM ONE_Contrato__c LIMIT 1].Id;
        List<ONE_SaldoIntegrationService.FlowOutputs> fo;
        Test.startTest();
        //Integration call test
        fo = ONE_SaldoIntegrationService.invokeIntegration(new List<ONE_SaldoIntegrationService.FlowInputs> { fi });
        Test.stopTest();
		//Assert definition
        System.assertEquals(fo[0].Importe, '0.0000');
        System.assertEquals(fo[0].ImporteCobrado, '1000.0000');
        System.assertEquals(fo[0].TotalCuotasImpagadas, '1.00');
        System.assertEquals(fo[0].TotalImporteImpagado, '20.00');
        
    }
	//Mock up resposne structure definition
    @TestVisible
    private class SaldoIntegrationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public SaldoIntegrationMock(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            res.setBody(this.body);
            return res;
        }
    }
	//Mockup response definition
    private static String prepareResponse() {
        //TODO: proper object creation and serialization
        return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_SRV/SaldoPagadoSet(Cliente=-100078003-,ContratoElectium=-00999-,Sociedad=-1140-)","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_SRV/SaldoPagadoSet(Cliente=-100078003-,ContratoElectium=-00999-,Sociedad=-1140-)","type":"ZONE_ELECTIUM_SRV.SaldoPagado"},"Cliente":"100078003","ContratoElectium":"00999","Sociedad":"1140","Importe":"0.0000","ImporteCobrado":"1000.0000", "TotalCuotasImpagadas":"1.00", "TotalImporteImpagado":"20.00"}}';
    }
}
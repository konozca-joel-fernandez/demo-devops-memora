/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_SEPAMandateIntegrationServiceTest {
    @TestSetup
    private static void dataSetup() {

        Account acc1 = ONE_TestDataFactory.createCentro(null,true);
        Account acc2 = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = 'someId'
        ), true);
        ONE_Expediente__c expedient = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = acc1.Id
        ), true);

        ONE_Interlocutor__c interlocutor = ONE_TestDataFactory.createInterlocutor(
            new ONE_Interlocutor__c(
                ONE_Contacto__c = acc2.Id
            ), true);

        ONE_Orden_De_Venta__c ordenDeVenta = ONE_TestDataFactory.createOrdenDeVenta(
            new ONE_Orden_De_Venta__c(
                ONE_Pagador_Particular__c = interlocutor.Id,
                ONE_Servicio__c = expedient.Id,
                ONE_Fecha_De_Facturacion__c = Date.today(),
                ONE_Numero_de_factura__c = 'FV25/02/21'
            ), true);
    }

    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new SEPAMandateMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_SEPAMandateIntegrationService.FlowInputs fi = new ONE_SEPAMandateIntegrationService.FlowInputs();
        fi.ordenDeVentaId = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id;
        List<ONE_SEPAMandateIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_SEPAMandateIntegrationService.invokeIntegration(new List<ONE_SEPAMandateIntegrationService.FlowInputs> { fi });
        Test.stopTest();

        System.assert(fo[0].success, true);
    }

    @TestVisible
    private class SEPAMandateMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public SEPAMandateMock(Integer code, String status, String body) {
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

    private static String prepareResponse() {
        //TODO: proper object creation and serialization
        return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_SEPA_SRV/SEPAMandateSet(\'2017S000105000000009082016100127507\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_SEPA_SRV/SEPAMandateSet(\'2017S000105000000009082016100127507\')","type":"ZONE_SEPA_SRV.SEPAMandate"},"referenceId":"2017S000105000000009082016100127507","citySign":"BARCELONA","creditorNumber":"ES06000B85012441","sapIdC":"0100127692","name":"AYUNT. SAN ESTEBAN DE GORMAZ","primaryAddressStreet":"MAYOR","primaryAddressNumberC":"1","primaryAddressPostalcode":"42330","primaryAddressCity":"SAN ESTEBAN DE GORMAZ","primaryAddressCountry":"ES","ibanC":"ES3621082850270010500972","swiftBicC":"CSPAES2LXXX","societyId":"0500","societyName":"MÉMORA SERVICIOS FUNERARIOS SLU","streetName":"SANCHO DE AVILA","number":"2","postalCode":"08018","cityRec":"BARCELONA","countryId":"ES","messageReturn":{"results":[{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_SEPA_SRV/SEPAMsgReturnSet(Id=\'\',Number=\'000\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_SEPA_SRV/SEPAMsgReturnSet(Id=\'\',Number=\'000\')","type":"ZONE_SEPA_SRV.messageReturn"},"Type":"","Id":"","Number":"000","Message":"","LogNo":"","LogMsgNo":"000000","MessageV1":"","MessageV2":"","MessageV3":"","MessageV4":"","Parameter":"","Row":0,"Field":"","System":""}]},"return":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_SEPA_SRV/returnSet(\'S\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_SEPA_SRV/returnSet(\'S\')","type":"ZONE_SEPA_SRV.return"},"Result":"S"}}}';
    }
}
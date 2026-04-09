/**
 * Created by mbujak003 on 24.02.2021.
 */
@IsTest
public with sharing class ONE_ClienteCreationIntegrationTest {

    @TestSetup
    private static void dataSetup() {
        Account acc1 = ONE_TestDataFactory.createCentro(new Account(
            ONE_Provincia__c = '08',
            ONE_Sociedad__c = '0500',
            ONE_Centro_Memora_Codigo_SAP__c = '2000'
        ),true);

        Account acc2 = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = '100910742',
            ONE_Municipio__pc = 'Sant Cebrià de Vallalta',
            ONE_Pais__c = 'ES',
            ONE_Pais__pc = 'ES',
            ONE_Provincia__pc = '08',
            ONE_Tipo_de_documento__pc = '97',
            ONE_N_Documento__pc = '95885446X',
            FirstName = 'Manolo',
            LastName = 'Bombo Grande',
            ONE_Direccion__pc = '45 Carrer Roure',
            ONE_Codigo_Postal__pc = '08396'
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
                ONE_Numero_de_factura__c = 'FV25/02/21',
                ONE_Forma_De_Pago__c = 'A',
                ONE_Moneda__c = 'EUR',
                ONE_IBAN__c = 'ES3621082850270010500972',
                ONE_Titular_De_La_Cuenta_Bancaria__c = 'José Carreño Iborra',
                ONE_El_Pagador_Es_El_Difunto__c = false
            ), true);
    }

    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new ClientCreationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_ClientCreationIntegrationService.FlowInputs fi = new ONE_ClientCreationIntegrationService.FlowInputs();

        fi.ordenDeVentaId = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id;

        List<ONE_ClientCreationIntegrationService.FlowOutputs> fo;

        Test.startTest();
        fo = ONE_ClientCreationIntegrationService.invokeIntegration(new List<ONE_ClientCreationIntegrationService.FlowInputs> { fi });
        Test.stopTest();

        System.assertEquals(fo[0].success, true);
        System.assertNotEquals(fo[0].customerId, null);
        System.assertEquals(fo[0].customerId, '100923301');
    }


    @TestVisible
    private class ClientCreationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public ClientCreationMock(Integer code, String status, String body) {
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
        return '{"d":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/CustomerSet(\'100923301\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/CustomerSet(\'100923301\')","type":"ZONE_CUSTOMER_SRV.Customer"},"customerId":"100923301","Address":null,"BankAccount":null,"Company":null,"GeneralData":null,"PartnerFunction":null,"messageReturn":null,"SalesData":null,"TaxIndicator":null,"result":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/resultSet(\'S\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/resultSet(\'S\')","type":"ZONE_CUSTOMER_SRV.result"},"Result":"S"}}}';
    }
}
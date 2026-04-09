/**
 * Created by mbujak003 on 24.02.2021.
 */
//Test class for sales order cancelation integration
@IsTest
public with sharing class ONE_SalesOrderCancelIntegrationTest {

    //Data structure definition
    @TestSetup
    private static void dataSetup() {
		
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account acc1 = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id),true);
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
                ONE_Fecha_De_Facturacion__c = Date.newInstance(2020, 12, 30),
                ONE_Numero_de_factura__c = 'FV25/02/21',
                ONE_Fecha_Hora_Del_Abono_Factura__c = Date.today()
            ), true);
    }

	//Invoke integration test
    @IsTest
    private static void invokeIntegrationTest() {
        //Set mock response
        Test.setMock(HttpCalloutMock.class, new SalesOrderCancellationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));
		//flow input variable population
        ONE_SalesOrderCancelIntegrationService.FlowInputs fi = new ONE_SalesOrderCancelIntegrationService.FlowInputs();
        fi.ordernDeVentaId = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id;
        List<ONE_SalesOrderCancelIntegrationService.FlowOutputs> fo;
        Test.startTest();
        //Integration call
        fo = ONE_SalesOrderCancelIntegrationService.invokeIntegration(new List<ONE_SalesOrderCancelIntegrationService.FlowInputs> { fi });
        Test.stopTest();
		//Assert definition
        System.assertEquals(fo[0].EFkdatAnul, Date.newInstance(2020, 12, 30));
        System.assertEquals(fo[0].ESfakn, '2012938009');
        System.assertEquals(fo[0].EResult, 'S');
    }

	//Invoke integration test
    @IsTest
    private static void invokeAlternativeIntegrationTest() {
        //Set mock response
        Test.setMock(HttpCalloutMock.class, new SalesOrderCancellationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareAlternativeResponse()));
		//flow input variable population
        ONE_SalesOrderCancelIntegrationService.FlowInputs fi = new ONE_SalesOrderCancelIntegrationService.FlowInputs();
        fi.ordernDeVentaId = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id;
        List<ONE_SalesOrderCancelIntegrationService.FlowOutputs> fo;
        Test.startTest();
        //Integration call
        fo = ONE_SalesOrderCancelIntegrationService.invokeIntegration(new List<ONE_SalesOrderCancelIntegrationService.FlowInputs> { fi });
        Test.stopTest();
    }

	//Mock up response data structure definition
    @TestVisible
    private class SalesOrderCancellationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public SalesOrderCancellationMock(Integer code, String status, String body) {
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
	//Response mockup definition
    private static String prepareResponse() {
        //TODO: proper object creation and serialization
        return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELINVOICE_SRV/Z_ONE_CANCEL_INVOICESet(IFkdat=datetime\'2020-12-30T00-00-00\',IVbeln=\'1910059064\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELINVOICE_SRV/Z_ONE_CANCEL_INVOICESet(IFkdat=datetime\'2020-12-30T00-00-00\',IVbeln=\'1910059064\')","type":"ZONE_CANCELINVOICE_SRV.Z_ONE_CANCEL_INVOICE"},"IFkdat":"/Date(1609286400000)/","IVbeln":"1910059064","EFkdatAnul":"/Date(1609286400000)/","EResult":"S","ESfakn":"2012938009", "messageReturn": { "results": [] }}}';
    }

	//Response mockup definition
    private static String prepareAlternativeResponse() {
        //TODO: proper object creation and serialization
        return '{"error":{"code":"F5/287","message":{"lang":"es","value":"La cuenta 100120323 0500 está siendo tratada por el usuario CARTASP"},"innererror":{"application":{"component_id":"","service_namespace":"/SAP/","service_id":"ZONE_CANCELINVOICE_SRV","service_version":"0001"},"transactionid":"85E00D17F4660050E00628B62B2650A0","timestamp":"","Error_Resolution":{"SAP_Transaction":"","SAP_Note":"See SAP Note 1797736 for error analysis (https://service.sap.com/sap/support/notes/1797736)"},"errordetails":[{"code":"VF/050","message":"Documento 2207938365 grabado (documento contable no creado)","propertyref":"","severity":"warning","target":""},{"code":"VF/050","message":"Documento 2207938365 grabado (documento contable no creado)","propertyref":"","severity":"warning","target":""},{"code":"F5/287","message":"La cuenta 100120323 0500 está siendo tratada por el usuario CARTASP","propertyref":"","severity":"error","target":""},{"code":"/IWBEP/CX_SD_GEN_DPC_BUSINS","message":"An application exception has occurred.","propertyref":"","severity":"error","target":""}]}}}';
    }
}
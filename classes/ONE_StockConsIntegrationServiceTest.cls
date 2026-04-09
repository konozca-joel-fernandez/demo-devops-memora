/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_StockConsIntegrationServiceTest {
    @IsTest
    public static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new StockReservationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_StockConsumptionIntegrationService.FlowInputs fi = new ONE_StockConsumptionIntegrationService.FlowInputs();
        fi.Expediente = 'PRUEBAS';
        fi.IMblnr = '4900567319';
        fi.IMjahr = '2020';

        List<ONE_StockConsumptionIntegrationService.FlowOutputs> fo = null;

        Test.startTest();
        fo = ONE_StockConsumptionIntegrationService.invokeIntegration(
            new List<ONE_StockConsumptionIntegrationService.FlowInputs> { fi }
        );
        Test.stopTest();
        System.assertEquals(fo[0].EMblnrConsigna, '');
        System.assertEquals(fo[0].EMblnrConsumo, '4900567321');
        System.assertEquals(fo[0].EMblnrAnulres, '4900567320');
        System.assertEquals(fo[0].EMjahrConsigna, '0000');
        System.assertEquals(fo[0].EMjahrConsumo, '2020');
    }

    @TestVisible
    private class StockReservationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public StockReservationMock(Integer code, String status, String body) {
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
        ONE_SAPResponses.StockConsumptionResponse resp = new ONE_SAPResponses.StockConsumptionResponse();
        resp.Expediente = 'PRUEBAS';
        resp.IMblnr = '4900567319';
        resp.IMjahr = '2020';
        resp.EMblnrAnulres = '4900567320';
        resp.EMblnrConsigna = '';
        resp.EMblnrConsumo = '4900567321';
        resp.EMjahrAnulres = '2020';
        resp.EMjahrConsigna = '0000';
        resp.EMjahrConsumo = '2020';
        resp.Result = 'S';
        return JSON.serialize(new ONE_SAPResponses.StockConsumptionResponseWrapper(resp));
    }
}
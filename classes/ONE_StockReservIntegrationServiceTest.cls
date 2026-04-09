/**
 * Created by mbujak003 on 22.02.2021.
 */

@IsTest
public with sharing class ONE_StockReservIntegrationServiceTest {

    private static final String MATNR = '300005842';
    private static final String IZZAUFNR = 'PRUEBAS';
    private static final String IWERKS = '6095';
    private static final String IMEINS = 'UN';
    private static final Decimal IMENGE = 9;
    private static final Boolean IXFUERZAWERKS = true;

    @IsTest
    public static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new StockReservationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_StockReservationIntegrationService.FlowInputs fi = new ONE_StockReservationIntegrationService.FlowInputs();
        fi.IMatnr = MATNR;
        fi.IZzaufnr = IZZAUFNR;
        fi.IWerks = IWERKS;
        fi.IMenge = IMENGE;
        fi.IMeins = IMEINS;
        fi.IMeins = IMEINS;
        fi.IXfuerzawerks = IXFUERZAWERKS;

        List<ONE_StockReservationIntegrationService.FlowInputs> inputs = new List<ONE_StockReservationIntegrationService.FlowInputs >{fi};

        List<ONE_StockReservationIntegrationService.FlowOutputs> fo = null;

        Test.startTest();
        fo = ONE_StockReservationIntegrationService.invokeIntegration(inputs);
        Test.stopTest();

        System.assertEquals(fo[0].EResult, 'S');
        System.assertEquals(fo[0].EMblnr, '4900567239');
        System.assertEquals(fo[0].EMjahr, '2020');
        System.assertEquals(fo[0].EWerks, '6095');
        System.assertEquals(fo[0].ELgort, 'A001');
        System.assertEquals(fo[0].ELifnr, '');
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
        ONE_SAPResponses.StockReservationResponse resp = new ONE_SAPResponses.StockReservationResponse();
        resp.IMatnr = MATNR;
        resp.IMeins = IMEINS;
        resp.IMenge = IMENGE;
        resp.IWerks = IWERKS;
        resp.IZzaufnr = IZZAUFNR;
        resp.ELgort = 'A001';
        resp.ELifnr = '';
        resp.EMblnr = '4900567239';
        resp.EMjahr = '2020';
        resp.EResult = 'S';
        resp.EWerks = '6095';
        return JSON.serialize(new ONE_SAPResponses.StockReservationResponseWrapper(resp));
    }
}
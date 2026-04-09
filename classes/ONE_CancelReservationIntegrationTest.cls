/**
 * Created by mbujak003 on 19.05.2021.
 */
@IsTest
public with sharing class ONE_CancelReservationIntegrationTest {
    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new CancelReservationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_CancelReservationIntegrationService.FlowInputs fi = new ONE_CancelReservationIntegrationService.FlowInputs();
        fi.IMblnr = '4900567319';
        fi.IMjahr = '2020';
        List<ONE_CancelReservationIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_CancelReservationIntegrationService.invokeIntegration(new List<ONE_CancelReservationIntegrationService.FlowInputs> { fi });
        Test.stopTest();
        System.debug(fo);
        System.assertEquals(fo[0].Result, 'S');
    }


    @TestVisible
    private class CancelReservationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public CancelReservationMock(Integer code, String status, String body) {
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
        return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELSTOCK_SRV/Z_ONE_CANCEL_RESERVA_STOCKSet(IMblnr=\'4900567429\',IMjahr=\'2021\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELSTOCK_SRV/Z_ONE_CANCEL_RESERVA_STOCKSet(IMblnr=\'4900567429\',IMjahr=\'2021\')","type":"ZONE_CANCELSTOCK_SRV.Z_ONE_CANCEL_RESERVA_STOCK"},"IMblnr":"4900567429","IMjahr":"2021","EMblnr":"4900567429","EMjahr":"2021","EResult":"S"}}';
    }
}
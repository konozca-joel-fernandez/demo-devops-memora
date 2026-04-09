/**
 * Created by mbujak003 on 19.05.2021.
 */
@IsTest
public with sharing class ONE_CancelConsumptionIntegrationTest {

    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new ConsumptionIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_CancelConsumptionIntegrationService.FlowInputs fi = new ONE_CancelConsumptionIntegrationService.FlowInputs();
        fi.IMblnr = '4900567319';
        fi.IMjahr = '2020';
        List<ONE_CancelConsumptionIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_CancelConsumptionIntegrationService.invokeIntegration(new List<ONE_CancelConsumptionIntegrationService.FlowInputs> { fi });
        Test.stopTest();
        System.debug(fo);
        System.assertEquals(fo[0].Result, 'S');
    }


    @TestVisible
    private class ConsumptionIntegrationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public ConsumptionIntegrationMock(Integer code, String status, String body) {
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
        return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELCONSUMO_SRV/Z_ONE_CANCEL_CONSUMOSSet(IMblnr=\'4900567430\',IMjahr=\'2021\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELCONSUMO_SRV/Z_ONE_CANCEL_CONSUMOSSet(IMblnr=\'4900567430\',IMjahr=\'2021\')","type":"ZONE_CANCELCONSUMO_SRV.Z_ONE_CANCEL_CONSUMOS"},"IMblnr":"4900567430","IMjahr":"2021","EMblnr":"4900567430","EMjahr":"2021","EResult":"S"}}';
    }
}
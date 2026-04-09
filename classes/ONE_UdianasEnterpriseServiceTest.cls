@IsTest
public class ONE_UdianasEnterpriseServiceTest {

    private class EnterpriseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setBody('{"enterprise": {"enterpriseHashId":"ENT_X"}}');
            return r;
        }
    }

    @IsTest
    static void testCreateEnterprise() {

        Test.setMock(HttpCalloutMock.class, new EnterpriseMock());

        String hash = ONE_UdianasEnterpriseService.createEnterprise('Z.GIRONA');

        System.assertEquals('ENT_X', hash,'Debe devolver el enterpriseHashId del response');
    }
}
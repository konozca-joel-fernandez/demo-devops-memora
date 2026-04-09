@IsTest
public class ONE_UdianasInsuranceServiceTest {

    private class InsuranceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setBody('{"insuranceCompany": {"insuranceCompanyHashId":"INS_X"}}');
            return r;
        }
    }

    @IsTest
    static void testCreateInsurance() {

        Test.setMock(HttpCalloutMock.class, new InsuranceMock());

        String hash = ONE_UdianasInsuranceService.createInsurance('Mapfre');

        System.assertEquals('INS_X',hash,'Debe devolver el insuranceCompanyHashId del response');
    }

    @IsTest
    static void testLookupParticularHash() {

        String hash = ONE_UdianasInsuranceService.lookupParticularHash();

        List<ONE_TreeNationInsuranceCompany__mdt> rows = [
            SELECT ONE_InsuranceCompanyHashId__c
            FROM ONE_TreeNationInsuranceCompany__mdt
            WHERE ONE_CompanyKey__c = 'Particular'
            AND ONE_Active__c = true
            LIMIT 1
        ];

        System.assertEquals(rows[0].ONE_InsuranceCompanyHashId__c,hash,'Debe devolver el hash configurado en Custom Metadata');
    }

}
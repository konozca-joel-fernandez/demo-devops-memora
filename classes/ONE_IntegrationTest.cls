/**
 * Created by mbujak003 on 31.01.2021.
 */

@IsTest
public with sharing class ONE_IntegrationTest {

    private static final String metaName = 'testMeta';
    private static final String testBody = '{\'someBody\'}';

    public class TestIntegrationCallout extends ONE_Integration.IntegrationCallout {
        public TestIntegrationCallout() {
            super(metaName, ONE_Integration.RestMethod.POST);
        }
    }

    @IsTest
    public static void testSetBody() {
        

    }

    @IsTest
    public static void testPutHeaders() {

    }

    @IsTest
    public static void testPutHeader() {

    }

    @IsTest
    public static void testPutParam() {

    }

    @IsTest
    public static void testIsActive() {

    }

    @IsTest
    public static void testBuildRequest() {

    }

    @IsTest
    public static void testInvokeCallout() {

    }

    @IsTest
    public static void testBuildEndpoint() {

    }

    private static final String META_NAME = 'SHAREPOINT_CREATE_CSV_FILE';
    private static final String TEST_BODY = '{"someBody":true}';

    // Mock mínimo para Http.send
    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setBody('OK');
            return r;
        }
    }

    // Clase concreta para instanciar el abstract
    private class TestCallout extends ONE_Integration.IntegrationCallout {
        TestCallout(ONE_Integration.RestMethod method) {
            super(META_NAME, method);
        }
    }

    @IsTest
    public static void testSetBody_putHeaders_putParam_buildEndpoint() {
        TestCallout c = new TestCallout(ONE_Integration.RestMethod.GET);

        // Con Named Credential, el endpoint será callout:<NC><resource>
        c.setResource('/v1.0/test');

        c.setBody(TEST_BODY);
        c.putHeaders(new Map<String,Object>{ 'H1' => 'V1', 'H2' => 2 });
        c.putHeader('H3', true);

        c.putParam('a', '1');
        c.putParam('b', 'hola');

        String ep = c.buildEndpoint();

        System.assert(ep.startsWith('callout:'), 'Con Named Credential debe empezar por callout:');
        System.assert(ep.contains('/v1.0/test'), 'Debe incluir el resourceOverride');
        System.assert(ep.contains('?'), 'Debe añadir querystring');
        System.assert(ep.contains('a=1'), 'Debe incluir param a');
        System.assert(ep.contains('b=hola'), 'Debe incluir param b');
        System.assert(ep.endsWith('a=1&b=hola') || ep.endsWith('b=hola&a=1'),
            'El orden puede variar por el map, pero deben estar ambos y sin & final'
        );
    }

    @IsTest
    public static void testBuildRequest_setsDeleteMethod_headers_andBodyBlob() {
        TestCallout c = new TestCallout(ONE_Integration.RestMethod.DEL);

        c.setResource('https://example.com/delete');
        c.putHeader('X-Test', '1');
        c.setBodyAsBlob(Blob.valueOf('bin'));

        // buildRequest es @TestVisible
        HttpRequest req = c.buildRequest();

        System.assertEquals('DELETE', req.getMethod(), 'DEL enum debe convertirse a DELETE');
        System.assertEquals('1', req.getHeader('X-Test'));
        System.assert(req.getEndpoint().contains('https://example.com/delete'));
    }

    @IsTest
    public static void testInvokeCallout_ok() {
        Test.setMock(HttpCalloutMock.class, new OkMock());

        TestCallout c = new TestCallout(ONE_Integration.RestMethod.POST);
        c.setResource('https://example.com/api');
        c.setBody(TEST_BODY);

        Test.startTest();
        HttpResponse resp = c.invokeCallout(true);
        Test.stopTest();

        System.assertNotEquals(null, resp);
        System.assertEquals(200, resp.getStatusCode());
    }

        private static String getAnyLogActiveMeta() {
        ONE_Integration_endpoint__mdt ep = [
            SELECT DeveloperName
            FROM ONE_Integration_endpoint__mdt
            WHERE ONE_LogActive__c = true
            LIMIT 1
        ];
        return ep.DeveloperName;
    }

    // Callout que permite elegir un endpoint MDT con log activo
    private class TestCalloutLog extends ONE_Integration.IntegrationCallout {
        TestCalloutLog(String mdtName, ONE_Integration.RestMethod method) {
            super(mdtName, method);
        }
    }

    @IsTest
    public static void testInvokeCallout_withLogging_textBody() {
        Test.setMock(HttpCalloutMock.class, new OkMock());

        String metaWithLog = getAnyLogActiveMeta();

        TestCalloutLog c = new TestCalloutLog(metaWithLog, ONE_Integration.RestMethod.POST);
        c.setResource('/v1/test-log');
        c.setBody('{"log":true}');

        Test.startTest();
        HttpResponse resp = c.invokeCallout(true);
        Test.stopTest();

        System.assertEquals(200, resp.getStatusCode());
    }

    @IsTest
    public static void testInvokeCallout_withLogging_binaryBody() {
        Test.setMock(HttpCalloutMock.class, new OkMock());

        String metaWithLog = getAnyLogActiveMeta();

        TestCalloutLog c = new TestCalloutLog(metaWithLog, ONE_Integration.RestMethod.PUT);
        c.setResource('/v1/test-log-bin');
        c.setBodyAsBlob(Blob.valueOf('binary'));

        Test.startTest();
        HttpResponse resp = c.invokeCallout(false);
        Test.stopTest();

        System.assertEquals(200, resp.getStatusCode());
    }
}
/**
 * Created by bjaworski002 on 01.02.2022.
 */

@IsTest
public with sharing class ONE_GeneraliPdfBase64Test {

    @TestSetup
    public static void createData() {
        insert new ONE_InsuranceIntegrationCredentials__c(
            Name = 'GENERALI',
            ONE_Company__c = 'X',
            ONE_Password__c = 'X',
            ONE_Username__c = 'X'
        );

        ONE_Caso__c caso = new ONE_Caso__c(
            RecordTypeId = Schema.ONE_Caso__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('ONE_Presupuesto').getRecordTypeId()
        );
        insert caso;

        Blob bodyBlob = Blob.valueOf('ONE_GeneraliPdfBase64Test');

        ContentVersion cv = new ContentVersion(
                Title = 'SampleTitle',
                PathOnClient = 'SampleTitle.jpg',
                VersionData = bodyBlob,
                Origin = 'H',
                ONE_PDF_Compania__c = true
        );
        insert cv;

        ContentVersion cvAfterInsert = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = caso.Id;
        contentLink.ContentDocumentId = cvAfterInsert.ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
    }

    @IsTest
    public static void contentDocumentEncodedAndSent() {
        String body = '{"codeError":"000"}';

        ONE_Caso__c caso = [SELECT Id FROM ONE_Caso__c];

        Test.setMock(HttpCalloutMock.class, new GeneraliIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, body));
        List<ONE_GeneraliPdfBase64.FlowInput> fiList = new List<ONE_GeneraliPdfBase64.FlowInput>();
        ONE_GeneraliPdfBase64.FlowInput fi = new ONE_GeneraliPdfBase64.FlowInput();
        fi.casoId = caso.Id;
        fiList.add(fi);

        Test.startTest();

        List<ONE_GeneraliPdfBase64.FlowOutput> fo = ONE_GeneraliPdfBase64.encodeAndSendPdf(fiList);

        Test.stopTest();

        System.debug(fo.get(0));

        System.assert(fo.get(0).success);
        System.assertEquals('000', fo.get(0).codeError);
        System.assertEquals(null, fo.get(0).errorMessages);
    }

    @TestVisible
    private class GeneraliIntegrationMock implements HttpCalloutMock {
        protected Integer code;
        protected String body;

        public GeneraliIntegrationMock(Integer code, String body) {
            this.code = code;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.code);
            res.setBody(this.body);
            return res;
        }
    }
}
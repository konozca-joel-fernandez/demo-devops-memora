@IsTest
private class ONE_FrotcomIntegrationCalloutTest {
    private static final String USERNAME = 'username';
    private static final String PASSWORD = 'password';
    private static final String PROVIDER = 'provider';
    private static final String REFERENCE = 'ref';
    private static final String CONTENT = 'content';
    
    @TestSetup
    private static void setup() {
        ONE_FrotcomCredentials__c cs = new ONE_FrotcomCredentials__c(ONE_Username__c = USERNAME, ONE_Password__c = PASSWORD,
            ONE_Provider__c = PROVIDER);
        insert cs;
    }
    /*
    @IsTest
    private static void validateFailsWhenContentIsEmpty() {
        Test.setMock(HttpCalloutMock.class, new Mock());
    
        List<ONE_FrotcomIntegrationService.RequestWrapperItem> requestWrapperItems =
            new List<ONE_FrotcomIntegrationService.RequestWrapperItem> {
                new ONE_FrotcomIntegrationService.RequestWrapperItem(null, REFERENCE)
            };
        
        Test.startTest();
    
        ONE_FrotcomIntegrationCallout.FrotcomIntegrationCalloutException expectedException = null;
    
        try {
            ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout callout = new ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout(requestWrapperItems);
        } catch (ONE_FrotcomIntegrationCallout.FrotcomIntegrationCalloutException ex) {
            expectedException = ex;
        }
        
        Test.stopTest();
    
        System.assertNotEquals(null, expectedException);
        System.assertEquals(String.format(Label.FieldIsMandatory, new List<String> {'content'}), expectedException.getMessage());
    }
    */
    @IsTest
    private static void validateFailsWhenReferenceIsEmpty() {
        Test.setMock(HttpCalloutMock.class, new Mock());
    
        List<ONE_FrotcomIntegrationService.RequestWrapperItem> requestWrapperItems =
            new List<ONE_FrotcomIntegrationService.RequestWrapperItem> {
                new ONE_FrotcomIntegrationService.RequestWrapperItem(CONTENT, null)
            };
    
        Test.startTest();
    
        ONE_FrotcomIntegrationCallout.FrotcomIntegrationCalloutException expectedException = null;
    
        try {
            ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout callout = new ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout(requestWrapperItems);
        } catch (ONE_FrotcomIntegrationCallout.FrotcomIntegrationCalloutException ex) {
            expectedException = ex;
        }
    
        Test.stopTest();
    
        System.assertNotEquals(null, expectedException);
        System.assertEquals(String.format(Label.FieldIsMandatory, new List<String> {'reference'}), expectedException.getMessage());
    }
    
    @IsTest
    private static void successResponse() {
        Test.setMock(HttpCalloutMock.class, new Mock());
    
        List<ONE_FrotcomIntegrationService.RequestWrapperItem> requestWrapperItems =
            new List<ONE_FrotcomIntegrationService.RequestWrapperItem> {
                new ONE_FrotcomIntegrationService.RequestWrapperItem(CONTENT, REFERENCE)
            };
    
        Test.startTest();
    
        ONE_FrotcomIntegrationCallout.FrotcomIntegrationCalloutException expectedException = null;
        ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout callout = new ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout(requestWrapperItems);
        HttpResponse response = callout.invokeCallout();
    
        Test.stopTest();
    
        System.assertEquals(response.getStatusCode(), ONE_CommonConstants.HTPP_SUCCESS_CODE);
    }
    
    @TestVisible
    private class Mock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('authorize')) {
                response.setBody('{\n' +
                    '  "token": "df1574eb-ee2c-4873-9035-0800723b4ec2",\n' +
                    '  "provider": "thirdparty",\n' +
                    '  "announcements": []\n' +
                    '}'
                );
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else {
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('[\n' +
                    '    {\n' +
                    '        "id": 3804074,\n' +
                    '        "tasks": [\n' +
                    '            3822318,\n' +
                    '            3822319\n' +
                    '        ],\n' +
                    '        "isNew": true\n' +
                    '    }\n' +
                    ']'
                );
            }
            return response;
        }
    }
}
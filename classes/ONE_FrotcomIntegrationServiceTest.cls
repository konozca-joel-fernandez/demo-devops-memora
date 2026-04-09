@IsTest
private class ONE_FrotcomIntegrationServiceTest {
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

    
    @IsTest
    private static void sendTasksWithoutException() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        
    
        ONE_FrotcomIntegrationCallout.FrotcomIntegrationCalloutException expectedException = null;
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id), true);
        ONE_Tarea__c tarea = ONE_TestDataFactory.createTarea(new ONE_Tarea__c(ONE_Expediente__c = expediente.Id), true);
    
        Test.startTest();
    
        try {
            ONE_FrotcomIntegrationService.sendTask(tarea.Id);
        } catch (ONE_FrotcomIntegrationCallout.FrotcomIntegrationCalloutException ex) {
            expectedException = ex;
        }
        
        Test.stopTest();
        
        System.assertEquals(null, expectedException);
    }
    
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
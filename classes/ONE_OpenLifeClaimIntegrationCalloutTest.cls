@IsTest
private class ONE_OpenLifeClaimIntegrationCalloutTest {
    private static final String POLICY_CIA = 'G';
    private static final String POLICY_BRANCH = 'br';
    private static final String POLICY_POLICY = 'policy';
    
    private static String DATA_TIPOLOGY = 'F';
    private static String DATA_OCURRENCE_PLACE = 'place';
    private static String DATA_INSURED_IDENTITY_CARD = 'nif';
    private static String DATA_DESCRIPTION = 'description';
    private static String DATA_DAMAGES = 'damages';
    private static String DATA_CONTACT_NAME = 'contact name';
    private static String DATA_CONTACT_RELATIONSHIP = 'contact relationship';
    private static String DATA_PROVIDER_REFERENCE = 'provider reference';
    
    private static final String OCCURRENCE_DATE_DAY = '1';
    private static final String OCCURRENCE_DATE_MONTH = '1';
    private static final String OCCURRENCE_DATE_YEAR = '1999';
    private static final String OCCURRENCE_DATE_HOUR = '1';
    private static final String OCCURRENCE_DATE_MINUTE = '1';
    
    private static final String CREDENTIAL_NAME = 'GENERALI';
    private static final String CREDENTIAL_COMPANY = 'K';
    private static final String CREDENTIAL_USERNAME = 'username';
    private static final String CREDENTIAL_PASSWORD = 'password';
    
    @TestSetup
    private static void setup() {
        ONE_InsuranceIntegrationCredentials__c cs = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs;
    }
    
    @IsTest
    private static void validationFailsWhenPolicyTooLong() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        ONE_OpenLifeClaimIntegrationService.RequestWrapper requestWrapper = buildRequestWrapper();
        requestWrapper.policy.policy = POLICY_POLICY + POLICY_POLICY;
    
        Test.startTest();
    
        ONE_OpenLifeClaimIntegrationCallout.ONE_OpenLifeClaimIntegrationCalloutException expectedException = null;
        
        try {
            ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout callout = new ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout(requestWrapper);
            HttpResponse resp = callout.invokeCallout();
            
        } catch (ONE_OpenLifeClaimIntegrationCallout.ONE_OpenLifeClaimIntegrationCalloutException ex) {
            expectedException = ex;
        }
    
        Test.stopTest();
    
        System.assertNotEquals(null, expectedException);
        System.assertEquals(String.format(ONE_OpenLifeClaimIntegrationCallout.DATA_TOO_LONG, new List<String> {'policy.policy',
            String.valueOf(ONE_OpenLifeClaimIntegrationCallout.POLICY_MAX_LENGTH), requestWrapper.policy.policy}), expectedException.getMessage());
    }
    
    @IsTest
    private static void validationFailsWhenCiaTooLong() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        ONE_OpenLifeClaimIntegrationService.RequestWrapper requestWrapper = buildRequestWrapper();
        requestWrapper.policy.cia = POLICY_CIA + POLICY_CIA;
    
        Test.startTest();
    
        ONE_OpenLifeClaimIntegrationCallout.ONE_OpenLifeClaimIntegrationCalloutException expectedException = null;
    
        try {
            ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout callout = new ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout(requestWrapper);
            HttpResponse resp = callout.invokeCallout();
    
        } catch (ONE_OpenLifeClaimIntegrationCallout.ONE_OpenLifeClaimIntegrationCalloutException ex) {
            expectedException = ex;
        }
    
        Test.stopTest();
    
        System.assertNotEquals(null, expectedException);
        System.assertEquals(String.format(ONE_OpenLifeClaimIntegrationCallout.DATA_TOO_LONG, new List<String> {'policy.cia',
            String.valueOf(ONE_OpenLifeClaimIntegrationCallout.CIA_MAX_LENGTH), requestWrapper.policy.cia}), expectedException.getMessage());
    }
    
    @IsTest
    private static void validationFailsWhenBranchTooLong() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        ONE_OpenLifeClaimIntegrationService.RequestWrapper requestWrapper = buildRequestWrapper();
        requestWrapper.policy.branch = POLICY_BRANCH + POLICY_BRANCH;
    
        Test.startTest();
    
        ONE_OpenLifeClaimIntegrationCallout.ONE_OpenLifeClaimIntegrationCalloutException expectedException = null;
    
        try {
            ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout callout = new ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout(requestWrapper);
            HttpResponse resp = callout.invokeCallout();
    
        } catch (ONE_OpenLifeClaimIntegrationCallout.ONE_OpenLifeClaimIntegrationCalloutException ex) {
            expectedException = ex;
        }
    
        Test.stopTest();
    
        System.assertNotEquals(null, expectedException);
        System.assertEquals(String.format(ONE_OpenLifeClaimIntegrationCallout.DATA_TOO_LONG, new List<String> {'policy.branch',
            String.valueOf(ONE_OpenLifeClaimIntegrationCallout.BRANCH_MAX_LENGTH), requestWrapper.policy.branch}), expectedException.getMessage());
    }
    
    @IsTest
    private static void validationPassesWhenCorrectData() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        ONE_OpenLifeClaimIntegrationService.RequestWrapper requestWrapper = buildRequestWrapper();
        
        Test.startTest();

        ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout callout = new ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout(requestWrapper);
        HttpResponse resp = callout.invokeCallout();
        
        Test.stopTest();
        
        System.assertEquals(resp.getStatusCode(), ONE_CommonConstants.HTPP_SUCCESS_CODE);
    }
    
    private static ONE_OpenLifeClaimIntegrationService.RequestWrapper buildRequestWrapper() {
        ONE_OpenLifeClaimIntegrationService.RequestWrapper requestWrapper = new ONE_OpenLifeClaimIntegrationService.RequestWrapper();
        
        requestWrapper.policy = new ONE_OpenLifeClaimIntegrationService.PolicyWrapper();
        requestWrapper.policy.cia = POLICY_CIA;
        requestWrapper.policy.branch = POLICY_BRANCH;
        requestWrapper.policy.policy = POLICY_POLICY;
        
        requestWrapper.data = new ONE_OpenLifeClaimIntegrationService.DataWrapper();
        requestWrapper.data.tipology = DATA_TIPOLOGY;
        requestWrapper.data.occurrencePlace = DATA_OCURRENCE_PLACE;
        requestWrapper.data.insuredIdentityCard = DATA_INSURED_IDENTITY_CARD;
        requestWrapper.data.description = DATA_DESCRIPTION;
        requestWrapper.data.damages = DATA_DAMAGES;
        requestWrapper.data.contactName = DATA_CONTACT_NAME;
        requestWrapper.data.contactRelationship = DATA_CONTACT_RELATIONSHIP;
        requestWrapper.data.providerReference = DATA_PROVIDER_REFERENCE;
        
        requestWrapper.occurrenceDate = new ONE_OpenLifeClaimIntegrationService.OccurrenceDateWrapper();
        requestWrapper.occurrenceDate.day = OCCURRENCE_DATE_DAY;
        requestWrapper.occurrenceDate.month = OCCURRENCE_DATE_MONTH;
        requestWrapper.occurrenceDate.year = OCCURRENCE_DATE_YEAR;
        requestWrapper.occurrenceDate.hour = OCCURRENCE_DATE_HOUR;
        requestWrapper.occurrenceDate.minute = OCCURRENCE_DATE_MINUTE;
        
        return requestWrapper;
    }
    
    private class Mock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('loginUserService')) {
                response.setBody('{\n' +
                    '    "codeError": "' + ONE_OpenLifeClaimIntegrationService.CODE_ERROR_SUCCESS + '",\n' +
                    '    "sesion": "A4yrlp-5D9xddkWs3Pf4Zw7mHJzH_Ix1I85hLFjyw"\n' +
                    '}');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else if (endpoint.endsWith('openLifeClaim')) {
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('{\n' +
                    '    "codeError": "' + ONE_OpenLifeClaimIntegrationService.CODE_ERROR_SUCCESS + '",\n' +
                    '    "claim": {\n' +
                    '        "cia": "G",\n' +
                    '        "branch": "07",\n' +
                    '        "year": "21",\n' +
                    '        "policy": "33600005",\n' +
                    '        "controlDigit": "6"\n' +
                    '    }\n' +
                    '}');
            }
            return response;
        }
    }
}
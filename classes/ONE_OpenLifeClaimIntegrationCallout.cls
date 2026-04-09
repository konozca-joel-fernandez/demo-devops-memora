/**
 * Created by mkuzak001 on 01.03.2021.
 */

public with sharing class ONE_OpenLifeClaimIntegrationCallout {
    @TestVisible
    public static final String DATA_TOO_LONG = 'Data too long: {0}. Maximum character length is: {1}. ({2})';
    @TestVisible
    public static final Integer POLICY_MAX_LENGTH = 9;
    @TestVisible
    public static final Integer CIA_MAX_LENGTH = 1;
    @TestVisible
    public static final Integer BRANCH_MAX_LENGTH = 2;

    public class GeneraliCallout extends ONE_InsuranceIntegrationCallout.GeneraliInsuranceCallout {
        public GeneraliCallout(Object params) {
            super(params);
            validateRequest(params);
            endpointData = [
                SELECT DeveloperName, ONE_Resource__c, ONE_Active__c, ONE_Named_Credentials__c, ONE_LogActive__c
                FROM ONE_Integration_endpoint__mdt
                WHERE DeveloperName = :ONE_CommonConstants.CM_GENERALI_OPEN_LIFE_CLAIM
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        }
    }

    public class CajamarCallout extends ONE_InsuranceIntegrationCallout.CajamarInsuranceCallout {
        public CajamarCallout(Object params) {
            super(params);
            validateRequest(params);
            endpointData = [
                SELECT DeveloperName, ONE_Resource__c, ONE_Active__c, ONE_Named_Credentials__c, ONE_LogActive__c
                FROM ONE_Integration_endpoint__mdt
                WHERE DeveloperName = :ONE_CommonConstants.CM_CAJAMAR_OPEN_LIFE_CLAIM
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        }
    }

    public class KutxabankCallout extends ONE_InsuranceIntegrationCallout.KutxabankInsuranceCallout {
        public KutxabankCallout(Object params) {
            super(params);
            endpointData = [
                SELECT DeveloperName, ONE_Resource__c, ONE_Active__c, ONE_Named_Credentials__c, ONE_LogActive__c
                FROM ONE_Integration_endpoint__mdt
                WHERE DeveloperName = :ONE_CommonConstants.CM_MIDDLEWARE_KBS_AS
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        }
    }

    public class KutxabankCalloutBatch extends ONE_InsuranceIntegrationCallout.KutxabankInsuranceCallout {
        public KutxabankCalloutBatch(Object params) {
            super(params);
            endpointData = [
                SELECT DeveloperName, ONE_Resource__c, ONE_Active__c, ONE_Named_Credentials__c, ONE_LogActive__c
                FROM ONE_Integration_endpoint__mdt
                WHERE DeveloperName = :ONE_CommonConstants.CM_MIDDLEWARE_KBS_AS_NOLOGS
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        }
    }

    private static void validateRequest(Object params) {
        ONE_OpenLifeClaimIntegrationService.RequestWrapper requestWrapper = (ONE_OpenLifeClaimIntegrationService.RequestWrapper) params;

        if (requestWrapper.policy != null && requestWrapper.policy.policy != null && requestWrapper.policy.policy.length() > POLICY_MAX_LENGTH) {
            throw new ONE_OpenLifeClaimIntegrationCalloutException(String.format(DATA_TOO_LONG, new List<String> {'policy.policy', '9', requestWrapper.policy.policy}));
        }
        if (requestWrapper.policy != null && requestWrapper.policy.cia != null && requestWrapper.policy.cia.length() > CIA_MAX_LENGTH) {
            throw new ONE_OpenLifeClaimIntegrationCalloutException(String.format(DATA_TOO_LONG, new List<String> {'policy.cia', String.valueOf(CIA_MAX_LENGTH), requestWrapper.policy.cia}));
        }
        if (requestWrapper.policy != null && requestWrapper.policy.branch != null && requestWrapper.policy.branch.length() > BRANCH_MAX_LENGTH) {
            throw new ONE_OpenLifeClaimIntegrationCalloutException(String.format(DATA_TOO_LONG, new List<String> {'policy.branch', String.valueOf(BRANCH_MAX_LENGTH), requestWrapper.policy.branch}));
        }
    }

    public class ONE_OpenLifeClaimIntegrationCalloutException extends Exception {}
}
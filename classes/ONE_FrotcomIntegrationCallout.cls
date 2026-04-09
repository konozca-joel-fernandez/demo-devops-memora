public with sharing class ONE_FrotcomIntegrationCallout extends ONE_Integration.IntegrationCallout {
    private static final String PARAM_API_KEY = 'api_key';
    
    public ONE_FrotcomIntegrationCallout(ONE_Integration.RestMethod restMethod) {
        super(ONE_CommonConstants.CM_FROTCOM_AUTHORIZE, restMethod);
    }

    
    public class FrotcomAuthorizeCallout extends ONE_Integration.IntegrationCallout {
        public FrotcomAuthorizeCallout() {
            super(ONE_CommonConstants.CM_FROTCOM_AUTHORIZE, ONE_Integration.RestMethod.POST);
            ONE_FrotcomCredentials__c integrationCredentials = ONE_FrotcomCredentials__c.getInstance();
            Map<String, String> loginRequest = new Map<String, String> {
                'provider' => integrationCredentials.ONE_Provider__c,
                'username' => integrationCredentials.ONE_Username__c,
                'password' => integrationCredentials.ONE_Password__c
            };
            setBody(JSON.serialize(loginRequest));
            putHeader(ONE_Integration.HEADER_CT, ONE_Integration.CT_JSON);
        }
    }
    
    public class FrotcomSendTasksCallout extends ONE_Integration.IntegrationCallout {
        public FrotcomSendTasksCallout(List<ONE_FrotcomIntegrationService.RequestWrapperItem> requestWrapperItems) {
            super(ONE_CommonConstants.CM_FROTCOM_SEND_TASKS, ONE_Integration.RestMethod.POST);
            validateRequest(requestWrapperItems);
            putParam(PARAM_API_KEY, getToken());
            putHeader(ONE_Integration.HEADER_CT, ONE_Integration.CT_JSON);
            String body = replaceTemporalWords(JSON.serialize(requestWrapperItems));
            setBody(body);
        }
    
        private void validateRequest(List<ONE_FrotcomIntegrationService.RequestWrapperItem> requestWrapperItems) {
            for (ONE_FrotcomIntegrationService.RequestWrapperItem item : requestWrapperItems) {
                if (String.isBlank(item.what.reference)) {
                    throw new FrotcomIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'reference'}));
                }
                /* we comment this validation because for Cases 'Recogida Judicial' we may not have Difunto field
                if (String.isBlank(item.what.content)) {
                    throw new FrotcomIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'content'}));
                }
                */
            }
        }
    
        public override HttpResponse invokeCallout() {
            return invokeCallout(false);
        }
    }
    
    private static String getToken() {

        FrotcomAuthorizeCallout callout = new FrotcomAuthorizeCallout();
        HttpResponse res = callout.invokeCallout(false);
        try {
            AuthorizeResponseWrapper authorizeResponse = (AuthorizeResponseWrapper)JSON.deserialize(res.getBody(), AuthorizeResponseWrapper.class);
            return authorizeResponse.token;
        } catch (Exception ex) {
            System.debug(ex);
            return '';
        }
    }
    
    
    //The JSON request contains words that are key words in Apex. This methods gets replace the temporal names with the actual one
    private static String replaceTemporalWords(String str) {
        str = str.replaceAll('whenParam', 'when');
        str = str.replaceAll('whereParam', 'where');
        str = str.replaceAll('endParam', 'end');
        return str;
    }
    
    private class AuthorizeResponseWrapper {
        public String token {public get; public set;}
    }
    
    public class FrotcomIntegrationCalloutException extends Exception {}
}
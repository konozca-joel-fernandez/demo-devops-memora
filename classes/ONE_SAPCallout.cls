/**
 * Created by mbujak003 on 31.01.2021.
 */
//Class for the request used in all SAP Integration
public abstract class ONE_SAPCallout extends ONE_Integration.IntegrationCallout {

    public ONE_SAPCallout(String endpointMetadataName, ONE_Integration.RestMethod restMethod, String scope) {
        super(endpointMetadataName, restMethod); // Get Enpoint and Method to call
        putHeader(ONE_Integration.HEADER_CT, ONE_Integration.CT_JSON);
        putHeader(ONE_Integration.HEADER_ACCEPT, ONE_Integration.CT_JSON);
        putHeader(ONE_Integration.HEADER_X_REQUESTED_WITH, 'X');
        putHeader(ONE_Integration.HEADER_AUTHORIZATION, 'Bearer ' + getAccessToken(scope));
    }


    
   public String getAccessToken(String scope) {
        Set<String> availableScopes = new Set<String>{
            'ZCRM_ELECTIUM_CLIENTES_SRV_0001',
            'ZONE_CANCELCONSUMO_SRV_0001',
            'ZONE_CANCELINVOICE_SRV_0001',
            'ZONE_CANCELSTOCK_SRV_0001',
            'ZONE_CONSUMOS_SRV_0001',
            'ZONE_CUSTOMER_SRV_0001',
            'ZONE_ELECTIUM_COBROS_SRV_0001',
            'ZONE_ELECTIUM_MES_COBROS_SRV_0001',
            'ZONE_ELECTIUM_SRV_0001',
            'ZONE_PAYMENT_SRV_0001',
            'ZONE_PURCHASEORDER_SRV_01_0001',
            'ZONE_SALESORDER_SRV_0001',
            'ZONE_SEPA_SRV_0001',
            'ZONE_STOCK_SRV_0001',
            'ZONE_TRASLADOSMAT_SRV_0001'
        };
        if (!availableScopes.contains(scope)) {
            throw new SapAuthenticationException(scope + ' is not on the list ov available scopes');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP/sap/bc/sec/oauth2/token?sap-client=100');
        req.setMethod('POST');
        req.setHeader(ONE_Integration.HEADER_CT, ONE_Integration.CT_APP_ENC);
        req.setHeader(ONE_Integration.HEADER_ACCEPT, ONE_Integration.CT_JSON);
        req.setHeader(ONE_Integration.HEADER_X_REQUESTED_WITH, 'X');
       
        ONE_Integration_Credential__mdt credentials = [SELECT ONE_ClientID__c, ONE_ClientSecret__c FROM ONE_Integration_Credential__mdt WHERE DeveloperName = 'SAP'];
        String basicAuth = 'Basic ' + EncodingUtil.base64Encode(
            Blob.valueOf(credentials.ONE_ClientID__c + ':' + credentials.ONE_ClientSecret__c)
        );
        req.setHeader(ONE_Integration.HEADER_AUTHORIZATION, basicAuth);

        String body = 'grant_type=client_credentials&scope=' + scope;
        req.setBody(body);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == ONE_CommonConstants.HTPP_SUCCESS_CODE) {
            SapAuthenticationResponse response = (SapAuthenticationResponse)JSON.deserialize(res.getBody(), SapAuthenticationResponse.class);
            return response.access_token;
        } else {
            throw new SapAuthenticationException('Authentication request unsuccessful.\nStatus code: ' + res.getStatusCode() + '\nStatus: ' + res.getStatus() + '\nBody: ' + res.getBody());
        }
    }

    private class SapAuthenticationResponse {
        String access_token;
        Integer expires_in;
        String scope;
        String token_type;
    }

    private class SapAuthenticationException extends Exception {
    }
}
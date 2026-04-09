/**
 * Created by mbujak003 on 25.06.2021.
 */
//SAP autorization class definition 
public with sharing class ONE_SapAuthorizeService {
	//Autorization callout extend SAP callout for basic method
    public class SapAuthorizeCallout extends ONE_SAPCallout {
        public SapAuthorizeCallout(String filters) {
            super(ONE_CommonConstants.CM_SAP_OAUTH, ONE_Integration.RestMethod.POST, null);

            Map<String, Object> parsedParams = (Map<String, Object>)JSON.deserializeUntyped(filters);
			//Request data population
            String responseType = (string)parsedParams.get('responseType');
            String clientId = (string)parsedParams.get('clientId');
            String redirect_uri = (string)parsedParams.get('redirectUri');
            String scope = (string)parsedParams.get('scope');
            String state = (string)parsedParams.get('state');

            /*putParam('response_type', EncodingUtil.urlEncode(responseType, ONE_Integration.ENCODING_UTF8));
            putParam('client_id', EncodingUtil.urlEncode(clientId, ONE_Integration.ENCODING_UTF8));
            putParam('redirect_uri', EncodingUtil.urlEncode(redirect_uri, ONE_Integration.ENCODING_UTF8));
            putParam('scope', EncodingUtil.urlEncode(scope, ONE_Integration.ENCODING_UTF8));
            putParam('state', EncodingUtil.urlEncode(state, ONE_Integration.ENCODING_UTF8));*/
			
            //Add parameter to the response
            putParam('response_type', responseType);
            putParam('client_id', clientId);
            putParam('redirect_uri', redirect_uri);
            putParam('scope', scope);
            putParam('state', state);
        }
		//Build endpoint using cutom metada integration endpoint
        public override String buildEndpoint() {
            String endpoint = super.buildEndpoint();
            if(!params.isEmpty()) {
                String paramString = '?';
                for(String key : params.keySet()) {
                    paramString += String.format('{0}={1}&', new List<String>{ key, String.valueOf(params.get(key)) });
                }
                endpoint += paramString.removeEnd('&');
            }
            return endpoint;
        }
    }

}
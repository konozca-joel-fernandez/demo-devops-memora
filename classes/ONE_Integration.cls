public without sharing class ONE_Integration {

    /*
    TODO: proper exception handling using custom objects + integration logs
    */
    public enum RestMethod {
        POST,
        GET,
        PUT,
        DEL
    }
    
    public static final String METHOD_DELETE = 'DELETE'; //delete is a keyword, it cannot be used as enum
    public static final String HEADER_VINSHIELD = 'X-VinShieldPublic';
    public static final String HEADER_AUTHORIZATION = 'Authorization';
    public static final String HEADER_CT = 'Content-Type';
    public static final String HEADER_ACCEPT = 'Accept';
    public static final String HEADER_X_REQUESTED_WITH = 'X-Requested-With';
    public static final String HEADER_ACCEPT_CHARSET = 'Accept-Charset';
    public static final String HEADER_CHARSET = 'Charset';
    
    public static final String TOKEN = 'token';

    public static final String CT_JSON = 'application/json';
    public static final String CT_TEXT_XML = 'text/xml';
    public static final String CT_APP_XML = 'application/xml';
    public static final String CT_APP_ENC = 'application/x-www-form-urlencoded';
    public static final String VINSHIELD = 'vinshield';

    public static final String ENCODING_UTF8 = 'utf-8';

    public abstract class IntegrationCallout {

        public ONE_Integration_endpoint__mdt endpointData { get; protected set; }
        public RestMethod method { get; private set; }

        public Map<String, Object> headers { get; private set; }
        public Map<String, Object> params { get; private set; }

        public String body { get; private set; }

        public Blob bodyBlob { get; private set; }

        private String resourceOverride;

        public IntegrationCallout(String endpointMetadataName, RestMethod restMethod) {
            endpointData = [
                SELECT DeveloperName, ONE_Resource__c, ONE_Active__c, ONE_Named_Credentials__c, ONE_LogActive__c
                FROM ONE_Integration_endpoint__mdt
                WHERE DeveloperName = :endpointMetadataName
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            headers = new Map<String, Object>();
            params = new Map<String, Object>();
            method = restMethod;
        }

        public void setBody(String jsonBody) {
            body = jsonBody;
        }

        public void setBodyAsBlob(Blob blobBody) { 
            body = null;
            bodyBlob = blobBody; 
        }

        public void putHeaders(Map<String, Object> newHeaders) {
            headers.putAll(newHeaders);
        }

        public void putHeader(String key, Object value) {
            headers.put(key, value);
        }

        public void putParam(String key, Object value) {
            params.put(key, value);
        }

        public void setResource(String resource) { 
            resourceOverride = resource; 
        }

        protected Boolean isActive() {
            return endpointData != null && (endpointData.ONE_Active__c || Test.isRunningTest());
        }

        protected Boolean isLogActive() {
            return endpointData != null && (endpointData.ONE_LogActive__c);
        }

        @TestVisible
        protected HttpRequest buildRequest() {
            HttpRequest req = new HttpRequest();
            String httpMethod = (method == RestMethod.DEL) ? METHOD_DELETE : String.valueOf(method);
            req.setMethod(httpMethod);
            req.setEndpoint(buildEndpoint());
            for(String key : headers.keySet()) {
                req.setHeader(key, String.valueOf(headers.get(key)));
            }
            if(body != null) {
                req.setBody(body);
            } else if (bodyBlob != null) { 
                req.setBodyAsBlob(bodyBlob); 
            }
            if (bodyBlob != null) {
                System.debug('[BINARY BODY - ' + bodyBlob.size() + ' bytes]');
            } else {
                System.debug(req.getBody());
            }
            System.debug(headers);
            req.setTimeout(120000);
            System.debug(req);
            return req;
        }
        public virtual HttpResponse invokeCallout() {
            return invokeCallout(true);
        }

       
        public virtual HttpResponse invokeCallout(Boolean asyncLog) { 
            if(!isActive()) {
                throw new ONE_Exception(
                    ONE_Exception.ExceptionType.INTEGRATION,
                    String.format(
                        'Integration endpoint {0} is inactive',
                        new List<String>{
                            endpointData.ONE_Named_Credentials__c + '.' + endpointData.ONE_Resource__c
                        }
                    )
                );
            }

            HttpRequest request = buildRequest();
            HttpResponse response = new Http().send(request);
			

            
            if(isLogActive()) {

                String requestBodyForLog;

                if (bodyBlob != null) {
                    requestBodyForLog = '[BINARY BODY - ' + bodyBlob.size() + ' bytes]';
                } else {
                    requestBodyForLog = request.getBody();
                }

                ONE_IntegrationLog integrationLog = new ONE_IntegrationLog(
                    String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')),
                    requestBodyForLog,
                    response.getBody(),
                    request.getMethod(),
                    request.getEndpoint(),
                    ONE_IntegrationLog.Direction.OUTBOUND,
                    response.getStatusCode().toString()
                );
                

                ONE_IntegrationLog.commitLog(integrationLog, asyncLog, true);
            }
            return response;
        }


        public virtual String buildEndpoint() {
            String endpoint;
            if(endpointData.ONE_Named_Credentials__c != null){
                endpoint = String.format(
                    'callout:{0}{1}',
                    new List<String> {
                        endpointData.ONE_Named_Credentials__c,
                        resourceOverride != null ? resourceOverride : endpointData.ONE_Resource__c
                    }
                );
            } else {
                endpoint = resourceOverride != null 
                    ? resourceOverride 
                    : endpointData.ONE_Resource__c;
            }        

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
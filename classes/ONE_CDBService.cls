/**
 * Created by mchruscick001 on 05.10.2021 13:33.
 */

public with sharing class ONE_CDBService {
    static final String CDB_RESERVATION_ENDPOINT_METADATA_NAME = 'CDB_RESERVATION';
    static final String CDB_CONTRACT_ENDPOINT_METADATA_NAME = 'CDB_CONTRACT';
    static final String CDB_GRAVE_STATUS_ENDPOINT_METADATA_NAME = 'CDB_GRAVE_STATUS';
    static final String CONTENT_TYPE = 'Content-Type', CONTENT_TYPE_APP_SOAP_XML = 'application/soap+xml';

    public static Dom.Document callCDBService(String metadataEndpointName, String method, Dom.Document body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ONE_IntegrationEndpointSelector.selectIntegrationEndpoint(metadataEndpointName).ONE_Resource__c);
        req.setMethod(method);
        req.setBody(body.toXmlString());
        req.setHeader(CONTENT_TYPE, CONTENT_TYPE_APP_SOAP_XML);
        req.setTimeout(120000);
        HttpResponse res = new Http().send(req);
        ONE_CommonUtils.createInboundIntegrationLog(metadataEndpointName, req.getBody(), res.getBody(), req.getMethod(), metadataEndpointName);
        return res.getBodyDocument();
    }
    
    public static Dom.Document callCDBReservationService(Dom.Document body) {
        return callCDBService(CDB_RESERVATION_ENDPOINT_METADATA_NAME, ONE_CommonConstants.HTTP_METHOD_POST, body);
    }
    
    public static Dom.Document callCDBContractService(Dom.Document body) {
        return callCDBService(CDB_CONTRACT_ENDPOINT_METADATA_NAME, ONE_CommonConstants.HTTP_METHOD_POST, body);
    }

    public static Dom.Document callCDBGraveStatusService(Dom.Document body) {
        return callCDBService(CDB_GRAVE_STATUS_ENDPOINT_METADATA_NAME, ONE_CommonConstants.HTTP_METHOD_POST, body);
    }
}
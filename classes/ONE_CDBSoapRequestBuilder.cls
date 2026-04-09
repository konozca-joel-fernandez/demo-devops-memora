/**
 * Created by mchruscick001 on 04.10.2021 14:51.
 */

public with sharing class ONE_CDBSoapRequestBuilder {
    static final String SOAP_DEFAULT_URL = 'http://tempuri.org/';
    static final String SOAP_ENVELOPE_W3_URL = 'http://www.w3.org/2003/05/soap-envelope';
    static final String SOAP12_ENV = 'SOAP12-ENV';
    static final String SOAP_ENVELOPE_POSTFIX = ':Envelope';
    static final String SOAP_BODY_POSTFIX = ':Body';
    static final String SOAP_XMLNS_PREFIX = 'xmlns';
    static final String SOAP_FJS1_PREFIX = 'fjs1';
    static final String SOAP_PARAMETRES_PARAMETER = 'parametres';
    static final String SOAP_DOCUMENT_PARAMETER = 'document';
    static final String EMPTY_VALUE = '';

    static final String XMLNS_SOAP12_ENV = SOAP_XMLNS_PREFIX + ':' + SOAP12_ENV;
    static final String SOAP12_ENV_ENVELOPE = SOAP12_ENV + SOAP_ENVELOPE_POSTFIX;
    static final String SOAP12_ENV_BODY = SOAP12_ENV + SOAP_BODY_POSTFIX;
    static final String XMLNS_FJS1 = SOAP_XMLNS_PREFIX + ':' + SOAP_FJS1_PREFIX;
    static final String FJS1_PARAMETRES = SOAP_FJS1_PREFIX + ':' + SOAP_PARAMETRES_PARAMETER;
    
    public static Dom.XmlNode buildRequestBodyBase(Dom.Document soapXMLDocument) {
        Dom.XmlNode soapEnvelope = soapXMLDocument.createRootElement(SOAP12_ENV_ENVELOPE, null, null);
        soapEnvelope.setAttribute(XMLNS_SOAP12_ENV, SOAP_ENVELOPE_W3_URL);
        Dom.XmlNode soapBody = soapEnvelope.addChildElement(SOAP12_ENV_BODY, null, null);
        Dom.XmlNode soapParameters = addChildElementWithParameter(soapBody, FJS1_PARAMETRES, new Map<String, String> {XMLNS_FJS1 => SOAP_DEFAULT_URL});
        Dom.XmlNode soapDocument = addChildElementWithParameter(soapParameters, SOAP_DOCUMENT_PARAMETER, new Map<String, String> {SOAP_XMLNS_PREFIX => SOAP_DEFAULT_URL});
        return soapDocument;
    }

    static Dom.XmlNode addChildElementWithParameter(Dom.XmlNode parentNode, String childElementName, Map<String, String> childElementParameter2Value) {
        Dom.XmlNode childNode = parentNode.addChildElement(childElementName, null, null);
        for (String childElementParameter : childElementParameter2Value.keySet()) {
            childNode.setAttribute(childElementParameter, childElementParameter2Value.get(childElementParameter));
        }
        return childNode;
    }

    public static void addChildElementWithValue(Dom.XmlNode parentNode, String childElementName, String childElementValue) {
        parentNode.addChildElement(childElementName, null, null).addTextNode(String.isNotBlank(childElementValue) ? childElementValue : EMPTY_VALUE);
    }
}
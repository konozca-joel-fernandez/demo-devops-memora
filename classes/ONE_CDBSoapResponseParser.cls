/**
 * Created by mchruscick001 on 05.10.2021 13:01.
 */

public with sharing class ONE_CDBSoapResponseParser {
    static final String SOAP_ENVELOPE_NAMESPACE = 'http://www.w3.org/2003/05/soap-envelope', SOAP_DEFAULT_NAMESPACE = 'http://tempuri.org/';
    static final String BODY_NODE_NAME = 'Body', RETURN_NODE_NAME = 'retorn', DOCUMENT_NODE_NAME = 'document';
    
    public static List<Dom.XmlNode> getResponseDocument(Dom.Document responseDom){
        return responseDom.getRootElement()
                ?.getChildElement(BODY_NODE_NAME, SOAP_ENVELOPE_NAMESPACE)
                ?.getChildElement(RETURN_NODE_NAME, SOAP_DEFAULT_NAMESPACE)
                ?.getChildElement(DOCUMENT_NODE_NAME, SOAP_DEFAULT_NAMESPACE)
                ?.getChildElements();
    }

    public static String getValueByNameIfNotEmpty(Dom.XmlNode node, String nodeName) {
        return node.getName() == nodeName && String.isNotBlank(node.getText()) ? node.getText() : null;
    }

    public static String assignNewValueIfOldIsBlank(Dom.XmlNode documentNode, String value, String valueName) {
        return String.isBlank(value) ? ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, valueName) : value;
    }
}
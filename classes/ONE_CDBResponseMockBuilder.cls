/**
 * Created by mchruscick001 on 11.10.2021 14:00.
 */

public with sharing class ONE_CDBResponseMockBuilder {
    final String SOAP_DEFAULT_URL = 'http://tempuri.org/';
    final String SOAP_ENVELOPE_W3_URL = 'http://www.w3.org/2003/05/soap-envelope';
    final String SOAP12_ENV = 'SOAP12-ENV';
    final String SOAP_ENVELOPE_POSTFIX = ':Envelope', SOAP_BODY_POSTFIX = ':Body';
    final String SOAP_XMLNS_PREFIX = 'xmlns', SOAP_FJS1_PREFIX = 'fjs1';
    final String SOAP_RETURN_PARAMETER = 'retorn', SOAP_DOCUMENT_PARAMETER = 'document';

    final String XMLNS_SOAP12_ENV = SOAP_XMLNS_PREFIX + ':' + SOAP12_ENV;
    final String SOAP12_ENV_ENVELOPE = SOAP12_ENV + SOAP_ENVELOPE_POSTFIX;
    final String SOAP12_ENV_BODY = SOAP12_ENV + SOAP_BODY_POSTFIX;
    final String XMLNS_FJS1 = SOAP_XMLNS_PREFIX + ':' + SOAP_FJS1_PREFIX;
    final String FJS1_RETURN_PARAMETRES = SOAP_FJS1_PREFIX + ':' + SOAP_RETURN_PARAMETER;

    @TestVisible
    final static String
            GRAVE_RESPONSE_STATUS_OK = 'KO',
            GRAVE_RESPONSE_MESSAGE = 'La sepultura té rebuts pendents per import de 65,87 euros.',
            GRAVE_RESPONSE_AMOUNT = '65,87',
            GRAVE_RESPONSE_CODE = ONE_TestDataFactory.getRandomName();

    @TestVisible
    final static String
            RESPONSE_SUCCESSFUL_ANULATION_MESSAGE = 'ELIMINACIÓN DE RESERVA REALIZADA CORRECTAMENTE',
            RESPONSE_SUCCESSFUL_RESERVATION_MESSAGE = 'RESERVA REALIZADA CORRECTAMENTE',
            SELECTED_CEMETERY_CODE = '2',
            REQUEST_CANCELATION_TYPE = 'X',
            RESPONSE_MESSAGE_CRITICALITY_OK_CODE = 'C',
            RESERVATION_DATE = '12/12/2012', RESERVATION_TIME = '12:12',
            AVAILABLE_HOUR_0 = '12:00', AVAILABLE_HOUR_1 = '12:30';

    @TestVisible
    final static String
            RESPONSE_CONTRACT_REQUEST_NUMBER = String.valueOf(Math.round((Math.random() * 1000))),
            RESPONSE_CONTRACT_BURIAL_CODE = String.valueOf(Math.round((Math.random() * 1000))),
            RESPONSE_CONTRACT_ERROR_MESSAGE = 'No s\'ha trobat cap sepultura que coincideixi amb els paràmetres enviats',
            RESPONSE_CONTRACT_ERROR_VALIDITY = 'E',
            RESPONSE_CONTRACT_COMPONENT_NAME = ONE_TestDataFactory.getRandomName(), RESPONSE_CONTRACT_COMPONENT_2_NAME = ONE_TestDataFactory.getRandomName(1),
            RESPONSE_CONTRACT_COMPONENT_QUANTITY = '1', RESPONSE_CONTRACT_COMPONENT_2_QUANTITY = '6',
            RESPONSE_CONTRACT_COMPONENT_HEADLINE = '1', RESPONSE_CONTRACT_COMPONENT_2_HEADLINE = '2', RESPONSE_CONTRACT_COMPONENT_3_HEADLINE = '3', RESPONSE_CONTRACT_COMPONENT_4_HEADLINE = '4',
            RESPONSE_CONTRACT_COMPONENT_GROSS_AMOUNT = '11.22', RESPONSE_CONTRACT_COMPONENT_2_GROSS_AMOUNT = '33.44';
    @TestVisible
    final static String MATCHING_DOCUMENT_ID = 'A', MATCHING_CIF_ID = 'D';
    final static String BUSINESS_INVOICE_TYPE = '3', PERSONAL_INVOICE_TYPE = '2';
    
    public String buildGraveStatusResponse() {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildResponseBodyBase(soapXMLDocument);
        addChildElementWithValue(soapDocument, ONE_CDBGraveStatusResponseParser.GRAVE_STATUS_RESPONSE_STATUS, GRAVE_RESPONSE_STATUS_OK);
        addChildElementWithValue(soapDocument, ONE_CDBGraveStatusResponseParser.GRAVE_STATUS_RESPONSE_MESSAGE, GRAVE_RESPONSE_MESSAGE);
        addChildElementWithValue(soapDocument, ONE_CDBGraveStatusResponseParser.GRAVE_STATUS_RESPONSE_PENDING_AMOUNT, GRAVE_RESPONSE_AMOUNT);
        addChildElementWithValue(soapDocument, ONE_CDBGraveStatusResponseParser.GRAVE_STATUS_RESPONSE_CODE, GRAVE_RESPONSE_CODE);
        return soapXMLDocument.toXmlString();
    }

    public String buildContractWithErrorsResponse() {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildResponseBodyBase(soapXMLDocument);
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_RETURN, getBuildErrorMap());
        return soapXMLDocument.toXmlString();
    }

    public String buildContractWithoutErrorsResponse() {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildResponseBodyBase(soapXMLDocument);
        addChildElementWithValue(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_PETICIO, RESPONSE_CONTRACT_REQUEST_NUMBER);
        addChildElementWithValue(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_SEPULTURA, RESPONSE_CONTRACT_BURIAL_CODE);
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENTS, getBuildComplementsMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENTS, getBuildComplementsSecondMap());
        return soapXMLDocument.toXmlString();
    }

    public String buildContractWithProductsAndInvoicesWithoutErrorsResponse() {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildResponseBodyBase(soapXMLDocument);
        addChildElementWithValue(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_PETICIO, RESPONSE_CONTRACT_REQUEST_NUMBER);
        addChildElementWithValue(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_SEPULTURA, RESPONSE_CONTRACT_BURIAL_CODE);
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_INVOICE, getBuildInvoicesMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_INVOICE, getBuildInvoicesSecondMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_INVOICE, getBuildInvoicesThirdMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_INVOICE, getBuildInvoicesFourthMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENTS, getBuildComplementsMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENTS, getBuildComplementsSecondMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENTS, getBuildComplementsThirdMap());
        addChildNodeWithElements(soapDocument, ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENTS, getBuildComplementsFourthMap());
        return soapXMLDocument.toXmlString();
    }
    
    public String buildCancelResponse() {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildResponseBodyBase(soapXMLDocument);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.ERROR_WARNING_MESSAGES_NODE_NAME, RESPONSE_SUCCESSFUL_ANULATION_MESSAGE);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.CRITICALITY_ERROR_WARNING_MESSAGES_NODE_NAME, RESPONSE_MESSAGE_CRITICALITY_OK_CODE);
        return soapXMLDocument.toXmlString();
    }

    public String buildGetAvailableTimesResponse() {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildResponseBodyBase(soapXMLDocument);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.AVAILABLE_INCINERATION_HOUR_NODE_NAME, AVAILABLE_HOUR_0);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.AVAILABLE_INCINERATION_HOUR_NODE_NAME, AVAILABLE_HOUR_1);
        return soapXMLDocument.toXmlString();
    }

    public String buildMakeAnReservationResponse() {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildResponseBodyBase(soapXMLDocument);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.DECEASED_PERSON_ID_NODE_NAME, ONE_ExpedienteTestDataFactory.DEFAULT_UNIQUE_RESERVATION_ID);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.ERROR_WARNING_MESSAGES_NODE_NAME, RESPONSE_SUCCESSFUL_RESERVATION_MESSAGE);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.CRITICALITY_ERROR_WARNING_MESSAGES_NODE_NAME, RESPONSE_MESSAGE_CRITICALITY_OK_CODE);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.RESERVED_INCINERATION_PLACE_CODE_NODE_NAME, SELECTED_CEMETERY_CODE);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.RESERVED_INCINERATION_DATE_NODE_NAME, RESERVATION_DATE);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.RESERVED_INCINERATION_TIME_NODE_NAME, RESERVATION_TIME);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.FUNERAL_TYPE_NODE_NAME, ONE_CDBReservationService.INCINERATION_SHORT);
        addChildElementWithValue(soapDocument, ONE_CDBReservationResponseParser.BURIAL_TYPE_NODE_NAME, ONE_CDBReservationService.DEFAULT_BURIAL_TYPE);
        return soapXMLDocument.toXmlString();
    }

    Dom.XmlNode buildResponseBodyBase(Dom.Document soapXMLDocument) {
        Dom.XmlNode soapEnvelope = soapXMLDocument.createRootElement(SOAP12_ENV_ENVELOPE, null, null);
        soapEnvelope.setAttribute(XMLNS_SOAP12_ENV, SOAP_ENVELOPE_W3_URL);
        Dom.XmlNode soapParameters = addChildElementWithParameter(
                soapEnvelope.addChildElement(SOAP12_ENV_BODY, null, null), FJS1_RETURN_PARAMETRES, new Map<String, String>{XMLNS_FJS1 => SOAP_DEFAULT_URL}
        );
        Dom.XmlNode soapDocument = addChildElementWithParameter(soapParameters, SOAP_DOCUMENT_PARAMETER, new Map<String, String>{SOAP_XMLNS_PREFIX => SOAP_DEFAULT_URL});
        return soapDocument;
    }

    Dom.XmlNode addChildElementWithParameter(Dom.XmlNode parentNode, String childElementName, Map<String, String> childElementParameter2Value) {
        Dom.XmlNode childNode = parentNode.addChildElement(childElementName, null, null);
        for (String childElementParameter : childElementParameter2Value.keySet()) {
            childNode.setAttribute(childElementParameter, childElementParameter2Value.get(childElementParameter));
        }
        return childNode;
    }

    void addChildElementWithValue(Dom.XmlNode parentNode, String childElementName, String childElementValue) {
        parentNode.addChildElement(childElementName, null, null).addTextNode(childElementValue);
    }

    void addChildNodeWithElements(Dom.XmlNode parentNode, String childNodeName, Map<String, String> name2Value) {
        Dom.XmlNode childNode = parentNode.addChildElement(childNodeName, null, null);
        for (String nodeName : name2Value.keySet()) {
            childNode.addChildElement(nodeName, null, null).addTextNode(name2Value.get(nodeName));
        }
    }

    Map<String, String> getBuildComplementsMap() {
        return getBuildComplementsMap(RESPONSE_CONTRACT_COMPONENT_NAME, RESPONSE_CONTRACT_COMPONENT_QUANTITY, RESPONSE_CONTRACT_COMPONENT_GROSS_AMOUNT, RESPONSE_CONTRACT_COMPONENT_HEADLINE);
    }
    
    Map<String, String> getBuildComplementsSecondMap() {
        return getBuildComplementsMap(RESPONSE_CONTRACT_COMPONENT_2_NAME, RESPONSE_CONTRACT_COMPONENT_2_QUANTITY, RESPONSE_CONTRACT_COMPONENT_2_GROSS_AMOUNT, RESPONSE_CONTRACT_COMPONENT_2_HEADLINE);
    }

    Map<String, String> getBuildComplementsThirdMap() {
        return getBuildComplementsMap(RESPONSE_CONTRACT_COMPONENT_2_NAME, RESPONSE_CONTRACT_COMPONENT_2_QUANTITY, RESPONSE_CONTRACT_COMPONENT_2_GROSS_AMOUNT, RESPONSE_CONTRACT_COMPONENT_3_HEADLINE);
    }

    Map<String, String> getBuildComplementsFourthMap() {
        return getBuildComplementsMap(RESPONSE_CONTRACT_COMPONENT_2_NAME, RESPONSE_CONTRACT_COMPONENT_2_QUANTITY, RESPONSE_CONTRACT_COMPONENT_2_GROSS_AMOUNT, RESPONSE_CONTRACT_COMPONENT_4_HEADLINE);
    }

    Map<String, String> getBuildInvoicesMap() {
        return getBuildInvoiceMap(RESPONSE_CONTRACT_COMPONENT_HEADLINE, MATCHING_DOCUMENT_ID, PERSONAL_INVOICE_TYPE);
    }
    
    Map<String, String> getBuildInvoicesSecondMap() {
        return getBuildInvoiceMap(RESPONSE_CONTRACT_COMPONENT_4_HEADLINE, 'B', BUSINESS_INVOICE_TYPE);
    }

    Map<String, String> getBuildInvoicesThirdMap() {
        return getBuildInvoiceMap(RESPONSE_CONTRACT_COMPONENT_3_HEADLINE, 'C', PERSONAL_INVOICE_TYPE);
    }

    Map<String, String> getBuildInvoicesFourthMap() {
        return getBuildInvoiceMap(RESPONSE_CONTRACT_COMPONENT_2_HEADLINE, MATCHING_CIF_ID, BUSINESS_INVOICE_TYPE);
    }

    Map<String, String> getBuildComplementsMap(String articleCode, String quantity, String grossAmount, String headline) {
        return new Map<String, String>{
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENT_ARTICLE_CODE => articleCode,
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENT_QUANTITY => quantity,
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENT_GROSS_AMOUNT => grossAmount,
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_COMPLEMENT_LINE_HOLDER_CODE => headline
        };
    }

    Map<String, String> getBuildInvoiceMap(String invoiceCode, String invoiceDocumentNumber, String invoiceDocumentType) {
        return new Map<String, String>{
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_TITULAR_FRA_CODE => invoiceCode,
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_TITULAR_FRA_DOCUMENT_NUMBER => invoiceDocumentNumber,
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_TITULAR_FRA_DOCUMENT_TYPE => invoiceDocumentType,
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_TITULAR_FRA_NAME_1 => 'Last Name',
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_TITULAR_FRA_NAME => 'Name'
        };
    }

    Map<String, String> getBuildErrorMap() {
        return new Map<String, String>{
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_ERROR_VALIDITY => RESPONSE_CONTRACT_ERROR_VALIDITY,
                ONE_CDBContractResponseParser.CONTRACT_RESPONSE_NODE_ERROR_MESSAGE => RESPONSE_CONTRACT_ERROR_MESSAGE
        };
    }
}
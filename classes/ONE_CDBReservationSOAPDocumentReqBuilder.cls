public with sharing class ONE_CDBReservationSOAPDocumentReqBuilder {
    
    public static Dom.XmlNode buildRequestBodyBase(DOM.Document soapXMLDocument) {
        return ONE_CDBSoapRequestBuilder.buildRequestBodyBase(soapXMLDocument);
    }
    
    public static Dom.Document buildCancelationBody(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildRequestBodyBase(soapXMLDocument);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcprosol', ONE_CDBReservationService.DEFAULT_IDENTIFICATION);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcususol', ONE_CDBReservationService.DEFAULT_USERNAME);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcdifunt', ONE_ExpedienteSelector.selectExpediente(reservationModel.expedienteId).ONE_Codigo_Difunto_CBSA__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rctipsol', reservationModel.reservationType);
        return soapXMLDocument;
    }
    
    public static Dom.Document buildReservationBody(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        ONE_CDBReservationService.ReservationParameters buildReservationParameters = ONE_CDBReservationService.buildReservationParameters(reservationModel);
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = buildRequestBodyBase(soapXMLDocument);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcprosol', buildReservationParameters.rcprosol);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcususol', buildReservationParameters.rcususol);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rctipsol', buildReservationParameters.rctipsol);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcdifunt', buildReservationParameters.rcdifunt);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rctipinh', buildReservationParameters.rctipinh);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcnom', buildReservationParameters.rcnom);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rccog1', buildReservationParameters.rccog1);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcsexe', buildReservationParameters.rcsexe);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcnaixe', buildReservationParameters.rcnaixe);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcprovi', buildReservationParameters.rcprovi);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rctelef', buildReservationParameters.rctelef);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rccaumor', buildReservationParameters.rccaumor);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcdatdef', buildReservationParameters.rcdatdef);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rchordef', buildReservationParameters.rchordef);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcestdif', buildReservationParameters.rcestdif);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rctipser', buildReservationParameters.rctipser);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcdatinc', buildReservationParameters.rcdatinc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rchorinc', buildReservationParameters.rchorinc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcceminc', buildReservationParameters.rcceminc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcdatinh', buildReservationParameters.rcdatinh);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rchorinh', buildReservationParameters.rchorinh);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'rcceminh', buildReservationParameters.rcceminh);
        //ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'Dominicana', buildReservationParameters.Dominicana);
        return soapXMLDocument;
    }
}
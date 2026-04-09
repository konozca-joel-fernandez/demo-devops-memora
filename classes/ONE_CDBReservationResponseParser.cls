/**
 * Created by mchruscick001 on 24.09.2021 08:26.
 */

public with sharing class ONE_CDBReservationResponseParser {
    public static final String AVAILABLE_INHUMATION_HOUR_NODE_NAME = 'rchorinhdis', AVAILABLE_INCINERATION_HOUR_NODE_NAME = 'rchorincdis';
    static final String RESERVED_INHUMATION_DATE_NODE_NAME = 'rcdatinh', RESERVED_INHUMATION_TIME_NODE_NAME = 'rchorinh';
    public static final String RESERVED_INCINERATION_DATE_NODE_NAME = 'rcdatinc', RESERVED_INCINERATION_TIME_NODE_NAME = 'rchorinc';
    public static final String RESERVED_INHUMATION_PLACE_CODE_NODE_NAME = 'rcceminh', RESERVED_INCINERATION_PLACE_CODE_NODE_NAME = 'rcceminc';
    public static final String ERROR_WARNING_MESSAGES_NODE_NAME = 'missatges', CRITICALITY_ERROR_WARNING_MESSAGES_NODE_NAME = 'rcestado';
    public static final String DECEASED_PERSON_ID_NODE_NAME = 'rcdifunt';
    public static final String FUNERAL_TYPE_NODE_NAME = 'rctipsol';
    public static final String BURIAL_TYPE_NODE_NAME = 'rctipinh';

    public static List<String> getAvailableHoursFromServiceResponse(Dom.Document serviceResponse) {
        List<String> availableHours = new List<String>();
        for (Dom.XmlNode fluxNode : ONE_CDBSoapResponseParser.getResponseDocument(serviceResponse)) {
            if (fluxNode.getName() == AVAILABLE_INHUMATION_HOUR_NODE_NAME || fluxNode.getName() == AVAILABLE_INCINERATION_HOUR_NODE_NAME) {
                availableHours.add(fluxNode.getText());
            }
        }
        return availableHours;
    }

    public static ONE_CDBReservationService.ReservationResponse extractReservationResponse(Dom.Document serviceResponse) {
        return getReservationResponse(ONE_CDBSoapResponseParser.getResponseDocument(serviceResponse));
    }
    
    static ONE_CDBReservationService.ReservationResponse getReservationResponse(List<Dom.XmlNode> responseDocument) {
        ONE_CDBReservationService.ReservationResponse reservationResponse = new ONE_CDBReservationService.ReservationResponse();
        for (Dom.XmlNode documentNode : responseDocument) {
            reservationResponse.deceasedPersonId = String.isBlank(reservationResponse.deceasedPersonId) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, DECEASED_PERSON_ID_NODE_NAME) :
                    reservationResponse.deceasedPersonId;
            reservationResponse.burialType = String.isBlank(reservationResponse.burialType) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, BURIAL_TYPE_NODE_NAME) :
                    reservationResponse.burialType;
            reservationResponse.funeralType = String.isBlank(reservationResponse.funeralType) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, FUNERAL_TYPE_NODE_NAME) :
                    reservationResponse.funeralType;
            reservationResponse.cemeteryCode = String.isBlank(reservationResponse.cemeteryCode) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, isFuneralOfInhumationType(reservationResponse.funeralType)  ? RESERVED_INHUMATION_PLACE_CODE_NODE_NAME : RESERVED_INCINERATION_PLACE_CODE_NODE_NAME) :
                    reservationResponse.cemeteryCode;
            reservationResponse.burialReservedDate = String.isBlank(reservationResponse.burialReservedDate) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, RESERVED_INHUMATION_DATE_NODE_NAME) :
                    reservationResponse.burialReservedDate;
            reservationResponse.incinerationReservedDate = String.isBlank(reservationResponse.incinerationReservedDate) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, RESERVED_INCINERATION_DATE_NODE_NAME) :
                    reservationResponse.incinerationReservedDate;
            reservationResponse.burialReservedTime = String.isBlank(reservationResponse.burialReservedTime) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, RESERVED_INHUMATION_TIME_NODE_NAME) :
                    reservationResponse.burialReservedTime;
            reservationResponse.incinerationReservedTime = String.isBlank(reservationResponse.incinerationReservedTime) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, RESERVED_INCINERATION_TIME_NODE_NAME) :
                    reservationResponse.incinerationReservedTime;
            reservationResponse.responseMessagesCriticality = String.isBlank(reservationResponse.responseMessagesCriticality) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, CRITICALITY_ERROR_WARNING_MESSAGES_NODE_NAME) :
                    reservationResponse.responseMessagesCriticality;
            reservationResponse.responseMessages = String.isBlank(reservationResponse.responseMessages) ?
                    ONE_CDBSoapResponseParser.getValueByNameIfNotEmpty(documentNode, ERROR_WARNING_MESSAGES_NODE_NAME) :
                    reservationResponse.responseMessages;
        }
        return reservationResponse;
    }

    static Boolean isFuneralOfInhumationType(String funeralType) {
        return funeralType == ONE_CDBReservationService.INHUMATION_SHORT;
    }
}
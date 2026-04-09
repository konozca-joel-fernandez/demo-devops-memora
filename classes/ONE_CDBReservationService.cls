public with sharing class ONE_CDBReservationService {
    public static final String DEFAULT_IDENTIFICATION = '998';
    public static final String DEFAULT_USERNAME = 'sfb-sa';
    static final String DEFAULT_CEMETERY_CODE = '2';

    public static final String INHUMATION_SHORT = 'E', INCINERATION_SHORT = 'I';
    static final String DEFAULT_TYPE_OF_SERVICE = 'PR';
    public static final String DEFAULT_BURIAL_TYPE = 'D', BURY_ASHES_BURIAL_TYPE = 'C';
    static final String EMPTY_VALUE = ONE_CDBRequestBuilderUtilities.EMPTY_VALUE;

    public static ReservationResponse cancelReservation(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        return ONE_CDBReservationResponseParser.extractReservationResponse(ONE_CDBService.callCDBReservationService(
                ONE_CDBReservationSOAPDocumentReqBuilder.buildCancelationBody(reservationModel))
        );
    }

    public static List<String> checkAvailableHours(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        return getAvailableHours(reservationModel);
    }

    public static ReservationResponse makeAnReservation(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        return getReservationInformation(reservationModel);
    }

    static ReservationResponse getReservationInformation(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        return ONE_CDBReservationResponseParser.extractReservationResponse(ONE_CDBService.callCDBReservationService(
                ONE_CDBReservationSOAPDocumentReqBuilder.buildReservationBody(reservationModel))
        );
    }

    static List<String> getAvailableHours(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        return ONE_CDBReservationResponseParser.getAvailableHoursFromServiceResponse(
                ONE_CDBService.callCDBReservationService(ONE_CDBReservationSOAPDocumentReqBuilder.buildReservationBody(reservationModel))
        );
    }
    
    static String returnEmptyIfNull(String stringValue) {
        return stringValue == null ? EMPTY_VALUE : stringValue;
    }
    
    public static ReservationParameters buildReservationParameters(ONE_CDBReservationModalController.ReservationModel reservationModel) {
        ONE_Expediente__c servicio = ONE_ExpedienteSelector.selectExpediente(reservationModel.expedienteId);
        ReservationParameters CDBReservationParameters = ONE_CDBReservationRequestBuilder.newInstance()
                .setRcprosol(DEFAULT_IDENTIFICATION)
                .setRcususol(DEFAULT_USERNAME)
                .setRctipsol(reservationModel.reservationType)
                .setRcdifunt(returnEmptyIfNull(servicio.ONE_Codigo_Difunto_CBSA__c))
                .setRctipinh(String.isBlank(reservationModel.burialType) ? DEFAULT_BURIAL_TYPE : reservationModel.burialType)
                .setRcnom(returnEmptyIfNull(servicio.ONE_Difunto__r?.FirstName))
                .setRccog1(returnEmptyIfNull(servicio.ONE_Difunto__r?.LastName))
                .setRcsexe(ONE_CDBRequestBuilderUtilities.getShortSex(servicio.ONE_Difunto__r?.ONE_Sexo__c))
                .setRcnaixe(ONE_CDBRequestBuilderUtilities.getFormattedDate((Datetime) servicio.ONE_Difunto__r?.ONE_Fecha_de_nacimiento__pc))
                .setRcprovi(returnEmptyIfNull(servicio.ONE_Difunto__r?.ONE_Provincia__pc))
                .setRctelef(returnEmptyIfNull(servicio.ONE_Difunto__r?.Phone))
                .setRccaumor(servicio.ONE_Causas_Defuncion__c)
                .setRcdatdef(ONE_CDBRequestBuilderUtilities.getFormattedDate(servicio.ONE_Fecha_De_Defuncion__c))
                .setRchordef(ONE_CDBRequestBuilderUtilities.getTime(servicio.ONE_Fecha_De_Defuncion__c))
                .setRcestdif(servicio.ONE_Estado_Del_Difunto__c)
                .setRctipser(String.isEmpty(servicio.ONE_Tipo_De_Servicio_CB__c) ? DEFAULT_TYPE_OF_SERVICE : servicio.ONE_Tipo_De_Servicio_CB__c)
                .setRcdatinc(reservationModel.reservationType == INCINERATION_SHORT ? reservationModel.reservationDate : (servicio.ONE_Inicio_Incineracion__c != null) ? ONE_CDBRequestBuilderUtilities.getFormattedDate(servicio.ONE_Inicio_Incineracion__c) : EMPTY_VALUE)
                .setRchorinc(reservationModel.reservationType == INCINERATION_SHORT ? reservationModel.reservationTime : (servicio.ONE_Inicio_Incineracion__c != null) ? ONE_CDBRequestBuilderUtilities.getTime(servicio.ONE_Inicio_Incineracion__c) : EMPTY_VALUE)
                .setRcceminc(DEFAULT_CEMETERY_CODE)
                .setRcdatinh(reservationModel.reservationType == INHUMATION_SHORT ? reservationModel.reservationDate : EMPTY_VALUE)
                .setRchorinh(reservationModel.reservationType == INHUMATION_SHORT && reservationModel.reservationTime != null ? reservationModel.reservationTime : EMPTY_VALUE)
                .setRcceminh(reservationModel.selectedCemetery)
                //.setDominicana(ONE_CDBRequestBuilderUtilities.getTime(ONE_CDBRequestBuilderUtilities.getReservationPeriod(reservationModel, servicio)))
                .get();
        if (checkIfIncinerationDateTimeAndInhumationDateIsSet(CDBReservationParameters)) {
            CDBReservationParameters.rctipsol = INCINERATION_SHORT;
            CDBReservationParameters.rctipinh = BURY_ASHES_BURIAL_TYPE;
        }
        return CDBReservationParameters;
    }
    
    static Boolean checkIfIncinerationDateTimeAndInhumationDateIsSet(ReservationParameters reservationParameters) {
        return String.isNotEmpty(reservationParameters.rcdatinc) && String.isNotEmpty(reservationParameters.rchorinc) && String.isNotEmpty(reservationParameters.rcdatinh);
    }
    
    public class ReservationParameters {
        public String rcprosol;
        public String rcususol;
        public String rctipsol;
        public String rcdifunt;
        public String rchorinh;
        public String rcdatinh;
        public String rchorinc;
        public String rcnom;
        public String rccog1;
        public String rcsexe;
        public String rcnaixe;
        public String rcprovi;
        public String rccaumor;
        public String rcdatdef;
        public String rchordef;
        public String rcestdif;
        public String rctipser;
        public String rcdatinc;
        public String rcceminc;
        public String rctipinh;
        public String rctelef;
        public String rcceminh;
        //public String Dominicana;
    }

    public class ReservationResponse {
        public String deceasedPersonId;
        public String funeralType;
        public String cemeteryCode;
        public String burialReservedDate;
        public String burialReservedTime;
        public String incinerationReservedDate;
        public String incinerationReservedTime;
        public String burialType;
        @AuraEnabled
        public String responseMessagesCriticality;
        @AuraEnabled
        public String responseMessages;
    }
}
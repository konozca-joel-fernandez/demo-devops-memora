/**
 * Created by mchruscick001 on 21.09.2021 12:06.
 */

public with sharing class ONE_CDBReservationModalController {
    static String TIME_SEPARATOR = ':';
    static String DATE_SEPARATOR = '/';
    @TestVisible
    static String DEFAULT_INHUMATION_SITE = 'Externo', DEFAULT_INCINERATION_SITE = 'Externo';

    @AuraEnabled
    public static CustomerReservationStatus doesCustomerHasReservationAlready(Id customerId) {
        ONE_Expediente__c customer = ONE_ExpedienteSelector.selectExpediente(customerId);
        CustomerReservationStatus customerReservationStatus = new CustomerReservationStatus();
        customerReservationStatus.hasIncinerationReservation = customer.ONE_Incineracion__c;
        customerReservationStatus.hasInhumationReservation = customer.ONE_Cementerio__c;
        customerReservationStatus.hasBothReservations = customer.ONE_Cementerio__c && customer.ONE_Incineracion__c;
        return customerReservationStatus;
    } 
    
    @AuraEnabled
    public static ONE_CDBReservationService.ReservationResponse cancelReservation(ReservationModel reservationModel){
        ONE_CDBReservationService.ReservationResponse reservationResponse = ONE_CDBReservationService.cancelReservation(reservationModel);
        clearReservation(reservationModel.expedienteId);
        return reservationResponse;
    }
    
    @AuraEnabled
    public static List<String> getReservationTimes(ReservationModel reservationModel){
        return ONE_CDBReservationService.checkAvailableHours(reservationModel);
    }

    @AuraEnabled
    public static ONE_CDBReservationService.ReservationResponse makeAnReservation(ReservationModel reservationModel){
        ONE_CDBReservationService.ReservationResponse reservationResponse = ONE_CDBReservationService.makeAnReservation(reservationModel);
        if (reservationResponse.responseMessagesCriticality != ONE_CDBContractService.FATAL_ERROR_VALIDITY_LETTER){
            saveReservation(reservationModel.expedienteId, reservationResponse);
        }
        return reservationResponse;
    }

    static Time buildReservedTime(String reservedTime) {
        String[] splittedReservationTime = reservedTime.split(TIME_SEPARATOR);
        return Time.newInstance(
                Integer.valueOf(splittedReservationTime[0]),
                Integer.valueOf(splittedReservationTime[1]),
                0,
                0
        );
    }

    static Date buildReservedDate(String reservedDate) {
        String[] splittedReservationDate = reservedDate.split(DATE_SEPARATOR);
        return Date.newInstance(
                Integer.valueOf(splittedReservationDate[2]),
                Integer.valueOf(splittedReservationDate[1]),
                Integer.valueOf(splittedReservationDate[0])
        );
    }

    static Datetime buildReservedDateTime(String reservedDate, String reservedTime) {
        return Datetime.newInstance(buildReservedDate(reservedDate), buildReservedTime(reservedTime));
    }

    static void clearReservation(Id customerId) {
        update new ONE_Expediente__c(
                Id = customerId,
                ONE_Codigo_Difunto_CBSA__c = null,
                ONE_Hora_destino_final__c = null,
                ONE_Destino_Final__c = null,
                ONE_Inicio_incineracion__c = null,
                ONE_Lugar_Incineracion__c = null,
                ONE_Tipo_De_Lugar_De_Incineracion__c = null,
                ONE_Tipo_De_Lugar_Destino_Final__c = null,
                ONE_Incineracion__c = false,
                ONE_Cementerio__c = false
        );
    }
    
    static void saveReservation(Id customerId, ONE_CDBReservationService.ReservationResponse reservationResponse) {
        if (reservationResponse.funeralType == ONE_CDBReservationService.INCINERATION_SHORT && reservationResponse.burialType == ONE_CDBReservationService.DEFAULT_BURIAL_TYPE) {
            updateExpedienteWithIncinerationDetails(customerId, reservationResponse.deceasedPersonId, buildReservedDateTime(reservationResponse.incinerationReservedDate, reservationResponse.incinerationReservedTime), reservationResponse.cemeteryCode);
        } else if (reservationResponse.funeralType == ONE_CDBReservationService.INHUMATION_SHORT) {
            updateExpedienteWithInhumationDetails(customerId, reservationResponse.deceasedPersonId, buildReservedDateTime(reservationResponse.burialReservedDate, reservationResponse.burialReservedTime), reservationResponse.cemeteryCode);
        }  else if (reservationResponse.funeralType == ONE_CDBReservationService.INCINERATION_SHORT && reservationResponse.burialType == ONE_CDBReservationService.BURY_ASHES_BURIAL_TYPE) {
            updateExpedienteWithIncinerationDetails(customerId, reservationResponse.deceasedPersonId, buildReservedDateTime(reservationResponse.incinerationReservedDate, reservationResponse.incinerationReservedTime), reservationResponse.cemeteryCode);
            updateExpedienteWithInhumationDetails(customerId, reservationResponse.deceasedPersonId, buildReservedDateTime(reservationResponse.burialReservedDate, reservationResponse.burialReservedTime), reservationResponse.cemeteryCode);
        }
    }
    
    static void updateExpedienteWithInhumationDetails(Id customerId, String deceasedPersonReservationId, Datetime reservedDateAndTime, String cemeteryCode) {
        update new ONE_Expediente__c(
                Id = customerId,
                ONE_Codigo_Difunto_CBSA__c = deceasedPersonReservationId,
                ONE_Hora_destino_final__c = reservedDateAndTime,
                ONE_Destino_Final__c = ONE_AccountSelector.selectAccount(cemeteryCode).Id,
                ONE_Tipo_De_Lugar_Destino_Final__c = DEFAULT_INHUMATION_SITE,
                ONE_Cementerio__c = true
        );
    }    
    
    static void updateExpedienteWithIncinerationDetails(Id customerId, String deceasedPersonReservationId, Datetime reservedDateAndTime, String cemeteryCode) {
        update new ONE_Expediente__c(
                Id = customerId,
                ONE_Codigo_Difunto_CBSA__c = deceasedPersonReservationId,
                ONE_Inicio_incineracion__c = reservedDateAndTime,
                ONE_Lugar_Incineracion__c = ONE_AccountSelector.selectAccount(cemeteryCode).Id,
                ONE_Tipo_De_Lugar_De_Incineracion__c = DEFAULT_INCINERATION_SITE,
                ONE_Incineracion__c = true
        );
    }
    
    public class ReservationModel {
        @AuraEnabled
        public String expedienteId { get; set; }
        @AuraEnabled
        public String burialType { get; set; }
        @AuraEnabled
        public String reservationType { get; set; }
        @AuraEnabled
        public String reservationDate { get; set; }
        @AuraEnabled
        public String reservationTime { get; set; }
        @AuraEnabled
        public String selectedCemetery { get; set; }
    }
    @TestVisible
    class CustomerReservationStatus{
        @AuraEnabled
        public Boolean hasIncinerationReservation;
        @AuraEnabled
        public Boolean hasInhumationReservation;
        @AuraEnabled
        public Boolean hasBothReservations;
    }
}
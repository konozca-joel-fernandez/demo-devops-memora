/**
 * Created by mchruscick001 on 30.09.2021 09:29.
 */
@IsTest
public with sharing class ONE_CDBReservationModalControllerTest {
    static Account WITHOUT_ACCOUNT_TEMPLATE = null;
    static Boolean DO_INSERT = true;
    
    @IsTest
    static void doesCustomerHasReservationAlreadyTest() {
        ONE_CDBReservationModalController.CustomerReservationStatus customerReservationStatus
                = ONE_CDBReservationModalController.doesCustomerHasReservationAlready(ONE_ExpedienteTestDataFactory.getInsertCustomerWithReservation().Id);
        System.assert(!customerReservationStatus.hasIncinerationReservation);
        System.assert(!customerReservationStatus.hasInhumationReservation);
        System.assert(!customerReservationStatus.hasBothReservations);
    }
    
    @IsTest
    static void cancelReservationTest() {
        Id expedienteId = ONE_ExpedienteTestDataFactory.getInsertCustomerWithReservation().Id;
        Test.setMock(HttpCalloutMock.class, new ONE_CDBResponseMockService.CDBServiceResponseMock(ONE_CDBResponseMockService.getConstructedCancelResponse()));
        
        Test.startTest();
        ONE_CDBReservationService.ReservationResponse response = ONE_CDBReservationModalController.cancelReservation(buildCancelModel(expedienteId));
        System.assertEquals(ONE_CDBResponseMockBuilder.RESPONSE_SUCCESSFUL_ANULATION_MESSAGE, response.responseMessages);
        System.assertEquals(ONE_CDBResponseMockBuilder.RESPONSE_MESSAGE_CRITICALITY_OK_CODE, response.responseMessagesCriticality);
        assertCancelledReservation(ONE_ExpedienteSelector.selectExpediente(expedienteId));
        Test.stopTest();
    } 
    
    static void assertCancelledReservation(ONE_Expediente__c expediente) {
        System.assertNotEquals(null, expediente.ONE_Codigo_Difunto_CBSA__c);
        System.assertEquals(null, expediente.ONE_Hora_destino_final__c);
        System.assertEquals(null, expediente.ONE_Destino_Final__c);
        System.assertEquals(null, expediente.ONE_Inicio_incineracion__c);
        System.assertEquals(null, expediente.ONE_Lugar_Incineracion__c);
        System.assertEquals(null, expediente.ONE_Tipo_De_Lugar_De_Incineracion__c);
        System.assertEquals(null, expediente.ONE_Tipo_De_Lugar_Destino_Final__c);
        System.assert(!expediente.ONE_Incineracion__c);
        System.assert(!expediente.ONE_Cementerio__c);
    }

    static void assertMakingAReservation(ONE_Expediente__c expediente, ONE_CDBReservationService.ReservationResponse response) {
        System.assertEquals(ONE_ExpedienteTestDataFactory.DEFAULT_UNIQUE_RESERVATION_ID, expediente.ONE_Codigo_Difunto_CBSA__c);
        System.assertEquals(null, expediente.ONE_Hora_destino_final__c);
        System.assertEquals(null, expediente.ONE_Destino_Final__c);
        System.assertEquals(ONE_AccountSelector.selectAccount(response.cemeteryCode).Id, expediente.ONE_Lugar_Incineracion__c);
        System.assertEquals(ONE_CDBReservationModalController.DEFAULT_INCINERATION_SITE, expediente.ONE_Tipo_De_Lugar_De_Incineracion__c);
        System.assertEquals(null, expediente.ONE_Tipo_De_Lugar_Destino_Final__c);
        System.assert(expediente.ONE_Incineracion__c);
        System.assert(!expediente.ONE_Cementerio__c);
    }

    @IsTest
    static void makeAnReservationTest() {
        ONE_Expediente__c ex = ONE_ExpedienteTestDataFactory.getInsertCustomerWithoutReservation();
        ONE_TestDataFactory.createCentroCemetary(WITHOUT_ACCOUNT_TEMPLATE, DO_INSERT);
        Test.setMock(HttpCalloutMock.class, new ONE_CDBResponseMockService.CDBServiceResponseMock(ONE_CDBResponseMockService.getConstructedReservationResponse()));
        
        Test.startTest();
        ONE_CDBReservationService.ReservationResponse response = ONE_CDBReservationModalController.makeAnReservation(buildMakeReservationModel(ex.Id));
        System.assertEquals(ONE_CDBResponseMockBuilder.RESPONSE_SUCCESSFUL_RESERVATION_MESSAGE, response.responseMessages);
        System.assertEquals(ONE_CDBResponseMockBuilder.RESPONSE_MESSAGE_CRITICALITY_OK_CODE, response.responseMessagesCriticality);
        assertMakingAReservation(ONE_ExpedienteSelector.selectExpediente(ex.Id), response);
        Test.stopTest();
    }
    
    @IsTest
    static void checkAvailableHoursTest() {
        ONE_Expediente__c ex = ONE_ExpedienteTestDataFactory.getInsertCustomerWithReservation();
        
        Test.setMock(HttpCalloutMock.class, new ONE_CDBResponseMockService.CDBServiceResponseMock(ONE_CDBResponseMockService.getConstructedAvailableTimesResponse()));
        
        Test.startTest();
        System.assert(!ONE_CDBReservationModalController.getReservationTimes(buildGetAvailableReservationTimesModel(ex.Id)).isEmpty());
        Test.stopTest();
    }

    static ONE_CDBReservationModalController.ReservationModel buildMakeReservationModel(Id expedienteId) {
        return buildReservationModel(expedienteId, ONE_CDBReservationService.INCINERATION_SHORT, String.valueOf(System.now().time()), String.valueOf(System.today()), ONE_CDBReservationService.DEFAULT_BURIAL_TYPE);
    }
    
    static ONE_CDBReservationModalController.ReservationModel buildGetAvailableReservationTimesModel(Id expedienteId) {
        return buildReservationModel(expedienteId, ONE_CDBReservationService.INCINERATION_SHORT, null, String.valueOf(System.today()), ONE_CDBReservationService.DEFAULT_BURIAL_TYPE);
    }
    
    static ONE_CDBReservationModalController.ReservationModel buildCancelModel(Id expedienteId) {
        return buildReservationModel(expedienteId, ONE_CDBResponseMockBuilder.REQUEST_CANCELATION_TYPE, null, null, ONE_CDBReservationService.DEFAULT_BURIAL_TYPE);
    }
    
    static ONE_CDBReservationModalController.ReservationModel buildReservationModel(Id expedienteId, String reservationType,
            String reservationTime, String reservationDate, String burialType) {
        ONE_CDBReservationModalController.ReservationModel reservationModel = new ONE_CDBReservationModalController.ReservationModel();
        reservationModel.expedienteId = expedienteId;
        reservationModel.reservationType = reservationType;
        reservationModel.reservationTime = reservationTime;
        reservationModel.reservationDate = reservationDate;
        reservationModel.burialType = burialType;
        reservationModel.selectedCemetery = ONE_CDBResponseMockBuilder.SELECTED_CEMETERY_CODE;
        return reservationModel;
    }
}
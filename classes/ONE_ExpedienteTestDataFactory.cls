/**
 * Created by mchruscick001 on 11.10.2021 10:38.
 */

public with sharing class ONE_ExpedienteTestDataFactory {
    static final Boolean DO_NOT_INSERT = false, DO_INSERT = true;
    static final Boolean WITH_RESERVATION = true, WITHOUT_RESERVATION = false;
    static final ONE_Expediente__c WITHOUT_EXPEDIENTE_TEMPLATE = null;
    static final String ORDINARY_STATE_OF_DECEASED_CUSTOMER = 'O';
    public final static String DEFAULT_UNIQUE_RESERVATION_ID = ONE_TestDataFactory.getRandomName();

    public static ONE_Expediente__c getInsertCustomerWithoutReservation() {
        return getInsertCustomer(WITHOUT_RESERVATION);
    }

    public static ONE_Expediente__c getInsertCustomerWithReservation() {
        return getInsertCustomer(WITH_RESERVATION);
    }

    static ONE_Expediente__c getInsertCustomer(Boolean withReservation) {
        ONE_Expediente__c ex = ONE_TestDataFactory.createExpediente(WITHOUT_EXPEDIENTE_TEMPLATE, DO_NOT_INSERT);
        ex.ONE_Codigo_Difunto_CBSA__c = withReservation ? DEFAULT_UNIQUE_RESERVATION_ID : null;
        ex.ONE_Estado_Del_Difunto__c = ORDINARY_STATE_OF_DECEASED_CUSTOMER;
        ex.ONE_Fecha_De_Defuncion__c = Datetime.now().addYears(-70);
        ex.ONE_Inicio_Ceremonia__c = Datetime.now().addDays(1);
        ex.ONE_Lugar_Ceremonia__c = ONE_TestDataFactory.createCentroCemetary(null, DO_INSERT).Id;
        ex.ONE_Declarante__c = ONE_TestDataFactory.createPersonAccount(null, DO_INSERT).Id;
        insert ex;
        return ex;
    }
}
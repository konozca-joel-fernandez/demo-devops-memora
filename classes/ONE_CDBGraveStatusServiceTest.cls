/**
 * Created by mchruscick001 on 08.10.2021 11:51.
 */
@IsTest
public with sharing class ONE_CDBGraveStatusServiceTest {

    @IsTest
    static void getGraveStatusTest() {
        Id budgetId = ONE_PresupuestoTestDataFactory.getInsertBudgetWithExpediente(ONE_ExpedienteTestDataFactory.getInsertCustomerWithReservation().Id).Id;
        
        Test.setMock(HttpCalloutMock.class, new ONE_CDBResponseMockService.CDBServiceResponseMock(ONE_CDBResponseMockService.getConstructedGraveStatusResponse()));
        Test.startTest();
        ONE_CDBGraveStatusService.GraveStatusResponse response = ONE_CDBGraveStatusService.getGraveStatus(new List<Id>{budgetId})[0];
        System.assertEquals(ONE_CDBResponseMockBuilder.GRAVE_RESPONSE_STATUS_OK, response.graveStatusResponse.status);
        System.assertEquals(ONE_CDBResponseMockBuilder.GRAVE_RESPONSE_MESSAGE, response.graveStatusResponse.mensaje);
        System.assertEquals(ONE_CDBResponseMockBuilder.GRAVE_RESPONSE_AMOUNT, response.graveStatusResponse.pendent);
        System.assertEquals(ONE_CDBResponseMockBuilder.GRAVE_RESPONSE_CODE, response.graveStatusResponse.codi);
        Test.stopTest();
    }
}
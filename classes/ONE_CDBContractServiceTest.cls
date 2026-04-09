/**
 * Created by mchruscick001 on 06.10.2021 13:25.
 */
@IsTest
public with sharing class ONE_CDBContractServiceTest {
    //Static variable definition
    final static String SUB_PRODUCTS_CREATED_STATUS = 'OK';
    final static String SUB_PRODUCTS_NOT_CREATED_STATUS = 'KO';
    final static String EMPTY_VALUE = '';
	
    //Test integration call with products and without errors
    @IsTest
    static void sendContractToCDBWithProductsMatchWithoutErrorsTest() {
        Id budgetId = ONE_PresupuestoTestDataFactory.getInsertBudgetWithExpediente(ONE_ExpedienteTestDataFactory.getInsertCustomerWithReservation().Id).Id;
        Database.insert(new ONE_Producto__c(ONE_Codigo_Comercial__c = ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_COMPONENT_NAME, ONE_Cementiris_De_Barcelona__c = true)).getId();
        ONE_TestDataFactory.createBusinessAccount(new Account(ONE_CIF__c = ONE_CDBResponseMockBuilder.MATCHING_CIF_ID), true);
        ONE_TestDataFactory.createPersonAccount(new Account(ONE_N_Documento__pc = ONE_CDBResponseMockBuilder.MATCHING_DOCUMENT_ID), true);

        Test.setMock(HttpCalloutMock.class, new ONE_CDBResponseMockService.CDBServiceResponseMock(ONE_CDBResponseMockService.getConstructedContractWithProductsAndInvoicesWithoutErrorsResponse()));
        Test.startTest();
        assertIfContractSentSuccessfully(ONE_CDBContractService.sendContractToCDB(new List<Id>{budgetId})[0]);
        assertIfProductsWereUpdatedWithRightAccounts(budgetId);
        Test.stopTest();
    }
	//Check if the response was treated correctly and all the product where updated in the right accounts
    static void assertIfProductsWereUpdatedWithRightAccounts(Id budgetId) {
        Map<Id, Account> matchingAccounts = new Map<Id, Account>([SELECT Id FROM Account WHERE ONE_N_Documento__pc = :ONE_CDBResponseMockBuilder.MATCHING_DOCUMENT_ID OR ONE_CIF__c = :ONE_CDBResponseMockBuilder.MATCHING_CIF_ID]);
        List<ONE_SLI_Producto_CB__c> matchedWithExistingAccountSLIs = [SELECT Id, ONE_Unidades__c, ONE_Importe_Neto_Total__c FROM ONE_SLI_Producto_CB__c WHERE ONE_Titular_SLI_CB__c IN :matchingAccounts.keySet() AND ONE_Presupuesto__c = :budgetId];
        List<ONE_SLI_Producto_CB__c> allInsertedSlis = [SELECT Id, ONE_Unidades__c, ONE_Importe_Neto_Total__c FROM ONE_SLI_Producto_CB__c WHERE ONE_Presupuesto__c = :budgetId];
        System.assertEquals(4, allInsertedSlis.size());
        System.assertEquals(2, matchedWithExistingAccountSLIs.size());
    }
    //Test integration call without products and without errors
    @IsTest
    static void sendContractToCDBWithoutErrorsTest() {
        Id budgetId = ONE_PresupuestoTestDataFactory.getInsertBudgetWithExpediente(ONE_ExpedienteTestDataFactory.getInsertCustomerWithReservation().Id).Id;
        Id productId = Database.insert(new ONE_Producto__c(ONE_Codigo_Comercial__c = ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_COMPONENT_NAME, ONE_Cementiris_De_Barcelona__c = true)).getId();
        Id existingSLIProductId = Database.insert(new ONE_SLI_Producto_CB__c(ONE_Presupuesto__c = budgetId, ONE_Producto__c = productId)).getId();
        ONE_TestDataFactory.createPersonAccount(new Account(ONE_N_Documento__pc = ONE_CDBResponseMockBuilder.MATCHING_DOCUMENT_ID), true);

        Test.setMock(HttpCalloutMock.class, new ONE_CDBResponseMockService.CDBServiceResponseMock(ONE_CDBResponseMockService.getConstructedContractWithoutErrorsResponse()));
        Test.startTest();
        assertIfContractSentSuccessfully(ONE_CDBContractService.sendContractToCDB(new List<Id>{budgetId})[0]);
        assertIfExistingProductsWereUpdated(existingSLIProductId);
        assertIfNewProductsWereInserted(existingSLIProductId);
        Test.stopTest();
    }
	//Check if the response was treated correctle and the product where inserted
    static void assertIfNewProductsWereInserted(Id existingSLIProductId) {
        System.assert(![SELECT Id FROM ONE_SLI_Producto_CB__c WHERE Id != :existingSLIProductId].isEmpty());
    }
	//Check if the response was treated correctle and the product where updated
    static void assertIfExistingProductsWereUpdated(Id existingSLIProduct) {
        ONE_SLI_Producto_CB__c updatedSLI = [SELECT Id, ONE_Unidades__c, ONE_Importe_Neto_Total__c FROM ONE_SLI_Producto_CB__c WHERE Id = :existingSLIProduct];
        System.assertEquals(Decimal.valueOf(ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_COMPONENT_QUANTITY), updatedSLI.ONE_Unidades__c);
        System.assertEquals(Decimal.valueOf(ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_COMPONENT_GROSS_AMOUNT), updatedSLI.ONE_Importe_Neto_Total__c);
    }
    //Test contract integration with error
    @IsTest
    static void sendContractToCDBWithErrorsTest() {
        Id budgetId = ONE_PresupuestoTestDataFactory.getInsertBudgetWithExpediente(ONE_ExpedienteTestDataFactory.getInsertCustomerWithReservation().Id).Id;

        Test.setMock(HttpCalloutMock.class, new ONE_CDBResponseMockService.CDBServiceResponseMock(ONE_CDBResponseMockService.getConstructedContractWithErrorsResponse()));
        Test.startTest();
        assertIfContractSentButReturnedErrors(ONE_CDBContractService.sendContractToCDB(new List<Id>{budgetId})[0]);
        Test.stopTest();
    }
 
    //Check is contract was send correctly and we got an OK response
    static void assertIfContractSentSuccessfully(ONE_CDBContractService.ContractResponse response) {
        System.assertEquals(ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_REQUEST_NUMBER, response.peticio);
        System.assertEquals(ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_BURIAL_CODE, response.sepultura);
        System.assertEquals(EMPTY_VALUE, response.rterror);
        System.assertEquals(SUB_PRODUCTS_CREATED_STATUS, response.lineCreationStatus);
        System.assert(response.response);
    }
  
    //Check is contract was send correctly and we got an KO response
    static void assertIfContractSentButReturnedErrors(ONE_CDBContractService.ContractResponse response) {
        System.assertEquals(null, response.peticio);
        System.assertEquals(null, response.sepultura);
        System.assertEquals(ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_ERROR_VALIDITY + ' ' + ONE_CDBResponseMockBuilder.RESPONSE_CONTRACT_ERROR_MESSAGE, response.rterror);
        System.assertEquals(SUB_PRODUCTS_NOT_CREATED_STATUS, response.lineCreationStatus);
        System.assert(!response.response);
    }
   @IsTest
   static void assetNewDidires(){
        System.assertEquals('P', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased('1'));
        System.assertEquals('D', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased('2'));
        System.assertEquals('E', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased('3'));
        System.assertEquals('F', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased('4'));
        System.assertEquals('R', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased('5'));
        System.assertEquals('E', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased('6'));
        System.assertEquals('D', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased('7'));
    }
    //Test method to test class
    @IsTest
   static void getShortTypeOfDocumentTest(){
        System.assertEquals('97', ONE_CDBRequestBuilderUtilities.getSFFormOfDocumentType('1'));
        System.assertEquals('96', ONE_CDBRequestBuilderUtilities.getSFFormOfDocumentType('3'));
        System.assertEquals('95', ONE_CDBRequestBuilderUtilities.getSFFormOfDocumentType('2'));
        System.assertEquals('94', ONE_CDBRequestBuilderUtilities.getSFFormOfDocumentType('4'));
        
    }
     @IsTest
   static void getDesparentiuTest(){
       System.assertEquals('99', ONE_CDBRequestBuilderUtilities.getDeparentiu('Hijo/a', 'Mujer'));
       System.assertEquals('7', ONE_CDBRequestBuilderUtilities.getDeparentiu('Abuelo/a', 'Mujer'));
       System.assertEquals('6', ONE_CDBRequestBuilderUtilities.getDeparentiu('Abuelo/a', 'Hombre'));
       System.assertEquals('19', ONE_CDBRequestBuilderUtilities.getDeparentiu('Ahijado/a', 'Mujer'));
       System.assertEquals('20', ONE_CDBRequestBuilderUtilities.getDeparentiu('Ahijado/a', 'Hombre'));
       System.assertEquals('46', ONE_CDBRequestBuilderUtilities.getDeparentiu('Amistad', 'Hombre'));
       System.assertEquals('45', ONE_CDBRequestBuilderUtilities.getDeparentiu('Conviviente Civil', 'Hombre'));
       System.assertEquals('32', ONE_CDBRequestBuilderUtilities.getDeparentiu('Biznieto/a', 'Hombre'));
       System.assertEquals('33', ONE_CDBRequestBuilderUtilities.getDeparentiu('Biznieto/a', 'Mujer'));
       System.assertEquals('9', ONE_CDBRequestBuilderUtilities.getDeparentiu('Cónyuge', 'Hombre'));
       System.assertEquals('10', ONE_CDBRequestBuilderUtilities.getDeparentiu('Cónyuge', 'Mujer'));
       System.assertEquals('16', ONE_CDBRequestBuilderUtilities.getDeparentiu('Cuñado/a', 'Hombre'));
       System.assertEquals('15', ONE_CDBRequestBuilderUtilities.getDeparentiu('Cuñado/a', 'Mujer'));
       System.assertEquals('48', ONE_CDBRequestBuilderUtilities.getDeparentiu('Director/a Comunidad religiosa', 'Mujer'));
       System.assertEquals('47', ONE_CDBRequestBuilderUtilities.getDeparentiu('Director/a Residencia', 'Mujer'));
       System.assertEquals('3', ONE_CDBRequestBuilderUtilities.getDeparentiu('Hijo', 'Hombre'));
       System.assertEquals('4', ONE_CDBRequestBuilderUtilities.getDeparentiu('Hija', 'Mujer'));
       System.assertEquals('21', ONE_CDBRequestBuilderUtilities.getDeparentiu('Hijo/a polític.', 'Hombre'));
       System.assertEquals('22', ONE_CDBRequestBuilderUtilities.getDeparentiu('Hijo/a polític.', 'Mujer'));
       System.assertEquals('2', ONE_CDBRequestBuilderUtilities.getDeparentiu('Madre', 'Mujer'));
       System.assertEquals('50', ONE_CDBRequestBuilderUtilities.getDeparentiu('Madrastra', 'Mujer'));
       System.assertEquals('99', ONE_CDBRequestBuilderUtilities.getDeparentiu('Otro', 'Mujer'));
       System.assertEquals('11', ONE_CDBRequestBuilderUtilities.getDeparentiu('Nieto/a', 'Hombre'));
       System.assertEquals('12', ONE_CDBRequestBuilderUtilities.getDeparentiu('Nieto/a', 'Mujer'));
       System.assertEquals('51', ONE_CDBRequestBuilderUtilities.getDeparentiu('Padrastro', 'Hombre'));
       System.assertEquals('1', ONE_CDBRequestBuilderUtilities.getDeparentiu('Padre', 'Hombre'));
       System.assertEquals('49', ONE_CDBRequestBuilderUtilities.getDeparentiu('Pareja', 'Hombre'));
       System.assertEquals('18', ONE_CDBRequestBuilderUtilities.getDeparentiu('Primo/a', 'Hombre'));
       System.assertEquals('17', ONE_CDBRequestBuilderUtilities.getDeparentiu('Primo/a', 'Mujer'));
       System.assertEquals('98', ONE_CDBRequestBuilderUtilities.getDeparentiu('Representante legal', 'Mujer'));
       System.assertEquals('44', ONE_CDBRequestBuilderUtilities.getDeparentiu('Trabajador social', 'Mujer'));
       System.assertEquals('99', ONE_CDBRequestBuilderUtilities.getDeparentiu('No se ha seleccionado', 'Mujer'));
       System.assertEquals('24', ONE_CDBRequestBuilderUtilities.getDeparentiu('Sobrino/a', 'Hombre'));
       System.assertEquals('23', ONE_CDBRequestBuilderUtilities.getDeparentiu('Sobrino/a', 'Mujer'));
       System.assertEquals('26', ONE_CDBRequestBuilderUtilities.getDeparentiu('Suegro/a', 'Hombre'));
       System.assertEquals('25', ONE_CDBRequestBuilderUtilities.getDeparentiu('Suegro/a', 'Mujer'));
       System.assertEquals('13', ONE_CDBRequestBuilderUtilities.getDeparentiu('Tío/a', 'Hombre'));
       System.assertEquals('14', ONE_CDBRequestBuilderUtilities.getDeparentiu('Tío/a', 'Mujer'));
       System.assertEquals('42', ONE_CDBRequestBuilderUtilities.getDeparentiu('Hijastro/a', 'Hombre'));
       System.assertEquals('43', ONE_CDBRequestBuilderUtilities.getDeparentiu('Hijastro/a', 'Mujer'));
    }
}
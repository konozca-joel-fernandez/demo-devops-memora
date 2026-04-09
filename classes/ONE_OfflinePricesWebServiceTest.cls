/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_OfflinePricesWebServiceTest {
    @TestSetup
    public static void dataSetup() {

        ONE_Catalogo_De_Precios__c catalogo = ONE_TestDataFactory.createCatalogoDePrecios(
            new ONE_Catalogo_De_Precios__c(
                ONE_Validez_Hasta__c = Date.today().addDays(1),
                ONE_Validez_Desde__c = Date.today().addDays(-1)
            ), true);
        ONE_Entrada_De_Precio__c entrada = ONE_TestDataFactory.createEntradaDePrecio(
            new ONE_Entrada_De_Precio__c(
                ONE_Catalogo_De_Precios__c = catalogo.Id
            ), true);
        ONE_Entrada_De_Modelo__c entradaDeModelo = ONE_TestDataFactory.createEntradaDeModelo(
            new ONE_Entrada_De_Modelo__c(
                ONE_Entrada_De_Precio__c = entrada.Id,
                ONE_Catalogo_De_Precios__c = catalogo.Id
            ), true);


    }

    @IsTest
    public static void getTypologyTest() {
        String retJson = '';
        ONE_OfflinePricesWebService.DTO dto = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/offline-pricing/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        ONE_OfflinePricesWebService.getOfflinePrices();
        System.debug(RestContext.response.responseBody.toString());
        dto = (ONE_OfflinePricesWebService.DTO)JSON.deserialize(
            RestContext.response.responseBody.toString(),
            ONE_OfflinePricesWebService.DTO.class
        );
        Test.stopTest();
        System.assertNotEquals(null, dto);
    }
}
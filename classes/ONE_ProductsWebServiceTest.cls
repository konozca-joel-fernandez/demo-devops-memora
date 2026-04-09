/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_ProductsWebServiceTest {
    @TestSetup
    public static void dataSetup() {

        ONE_Producto__c prod = ONE_TestDataFactory.createProducto(null, true);
        ONE_Producto__c prod2 = ONE_TestDataFactory.createProducto(null, true);
        ONE_Imagen__c image = ONE_TestDataFactory.createImagen(
            new ONE_Imagen__c(
                ONE_Producto__c = prod.Id
            ), true);
        ONE_Relacion_De_Productos__c rel = ONE_TestDataFactory.createRelacionDeProductos(
            new ONE_Relacion_De_Productos__c(
                ONE_Producto_Comercial_Padre__c = prod.Id,
                ONE_Producto_Incluido__c = prod2.Id
            ), true);
    }

    @IsTest
    public static void getTypologyTest() {
        String retJson = '';
        List<ONE_ProductsWebService.Producto> productos = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/products/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        ONE_ProductsWebService.getProducts();
        productos = (List<ONE_ProductsWebService.Producto>)JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<ONE_ProductsWebService.Producto>.class
        );
        Test.stopTest();

        System.assertNotEquals(null, productos);
        System.assertEquals(2, productos.size());
    }
}
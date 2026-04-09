/**
 * Created by Miguel Serrat on 24.05.2023.
 *
 * LOGs:
 * ------------------------------------------
 * DATA       USER            CHANGE
 * ------------------------------------------
 */
@IsTest
public class ONE_SynchronizeStockWebServiceTest {
    
    private static final String CENTRO = '2021';
    private static final List<String> SKU_LIST = new List<String>{'12000000','13000000','14000000'};
        
	private static String JSON_REQ_TEMPLATE = '{\n' +
		'"workPlace":"{%CentroId%}",\n'+
		'"products":[\n' +
		'{"id":"{%ProductoSinModeloId%}", "model":""},\n' +
        '{"id":"{%ProductoConModeloId%}", "model":"{%ModeloSinStockId%}"},\n' +
		'{"id":"{%ProductoConModeloId%}", "model":"{%ModeloConStockId%}"}\n' +
		']\n' +
		'}';
    
    private static String handleRequest(Map<String, String> parameters) {
        String retString = JSON_REQ_TEMPLATE;
        for(String key : parameters.keySet()) {
            retString = retString.replace('{%'+key +'%}', parameters.get(key));
        }
        return retString;
    }
    
    @TestSetup
    public static void dataSetup() {
        //LUGAR
        ONE_Lugar__c lugarDelegacion = ONE_TestDataFactory.createLugar(null, true); 
        ONE_Lugar__c lugarZona = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarDelegacion.Id), true);
        ONE_Lugar__c lugarArea = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarZona.Id), true);
        
        //CENTRO
        Account accCentro = ONE_TestDataFactory.createCentro(new Account(
            ONE_Provincia__c = '08',
            ONE_Sociedad__c = '0500',
            ONE_Centro_Memora_Codigo_SAP__c = '2000',
        	ONE_Lugar__c = lugarArea.Id
        ),true);
        

        //PRODUCTOS:
        ONE_Producto__c productoSinModelos = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Sin Modelos',
                ONE_SKU__c = '12000000',
                ONE_Stockable__c = true
            ),
            true
        );
        
        ONE_Producto__c productoConModelos = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Con Modelos',
                ONE_SKU__c = '0000',
                ONE_Stockable__c = true
            ),
            true
        );
        
        ONE_Producto__c productoSinSKU = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Sin SKU',
                ONE_Stockable__c = true
            ),
            true
        );
       
        
        //MODELOS:
        ONE_Modelo__c modeloSinStock = ONE_TestDataFactory.createModelo(
            new ONE_Modelo__c(
                Name = 'modeloSinStock',
                ONE_SKU__c = '13000000',
                ONE_Producto_Comercial__c = productoConModelos.Id
            ),
            true);
        
        ONE_Modelo__c modeloConStock = ONE_TestDataFactory.createModelo(
            new ONE_Modelo__c(
                Name = 'modeloConStock',
                ONE_SKU__c = '14000000',
                ONE_Producto_Comercial__c = productoConModelos.Id
            ),
            true);
        
        ONE_Modelo__c modeloSinSKU = ONE_TestDataFactory.createModelo(
            new ONE_Modelo__c(
                Name = 'modeloSinSKU',
                ONE_Producto_Comercial__c = productoConModelos.Id
            ),
            true);
    }
    
    @IsTest
    public static void test1() {
        
        account centro = [SELECT id FROM Account LIMIT 1];
        ONE_Producto__c productoSinModelo = [SELECT id FROM ONE_Producto__c WHERE Name = 'Producto Sin Modelos' LIMIT 1];
        List<ONE_Modelo__c> modelos = [SELECT id, ONE_Producto_Comercial__c FROM ONE_Modelo__c WHERE ONE_Producto_Comercial__r.Name = 'Producto Con Modelos' AND ONE_SKU__c != NULL LIMIT 2];
        
        Test.setMock(HttpCalloutMock.class, new StockAvailabilityMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/queryStock/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'CentroId' => centro.id,
            'ProductoSinModeloId' => productoSinModelo.id,
            'ProductoConModeloId' => modelos[0].ONE_Producto_Comercial__c,
            'ModeloSinStockId' => modelos[0].Id,
            'ModeloConStockId' => modelos[1].Id
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeStockWebService.checkStock();
        Test.stopTest();
    }
    
    @IsTest
    public static void test2() {
        
        account centro = [SELECT id FROM Account LIMIT 1];
        ONE_Producto__c productoSinSKU = [SELECT id FROM ONE_Producto__c WHERE Name = 'Producto Sin SKU' LIMIT 1];
        List<ONE_Modelo__c> modelos = [SELECT id, ONE_Producto_Comercial__c FROM ONE_Modelo__c WHERE ONE_Producto_Comercial__r.Name = 'Producto Con Modelos' AND ONE_SKU__c != NULL LIMIT 2];
        
        Test.setMock(HttpCalloutMock.class, new StockAvailabilityMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/queryStock/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'CentroId' => centro.id,
            'ProductoSinModeloId' => productoSinSKU.id,
            'ProductoConModeloId' => modelos[0].ONE_Producto_Comercial__c,
            'ModeloSinStockId' => modelos[0].Id,
            'ModeloConStockId' => modelos[1].Id
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeStockWebService.checkStock();
        Test.stopTest();
    }
    
    @IsTest
    public static void test3() {
        Test.setMock(HttpCalloutMock.class, new StockAvailabilityMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/queryStock/';
        req.httpMethod = 'POST';
        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeStockWebService.checkStock();
        Test.stopTest();
    }
    
    @IsTest
    public static void test4() {
        
        account centro = [SELECT id FROM Account LIMIT 1];
        ONE_Producto__c productoSinSKU = [SELECT id FROM ONE_Producto__c WHERE Name = 'Producto Sin SKU' LIMIT 1];
        List<ONE_Modelo__c> modelos = [SELECT id, ONE_Producto_Comercial__c FROM ONE_Modelo__c WHERE Name IN ('modeloSinSKU', 'modeloConStock') LIMIT 2];
        
        Test.setMock(HttpCalloutMock.class, new StockAvailabilityMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/queryStock/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'CentroId' => centro.id,
            'ProductoSinModeloId' => productoSinSKU.id,
            'ProductoConModeloId' => modelos[0].ONE_Producto_Comercial__c,
            'ModeloSinStockId' => modelos[0].Id,
            'ModeloConStockId' => modelos[1].Id
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeStockWebService.checkStock();
        Test.stopTest();
    }
    
    @TestVisible
    private class StockAvailabilityMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public StockAvailabilityMock(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            res.setBody(this.body);
            return res;
        }
    }

    private static String prepareResponse() {
        ONE_SAPResponses.StockAvailabilityResponse resp1 = new ONE_SAPResponses.StockAvailabilityResponse();
        resp1.Material = SKU_LIST[0];
        resp1.Centro = CENTRO;
        resp1.Almacen = 'A000';
        resp1.Proveedor = '12340000';
        resp1.Unidades = '1';

        ONE_SAPResponses.StockAvailabilityResponse resp3 = new ONE_SAPResponses.StockAvailabilityResponse();
        resp3.Material = SKU_LIST[2];
        resp3.Centro = CENTRO;
        resp3.Almacen = 'C000';
        resp3.Proveedor = '12340002';
        resp3.Unidades = '3';

        List<ONE_SAPResponses.StockAvailabilityResponse> results = new List<ONE_SAPResponses.StockAvailabilityResponse>{resp1, resp3};
        Map<String, List<ONE_SAPResponses.StockAvailabilityResponse>> dMap = new Map<String, List<ONE_SAPResponses.StockAvailabilityResponse>> {
            'results' => results
        };
        ONE_SAPResponses.StockAvailabilityResponseWrapper response  = new ONE_SAPResponses.StockAvailabilityResponseWrapper(dMap);
        return JSON.serialize(response);
    }
}
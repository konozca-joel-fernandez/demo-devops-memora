/**
 * Created by mbujak003 on 22.02.2021.
 */

@IsTest
public with sharing class ONE_StockIntegrationServiceTest {

    private static final String CENTRO = '2021';
    private static final List<String> SKU_LIST = new List<String>{'12000000','13000000','14000000'};

    @TestSetup
    private static void setup() {
        ONE_Modelo__c modelo1 = ONE_TestDataFactory.createModelo(new ONE_Modelo__c(
                Name = 'Test modelo 1',
                ONE_SKU__c = SKU_LIST[0]
        ), false);
        ONE_Modelo__c modelo2 = ONE_TestDataFactory.createModelo(new ONE_Modelo__c(
                Name = 'Test modelo 2',
                ONE_SKU__c = SKU_LIST[1]
        ), false);
        ONE_Modelo__c modelo3 = ONE_TestDataFactory.createModelo(new ONE_Modelo__c(
                Name = 'Test modelo 3',
                ONE_SKU__c = SKU_LIST[2]
        ), false);

        insert new List<ONE_Modelo__c>{modelo1, modelo2, modelo3};
    }


    @IsTest
    public static void invokeIntegrationTest() {
        
        Test.setMock(HttpCalloutMock.class, new StockAvailabilityMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_StockIntegrationService.FlowInputs fi = new ONE_StockIntegrationService.FlowInputs();
        fi.centro = CENTRO;
        fi.matnr = SKU_LIST;


        List<ONE_StockIntegrationService.FlowOutputs> fo = new List<ONE_StockIntegrationService.FlowOutputs>();

        Test.startTest();
        fo = ONE_StockIntegrationService.invokeIntegration(
            new List<ONE_StockIntegrationService.FlowInputs> { fi }
        );
        Test.stopTest();

        System.assertNotEquals(null, fo[0].modeloTableJson);
        System.assertEquals(Label.Modelo_Table, fo[0].tableHeader);

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

        ONE_SAPResponses.StockAvailabilityResponse resp2 = new ONE_SAPResponses.StockAvailabilityResponse();
        resp2.Material = SKU_LIST[1];
        resp2.Centro = CENTRO;
        resp2.Almacen = 'B000';
        resp2.Proveedor = '12340001';
        resp2.Unidades = '2';

        ONE_SAPResponses.StockAvailabilityResponse resp3 = new ONE_SAPResponses.StockAvailabilityResponse();
        resp3.Material = SKU_LIST[2];
        resp3.Centro = CENTRO;
        resp3.Almacen = 'C000';
        resp3.Proveedor = '12340002';
        resp3.Unidades = '3';

        List<ONE_SAPResponses.StockAvailabilityResponse> results = new List<ONE_SAPResponses.StockAvailabilityResponse>{resp1, resp2, resp3};
        Map<String, List<ONE_SAPResponses.StockAvailabilityResponse>> dMap = new Map<String, List<ONE_SAPResponses.StockAvailabilityResponse>> {
            'results' => results
        };
        ONE_SAPResponses.StockAvailabilityResponseWrapper response  = new ONE_SAPResponses.StockAvailabilityResponseWrapper(dMap);
        return JSON.serialize(response);
    }
}
@IsTest
private class ONE_WSFacturasSAPTest {
    
    static final String WS_TEST_METADATA_NAME = 'SF_FACTURAS_TEST';
    
    @isTest static void testUpdateOrdenVenta() {
        ONE_Orden_De_Venta__c OV = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(ONE_Numero_de_factura__c = '55205520', ONE_Compensado__c = false), true);
        
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = ONE_IntegrationEndpointSelector.selectIntegrationEndpoint(WS_TEST_METADATA_NAME).ONE_Resource__c;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"data": [{"factura": "55205520","compensado": true}]}');
        RestContext.request = request;
        RestContext.response= response;
        Map<String, List<ONE_Orden_De_Venta__c>> OVs = ONE_WSFacturasSAP.updateOrdenDeVenta();
        System.assert(OVs != null);
        List<ONE_Orden_De_Venta__c> OVList = [SELECT Id, ONE_Numero_de_factura__c, ONE_Compensado__c, ONE_Fecha_de_compensaci_n__c FROM ONE_Orden_De_Venta__c WHERE ONE_Numero_de_factura__c = '55205520'];
        System.assert(OVList != null);
        System.assertEquals(OVList[0].ONE_Compensado__c, true);
        System.assert(response.statusCode == 200);
    }
    
    @isTest static void testPartialUpdateOrdenVenta() {
        ONE_Orden_De_Venta__c OV = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(ONE_Numero_de_factura__c = '55205520', ONE_Compensado__c = false), true);

        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = ONE_IntegrationEndpointSelector.selectIntegrationEndpoint(WS_TEST_METADATA_NAME).ONE_Resource__c;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"data": [{"factura": "55205520","compensado": true}, {"factura": "12","compensado": true}]}');
        RestContext.request = request;
        RestContext.response= response;
        Map<String, List<ONE_Orden_De_Venta__c>> OVs = ONE_WSFacturasSAP.updateOrdenDeVenta();
        List<ONE_Orden_De_Venta__c> OVList = [SELECT Id, ONE_Numero_de_factura__c, ONE_Compensado__c, ONE_Fecha_de_compensaci_n__c FROM ONE_Orden_De_Venta__c WHERE ONE_Numero_de_factura__c = '55205520'];
        System.assert(response.statusCode == 206);
    }

    @isTest static void testNoContentUpdateOrdenVenta() {
        ONE_Orden_De_Venta__c OV = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(ONE_Numero_de_factura__c = '55205520', ONE_Compensado__c = false), true);

        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = ONE_IntegrationEndpointSelector.selectIntegrationEndpoint(WS_TEST_METADATA_NAME).ONE_Resource__c;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"data": [{"factura": "12","compensado": true}]}');
        RestContext.request = request;
        RestContext.response= response;
        Map<String, List<ONE_Orden_De_Venta__c>> OVs = ONE_WSFacturasSAP.updateOrdenDeVenta();
        System.assert(response.statusCode == 204);
    }

    @isTest static void testDescompensarOrdenVenta() {
        ONE_Orden_De_Venta__c OV = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(ONE_Numero_de_factura__c = '55205520', ONE_Compensado__c = true, ONE_Fecha_de_compensaci_n__c = System.today()), true);

        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = ONE_IntegrationEndpointSelector.selectIntegrationEndpoint(WS_TEST_METADATA_NAME).ONE_Resource__c;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"data": [{"factura": "55205520","compensado": false}]}');
        RestContext.request = request;
        RestContext.response= response;
        Map<String, List<ONE_Orden_De_Venta__c>> OVs = ONE_WSFacturasSAP.updateOrdenDeVenta();
        List<ONE_Orden_De_Venta__c> OVList = [SELECT Id, ONE_Numero_de_factura__c, ONE_Compensado__c, ONE_Fecha_de_compensaci_n__c FROM ONE_Orden_De_Venta__c WHERE ONE_Numero_de_factura__c = '55205520'];
        System.assert(OVList != null);
        System.assertEquals(OVList[0].ONE_Fecha_de_compensaci_n__c, null);
        System.assert(response.statusCode == 200);
    }

    // @isTest static void testExceptionUpdateOrdenVenta() {
    //     ONE_Orden_De_Venta__c OV = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(ONE_Numero_de_factura__c = '55205520', ONE_Compensado__c = false), true);

    //     User testUser = [Select Id from user where Profile.Name LIKE '%System%' and IsActive = true LIMIT 1];
    //     List<ONE_Orden_De_Venta__c> block = [SELECT Id, ONE_Numero_de_factura__c, ONE_Compensado__c, ONE_Fecha_de_compensaci_n__c FROM ONE_Orden_De_Venta__c WHERE ONE_Numero_de_factura__c = '55205520' FOR UPDATE];

    //     test.startTest();
    //     System.runAs(testUser){
    //         RestResponse response = new RestResponse();
    //         RestRequest request = new RestRequest();
    //         request.requestUri = ONE_IntegrationEndpointSelector.selectIntegrationEndpoint(WS_TEST_METADATA_NAME).ONE_Resource__c;
    //         request.httpMethod = 'PATCH';
    //         request.addHeader('Content-Type', 'application/json');
    //         request.requestBody = Blob.valueOf('{"data": [{"factura": "55205520","compensado": true}]}');
    //         RestContext.request = request;
    //         RestContext.response= response;
    //         Map<String, List<ONE_Orden_De_Venta__c>> OVs = ONE_WSFacturasSAP.updateOrdenDeVenta();
    //         System.debug(response.statusCode);
    //         System.assert(response.statusCode == 500);
    //     }
    //     test.stopTest();
    // }

}
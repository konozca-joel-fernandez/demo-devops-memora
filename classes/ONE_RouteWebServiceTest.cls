@IsTest
private class ONE_RouteWebServiceTest {

    @testSetup
    static void setupData() {
        ONE_Lugar__c lugarSuperior = new ONE_Lugar__c(Name = 'Zona Superior');
        insert lugarSuperior;

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar',
            ONE_Lugar_Superior__c = lugarSuperior.Id
        );
        insert lugar;

        Account centro = new Account(
            Name = 'Centro',
            ONE_Lugar__c = lugar.Id
        );
        insert centro;

        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = centro.Id
        );
        insert expediente;

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto servicio completo',
            ONE_Tipo_De_Venta__c = null
        );
        insert presupuesto;

        ONE_Tipologia_Producto__c tipologia = new ONE_Tipologia_Producto__c(
            Name = 'Tipo',
            ONE_Excepcion__c = '09'
        );
        insert tipologia;

        ONE_Producto__c producto = new ONE_Producto__c(
            Name = 'Producto',
            ONE_Tipologia_De_Producto_Lookup__c = tipologia.Id
        );
        insert producto;

        ONE_Expediente_Line_Item__c lineItem = new ONE_Expediente_Line_Item__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Presupuesto__c = presupuesto.Id,
            ONE_Producto__c = producto.Id,
            ONE_Numero_SLI__c = 1
        );
        insert lineItem;

        ONE_Ruta__c ruta = new ONE_Ruta__c(
            Name = 'Ruta Test',
            ONE_Lugar__c = lugarSuperior.Id
        );
        insert ruta;

        ONE_Punto_de_Interes__c poi = new ONE_Punto_de_Interes__c(
            Name = 'POI',
            ONE_Ruta__c = ruta.Id,
            ONE_Direccion__c = 'Calle 1',
            ONE_Municipio__c = 'Ciudad',
            ONE_Provincia_picklist__c = '08'
        );
        insert poi;
    }

    @IsTest
    static void testUpsertStops_OK() {
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        String body = JSON.serialize(new Map<String, Object>{
            'serviceId' => expediente.Id,
            'stops' => new List<Object>{
                new Map<String, Object>{
                    'Id' => 'selected-1',
                    'Name' => 'Punto nuevo',
                    'Address' => 'Calle Test',
                    'City' => 'Madrid',
                    'Province' => '08',
                    'ExtraInfo' => 'Info',
                    'SLINumber' => 1,
                    'Custom' => true,
                    'Selected' => true,
                    'RouteId' => null,
                    'StopId' => null,
                    'Deleted' => false
                }
            }
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/routes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ONE_RouteWebService.upsertStops();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
    }

    @IsTest
    static void testUpsertStops_MissingParams() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/routes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{}');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ONE_RouteWebService.upsertStops();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    static void testGetRoutes_OK() {
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        ONE_Presupuesto__c presupuesto = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1];

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/routes';
        req.httpMethod = 'GET';
        req.addParameter('serviceId', expediente.Id);
        req.addParameter('quoteId', presupuesto.Id);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ONE_RouteWebService.getRoutes();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(
            RestContext.response.responseBody.toString().contains('routes'),
            'La respuesta debe contener routes'
        );
    }

    @IsTest
    static void testGetRoutes_MissingServiceId() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/routes';
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ONE_RouteWebService.getRoutes();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }
}
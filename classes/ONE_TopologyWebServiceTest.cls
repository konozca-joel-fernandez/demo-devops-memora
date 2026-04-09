@IsTest
public with sharing class ONE_TopologyWebServiceTest {

    private static final String NOMBRECAT = 'testNombreCat';
    private static Id testServiceId;

    @TestSetup
    public static void dataSetup() {
        ONE_Lugar__c lugarSuperior = new ONE_Lugar__c(Name = 'Lugar Superior', ONE_Nivel_Jerarquico__c = 'zona_operativa');
        insert lugarSuperior;

        ONE_Lugar__c lugar = new ONE_Lugar__c(Name = 'Lugar Hijo', ONE_Lugar_Superior__c = lugarSuperior.Id);
        insert lugar;

        Account centro = new Account(Name = 'Centro', ONE_Lugar__c = lugar.Id);
        insert centro;

        ONE_Expediente__c expediente = new ONE_Expediente__c(ONE_Centro_Del_Expediente__c = centro.Id);
        insert expediente;

        ONE_Tipologia_Producto__c tipologiaProducto = ONE_TestDataFactory.createTipologiaProducto(
            new ONE_Tipologia_Producto__c(
                ONE_Nombre_CAT__c = NOMBRECAT
            ),
            true
        );

        ONE_Atributo__c attribute = ONE_TestDataFactory.createAttribute(
            new ONE_Atributo__c(
                ONE_Tipologia_De_Producto__c = tipologiaProducto.Id,
                Name = 'Piezas Seleccionadas'
            ),
            true
        );

        ONE_Recurso__c recursoSinZona = ONE_TestDataFactory.createRecurso(
            new ONE_Recurso__c(
                ONE_Atributo__c = attribute.Id,
                ONE_Tipo_De_Registro__c = '01' 
            ),
            true
        );

        ONE_Recurso__c recursoConZona = ONE_TestDataFactory.createRecurso(
            new ONE_Recurso__c(
                ONE_Atributo__c = attribute.Id,
                ONE_Lugar__c = lugarSuperior.Id,
                ONE_Tipo_De_Registro__c = '01'
            ),
            true
        );
    }

    @IsTest
    public static void getTypologyTest() {
        
        List<ONE_TopologyWebService.TipologiaProducto> tipologiaProductos;
        testServiceId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        
        Test.startTest();
        
        RestResponse res = new RestResponse();
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/typology?serviceId=' + testServiceId;
        req.httpMethod = 'GET';
        req.params.put('serviceId', testServiceId);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();

        ONE_TopologyWebService.getTypology();
        
        String responseStr = RestContext.response.responseBody.toString();

        tipologiaProductos = (List<ONE_TopologyWebService.TipologiaProducto>)JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<ONE_TopologyWebService.TipologiaProducto>.class
        );
        
        Test.stopTest();

        System.assertNotEquals(null, tipologiaProductos, 'El resultado no debería ser null');
    }
}
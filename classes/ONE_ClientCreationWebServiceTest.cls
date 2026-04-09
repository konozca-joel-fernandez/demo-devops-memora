/**
 * Created by mbujak003 on 19.05.2021.
 */
@IsTest
public with sharing class ONE_ClientCreationWebServiceTest {

    private static String REQ_JSON_PARTICULAR = '{"pedido":{"consentimientoFamiliar":true, "consentimientoElectium":true, "consentimientoVentaADistancia":true, "consentimientoDatosVentaFlores":true, "consentimientoAvisoLegal":true,"consentimientoDatosPresupuesto":true,"consentimientoPublicidad":true,"consentimientoGestionDatos":true,"idServicioConsulta":"<idServicio>","IDSAPempleado":"","tipoCliente":"Particular","nombreEmpresa":"","nombreCliente":"Martina","apellido1":"López","apellido2":"Martinez","tipoDeDocumento":"97","numeroDeDocumento":"54609640G","pais":"ES","provincia":"28","municipio":"Madrid","tipoDeCalle":"calle","direccion":"Amapola,15","numeroDeCalle":"7","piso":"6","codigoPostal":"10001","movil":"66456666","email":"martina@test.com","generacionFactura":false,"fechaDeFacturacion":"2021-03-23","importeTotal":10021},"lineasPedido":[{"codigoDeProducto":"<idProducto1>","cantidad":"1","lazoOTarjeta":"Lazo","textoBandaOLazo":"Marta, ojala nos pasaran las cosas revisadas","fraseTarjeta":"Prueba","remitente":"Juanito","importeBase":"263.00","importeimpuestos":"18","porcentajeImpuesto":"10"},{"codigoDeProducto":"<idProducto2>","cantidad":"1","lazoOTarjeta":"Tarjeta","textoBandaOLazo":"","fraseTarjeta":"Prueba","remitente":"marina","importeBase":"2633.00","importeimpuestos":"145","porcentajeImpuesto":"7"}]}';
    private static String REQ_JSON_EMPRESA = '{"pedido":{"consentimientoFamiliar":true, "consentimientoElectium":true, "consentimientoVentaADistancia":true, "consentimientoDatosVentaFlores":true, "consentimientoAvisoLegal":true,"consentimientoDatosPresupuesto":true,"consentimientoPublicidad":true,"consentimientoGestionDatos":true, idServicioConsulta":"<idServicio>","IDSAPempleado":"","tipoCliente":"Empresa","nombreEmpresa":"","nombreCliente":"Martina","apellido1":"López","apellido2":"Martinez","tipoDeDocumento":"97","numeroDeDocumento":"54609640G","pais":"ES","provincia":"28","municipio":"Madrid","tipoDeCalle":"calle","direccion":"Amapola,15","numeroDeCalle":"7","piso":"6","codigoPostal":"10001","movil":"66456666","email":"martina@test.com","generacionFactura":false,"fechaDeFacturacion":"2021-03-23","importeTotal":10021},"lineasPedido":[{"codigoDeProducto":"<idProducto1>","cantidad":"1","lazoOTarjeta":"Lazo","textoBandaOLazo":"Marta, ojala nos pasaran las cosas revisadas","fraseTarjeta":"Prueba","remitente":"Juanito","importeBase":"263.00","importeimpuestos":"18","porcentajeImpuesto":"10"},{"codigoDeProducto":"<idProducto2>","cantidad":"1","lazoOTarjeta":"Tarjeta","textoBandaOLazo":"","fraseTarjeta":"Prueba","remitente":"marina","importeBase":"2633.00","importeimpuestos":"145","porcentajeImpuesto":"7"}]}';

    @TestSetup
    public static void dataSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
            ONE_Tipo_De_Impuesto__c = 'IVA');

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);

        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
            ONE_Tipo_De_Impuesto__c = 'IVA',
            ONE_Lugar__c = lugar.Id);

        insert new List<Account> {acc, accMemora};

        ONE_Catalogo_De_Precios__c catalogo = ONE_TestDataFactory.createCatalogoDePrecios(
            new ONE_Catalogo_De_Precios__c(
                ONE_Validez_Hasta__c = Date.today().addDays(1),
                ONE_Validez_Desde__c = Date.today().addDays(-1)
            ), true);

        ONE_Catalogo_De_Precios__c catalogo2 = ONE_TestDataFactory.createCatalogoDePrecios(
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

        ONE_Segmentacion_Acuerdo__c seg = new ONE_Segmentacion_Acuerdo__c(
            ONE_Vigencia_Desde__c = Date.today().addDays(-5),
            ONE_Vigencia_Hasta__c = Date.today().addDays(5)
        );
        insert seg;

        ONE_Expediente__c servicio = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Defuncion'),
            ONE_Difunto__c = acc.Id,
            ONE_Centro_Del_Expediente__c = accMemora.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Catalogo_De_Precios_Acuerdo__c = catalogo2.Id,
            ONE_Acuerdo_Comercial__c = seg.Id
        );
        insert servicio;

        ONE_Momento__c velacionMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT);
        ONE_Momento__c ceremonianMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_MOMENT);
        insert new List<ONE_Momento__c> {velacionMomento, ceremonianMomento};

        ONE_Agrupacion__c composicioneAgrupacion = new ONE_Agrupacion__c(Name = ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = velacionMomento.Id);
        ONE_Agrupacion__c ceremonialAgrupacion = new ONE_Agrupacion__c(Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = ceremonianMomento.Id);
        insert new List<ONE_Agrupacion__c>{composicioneAgrupacion, ceremonialAgrupacion};

        ONE_Categoria__c salasVelatoriolCategoria = new ONE_Categoria__c(ONE_Agrupacion__c= composicioneAgrupacion.Id,
            Name = (ONE_MomentoServiceConstants.VELACION_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0))
            ).get(0)
        );
        ONE_Categoria__c salasCeremonialCategoria = new ONE_Categoria__c(ONE_Agrupacion__c= ceremonialAgrupacion.Id,
            Name = (ONE_MomentoServiceConstants.CEREMONIA_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST.get(0)).
                get(0))
        );
        insert new List<ONE_Categoria__c>{salasCeremonialCategoria, salasVelatoriolCategoria};


        ONE_Producto__c velProducto = new ONE_Producto__c(Name = 'VelProd', ONE_Categoria__c = salasVelatoriolCategoria.Id);
        ONE_Producto__c ceremoniaProducto = new ONE_Producto__c(Name = 'CerProd', ONE_Categoria__c = salasCeremonialCategoria.Id,
            ONE_Codigo_Comercial__c = '1000005886');
        ONE_Producto__c velChildProducto = new ONE_Producto__c(Name = 'VelChildProd', ONE_Categoria__c = salasVelatoriolCategoria.Id,
            ONE_Codigo_Comercial__c = '1000005887');

        insert new List<ONE_Producto__c>{velProducto, ceremoniaProducto, velChildProducto};
    }


    @IsTest
    private static void testCreateClientParticular() {

        Id idServicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        List<ONE_Producto__c> productos = [SELECT Id FROM ONE_Producto__c LIMIT 2];
        String reqJson = REQ_JSON_PARTICULAR;
        reqJson = reqJson.replace('<idServicio>', idServicio);
        reqJson = reqJson.replace('<idProducto1>', productos[0].Id);
        reqJson = reqJson.replace('<idProducto2>', productos[1].Id);

        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl().toExternalForm() + '/client/create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqJson);
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new ClientCreationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponseClientCreation()));
        Test.setMock(HttpCalloutMock.class, new SalesOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponseSalesOrderCreation()));

        Test.startTest();

        ONE_ClientCreationWebService.createCient();

        Test.stopTest();
    }

    @IsTest
    private static void testCreateClientEmpresa() {

        Id idServicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        List<ONE_Producto__c> productos = [SELECT Id FROM ONE_Producto__c LIMIT 2];
        String reqJson = REQ_JSON_EMPRESA;
        reqJson = reqJson.replace('<idServicio>', idServicio);
        reqJson = reqJson.replace('<idProducto1>', productos[0].Id);
        reqJson = reqJson.replace('<idProducto2>', productos[1].Id);

        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl().toExternalForm() + '/client/create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqJson);
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        ONE_ClientCreationWebService.HttpError testingPass = new ONE_ClientCreationWebService.HttpError();
        testingPass.errorCode = 404;
        testingPass.errorMsg = 'NOT FOUND';
     
        

        Test.setMock(HttpCalloutMock.class, new ClientCreationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponseClientCreation()));
        Test.setMock(HttpCalloutMock.class, new SalesOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponseSalesOrderCreation()));

        Test.startTest();

        ONE_ClientCreationWebService.createCient();

        Test.stopTest();
    }

    @TestVisible
    private class ClientCreationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public ClientCreationMock(Integer code, String status, String body) {
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

    @TestVisible
    private static String prepareResponseClientCreation() {
        //TODO: proper object creation and serialization
        return '{"d":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/CustomerSet(\'100923301\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/CustomerSet(\'100923301\')","type":"ZONE_CUSTOMER_SRV.Customer"},"customerId":"100923301","Address":null,"BankAccount":null,"Company":null,"GeneralData":null,"PartnerFunction":null,"messageReturn":null,"SalesData":null,"TaxIndicator":null,"result":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/resultSet(\'S\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_CUSTOMER_SRV/resultSet(\'S\')","type":"ZONE_CUSTOMER_SRV.result"},"Result":"S"}}}';
    }

    @TestVisible
    private class SalesOrderMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public SalesOrderMock(Integer code, String status, String body) {
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

    @TestVisible
    private static String prepareResponseSalesOrderCreation() {
        //TODO: proper object creation and serialization
        return '{"d":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderSet(\'\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderSet(\'\')","type":"ZONE_SALESORDER_SRV.salesOrder"},"numPoliza":"","siniestro":"","contractNumber":"","invoiceNumber":"2105028014","businessData":null,"commentSet":null,"conditionsSet":null,"headerData":null,"itemDataSet":null,"partnerSet":null,"scheduleLineDataSet":null,"processSet":{"results":[{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","type":"ZONE_SALESORDER_SRV.process"},"contractNumber":"0038102329","code":"E8","message":"Contrato Particular 38102329 se ha grabado"},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","type":"ZONE_SALESORDER_SRV.process"},"contractNumber":"0038102329","code":"E8","message":"Documento 2105028014 grabado."}]},"messageReturn":{"results":[{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'V1\',Number=\'311\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'V1\',Number=\'311\')","type":"ZONE_SALESORDER_SRV.messageReturn"},"Type":"S","Id":"V1","Number":"311","Message":"Contrato Particular 38102329 se ha grabado","LogNo":"","LogMsgNo":"000000","MessageV1":"Contrato Particular","MessageV2":"38102329","MessageV3":"","MessageV4":"","Parameter":"SALES_HEADER_IN","Row":0,"Field":"","System":"CERCLNT100"},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'VF\',Number=\'311\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'VF\',Number=\'311\')","type":"ZONE_SALESORDER_SRV.messageReturn"},"Type":"S","Id":"VF","Number":"311","Message":"Documento 2105028014 grabado.","LogNo":"","LogMsgNo":"000000","MessageV1":"2105028014","MessageV2":"","MessageV3":"","MessageV4":"","Parameter":"","Row":0,"Field":"","System":""}]},"result":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/resultSet(\'E8\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/resultSet(\'E8\')","type":"ZONE_SALESORDER_SRV.result"},"Result":"S","EResult":"E8"}}}';
    }
}
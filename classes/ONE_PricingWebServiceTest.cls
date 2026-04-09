/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_PricingWebServiceTest {
    @TestSetup
    public static void dataSetup() {
        //LUGARES
        ONE_Lugar__c lugarDelegacion = ONE_TestDataFactory.createLugar(null, true); 
        ONE_Lugar__c lugarZona = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarDelegacion.Id), true);
        ONE_Lugar__c lugarArea = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarZona.Id), true);
        
        //CUENTAS
        Account acc = new Account(
            FirstName = 'John', 
            LastName = 'Smith', 
            Phone='334343242',
            ONE_Indicativo_Tel_fono__c = '+852 - Hong Kong',
            ONE_Email__c = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
            ONE_Tipo_De_Impuesto__c = 'IVA'
        );
        Account accMemora = new Account(
            Name = 'MemoraTestName', 
            Phone='54543322',
            ONE_Indicativo_Tel_fono__c = '+852 - Hong Kong',
            ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_CENTRO_MEMORA), 
            ONE_Lugar__c = lugarArea.Id,
            ONE_Tipo_De_Impuesto__c = 'IVA'
        );

        insert new List<Account> {acc, accMemora};

        //MOMENTOS
        ONE_Momento__c velacionMomento = new ONE_Momento__c(
            Name = ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT
        );
        ONE_Momento__c ceremonianMomento = new ONE_Momento__c(
            Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_MOMENT
        );

        insert new List<ONE_Momento__c> {velacionMomento, ceremonianMomento};

        //AGRUPACIÓNES
        ONE_Agrupacion__c composicioneAgrupacion = new ONE_Agrupacion__c(
            Name = ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = velacionMomento.Id
        );
        ONE_Agrupacion__c ceremonialAgrupacion = new ONE_Agrupacion__c(
            Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = ceremonianMomento.Id
        );

        insert new List<ONE_Agrupacion__c>{composicioneAgrupacion, ceremonialAgrupacion};

        //CATEGORÍAS
        ONE_Categoria__c salasVelatoriolCategoria = new ONE_Categoria__c(
            ONE_Agrupacion__c = composicioneAgrupacion.Id,
            Name = (ONE_MomentoServiceConstants.VELACION_SERVICO_CATEGORIA_MAP
                .get(ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST
                    .get(0)
                )).get(0)
        );
        ONE_Categoria__c salasCeremonialCategoria = new ONE_Categoria__c(
            ONE_Agrupacion__c = ceremonialAgrupacion.Id,
            Name = (ONE_MomentoServiceConstants.CEREMONIA_SERVICO_CATEGORIA_MAP
                .get(ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST
                    .get(0)
                ).get(0))
        );

        insert new List<ONE_Categoria__c>{salasCeremonialCategoria, salasVelatoriolCategoria};

        //PRODUCTOS
        ONE_Producto__c velProducto = new ONE_Producto__c(
            Name = 'VelProd', 
            ONE_Categoria__c = salasVelatoriolCategoria.Id
        );
        ONE_Producto__c ceremoniaProducto = new ONE_Producto__c(
            Name = 'CerProd', 
            ONE_Categoria__c = salasCeremonialCategoria.Id,
            ONE_Codigo_Comercial__c = '1000005886'
        );
        ONE_Producto__c velChildProducto = new ONE_Producto__c(
            Name = 'VelChildProd', 
            ONE_Categoria__c = salasVelatoriolCategoria.Id,
            ONE_Codigo_Comercial__c = '1000005887'
        );

        insert new List<ONE_Producto__c>{velProducto, ceremoniaProducto, velChildProducto};

        //MODELOS
        ONE_Modelo__c ceremoniaModelo1 = new ONE_Modelo__c(
            Name = 'Modelo1',
            ONE_Nombre_ESP__c = 'Modelo1',
            ONE_Nombre_EUS__c = 'Modelo1',
            ONE_Nombre_CAT__c = 'Modelo1',
            ONE_Producto_Comercial__c = ceremoniaProducto.Id
        );
        ONE_Modelo__c ceremoniaModelo2 = new ONE_Modelo__c(
            Name = 'Modelo2',
            ONE_Nombre_ESP__c = 'Modelo2',
            ONE_Nombre_EUS__c = 'Modelo2',
            ONE_Nombre_CAT__c = 'Modelo2',
            ONE_Producto_Comercial__c = ceremoniaProducto.Id
        );
    
        insert new List<ONE_Modelo__c>{ceremoniaModelo1, ceremoniaModelo2};

        //CATALOGOS
        ONE_Catalogo_De_Precios__c catalogo = ONE_TestDataFactory.createCatalogoDePrecios(
            new ONE_Catalogo_De_Precios__c(
                //ONE_Validez_Hasta__c = Date.today().addDays(15),
                ONE_Validez_Desde__c = Date.today().addDays(-15),
                ONE_Centro__c = accMemora.Id
            ), 
            true
        );
        ONE_Catalogo_De_Precios__c catalogo2 = ONE_TestDataFactory.createCatalogoDePrecios(
            new ONE_Catalogo_De_Precios__c(
                ONE_Validez_Hasta__c = Date.today().addDays(15),
                ONE_Validez_Desde__c = Date.today().addDays(-15),
                ONE_Centro__c = accMemora.Id
            ), 
            true
        );
        
        //RELACIÓN PRODUCTOS
        ONE_Relacion_De_Productos__c rel = new ONE_Relacion_De_Productos__c(
        	ONE_Producto_Comercial_Padre__c = velProducto.Id,
            ONE_Producto_Incluido__c = velChildProducto.Id,
            ONE_Tipo_De_Relacion__c = 'Pack'
        );
        insert rel;

        //ENTRADES DE PRECIOS
        ONE_Entrada_De_Precio__c entrada1 = ONE_TestDataFactory.createEntradaDePrecio(
            new ONE_Entrada_De_Precio__c(
                ONE_Catalogo_De_Precios__c = catalogo.Id,
                ONE_Concepto_Comercial__c = velProducto.Id,
                ONE_Precio__c = 300,
                ONE_Vigente_Hasta__c = Date.today().addDays(15),
                ONE_Vigente_Desde__c = Date.today().addDays(-15)
            ), 
            true
        );
        ONE_Entrada_De_Precio__c entrada2 = ONE_TestDataFactory.createEntradaDePrecio(
            new ONE_Entrada_De_Precio__c(
                ONE_Catalogo_De_Precios__c = catalogo.Id,
                ONE_Concepto_Comercial__c = velChildProducto.Id,
                ONE_Precio__c = 300,
                ONE_Vigente_Hasta__c = Date.today().addDays(15),
                ONE_Vigente_Desde__c = Date.today().addDays(-15)
            ), 
            true
        );
        ONE_Entrada_De_Precio__c entrada3 = ONE_TestDataFactory.createEntradaDePrecio(
            new ONE_Entrada_De_Precio__c(
                ONE_Catalogo_De_Precios__c = catalogo2.Id,
                ONE_Concepto_Comercial__c = ceremoniaProducto.Id,
                ONE_Precio__c = 300,
                ONE_Vigente_Hasta__c = Date.today().addDays(15),
                ONE_Vigente_Desde__c = Date.today().addDays(-15)
            ), 
            true
        );

        //ENTRADA DE MODELO --?
        ONE_Entrada_De_Modelo__c entradaDeModelo = ONE_TestDataFactory.createEntradaDeModelo(
            new ONE_Entrada_De_Modelo__c(
                ONE_Entrada_De_Precio__c = entrada3.Id,
                ONE_Catalogo_De_Precios__c = catalogo.Id,
                ONE_Modelo__c = ceremoniaModelo1.Id,
                ONE_Producto__c = ceremoniaProducto.Id
            ), 
            true
        );

        //SEGMENTO
        ONE_Segmentacion_Acuerdo__c seg = new ONE_Segmentacion_Acuerdo__c(
            ONE_Vigencia_Desde__c = Date.today().addDays(-5),
            ONE_Vigencia_Hasta__c = Date.today().addDays(5)
        );
        insert seg;


        //SERVICIO
        ONE_Expediente__c servicio = ONE_TestDataFactory.createExpediente(
            new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = accMemora.Id,
                ONE_Catalogo_De_Precios__c = catalogo.Id,
            	ONE_Catalogo_De_Precios_Acuerdo__c = catalogo2.Id,
                ONE_Acuerdo_Comercial__c = seg.Id
            ), 
            true
        );

        //INTERLOCUTOR
        ONE_Interlocutor__c interlocutor = ONE_TestDataFactory.createInterlocutor(
            new ONE_Interlocutor__c(
                ONE_Expediente__c = servicio.Id,
                ONE_Contacto__c = acc.Id
            ), 
            true
        );

        //ORDEN DE VENTA
        ONE_Orden_De_Venta__c ordenDeVenta = ONE_TestDataFactory.createOrdenDeVenta(
            new ONE_Orden_De_Venta__c(
                ONE_Pagador_Particular__c = interlocutor.Id,
                ONE_Servicio__c = servicio.Id,
                ONE_Fecha_De_Facturacion__c = Date.today(),
                ONE_Numero_de_factura__c = 'FV25/02/21',
                ONE_Forma_De_Pago__c = 'A',
                ONE_Moneda__c = 'EUR',
                ONE_IBAN__c = 'ES3621082850270010500972',
                ONE_Titular_De_La_Cuenta_Bancaria__c = 'José Carreño Iborra',
                ONE_El_Pagador_Es_El_Difunto__c = false
            ), 
            true
        );

        //PRESUPUESTO
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                ONE_Presupuesto__c.SObjectType.getDescribe().name,'ONE_Presupuesto_App'),
            ONE_Tipo_De_Contrato__c = 'Particular',
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
            ONE_Importe_IVA_3__c =23,
            ONE_Importe_IVA_21__c = 883,
            ONE_Importe_IVA_10__c = 33,
            ONE_Expediente__c = servicio.Id
        );
        insert presupuesto;

        //SLIs
        ONE_Expediente_Line_Item__c lineItem1 = new ONE_Expediente_Line_Item__c(
            ONE_Producto__c = velProducto.Id, 
            ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 223, 
            ONE_Impuesto__c = 888, 
            ONE_Cantidad__c = 2, 
            ONE_Expediente__c = servicio.Id , 
            ONE_Suplido__c = false, 
            ONE_Orden_De_Venta__c = ordenDeVenta.Id
        );
        ONE_Expediente_Line_Item__c lineItem2 = new ONE_Expediente_Line_Item__c(
            ONE_Producto__c = ceremoniaProducto.Id, 
            ONE_Presupuesto__c = presupuesto.Id, 
            ONE_Orden_De_Venta__c = ordenDeVenta.Id,
            ONE_Importe_Neto__c = 444, 
            ONE_Impuesto__c = 65, 
            ONE_Cantidad__c = 2, 
            ONE_Expediente__c = servicio.Id , 
            ONE_Suplido__c = false
        );
        ONE_Expediente_Line_Item__c lineItem3 = new ONE_Expediente_Line_Item__c(
            ONE_Producto__c = velChildProducto.Id, 
            ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 0, 
            ONE_Impuesto__c = 0, 
            ONE_Cantidad__c = 2, 
            ONE_Expediente__c = servicio.Id, 
            ONE_Suplido__c = false,
            ONE_Linea_De_Servicio_Padre__c = lineItem1.Id
        );
        ONE_Expediente_Line_Item__c lineItem4 = new ONE_Expediente_Line_Item__c(
            ONE_Producto__c = ceremoniaProducto.Id, 
            ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 55,
            ONE_Impuesto__c = 65, 
            ONE_Cantidad__c = 2, 
            ONE_Expediente__c = servicio.Id, 
            ONE_Suplido__c = true,
            ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId()
        );

        insert new List<ONE_Expediente_Line_Item__c>{lineItem1, lineItem2, lineItem3, lineItem4};
    }

    @IsTest
    public static void getPricingTest() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pricing/';
        req.httpMethod = 'GET';
        ONE_Presupuesto__c p = [SELECT Id, ONE_Tipo_De_Contrato__c FROM ONE_Presupuesto__c];
        p.ONE_Tipo_De_Contrato__c = 'Hoja de servicio';
        update p;
        req.params.put('serviceId', [SELECT Id FROM ONE_Expediente__c].Id);
        req.params.put('quoteId', p.Id);
        RestContext.request = req;
        RestContext.response= res;
        ONE_PricingWebService.getPricing();
        Test.stopTest();
        System.assertNotEquals(null, RestContext.response.responseBody.toString());
    }


    @IsTest
    public static void getPricingTest2() {
        ONE_Expediente__c exp = [SELECT Id, ONE_Acuerdo_Comercial__c  FROM ONE_Expediente__c];
        exp.ONE_Acuerdo_Comercial__c = null;
        update exp;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pricing/';
        req.httpMethod = 'GET';
        req.params.put('serviceId', [SELECT Id FROM ONE_Expediente__c].Id);
        req.params.put('quoteId', [SELECT Id FROM ONE_Presupuesto__c].Id);
        RestContext.request = req;
        RestContext.response= res;
        ONE_PricingWebService.getPricing();
        Test.stopTest();
        System.assertNotEquals(null, RestContext.response.responseBody.toString());
    }
    
    @IsTest
    public static void getPricingTest3() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pricing/';
        req.httpMethod = 'GET';
        req.params.put('serviceId', null);
        req.params.put('quoteId', null);
        RestContext.request = req;
        RestContext.response= res;
        ONE_PricingWebService.getPricing();
        Test.stopTest();
    }
}
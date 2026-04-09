/**
 * Created by mbujak003 on 27.05.2021.
 *
 * LOGs:
 * ------------------------------------------
 * DATA       USER            CHANGE
 * 28.03.23   Miguel Serrat   ORI-2525 // ORI-4867 : Update for data validation
 * ------------------------------------------
 */
@IsTest
public with sharing class ONE_SynchronizeWebServiceTest {
    private static String JSON_REQ_TEMPLATE = '{\n' +
        '  "actualQuote": "{%IdQuote%}",\n' +
        '  "taxes": "IVA",\n' +
        '  "StartVelacion": "2021-05-05T00:49",\n' +
        '  "StartFinalDestination": "2021-06-05T00:49",\n' +
        '  "StartCrematorio": "2021-07-05T00:49",\n' +
        '  "StartCeremonia": "2021-08-05T00:49",\n' +
        '  "SiniestroNumber": "X5435464574R",\n' +
        '  "ServiceWorkPlaceName": "Tanatorio Les Corts",\n' +
        '  "serviceType": "Servicio Integral",\n' +
        '  "ServiceOwnerSurname": "Sierra López",\n' +
        '  "ServiceOwnerName": "Laura",\n' +
        '  "segmentType": "Nobilis",\n' +
        '  "SegmenttId": "{%SegmenttId%}",\n' +
        '  "SegmentName": "Z_Meridiem Levante",\n' +
        '  "pvaStretch1": 1000,\n' +
		'  "pvaStretch2": 2000,\n' +
		'  "serviceRecordType": "ONE_Servicio_Defuncion",\n' +
		'  "checkStockWorkPlace": true,\n' +
		'  "SLICounter": 190,\n' +
        '  "centroCementiris": true,\n' +
        '  "quotes": [\n' +
        '    {\n' +
        '      "valueDiscount": 12,\n' +
        '      "typeOfContract": "Particular",\n' +
        '      "totalAmount": 531.1,\n' +
        '      "TaxAmountSuplido": 0,\n' +
        '      "TaxAmount4": 0,\n' +
        '      "TaxAmount3": 0,\n' +
        '      "TaxAmount21": 2121,\n' +
        '      "TaxAmount10": 0,\n' +
        '      "TaxAmount0": 0,\n' +
        '      "status": "Contratado",\n' +
        '      "SLI": [\n' +
        '        {\n' +
        '          "taxPrice": 0,\n' +
        '          "tax": 21,\n' +
        '          "Suplido": false,\n' +
        '          "status": "Confirmado",\n' +
        '          "SLINumber": 1,\n' +
        '          "parentSLINumber": null,\n' +
        '          "queryStock": false,\n' +
        '          "quantity": 1,\n' +
        '          "productId": "{%productId%}",\n' +
        '          "PriceList": 0,\n' +
        '          "pricelisEntryId": "{%pricelisEntryId%}",\n' +
        '          "OwnerSLI": "{%OwnerSLI%}",\n' +
        '          "NoServir": false,\n' +
        '          "netPrice": 0,\n' +
        '          "modelId": "",\n' +
        '          "MejoraCompania": false,\n' +
        '          "lineCategory": "02",\n' +
        '          "Id": "{%IdSLI%}",\n' +
        '          "hasStock": false,\n' +
        '          "freePrice": null,\n' +
        '          "discountvalue": null,\n' +
        '          "discountType": "Porcentaje (%)",\n' +
        '          "discountReason": "",\n' +
        '          "discountPrice": 0,\n' +
        '          "basePrice": 0,\n' +
        '          "Attachment": [\n' +
        '            {\n' +
        '              "DocName": null,\n' +
        '              "Bas64Content": null\n' +
        '            }\n' +
        '          ],\n' +
        '          "Atributos": [{%Atributos%}]\n' +
        '        }\n' +
        '      ],\n' +
        '      "Signatures": [\n' +
        '        {\n' +
        '          "DocName": "Contrato 26-04-2021 11:45",\n' +
        '          "Bas64Content": null\n' +
        '        },\n' +
        '        {\n' +
        '          "DocName": "Condiciones de Contratación 26-04-2021 11:45",\n' +
        '          "Bas64Content": null\n' +
        '        }\n' +
        '      ],\n' +
        '      "ServiceId": "{%IdService%}",\n' +
        '      "salesType": "",\n' +
        '      "quoteType": "Presupuesto servicio completo",\n' +
        '      "QuoteOwner": "{%QuoteOwner%}",\n' +
        '      "QuoteNumber": "",\n' +
        '      "preconfigured": true,\n' +
        '      "paymentMethod": "1",\n' +
        '      "NetAmountSuplido": 0,\n' +
        '      "NetAmount4": 0,\n' +
        '      "NetAmount3": 0,\n' +
        '      "NetAmount21": 60.5,\n' +
        '      "NetAmount10": 0,\n' +
        '      "NetAmount0": 0,\n' +
        '      "interlocutorId": "",\n' +
        '      "interlocutorDocNumber": "10470384W",\n' +
        '      "Id": "{%IdQuote%}",\n' +
        '      "freeprice": 34,\n' +
        '      "discountType": "Precio libre",\n' +
        '      "discountReason": "texto abierto?",\n' +
        '      "CreatedDate": "2021-04-07T16:49",\n' +
        '      "BaseAmountSuplido": 0,\n' +
        '      "BaseAmount4": 0,\n' +
        '      "BaseAmount3": 0,\n' +
        '      "BaseAmount21": 50,\n' +
        '      "BaseAmount10": 0,\n' +
        '      "BaseAmount0": 0,\n' +
        '      "BaseAmount": 23223\n' +
        '    }\n' +
        '  ],\n' +
        '  "ProvinceVelacion": "08",\n' +
        '  "ProvinceDeceasedPlace": "08",\n' +
        '  "ProvinceCrematorio": "08",\n' +
        '  "ProvinceCeremonia": "08",\n' +
        '  "priceParticularName": "CATALOGO TEST DEMO E INTEGRACION APP 2",\n' +
        '  "priceParticularId": "{%priceParticularId%}",\n' +
        '  "priceAgreementName": null,\n' +
        '  "priceAgreementId": null,\n' +
        '  "PostalCodeVelacion": "08028",\n' +
        '  "PostalCodeFinalDestination": "08028",\n' +
        '  "PostalCodeDeceasedPlace": "08028",\n' +
        '  "PostalCodeCrematorio": "08840",\n' +
        '  "PostalCodeCeremonia": "08860",\n' +
        '  "PolizaNumber": "9857ERTEE",\n' +
        '  "nServicio": "",\n' +
        '  "namePlaceVelacion": "Tanatorio Les Corts",\n' +
        '  "NamePlaceFinalDestination": "Cementerio Montjuic",\n' +
        '  "namePlaceCeremonia": "Tanatorio Les Corts",\n' +
        '  "NameDeceasedPlace": "Hospital Vall D’Hebrón",\n' +
        '  "language": "es",\n' +
        '  "interlocutors": [\n' +
        '    {\n' +
        '      "ServiceId": "{%IdService%}",\n' +
        '      "relation": "Madrastra",\n' +
        '      "ProvinceInterlocutor": "08",\n' +
        '      "PostalCodeInterlocutor": "08860",\n' +
        '      "NumberId": "49241142M",\n' +
        '      "LastName": "ELBUEsdsdsNOPEVERDADGsdsABRI",\n' +
        '      "interlocutorId": "newID-123456789",\n' +
        '      "IdContact": "",\n' +
        '      "FirstName": "serdrdrdse",\n' +
        '      "DocTypeInterlocutor": "97",\n' +
        '      "Declarante": true,\n' +
        '      "CountryInterlocutor": "ES",\n' +
        '      "clasification": "Participante",\n' +
        '      "CityInterlocutor": "Gavà",\n' +
        '      "AddressInterlocutor": "Calle Roure 56",\n' +
        '      "EmailInterlocutor": "gespin@test.com",\n' +
        '      "PhoneInterlocutor": "659414175"\n' +
        '    }\n' +
        '  ],\n' +
        '  "IdVelacion": "{%IdVelacion%}",\n' +
        '  "IdServiceWorkPLace": "{%IdServiceWorkPLace%}",\n' +
        '  "IdServiceOwner": "{%IdServiceOwner%}",\n' +
        '  "IdFinalDestination": "{%IdFinalDestination%}",\n' +
        '  "IdDeceasedPlace": "",\n' +
        '  "IdDeceased": "{%IdDeceased%}",\n' +
        '  "IdCrematorio": "",\n' +
        '  "IdCeremonia": "{%IdCeremonia%}",\n' +
        '  "Id": "{%IdService%}",\n' +
        '  "EndVelacion": "2021-04-07T20:49",\n' +
        '  "EndCrematorio": "",\n' +
        '  "EndCeremonia": "2021-04-08T17:49",\n' +
        '  "Difunto": {\n' +
        '    "typeDoc": "97",\n' +
        '    "surnameDeceased": "Espin nomuerto",\n' +
        '    "numberDoc": "33623280V",\n' +
        '    "nameDeceased": "Test Gabri",\n' +
        '    "Id": "",\n' +
        '    "deceasedDate": "2020-04-05T00:49",\n' +
        '    "birthDate": "1990-10-28"\n' +
        '  },\n' +
        '  "deceasedType": "1",\n' +
        '  "CountryVelacion": "ES",\n' +
        '  "CountryFinalDestination": "ES",\n' +
        '  "CountryDeceasedPlace": "ES",\n' +
        '  "CountryCrematorio": "",\n' +
        '  "CountryCeremonia": "ES",\n' +
        '  "company": "",\n' +
        '  "clientType": "Particular",\n' +
        '  "CityVelacion": "Barcelona",\n' +
        '  "CityFinalDestination": "Barcelona",\n' +
        '  "CityFinalDeceasedPlace": "Barcelona",\n' +
        '  "CityCrematorio": "",\n' +
        '  "CityCeremonia": "Barcelona",\n' +
        '  "capital": 0,\n' +
        '  "AgreementName": "",\n' +
        '  "AgreementId": "",\n' +
        '  "AddressVelacion": "C/ Sant Joan XXIII, 15-27",\n' +
        '  "AddressFinalDestination": "Cementiri de Montjuïc 56 Carrer de la Mare de Déu de Port",\n' +
        '  "AddressDeceasedPlace": "Ciutat Sanitària de la Vall d’Hebron",\n' +
        '  "AddressCrematorio": "",\n' +
        '  "AddressCeremonia": "C/ Sant Joan XXIII, 15-27"\n' +
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
        List<ONE_Lugar__c> listPlaces = new List<ONE_Lugar__c>();
        ONE_Lugar__c lugarDelegacion = ONE_TestDataFactory.createLugar(null, true); 
       
        ONE_Lugar__c lugarZona = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarDelegacion.Id), true);

        ONE_Lugar__c lugarArea = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarZona.Id), true);         

        //ACOUNTS
        List<Account> listAcc = new List<Account>();
        Account accCentro = ONE_TestDataFactory.createCentro(new Account(
            ONE_Provincia__c = '08',
            ONE_Sociedad__c = '0500',
            ONE_Centro_Memora_Codigo_SAP__c = '2000',
        	ONE_Lugar__c = lugarArea.Id,
            ONE_Cementiris_De_Barcelona__c = true
        ),false);
        listAcc.add(accCentro);
        Account accPerson = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = '100910742',
            ONE_Municipio__pc = 'Sant Cebrià de Vallalta',
            ONE_Pais__c = 'ES',
            ONE_Pais__pc = 'ES',
            ONE_Provincia__pc = '08',
            ONE_Tipo_de_documento__pc = '97',
            ONE_N_Documento__pc = '95885446X',
            FirstName = 'Manolo',
            LastName = 'Bombo Grande',
            ONE_Direccion__pc = '45 Carrer Roure',
            ONE_Codigo_Postal__pc = '08396',
            ONE_Publicacion_Datos_Web__pc = 'No',
            ONE_Publicacion_Datos_Prensa__pc = 'No',
            ONE_Contacto_para_la_realizacion_de_encu__pc = 'No'
        ), false);
        listAcc.add(accPerson);
        
        insert listAcc;
        
        //TIPOLOGÍAS DE PRODUCTO
        ONE_Tipologia_Producto__c tipologiaDefault = ONE_TestDataFactory.createTipologiaProducto(
            new ONE_Tipologia_Producto__c(
                Name = 'Default'
            ),
            true
        );
        ONE_Tipologia_Producto__c tipologiaRequeridos = ONE_TestDataFactory.createTipologiaProducto(
            new ONE_Tipologia_Producto__c(
                Name = 'Requeridos'
            ),
            true
        );
        ONE_Tipologia_Producto__c tipologiaFlores = ONE_TestDataFactory.createTipologiaProducto(
            new ONE_Tipologia_Producto__c(
                Name = 'Flores'
            ),
            true
        );

        //ATRIBUTOS REQ.
        ONE_Atributo__c atributoRequerido = ONE_TestDataFactory.createAttribute(
            new ONE_Atributo__c(
                ONE_Campo_En_SF__c = 'Requerido',
                ONE_Tipologia_De_Producto__c = tipologiaRequeridos.Id,
                ONE_Requerido__c = true
            ),
            true
        );
        ONE_Atributo__c atributoTextoFlores = ONE_TestDataFactory.createAttribute(
            new ONE_Atributo__c(
                ONE_Campo_En_SF__c = 'ONE_Texto_Banda_O_Lazo__c',
                ONE_Tipologia_De_Producto__c = tipologiaFlores.Id,
                ONE_Requerido__c = true
            ),
            true
        );
        ONE_Atributo__c atributoFlores = ONE_TestDataFactory.createAttribute(
            new ONE_Atributo__c(
                ONE_Campo_En_SF__c = 'ONE_Tarjeta_O_Lazo__c',
                ONE_Tipologia_De_Producto__c = tipologiaRequeridos.Id,
                ONE_Requerido__c = true
            ),
            true
        );
        

        //PRODUCTOS:
        List<ONE_Producto__c> listProducts = new List<ONE_Producto__c>();
        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null,false);
        listProducts.add(producto);
        ONE_Producto__c productoFlores = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Flores',
                ONE_Tipologia_De_Producto_Lookup__c = tipologiaFlores.Id
            ),
            false
        );
        listProducts.add(productoFlores);
        ONE_Producto__c productoDescatalogado = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Descatalogado',
                ONE_Estado__c = 'Descatalogado',
                ONE_Tipologia_De_Producto_Lookup__c = tipologiaDefault.Id
            ), 
            false
        );
        listProducts.add(productoDescatalogado);
        ONE_Producto__c productoRequerido = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Requerido',
                ONE_Tipologia_De_Producto_Lookup__c = tipologiaRequeridos.Id
            ), 
            false
        );
        listProducts.add(productoRequerido);
        ONE_Producto__c productoCementiris = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Cementiris',
                ONE_Tipologia_De_Producto_Lookup__c = tipologiaDefault.Id, //habrá que crear tipologia cementiris
                ONE_C_digo_CB__c = '1',
                ONE_Cementiris_De_Barcelona__c = true
            ), 
            false
        );
        listProducts.add(productoCementiris);

        ONE_Producto__c productoRelatedCementiris = ONE_TestDataFactory.createProducto(
            new ONE_Producto__c(
                Name = 'Producto Related Cementiris',
                ONE_Tipologia_De_Producto_Lookup__c = tipologiaDefault.Id, //habrá que crear tipologia cementiris
                ONE_C_digo_CB__c = '1',
                ONE_Cementiris_De_Barcelona__c = false
            ), 
            false
        );
        listProducts.add(productoRelatedCementiris);
        
        insert listProducts;

        //CATALOGO DE PRECIOS:
        ONE_Catalogo_De_Precios__c catalogo = ONE_TestDataFactory.createCatalogoDePrecios(
            new ONE_Catalogo_De_Precios__c(
                ONE_Validez_Hasta__c = Date.today().addDays(1),
                ONE_Validez_Desde__c = Date.today().addDays(-1),
                ONE_Centro__c = listAcc[0].Id
            ), 
            true
        );

        //ENTRADA DE PRCIOS:
        List<ONE_Entrada_De_Precio__c> listEntradas = new List<ONE_Entrada_De_Precio__c>();
        ONE_Entrada_De_Precio__c entrada1 = ONE_TestDataFactory.createEntradaDePrecio(
            new ONE_Entrada_De_Precio__c(
                ONE_Catalogo_De_Precios__c = catalogo.Id,
                ONE_Concepto_Comercial__c = producto.Id
            ),
            false
        );
        listEntradas.add(entrada1);
        ONE_Entrada_De_Precio__c entrada2 = ONE_TestDataFactory.createEntradaDePrecio(
            new ONE_Entrada_De_Precio__c(
                ONE_Catalogo_De_Precios__c = catalogo.Id,
                ONE_Concepto_Comercial__c = productoDescatalogado.Id
            ), 
            false
        );
        listEntradas.add(entrada2);
        ONE_Entrada_De_Precio__c entrada3 = ONE_TestDataFactory.createEntradaDePrecio(
            new ONE_Entrada_De_Precio__c(
                ONE_Catalogo_De_Precios__c = catalogo.Id,
                ONE_Concepto_Comercial__c = productoRequerido.Id
            ), 
            false
        );
        listEntradas.add(entrada3);
        
        insert listEntradas;

        //ENTRADA DE MODELO:
        /*ONE_Entrada_De_Modelo__c entradaDeModelo = ONE_TestDataFactory.createEntradaDeModelo(
            new ONE_Entrada_De_Modelo__c(
                ONE_Entrada_De_Precio__c = entrada.Id,
                ONE_Catalogo_De_Precios__c = catalogo.Id
            ), true);*/
        

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(
            new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = listAcc[0].Id
            ), 
            true
        );

        ONE_Interlocutor__c interlocutor = ONE_TestDataFactory.createInterlocutor(
            new ONE_Interlocutor__c(
                ONE_Contacto__c = listAcc[1].Id
            ), 
            true
        );

        ONE_Orden_De_Venta__c ordenDeVenta = ONE_TestDataFactory.createOrdenDeVenta(
            new ONE_Orden_De_Venta__c(
                ONE_Pagador_Particular__c = interlocutor.Id,
                ONE_Servicio__c = expediente.Id,
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

        ONE_Presupuesto__c presupuesto = ONE_TestDataFactory.createPresupuesto(
            new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name,
                    'ONE_Presupuesto_App'),
                ONE_Tipo_De_Contrato__c = 'Particular',
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c =23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id,
                Productos_Recuperados_CB__c = true
            ),
            true
        );
        
        ONE_Expediente_Line_Item__c a = new ONE_Expediente_Line_Item__c();
      
        insert new ONE_Expediente_Line_Item__c(ONE_Expediente__c = expediente.Id, ONE_Presupuesto__c = presupuesto.Id, ONE_Producto__c = listProducts[0].Id, ONE_Precio__c = 100); 
    }

    @IsTest
    public static void synchronizeTest() {
        String retJson = '';
        ONE_PricingWebService.PricingObject dto = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/synchronize/';
        req.httpMethod = 'POST';
        
        ONE_Presupuesto__c quote = [SELECT Id, ONE_Expediente__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c FROM ONE_Presupuesto__c LIMIT 1];
        
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'IdService' => quote.ONE_Expediente__c,
            'IdQuote' => quote.Id,
            'IdSLI' => '',
            'SegmenttId' => '',
            'productId' => [SELECT Id FROM ONE_Producto__c LIMIT 1].Id,
            'pricelisEntryId' => '',
            'OwnerSLI' => UserInfo.getUserId(),
            'Atributos' => '',
            'QuoteOwner' => UserInfo.getUserId(),
            'priceParticularId' => [SELECT Id FROM ONE_Catalogo_De_Precios__c].Id,
            'IdVelacion' => '',
            'IdServiceWorkPLace' => '',
            'IdServiceOwner' => UserInfo.getUserId(),
            'IdServiceOwner' => UserInfo.getUserId(),
            'IdFinalDestination' => '',
            'IdDeceased' => '',
            'IdCeremonia' => ''
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeWebService.synchronize();
        Test.stopTest();
        //System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @IsTest
    public static void cementirisTest() {
        String retJson = '';
        ONE_PricingWebService.PricingObject dto = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/synchronize/';
        req.httpMethod = 'POST';
        
        ONE_Presupuesto__c quote = [SELECT Id, ONE_Expediente__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c FROM ONE_Presupuesto__c LIMIT 1];
        
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'IdService' => quote.ONE_Expediente__c,
            'IdQuote' => quote.Id,
            'IdSLI' => '',
            'SegmenttId' => '',
            'productId' => [SELECT Id FROM ONE_Producto__c WHERE Name = 'Producto Cementiris' LIMIT 1].Id,
            'pricelisEntryId' => '',
            'OwnerSLI' => UserInfo.getUserId(),
            'Atributos' => '',
            'QuoteOwner' => UserInfo.getUserId(),
            'priceParticularId' => [SELECT Id FROM ONE_Catalogo_De_Precios__c].Id,
            'IdVelacion' => '',
            'IdServiceWorkPLace' => '',
            'IdServiceOwner' => UserInfo.getUserId(),
            'IdServiceOwner' => UserInfo.getUserId(),
            'IdFinalDestination' => '',
            'IdDeceased' => '',
            'IdCeremonia' => ''
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeWebService.synchronize();
        Test.stopTest();
        //System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    public static void synchronizeTestErrDiscontinuedData() {
        String retJson = '';
        ONE_PricingWebService.PricingObject dto = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        ONE_Presupuesto__c quote = [SELECT Id, ONE_Expediente__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c FROM ONE_Presupuesto__c LIMIT 1];


        req.requestURI = '/services/apexrest/synchronize/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'IdService'=> quote.ONE_Expediente__c,
            'IdQuote' => quote.Id,
            'IdSLI'=> [SELECT Id FROM ONE_Expediente_Line_Item__c WHERE ONE_Presupuesto__c = :quote.Id LIMIT 1].Id,
            'SegmenttId' => '',
            'productId' => [SELECT Id FROM ONE_Producto__c WHERE Name = 'Producto Descatalogado' LIMIT 1].Id,
            'pricelisEntryId' => '',
            'IdSLIwner' => '',
            'IdFinalDestination' => '',
            'IdDeceased' => '',
            'IdCeremonia' => '',
            'IdService' => [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id,
            'QuoteOwner' => UserInfo.getUserId(),
            'priceParticularId' => [SELECT Id FROM ONE_Catalogo_De_Precios__c].Id,
            'IdVelacion' => '',
            'IdServiceWorkPLace' => '', 
            'IdServiceOwner' => UserInfo.getUserId(),
            'OwnerSLI' => UserInfo.getUserId(),
            'Atributos' => ''
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeWebService.synchronize();
        Test.stopTest();
    }

    @IsTest
    public static void synchronizeTestErrUncompletedData() {
        String retJson = '';
        ONE_PricingWebService.PricingObject dto = null;

        ONE_Presupuesto__c quote = [SELECT Id, ONE_Expediente__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c FROM ONE_Presupuesto__c LIMIT 1];
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/synchronize/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'SegmenttId' => '',
            'productId' => [SELECT Id FROM ONE_Producto__c WHERE Name = 'Producto Requerido' LIMIT 1].Id,
            'pricelisEntryId' => '',
            'QuoteOwner' => UserInfo.getUserId(),
            'priceParticularId' => [SELECT Id FROM ONE_Catalogo_De_Precios__c].Id,
            'IdVelacion' => '',
            'IdServiceWorkPLace' => '',
            'IdServiceOwner' => UserInfo.getUserId(), 
            'IdFinalDestination' => '',
            'IdDeceased' => '',
            'IdCeremonia' => '',
            'IdServiceOwner' => UserInfo.getUserId(),
            'OwnerSLI' => UserInfo.getUserId(),
            'Atributos' => '',
            'IdQuote' => quote.Id,
			'IdSLI' => '',
			'IdService' => quote.ONE_Expediente__c
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeWebService.synchronize();
        Test.stopTest();
    }

    @IsTest
    public static void synchronizeTestFLores() {
        String retJson = '';
        ONE_PricingWebService.PricingObject dto = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/synchronize/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String> {
            'SegmenttId' => '',
            'productId' => [SELECT Id FROM ONE_Producto__c WHERE Name = 'Producto Flores' LIMIT 1].Id,
            'pricelisEntryId' => '',
            'QuoteOwner' => UserInfo.getUserId(),
            'priceParticularId' => [SELECT Id FROM ONE_Catalogo_De_Precios__c].Id,
            'IdVelacion' => '',
            'IdServiceWorkPLace' => '',
            'IdServiceOwner' => UserInfo.getUserId(),
            'IdFinalDestination' => '',
            'IdDeceased' => '',
            'IdCeremonia' => '',
            'IdServiceOwner' => UserInfo.getUserId(),
            'OwnerSLI' => UserInfo.getUserId(),
            'Atributos' => '{"Value": null, "APIName": "ONE_Texto_Banda_O_Lazo__c"},\n{"Value": "_Sin dedicatoria", "APIName": "ONE_Tarjeta_O_Lazo__c"}',
            'IdQuote' => '',
			'IdSLI' => 'newSLI-1234',
			'IdService' => [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id
        }));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeWebService.synchronize();
        Test.stopTest();
    }
    
    @IsTest
    public static void synchronizeFailTest() {
        String retJson = '';
        ONE_PricingWebService.PricingObject dto = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/synchronize/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(handleRequest(new Map<String, String>()));
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeWebService.synchronize();
        System.debug(RestContext.response.responseBody.toString());
        dto = (ONE_PricingWebService.PricingObject)JSON.deserialize(
            RestContext.response.responseBody.toString(),
            ONE_PricingWebService.PricingObject.class
        );
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @IsTest
    public static void synchronizeFailTest2() {
        String retJson = '';
        ONE_PricingWebService.PricingObject dto = null;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/synchronize/';
        req.httpMethod = 'POST';
        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = res;
        ONE_SynchronizeWebService.synchronize();
        Test.stopTest();
    }
    
    @IsTest
    public static void dataStructureTest() {
        Test.startTest();
        ONE_SynchronizeWebService.ServiceDTO serviceTest = new ONE_SynchronizeWebService.ServiceDTO();
        serviceTest.deceasedType = null;
        serviceTest.clientType = null;
        serviceTest.serviceType  = null;
        serviceTest.capital = null;
        serviceTest.SegmenttId = null;
        serviceTest.AgreementId = null;
        serviceTest.segmentType = null;
        serviceTest.priceParticularId = null;
        serviceTest.priceAgreementId = null;
        serviceTest.language = null;
        serviceTest.IdVelacion = null;
        serviceTest.StartVelacion = null;
        serviceTest.EndVelacion = null;
        serviceTest.AddressVelacion = null;
        serviceTest.PostalCodeVelacion = null;
        serviceTest.CityVelacion = null;
        serviceTest.ProvinceVelacion = null;
        serviceTest.CountryVelacion = null;
        serviceTest.IdCeremonia = null;
        serviceTest.StartCeremonia = null;
        serviceTest.EndCeremonia = null;
        serviceTest.AddressCeremonia = null;
        serviceTest.PostalCodeCeremonia = null;
        serviceTest.CityCeremonia = null;
        serviceTest.ProvinceCeremonia = null;
        serviceTest.CountryCeremonia = null;
        serviceTest.IdCrematorio = null;
        serviceTest.StartCrematorio = null;
        serviceTest.EndCrematorio = null;
        serviceTest.AddressCrematorio = null;
        serviceTest.PostalCodeCrematorio = null;
        serviceTest.CityCrematorio = null;
        serviceTest.ProvinceCrematorio = null;
        serviceTest.CountryCrematorio = null;
        serviceTest.IdFinalDestination = null;
        serviceTest.StartFinalDestination = null;
        serviceTest.AddressFinalDestination = null;
        serviceTest.PostalCodeFinalDestination = null;
        serviceTest.CityFinalDestination = null;
        serviceTest.ProvinceDeceasedPlace = null;
        serviceTest.CountryDeceasedPlace = null;
        serviceTest.SiniestroNumber = null;
        serviceTest.PolizaNumber = null;
        serviceTest.IdServiceOwner = null;
        serviceTest.PostalCodeDeceasedPlace = null;
        serviceTest.CityFinalDeceasedPlace = null;
        serviceTest.IdServiceWorkPLace = null;
        serviceTest.IdDeceasedPlace = null;
        serviceTest.AddressDeceasedPlace = null;
        serviceTest.CountryFinalDestination = null;
        serviceTest.SLICounter = null;
        
        ONE_SynchronizeWebService.InterlocutorDTO interlocutorTest = new ONE_SynchronizeWebService.InterlocutorDTO();
        interlocutorTest.interlocutorId = null;
        interlocutorTest.IdContact = null;
        interlocutorTest.ServiceId = null;
        interlocutorTest.FirstName = null;
        interlocutorTest.LastName = null;
        interlocutorTest.Declarante = null;
        interlocutorTest.AddressInterlocutor = null;
        interlocutorTest.PostalCodeInterlocutor = null;
        interlocutorTest.CityInterlocutor = null;
        interlocutorTest.ProvinceInterlocutor = null;
        interlocutorTest.CountryInterlocutor = null;
        interlocutorTest.relation = null;
        interlocutorTest.clasification = null;
        interlocutorTest.DocTypeInterlocutor = null;
        interlocutorTest.EmailInterlocutor = null;
        interlocutorTest.PhoneInterlocutor = null;
        interlocutorTest.NumberId = null;
        
        ONE_SynchronizeWebService.DifuntoDTO difuntoTest = new ONE_SynchronizeWebService.DifuntoDTO();
        difuntoTest.Id = null;
        difuntoTest.nameDeceased = null;
        difuntoTest.surnameDeceased = null;
        difuntoTest.typeDoc = null;
        difuntoTest.numberDoc = null;
        difuntoTest.birthDate = null;
        difuntoTest.deceasedDate = null;
        
        Test.stopTest();
    }
}
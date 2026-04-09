@IsTest
public with sharing class ONE_UdianasCreateQueueableTest {

    private class UdianasMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            String endpoint = req.getEndpoint();

            if (endpoint != null && endpoint.contains('/Enterprises/Create')) {
                r.setStatusCode(200);
                r.setBody('{"enterprise": {"enterpriseHashId":"ENT_TEST"}}');
                return r;
            }

            if (endpoint != null && endpoint.contains('/InsuranceCompanies/Create')) {
                r.setStatusCode(200);
                r.setBody('{"insuranceCompany": {"insuranceCompanyHashId":"INS_TEST"}}');
                return r;
            }

            r.setStatusCode(200);
            r.setBody('{"udianaHashId":"FIN_TEST"}');
            return r;
        }
    }

    private class ThrowingMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new System.CalloutException('Simulated callout failure');
        }
    }

    private class EmptyResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            return r;
        }
    }

    private class ErrorStatusMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            String endpoint = req.getEndpoint();

            if (endpoint != null && endpoint.contains('/Enterprises/Create')) {
                r.setStatusCode(200);
                r.setBody('{"enterprise": {"enterpriseHashId":"ENT_TEST"}}');
                return r;
            }

            if (endpoint != null && endpoint.contains('/InsuranceCompanies/Create')) {
                r.setStatusCode(200);
                r.setBody('{"insuranceCompany": {"insuranceCompanyHashId":"INS_TEST"}}');
                return r;
            }

            r.setStatusCode(500);
            r.setBody('Internal Server Error');
            return r;
        }
    }

    @TestSetup
    static void setup() {
        Id rtPerson = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId();
        Id rtCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Centro_Memora').getRecordTypeId();

        Account declarante = new Account(
            RecordTypeId = rtPerson,
            LastName = 'Declarante',
            FirstName = 'Test',
            PersonEmail = 'decl@test.com',
            ONE_Idioma__pc = 'ES',
            ONE_Remision_de_info_y_accion_comercial__pc = 'Si'
        );
        insert declarante;

        Account difunto = new Account(
            RecordTypeId = rtPerson,
            FirstName = 'Pepe',
            LastName = 'Lopez',
            ONE_Sexo__c = 'Hombre'
        );
        insert difunto;

        ONE_Lugar__c delegacion = new ONE_Lugar__c(
            Name = 'CATALUNYA',
            ONE_Nivel_Jerarquico__c = 'delegacion'
        );
        insert delegacion;

        ONE_Lugar__c zona = new ONE_Lugar__c(
            Name = 'Z.GIRONA',
            ONE_Nivel_Jerarquico__c = 'zona_operativa',
            ONE_Lugar_Superior__c = delegacion.Id
        );
        insert zona;

        ONE_Lugar__c area = new ONE_Lugar__c(
            Name = 'AREA_GIRONA',
            ONE_Nivel_Jerarquico__c = 'area_operativa',
            ONE_Lugar_Superior__c = zona.Id
        );
        insert area;

        Account centro = new Account(
            RecordTypeId = rtCentro,
            Name = 'Centro Test',
            ONE_Lugar__c = area.Id,
            ONE_Nivel_Jerarquia_Cuentas__c = 'Jerarquía 2'
        );
        insert centro;

        ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Lugar__c = zona.Id,
            ONE_Compania__c = centro.Id,
            ONE_Centro__c = centro.Id,
            ONE_Tipo_De_Tarifa__c = 'Base',
            ONE_Estado__c = null
        );
        insert catalogo;

        ONE_Segmentacion_Acuerdo__c agreement = new ONE_Segmentacion_Acuerdo__c(
            ONE_Vigencia_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = centro.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Lugar__c = zona.Id
        );
        insert agreement;

        ONE_Expediente__c exp = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Defuncion'
            ),
            ONE_Fecha_De_Defuncion__c = Date.today(),
            ONE_Declarante__c = declarante.Id,
            ONE_Difunto__c = difunto.Id,
            ONE_In_Arboriam__c = 'Si',
            ONE_Centro_Del_Expediente__c = centro.Id,
            ONE_Servicio__c = 'Asegurado/Acuerdo',
            ONE_Catalogo_De_Precios_Acuerdo__c = catalogo.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id
        );
        insert exp;

        ONE_Expediente__c expDelegacion = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Defuncion'
            ),
            ONE_Fecha_De_Defuncion__c = Date.today(),
            ONE_Declarante__c = declarante.Id,
            ONE_Difunto__c = difunto.Id,
            ONE_In_Arboriam__c = 'Si',
            ONE_Centro_Del_Expediente__c = centro.Id,
            ONE_Servicio__c = 'Asegurado/Acuerdo',
            ONE_Catalogo_De_Precios_Acuerdo__c = catalogo.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id
        );
        insert expDelegacion;
    }

    @IsTest
    static void testQueueable_Success_200() {
        ONE_Expediente__c exp = [SELECT Id, ONE_Servicio__c FROM ONE_Expediente__c LIMIT 1];
        exp.ONE_Servicio__c = 'Particular';
        update exp;

        Test.setMock(HttpCalloutMock.class, new UdianasMock());

        Test.startTest();
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>{ exp.Id }));
        Test.stopTest();

        ONE_Expediente__c after = [
            SELECT Udiana_Status__c, Udiana_Hash_Id__c
            FROM ONE_Expediente__c WHERE Id = :exp.Id
        ];

        System.assertEquals('Sent', after.Udiana_Status__c);
        System.assertEquals('FIN_TEST', after.Udiana_Hash_Id__c);
    }

    @IsTest
    static void testQueueable_Error_ThrownException() {
        ONE_Expediente__c exp = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new ThrowingMock());

        Test.startTest();
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>{ exp.Id }));
        Test.stopTest();

        ONE_Expediente__c after = [
            SELECT Udiana_Status__c
            FROM ONE_Expediente__c WHERE Id = :exp.Id
        ];

        System.assertEquals('Error', after.Udiana_Status__c);
    }

    @IsTest
    static void testQueueable_NoResponse() {
        ONE_Expediente__c exp = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new EmptyResponseMock());

        Test.startTest();
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>{ exp.Id }));
        Test.stopTest();

        ONE_Expediente__c after = [
            SELECT Udiana_Status__c
            FROM ONE_Expediente__c
            WHERE Id = :exp.Id
        ];

        System.assertEquals('Error', after.Udiana_Status__c);
    }

    @IsTest
    static void testQueueable_Delegacion_UsingSetup() {

        ONE_Expediente__c exp = [
            SELECT Id FROM ONE_Expediente__c LIMIT 1
        ];

        Test.setMock(HttpCalloutMock.class, new UdianasMock());

        Test.startTest();
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>{ exp.Id }));
        Test.stopTest();

        ONE_Lugar__c lugar = [
            SELECT ONE_EnterpriseHashId__c
            FROM ONE_Lugar__c
            WHERE ONE_Nivel_Jerarquico__c = 'zona_operativa'
            AND Name = 'Z.GIRONA'
            LIMIT 1
        ];

        System.assertEquals('ENT_TEST', lugar.ONE_EnterpriseHashId__c);
    }

    @IsTest
    static void testQueueable_Error_ByStatusCode() {

        ONE_Expediente__c exp = [SELECT Id, ONE_Servicio__c FROM ONE_Expediente__c LIMIT 1];
        exp.ONE_Servicio__c = 'Particular';
        update exp;

        Test.setMock(HttpCalloutMock.class, new ErrorStatusMock());

        Test.startTest();
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>{ exp.Id }));
        Test.stopTest();

        ONE_Expediente__c after = [
            SELECT Udiana_Status__c
            FROM ONE_Expediente__c
            WHERE Id = :exp.Id
        ];

        System.assertEquals('Error', after.Udiana_Status__c);
    }

    @IsTest()
    static void testResolveApiKey_Serfunle() {
        ONE_UdianasCreateQueueable q = new ONE_UdianasCreateQueueable(new List<Id>());

        String apiKey = q.getSerfunleApiKey();
        System.assertNotEquals(null, apiKey);
    }

    @IsTest()
    static void testResolveApiKey_DefaultAndSerfunle_NoInsertMDT() {

        ONE_UdianasCreateQueueable q = new ONE_UdianasCreateQueueable(new List<Id>());

        Test.startTest();
        String kDefault  = q.resolveApiKey(null);
        String kSerfunle = q.resolveApiKey('SERFUNLE');  
        Test.stopTest();

        System.assertNotEquals(null, kDefault);
        System.assertNotEquals(null, kSerfunle);
    }

    @IsTest
    static void testApplyNoSendPreUpdates_PersistsEnterpriseAndSetsPending() {

        ONE_Expediente__c exp = [
            SELECT Id,
                ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id,
                ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_EnterpriseHashId__c
            FROM ONE_Expediente__c
            LIMIT 1
        ];

        ONE_Lugar__c zona = [
            SELECT Id, ONE_EnterpriseHashId__c
            FROM ONE_Lugar__c
            WHERE Id = :exp.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id
            LIMIT 1
        ];
        zona.ONE_EnterpriseHashId__c = null;
        update zona;

        Test.startTest();
        ONE_UdianasCreateQueueable.applyNoSendPreUpdates(exp.Id, exp, 'ENT_PRE_TEST');
        Test.stopTest();

        ONE_Expediente__c expAfter = [
            SELECT Udiana_Status__c
            FROM ONE_Expediente__c
            WHERE Id = :exp.Id
        ];
        System.assertEquals('Pending', expAfter.Udiana_Status__c);

        ONE_Lugar__c zonaAfter = [
            SELECT ONE_EnterpriseHashId__c
            FROM ONE_Lugar__c
            WHERE Id = :zona.Id
        ];
        System.assertEquals('ENT_PRE_TEST', zonaAfter.ONE_EnterpriseHashId__c);
    }

    @IsTest
    static void testQueueable_AseguradoAcuerdo_WithODV_Sent() {

        Test.setMock(HttpCalloutMock.class, new UdianasMock());

        ONE_Expediente__c exp = [
            SELECT Id, ONE_Centro_Del_Expediente__c, ONE_In_Arboriam__c, ONE_Servicio__c
            FROM ONE_Expediente__c
            LIMIT 1
        ];

        // Presupuesto facturado
        ONE_Presupuesto__c p = new ONE_Presupuesto__c(
            ONE_Expediente__c = exp.Id,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto servicio completo',
            ONE_Estado_Facturacion_Presupuesto__c = 'Facturado (Orden de Venta creada)',
            ONE_Tipo_De_Venta__c = null
        );
        insert p;

        // Jerarquía: Agrupación SF en Parent.Parent
        Account agr = new Account(
            Name = 'AGR-J4',
            ONE_Nivel_Jerarquia_Cuentas__c = 'Agrupación Salesforce'
        );
        insert agr;

        Account parent = new Account(
            Name = 'PARENT-J5',
            ParentId = agr.Id
        );
        insert parent;

        Account payor = new Account(
            Name = 'PAYOR',
            ParentId = parent.Id
        );
        insert payor;

        // ODV candidata
        ONE_Orden_De_Venta__c odv = new ONE_Orden_De_Venta__c(
            ONE_Presupuesto__c = p.Id,
            ONE_Pagador_Compania__c = payor.Id,
            ONE_Orden_de_Venta_Cancelada__c = false
        );
        insert odv;

        Test.startTest();
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>{ exp.Id }));
        Test.stopTest();

        ONE_Expediente__c afterExp = [
            SELECT Udiana_Status__c, Udiana_Hash_Id__c
            FROM ONE_Expediente__c
            WHERE Id = :exp.Id
        ];
        System.assertEquals('Sent', afterExp.Udiana_Status__c);
        System.assertEquals('FIN_TEST', afterExp.Udiana_Hash_Id__c);
    }

    @IsTest
    static void testQueueable_AseguradoAcuerdo_NoODV_Pending_PersistsEnterprise() {

        Test.setMock(HttpCalloutMock.class, new UdianasMock());

        ONE_Expediente__c exp = [
            SELECT Id,
                ONE_Servicio__c,
                ONE_In_Arboriam__c,
                ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id
            FROM ONE_Expediente__c
            LIMIT 1
        ];

        // Forzamos zona sin hash para que se actualice en el no-send
        ONE_Lugar__c zona = [
            SELECT Id, ONE_EnterpriseHashId__c
            FROM ONE_Lugar__c
            WHERE Id = :exp.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id
            LIMIT 1
        ];
        zona.ONE_EnterpriseHashId__c = null;
        update zona;

        Test.startTest();
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>{ exp.Id }));
        Test.stopTest();

        ONE_Expediente__c afterExp = [
            SELECT Udiana_Status__c
            FROM ONE_Expediente__c
            WHERE Id = :exp.Id
        ];
        System.assertEquals('Pending', afterExp.Udiana_Status__c);

        ONE_Lugar__c zonaAfter = [
            SELECT ONE_EnterpriseHashId__c
            FROM ONE_Lugar__c
            WHERE Id = :zona.Id
        ];
        System.assertEquals('ENT_TEST', zonaAfter.ONE_EnterpriseHashId__c);
    }


}
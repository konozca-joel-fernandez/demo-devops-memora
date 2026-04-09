@IsTest
public with sharing class ONE_UdianasIntegrationServiceTest {

    private class UdianasMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();

            if (req.getEndpoint().contains('UDIANAS_ENTERPRISE_CREATE')) {
                r.setStatusCode(200);
                r.setBody('{"enterprise":{"enterpriseHashId":"HASH_ENT"}}');
                return r;
            }

            if (req.getEndpoint().contains('UDIANAS_INSURANCE_CREATE')) {
                r.setStatusCode(200);
                r.setBody('{"insuranceCompany":{"insuranceCompanyHashId":"HASH_INS"}}');
                return r;
            }

            r.setStatusCode(200);
            r.setBody('{"udianaHashId":"HASH_FINAL"}');
            return r;
        }
    }

    @TestSetup
    static void setup() {
        Id rtPerson = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular')
            .getRecordTypeId();

        Id rtCentro = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('ONE_Centro_Memora')
            .getRecordTypeId();

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

        Account centro = new Account(
            RecordTypeId = rtCentro,
            Name = 'Centro Test',
            ONE_Delegacion__c = delegacion.Id,
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
    }

    @IsTest
    static void testInvokeIntegration_Enqueued() {

        ONE_Expediente__c exp = [
            SELECT Id FROM ONE_Expediente__c LIMIT 1
        ];

        Test.setMock(HttpCalloutMock.class, new UdianasMock());

        ONE_UdianasIntegrationService.FlowInputs fi =
            new ONE_UdianasIntegrationService.FlowInputs();
        fi.recordId = exp.Id;

        Test.startTest();
        List<ONE_UdianasIntegrationService.FlowOutputs> out =
            ONE_UdianasIntegrationService.invokeIntegration(
                new List<ONE_UdianasIntegrationService.FlowInputs>{ fi }
            );
        Test.stopTest();

        System.assertEquals(1, out.size());
        System.assertEquals(true, out[0].success);
        System.assertEquals('Enqueued', out[0].message);
    }

    @IsTest
    static void testInvokeIntegration_PendingByZona() {

        List<ONE_Expediente__c> exps =
            [SELECT Id FROM ONE_Expediente__c];

        Test.setMock(HttpCalloutMock.class, new UdianasMock());

        List<ONE_UdianasIntegrationService.FlowInputs> inputs =
            new List<ONE_UdianasIntegrationService.FlowInputs>();

        for (ONE_Expediente__c e : exps) {
            ONE_UdianasIntegrationService.FlowInputs fi =
                new ONE_UdianasIntegrationService.FlowInputs();
            fi.recordId = e.Id;
            inputs.add(fi);
        }

        Test.startTest();
        List<ONE_UdianasIntegrationService.FlowOutputs> out =
            ONE_UdianasIntegrationService.invokeIntegration(inputs);
        Test.stopTest();

        System.assertEquals(exps.size(), out.size());
    }

    @IsTest
    static void testInvokeIntegration_EmptyInput() {

        Test.startTest();
        List<ONE_UdianasIntegrationService.FlowOutputs> out =
            ONE_UdianasIntegrationService.invokeIntegration(null);
        Test.stopTest();

        System.assertEquals(0, out.size());
    }

    @IsTest
    static void testInvokeIntegration_NullRecordId() {

        ONE_UdianasIntegrationService.FlowInputs fi =
            new ONE_UdianasIntegrationService.FlowInputs();

        Test.startTest();
        List<ONE_UdianasIntegrationService.FlowOutputs> out =
            ONE_UdianasIntegrationService.invokeIntegration(
                new List<ONE_UdianasIntegrationService.FlowInputs>{ fi }
            );
        Test.stopTest();

        System.assertEquals(1, out.size());
    }

    @IsTest
    static void testInvokeIntegration_InsuranceHeadOfSeries_ByPayorHierarchy() {

        ONE_Expediente__c exp = [
            SELECT Id
            FROM ONE_Expediente__c
            LIMIT 1
        ];

        ONE_Presupuesto__c p = new ONE_Presupuesto__c(
            ONE_Expediente__c = exp.Id,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto servicio completo',
            ONE_Estado_Facturacion_Presupuesto__c = 'Facturado (Orden de Venta creada)',
            ONE_Tipo_De_Venta__c = null
        );
        insert p;

        Account agrupacion = new Account(
            Name = 'AGRUPACION-J4',
            ONE_Nivel_Jerarquia_Cuentas__c = 'Agrupación Salesforce',
            ONE_InsuranceHashId__c = null
        );
        insert agrupacion;

        Account parent = new Account(
            Name = 'PARENT-J5',
            ParentId = agrupacion.Id,
            ONE_Nivel_Jerarquia_Cuentas__c = null
        );
        insert parent;

        Account payor = new Account(
            Name = 'PAYOR',
            ParentId = parent.Id
        );
        insert payor;

        ONE_Orden_De_Venta__c odv = new ONE_Orden_De_Venta__c(
            ONE_Presupuesto__c = p.Id,
            ONE_Pagador_Compania__c = payor.Id,
            ONE_Orden_de_Venta_Cancelada__c = false
        );
        insert odv;

        Test.setMock(HttpCalloutMock.class, new UdianasMock());

        ONE_UdianasIntegrationService.FlowInputs fi1 = new ONE_UdianasIntegrationService.FlowInputs();
        fi1.recordId = exp.Id;

        ONE_UdianasIntegrationService.FlowInputs fi2 = new ONE_UdianasIntegrationService.FlowInputs();
        fi2.recordId = exp.Id;

        Test.startTest();
        List<ONE_UdianasIntegrationService.FlowOutputs> out =
            ONE_UdianasIntegrationService.invokeIntegration(
                new List<ONE_UdianasIntegrationService.FlowInputs>{ fi1, fi2 }
            );
        Test.stopTest();

        System.assertEquals(2, out.size());
        System.assertEquals(true, out[0].success);
        System.assertEquals(true, out[1].success);
    }
}
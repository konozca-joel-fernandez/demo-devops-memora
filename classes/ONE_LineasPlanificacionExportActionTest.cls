@IsTest
public with sharing class ONE_LineasPlanificacionExportActionTest {

    @TestSetup
    static void setup() {
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        
        Id rtCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Centro_Memora').getRecordTypeId();

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

        ONE_Expediente__c exp = ONE_TestDataFactory.createExpediente(
            new ONE_Expediente__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                    'ONE_Expediente__c',
                    'ONE_Servicio_Defuncion'
                ),
                ONE_Difunto__c = difunto.Id,
                ONE_Centro_Del_Expediente__c = centro.Id
            ),
            true
        );

        ONE_LineaPlanificacion__c lp = new ONE_LineaPlanificacion__c(
            ONE_Servicio__c = exp.Id,
            ONE_Zona_Operativa_Centro__c = 'Z.GIRONA'
        );
        insert lp;
    }

    @IsTest
    static void testExportarLineasPlanificacionSuccess() {
        Test.setMock(HttpCalloutMock.class, new SharePointPut201Mock());

        ONE_LineaPlanificacion__c lp = [SELECT Id FROM ONE_LineaPlanificacion__c LIMIT 1];

        ONE_LineasPlanificacionExportAction.FlowInputs inp = new ONE_LineasPlanificacionExportAction.FlowInputs();
        inp.lineas = new List<ONE_LineaPlanificacion__c>{
            new ONE_LineaPlanificacion__c(Id = lp.Id)
        };

        Test.startTest();
        List<ONE_LineasPlanificacionExportAction.FlowOutputs> outp =
            ONE_LineasPlanificacionExportAction.exportarLineasPlanificacion(
                new List<ONE_LineasPlanificacionExportAction.FlowInputs>{ inp }
            );
        Test.stopTest();

        System.assertEquals(1, outp.size());
        System.assertEquals(true, outp[0].success, 'Debe devolver success=true si el callout responde 200/201');
    }

    @IsTest
    static void testExportarLineasPlanificacionNoLineas() {
        ONE_LineasPlanificacionExportAction.FlowInputs inp = new ONE_LineasPlanificacionExportAction.FlowInputs();
        inp.lineas = new List<ONE_LineaPlanificacion__c>(); // vacío

        Test.startTest();
        List<ONE_LineasPlanificacionExportAction.FlowOutputs> outp =
            ONE_LineasPlanificacionExportAction.exportarLineasPlanificacion(
                new List<ONE_LineasPlanificacionExportAction.FlowInputs>{ inp }
            );
        Test.stopTest();

        System.assertEquals(1, outp.size());
        System.assertEquals(false, outp[0].success, 'Sin líneas debe devolver success=false');
    }

    private class SharePointPut201Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(201);
            r.setBody('{"ok":true}');
            return r;
        }
    }
}
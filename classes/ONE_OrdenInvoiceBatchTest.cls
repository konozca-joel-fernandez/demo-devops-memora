/**
 * Created by kmotyka005 on 21.10.2021.
 */

@IsTest
public with sharing class ONE_OrdenInvoiceBatchTest {
    //Static variable definition
    private static final String CREDENTIAL_NAME = 'GENERALI';
    private static final String CREDENTIAL_COMPANY = 'K';
    private static final String CREDENTIAL_USERNAME = 'username';
    private static final String CREDENTIAL_PASSWORD = 'password';

    //Data definition for testing
    @TestSetup
    private static void setup() {
        ONE_InsuranceIntegrationCredentials__c cs = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs;

        ONE_Expediente__c ex = ONE_TestDataFactory.createExpediente(null, false);
        ex.ONE_Numero_de_Siniestro__c = '123';
        insert ex;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];


        ContentVersion ct = new ContentVersion();
        ct.TagCsv = 'DOCUMENTACION_CIA';
        ct.Title = 'Test';
        ct.PathOnClient = 'Test.jpg';
        ct.VersionData = Blob.valueOf('s');
        ct.IsMajorVersion = true;
        insert ct;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = ex.Id;
        cdl.ContentDocumentId = [SELECT Id FROM ContentDocument].Id;
        insert cdl;

        ONE_Orden_De_Venta__c ordenRecord = ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_De_Venta__c(
            ONE_Servicio__c = ex.Id,
            ONE_Numero_de_factura__c = '123',
            ONE_Tipo_Tasa__c = '1',
            ONE_GeneraliOCajamar__c = 'G',
            ONE_estado__c = 'A',
            ONE_Tipo_De_Factura_M1__c='Principal',
            ONE_Facturado_Generali__c = false
        ), true);

        ONE_Lineas_Factura__c lf = new ONE_Lineas_Factura__c(
            ONE_tipo__c = 'SE',
                ONE_Tipo_de_Tasa__c = '1',
            ONE_Tipo_Impositivo__c = '0',
            ONE_Codigo__c = '23',
            ONE_Precio__c = 1000,
            ONE_Identificador_Linea__c = 'asd2',
            ONE_Orden_de_venta__c = ordenRecord.Id);

        insert lf;
    }
	//Invoke test
    @IsTest
    public static void invokeBatchTest() {
        ONE_Orden_De_Venta__c ordenRecord = [SELECT ONE_Servicio__c, Id,ONE_Numero_de_factura__c,ONE_Tipo_Tasa__c,ONE_GeneraliOCajamar__c,ONE_Facturado_Generali__c FROM ONE_Orden_De_Venta__c LIMIT 1];


        Test.setMock(HttpCalloutMock.class, new InvoiceBudgetMock());

        Test.startTest();
        Id batchJobId = Database.executeBatch(new ONE_OrdenInvoiceBatch(), 20);
        Test.stopTest();

        System.assertEquals([SELECT ONE_Facturado_Generali__c FROM ONE_Orden_De_Venta__c LIMIT 1].ONE_Facturado_Generali__c, true);

    }
	//Define mockup definitino for the response
    @TestVisible
    private class InvoiceBudgetMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('loginUserService')) {
                response.setBody('{\n' +
                    '    "codeError": "' + ONE_CommonConstants.HTPP_SUCCESS_CODE + '",\n' +
                    '    "sesion": "A4yrlp-5D9xddkWs3Pf4Zw7mHJzH_Ix1I85hLFjyw"\n' +
                    '}');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else if (endpoint.endsWith('invoice')) {
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('{\n' +
                    '    "codeError": "000 ",\n' +
                    '    "errorMessage":  "000 ",\n' +
                    '"budgets":[\n' +
                    '      {\n' +
                    '         "budgetNumber":"BgtwXf1fOnzklqSNVcPgmsADtCuoBBor0cqrxA5LMj5rrzO4UH",\n' +
                    '         "scales":[\n' +
                    '            {\n' +
                    '               "scaleId":"BgtwXf1fOnzklqSNVcPgmsADtCuoBBor0cqrxA5LMj505se"\n' +
                    '            },\n' +
                    '            {\n' +
                    '               "scaleId":"BgtwXf1fOnzklqSNVcPgmsADtCuoBBor0cqrxA5LMj505s"\n' +
                    '            }\n' +
                    '         ]\n' +
                    '}]}');
            }
            return response;
        }
    }
}
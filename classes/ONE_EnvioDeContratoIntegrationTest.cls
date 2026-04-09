/**
 * Created by mbujak003 on 24.02.2021.
 */
//Test for the contract SAP integration
@IsTest
public with sharing class ONE_EnvioDeContratoIntegrationTest {
    //Data setup for the test
    @TestSetup
    private static void dataSetup() {
        
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id, Name='Lugar2', ONE_Nivel_Jerarquico__c = 'zona_operativa'), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id,Name='Lugar1'), true);
        
        
        Account acc = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = 'someId'
        ), true);

        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(
            new ONE_Contrato__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Contrato__c', 'ONE_Contrato_M1'),
                ONE_Numero_Contrato_Anexo__c = 'test',
                ONE_Contratante__c = acc.Id,
                ONE_Beneficiario_1__c=acc.Id,
                //ONE_Forma_De_Pago__c = '1',
                ONE_Gerencia_Electium__c = 'Z.SEVILLA',
                ONE_Fecha_De_Contrato__c = 	Date.valueOf('2023-10-05'),
                ONE_Tipo_De_Contrato__c = 'Principal',
                ONE_Tipo_Contrato__c = 'Línea a Línea',
                ONE_Num_Mensualidades__c = Decimal.valueOf('7')
                //ONE_Cuota_Mensual__c = Decimal.valueOf('2'),
                //ONE_Codigo_Electium_Smart__c = '6',
                //ONE_Observaciones_Generales__c = ''
            ), true);
        
        ONE_Contrato__c contrato2 = ONE_TestDataFactory.createContrato(
            new ONE_Contrato__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Contrato__c', 'ONE_Contrato_M1'),
                ONE_Numero_Contrato_Anexo__c = 'test',
                ONE_Contratante__c = acc.Id,
                ONE_Beneficiario_1__c=acc.Id,
                //ONE_Forma_De_Pago__c = '1',
                ONE_Gerencia_Electium__c = 'Z.SEVILLA',
                ONE_Fecha_De_Contrato__c = 	Date.valueOf('2023-10-05'),
                ONE_Tipo_De_Contrato__c = 'Principal',
                ONE_Tipo_Contrato__c = 'Social',
                ONE_Num_Mensualidades__c = Decimal.valueOf('7')
                //ONE_Cuota_Mensual__c = Decimal.valueOf('2'),
                //ONE_Codigo_Electium_Smart__c = '6',
                //ONE_Observaciones_Generales__c = ''
            ), true);

        ONE_Contracto_Line_Item__c ocli1 = ONE_TestDataFactory.createContractoLineItem(
            new ONE_Contracto_Line_Item__c(
                ONE_Base_Imponible__c = 5,
                ONE_Tipo_Impositivo__c = '3',
                ONE_Total_Impuestos_Electium__c = 45,
                ONE_Contrato__c = contrato.Id
            ), true);

        ONE_Contracto_Line_Item__c ocli2 = ONE_TestDataFactory.createContractoLineItem(
            new ONE_Contracto_Line_Item__c(
                ONE_Base_Imponible__c = 70,
                ONE_Tipo_Impositivo__c = '4',
                ONE_Total_Impuestos_Electium__c = 45,
                ONE_Contrato__c = contrato.Id
            ), true);
        
        ONE_Contracto_Line_Item__c ocli3 = ONE_TestDataFactory.createContractoLineItem(
            new ONE_Contracto_Line_Item__c(
                ONE_Base_Imponible__c = 5,
                ONE_Tipo_Impositivo__c = '3',
                ONE_Total_Impuestos_Electium__c = 45,
                ONE_Contrato__c = contrato2.Id
            ), true);

        ONE_Contracto_Line_Item__c ocli4 = ONE_TestDataFactory.createContractoLineItem(
            new ONE_Contracto_Line_Item__c(
                ONE_Base_Imponible__c = 70,
                ONE_Tipo_Impositivo__c = '4',
                ONE_Total_Impuestos_Electium__c = 45,
                ONE_Contrato__c = contrato2.Id
            ), true);

    }
	//Test integration call
    @IsTest
    private static void invokeIntegrationTestLineaaLinea() {
        Test.setMock(HttpCalloutMock.class, new EnvioDeContratoMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_EnvioDeContratoIntegrationService.FlowInputs fi = new ONE_EnvioDeContratoIntegrationService.FlowInputs();
        fi.contractId = [SELECT Id FROM ONE_Contrato__c WHERE ONE_Tipo_Contrato__c = 'Línea a Línea' LIMIT 1].Id;
        List<ONE_EnvioDeContratoIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_EnvioDeContratoIntegrationService.invokeIntegration(new List<ONE_EnvioDeContratoIntegrationService.FlowInputs>{
            fi
        });
        Test.stopTest();
        System.debug(fo);
        System.assertNotEquals(fo[0].success, true);
    }
    
    @IsTest
    private static void invokeIntegrationTestSocial() {
        Test.setMock(HttpCalloutMock.class, new EnvioDeContratoMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_EnvioDeContratoIntegrationService.FlowInputs fi = new ONE_EnvioDeContratoIntegrationService.FlowInputs();
        fi.contractId = [SELECT Id FROM ONE_Contrato__c WHERE ONE_Tipo_Contrato__c = 'Social' LIMIT  1].Id;
        List<ONE_EnvioDeContratoIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_EnvioDeContratoIntegrationService.invokeIntegration(new List<ONE_EnvioDeContratoIntegrationService.FlowInputs>{
            fi
        });
        Test.stopTest();
        System.debug(fo);
        System.assertNotEquals(fo[0].success, true);
    }
	//Test response with mock callout
    @TestVisible
    private class EnvioDeContratoMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public EnvioDeContratoMock(Integer code, String status, String body) {
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
	//Prepare mockup response
    private static String prepareResponse() {
        //TODO: proper object creation and serialization
        return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/ZONE_ELECTUM_COBROSSet(\'\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/ZONE_ELECTUM_COBROSSet(\'\')","type":"ZONE_ELECTIUM_COBROS_SRV.ZONE_ELECTUM_COBROS"},"PI":"","TiFraCabecera":{"results":[{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/TiFraCabeceraSet(\'\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/TiFraCabeceraSet(\'\')","type":"ZONE_ELECTIUM_COBROS_SRV.TiFraCabecera"},"IdXblnr":"","XblnrFra":"","XblnrCbr":"","Kunnr":"100373049","Bukrs":"1140","Bldat":"/Date(1588809600000)/","Budat":"/Date(1588809600000)/","Zlsch":"V","Xref1":"30236/0-1","Xref3":"FRANCINA BALAGUE","Import":"121.000","Bktxt":"FACTURA ELECTIUM"}]},"TiReturn":{"results":[{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/TiReturnSet(\'\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/TiReturnSet(\'\')","type":"ZONE_ELECTIUM_COBROS_SRV.TiReturn"},"Type":"E","Id":"","Number":"000","Message":"ERROR:Ya existe el apunte 1400006530 con este contrato/versión 30236/0-1","LogNo":"","LogMsgNo":"000000","MessageV1":"30236/0-1","MessageV2":"","MessageV3":"","MessageV4":"","Parameter":"","Row":0,"Field":"","System":""}]},"TiFraPosicion":{"results":[{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/TiFraPosicionSet(\'\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_ELECTIUM_COBROS_SRV/TiFraPosicionSet(\'\')","type":"ZONE_ELECTIUM_COBROS_SRV.TiFraPosicion"},"IdXblnr":"","WrbtrIng":"100.000","Contrapartida":"7050000004","Kostl":"0320-FU","ZuonrCp":"3026/0","SgtxtCp":"3026/0 - HILARIO FRESNILLO PEÑA","Mwskz":"R7","Fwste":"21.000"}]}}}';
    }
}
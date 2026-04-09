/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_ElectClientCreateIntegrationTest {
    @TestSetup
    private static void dataSetup() {

        Account acc = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = 'someId',
            ONE_Tipo_de_documento__pc = '94'
        ), true);

        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(
            new ONE_Contrato__c(
                ONE_Numero_Contrato_Anexo__c = 'test',
                ONE_Contratante__c = acc.Id,
                ONE_Beneficiario_1__c=acc.Id
            ), true);
    }

    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new ElectClientCreateMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_ElectClientCreateIntegrationService.FlowInputs fi = new ONE_ElectClientCreateIntegrationService.FlowInputs();
        fi.contractId = [SELECT Id FROM ONE_Contrato__c LIMIT 1].Id;
        List<ONE_ElectClientCreateIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_ElectClientCreateIntegrationService.invokeIntegration(new List<ONE_ElectClientCreateIntegrationService.FlowInputs> { fi });
        Test.stopTest();
        System.debug(fo);
        System.assertEquals(fo[0].status, true);
    }

    @TestVisible
    private class ElectClientCreateMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public ElectClientCreateMock(Integer code, String status, String body) {
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

    private static String prepareResponse() {
        //TODO: proper object creation and serialization
        return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZCRM_ELECTIUM_CLIENTES_SRV/ZCRM_ELECTIUM_CLIENTESSet(Country=\'ES\',Region=\'08\',Langu=\'ES\',Stcd1=\'01233445R\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZCRM_ELECTIUM_CLIENTES_SRV/ZCRM_ELECTIUM_CLIENTESSet(Country=\'ES\',Region=\'08\',Langu=\'ES\',Stcd1=\'01233445R\')","type":"ZCRM_ELECTIUM_CLIENTES_SRV.ZCRM_ELECTIUM_CLIENTES"},"EResult":"S","Ktokd":"Z001","Bukrs":"0500","TitleMedi":"","Name1":"CLIE 1","Name2":"","Name3":"","Name4":"XXXA","Street":"ARAGON","HouseNum1":"","HouseNum2":"","Roomnumber":"","Floor":"","PostCode1":"","City1":"","Country":"ES","Region":"08","Langu":"ES","TelNumber":"","FaxNumber":"","SmtpAddr":"","Stcd1":"01233445R","Stcd2":"123456","Banks":"","Bankl":"","Bankn":"","Bkont":"","Xezer":false,"Iban":"","Banka":"","StrasBco":"","Ort01Bco":"","Brnch":"","Swift":"","Akont":"","Zuawa":"","Fdgrv":"","Frgrp":"","Altkn":"","Zterm":"Z000","Guzte":"","Zwels":"A","Xzver":false,"Streetabbr":"","Vbund":"","Kunnr":"100472543","Return":{"results":[{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZCRM_ELECTIUM_CLIENTES_SRV/messageReturnSet(\'S\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZCRM_ELECTIUM_CLIENTES_SRV/messageReturnSet(\'S\')","type":"ZCRM_ELECTIUM_CLIENTES_SRV.messageReturn"},"Type":"S","Id":"","Number":"000","Message":"Cliente creado/modificado 0100472543 Nif:01233445R 123456","LogNo":"","LogMsgNo":"000000","MessageV1":"0100472543","MessageV2":"","MessageV3":"","MessageV4":"","Parameter":"","Row":0,"Field":"","System":""}]}}}';
    }
}
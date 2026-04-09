/**
 * Created by kmotyka005 on 27.10.2021.
 */

@IsTest
public with sharing class ONE_ConsultaDePolizaControllerTest {

    private static final String CREDENTIAL_NAME = 'GENERALI';
    private static final String CREDENTIAL_NAME_C = 'CAJAMAR';
    private static final String CREDENTIAL_NAME_K = 'KUTXABANK';
    private static final String CREDENTIAL_COMPANY = 'K';
    private static final String CREDENTIAL_USERNAME = 'username';
    private static final String CREDENTIAL_PASSWORD = 'password';

    @TestSetup
    public static void prepareValues() {
        ONE_InsuranceIntegrationCredentials__c cs = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs;
		
        ONE_InsuranceIntegrationCredentials__c cs2 = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME_K, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs2;
        
        ONE_InsuranceIntegrationCredentials__c cs3 = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME_C, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs3;
    }


    @IsTest
    public static void anadirActionTestNoPa() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
        System.debug([SELECT Id,ONE_N_Documento__pc FROM Account]);
        System.assertEquals([SELECT Id FROM Account].size(), 1);
        System.assertEquals([SELECT Id FROM ONE_Contrato__c].size(), 1);
    }
    
    @IsTest
    public static void anadirActionTestNoPaCajamar() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGeneratorCajamar());

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObjectC());

        Test.stopTest();
    }
  
    @IsTest
    public static void anadirActionTestNoPaKutxa() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaKutxaGenerator());

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObjectK());
        Test.stopTest();
    }
    
    
    @IsTest
    public static void anadirActionTestNoPaKutxaerr() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaKutxaGeneratorErr());

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObjectK());
        Test.stopTest();
    }

    @IsTest
    public static void anadirActionTestWithPa() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        ac.ONE_N_Documento__pc = '05424436R';
        insert ac;
        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
        System.assertEquals([SELECT Id FROM Account].size(), 1);
        System.assertEquals([SELECT Id FROM ONE_Contrato__c].size(), 1);
    }

    @IsTest
    public static void anadirActionTestWithPaAndContract() {
        
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        Account ac2 = ONE_TestDataFactory.createPersonAccount(null, false);
        ac2.FirstName = 'Test1';
        ac2.LastName = 'Test2';
        ac2.ONE_Tipo_de_documento__pc = '97';
        ac2.ONE_N_Documento__pc = '13489292E';
        ac2.ONE_Fecha_de_nacimiento__pc = Date.valueOf('2023-03-23');
        ac2.ONE_Direccion__pc = 'Carrer de Joaquim Molins 15';
        ac2.ONE_Municipio__pc = 'Barcelona';
        ac2.ONE_Provincia__pc = '08';
        ac2.ONE_Pais__pc = 'ES';
        ac2.ONE_Codigo_Postal__pc = '08028';

        insert ac2;
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Beneficiario_1__c=ac2.Id;
        contrato.ONE_Parentesco__c = '27';

        insert contrato;

        ac.ONE_N_Documento__pc = '05424436R';
        ac.ONE_Polizas_1__pc = contrato.Id;
        insert ac;


        Test.startTest();
        
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        List<ONE_Contrato__c> fcbb1 = new List<ONE_Contrato__c>();
        fcbb1 = ONE_ContratoHelper.fetchContratosByBeneficiaro1(contrato.ONE_Beneficiario_1__r.Name);
        ONE_Contrato__c fcbb2 = ONE_ContratoHelper.fetchContratosById(contrato.Id);
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
        System.assertNotEquals([SELECT ONE_Capital__c FROM ONE_Contrato__c].ONE_Capital__c, 25.00);
    }

    @IsTest
    public static void anadirActionTestWithPaAndContractPoliza2() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        Account ac2 = ONE_TestDataFactory.createPersonAccount(null, false);
        insert ac2;
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);
        ONE_Contrato__c contrato2 = ONE_TestDataFactory.createContrato(null, false);
        
        ac.ONE_N_Documento__pc = '05424436R';
        ac.ONE_Polizas_1__pc = null;
        ac.ONE_Poliza_2__pc = contrato2.Id;
        ac.FirstName = 'Test1';
        ac.LastName = 'Test2';
        ac.ONE_Tipo_de_documento__pc = '97';
        ac.ONE_Fecha_de_nacimiento__pc = Date.valueOf('2023-03-23');
        ac.ONE_Direccion__pc = 'Carrer de Joaquim Molins 15';
        ac.ONE_Municipio__pc = 'Barcelona';
        ac.ONE_Provincia__pc = '08';
        ac.ONE_Pais__pc = 'ES';
        ac.ONE_Codigo_Postal__pc = '08028';
        
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Beneficiario_1__c=ac.Id;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;


        insert ac;


        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
        System.assertNotEquals([SELECT ONE_Capital__c FROM ONE_Contrato__c].ONE_Capital__c, 25.00);
    }
    
    @IsTest
    public static void anadirActionTestWithNoPaAndContractExisting() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
    }
    
    @IsTest
    public static void anadirActionTestWithPaAndContractUpdate() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        Account ac2 = ONE_TestDataFactory.createPersonAccount(null, false);
        insert ac2;
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'C';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Beneficiario_1__c=ac.Id;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;
		
        ac.ONE_N_Documento__pc = '05424436R';
        ac.ONE_Polizas_1__pc = contrato.Id;
        ac.FirstName = 'Test1';
        ac.LastName = 'Test2';
        ac.ONE_Tipo_de_documento__pc = '97';
        ac.ONE_Fecha_de_nacimiento__pc = Date.valueOf('2023-03-23');
        ac.ONE_Direccion__pc = 'Carrer de Joaquim Molins 15';
        ac.ONE_Municipio__pc = 'Barcelona';
        ac.ONE_Provincia__pc = '08';
        ac.ONE_Pais__pc = 'ES';
        ac.ONE_Codigo_Postal__pc = '08028';
        insert ac;

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
    }

    @IsTest
    public static void anadirActionTestWithPaAndContract2Update() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        Account ac2 = ONE_TestDataFactory.createPersonAccount(null, false);
        insert ac2;
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'C';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Beneficiario_1__c=ac.Id;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;
		
        ac.ONE_N_Documento__pc = '05424436R';
        ac.ONE_Poliza_2__pc = contrato.Id;
        ac.FirstName = 'Test1';
        ac.LastName = 'Test2';
        ac.ONE_Tipo_de_documento__pc = '97';
        ac.ONE_Fecha_de_nacimiento__pc = Date.valueOf('2023-03-23');
        ac.ONE_Direccion__pc = 'Carrer de Joaquim Molins 15';
        ac.ONE_Municipio__pc = 'Barcelona';
        ac.ONE_Provincia__pc = '08';
        ac.ONE_Pais__pc = 'ES';
        ac.ONE_Codigo_Postal__pc = '08028';
        insert ac;

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
    }

	@IsTest
    public static void anadirActionTestWithPaAndContract2Update2() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        Account ac2 = ONE_TestDataFactory.createPersonAccount(null, false);
        insert ac2;
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;
        ONE_Contrato__c contrato2 = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '08';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Parentesco__c = '27';
        insert contrato2;
		
        ac.ONE_N_Documento__pc = '05424436R';
        ac.ONE_Polizas_1__pc = contrato2.Id;
        ac.ONE_Poliza_2__pc = contrato.Id;
        ac.FirstName = 'Test1';
        ac.LastName = 'Test2';
        ac.ONE_Tipo_de_documento__pc = '97';
        ac.ONE_Fecha_de_nacimiento__pc = Date.valueOf('2023-03-23');
        ac.ONE_Direccion__pc = 'Carrer de Joaquim Molins 15';
        ac.ONE_Municipio__pc = 'Barcelona';
        ac.ONE_Provincia__pc = '08';
        ac.ONE_Pais__pc = 'ES';
        ac.ONE_Codigo_Postal__pc = '08028';
        insert ac;

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
    }

	@IsTest
    public static void anadirActionTestWithPaAndContract2Update3() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '09';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;
		
        ac.ONE_N_Documento__pc = '05424436R';
        ac.ONE_Polizas_1__pc = contrato.Id;
        ac.FirstName = 'Test1';
        ac.LastName = 'Test2';
        ac.ONE_Tipo_de_documento__pc = '97';
        ac.ONE_Fecha_de_nacimiento__pc = Date.valueOf('2023-03-23');
        ac.ONE_Direccion__pc = 'Carrer de Joaquim Molins 15';
        ac.ONE_Municipio__pc = 'Barcelona';
        ac.ONE_Provincia__pc = '08';
        ac.ONE_Pais__pc = 'ES';
        ac.ONE_Codigo_Postal__pc = '08028';
        insert ac;

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
    }
    
	@IsTest
    public static void anadirActionTestWithPaAndContract2Update4() {
        Test.setMock(HttpCalloutMock.class, new ConsultaDePolizaGenerator());
        Account ac = ONE_TestDataFactory.createPersonAccount(null, false);
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '07';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Parentesco__c = '27';
        insert contrato;
        
        ONE_Contrato__c contrato2 = ONE_TestDataFactory.createContrato(null, false);        
        contrato.ONE_Ramo__c = '08';
        contrato.ONE_Compania_Aseguradora__c = 'G';
        contrato.ONE_Pol__c = '283000046';
        contrato.ONE_Capital__c = 25.00;
        contrato.ONE_Parentesco__c = '27';
        insert contrato2;
		
        ac.ONE_N_Documento__pc = '05424436R';
        ac.FirstName = 'Test1';
        ac.LastName = 'Test2';
        ac.ONE_Tipo_de_documento__pc = '97';
        ac.ONE_Fecha_de_nacimiento__pc = Date.valueOf('2023-03-23');
        ac.ONE_Direccion__pc = 'Carrer de Joaquim Molins 15';
        ac.ONE_Municipio__pc = 'Barcelona';
        ac.ONE_Provincia__pc = '08';
        ac.ONE_Pais__pc = 'ES';
        ac.ONE_Codigo_Postal__pc = '08028';
        insert ac;

        Test.startTest();
        String response = ONE_ConsultaDePolizaController.invokeIntegration(getFormObject());
        ONE_ConsultaDePolizaController.anadirAction(JSON.deserializeUntyped(response), 'generali');
        Test.stopTest();
    }
    
    @TestVisible
    private static Object getFormObject() {
        return JSON.deserializeUntyped('{"apellido1":"Maria", "apellido2":"Maria", "integrationType":"(Generali)", "nombre":"Maria"}');
    }
    
    @TestVisible
    private static Object getFormObjectC() {
        return JSON.deserializeUntyped('{"apellido1":"Maria", "apellido2":"Maria", "integrationType":"(Cajamar)", "nombre":"Maria"}');
    }
    
    @TestVisible
    private static Object getFormObjectK() {
        return JSON.deserializeUntyped('{"FechaOcurrencia":"5-2-2024", "NIFAsegurado":"", "NumPoliza":"0026001594", "integrationType":"(Kutxabank)"}');
    }


    @TestVisible
    private class ConsultaDePolizaGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('loginUserService')) {
                response.setBody('{\n' +
                    '    "codeError": "' + ONE_CommonConstants.HTPP_SUCCESS_CODE + '",\n' +
                    '    "sesion": "A4yrlp-5D9xddkWs3Pf4Zw7mHJzH_Ix1I85hLFjyw"\n' +
                    '}');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else {
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('['+
                                 '{"cia":"G","ramo":"07","pol":"283000046","aplicacion":"000000000","dni":"05424436R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1988","sexo":"Mujer","capGarDecesos":"4.500,00","fAltaAsegurado":"01-03-2017","codPostal":"28045","poblacion":"MADRID","provincia":"MADRID","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"G","ramo":"07","pol":"519000092","aplicacion":"000000000","dni":"29110710R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"06-11-1973","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-10-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},' +
                    '{"cia":"G","ramo":"07","pol":"519000095","aplicacion":"000000000","dni":"29110710R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"06-11-1973","sexo":"Mujer","capGarDecesos":"5.000,00","fAltaAsegurado":"01-01-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"G","ramo":"07","pol":"519000082","aplicacion":"000000000","dni":"29110710R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"06-11-1973","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"13-07-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},' +
                    '{"cia":"G","ramo":"07","pol":"519000088","aplicacion":"000000000","dni":"32165487X","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1968","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-07-2015","codPostal":"08908","poblacion":"L\'HOSPITALET DE LLOBREGAT","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"G","ramo":"07","pol":"519000087","aplicacion":"000000000","dni":"32165487X","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1968","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"14-07-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},' +
                    '{"cia":"G","ramo":"07","pol":"519000091","aplicacion":"000000000","dni":"32165487X","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1968","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-09-2015","codPostal":"08908","poblacion":"L\'HOSPITALET DE LLOBREGAT","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"G","ramo":"07","pol":"620000376","aplicacion":"000000000","dni":"40998666Q","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-05-1980","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-06-2015","codPostal":"08013","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false}'+
                ']');
            }
            return response;
        }

    }

    @TestVisible
    private class ConsultaDePolizaGeneratorCajamar implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('loginUserService')) {
                response.setBody('{\n' +
                    '    "codeError": "' + ONE_CommonConstants.HTPP_SUCCESS_CODE + '",\n' +
                    '    "sesion": "A4yrlp-5D9xddkWs3Pf4Zw7mHJzH_Ix1I85hLFjyw"\n' +
                    '}');
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else {
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
                response.setBody('['+
                                 '{"cia":"C","ramo":"07","pol":"283000046","aplicacion":"000000000","dni":"05424436R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1988","sexo":"Mujer","capGarDecesos":"4.500,00","fAltaAsegurado":"01-03-2017","codPostal":"28045","poblacion":"MADRID","provincia":"MADRID","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"C","ramo":"07","pol":"519000092","aplicacion":"000000000","dni":"29110710R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"06-11-1973","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-10-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},' +
                    '{"cia":"C","ramo":"07","pol":"519000095","aplicacion":"000000000","dni":"29110710R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"06-11-1973","sexo":"Mujer","capGarDecesos":"5.000,00","fAltaAsegurado":"01-01-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"C","ramo":"07","pol":"519000082","aplicacion":"000000000","dni":"29110710R","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"06-11-1973","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"13-07-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},' +
                    '{"cia":"C","ramo":"07","pol":"519000088","aplicacion":"000000000","dni":"32165487X","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1968","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-07-2015","codPostal":"08908","poblacion":"L\'HOSPITALET DE LLOBREGAT","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"C","ramo":"07","pol":"519000087","aplicacion":"000000000","dni":"32165487X","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1968","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"14-07-2015","codPostal":"08009","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},' +
                    '{"cia":"C","ramo":"07","pol":"519000091","aplicacion":"000000000","dni":"32165487X","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-01-1968","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-09-2015","codPostal":"08908","poblacion":"L\'HOSPITALET DE LLOBREGAT","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false},'+
                    '{"cia":"C","ramo":"07","pol":"620000376","aplicacion":"000000000","dni":"40998666Q","apellido1":"MARIA","apellido2":"MARIA","nombre":"MARIA","fNacimiento":"01-05-1980","sexo":"Mujer","capGarDecesos":"4.700,00","fAltaAsegurado":"01-06-2015","codPostal":"08013","poblacion":"BARCELONA","provincia":"BARCELONA","clausulaEsp":null,"indPrimaUnica":"N","wnomco":"","capitalAdicionalDecesos": null,"repatriacion": false}'+
                ']');
            }
            return response;
        }

    }

	@TestVisible
    private class ConsultaDePolizaKutxaGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
           	response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            response.setBody('{"status":200,"resultado":[{"NumPoliza":"0023080252","Mediador":"2095","Situacion":"01","NifAsegurado":"22222222J","Apellido1Asegurado":"ASEGAPELLIDO1","Apellido2Asegurado":"ASEGAPELLIDO2","NombreAsegurado":"ASEGNOMBRE","Sexo":"H","FechaNacimiento":"19450603","Poblacion":"CÓRDOBA","FormaPago": "U","SumAsegurada": "3202.05","FechaEfectoPoliza": "20170620","ServicioContratado": "Inhumación (entierro) o Incineración"}]}');
            return response;
        }

    }
    
   @TestVisible
    private class ConsultaDePolizaKutxaGeneratorErr implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
           	response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            response.setBody('{"status":203,"resultado":{"Message":"Bloqueo por RGPD"}}');
            
            return response;
        }

    }
    
}
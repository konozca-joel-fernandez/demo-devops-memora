@IsTest
private class ONE_OpenLifeClaimIntegrationServiceTest {
    private static final String POLICY_CIA = 'G';
    private static final String POLICY_BRANCH = 'br';
    private static final String POLICY_POLICY = 'policy';
    
    private static String CONTRATO_POL = 'pol';
    private static String COMPANIA_ASEGURADORA = 'G';
    private static final String CONTRATO_RAMO = 'br';
    private static final String CONTRACTO_DIGITO_DE_CONTROL = '2';
    private static String DATA_TIPOLOGY = 'F';
    
    private static final Integer DAY = 1;
    private static final Integer MONTH = 1;
    private static final Integer YEAR = 1999;
    private static final Integer HOUR = 1;
    private static final Integer MINUTE = 1;
    
    private static final String DIRECCION_DE_DEFUNCION = 'direccion de defuncion';
    private static final String PROVINCIA_DE_DEFUNCION = '15';
    private static final String CODIGO_POSTAL_DE_DEFUNCION = 'codigo postal de defuncion';
    private static final String PAIS_DE_DEFUNCION = 'ES';
    
    private static final String NUMERO_DE_DOCUMENTO = 'numero';
    private static final String OBSERVACIONES = 'observaciones';
    private static final String NO_INFORMADO = 'No Informado';
    private static final String CAUSAS_DEFUNCION = 'Natural';
    private static final String NOMBRE_DE_LA_PERSONA_DE_CONTACTO = 'nombre de la person de contacto';
    private static final String RELACION_CON_EL_DIFUNTO = 'Padre';
    
    private static final String CREDENTIAL_NAME = 'GENERALI';
    private static final String CREDENTIAL_COMPANY = 'K';
    private static final String CREDENTIAL_USERNAME = 'username';
    private static final String CREDENTIAL_PASSWORD = 'password';
    
    private static final String FIRST_NAME = 'first';
    private static final String LAST_NAME = 'last';
    
    private static final String LOGIN_BODY = '{\n' +
        '    "codeError": "' + ONE_OpenLifeClaimIntegrationService.CODE_ERROR_SUCCESS + '",\n' +
        '    "sesion": "A4yrlp-5D9xddkWs3Pf4Zw7mHJzH_Ix1I85hLFjyw"\n' +
        '}';
    private static final String SUCCESS_BODY_TEMPLATE = '\'{\'"codeError": "{0}", "claim": \'{\' "cia": "{1}", "branch\": "{2}", "year": "{3}", ' +
        '"policy": "{4}", "controlDigit": "{5}"\'}\'}';
    private static final String SUCCESS_BODY = String.format(SUCCESS_BODY_TEMPLATE, new List<String>{
        ONE_OpenLifeClaimIntegrationService.CODE_ERROR_SUCCESS, COMPANIA_ASEGURADORA, CONTRATO_RAMO,
        String.valueOf(YEAR), CONTRATO_POL, CONTRACTO_DIGITO_DE_CONTROL
    });
    
    private static final String ERROR_BODY = '{\n' +
        '    "codeError": "999",\n' +
        '    "errorMessages": [\n' +
        '        "ERROR.Identificación Póliza: Siniestro ocurrido hace más de 3 meses                                        "\n' +
        '    ]\n' +
        '}';
    
    @TestSetup
    private static void setup() {
        ONE_InsuranceIntegrationCredentials__c cs = new ONE_InsuranceIntegrationCredentials__c(Name = CREDENTIAL_NAME, ONE_Company__c = CREDENTIAL_COMPANY,
            ONE_Username__c = CREDENTIAL_USERNAME, ONE_Password__c = CREDENTIAL_PASSWORD);
        insert cs;
        
        Account acc = new Account(FirstName = FIRST_NAME, LastName = LAST_NAME, RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
            ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        ONE_Contrato__c contrato = new ONE_Contrato__c(ONE_Pol__c = CONTRATO_POL, ONE_Ramo__c = CONTRATO_RAMO, ONE_Compania_Aseguradora__c = COMPANIA_ASEGURADORA);
        DateTime fechaDeDefuncion = DateTime.newInstance(Date.newInstance(YEAR, MONTH, DAY), Time.newInstance(HOUR, MINUTE, 0, 0));
        ONE_Caso__c caso = new ONE_Caso__c(ONE_Difunto__c = acc.Id, ONE_Contrato__c = contrato.Id, ONE_Fecha_De_Defuncion__c = fechaDeDefuncion,
            ONE_Direccion_De_Defuncion__c = DIRECCION_DE_DEFUNCION, ONE_Provincia_De_Defuncion__c = PROVINCIA_DE_DEFUNCION, ONE_Codigo_Postal_De_Defuncion__c = CODIGO_POSTAL_DE_DEFUNCION,
            ONE_Pais_De_Defuncion__c = PAIS_DE_DEFUNCION, ONE_Numero_De_Documento__c = NUMERO_DE_DOCUMENTO, ONE_Observaciones__c = OBSERVACIONES,
            ONE_Causas_Defuncion__c = CAUSAS_DEFUNCION, ONE_Nombre_De_La_Persona_De_Contacto__c = NOMBRE_DE_LA_PERSONA_DE_CONTACTO,
            ONE_Relacion_Con_El_Difunto__c = RELACION_CON_EL_DIFUNTO);
        insert caso;
    }
    
    @IsTest
    private static void invokeIntegrationSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new Mock(true, ONE_CommonConstants.HTPP_SUCCESS_CODE));
        
        ONE_Caso__c caso = [
            SELECT Id
            FROM ONE_Caso__c
            LIMIT 1
        ];
        
        ONE_OpenLifeClaimIntegrationService.FlowInputs input = new ONE_OpenLifeClaimIntegrationService.FlowInputs();
        input.casoId = caso.Id;
        input.service = 'generali';

        List<ONE_OpenLifeClaimIntegrationService.FlowInputs> inputs = new List<ONE_OpenLifeClaimIntegrationService.FlowInputs>{input};
        
        Test.startTest();
        
        List<ONE_OpenLifeClaimIntegrationService.FlowOutputs> outputs = ONE_OpenLifeClaimIntegrationService.invokeIntegration(inputs);
        
        Test.stopTest();
        
        System.assertEquals(1, outputs.size());
        ONE_OpenLifeClaimIntegrationService.FlowOutputs output = outputs.get(0);
        System.assert(output.success);
    }
    
    @IsTest
    private static void invokeIntegrationErrorTest() {
        Test.setMock(HttpCalloutMock.class, new Mock(false, ONE_CommonConstants.HTPP_SUCCESS_CODE));
        
        ONE_Caso__c caso = [
            SELECT Id
            FROM ONE_Caso__c
            LIMIT 1
        ];
        
        ONE_OpenLifeClaimIntegrationService.FlowInputs input = new ONE_OpenLifeClaimIntegrationService.FlowInputs();
        input.casoId = caso.Id;
        input.service = 'generali';

        List<ONE_OpenLifeClaimIntegrationService.FlowInputs> inputs = new List<ONE_OpenLifeClaimIntegrationService.FlowInputs>{input};
        
        Test.startTest();
        
        List<ONE_OpenLifeClaimIntegrationService.FlowOutputs> outputs = ONE_OpenLifeClaimIntegrationService.invokeIntegration(inputs);
        
        Test.stopTest();
        
        System.assertEquals(1, outputs.size());
        ONE_OpenLifeClaimIntegrationService.FlowOutputs output = outputs.get(0);
        System.assert(!output.success);
    }
    
    @IsTest
    private static void invokeIntegrationErrorConnectionTest() {
        Test.setMock(HttpCalloutMock.class, new Mock(false, ONE_CommonConstants.HTPP_SERVER_ERROR_CODE));
    
        ONE_Caso__c caso = [
            SELECT Id
            FROM ONE_Caso__c
            LIMIT 1
        ];
    
        ONE_OpenLifeClaimIntegrationService.FlowInputs input = new ONE_OpenLifeClaimIntegrationService.FlowInputs();
        input.casoId = caso.Id;
        input.service = 'generali';
    
        List<ONE_OpenLifeClaimIntegrationService.FlowInputs> inputs = new List<ONE_OpenLifeClaimIntegrationService.FlowInputs>{input};
    
        Test.startTest();
    
        List<ONE_OpenLifeClaimIntegrationService.FlowOutputs> outputs = ONE_OpenLifeClaimIntegrationService.invokeIntegration(inputs);
    
        Test.stopTest();
    
        System.assertEquals(1, outputs.size());
        ONE_OpenLifeClaimIntegrationService.FlowOutputs output = outputs.get(0);
        System.assert(!output.success);
    }
    
    private class Mock implements HttpCalloutMock {
        String body;
        Integer statusCode;
        
        Mock(Boolean success, Integer statusCode) {
            body = (success) ? SUCCESS_BODY : ERROR_BODY;
            this.statusCode = statusCode;
        }
        
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint.endsWith('loginUserService')) {
                response.setBody(LOGIN_BODY);
                response.setStatusCode(ONE_CommonConstants.HTPP_SUCCESS_CODE);
            } else if (endpoint.endsWith('openLifeClaim')) {
                response.setStatusCode(statusCode);
                response.setBody(body);
            }
            return response;
        }
    }
}
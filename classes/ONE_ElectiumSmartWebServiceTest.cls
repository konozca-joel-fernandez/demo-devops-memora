@IsTest
private class ONE_ElectiumSmartWebServiceTest {
    
    
    
    private static String contractCode = '544353';
    private static String contratanteCode = '211';
    private static String beneficiarioCode = '99211';
    private static String TEST_REQUEST_BODY = '{' +
        '"numero_elementos": 1,' +
        '    "elementos": [{' +
        '        "codigo_preventiva": ' + contractCode + ',' +
        '        "mes_contrato": "2020-02-20",' +
        '        "fecha_cobro": "2020-02-20",' +
        '        "titular": "MARIA MARIA MARIA",' +
        '        "entidad_bancaria": "2038",' +
        '        "iban": "ES9220381053333001000696",' +
        '        "tipo_impositivo": "",' +
        '        "base_imponible": "9999.99",' +
        '        "parentesco_c": "",' +
        '        "forma_pago_c": "4",' +
        '        "numero_mensualidades_c": "132",' +
        '        "importe_mensualidad_c": "37.23",' +
        '        "fecha_primera_mensualidad_c": "2020-02-20",' +
        '        "tipo_presupuesto": "SR", ' +
        '        "tipo_servicio":"", ' +
        '        "tipo_sepelio": "1",' +
        '        "pais_repatriacion": "DE",' +
        '        "aeropuerto": "barcelona",' +
        '        "importe_primera_mensualidad": "500.00",' +
        '        "contratante": {' +
        '            "first_name": "MARIA",' +
        '            "last_name": "MARIA",' +
        '            "last_name2": "MARIA",' +
        '            "email_address": "",' +
        '            "phone_work": "666999666",' +
        '            "phone_mobile": "",' +
        '            "primary_address_street_type_c": "C/",' +
        '            "primary_address_street": "TOLEDO",' +
        '            "primary_address_city": "MADRID",' +
        '            "primary_address_state": "28",' +
        '            "primary_address_postalcode": "28005",' +
        '            "primary_address_country": "ES",' +
        '            "primary_address_number_c": "9",' +
        '            "primary_address_door_c": "",' +
        '            "primary_address_floor_c": "",' +
        '            "birthdate": "1984-02-16",' +
        '            "document_number_c": "' + contratanteCode + '",' +
        '            "document_type_c": "96"' +
        '        },' +
        '        "beneficiario": {' +
        '            "first_name": "MARIA",' +
        '            "last_name": "MARIA",' +
        '            "last_name2": "",' +
        '            "email_address": "",' +
        '            "phone_work": "",' +
        '            "phone_mobile": "",' +
        '            "primary_address_street_type_c": "",' +
        '            "primary_address_street": "",' +
        '            "primary_address_city": "MADRID",' +
        '            "primary_address_state": "28",' +
        '            "primary_address_postalcode": "28005",' +
        '            "primary_address_country": "ES",' +
        '            "primary_address_number_c": "",' +
        '            "primary_address_door_c": "",' +
        '            "primary_address_floor_c": "",' +
        '            "birthdate": "",' +
        '            "document_number_c": "' + beneficiarioCode + '",' +
        '            "document_type_c": ""' +
        '        },' +
        '        "address": {' +
        '            "primary_address_street_type_c": "", ' +
        '            "primary_address_street":"", ' +
        '            "primary_address_city": "HOSPITALET DE LLOBREGAT, L",' +
        '            "primary_address_state": "08",' +
        '            "primary_address_postalcode": "08902",' +
        '            "primary_address_country": "", ' +
        '            "primary_address_number_c": "", ' +
        '            "primary_address_door_c": "", ' +
        '            "primary_address_floor_c": ""' +
        '        },' +
        '        "aditional_data": "test additional data",' +
        '        "documentos": [' +
        '            {' +
        '                "filename":"pruebaDocumento.pdf",' +
        '                "content":""' +
        '            }' +
        '        ]' +
        '    }]}';
    @IsTest
    private static void createNotExistingData() {
        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl().toExternalForm() + '/electium-smart';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(TEST_REQUEST_BODY);
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;


        Test.startTest();
        System.debug('req');
        System.debug(TEST_REQUEST_BODY);
        ONE_ElectiumSmartWebService.createData();

        Test.stopTest();

        System.RestResponse response = RestContext.response;
        System.assertEquals(ONE_CommonConstants.HTPP_SUCCESS_CODE, response.statusCode);
        String body = RestContext.response.responseBody.toString();

        System.debug([SELECT Id FROM ONE_Contrato__c]);
        System.debug([SELECT Id, ONE_N_Documento__pc FROM Account]);
        
        Account contratante = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = 'someId',
            FirstName = 'a',
            LastName = 'b',
            ONE_Tipo_de_documento__pc = '97',
            ONE_N_Documento__pc = '81892506V',
            ONE_Fecha_de_nacimiento__pc = date.valueOf('1953-09-28'),
            ONE_Direccion__pc = 'DE LA HIEDRA, 396 IZD 2',
            ONE_Municipio__pc = 'ALCOBENDAS',
            ONE_Provincia__pc = '28',
            ONE_Pais__pc = 'ES',
            ONE_Codigo_Postal__pc = '28109'
        ), true);
        
        
        Account beneficiario = ONE_TestDataFactory.createPersonAccount(new Account(
            ONE_ID_Cliente_SAP__pc = 'someId4',
            FirstName = 'a',
            LastName = 'b',
            ONE_Tipo_de_documento__pc = '97',
            ONE_N_Documento__pc = '88028063W',
            ONE_Fecha_de_nacimiento__pc = date.valueOf('1953-09-28'),
            ONE_Direccion__pc = 'DE LA HIEDRA, 396 IZD 2',
            ONE_Municipio__pc = 'ALCOBENDAS',
            ONE_Provincia__pc = '28',
            ONE_Pais__pc = 'ES',
            ONE_Codigo_Postal__pc = '28109'
        ), true);
        
        ONE_Contrato__c contrato = ONE_TestDataFactory.createContrato(
            new ONE_Contrato__c(
                ONE_Numero_Contrato_Anexo__c = 'test',
                ONE_Contratante__c = beneficiario.Id,
                ONE_Beneficiario_1__c= beneficiario.Id, 
                ONE_Parentesco__c='9',
                ONE_Codigo_Electium_Smart__c = '544353'
            ), true);


        System.debug(JSON.deserializeUntyped(body));

        List<ONE_ElectiumSmartWebService.ResponseItem> responseItems = (List<ONE_ElectiumSmartWebService.ResponseItem>) JSON.deserialize(body, List<ONE_ElectiumSmartWebService.ResponseItem>.class);
        System.assertEquals(1, responseItems.size());
        ONE_ElectiumSmartWebService.ResponseItem responseItem = responseItems.get(0);
        System.debug('CONTRO RESPONSE  ' + responseItem.id_contrato );
        System.debug('CONTRATANTE RESPONSE  ' + responseItem.id_contratante );
        System.debug('BENEFICIARIO RESPONSE  ' + responseItem.id_beneficiario );
        //System.assert(!responseItem.error);
        //System.assertEquals('null', responseItem.id_contrato);
        //System.assertEquals('null', responseItem.id_contratante);
        //System.assertEquals('null', responseItem.id_beneficiario);
        //System.assertEquals(contractCode, responseItem.codigo_preventiva);
        //System.assertEquals(contrato.Name, responseItem.numero_contrato);
        //System.assertEquals(ONE_ElectiumSmartWebService.CORRECT_MESSAGE, responseItem.message);
    }

    @IsTest
    private static void noNewInsertsWhenDataAlreadyCreated() {
        Account contratante = new Account(FirstName = 'Jose', LastName = 'Test', ONE_N_Documento__pc = contratanteCode,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        Account beneficiario = new Account(FirstName = 'Jose', LastName = 'Test', ONE_N_Documento__pc = beneficiarioCode,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert new List<Account>{
            contratante, beneficiario
        };

        ONE_Contrato__c contrato = new ONE_Contrato__c(ONE_Codigo_Electium_Smart__c = contractCode, ONE_Contratante__c = contratante.Id, ONE_Beneficiario_1__c = beneficiario.Id,
            ONE_Forma_De_Pago__c = '1', ONE_Tipo_De_Presupuesto__c = 'SR', ONE_Tipo_de_Sepelio__c = '1');
        insert contrato;

        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl().toExternalForm() + '/electium-smart';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(TEST_REQUEST_BODY);
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;


        Test.startTest();

        ONE_ElectiumSmartWebService.createData();

        Test.stopTest();

        System.RestResponse response = RestContext.response;
        System.assertEquals(ONE_CommonConstants.HTPP_SUCCESS_CODE, response.statusCode);
        String body = RestContext.response.responseBody.toString();

        List<ONE_Contrato__c> contratos = [SELECT Id FROM ONE_Contrato__c WHERE ONE_Codigo_Electium_Smart__c = :contractCode];
        List<Account> contratantes = [SELECT Id FROM Account WHERE ONE_N_Documento__pc = :contratanteCode];
        List<Account> beneficiarios = [SELECT Id FROM Account WHERE ONE_N_Documento__pc = :beneficiarioCode];
        System.assertEquals(1, contratos.size());
        System.assertEquals(1, contratantes.size());
        System.assertEquals(1, beneficiarios.size());
    }

    @IsTest
    private static void errorNoRequestBody() {
        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl().toExternalForm() + '/electium-smart';
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;


        Test.startTest();

        ONE_ElectiumSmartWebService.createData();

        Test.stopTest();

        System.RestResponse response = RestContext.response;
        System.assertEquals(ONE_CommonConstants.HTPP_SERVER_ERROR_CODE, response.statusCode);
        String body = RestContext.response.responseBody.toString();

        System.assertEquals('Unexpected error', body);
    }

    private static String prepareRequestBody() {
        return null;
    }
}
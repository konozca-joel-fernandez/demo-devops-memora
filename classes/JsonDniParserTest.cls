@IsTest
private class JsonDniParserTest {

    @IsTest
    static void parse_validCompletePayload() {

        String payload = '{"NOMBRE":"Juan","PRIMER_APELLIDO":"Pérez","SEGUNDO_APELLIDO":"García","FECHA_DE_NACIMIENTO":"15/08/1990","NUMERO_DOCUMENTO":"12345678A"}';
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = payload;
        req.tipoDoc = 'DNI Difunto';

        List<JsonDniParser.Response> results = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });

        System.assertEquals(1, results.size(), 'Debe devolver un único resultado');
        JsonDniParser.Response res = results[0];
        System.assertEquals('Juan', res.nombre, 'Nombre debe parsearse');
        System.assertEquals('Pérez García', res.apellidos, 'Apellidos deben parsearse');
        System.assertEquals(Date.newInstance(1990, 8, 15), res.fechaDeNacimiento, 'Fecha debe parsearse DD/MM/YYYY');
        System.assertEquals('12345678A', res.numeroDocumento, 'Número de documento debe parsearse');
    }

    @IsTest
    static void parse_blankAndNullValuesBecomeDefaultOrNull() {

        String payload = '{"NOMBRE":"  ","PRIMER_APELLIDO":"","SEGUNDO_APELLIDO":"   ","FECHA_DE_NACIMIENTO":"   ","NUMERO_DOCUMENTO":""}';
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = payload;
        req.tipoDoc = 'DNI Difunto';

        List<JsonDniParser.Response> results = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });

        System.assertEquals(1, results.size());
        JsonDniParser.Response res = results[0];
        System.assertEquals('', res.nombre, 'Nombre vacío - default');
        System.assertEquals('', res.apellidos, 'Primer y segudno apellido vacío - default');
        System.assertEquals(null, res.fechaDeNacimiento, 'Fecha vacía - null');
        System.assertEquals('', res.numeroDocumento, 'Documento vacío - default');
    }

    @IsTest
    static void parse_nullPayloadReturnsDefaults() {
       
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = null;
        req.tipoDoc = 'DNI Difunto';

        List<JsonDniParser.Response> results = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });

        System.assertEquals(1, results.size());
        JsonDniParser.Response res = results[0];
        System.assertEquals('', res.nombre);
        System.assertEquals('', res.apellidos);
        System.assertEquals(null, res.fechaDeNacimiento);
        System.assertEquals('', res.numeroDocumento);
    }

    @IsTest
    static void parse_blankPayloadReturnsDefaults() {
  
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = '   ';
        req.tipoDoc = 'DNI Difunto';

        List<JsonDniParser.Response> results = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });

        System.assertEquals(1, results.size());
        JsonDniParser.Response res = results[0];
        System.assertEquals('', res.nombre);
        System.assertEquals('', res.apellidos);
        System.assertEquals(null, res.fechaDeNacimiento);
        System.assertEquals('', res.numeroDocumento);
    }

    @IsTest
    static void parse_invalidJson_isSafelyCaughtAndDefaultsRemain() {
        
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = '{invalid json';
        req.tipoDoc = 'DNI Difunto';

        List<JsonDniParser.Response> results = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });

        System.assertEquals(1, results.size());
        JsonDniParser.Response res = results[0];
        System.assertEquals('', res.nombre);
        System.assertEquals('', res.apellidos);
        System.assertEquals(null, res.fechaDeNacimiento);
        System.assertEquals('', res.numeroDocumento);
    }

    @IsTest
    static void parse_invalidDateFormatReturnsNull() {

        String payload = '{"NOMBRE":"Ana","PRIMER_APELLIDO":"López","SEGUNDO_APELLIDO":"Ruiz","FECHA_DE_NACIMIENTO":"1990-08-15","NUMERO_DOCUMENTO":"87654321B"}';
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = payload;
        req.tipoDoc = 'DNI Difunto';

        List<JsonDniParser.Response> results = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });

        System.assertEquals(1, results.size());
        JsonDniParser.Response res = results[0];
        System.assertEquals('Ana', res.nombre);
        System.assertEquals('López Ruiz', res.apellidos);
        System.assertEquals(null, res.fechaDeNacimiento, 'Fecha inválida debe ser null');
        System.assertEquals('87654321B', res.numeroDocumento);
    }
    @IsTest
    static void parse_withServicioId_executesLogging() {

        // Crear difunto (Account)
        Account dif = new Account(
            FirstName = 'Juan',
            LastName = 'Perez',
            ONE_Fecha_de_nacimiento__pc = Date.newInstance(1950,1,1),
            ONE_Lugar_de_nacimiento__pc = 'Barcelona',
            ONE_N_Documento__pc = '12345678A',
            ONE_Sexo__c = 'Hombre',
            ONE_Nacionalidad__c = 'ES',
            ONE_Direccion__pc = 'Calle 1',
            ONE_Municipio__pc = 'Barcelona',
            ONE_Provincia__pc = '08',
            ONE_Pais__pc = 'ES'
        );
        insert dif;

        // Crear expediente
        ONE_Expediente__c exp = new ONE_Expediente__c(
            ONE_Difunto__c = dif.Id
        );
        insert exp;

        // JSON 
        String payload = JSON.serialize(new Map<String,Object>{
            'NOMBRE' => 'Juan',
            'PRIMER_APELLIDO' => 'Perez',
            'SEGUNDO_APELLIDO' => 'Lopez',
            'FECHA_DE_NACIMIENTO' => '01/01/1950',
            'NUMERO_DOCUMENTO' => '12345678A',
            'SEXO' => 'H',
            'NACIONALIDAD' => 'España',
            'LUGAR_NACIMIENTO' => 'Barcelona',
            'PROVINCIA_NACIMIENTO' => 'Barcelona',
            'DOMICILIO' => 'Calle 1',
            'MUNICIPIO' => 'Barcelona',
            'PROVINCIA' => 'Barcelona',
            'PAIS' => 'España',
            'NOMBREPADRE' => 'Jose',
            'NOMBREMADRE' => 'Maria'
        });

        // Request con servicioId
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = payload;
        req.difuntoServicio = exp.Id;
        req.tipoDoc = 'DNI Difunto';

        // Ejecutar
        Test.startTest();
        List<JsonDniParser.Response> out = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });
        Test.stopTest();

        // Validar
        System.assertEquals(1, out.size());
        System.assertEquals('Juan', out[0].nombre);
        System.assertEquals('Perez Lopez', out[0].apellidos);
    }

    @IsTest
    static void parse_withServicioId_executesLogging_declarante() {

        // Crear difunto (Account)
        Account dif = new Account(
            FirstName = 'Juan',
            LastName = 'Perez',
            ONE_Fecha_de_nacimiento__pc = Date.newInstance(1950,1,1),
            ONE_Lugar_de_nacimiento__pc = 'Barcelona',
            ONE_N_Documento__pc = '12345678A',
            ONE_Sexo__c = 'Hombre',
            ONE_Nacionalidad__c = 'ES',
            ONE_Direccion__pc = 'Calle 1',
            ONE_Municipio__pc = 'Barcelona',
            ONE_Provincia__pc = '08',
            ONE_Pais__pc = 'ES'
        );
        insert dif;

        // Crear expediente
        ONE_Expediente__c exp = new ONE_Expediente__c(
            ONE_Difunto__c = dif.Id
        );
        insert exp;

        // JSON 
        String payload = JSON.serialize(new Map<String,Object>{
            'NOMBRE' => 'Juan',
            'PRIMER_APELLIDO' => 'Perez',
            'SEGUNDO_APELLIDO' => 'Lopez',
            'FECHA_DE_NACIMIENTO' => '01/01/1950',
            'NUMERO_DOCUMENTO' => '12345678A',
            'SEXO' => 'H',
            'NACIONALIDAD' => 'España',
            'LUGAR_NACIMIENTO' => 'Barcelona',
            'PROVINCIA_NACIMIENTO' => 'Barcelona',
            'DOMICILIO' => 'Calle 1',
            'MUNICIPIO' => 'Barcelona',
            'PROVINCIA' => 'Barcelona',
            'PAIS' => 'España',
            'NOMBREPADRE' => 'Jose',
            'NOMBREMADRE' => 'Maria'
        });

        // Request con servicioId
        JsonDniParser.Request req = new JsonDniParser.Request();
        req.jsonPayload = payload;
        req.difuntoServicio = exp.Id;
        req.tipoDoc = 'DNI Declarante';

        // Ejecutar
        Test.startTest();
        List<JsonDniParser.Response> out = JsonDniParser.parse(new List<JsonDniParser.Request>{ req });
        Test.stopTest();

        // Validar
        System.assertEquals(1, out.size());
        System.assertEquals('Juan', out[0].nombre);
        System.assertEquals('Perez Lopez', out[0].apellidos);
    }


   
}
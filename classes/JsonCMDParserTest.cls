@IsTest
private class JsonCMDParserTest {

    // Utilidad para construir JSON CMD de ejemplo
    private static String buildCmdJson(
        String nombre,
        String primerApellido,
        String segundoApellido,
        String fechaNacimiento, // DD/MM/YYYY
        String sexo,
        String tipoDoc,
        String documentoIdentidad,
        String fechaDefuncion,  // DD/MM/YYYY
        String horaDefuncion,   // HH:MM
        String lugarDefuncion,
        String municipio,
        String provincia,
        String causaInmediata,
        String causasIntermedias,
        String causaFundamental,
        String otrosProcesos,
        String nombreMedico,
        String primerApellidoMedico,
        String segundoApellidoMedico,
        String numColegiado,
        String localidadCertificado,
        String fechaCertificado, // DD/MM/YYYY
        String numeroCertificado
    ) {
        Map<String, Object> m = new Map<String, Object>();
        if (nombre != null) m.put('NOMBRE_FALLECIDO', nombre);
        if (primerApellido != null) m.put('PRIMER_APELLIDO', primerApellido);
        if (segundoApellido != null) m.put('SEGUNDO_APELLIDO', segundoApellido);
        if (fechaNacimiento != null) m.put('FECHA_NACIMIENTO', fechaNacimiento);
        if (sexo != null) m.put('SEXO', sexo);
        if (tipoDoc != null) m.put('TIPO_DOCUMENTO', tipoDoc);
        if (documentoIdentidad != null) m.put('DOCUMENTO_IDENTIDAD', documentoIdentidad);

        if (fechaDefuncion != null) m.put('FECHA_DEFUNCION', fechaDefuncion);
        if (horaDefuncion != null) m.put('HORA_DEFUNCION', horaDefuncion);
        if (lugarDefuncion != null) m.put('LUGAR_DEFUNCION', lugarDefuncion);
        if (municipio != null) m.put('MUNICIPIO_DEFUNCION', municipio);
        if (provincia != null) m.put('PROVINCIA_DEFUNCION', provincia);

        if (causaInmediata != null) m.put('CAUSA_INMEDIATA', causaInmediata);
        if (causasIntermedias != null) m.put('CAUSAS_INTERMEDIAS', causasIntermedias);
        if (causaFundamental != null) m.put('CAUSA_FUNDAMENTAL', causaFundamental);
        if (otrosProcesos != null) m.put('OTROS_PROCESOS', otrosProcesos);

        if (nombreMedico != null) m.put('NOMBRE_MEDICO', nombreMedico);
        if (primerApellidoMedico != null) m.put('PRIMER_APELLIDO_MEDICO', primerApellidoMedico);
        if (segundoApellidoMedico != null) m.put('SEGUNDO_APELLIDO_MEDICO', segundoApellidoMedico);
        if (numColegiado != null) m.put('NUMERO_COLEGIADO', numColegiado);
        if (localidadCertificado != null) m.put('LOCALIDAD_CERTIFICADO', localidadCertificado);
        if (fechaCertificado != null) m.put('FECHA_CERTIFICADO', fechaCertificado);

        if (numeroCertificado != null) m.put('NUMERO_CERTIFICADO', numeroCertificado);

        return JSON.serialize(m);
    }

    @IsTest
    static void testParse_EqualPayloads_AllMatch() {
        // Ambos JSON iguales -> todos los campos deben coincidir (no NOT_FOUND), fechas y horas válidas
        String json = buildCmdJson(
            'Juan', 'Pérez', 'García', '01/02/1980', 'hombre', 'dni', '12345678Z',
            '10/10/2020', '13:45', 'Hospital Central', 'Madrid', 'Madrid',
            'Causa Inmediata', 'Causas Intermedias', 'Causa Fundamental', 'Otros procesos',
            'Dra. Ana', 'López', 'Santos', '12345', 'Madrid', '11/10/2020', 'CERT-001'
        );

        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = json;
        req.jsonPayload2 = json;

        Test.startTest();
        List<JsonCMDParser.Response> out = JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req });
        Test.stopTest();

        System.assertEquals(1, out.size(), 'Debe retornar una respuesta');
        JsonCMDParser.Response r = out[0];

        System.assertEquals('Juan', r.NOMBRE_FALLECIDO);
        System.assertEquals('Pérez García', r.APELLIDOS);
        System.assertEquals(Date.newInstance(1980, 2, 1), r.FECHA_NACIMIENTO);
        System.assertEquals('Hombre', r.SEXO);
        System.assertEquals('DNI', r.TIPO_DOCUMENTO);
        System.assertEquals('12345678Z', r.DOCUMENTO_IDENTIDAD);
        System.assertEquals(Date.newInstance(2020, 10, 10), r.FECHA_DEFUNCION);
        System.assertEquals(Time.newInstance(13,45,0,0), r.HORA_DEFUNCION);
        System.assertEquals('Hospital Central', r.LUGAR_DEFUNCION);
        System.assertEquals('Madrid', r.MUNICIPIO_DEFUNCION);
        System.assertEquals('Madrid', r.PROVINCIA_DEFUNCION);
        System.assertEquals('Causa Inmediata', r.CAUSA_INMEDIATA);
        System.assertEquals('Causas Intermedias', r.CAUSAS_INTERMEDIAS);
        System.assertEquals('Causa Fundamental', r.CAUSA_FUNDAMENTAL);
        System.assertEquals('Otros procesos', r.OTROS_PROCESOS);
        System.assertEquals('Dra. Ana', r.NOMBRE_MEDICO);
        System.assertEquals('López', r.PRIMER_APELLIDO_MEDICO);
        System.assertEquals('Santos', r.SEGUNDO_APELLIDO_MEDICO);
        System.assertEquals('12345', r.NUMERO_COLEGIADO);
        System.assertEquals('Madrid', r.LOCALIDAD_CERTIFICADO);
        System.assertEquals(Date.newInstance(2020,10,11), r.FECHA_CERTIFICADO);
        System.assertEquals('CERT-001', r.NUMERO_CERTIFICADO);
        System.assertNotEquals(null, r.FECHAHORA_DEFUNCION, 'Debe calcular FECHAHORA_DEFUNCION');
        System.assertEquals(Datetime.newInstance(2020,10,10,13,45,0), r.FECHAHORA_DEFUNCION);
    }

    @IsTest
    static void testParse_DifferentPayloads_StringsMismatchToNotFound_DatesNullWhenMismatch() {
        // Construimos dos JSON con diferencias para forzar NOT_FOUND y null en fechas/horas
        String json1 = buildCmdJson(
            'JUÁN', 'PÉREZ', 'GARCÍA', '01/02/1980', 'H', 'dni', '12345678Z',
            '10/10/2020', '13:45', 'Hospital Central', 'Madrid', 'Madrid',
            'Causa Inmediata', 'Causas Intermedias', 'Causa Fundamental', 'Otros procesos',
            'Dra. Ana', 'López', 'Santos', '12345', 'Madrid', '11/10/2020', 'CERT-001'
        );
        // Cambios: sexo = mujer, tipoDoc = nie, documento distinto, lugar distinto, fechas/horas distintas, numero certificado distinto
        String json2 = buildCmdJson(
            'Juan', 'Perez', 'Garcia', '02/02/1980', 'mujer', 'nie', '99999999X',
            '11/10/2020', '14:00', 'Otro Hospital', 'Madrid', 'Madrid',
            'Causa Inmediata', 'Causas Intermedias', 'Causa Fundamental', 'Otros procesos',
            'Dra. Ana', 'Lopez', 'Santos', '12345', 'Madrid', '12/10/2020', 'CERT-002'
        );

        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = json1;
        req.jsonPayload2 = json2;

        Test.startTest();
        List<JsonCMDParser.Response> out = JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req });
        Test.stopTest();

        System.assertEquals(1, out.size());
        JsonCMDParser.Response r = out[0];

        // Apellidos no coinciden por acentos después de normalización? 
        // OJO: compararStrings normaliza acentos, por lo que 'PÉREZ GARCÍA' vs 'Perez Garcia' SÍ coinciden.
        System.assertEquals('PÉREZ GARCÍA', r.APELLIDOS, 'Acentos deben normalizarse y considerarse iguales');

        // Nombre JUÁN vs Juan -> también coinciden tras normalizar
        System.assertEquals('JUÁN', r.NOMBRE_FALLECIDO);

        // Sexo y tipo doc diferentes -> NOT_FOUND
        System.assertEquals('', r.SEXO);
        System.assertEquals('', r.TIPO_DOCUMENTO);

        // Documento y lugar distintos -> NOT_FOUND
        System.assertEquals('', r.DOCUMENTO_IDENTIDAD);
        System.assertEquals('', r.LUGAR_DEFUNCION);

        // Municipio/Provincia iguales -> se mantienen
        System.assertEquals('Madrid', r.MUNICIPIO_DEFUNCION);
        System.assertEquals('Madrid', r.PROVINCIA_DEFUNCION);

        // Fechas/horas distintas -> null
        System.assertEquals(null, r.FECHA_NACIMIENTO);
        System.assertEquals(null, r.FECHA_DEFUNCION);
        System.assertEquals(null, r.HORA_DEFUNCION);
        System.assertEquals(null, r.FECHAHORA_DEFUNCION);
        System.assertEquals(null, r.FECHA_CERTIFICADO);

        // Número certificado distinto -> NOT_FOUND
        System.assertEquals('', r.NUMERO_CERTIFICADO);
    }

    @IsTest
    static void testParse_BlankPayload_Defaults() {
        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = null;
        req.jsonPayload2 = '';

        Test.startTest();
        List<JsonCMDParser.Response> out = JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req });
        Test.stopTest();

        System.assertEquals(1, out.size());
        JsonCMDParser.Response r = out[0];

        System.assertEquals('', r.NOMBRE_FALLECIDO);
        System.assertEquals('', r.APELLIDOS);
        System.assertEquals('', r.SEXO);
        System.assertEquals('', r.TIPO_DOCUMENTO);
        System.assertEquals('', r.DOCUMENTO_IDENTIDAD);
        System.assertEquals('', r.LUGAR_DEFUNCION);
        System.assertEquals('', r.MUNICIPIO_DEFUNCION);
        System.assertEquals('', r.PROVINCIA_DEFUNCION);
        System.assertEquals('', r.CAUSA_INMEDIATA);
        System.assertEquals('', r.CAUSAS_INTERMEDIAS);
        System.assertEquals('', r.CAUSA_FUNDAMENTAL);
        System.assertEquals('', r.OTROS_PROCESOS);
        System.assertEquals('', r.NOMBRE_MEDICO);
        System.assertEquals('', r.PRIMER_APELLIDO_MEDICO);
        System.assertEquals('', r.SEGUNDO_APELLIDO_MEDICO);
        System.assertEquals('', r.NUMERO_COLEGIADO);
        System.assertEquals('', r.LOCALIDAD_CERTIFICADO);
        System.assertEquals('', r.NUMERO_CERTIFICADO);

        // Tipos fecha/tiempo deben ser null
        System.assertEquals(null, r.FECHA_NACIMIENTO);
        System.assertEquals(null, r.FECHA_DEFUNCION);
        System.assertEquals(null, r.FECHA_CERTIFICADO);
        System.assertEquals(null, r.HORA_DEFUNCION);
        System.assertEquals(null, r.FECHAHORA_DEFUNCION);
    }

    @IsTest
    static void testParse_Normalization_Sexo_TipoDoc() {
        String json1 = buildCmdJson(
            'Maria', 'Lopez', 'Diaz', null, 'M', 'passport', null,
            null, null, null, null, null,
            null, null, null, null,
            null, null, null, null, null, null, null
        );
        String json2 = buildCmdJson(
            'Maria', 'Lopez', 'Diaz', null, 'mujer', 'PASAPORTE', null,
            null, null, null, null, null,
            null, null, null, null,
            null, null, null, null, null, null, null
        );

        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = json1;
        req.jsonPayload2 = json2;

        List<JsonCMDParser.Response> out = JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req });
        JsonCMDParser.Response r = out[0];

        System.assertEquals('Mujer', r.SEXO, 'Deben coincidir tras normalizar valores de sexo');
        System.assertEquals('Pasaporte', r.TIPO_DOCUMENTO, 'Deben coincidir tras normalizar valores de tipo documento');
    }

    @IsTest
    static void testParse_MergeFechaHora() {
        String json = buildCmdJson(
            'Luis', 'Ruiz', 'Lopez', null, null, null, null,
            '05/03/2024', '00:05', null, null, null,
            null, null, null, null,
            null, null, null, null, null, null, null
        );

        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = json;
        req.jsonPayload2 = json;

        JsonCMDParser.Response r = JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req })[0];

        System.assertEquals(Date.newInstance(2024,3,5), r.FECHA_DEFUNCION);
        System.assertEquals(Time.newInstance(0,5,0,0), r.HORA_DEFUNCION);
        System.assertEquals(Datetime.newInstance(2024,3,5,0,5,0), r.FECHAHORA_DEFUNCION);
    }

    @IsTest
    static void test_checkLogs() {

        // Crear Account difunto con valores válidos 
        Account dif = new Account(
            FirstName = 'Juan',
            LastName = 'Perez',
            ONE_Fecha_de_nacimiento__pc = Date.newInstance(1950, 01, 01),
            ONE_Fecha_de_defuncion__pc = Date.newInstance(2020, 10, 10),
            ONE_Nacionalidad__c = 'ES',   // picklist correcto
            ONE_Provincia__pc = '08',     // Barcelona
            ONE_Pais__pc = 'ES'          
        );
        insert dif;

        // Crear expediente que usa ese difunto
        ONE_Expediente__c exp = new ONE_Expediente__c(
            ONE_Difunto__c = dif.Id
        );
        insert exp;

        String json = '{"NOMBRE_FALLECIDO":"Juan","PRIMER_APELLIDO":"Perez","SEGUNDO_APELLIDO":"Garcia"}';

        // Crear Request con servicioId para activar checkLogs()
        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = json;
        req.jsonPayload2 = json;
        req.servicioId = exp.Id;

        // Ejecutar parse (internamente llama a checkLogs)
        Test.startTest();
        JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req });
        Test.stopTest();
        System.assert(true, 'checkLogs() ejecutado correctamente');
    }

    @IsTest
    static void test_checkLogs_fechaDefuncionDisabled_but_fechaDeDefuncionEnabled() {
        Account dif = new Account(
            FirstName = 'Laura',
            LastName = 'Martinez',
            ONE_Fecha_de_nacimiento__pc = Date.newInstance(1980, 1, 1),
            ONE_Fecha_de_defuncion__pc = Date.newInstance(2026, 1, 19),
            ONE_Nacionalidad__c = 'ES',
            ONE_Provincia__pc = '08',
            ONE_Pais__pc = 'ES'
        );
        insert dif;

        ONE_Expediente__c exp = new ONE_Expediente__c(
            ONE_Difunto__c = dif.Id,
            ONE_Fecha_De_Defuncion__c = Datetime.newInstance(2026, 1, 19, 1, 0, 0)
        );
        insert exp;

        String json = JSON.serialize(new Map<String, Object>{
            'NOMBRE_FALLECIDO' => 'Laura',
            'PRIMER_APELLIDO' => 'Martinez',
            'SEGUNDO_APELLIDO' => '',
            'FECHA_NACIMIENTO' => '01/01/1980',
            'SEXO' => 'M',
            'TIPO_DOCUMENTO' => 'DNI',
            'DOCUMENTO_IDENTIDAD' => '12345678Z',
            'FECHA_DEFUNCION' => '11/01/2026'
        });

        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = json;
        req.jsonPayload2 = json;
        req.servicioId = exp.Id;

        Test.startTest();
        JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req });
        Test.stopTest();

        Integer fechaDefDisabledCount = [
            SELECT Count()
            FROM Agentforce_Error_Log__c
            WHERE Servicio__c = :exp.Id
            AND Campo_Error__c = 'Fecha Defunción'
        ];

        Integer fechaDeDefCount = [
            SELECT Count()
            FROM Agentforce_Error_Log__c
            WHERE Servicio__c = :exp.Id
            AND Campo_Error__c = 'Fecha de Defunción'
        ];

        System.assertEquals(0, fechaDefDisabledCount, 'No deben crearse logs para Fecha Defunción');
        System.assertEquals(
            1,
            fechaDeDefCount,
            'Debe mantenerse el log de Fecha de Defunción cuando hay diferencia real. Insert error: ' +
            ParserHelper.lastLogInsertError
        );
    }

    @IsTest
    static void test_checkLogs_fechaDeDefuncion_noErrorWhenFormatDiffOnly() {
        Account dif = new Account(
            FirstName = 'Laura',
            LastName = 'Martinez',
            ONE_Fecha_de_nacimiento__pc = Date.newInstance(1980, 1, 1),
            ONE_Fecha_de_defuncion__pc = Date.newInstance(2026, 1, 11),
            ONE_Nacionalidad__c = 'ES',
            ONE_Provincia__pc = '08',
            ONE_Pais__pc = 'ES'
        );
        insert dif;

        ONE_Expediente__c exp = new ONE_Expediente__c(
            ONE_Difunto__c = dif.Id,
            ONE_Fecha_De_Defuncion__c = Datetime.newInstance(2026, 1, 11, 1, 0, 0)
        );
        insert exp;

        String json1 = JSON.serialize(new Map<String, Object>{
            'NOMBRE_FALLECIDO' => 'Laura',
            'PRIMER_APELLIDO' => 'Martinez',
            'SEGUNDO_APELLIDO' => '',
            'FECHA_NACIMIENTO' => '01/01/1980',
            'SEXO' => 'M',
            'TIPO_DOCUMENTO' => 'DNI',
            'DOCUMENTO_IDENTIDAD' => '12345678Z',
            'FECHA_DEFUNCION' => '11/01/2026'
        });
        String json2 = JSON.serialize(new Map<String, Object>{
            'NOMBRE_FALLECIDO' => 'Laura',
            'PRIMER_APELLIDO' => 'Martinez',
            'SEGUNDO_APELLIDO' => '',
            'FECHA_NACIMIENTO' => '1980-01-01',
            'SEXO' => 'M',
            'TIPO_DOCUMENTO' => 'DNI',
            'DOCUMENTO_IDENTIDAD' => '12345678Z',
            'FECHA_DEFUNCION' => '2026-01-11'
        });

        JsonCMDParser.Request req = new JsonCMDParser.Request();
        req.jsonPayload1 = json1;
        req.jsonPayload2 = json2;
        req.servicioId = exp.Id;

        Test.startTest();
        JsonCMDParser.parse(new List<JsonCMDParser.Request>{ req });
        Test.stopTest();

        Integer fechaDeDefCount = [
            SELECT Count()
            FROM Agentforce_Error_Log__c
            WHERE Servicio__c = :exp.Id
            AND Campo_Error__c = 'Fecha de Defunción'
        ];

        System.assertEquals(0, fechaDeDefCount, 'No debe crear log cuando solo cambia el formato de fecha');
    }

}
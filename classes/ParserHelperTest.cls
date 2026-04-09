@IsTest
private class ParserHelperTest {

    @IsTest
    static void domicilioCsvCases_doNotLogErrorExceptNotFound() {
        List<List<String>> shouldNotLog = new List<List<String>>{
            new List<String>{'PSEO PROLONGACION DEL MURO 2 2C', 'PROLONGACION PASEO DEL MURO, 2-2º C'},
            new List<String>{'C. MURO PROLONGACION 2 P02C', 'Paseo Paseo Del Muro 2  2 C'},
            new List<String>{'C. EJEA DE LOS CABALLEROS 1', 'C/ EJEA DE LOS CABALLEROS'},
            new List<String>{'C. MENDEZ NUÑEZ 24', 'CALLE MENDEZ NUÑEZ, 24'},
            new List<String>{'C. VILLA SAX 1', '1 Calle Villa de Sax'},
            new List<String>{'C. PLAZA 2', 'C/ PLAZA N. 2'},
            new List<String>{'C. LA IGLESIA 14', 'Calle la Iglesia nº 14'},
            new List<String>{'C. RIGUEL 5', 'CALLE RIGAL, 5'},
            new List<String>{'C. RIGUEL 5', 'CALLE RIGEL, 5'},
            new List<String>{'C COMANDANTE RIVERANOS 1', 'CALLE COMANDANTE RIVERANOS, 1'},
            new List<String>{'C. RAMON Y CAJAL 32', '32 Calle Ramón y Cajal'},
            new List<String>{'C. SEVERO OCHOA 5 PO4 D', 'CALLE SEVERO OCHOA, 5-4º DERECHA'},
            new List<String>{'PSEO. CONSTITUCION-EL BAYO 24', 'Paseo de la Constitución'},
            new List<String>{'C. ROCASOLANO 9 2A', 'C/ ROCASOLANO 9 2 A'},
            new List<String>{'C. CIUDADANO KANE 27 P03 A', 'Calle Ciudadano Kane, 27  3º A'},
            new List<String>{'C. LA IGLESIA 11', 'LA IGLESIA 11'},
            new List<String>{'C. PILAR LORENGAR 4', 'C/ PILAR LORENGAR 4'},
            new List<String>{'C. JOTA (LA) 0006', 'LA JOTA 6'},
            new List<String>{'C. CASTILLO 35', 'C/ CASTILLO, Nº 35'},
            new List<String>{'CRTA. AUTOVIA LOGROÑO (CASETAS) 0069 P02 A', 'AUTIVIA DE LOGROÑO,69'},
            new List<String>{'C. CASTILLO 14 CASETAS', 'C. CASTILLO 14'},
            new List<String>{'C. 28 DE FEBRERO 92', 'AVENIDA 28 FEBRERO Nº92'},
            new List<String>{'AVDA. JUAN CARLOS I 21 P01 0001', 'AVDA. JUAN CARLOS I 21 P01'},
            new List<String>{'URBN. PARQUE ROMA F10 P04 C', 'URBANIZACIÓN PARQUE ROMA BLOQUE F10 4ºC'}
        };

        for (List<String> pair : shouldNotLog) {
            String prompt = pair[0];
            String sfValue = pair[1];
            String parsed = ParserHelper.normalize(prompt, '');

            System.assertEquals(
                false,
                ParserHelper.handleFieldLogging(null, 'Domicilio', prompt, parsed, sfValue, 'DNI'),
                'No debería loguear error para: ' + prompt + ' <-> ' + sfValue
            );
        }

        List<List<String>> shouldLog = new List<List<String>>{
            new List<String>{'C. ALEJANDRO OLIVAN 16 P03 X', 'Calle de Fray Luis de León, 7  esc. 1  3º C'},
            new List<String>{'C. VIRGEN DEL PUY A 9', 'C/ROSARIO 10'}
        };
        for (List<String> pair : shouldLog) {
            String prompt = pair[0];
            String sfValue = pair[1];
            String parsed = ParserHelper.normalize(prompt, '');

            System.assertEquals(
                true,
                ParserHelper.handleFieldLogging(null, 'Domicilio', prompt, parsed, sfValue, 'DNI'),
                'Sí debería loguear error para domicilios distintos: ' + prompt + ' <-> ' + sfValue
            );
        }
        
        // Único caso que debe seguir reportando error.
        System.assertEquals(
            true,
            ParserHelper.handleFieldLogging(
                null,
                'Domicilio',
                'Valor no encontrado',
                ParserHelper.normalize('Valor no encontrado', ''),
                'CALLE MAYOR 1',
                'DNI'
            ),
            'Si el prompt devuelve "Valor no encontrado", debe loguear error'
        );
    }

    @IsTest
    static void nonDomicilio_normalizedComparisonAgainstSfValue() {
        System.assertEquals(
            true,
            ParserHelper.handleFieldLogging(null, 'Municipio', 'Madrid', 'Madrid', 'Barcelona', 'DNI'),
            'Para campos no Domicilio debe seguir detectando valores realmente distintos'
        );
        System.assertEquals(
            false,
            ParserHelper.handleFieldLogging(null, 'Municipio', 'Málaga', 'MA-LA GA!!', 'MALAGA', 'DNI'),
            'Para campos no Domicilio debe ignorar acentos y caracteres especiales al comparar'
        );
    }

    @IsTest
    static void normalizationHelpers_coverCoreBranches() {
        System.assertEquals('NF', ParserHelper.normalize(null, 'NF'));
        System.assertEquals('NF', ParserHelper.normalize('Valor no encontrado', 'NF'));
        System.assertEquals('abc', ParserHelper.normalize('  abc  ', 'NF'));
        System.assertEquals('NF', ParserHelper.normalize('   ', 'NF'));

        System.assertEquals('Hombre', ParserHelper.normalizeSexo('H', 'NF'));
        System.assertEquals('Hombre', ParserHelper.normalizeSexo('varón', 'NF'));
        System.assertEquals('Mujer', ParserHelper.normalizeSexo('mujer', 'NF'));
        System.assertEquals('NF', ParserHelper.normalizeSexo('x', 'NF'));

        System.assertEquals('DNI', ParserHelper.normalizeTipoDoc('dni', 'NF'));
        System.assertEquals('NIE', ParserHelper.normalizeTipoDoc('NIE', 'NF'));
        System.assertEquals('Pasaporte', ParserHelper.normalizeTipoDoc('passport', 'NF'));
        System.assertEquals('NF', ParserHelper.normalizeTipoDoc('otro', 'NF'));

        System.assertEquals(
            'Tratamiento con Isótopos Radioactivos',
            ParserHelper.normalizeIncineracion('Tratamiento con Isotopos Radioactivos')
        );
        System.assertEquals(
            'Existencia de prótesis',
            ParserHelper.normalizeIncineracion('Existencia de protesis')
        );
        System.assertEquals('Sin cambios', ParserHelper.normalizeIncineracion('Sin cambios'));
    }

    @IsTest
    static void textComparisonHelpers_coverAccentAndSemicolonNormalization() {
        System.assertEquals('arbol;nino', ParserHelper.normalizarTexto('Árbol ; Niño'));
        System.assertEquals(true, ParserHelper.compararStrings('PÉREZ', 'Perez'));
        System.assertEquals(true, ParserHelper.compararStrings('AB-123/45', 'ab 12345'));
        System.assertEquals(true, ParserHelper.compararStrings('C/ Mayor, 10', 'C Mayor 10'));
        System.assertEquals(false, ParserHelper.compararStrings(null, 'Perez'));
    }

    @IsTest
    static void dateAndTimeHelpers_coverFormatsAndMerge() {
        System.assertEquals(Date.newInstance(2026, 1, 11), ParserHelper.normalizeFecha('11/01/2026', 'NF'));
        System.assertEquals(Date.newInstance(2026, 1, 11), ParserHelper.normalizeFecha('2026-01-11', 'NF'));
        System.assertEquals(Date.newInstance(2026, 1, 11), ParserHelper.normalizeFecha('11.01.2026 09:35', 'NF'));
        System.assertEquals(null, ParserHelper.normalizeFecha('valor no valido', 'NF'));

        System.assertEquals(Time.newInstance(9, 35, 0, 0), ParserHelper.normalizeHora('09:35', 'NF'));
        System.assertEquals(null, ParserHelper.normalizeHora('9:35', 'NF'));
        System.assertEquals(null, ParserHelper.normalizeHora('NF', 'NF'));

        Date fecha = Date.newInstance(2026, 1, 11);
        Time hora = Time.newInstance(9, 35, 0, 0);
        System.assertEquals(Datetime.newInstance(2026, 1, 11, 9, 35, 0), ParserHelper.mergeFechaHora(fecha, hora));
        System.assertEquals(null, ParserHelper.mergeFechaHora(fecha, null));
    }

    @IsTest
    static void picklistHelpers_coverValidationAndLabels() {
        String NOT_FOUND = 'NF';

        System.assertEquals(NOT_FOUND, ParserHelper.validateNacionalidadAgainstPicklist(null, NOT_FOUND));
        System.assertEquals(NOT_FOUND, ParserHelper.validateProvinciaAgainstPicklist('', NOT_FOUND));

        List<Schema.PicklistEntry> nacionalidades = Account.ONE_Nacionalidad__c.getDescribe().getPicklistValues();
        if (!nacionalidades.isEmpty()) {
            Schema.PicklistEntry pe = nacionalidades[0];
            String label = pe.getLabel();
            String expectedValue = pe.getValue();
            System.assertEquals(
                expectedValue,
                ParserHelper.validateNacionalidadAgainstPicklist(label != null ? label.toLowerCase() : '', NOT_FOUND)
            );
        }

        List<Schema.PicklistEntry> provincias = Account.ONE_Provincia__pc.getDescribe().getPicklistValues();
        if (!provincias.isEmpty()) {
            Schema.PicklistEntry pe = provincias[0];
            String label = pe.getLabel();
            String expectedValue = pe.getValue();
            System.assertEquals(
                expectedValue,
                ParserHelper.validateProvinciaAgainstPicklist(label != null ? label.toLowerCase() : '', NOT_FOUND)
            );
        }

        System.assertEquals('CMD', ParserHelper.getPicklistLabel(Agentforce_Error_Log__c.TipoDeDocumento__c, 'CMD'));
        System.assertEquals('', ParserHelper.getPicklistLabel(Agentforce_Error_Log__c.TipoDeDocumento__c, ''));
        System.assertEquals('XX', ParserHelper.getPicklistLabel(Agentforce_Error_Log__c.TipoDeDocumento__c, 'XX'));
    }

    @IsTest
    static void loggingHelpers_coverAllVariants() {
        Date today = Date.today();
        Datetime nowDt = Datetime.newInstance(today, Time.newInstance(12, 0, 0, 0));

        System.assertEquals(
            true,
            ParserHelper.handleFieldLogging(null, 'Municipio', 'Madrid', '', 'Madrid', 'CMD')
        );
        System.assertEquals(
            false,
            ParserHelper.handleFieldLogging(null, 'Municipio', 'Madrid', 'Barcelona', 'Madrid', 'CMD')
        );
        System.assertEquals(
            true,
            ParserHelper.handleFieldLogging(null, 'Municipio', 'Sevilla', 'Barcelona', 'Madrid', 'CMD')
        );
        System.assertEquals(
            false,
            ParserHelper.handleFieldLogging(null, 'Municipio', 'Madrid', 'Madrid', '', 'CMD')
        );

        System.assertEquals(
            true,
            ParserHelper.handleDateFieldLogging(null, 'Fecha', '01/01/2026', null, today, 'CMD')
        );
        System.assertEquals(
            true,
            ParserHelper.handleDateFieldLogging(null, 'Fecha', '01/01/2026', today, today.addDays(1), 'CMD')
        );
        System.assertEquals(
            false,
            ParserHelper.handleDateFieldLogging(null, 'Fecha', '01/01/2026', today, today, 'CMD')
        );

        System.assertEquals(
            true,
            ParserHelper.handleDateTimeFieldLogging(null, 'FechaHora', '01/01/2026', null, nowDt, 'CMD')
        );
        System.assertEquals(
            true,
            ParserHelper.handleDateTimeFieldLogging(null, 'FechaHora', '01/01/2026', today, nowDt, 'CMD')
        );
        System.assertEquals(
            false,
            ParserHelper.handleDateTimeFieldLogging(null, 'FechaHora', '01/01/2026', today, null, 'CMD')
        );

        System.assertEquals(
            true,
            ParserHelper.handleBooleanFieldLogging(null, 'Riesgo', 'true', null, true, 'CMD')
        );
        System.assertEquals(
            false,
            ParserHelper.handleBooleanFieldLogging(null, 'Riesgo', 'true', 'true', true, 'CMD')
        );

        ParserHelper.logNotReadable(null, 'Campo Prueba', 'SF', 'PROMPT', 'INVALID_DOC');
        ParserHelper.logDifferentValue(null, 'Campo Prueba', 'SF', 'PROMPT', 'CMD');
    }
}
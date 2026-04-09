/**
* File Name:  ParserHelper
* Description: Clase helper para normalización, validación y logging de campos parseados en servicios de Agentforce.
* Date: 2025-11-03
*
* Copyright: Konozca Consulting
* @author: Joel Macías
* Test: ParserHelperTest
* Modification Log
* ===================================================================================================================
* Version Date       Author          Modification
* 01   2025-11-03  Joel Macías      Creación del archivo
* 02   2026-02-09  Manu Escudé      Flexibilización comparador de domicilios para reducir falsos registros de error.
* ===================================================================================================================
*/
public with sharing class ParserHelper {
    @TestVisible
    private static String lastLogInsertError;


    public static String normalize(String value, String defaultVal) {
    if (value == null) return defaultVal;
    if (value =='Valor no encontrado') return defaultVal;
    String normalizedValue = value.trim();
    if (normalizedValue == '') return defaultVal;
    return normalizedValue;
    }

    // Valida el valor de nacionalidad contra el picklist Account.ONE_Nacionalidad__c.
    // - Si el valor es NOT_FOUND o está vacío/null, devuelve NOT_FOUND.
    // - Si el valor exacto existe en el picklist (case-sensitive), lo mantiene.
    // - Si no existe, intenta case-insensitive: si encuentra coincidencia única por case-insensitive,
    //   devuelve el valor oficial del picklist. Si no encuentra, retorna NOT_FOUND.
    public static String validateNacionalidadAgainstPicklist(String nacionalidad, String NOT_FOUND) {
        if (nacionalidad == null || nacionalidad == '' || nacionalidad == NOT_FOUND) {
            return NOT_FOUND;
        }
        try {
            Schema.DescribeFieldResult dfr = Account.ONE_Nacionalidad__c.getDescribe();
            List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
            // Mapa para búsqueda case-sensitive y case-insensitive
            for (Schema.PicklistEntry pe : entries) {
                if (pe.getLabel() != null && pe.getLabel().equalsIgnoreCase(nacionalidad)) {
                    return pe.getValue(); // Si "españa".equalsIgnoreCase("España"), devuelve "ES" y sal.
                }
            }
        }
            catch(Exception e){
                system.debug(e);
                    }
            return NOT_FOUND;
                    
        }


    public static String validateProvinciaAgainstPicklist(String provincia, String NOT_FOUND) {
        if (provincia == null || provincia == '' || provincia == NOT_FOUND) {
            return NOT_FOUND;
        }
        try {
            Schema.DescribeFieldResult dfr = Account.ONE_Provincia__pc.getDescribe();
            List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
            Set<String> exact = new Set<String>();
            // Mapa para búsqueda case-sensitive y case-insensitive
            for (Schema.PicklistEntry pe : entries) {
                if (pe.getLabel() != null && pe.getLabel().equalsIgnoreCase(provincia)) {
                    return pe.getValue(); 
                    }
                }
            }
            catch(Exception e){
                system.debug(e);
                    }
            return NOT_FOUND;

    }


    
    // Helpers de logging a Agentforce_Error_Log__c
    public static Boolean handleFieldLogging(Id servicioId, String campo, String valorOriginal, String valorParseado, String valorActualSf, String doc) {
        return handleFieldLogging(servicioId, campo, valorOriginal, valorParseado, valorActualSf, doc, null, null);
    }

    public static Boolean handleFieldLogging(
        Id servicioId,
        String campo,
        String valorOriginal,
        String valorParseado,
        String valorActualSf,
        String doc,
        String primeraLectura,
        String segundaLectura
    ) {
        // Si el parseo resultó en NOT_FOUND (cadena vacía) o null, registramos "no legible"
        if (valorParseado == null || valorParseado == '') {
            logNotReadable(servicioId, campo, valorActualSf, valorOriginal, doc, primeraLectura, segundaLectura);
            return true;
        }

        // Si hay valor en Salesforce y es distinto del parseado, registramos "diferente"
        if (valorActualSf != null) {
            String current = valorActualSf.trim();
            if (current != '') {
                Boolean isDomicilio = isDomicilioField(campo);
                Boolean equalsParsed = isDomicilio
                    ? areEquivalentAddresses(current, valorParseado)
                    : compararStrings(current, valorParseado);
                Boolean equalsOriginal = isDomicilio
                    ? areEquivalentAddresses(valorActualSf, valorOriginal)
                    : compararStrings(valorActualSf, valorOriginal);

                if (!equalsParsed && !equalsOriginal) {
                    logDifferentValue(servicioId, campo, valorActualSf, valorOriginal, doc, primeraLectura, segundaLectura);
                    return true;
                }
            }
        }
        return false;
    }

    public static Boolean handleDateFieldLogging(Id servicioId, String campo, String valorOriginal, Date valorParseado, Date valorActualSf, String doc) {
        return handleDateFieldLogging(servicioId, campo, valorOriginal, valorParseado, valorActualSf, doc, null, null);
    }

    public static Boolean handleDateFieldLogging(
        Id servicioId,
        String campo,
        String valorOriginal,
        Date valorParseado,
        Date valorActualSf,
        String doc,
        String primeraLectura,
        String segundaLectura
    ) {
        if (valorParseado == null) {
            logNotReadable(servicioId, campo, String.valueOf(valorActualSf), String.valueOf(valorOriginal), doc, primeraLectura, segundaLectura);
            return true;
        }
        if (valorActualSf != null && valorActualSf != valorParseado ) {
            logDifferentValue(servicioId, campo, String.valueOf(valorActualSf), String.valueOf(valorOriginal), doc, primeraLectura, segundaLectura);
            return true;
        }
        return false;
    }
    public static Boolean handleDateTimeFieldLogging(Id servicioId, String campo, String valorOriginal, Date valorParseado, DateTime valorActualSf, String doc) {
        return handleDateTimeFieldLogging(servicioId, campo, valorOriginal, valorParseado, valorActualSf, doc, null, null);
    }

    public static Boolean handleDateTimeFieldLogging(
        Id servicioId,
        String campo,
        String valorOriginal,
        Date valorParseado,
        DateTime valorActualSf,
        String doc,
        String primeraLectura,
        String segundaLectura
    ) {
        if (valorParseado == null) {
            logNotReadable(servicioId, campo, String.valueOf(valorActualSf), String.valueOf(valorOriginal), doc, primeraLectura, segundaLectura);
            return true;
        }
        if (valorActualSf != null && valorActualSf != valorParseado ) {
            logDifferentValue(servicioId, campo, String.valueOf(valorActualSf), String.valueOf(valorOriginal), doc, primeraLectura, segundaLectura);
            return true;
        }
        return false;
    }
    public static Boolean handleBooleanFieldLogging(Id servicioId, String campo, String valorOriginal, String valorParseado, Boolean valorActualSf, String doc) {
        return handleBooleanFieldLogging(servicioId, campo, valorOriginal, valorParseado, valorActualSf, doc, null, null);
    }

    public static Boolean handleBooleanFieldLogging(
        Id servicioId,
        String campo,
        String valorOriginal,
        String valorParseado,
        Boolean valorActualSf,
        String doc,
        String primeraLectura,
        String segundaLectura
    ) {
        if (valorParseado == null) {
            logNotReadable(servicioId, campo, String.valueOf(valorActualSf), valorOriginal, doc, primeraLectura, segundaLectura);
            return true;
        }
        return false;
    }

    public static void logNotReadable(Id servicioId, String campo,String valorActualSalesforce, String valorOriginal, String doc) {
        logNotReadable(servicioId, campo, valorActualSalesforce, valorOriginal, doc, null, null);
    }

    public static void logNotReadable(
        Id servicioId,
        String campo,
        String valorActualSalesforce,
        String valorOriginal,
        String doc,
        String primeraLectura,
        String segundaLectura
    ) {
        try {
            Agentforce_Error_Log__c log = new Agentforce_Error_Log__c();
            log.Name = buildErrorLogName(campo, doc);
            log.Servicio__c = servicioId;
            log.Campo_Error__c = campo;
            log.Valor_campo_prompt__c = valorOriginal;
            log.Valor_campo_Salesforce__c = valorActualSalesforce; 
            log.TipoDeDocumento__c = sanitizeTipoDocumento(doc);
            log.Primera_lectura__c = primeraLectura;
            log.Segunda_lectura__c = segundaLectura;
            log.Error_Log__c = 'No se ha podido leer correctamente el valor del campo en el documento';
            insertErrorLog(log);
        } catch (Exception e) {
            // No interrumpir el flujo por errores de log
        }
    }

    public static void logDifferentValue(Id servicioId, String campo, String valorActualSalesforce, String valorOriginal, String doc) {
        logDifferentValue(servicioId, campo, valorActualSalesforce, valorOriginal, doc, null, null);
    }

    public static void logDifferentValue(
        Id servicioId,
        String campo,
        String valorActualSalesforce,
        String valorOriginal,
        String doc,
        String primeraLectura,
        String segundaLectura
    ) {
        try {
            Agentforce_Error_Log__c log = new Agentforce_Error_Log__c();
            log.Name = buildErrorLogName(campo, doc);
            log.Servicio__c = servicioId;
            log.Campo_Error__c = campo;
            log.Valor_campo_Salesforce__c = valorActualSalesforce;
            log.Valor_campo_prompt__c = valorOriginal;
            log.TipoDeDocumento__c = sanitizeTipoDocumento(doc); 
            log.Primera_lectura__c = primeraLectura;
            log.Segunda_lectura__c = segundaLectura;
            log.Error_Log__c = 'El valor encontrado es diferente del que ya se tiene disponible en salesforce';
            insertErrorLog(log);
        } catch (Exception e) {
            // No interrumpir el flujo por errores de log
        }
    }
    public static String getPicklistLabel(Schema.SObjectField fieldRef, String value) {
        if (value == null || value == '') return value;
        try {
            Schema.DescribeFieldResult dfr = fieldRef.getDescribe();
            for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {
                if (pe.getValue() == value) {
                    return pe.getLabel();
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'getPicklistLabel error: ' + e.getMessage());
        }
        return value;
    }
    // Normalizadores

    

    public static String normalizeSexo(String value, String defaultVal) {
        String v = value == null ? '' : value.trim();
        if (v == '') return defaultVal;
        String lower = v.toLowerCase();
        if (lower == 'h' || lower == 'hombre' || lower =='varón') return 'Hombre';
        if (lower == 'm' || lower == 'mujer') return 'Mujer';
        return defaultVal;
    }

    public static String normalizeTipoDoc(String value, String defaultVal) {
        String v = value == null ? '' : value.trim();
        if (v == '') return defaultVal;
        String lower = v.toLowerCase();
        if (lower == 'dni') return 'DNI';
        if (lower == 'nie') return 'NIE';
        if (lower == 'pasaporte' || lower == 'passport') return 'Pasaporte';
        return defaultVal;
    }

    public static Date normalizeFecha(String stringDate, String defaultVal) {
        if (stringDate == null) return null;
        String normalizedDate = stringDate.trim();
        if (normalizedDate == '' || normalizedDate == defaultVal) return null;
        // Acepta formatos comunes de fecha:
        // - DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY
        // - YYYY-MM-DD, YYYY/MM/DD
        // - con hora al final 
        try {
            Matcher ymd = Pattern.compile('^(\\d{4})[\\-/\\.](\\d{1,2})[\\-/\\.](\\d{1,2})(?:\\s+.*)?$').matcher(normalizedDate);
            if (ymd.matches()) {
                Integer year = Integer.valueOf(ymd.group(1));
                Integer month = Integer.valueOf(ymd.group(2));
                Integer day = Integer.valueOf(ymd.group(3));
                return Date.newInstance(year, month, day);
            }

            Matcher dmy = Pattern.compile('^(\\d{1,2})[\\-/\\.](\\d{1,2})[\\-/\\.](\\d{4})(?:\\s+.*)?$').matcher(normalizedDate);
            if (dmy.matches()) {
                Integer day = Integer.valueOf(dmy.group(1));
                Integer month = Integer.valueOf(dmy.group(2));
                Integer year = Integer.valueOf(dmy.group(3));
                return Date.newInstance(year, month, day);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static Time normalizeHora(String stringTime, String defaultVal) {
        if (stringTime == null) return null;
        String t = stringTime.trim();
        if (t == '' || t == defaultVal) return null;

        // HH:MM
        Pattern p = Pattern.compile('^([01]\\d|2[0-3]):([0-5]\\d)$');
        Matcher m = p.matcher(t);
        if (!m.matches()) {
            return null;
        }
        try {
            String[] parts = t.split(':');
            Integer hour = Integer.valueOf(parts[0]);
            Integer minute = Integer.valueOf(parts[1]);
            return Time.newInstance(hour, minute, 0, 0);
        } catch (Exception e) {
            return null;
        }
    }
    public static Datetime mergeFechaHora(Date fecha, Time hora) {
        if (fecha == null || hora == null) return null;
        return Datetime.newInstance(fecha.year(), fecha.month(), fecha.day(), hora.hour(), hora.minute(), 0);

    }
    /**
     * Compara dos cadenas ignorando mayúsculas, acentos y caracteres no alfanuméricos.
     * Devuelve true solo si, tras normalizar, ambas son iguales y no nulas.
     *
     * @param s1 Cadena 1.
     * @param s2 Cadena 2.
     * @return Boolean true si coinciden al normalizar, false en caso contrario.
     */
    public static Boolean compararStrings(String s1, String s2) {
        if (s1 == null || s2 == null) {
            return false;
        }
        String normalizedS1 = normalizeForComparison(s1);
        String normalizedS2 = normalizeForComparison(s2);
        System.debug('Comparando "' + normalizedS1 + '" con "' + normalizedS2 + '"');
        return normalizedS1.equals(normalizedS2);
    }

    /**
     * Normaliza texto a minúsculas y elimina tildes/caracteres especiales más comunes en castellano.
     *
     * @param texto Texto original.
     * @return String Texto normalizado.
     */
    public static String normalizarTexto(String texto) {
        texto = (texto == null) ? '' : texto.toLowerCase();

        // Reemplazar letras acentuadas por su versión sin acento
        texto = texto.replaceAll('[áàäâã]', 'a');
        texto = texto.replaceAll('[éèëê]', 'e');
        texto = texto.replaceAll('[íìïî]', 'i');
        texto = texto.replaceAll('[óòöôõ]', 'o');
        texto = texto.replaceAll('[úùüû]', 'u');
        texto = texto.replaceAll('[ñ]', 'n');
        texto = texto.replaceAll('[ç]', 'c');

        //Eliminar espacios ANTES del punto y coma.
        texto = texto.replaceAll('\\s*;', ';');
        //Eliminar espacios DESPUÉS del punto y coma.
        texto = texto.replaceAll(';\\s*', ';');

        return texto;
    }

    // Normalización orientada a comparación estricta sin ruido de formato.
    private static String normalizeForComparison(String texto) {
        String normalized = normalizarTexto(texto);
        normalized = normalized.replaceAll('[^a-z0-9]', '');
        return normalized;
    }

    // Comparador para Domicilio con tolerancia a formato
    private static Boolean areEquivalentAddresses(String valueA, String valueB) {
        String a = normalizeAddress(valueA);
        String b = normalizeAddress(valueB);

        if (a == '' || b == '') {
            return false;
        }
        if (a == b || a.contains(b) || b.contains(a)) {
            return true;
        }

        Set<String> wordsA = significantAddressWords(a);
        Set<String> wordsB = significantAddressWords(b);
        Set<String> commonWords = new Set<String>(wordsA);
        commonWords.retainAll(wordsB);

        Set<String> numsA = numericAddressTokens(a);
        Set<String> numsB = numericAddressTokens(b);
        Set<String> commonNums = new Set<String>(numsA);
        commonNums.retainAll(numsB);

        if (!commonWords.isEmpty() && !commonNums.isEmpty()) {
            return true;
        }
        // Si comparten al menos dos palabras relevantes, lo consideramos equivalente.
        if (commonWords.size() >= 2) {
            return true;
        }

        // Si una dirección no tiene número (solo nombre de calle) y sus palabras
        // significativas están contenidas en la otra, son equivalentes.
        if (numsB.isEmpty() && !wordsB.isEmpty() && wordsA.containsAll(wordsB)) {
            return true;
        }
        if (numsA.isEmpty() && !wordsA.isEmpty() && wordsB.containsAll(wordsA)) {
            return true;
        }

        if (!commonNums.isEmpty()) {
            for (String wa : wordsA) {
                for (String wb : wordsB) {
                    Integer minLen = Math.min(wa.length(), wb.length());
                    if (minLen >= 4 &&
                        wa.substring(0, 3) == wb.substring(0, 3) &&
                        Math.abs(wa.length() - wb.length()) <= 1) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    private static Boolean isDomicilioField(String campo) {
        return normalizarTexto(campo) == 'domicilio';
    }

    private static String normalizeAddress(String raw) {
        String v = normalizarTexto(normalize(raw, ''));
        if (v == '' || v == 'valor no encontrado') {
            return '';
        }

        v = v.replaceAll('[,.;:/()\\-ºª°#]', ' ');
        v = v.replaceAll('([0-9])([a-z])', '$1 $2');
        v = v.replaceAll('([a-z])([0-9])', '$1 $2');

        // Abreviaturas de vía frecuentes en DNI.
        v = v.replaceAll('\\bc\\.?\\b', 'calle');
        v = v.replaceAll('\\bpseo\\.?\\b', 'paseo');
        v = v.replaceAll('\\bavda\\.?\\b', 'avenida');
        v = v.replaceAll('\\bav\\.?\\b', 'avenida');
        v = v.replaceAll('\\bcrta\\.?\\b', 'carretera');
        v = v.replaceAll('\\burbn\\.?\\b', 'urbanizacion');
        v = v.replaceAll('\\burb\\.?\\b', 'urbanizacion');
        v = v.replaceAll('\\bn\\.?\\b', 'numero');
        // "numero" suele ser solo ruido de formato (n., nº, n) en documentos.
        v = v.replaceAll('\\bnumero\\b', ' ');
        v = v.replaceAll('\\bp0*([0-9]+)\\b', '$1');
        v = v.replaceAll('\\b0+([0-9]+)\\b', '$1');

        return v.replaceAll('\\s+', ' ').trim();
    }

    private static Set<String> significantAddressWords(String address) {
        Set<String> stopwords = new Set<String>{
            'calle','avenida','paseo','carretera','urbanizacion','plaza','camino','travesia','ronda',
            'de','del','la','las','el','los','numero','esc','escalera','bloque','piso','planta','puerta',
            'derecha','izquierda','casetas'
        };

        Set<String> words = new Set<String>();
        for (String token : address.split(' ')) {
            if (String.isBlank(token) || stopwords.contains(token)) {
                continue;
            }
            if (Pattern.compile('^\\d+$').matcher(token).matches()) {
                continue;
            }
            words.add(token);
        }
        return words;
    }

    private static Set<String> numericAddressTokens(String address) {
        Set<String> numbers = new Set<String>();
        for (String token : address.split(' ')) {
            if (Pattern.compile('^\\d+$').matcher(token).matches()) {
                numbers.add(token);
            }
        }
        return numbers;
    }

    /**
     * Devuelve el valor de la lista de selección de incineración corregido si es necesario.
     *
     * @param value Valor de la respuesta del prompt.
     * @return String Valor de la lista de selección.
     */
    public static String normalizeIncineracion(String value) {
        String normalized = normalizarTexto(value);
        if (normalized == 'tratamiento con isotopos radioactivos') {
            return 'Tratamiento con Isótopos Radioactivos';
        } else if (normalized == 'existencia de protesis') {
            return 'Existencia de prótesis';
        } else {
            return value;
        }
    }

    private static String buildErrorLogName(String campo, String doc) {
        String campoSafe = String.isBlank(campo) ? 'Campo' : campo.trim();
        String docSafe = String.isBlank(doc) ? 'DOC' : doc.trim();
        String raw = docSafe + ' - ' + campoSafe + ' - ' + String.valueOf(Datetime.now().getTime());
        return raw.length() > 80 ? raw.substring(0, 80) : raw;
    }

    private static String sanitizeTipoDocumento(String doc) {
        if (String.isBlank(doc)) {
            return null;
        }
        String candidate = doc.trim();
        try {
            Set<String> allowedValues = new Set<String>();
            for (Schema.PicklistEntry pe : Agentforce_Error_Log__c.TipoDeDocumento__c.getDescribe().getPicklistValues()) {
                allowedValues.add(pe.getValue());
            }
            return allowedValues.contains(candidate) ? candidate : null;
        } catch (Exception e) {
            return null;
        }
    }

    private static void insertErrorLog(Agentforce_Error_Log__c logRecord) {
        lastLogInsertError = null;
        Database.SaveResult sr = Database.insert(logRecord, false);
        if (sr.isSuccess()) {
            return;
        }

        lastLogInsertError = sr.getErrors()[0].getStatusCode() + ': ' + sr.getErrors()[0].getMessage();

        // Reintento mínimo sin tipo de documento para evitar fallos por restricciones de picklist.
        if (!String.isBlank(logRecord.TipoDeDocumento__c)) {
            logRecord.TipoDeDocumento__c = null;
            sr = Database.insert(logRecord, false);
            if (sr.isSuccess()) {
                lastLogInsertError = null;
                return;
            }
            lastLogInsertError = sr.getErrors()[0].getStatusCode() + ': ' + sr.getErrors()[0].getMessage();
        }
    }
    
}
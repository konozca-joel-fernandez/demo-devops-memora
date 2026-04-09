/**
* File Name: JsonCMDParser
* Description:
 * Parser y comparador de JSON de Certificado Médico de Defunción .
 * - Deserializa dos JSON de entrada por petición.
 * - Normaliza valores (cadenas, sexo, tipo de documento).
 * - Convierte fechas (DD/MM/YYYY) y horas (HH:MM).
 * - Compara ambos resultados y devuelve un único DTO con los valores coincidentes.
*
* Copyright: Konozca Consulting
* @author: Joel Macías
* Test: JsonCMDParserTest
* Modification Log
* ===================================================================================================================
*Version Date       Author          Modification
* 01   2025-11-03  Joel Macías      Creación del archivo
* 02   2026-02-09  Manu Escudé      Ajustes en lógica de comparación y logging de errores
* 03   2026-04-09  Joel Fernández   Test Demo DevOps
* ===================================================================================================================
*/
public with sharing class JsonCMDParser {

    /**
     * Constante de marcador cuando un valor no se encuentra o no coincide.
     */
    private static final String NOT_FOUND = '';
    private static final String TIPODOC = 'CMD';

    /**
     * DTO de entrada para el método invocable. Contiene los dos JSON a comparar.
     */
    public class Request {
        /**
         * Primer payload JSON (texto) recibido.
         */
        @InvocableVariable(required=true)
        public String jsonPayload1;
        /**
         * Segundo payload JSON (texto) recibido.
         */
        @InvocableVariable(required=true)
        public String jsonPayload2;

        /**
         * Id del servicio (ONE_Expediente__c) para logging en Agentforce_Error_Log__c.
         */
        @InvocableVariable(required=false)
        public Id servicioId;
    }

    /**
     * DTO de salida con todos los campos normalizados del CMD que serán usados en Flow.
     */
    public class Response {
        @InvocableVariable(description='NOMBRE_FALLECIDO')
        public String NOMBRE_FALLECIDO;
        @InvocableVariable(description='PRIMER Y SEGUNDO APELLIDOS ')
        public String APELLIDOS;
        @InvocableVariable(description='FECHA_NACIMIENTO (Date)')
        public Date FECHA_NACIMIENTO;
        @InvocableVariable(description='SEXO (Hombre/Mujer/Valor no encontrado)')
        public String SEXO;
        @InvocableVariable(description='TIPO DE DOCUMENTO (DNI/NIE/Pasaporte/Valor no encontrado)')
        public String TIPO_DOCUMENTO;
        @InvocableVariable(description='DOCUMENTO_IDENTIDAD')
        public String DOCUMENTO_IDENTIDAD;
        @InvocableVariable(description='FECHA_DEFUNCION (Date)')
        public Date FECHA_DEFUNCION;
        @InvocableVariable(description='HORA_DEFUNCION (Time)')
        public Time HORA_DEFUNCION;
        @InvocableVariable(description='LUGAR_DEFUNCION')
        public String LUGAR_DEFUNCION;
        @InvocableVariable(description='FECHAHORA_DEFUNCION (Date Time)')
        public Datetime FECHAHORA_DEFUNCION;
        @InvocableVariable(description='MUNICIPIO_DEFUNCION')
        public String MUNICIPIO_DEFUNCION;
        @InvocableVariable(description='PROVINCIA_DEFUNCION')
        public String PROVINCIA_DEFUNCION;
        @InvocableVariable(description='CAUSA_INMEDIATA')
        public String CAUSA_INMEDIATA;
        @InvocableVariable(description='CAUSAS_INTERMEDIAS')
        public String CAUSAS_INTERMEDIAS;
        @InvocableVariable(description='CAUSA_FUNDAMENTAL')
        public String CAUSA_FUNDAMENTAL;
        @InvocableVariable(description='OTROS_PROCESOS')
        public String OTROS_PROCESOS;
        @InvocableVariable(description='NOMBRE_MEDICO')
        public String NOMBRE_MEDICO;
        @InvocableVariable(description='PRIMER_APELLIDO_MEDICO')
        public String PRIMER_APELLIDO_MEDICO;
        @InvocableVariable(description='SEGUNDO_APELLIDO_MEDICO')
        public String SEGUNDO_APELLIDO_MEDICO;
        @InvocableVariable(description='NUMERO_COLEGIADO')
        public String NUMERO_COLEGIADO;
        @InvocableVariable(description='NUMERO_CERTIFICADO')
        public String NUMERO_CERTIFICADO;
        @InvocableVariable(description='LOCALIDAD_CERTIFICADO')
        public String LOCALIDAD_CERTIFICADO;
        @InvocableVariable(description='FECHA_CERTIFICADO (Date)')
        public Date FECHA_CERTIFICADO;
        @InvocableVariable(description='RIESGO')    
        public String RIESGO;
        @InvocableVariable(description='DESCRIPCION_RIESGO')
        public String DESCRIPCION_RIESGO;
        @InvocableVariable(description='INCINERACION_CONDICIONADA')
        public String INCINERACION_CONDICIONADA;
        @InvocableVariable(description='HAS_ERRORS_LOGGING')
        public Boolean HAS_ERRORS_LOGGING;
        @InvocableVariable(description='NUMERO_ERRORES')
        public INTEGER NUMERO_ERRORES;
        @InvocableVariable(description='JSON con campos no coincidentes entre las dos lecturas para reconciliacion via AgentForce')
        public String mismatchedFieldsJson;
    }

    // DTO de entrada esperado por JSON.deserialize (claves exactas del JSON)
    private class CMDInDTO {
        public String NOMBRE_FALLECIDO;
        public String PRIMER_APELLIDO;
		public String SEGUNDO_APELLIDO;
        public String FECHA_NACIMIENTO;
        public String SEXO;
        public String TIPO_DOCUMENTO;
        public String DOCUMENTO_IDENTIDAD;

        public String FECHA_DEFUNCION;
        public String HORA_DEFUNCION;
        public String LUGAR_DEFUNCION;
        public String MUNICIPIO_DEFUNCION;
        public String PROVINCIA_DEFUNCION;

        public String CAUSA_INMEDIATA;
        public String CAUSAS_INTERMEDIAS;
        public String CAUSA_FUNDAMENTAL;
        public String OTROS_PROCESOS;
        
        public String NOMBRE_MEDICO;
        public String PRIMER_APELLIDO_MEDICO;
        public String SEGUNDO_APELLIDO_MEDICO;
        public String NUMERO_COLEGIADO;
        public String LOCALIDAD_CERTIFICADO;
        public String FECHA_CERTIFICADO;

        public String NUMERO_CERTIFICADO;

        public String RIESGO;
        public String DESCRIPCION_RIESGO;
        public String INCINERACION_CONDICIONADA;

        public Boolean HAS_ERRORS_LOGGING;
        public Integer NUMERO_ERRORES;
    }

    /**
     * Método invocable que parsea, normaliza y compara dos payloads JSON del CMD por cada Request.
     * - Deserializa ambos JSON en el DTO interno.
     * - Normaliza valores (strings, fechas, horas).
     * - Compara ambos resultados y devuelve un único Response por Request, con valores coincidentes o NOT_FOUND.
     *
     * @param requests Lista de requests con dos JSON a comparar por cada elemento.
     * @return List<Response> Lista de respuestas (una por request), con valores normalizados y validados para Flow.
     * @author Joel Macías
     * @since 03/11/2025
     */
    @InvocableMethod(label='Parse JSON CMD' description='Parsea los JSON recibidos , los compara y devuelve DTO con valores normalizados iguales para Flow')
    public static List<Response> parse(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request r : requests) {
            Response response1 = parseOne(r != null ? r.jsonPayload1 : null);
            Response response2 = parseOne(r != null ? r.jsonPayload2 : null);
            Response res = compareResponses(response1, response2);
            //Normalize value in incineracion condicionada
            res.INCINERACION_CONDICIONADA = ParserHelper.normalizeIncineracion(res.INCINERACION_CONDICIONADA);
            Boolean hasErrors = checkLogs(r,res);
            res.HAS_ERRORS_LOGGING = hasErrors;
            results.add(res);
        }
        return results;
    }

    /**
     * Compara dos respuestas normalizadas campo a campo:
     * - Para Strings, compara insensible a mayúsculas y tildes.
     * - Para fechas/horas, igualdad exacta de valores Date/Time.
     * - Si no coinciden, devuelve NOT_FOUND (o null para tipos fecha/hora).
     *
     * @param response1 Primera respuesta normalizada.
     * @param response2 Segunda respuesta normalizada.
     * @return Response Respuesta resultante con los campos coincidentes o NOT_FOUND/null en su defecto.
     */
    private static Response compareResponses(Response response1, Response response2) {
        Response r = new Response();
        Map<String, Map<String, String>> mismatches = new Map<String, Map<String, String>>();

        r.NOMBRE_FALLECIDO = compareStringField('NOMBRE_FALLECIDO', response1.NOMBRE_FALLECIDO, response2.NOMBRE_FALLECIDO, mismatches);
        r.APELLIDOS = compareStringField('APELLIDOS', response1.APELLIDOS, response2.APELLIDOS, mismatches);
        r.SEXO = compareStringField('SEXO', response1.SEXO, response2.SEXO, mismatches);
        r.TIPO_DOCUMENTO = compareStringField('TIPO_DOCUMENTO', response1.TIPO_DOCUMENTO, response2.TIPO_DOCUMENTO, mismatches);
        r.DOCUMENTO_IDENTIDAD = compareStringField('DOCUMENTO_IDENTIDAD', response1.DOCUMENTO_IDENTIDAD, response2.DOCUMENTO_IDENTIDAD, mismatches);
        r.LUGAR_DEFUNCION = compareStringField('LUGAR_DEFUNCION', response1.LUGAR_DEFUNCION, response2.LUGAR_DEFUNCION, mismatches);
        r.MUNICIPIO_DEFUNCION = compareStringField('MUNICIPIO_DEFUNCION', response1.MUNICIPIO_DEFUNCION, response2.MUNICIPIO_DEFUNCION, mismatches);
        r.PROVINCIA_DEFUNCION = compareStringField('PROVINCIA_DEFUNCION', response1.PROVINCIA_DEFUNCION, response2.PROVINCIA_DEFUNCION, mismatches);
        r.CAUSA_INMEDIATA = compareStringField('CAUSA_INMEDIATA', response1.CAUSA_INMEDIATA, response2.CAUSA_INMEDIATA, mismatches);
        r.CAUSAS_INTERMEDIAS = compareStringField('CAUSAS_INTERMEDIAS', response1.CAUSAS_INTERMEDIAS, response2.CAUSAS_INTERMEDIAS, mismatches);
        r.CAUSA_FUNDAMENTAL = compareStringField('CAUSA_FUNDAMENTAL', response1.CAUSA_FUNDAMENTAL, response2.CAUSA_FUNDAMENTAL, mismatches);
        r.OTROS_PROCESOS = compareStringField('OTROS_PROCESOS', response1.OTROS_PROCESOS, response2.OTROS_PROCESOS, mismatches);
        r.NOMBRE_MEDICO = compareStringField('NOMBRE_MEDICO', response1.NOMBRE_MEDICO, response2.NOMBRE_MEDICO, mismatches);
        r.PRIMER_APELLIDO_MEDICO = compareStringField('PRIMER_APELLIDO_MEDICO', response1.PRIMER_APELLIDO_MEDICO, response2.PRIMER_APELLIDO_MEDICO, mismatches);
        r.SEGUNDO_APELLIDO_MEDICO = compareStringField('SEGUNDO_APELLIDO_MEDICO', response1.SEGUNDO_APELLIDO_MEDICO, response2.SEGUNDO_APELLIDO_MEDICO, mismatches);
        r.NUMERO_COLEGIADO = compareStringField('NUMERO_COLEGIADO', response1.NUMERO_COLEGIADO, response2.NUMERO_COLEGIADO, mismatches);
        r.LOCALIDAD_CERTIFICADO = compareStringField('LOCALIDAD_CERTIFICADO', response1.LOCALIDAD_CERTIFICADO, response2.LOCALIDAD_CERTIFICADO, mismatches);

        // Fechas y horas requieren igualdad exacta de tipo
        r.FECHA_NACIMIENTO = (response1.FECHA_NACIMIENTO == response2.FECHA_NACIMIENTO) ? response1.FECHA_NACIMIENTO : null;
        r.FECHA_DEFUNCION = (response1.FECHA_DEFUNCION == response2.FECHA_DEFUNCION) ? response1.FECHA_DEFUNCION : null;
        r.FECHA_CERTIFICADO = (response1.FECHA_CERTIFICADO == response2.FECHA_CERTIFICADO) ? response1.FECHA_CERTIFICADO : null;
        r.HORA_DEFUNCION = (response1.HORA_DEFUNCION == response2.HORA_DEFUNCION) ? response1.HORA_DEFUNCION : null;
        r.FECHAHORA_DEFUNCION = (response1.FECHAHORA_DEFUNCION == response2.FECHAHORA_DEFUNCION) ? response1.FECHAHORA_DEFUNCION : null;

        r.NUMERO_CERTIFICADO = compareStringField('NUMERO_CERTIFICADO', response1.NUMERO_CERTIFICADO, response2.NUMERO_CERTIFICADO, mismatches);

        r.RIESGO = compareStringField('RIESGO', response1.RIESGO, response2.RIESGO, mismatches);
        r.DESCRIPCION_RIESGO = compareStringField('DESCRIPCION_RIESGO', response1.DESCRIPCION_RIESGO, response2.DESCRIPCION_RIESGO, mismatches);
        r.INCINERACION_CONDICIONADA = compareStringField('INCINERACION_CONDICIONADA', response1.INCINERACION_CONDICIONADA, response2.INCINERACION_CONDICIONADA, mismatches);

        r.mismatchedFieldsJson = mismatches.isEmpty() ? null : JSON.serialize(mismatches);
        return r;
    }

    /**
     * Compara dos valores de texto y, si no coinciden, registra el par en el mapa de mismatches.
     * @param fieldName Nombre del campo (clave para el mapa de mismatches).
     * @param val1 Valor de la primera lectura.
     * @param val2 Valor de la segunda lectura.
     * @param mismatches Mapa acumulador de campos no coincidentes.
     * @return El valor coincidente o NOT_FOUND si no coinciden.
     */
    private static String compareStringField(String fieldName, String val1, String val2, Map<String, Map<String, String>> mismatches) {
        if (ParserHelper.compararStrings(val1, val2)) {
            return val1;
        }
        if (String.isNotBlank(val1) || String.isNotBlank(val2)) {
            mismatches.put(fieldName, new Map<String, String>{
                'lectura1' => val1 != null ? val1 : '',
                'lectura2' => val2 != null ? val2 : ''
            });
        }
        return NOT_FOUND;
    }

  
    /**
     * Parser central de un único payload JSON:
     * - Deserializa el JSON en el DTO interno.
     * - Normaliza cadenas, sexo, tipo de documento.
     * - Convierte fechas y horas.
     * - Calcula FECHAHORA_DEFUNCION si hay fecha y hora válidas.
     * En caso de error devuelve la respuesta por defecto.
     *
     * @param jsonPayload Cadena JSON a procesar.
     * @return Response DTO con campos normalizados a partir del payload. Si vacío/erróneo, defaults/NOT_FOUND.
     */
    private static Response parseOne(String jsonPayload) {
        
        Response res = defaultResponse(NOT_FOUND);

        if (String.isBlank(jsonPayload)) {
            return res;
        }
        try {
            CMDInDTO dto = (CMDInDTO) JSON.deserialize(jsonPayload, CMDInDTO.class);
       
            res.NOMBRE_FALLECIDO        = ParserHelper.normalize(dto != null ? dto.NOMBRE_FALLECIDO   : null, NOT_FOUND);
            if ( dto.SEGUNDO_APELLIDO == 'Valor no encontrado') dto.SEGUNDO_APELLIDO = '';
            res.APELLIDOS               = ParserHelper.normalize(dto != null ? dto.PRIMER_APELLIDO + ' ' + dto.SEGUNDO_APELLIDO : null, NOT_FOUND); 
            res.SEXO                    = ParserHelper.normalizeSexo(dto != null ? dto.SEXO               : null, NOT_FOUND);
            res.TIPO_DOCUMENTO          = ParserHelper.normalizeTipoDoc(dto != null ? dto.TIPO_DOCUMENTO : null, NOT_FOUND);
            res.DOCUMENTO_IDENTIDAD     = ParserHelper.normalize(dto != null ? dto.DOCUMENTO_IDENTIDAD: null, NOT_FOUND);
            res.LUGAR_DEFUNCION         = ParserHelper.normalize(dto != null ? dto.LUGAR_DEFUNCION    : null, NOT_FOUND);
            res.MUNICIPIO_DEFUNCION     = ParserHelper.normalize(dto != null ? dto.MUNICIPIO_DEFUNCION: null, NOT_FOUND);
            res.PROVINCIA_DEFUNCION     = ParserHelper.normalize(dto != null ? dto.PROVINCIA_DEFUNCION: null, NOT_FOUND);
            res.CAUSA_INMEDIATA         = ParserHelper.normalize(dto != null ? dto.CAUSA_INMEDIATA    : null, NOT_FOUND);
            res.CAUSAS_INTERMEDIAS      = ParserHelper.normalize(dto != null ? dto.CAUSAS_INTERMEDIAS : null, NOT_FOUND);
            res.CAUSA_FUNDAMENTAL       = ParserHelper.normalize(dto != null ? dto.CAUSA_FUNDAMENTAL  : null, NOT_FOUND);
            res.OTROS_PROCESOS          = ParserHelper.normalize(dto != null ? dto.OTROS_PROCESOS     : null, NOT_FOUND);
            res.NOMBRE_MEDICO           = ParserHelper.normalize(dto != null ? dto.NOMBRE_MEDICO      : null, NOT_FOUND);
            res.PRIMER_APELLIDO_MEDICO  = ParserHelper.normalize(dto != null ? dto.PRIMER_APELLIDO_MEDICO : null, NOT_FOUND);
            res.SEGUNDO_APELLIDO_MEDICO = ParserHelper.normalize(dto != null ? dto.SEGUNDO_APELLIDO_MEDICO : null, NOT_FOUND);
            res.NUMERO_COLEGIADO        = ParserHelper.normalize(dto != null ? dto.NUMERO_COLEGIADO   : null, NOT_FOUND);
            res.LOCALIDAD_CERTIFICADO   = ParserHelper.normalize(dto != null ? dto.LOCALIDAD_CERTIFICADO : null, NOT_FOUND);
            res.NUMERO_CERTIFICADO      = ParserHelper.normalize(dto != null ? dto.NUMERO_CERTIFICADO : null, NOT_FOUND);
            res.RIESGO                  = ParserHelper.normalize(dto != null ? dto.RIESGO : null, NOT_FOUND);
            res.DESCRIPCION_RIESGO      = ParserHelper.normalize(dto != null ? dto.DESCRIPCION_RIESGO : null, NOT_FOUND);
            res.INCINERACION_CONDICIONADA = ParserHelper.normalize(dto != null ? dto.INCINERACION_CONDICIONADA : null, NOT_FOUND);
            // Fechas (DD/MM/YYYY) -> Date
            res.FECHA_NACIMIENTO   = ParserHelper.normalizeFecha(dto != null ? dto.FECHA_NACIMIENTO   : null, NOT_FOUND);
            res.FECHA_DEFUNCION    = ParserHelper.normalizeFecha(dto != null ? dto.FECHA_DEFUNCION    : null, NOT_FOUND);
            res.FECHA_CERTIFICADO  = ParserHelper.normalizeFecha(dto != null ? dto.FECHA_CERTIFICADO  : null, NOT_FOUND);
            // Hora (HH:MM) -> Time
            res.HORA_DEFUNCION     = ParserHelper.normalizeHora(dto != null ? dto.HORA_DEFUNCION : null, NOT_FOUND);

            //Fecha y hora combinadas
            res.FECHAHORA_DEFUNCION = ParserHelper.mergeFechaHora(res.FECHA_DEFUNCION, res.HORA_DEFUNCION);

        } catch (Exception e) {
            // Devuelve default si hay error
        }
        return res;
    }

    // Respuesta con defaults
    private static Response defaultResponse(String NOT_FOUND) {
        Response r = new Response();
        r.NOMBRE_FALLECIDO = NOT_FOUND;
        r.APELLIDOS = NOT_FOUND;
        r.SEXO = NOT_FOUND;
        r.TIPO_DOCUMENTO = NOT_FOUND;
        r.DOCUMENTO_IDENTIDAD = NOT_FOUND;
        r.LUGAR_DEFUNCION = NOT_FOUND;
        r.MUNICIPIO_DEFUNCION = NOT_FOUND;
        r.PROVINCIA_DEFUNCION = NOT_FOUND;
        r.CAUSA_INMEDIATA = NOT_FOUND;
        r.CAUSAS_INTERMEDIAS = NOT_FOUND;
        r.CAUSA_FUNDAMENTAL = NOT_FOUND;
        r.OTROS_PROCESOS = NOT_FOUND;
        r.NOMBRE_MEDICO = NOT_FOUND;
        r.PRIMER_APELLIDO_MEDICO = NOT_FOUND;
        r.SEGUNDO_APELLIDO_MEDICO = NOT_FOUND;
        r.NUMERO_COLEGIADO = NOT_FOUND;
        r.LOCALIDAD_CERTIFICADO = NOT_FOUND;
        r.FECHA_NACIMIENTO = null;
        r.FECHA_DEFUNCION = null;
        r.FECHA_CERTIFICADO = null;
        r.HORA_DEFUNCION = null;
        r.FECHAHORA_DEFUNCION = null;
        r.NUMERO_CERTIFICADO = NOT_FOUND;
        r.RIESGO = NOT_FOUND;
        r.DESCRIPCION_RIESGO = NOT_FOUND;
        r.INCINERACION_CONDICIONADA = NOT_FOUND;
        return r;
    }

    private static Boolean checkLogs(Request r, Response res ){
        Boolean hasError = false;
        Integer errorsCount = 0;
        if (r != null && r.servicioId != null) {
                try {
                    CMDInDTO dto = String.isBlank(r.jsonPayload1)
                        ? new CMDInDTO()
                        : (CMDInDTO) JSON.deserialize(r.jsonPayload1, CMDInDTO.class);
                    if (dto == null) {
                        dto = new CMDInDTO();
                    }
                    CMDInDTO dto2 = String.isBlank(r.jsonPayload2)
                        ? new CMDInDTO()
                        : (CMDInDTO) JSON.deserialize(r.jsonPayload2, CMDInDTO.class);
                    if (dto2 == null) {
                        dto2 = new CMDInDTO();
                    }
                    List<ONE_Expediente__c> servList = [
                        SELECT Id,
                        ONE_Difunto__c,
                        ONE_Causa_Inicial_o_Fundamental__c,
                        ONE_Causas_Intermedias__c,
                        ONE_Causa_Inmediata__c,
                        ONE_Otros_procesos__c,
                        ONE_Lugar_de_defuncion__c,
                        ONE_Fecha_De_Defuncion__c,
                        ONE_Municipio_De_Defuncion__c,
                        ONE_N_Certificado__c,
                        ONE_N_Colegiado__c,
                        ONE_Nombre_Doctor__c,
                        ONE_Primer_Apellido_Doctor__c,
                        ONE_Segundo_Apellido_Doctor__c,
                        ONE_Tipo_De_Lugar_De_Defuncion__c,
                        ONE_Riesgo__c,
                        ONE_Descripcion_De_Riesgo__c,
                        ONE_Incineraci_n_condicionada__c,
                        ONE_Nombre_Lugar_de_defuncion__c

                        FROM ONE_Expediente__c
                        WHERE Id = :r.servicioId
                        LIMIT 1
                    ];
                    if (servList.isEmpty()) {
                        return hasError;
                    }
                    ONE_Expediente__c serv = servList[0];
                    Account difunto = null;
                    if (serv.ONE_Difunto__c != null) {
                        List<Account> difuntoList = [
                            SELECT Id,
                                FirstName,
                                LastName,
                                ONE_Fecha_de_nacimiento__pc,
                                ONE_Fecha_de_defuncion__pc
                            FROM Account
                            WHERE Id = :serv.ONE_Difunto__c
                            LIMIT 1
                        ];
                        difunto = difuntoList.isEmpty() ? null : difuntoList[0];
                    }

                    // Campos CMD comparados contra Account (difunto)
                    // Nombre/apellidos del fallecido
                    /*Boolean nameError = ParserHelper.handleFieldLogging(r.servicioId, 'Nombre', dto.NOMBRE_FALLECIDO, res.NOMBRE_FALLECIDO, difunto != null ? difunto.FirstName : null, TIPODOC);
                    if (nameError) {
                        errorsCount++;
                    }
                    hasError = hasError || nameError;
                    Boolean apellidoError = ParserHelper.handleFieldLogging(r.servicioId, 'Apellidos', dto.PRIMER_APELLIDO + dto.SEGUNDO_APELLIDO, res.APELLIDOS, difunto != null ? difunto.LastName : null, TIPODOC);
                    if (apellidoError) {
                        errorsCount++;
                    }
                    hasError = hasError || apellidoError;*/
                    // Fecha nacimiento
                    Boolean fechaNacError = ParserHelper.handleDateFieldLogging(
                        r.servicioId,
                        'Fecha Nacimiento',
                        dto.FECHA_NACIMIENTO,
                        res.FECHA_NACIMIENTO,
                        difunto != null ? difunto.ONE_Fecha_de_nacimiento__pc : null,
                        TIPODOC,
                        dto.FECHA_NACIMIENTO,
                        dto2.FECHA_NACIMIENTO
                    );
                    if (fechaNacError) {
                        errorsCount++;
                    }
                    hasError = hasError || fechaNacError;
                    // Fecha defunción (desactivado)
                    //Boolean fechaDefuncionError = ParserHelper.handleDateFieldLogging(
                    //    r.servicioId,
                    //    'Fecha Defunción',
                    //    dto.FECHA_DEFUNCION,
                    //    res.FECHA_DEFUNCION,
                    //    difunto != null ? difunto.ONE_Fecha_de_defuncion__pc : null,
                    //    TIPODOC
                    //);
                    //if (fechaDefuncionError) {
                    //    errorsCount++;
                    //}
                    //hasError = hasError || fechaDefuncionError;

                    // Logging adicional para los campos solicitados
                    Boolean causaInicialError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Causa Inicial o Fundamental',
                        dto.CAUSA_FUNDAMENTAL,
                        res.CAUSA_FUNDAMENTAL,
                        serv.ONE_Causa_Inicial_o_Fundamental__c,
                        TIPODOC,
                        dto.CAUSA_FUNDAMENTAL,
                        dto2.CAUSA_FUNDAMENTAL
                    );
                    if (causaInicialError) {
                        errorsCount++;
                    }
                    hasError = hasError || causaInicialError;

                    Boolean causaIntermediaError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Causa Intermedia',
                        dto.CAUSAS_INTERMEDIAS,
                        res.CAUSAS_INTERMEDIAS,
                        serv.ONE_Causas_Intermedias__c,
                        TIPODOC,
                        dto.CAUSAS_INTERMEDIAS,
                        dto2.CAUSAS_INTERMEDIAS
                    );
                    if (causaIntermediaError) {
                        errorsCount++;
                    }
                    hasError = hasError || causaIntermediaError;

                    Boolean causaInmediataError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Causa Inmediata',
                        dto.CAUSA_INMEDIATA,
                        res.CAUSA_INMEDIATA,
                        serv.ONE_Causa_Inmediata__c,
                        TIPODOC,
                        dto.CAUSA_INMEDIATA,
                        dto2.CAUSA_INMEDIATA
                    );
                    if (causaInmediataError) {
                        errorsCount++;
                    }
                    hasError = hasError || causaInmediataError;

                    if (res.OTROS_PROCESOS != '') {
                        Boolean otrosProcesosError = ParserHelper.handleFieldLogging(
                            r.servicioId,
                            'Otros Procesos',
                            dto.OTROS_PROCESOS,
                            res.OTROS_PROCESOS,
                            serv.ONE_Otros_procesos__c,
                            TIPODOC,
                            dto.OTROS_PROCESOS,
                            dto2.OTROS_PROCESOS
                        );
                        if (otrosProcesosError) {
                            errorsCount++;
                        }
                        hasError = hasError || otrosProcesosError;
                    }                    

                    Boolean lugarDefuncionError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Lugar de Defunción',
                        dto.LUGAR_DEFUNCION,
                        res.LUGAR_DEFUNCION,
                        serv.ONE_Nombre_Lugar_de_defuncion__c,
                        TIPODOC,
                        dto.LUGAR_DEFUNCION,
                        dto2.LUGAR_DEFUNCION
                    );
                    if (lugarDefuncionError) {
                        errorsCount++;
                    }
                    hasError = hasError || lugarDefuncionError;
                    // Fecha de defunción
                    // Fallbacks para evitar falsos negativos cuando el comparador deja null
                    // o cuando el campo del expediente viene vacío por automatizaciones.
                    Date fechaDefParseada = res.FECHA_DEFUNCION;
                    if (fechaDefParseada == null && dto != null) {
                        fechaDefParseada = ParserHelper.normalizeFecha(dto.FECHA_DEFUNCION, NOT_FOUND);
                    }
                    Date fechaDef = (serv.ONE_Fecha_De_Defuncion__c != null)
                        ? serv.ONE_Fecha_De_Defuncion__c.date()
                        : (difunto != null ? difunto.ONE_Fecha_de_defuncion__pc : null);
                    Boolean fechaDefuncion2Error = ParserHelper.handleDateFieldLogging(
                        r.servicioId,
                        'Fecha de Defunción',
                        dto.FECHA_DEFUNCION,
                        fechaDefParseada,
                        fechaDef,
                        TIPODOC,
                        dto.FECHA_DEFUNCION,
                        dto2.FECHA_DEFUNCION
                    );
                    if (fechaDefuncion2Error) {
                        errorsCount++;
                    }
                    hasError = hasError || fechaDefuncion2Error;

                    Boolean municipioDefuncionError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Municipio de Defunción',
                        dto.MUNICIPIO_DEFUNCION,
                        res.MUNICIPIO_DEFUNCION,
                        serv.ONE_Municipio_De_Defuncion__c,
                        TIPODOC,
                        dto.MUNICIPIO_DEFUNCION,
                        dto2.MUNICIPIO_DEFUNCION
                    );
                    if (municipioDefuncionError) {
                        errorsCount++;
                    }
                    hasError = hasError || municipioDefuncionError;

                    Boolean numCertificadoError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Número de Certificado',
                        dto.NUMERO_CERTIFICADO,
                        res.NUMERO_CERTIFICADO,
                        serv.ONE_N_Certificado__c,
                        TIPODOC,
                        dto.NUMERO_CERTIFICADO,
                        dto2.NUMERO_CERTIFICADO
                    );
                    if (numCertificadoError) {
                        errorsCount++;
                    }
                    hasError = hasError || numCertificadoError;

                    Boolean numColegiadoError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Número de Colegiado',
                        dto.NUMERO_COLEGIADO,
                        res.NUMERO_COLEGIADO,
                        serv.ONE_N_Colegiado__c,
                        TIPODOC,
                        dto.NUMERO_COLEGIADO,
                        dto2.NUMERO_COLEGIADO
                    );
                    if (numColegiadoError) {
                        errorsCount++;
                    }
                    hasError = hasError || numColegiadoError;

                    Boolean nombreDoctorError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Nombre del Doctor',
                        dto.NOMBRE_MEDICO,
                        res.NOMBRE_MEDICO,
                        serv.ONE_Nombre_Doctor__c,
                        TIPODOC,
                        dto.NOMBRE_MEDICO,
                        dto2.NOMBRE_MEDICO
                    );
                    if (nombreDoctorError) {
                        errorsCount++;
                    }
                    hasError = hasError || nombreDoctorError;

                    Boolean primerApellidoDoctorError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Primer Apellido del Doctor',
                        dto.PRIMER_APELLIDO_MEDICO,
                        res.PRIMER_APELLIDO_MEDICO,
                        serv.ONE_Primer_Apellido_Doctor__c,
                        TIPODOC,
                        dto.PRIMER_APELLIDO_MEDICO,
                        dto2.PRIMER_APELLIDO_MEDICO
                    );
                    if (primerApellidoDoctorError) {
                        errorsCount++;
                    }
                    hasError = hasError || primerApellidoDoctorError;

                    Boolean segundoApellidoDoctorError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Segundo Apellido del Doctor',
                        dto.SEGUNDO_APELLIDO_MEDICO,
                        res.SEGUNDO_APELLIDO_MEDICO,
                        serv.ONE_Segundo_Apellido_Doctor__c,
                        TIPODOC,
                        dto.SEGUNDO_APELLIDO_MEDICO,
                        dto2.SEGUNDO_APELLIDO_MEDICO
                    );
                    if (segundoApellidoDoctorError) {
                        errorsCount++;
                    }
                    hasError = hasError || segundoApellidoDoctorError;

                    
                    String tipolugarLabel = ParserHelper.getPicklistLabel(ONE_Expediente__c.ONE_Tipo_De_Lugar_De_Defuncion__c, difunto != null ? serv.ONE_Tipo_De_Lugar_De_Defuncion__c : null);
                    Boolean tipoLugarDefuncionError = ParserHelper.handleFieldLogging(
                        r.servicioId,
                        'Tipo de Lugar de Defunción',
                        dto.LUGAR_DEFUNCION,
                        res.LUGAR_DEFUNCION,
                        serv.ONE_Tipo_De_Lugar_De_Defuncion__c,
                        TIPODOC,
                        dto.LUGAR_DEFUNCION,
                        dto2.LUGAR_DEFUNCION
                    );
                    if (tipoLugarDefuncionError) {
                        errorsCount++;
                    }
                    hasError = hasError || tipoLugarDefuncionError;

                    Boolean riesgoError = ParserHelper.handleBooleanFieldLogging(
                        r.servicioId,
                        'Riesgo',
                        dto.RIESGO,
                        res.RIESGO,
                        serv.ONE_Riesgo__c,
                        TIPODOC,
                        dto.RIESGO,
                        dto2.RIESGO
                    );
                    if (riesgoError) {
                        errorsCount++;
                    }
                    hasError = hasError || riesgoError;

                    if (res.RIESGO == 'true') {
                        Boolean descripcionRiesgoError = ParserHelper.handleFieldLogging(
                            r.servicioId,
                            'Descripción de Riesgo',
                            dto.DESCRIPCION_RIESGO,
                            res.DESCRIPCION_RIESGO,
                            serv.ONE_Descripcion_De_Riesgo__c,
                            TIPODOC,
                            dto.DESCRIPCION_RIESGO,
                            dto2.DESCRIPCION_RIESGO
                        );
                        if (descripcionRiesgoError) {
                            errorsCount++;
                        }
                        hasError = hasError || descripcionRiesgoError;
                    }                   

                    if (res.INCINERACION_CONDICIONADA != '') {
                        Boolean incineracionCondicionadaError = ParserHelper.handleFieldLogging(
                            r.servicioId,
                            'Incineración Condicionada',
                            dto.INCINERACION_CONDICIONADA,
                            res.INCINERACION_CONDICIONADA,
                            serv.ONE_Incineraci_n_condicionada__c,
                            TIPODOC,
                            dto.INCINERACION_CONDICIONADA,
                            dto2.INCINERACION_CONDICIONADA
                        );
                        if (incineracionCondicionadaError) {
                            errorsCount++;
                        }
                        hasError = hasError || incineracionCondicionadaError;
                    }

                } catch (Exception e) {
                    // No interrumpir procesamiento por errores en logging/comparación
                }
            }
        res.NUMERO_ERRORES = errorsCount;
        return hasError;
    }
}
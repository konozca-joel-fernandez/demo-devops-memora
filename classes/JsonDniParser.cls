public with sharing class JsonDniParser {
    private static final String TIPODOC = 'DNI';



    public  class Request { 
    @InvocableVariable(required=true) 
    public String jsonPayload; 
    @InvocableVariable(required=true)
    public Id difuntoServicio;
    @InvocableVariable(required=true)
    public String tipoDoc;
}
    
    public class Response {
        @InvocableVariable(description='Nombre DNI')
        public String nombre;
        @InvocableVariable(description='PRIMER Y SEGUNDO APELLIDOS ')
        public String apellidos;
        @InvocableVariable(description='Fecha de Nacimiento DNI')
        public Date fechaDeNacimiento; 
        @InvocableVariable(description='Numero de Documento DNI')
        public String numeroDocumento;
        @InvocableVariable(description='Tipo de Documento')
        public String tipoDocumento;
        @InvocableVariable(description='SEXO')
        public String sexo;
        @InvocableVariable(description='NACIONALIDAD')
        public String nacionalidad;
        @InvocableVariable(description='DOMICILIO')
        public String domicilio;
        @InvocableVariable(description='MUNICIPIO')
        public String municipio;
        @InvocableVariable(description='PROVINCIA')
        public String provincia;
        @InvocableVariable(description='PAIS')
        public String pais;
        @InvocableVariable(description='PADRE')
        public String padre;
        @InvocableVariable(description='MADRE')
        public String madre;
        @InvocableVariable(description='LUGAR_NACIMIENTO')
        public String lugar_nacimiento;
        @InvocableVariable(description='PROVINCIA_NACIMIENTO')
        public String provincia_nacimiento;
        @InvocableVariable(description='HAS_ERRORS_LOGGING')
        public Boolean HAS_ERRORS_LOGGING;     
        @InvocableVariable(description='NUMERO_ERRORES')
        public INTEGER NUMERO_ERRORES;
    }


    private class PersonaDTO {
        public String NOMBRE;
        public String PRIMER_APELLIDO;
        public String SEGUNDO_APELLIDO;
        public String FECHA_DE_NACIMIENTO;
        public String NUMERO_DOCUMENTO;
        public String TIPO_DOCUMENTO;
        public String SEXO;
        public String NACIONALIDAD;
        public String LUGAR_NACIMIENTO;
    	public String PROVINCIA_NACIMIENTO;
        public String DOMICILIO;
        public String MUNICIPIO;
        public String PROVINCIA;
        public String NOMBREPADRE;
        public String NOMBREMADRE;
        public string PAIS;
    }

    @InvocableMethod(label='Parse JSON DNI' description='Parsea el JSON recibido como respuesta del LLM para poder modificar los campos en el flow')
    public static List<Response> parse(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request r : requests) {
            if (r.tipoDoc == 'DNI Difunto') {
                results.add(parseOne(r));
            }
            else if (r.tipoDoc == 'DNI Declarante') {
                //results.add(parseOne(r));
                results.add(parseDeclarante(r));
            }
        }
        return results;
    }

    // Core parser for a single payload
    private static Response parseOne(Request req) {
        Response res = new Response();
        String jsonPayload = (req != null ? req.jsonPayload : null);
        Id servicioId = (req != null ? req.difuntoServicio : null);
        String NOT_FOUND = '';
        Boolean hasError = false;
        Integer errorsCount = 0;

        res.nombre = NOT_FOUND;
        res.apellidos = NOT_FOUND;
        res.fechaDeNacimiento = null;
        res.numeroDocumento = NOT_FOUND;
        res.tipoDocumento = 'DNI';
        res.sexo = NOT_FOUND ;
        res.nacionalidad = NOT_FOUND;
        res.lugar_nacimiento = NOT_FOUND;
        res.provincia_nacimiento = NOT_FOUND;
        res.domicilio = NOT_FOUND;
        res.municipio = NOT_FOUND;
        res.provincia = NOT_FOUND;
        res.padre = NOT_FOUND;
        res.madre = NOT_FOUND;
        res.pais = NOT_FOUND;

        if (String.isBlank(jsonPayload)) {
            return res;
        }
        Account difunto = null;
        try {
            if (servicioId != null) {
                ONE_Expediente__c serv = [
                    SELECT Id, ONE_Difunto__c
                    FROM ONE_Expediente__c
                    WHERE Id = :servicioId
                    LIMIT 1
                ];
                difunto = [
                    SELECT Id,IsPersonAccount,FirstName,LastName,ONE_Direccion__pc,ONE_Fecha_de_nacimiento__pc,ONE_Lugar_de_nacimiento__pc,ONE_Municipio__pc,
                          ONE_N_Documento__pc,ONE_Nacionalidad__c,ONE_Nombre_De_La_Madre__c,ONE_Padres__c,ONE_Pais__pc,ONE_Provincia__pc ,ONE_Provincia_nacimiento__c,ONE_Sexo__c,ONE_Tipo_de_documento__pc
                    FROM Account
                    WHERE Id = :serv.ONE_Difunto__c
                    LIMIT 1
                ];

            }
        } catch (Exception e) {
            // Si no se puede recuperar el expediente o el difunto, continuamos sin comparación.
        }

        try {
            PersonaDTO dto = (PersonaDTO) JSON.deserialize(jsonPayload, PersonaDTO.class);

            // Nombre
            res.nombre = ParserHelper.normalize(dto != null ? dto.NOMBRE : null, NOT_FOUND);
            Boolean nameError = ParserHelper.handleFieldLogging(servicioId, 'Nombre', dto.NOMBRE, res.nombre, difunto != null ? (String) difunto.FirstName : null, TIPODOC);
            if (nameError) {
                errorsCount++;
            }
            hasError = hasError || nameError;

            // Apellidos (une primer + segundo, ajustando "Valor no encontrado")
            if ( dto.SEGUNDO_APELLIDO == 'Valor no encontrado') dto.SEGUNDO_APELLIDO = '';
            String dtoApe = dto != null ? (dto.PRIMER_APELLIDO + ' ' + dto.SEGUNDO_APELLIDO).trim() : null;
            res.apellidos = ParserHelper.normalize(dtoApe, NOT_FOUND);
            Boolean apellidosError = ParserHelper.handleFieldLogging(servicioId, 'Apellidos', dtoApe, res.apellidos, difunto != null ? (String) difunto.LastName : null, TIPODOC);
            if (apellidosError) {
                errorsCount++;
            }
            hasError = hasError || apellidosError;

            // Fecha Nacimiento
            String rawFecha = ParserHelper.normalize(dto != null ? dto.FECHA_DE_NACIMIENTO : null, NOT_FOUND);
            res.fechaDeNacimiento = ParserHelper.normalizeFecha(rawFecha, NOT_FOUND);
            Boolean fechaNacimientoError = ParserHelper.handleDateFieldLogging(servicioId, 'Fecha de Nacimiento',dto.FECHA_DE_NACIMIENTO, res.fechaDeNacimiento, difunto != null ? (Date) difunto.ONE_Fecha_de_nacimiento__pc : null, TIPODOC);
            if (fechaNacimientoError) {
                errorsCount++;
            }
            hasError = hasError || fechaNacimientoError;

            // Número Documento
            res.numeroDocumento = ParserHelper.normalize(dto != null ? dto.NUMERO_DOCUMENTO : null, NOT_FOUND);
            Boolean numeroDocError = ParserHelper.handleFieldLogging(servicioId, 'Número de Documento', dto.NUMERO_DOCUMENTO, res.numeroDocumento, difunto != null ? (String) difunto.ONE_N_Documento__pc : null, TIPODOC);
            if (numeroDocError) {
                errorsCount++;
            }
            hasError = hasError || numeroDocError;

            // Tipo Documento   
            /*res.tipoDocumento = ParserHelper.normalize(dto != null ? dto.TIPO_DOCUMENTO : null, 'DNI');
            String tipoDocLabel = ParserHelper.getPicklistLabel(Account.ONE_Tipo_de_documento__pc, difunto != null ? difunto.ONE_Nacionalidad__c : null);
            hasError = hasError || ParserHelper.handleFieldLogging(servicioId, 'Tipo de Documento', dto.TIPO_DOCUMENTO, res.tipoDocumento,  difunto.ONE_Tipo_de_documento__pc, TIPODOC);*/

            // Sexo
            res.sexo = ParserHelper.normalize(dto != null ? dto.SEXO : null, NOT_FOUND);
            Boolean sexoError = ParserHelper.handleFieldLogging(servicioId, 'Sexo', dto.SEXO, res.sexo, difunto != null ? (String) difunto.ONE_Sexo__c : null, TIPODOC);
            if (sexoError) {
                errorsCount++;
            }
            hasError = hasError || sexoError;

            // Nacionalidad
            if (dto.NACIONALIDAD.toLowerCase().startsWith('esp')) dto.NACIONALIDAD = 'España';
            String nacionalidadRaw = ParserHelper.normalize(dto != null ? dto.NACIONALIDAD : null, NOT_FOUND);
            res.nacionalidad = ParserHelper.validateNacionalidadAgainstPicklist(nacionalidadRaw, NOT_FOUND);
            String nacionalidadLabel = ParserHelper.getPicklistLabel(Account.ONE_Nacionalidad__c, difunto != null ? difunto.ONE_Nacionalidad__c : null);
            Boolean nacionalidadError = ParserHelper.handleFieldLogging(servicioId, 'Nacionalidad', dto != null ? nacionalidadRaw : null, res.nacionalidad, nacionalidadLabel, TIPODOC);
            if (nacionalidadError) {
                errorsCount++;
            }
            hasError = hasError || nacionalidadError;

            // Domicilio
            res.domicilio = ParserHelper.normalize(dto != null ? dto.DOMICILIO : null, NOT_FOUND);
            Boolean domicilioError = ParserHelper.handleFieldLogging(servicioId, 'Domicilio', dto.DOMICILIO, res.domicilio, difunto != null ? difunto.ONE_Direccion__pc : null, TIPODOC);
            if (domicilioError) {
                errorsCount++;
            }
            hasError = hasError || domicilioError;

            // Municipio
            res.municipio = ParserHelper.normalize(dto != null ? dto.MUNICIPIO : null, NOT_FOUND);
            Boolean municipioError = ParserHelper.handleFieldLogging(servicioId, 'Municipio', dto.MUNICIPIO, res.municipio, difunto != null ? difunto.ONE_Municipio__pc : null, TIPODOC);
            if (municipioError) {
                errorsCount++;
            }
            hasError = hasError || municipioError;

            // Provincia (valida contra picklist Contact.ONE_Provincia__pc para mapear a valor estándar)
            String provinciaRaw = ParserHelper.normalize(dto != null ? dto.PROVINCIA : null, NOT_FOUND);
            provinciaRaw = ParserHelper.validateProvinciaAgainstPicklist(provinciaRaw, NOT_FOUND);
            res.provincia = provinciaRaw;
            String provinciaLabel = ParserHelper.getPicklistLabel(Account.ONE_Provincia__pc, difunto != null ? difunto.ONE_Provincia__pc : null);
            Boolean provinciaError = ParserHelper.handleFieldLogging(servicioId, 'Provincia', dto != null ? dto.PROVINCIA : null, res.provincia, provinciaLabel, TIPODOC);
            if (provinciaError) {
                errorsCount++;
            }
            hasError = hasError || provinciaError;

            // Provincia de nacimiento
            String provinciaNacimientoRaw = ParserHelper.normalize(dto != null ? dto.PROVINCIA_NACIMIENTO : null, NOT_FOUND);
            provinciaNacimientoRaw = ParserHelper.validateProvinciaAgainstPicklist(provinciaNacimientoRaw, NOT_FOUND);
            res.provincia_nacimiento = provinciaNacimientoRaw;
            String privinciaNacLabel = ParserHelper.getPicklistLabel(Account.ONE_Provincia_nacimiento__c, difunto != null ? difunto.ONE_Provincia_nacimiento__c : null);
            Boolean provinciaNacError = ParserHelper.handleFieldLogging(servicioId, 'Provincia de Nacimiento', dto != null ? dto.PROVINCIA_NACIMIENTO : null, res.provincia_nacimiento, privinciaNacLabel, TIPODOC);
            if (provinciaNacError) {
                errorsCount++;
            }
            hasError = hasError || provinciaNacError;

            // País
            if (dto.PAIS.toLowerCase().startsWith('esp')) dto.PAIS = 'España';
            String paisRaw = ParserHelper.normalize(dto != null ? dto.PAIS : null, NOT_FOUND);
            res.pais = ParserHelper.validateNacionalidadAgainstPicklist(dto != null ? dto.PAIS : null, NOT_FOUND);
            String paisLabel = ParserHelper.getPicklistLabel(Account.ONE_Pais__pc, difunto != null ? difunto.ONE_Pais__pc : null);
            Boolean paisError = ParserHelper.handleFieldLogging(servicioId, 'País', dto != null ? dto.PAIS : null, res.pais, paisLabel, TIPODOC);
            if (paisError) {
                errorsCount++;
            }
            hasError = hasError || paisError; 

            // Lugar nacimiento
            res.lugar_nacimiento = ParserHelper.normalize(dto != null ? dto.LUGAR_NACIMIENTO : null, NOT_FOUND);
            Boolean lugarNacError = ParserHelper.handleFieldLogging(servicioId, 'Lugar de Nacimiento', dto.LUGAR_NACIMIENTO, res.lugar_nacimiento, difunto != null ? difunto.ONE_Lugar_de_nacimiento__pc : null, TIPODOC);
            if (lugarNacError) {
                errorsCount++;
            }
            hasError = hasError || lugarNacError;

            // Padre
            res.padre = ParserHelper.normalize(dto != null ? dto.NOMBREPADRE : null, NOT_FOUND);
            Boolean padreError = ParserHelper.handleFieldLogging(servicioId, 'Padre', dto.NOMBREPADRE, res.padre, difunto != null ? difunto.ONE_Padres__c : null, TIPODOC);
            if (padreError) {
                errorsCount++;
            }
            hasError = hasError || padreError;

            // Madre
            res.madre = ParserHelper.normalize(dto != null ? dto.NOMBREMADRE : null, NOT_FOUND);
            Boolean madreError = ParserHelper.handleFieldLogging(servicioId, 'Madre', dto.NOMBREMADRE, res.madre, difunto != null ? difunto.ONE_Nombre_De_La_Madre__c : null, TIPODOC);
            if (madreError) {
                errorsCount++;
            }
            hasError = hasError || madreError;

        } catch (Exception e) {
            
        }

        res.HAS_ERRORS_LOGGING = hasError;
        res.NUMERO_ERRORES = errorsCount;

        return res;
    }

    private static Response parseDeclarante(Request req) {
        Response res = new Response();
        String jsonPayload = (req != null ? req.jsonPayload : null);
        Id servicioId = (req != null ? req.difuntoServicio : null);
        String NOT_FOUND = '';
        Boolean hasError = false;
        Integer errorsCount = 0;

        res.nombre = NOT_FOUND;
        res.apellidos = NOT_FOUND;
        res.fechaDeNacimiento = null;
        res.numeroDocumento = NOT_FOUND;
        res.tipoDocumento = 'DNI';
        res.sexo = NOT_FOUND ;
        res.nacionalidad = NOT_FOUND;
        res.lugar_nacimiento = NOT_FOUND;
        res.provincia_nacimiento = NOT_FOUND;
        res.domicilio = NOT_FOUND;
        res.municipio = NOT_FOUND;
        res.provincia = NOT_FOUND;
        res.padre = NOT_FOUND;
        res.madre = NOT_FOUND;
        res.pais = NOT_FOUND;

        if (String.isBlank(jsonPayload)) {
            return res;
        }
        Account declarante = null;
        PersonaDTO dto = (PersonaDTO) JSON.deserialize(jsonPayload, PersonaDTO.class);
        String numDoc = ParserHelper.normalize(dto != null ? dto.NUMERO_DOCUMENTO : null, NOT_FOUND);

        try {
            if (servicioId != null) {
                declarante = [
                    SELECT Id,IsPersonAccount,FirstName,LastName,ONE_Direccion__pc,ONE_Fecha_de_nacimiento__pc,ONE_Lugar_de_nacimiento__pc,ONE_Municipio__pc,
                          ONE_N_Documento__pc,ONE_Nacionalidad__c,ONE_Nombre_De_La_Madre__c,ONE_Padres__c,ONE_Pais__pc,ONE_Provincia__pc ,ONE_Provincia_nacimiento__c,ONE_Sexo__c,ONE_Tipo_de_documento__pc
                    FROM Account
                    WHERE ONE_N_Documento__pc = :numDoc
                    LIMIT 1
                ];
            }
        } catch (Exception e) {
            // Si no se puede recuperar el declarante, continuamos sin comparación.
        }

        try {
            // Nombre
            res.nombre = ParserHelper.normalize(dto != null ? dto.NOMBRE : null, NOT_FOUND);
            Boolean nameError = ParserHelper.handleFieldLogging(servicioId, 'Nombre', dto.NOMBRE, res.nombre, declarante != null ? (String) declarante.FirstName : null, TIPODOC);
            if (nameError) {
                errorsCount++;
            }
            hasError = hasError || nameError;

            // Apellidos (une primer + segundo, ajustando "Valor no encontrado")
            if ( dto.SEGUNDO_APELLIDO == 'Valor no encontrado') dto.SEGUNDO_APELLIDO = '';
            String dtoApe = dto != null ? (dto.PRIMER_APELLIDO + ' ' + dto.SEGUNDO_APELLIDO).trim() : null;
            res.apellidos = ParserHelper.normalize(dtoApe, NOT_FOUND);
            Boolean apellidosError = ParserHelper.handleFieldLogging(servicioId, 'Apellidos', dtoApe, res.apellidos, declarante != null ? (String) declarante.LastName : null, TIPODOC);
            if (apellidosError) {
                errorsCount++;
            }
            hasError = hasError || apellidosError;

            // Fecha Nacimiento
            String rawFecha = ParserHelper.normalize(dto != null ? dto.FECHA_DE_NACIMIENTO : null, NOT_FOUND);
            res.fechaDeNacimiento = ParserHelper.normalizeFecha(rawFecha, NOT_FOUND);
            Boolean fechaNacimientoError = ParserHelper.handleDateFieldLogging(servicioId, 'Fecha de Nacimiento',dto.FECHA_DE_NACIMIENTO, res.fechaDeNacimiento, declarante != null ? (Date) declarante.ONE_Fecha_de_nacimiento__pc : null, TIPODOC);
            if (fechaNacimientoError) {
                errorsCount++;
            }
            hasError = hasError || fechaNacimientoError;

            // Número Documento
            res.numeroDocumento = ParserHelper.normalize(dto != null ? dto.NUMERO_DOCUMENTO : null, NOT_FOUND);

            // Sexo
            res.sexo = ParserHelper.normalize(dto != null ? dto.SEXO : null, NOT_FOUND);
            Boolean sexoError = ParserHelper.handleFieldLogging(servicioId, 'Sexo', dto.SEXO, res.sexo, declarante != null ? (String) declarante.ONE_Sexo__c : null, TIPODOC);
            if (sexoError) {
                errorsCount++;
            }
            hasError = hasError || sexoError;

            // Nacionalidad
            if (dto.NACIONALIDAD.toLowerCase().startsWith('esp')) dto.NACIONALIDAD = 'España';
            String nacionalidadRaw = ParserHelper.normalize(dto != null ? dto.NACIONALIDAD : null, NOT_FOUND);
            res.nacionalidad = ParserHelper.validateNacionalidadAgainstPicklist(nacionalidadRaw, NOT_FOUND);
            String nacionalidadLabel = ParserHelper.getPicklistLabel(Account.ONE_Nacionalidad__c, declarante != null ? declarante.ONE_Nacionalidad__c : null);
            Boolean nacionalidadError = ParserHelper.handleFieldLogging(servicioId, 'Nacionalidad', dto != null ? nacionalidadRaw : null, res.nacionalidad, nacionalidadLabel, TIPODOC);
            if (nacionalidadError) {
                errorsCount++;
            }
            hasError = hasError || nacionalidadError;

            // Domicilio
            res.domicilio = ParserHelper.normalize(dto != null ? dto.DOMICILIO : null, NOT_FOUND);
            Boolean domicilioError = ParserHelper.handleFieldLogging(servicioId, 'Domicilio', dto.DOMICILIO, res.domicilio, declarante != null ? declarante.ONE_Direccion__pc : null, TIPODOC);
            if (domicilioError) {
                errorsCount++;
            }
            hasError = hasError || domicilioError;

            // Municipio
            res.municipio = ParserHelper.normalize(dto != null ? dto.MUNICIPIO : null, NOT_FOUND);
            Boolean municipioError = ParserHelper.handleFieldLogging(servicioId, 'Municipio', dto.MUNICIPIO, res.municipio, declarante != null ? declarante.ONE_Municipio__pc : null, TIPODOC);
            if (municipioError) {
                errorsCount++;
            }
            hasError = hasError || municipioError;

            // Provincia (valida contra picklist Contact.ONE_Provincia__pc para mapear a valor estándar)
            String provinciaRaw = ParserHelper.normalize(dto != null ? dto.PROVINCIA : null, NOT_FOUND);
            provinciaRaw = ParserHelper.validateProvinciaAgainstPicklist(provinciaRaw, NOT_FOUND);
            res.provincia = provinciaRaw;
            String provinciaLabel = ParserHelper.getPicklistLabel(Account.ONE_Provincia__pc, declarante != null ? declarante.ONE_Provincia__pc : null);
            Boolean provinciaError = ParserHelper.handleFieldLogging(servicioId, 'Provincia', dto != null ? dto.PROVINCIA : null, res.provincia, provinciaLabel, TIPODOC);
            if (provinciaError) {
                errorsCount++;
            }
            hasError = hasError || provinciaError;

            // Provincia de nacimiento
            String provinciaNacimientoRaw = ParserHelper.normalize(dto != null ? dto.PROVINCIA_NACIMIENTO : null, NOT_FOUND);
            provinciaNacimientoRaw = ParserHelper.validateProvinciaAgainstPicklist(provinciaNacimientoRaw, NOT_FOUND);
            res.provincia_nacimiento = provinciaNacimientoRaw;
            String privinciaNacLabel = ParserHelper.getPicklistLabel(Account.ONE_Provincia_nacimiento__c, declarante != null ? declarante.ONE_Provincia_nacimiento__c : null);
            Boolean provinciaNacError = ParserHelper.handleFieldLogging(servicioId, 'Provincia de Nacimiento', dto != null ? dto.PROVINCIA_NACIMIENTO : null, res.provincia_nacimiento, privinciaNacLabel, TIPODOC);
            if (provinciaNacError) {
                errorsCount++;
            }
            hasError = hasError || provinciaNacError;

            // País
            if (dto.PAIS.toLowerCase().startsWith('esp')) dto.PAIS = 'España';
            String paisRaw = ParserHelper.normalize(dto != null ? dto.PAIS : null, NOT_FOUND);
            res.pais = ParserHelper.validateNacionalidadAgainstPicklist(dto != null ? dto.PAIS : null, NOT_FOUND);
            String paisLabel = ParserHelper.getPicklistLabel(Account.ONE_Pais__pc, declarante != null ? declarante.ONE_Pais__pc : null);
            Boolean paisError = ParserHelper.handleFieldLogging(servicioId, 'País', dto != null ? dto.PAIS : null, res.pais, paisLabel, TIPODOC);
            if (paisError) {
                errorsCount++;
            }
            hasError = hasError || paisError; 

            // Lugar nacimiento
            res.lugar_nacimiento = ParserHelper.normalize(dto != null ? dto.LUGAR_NACIMIENTO : null, NOT_FOUND);
            Boolean lugarNacError = ParserHelper.handleFieldLogging(servicioId, 'Lugar de Nacimiento', dto.LUGAR_NACIMIENTO, res.lugar_nacimiento, declarante != null ? declarante.ONE_Lugar_de_nacimiento__pc : null, TIPODOC);
            if (lugarNacError) {
                errorsCount++;
            }
            hasError = hasError || lugarNacError;

            // Padre
            res.padre = ParserHelper.normalize(dto != null ? dto.NOMBREPADRE : null, NOT_FOUND);
            Boolean padreError = ParserHelper.handleFieldLogging(servicioId, 'Padre', dto.NOMBREPADRE, res.padre, declarante != null ? declarante.ONE_Padres__c : null, TIPODOC);
            if (padreError) {
                errorsCount++;
            }
            hasError = hasError || padreError;

            // Madre
            res.madre = ParserHelper.normalize(dto != null ? dto.NOMBREMADRE : null, NOT_FOUND);
            Boolean madreError = ParserHelper.handleFieldLogging(servicioId, 'Madre', dto.NOMBREMADRE, res.madre, declarante != null ? declarante.ONE_Nombre_De_La_Madre__c : null, TIPODOC);
            if (madreError) {
                errorsCount++;
            }
            hasError = hasError || madreError;

        } catch (Exception e) {
            
        }

        res.HAS_ERRORS_LOGGING = hasError;
        res.NUMERO_ERRORES = errorsCount;

        return res;
    }


    

}
/**
 * Created by mkuzak001 on 01.03.2021.
 */

public with sharing class ONE_OpenLifeClaimIntegrationService {
    private static String F_TIPOLOGY = 'F';
    private static String DESCRIPTION_NO_INFORMADO = 'No informado';
    @TestVisible
    private static String CODE_ERROR_SUCCESS = '000';

    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        FlowInputs input = flowInputs.get(0);
        Id casoId = input.casoId;
        ONE_InsuranceIntegrationCallout.InsuranceCallout callout;
        if (input.service.equalsIgnoreCase('kutxabank')) {
            KutxabankWrapper kbsWrapper = prepareKBSWrapper(casoId);
            if(input.batchKBS == true){
                callout = new ONE_OpenLifeClaimIntegrationCallout.KutxabankCalloutBatch(kbsWrapper);
            }
            else{
                callout = new ONE_OpenLifeClaimIntegrationCallout.KutxabankCallout(kbsWrapper);
            }
            HttpResponse resp = callout.invokeCallout();
            return parseResponseKBS(resp);
        }
        else {
            RequestWrapper requestWrapper = prepareRequestWrapper(casoId);
            if (input.service.equalsIgnoreCase('generali')) {
                callout = new ONE_OpenLifeClaimIntegrationCallout.GeneraliCallout(requestWrapper);
            } else if (input.service.equalsIgnoreCase('cajamar')) {
                callout = new ONE_OpenLifeClaimIntegrationCallout.CajamarCallout(requestWrapper);
            }
            HttpResponse resp = callout.invokeCallout();
            return parseResponse(resp);
        }
    }

    private static List<FlowOutputs> parseResponse(HttpResponse resp) {
        FlowOutputs fo = new FlowOutputs();

        if (resp.getStatusCode() == ONE_CommonConstants.HTPP_SUCCESS_CODE) {
            ResponseWrapper response = (ResponseWrapper) JSON.deserialize(resp.getBody(), ResponseWrapper.class);
            System.debug(response);
            if (response.codeError == CODE_ERROR_SUCCESS && response.claim != null) {
                fo.success = true;

                ClaimWrapper claim = response.claim;
                fo.returnValue = String.format('{0}{1}{2}{3}{4}', new List<String>{
                    claim.cia, claim.branch, claim.year, claim.policy, claim.controlDigit
                });

            } else {
                fo.success = false;
                System.debug(LoggingLevel.ERROR, response.codeError + ' ' + response.errorMessages);
            }
        } else {
            fo.success = false;
            System.debug(LoggingLevel.ERROR, resp.getBody());
        }

        return new List<FlowOutputs>{
            fo
        };
    }

    public static List<FlowOutputs> parseResponseKBS(HttpResponse resp) {

        FlowOutputs fo = new FlowOutputs();

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        Map<String, Object> resultado = (Map<String, Object>) parsed.get('resultado');
        if (resp.getStatusCode() == 201 || resp.getStatusCode() == 202) {
            fo.success = true;
            fo.returnValue = (String) resultado.get('Expediente');
        } else if (resp.getStatusCode() == 503) {
            fo.success = false;
            fo.returnValue = 'El servicio no está disponible en este momento por restricción horaria. Se reintentará automáticamente.';
            fo.errorCode = 503;
        } else if (resp.getStatusCode() == 500) {
            fo.success = false;
            fo.returnValue = 'Error interno del servidor. Por favor, contacte con soporte.';
        } else {
            fo.success = false;
            String message = (String) resultado.get('Message');
            String details;
            Map<String, Object> detailsMap = (Map<String, Object>) resultado.get('Details');
            if (detailsMap != null) {
                for (String key : detailsMap.keySet()) {
                    List<Object> msgs = (List<Object>) detailsMap.get(key);
                    for (Object msg : msgs) {
                        details += key + ': ' + (String) msg + '\n';
                    }
                }
            }
            fo.returnValue =  message + (details != null ? '\n' + details : '');
            System.debug(LoggingLevel.ERROR, 'Error: ' + resp.getBody());
        }

        return new List<FlowOutputs>{
            fo
        };
    }

    public class FlowInputs {
        @InvocableVariable
        public String casoId;
        @InvocableVariable
        public String service;
        @InvocableVariable
        public Boolean batchKBS;
    }

    public class FlowOutputs {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String returnValue;
        @InvocableVariable
        public Integer errorCode;
    }

    public static RequestWrapper prepareRequestWrapper(Id casoId) {
        RequestWrapper requestWrapper;

        ONE_Caso__c caso = selectCaso(casoId);

        return prepareRequestWrapper(caso);
    }

    private static RequestWrapper prepareRequestWrapper(ONE_Caso__c caso) {
        RequestWrapper requestWrapper = new RequestWrapper();

        requestWrapper.policy = preparePolicyWrapper(caso);
        requestWrapper.occurrenceDate = prepareOccurrenceDateWrapper(caso);
        requestWrapper.data = prepareDataWrapper(caso);

        return requestWrapper;
    }

    private static PolicyWrapper preparePolicyWrapper(ONE_Caso__c caso) {
        PolicyWrapper policyWrapper = new PolicyWrapper();

        policyWrapper.policy = caso.ONE_Contrato__r?.ONE_Pol__c;
        policyWrapper.cia = caso.ONE_Contrato__r?.ONE_Compania_Aseguradora__c;
        policyWrapper.branch = caso.ONE_Contrato__r?.ONE_Ramo__c;

        return policyWrapper;
    }

    private static OccurrenceDateWrapper prepareOccurrenceDateWrapper(ONE_Caso__c caso) {
        OccurrenceDateWrapper occurrenceDateWrapper = new OccurrenceDateWrapper();

        DateTime fechaDeDefuncion = caso.ONE_Fecha_De_Defuncion__c;
        if (fechaDeDefuncion != null) {
            occurrenceDateWrapper.day = String.valueOf(fechaDeDefuncion.day());
            occurrenceDateWrapper.month = String.valueOf(fechaDeDefuncion.month());
            occurrenceDateWrapper.year = String.valueOf(fechaDeDefuncion.year());
            occurrenceDateWrapper.hour = String.valueOf(fechaDeDefuncion.hour());
            occurrenceDateWrapper.minute = String.valueOf(fechaDeDefuncion.minute());
        }

        return occurrenceDateWrapper;
    }

    private static DataWrapper prepareDataWrapper(ONE_Caso__c caso) {
        DataWrapper dataWrapper = new DataWrapper();

        dataWrapper.providerReference = caso.Id;
        dataWrapper.tipology = F_TIPOLOGY;
        dataWrapper.occurrencePlace = caso.ONE_Direccion_De_Defuncion__c + ', ' + caso.ONE_Provincia_De_Defuncion__c + ', '
            + caso.ONE_Codigo_Postal_De_Defuncion__c + ', ' + caso.ONE_Pais_De_Defuncion__c;
        dataWrapper.insuredIdentityCard = caso.ONE_Numero_De_Documento__c;
        dataWrapper.description = (caso.ONE_Observaciones__c != null) ? caso.ONE_Observaciones__c : DESCRIPTION_NO_INFORMADO;
        dataWrapper.damages = caso.ONE_Causas_Defuncion__c;
        dataWrapper.contactName = caso.ONE_Nombre_De_La_Persona_De_Contacto__c;
        dataWrapper.contactRelationship = caso.ONE_Relacion_Con_El_Difunto__c;

        return dataWrapper;
    }

    public static KutxabankWrapper prepareKBSWrapper(Id casoId) {
        ONE_Caso__c caso = selectCasoKBS(casoId);
        KutxabankWrapper wrapper = new KutxabankWrapper();

        wrapper.NumeroReferenciaProveedor = caso.Name;
        wrapper.TipoSiniestro = '1';
        wrapper.NumeroPoliza = caso.ONE_Numero_De_Poliza__c != null ? caso.ONE_Numero_De_Poliza__c.replaceAll('[^0-9]', '') : caso.ONE_Numero_De_Poliza_texto__c != null ? caso.ONE_Numero_De_Poliza_texto__c.replaceAll('[^0-9]', '') : '';
        wrapper.FechaDeclaracion = caso.CreatedDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        wrapper.FechaFallecimiento = caso.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c != null ? caso.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.format('yyyy-MM-dd\'T\'00:00:00\'Z\'') : '';
        wrapper.HoraOcurrencia = caso.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c != null ? caso.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.format('HH:mm') : '';
        wrapper.LocalidadOcurrencia = caso.ONE_Municipio_de_Defuncion__c != null ? caso.ONE_Municipio_de_Defuncion__c : caso.ONE_Lugar_De_Defuncion02__r.ONE_Municipio_Direccion__c != null ? caso.ONE_Lugar_De_Defuncion02__r.ONE_Municipio_Direccion__c : caso.ONE_Lugar_De_Defuncion02__r.ONE_Municipio__r.Name != null ? caso.ONE_Lugar_De_Defuncion02__r.ONE_Municipio__r.Name : caso.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c != null ? caso.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c : caso.ONE_Lugar_De_Defuncion__r.ONE_Municipio__r.Name != null ? caso.ONE_Lugar_De_Defuncion__r.ONE_Municipio__r.Name : '';
        // wrapper.LocalidadOrigen = caso.ONE_Tipo_De_Servicio__c == 'Traslado' ? POR FINALIZAR
        // wrapper.LocalidadDestino = caso.ONE_Tipo_De_Servicio__c == 'Traslado' ? POR FINALIZAR
        wrapper.Traslado = caso.ONE_Tipo_De_Servicio__c == 'Traslado' ? 'S' : 'N';
        wrapper.TipoTraslado = caso.ONE_Tipo_De_Servicio__c == 'Traslado' ? caso.ONE_Tipo_Traslado__c != null ? caso.ONE_Tipo_Traslado__c : '' : '';
        wrapper.AcompananteTraslado = caso.ONE_Tipo_De_Servicio__c == 'Traslado' ? 'N' : '';
        wrapper.Comentarios = '';
        wrapper.DeclaranteNombre = caso.ONE_Nombre_De_La_Persona_De_Contacto__c != null ? caso.ONE_Nombre_De_La_Persona_De_Contacto__c + ' - Parentesco: ' + caso.ONE_Relacion_Con_El_Difunto__c : '';
        wrapper.DeclaranteTelefono1 = caso.ONE_Telefono_De_La_Persona_De_Contacto__c != null ? caso.ONE_Telefono_De_La_Persona_De_Contacto__c.replace(' ', '').replace('.','') : '';

        return wrapper;
    }

    private static ONE_Caso__c selectCasoKBS(String casoId) {
        return [
            SELECT Name, ONE_Numero_De_Poliza__c, CreatedDate, ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c, ONE_Relacion_Con_El_Difunto__c,
                ONE_Municipio_de_Defuncion__c, ONE_Lugar_De_Defuncion02__r.ONE_Municipio_Direccion__c, ONE_Lugar_De_Defuncion02__r.ONE_Municipio__r.Name,
                ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c, ONE_Lugar_De_Defuncion__r.ONE_Municipio__r.Name, ONE_Tipo_De_Servicio__c,
                ONE_Nombre_De_La_Persona_De_Contacto__c, ONE_Telefono_De_La_Persona_De_Contacto__c, ONE_Tipo_Traslado__c, ONE_Numero_De_Poliza_texto__c
            FROM ONE_Caso__c
            WHERE Id = :casoId
        ];
    }

    private static ONE_Caso__c selectCaso(Id casoId) {
        return [
            SELECT Id, ONE_Contrato__r.ONE_Pol__c, ONE_Contrato__r.ONE_Compania_Aseguradora__c, ONE_Contrato__r.ONE_Ramo__c,
                ONE_Fecha_De_Defuncion__c, ONE_Direccion_De_Defuncion__c, toLabel(ONE_Provincia_De_Defuncion__c), ONE_Codigo_Postal_De_Defuncion__c,
                toLabel(ONE_Pais_De_Defuncion__c), ONE_Numero_De_Documento__c, ONE_Observaciones__c, toLabel(ONE_Causas_Defuncion__c),
                ONE_Nombre_De_La_Persona_De_Contacto__c, ONE_Relacion_Con_El_Difunto__c
            FROM ONE_Caso__c
            WHERE Id = :casoId
        ];
    }

    public class KutxabankWrapper {
        public String NumeroReferenciaProveedor;
        public String TipoSiniestro;
        public String NumeroPoliza;
        public String FechaDeclaracion;
        public String FechaFallecimiento;
        public String HoraOcurrencia;
        //public String ServicioSolicitado;
        public String LocalidadOcurrencia;
        public String LocalidadOrigen;
        public String LocalidadDestino;
        public String Traslado;
        public String TipoTraslado;
        public String AcompananteTraslado;
        public String Comentarios;
        public String DeclaranteNombre;
        public String DeclaranteTelefono1;
        // public String DeclaranteTelefono2;
        // public String DeclaranteTelefono3;
        // public String PersonaContactoNombre;
        // public String PersonaContactoTelefono1;
        // public String PersonaContactoTelefono2;
        // public String PersonaContactoTelefono3;
        public Boolean DeactivateLogs;
    }

    public class RequestWrapper {
        public PolicyWrapper policy;
        public OccurrenceDateWrapper occurrenceDate;
        public DataWrapper data;
    }

    public class PolicyWrapper {
        public String cia;
        public String branch;
        public String policy;
    }

    public class OccurrenceDateWrapper {
        public String day;
        public String month;
        public String year;
        public String hour;
        public String minute;
    }

    public class DataWrapper {
        public String tipology;
        public String occurrencePlace;
        public String insuredIdentityCard;
        public String description;
        public String damages;
        public String contactName;
        public String contactRelationship;
        public String providerReference;
    }

    public class ResponseWrapper {
        public String codeError;
        public ClaimWrapper claim;
        public String[] errorMessages;
    }

    public class ClaimWrapper {
        public String cia;
        public String branch;
        public String year;
        public String policy;
        public String controlDigit;
    }
}
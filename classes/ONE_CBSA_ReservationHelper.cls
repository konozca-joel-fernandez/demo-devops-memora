public with sharing class ONE_CBSA_ReservationHelper {
    
    public static final String DEFAULT_IDENTIFICATION = '998';
    public static final String DEFAULT_USERNAME = 'sfb-sa';
    static final String MALE_SEX = 'Hombre', MALE_SEX_SHORT = 'M';
    static final String FEMALE_SEX = 'Mujer', FEMALE_SEX_SHORT = 'F';
    static final String UNDETERMINED_SEX = 'Indefinido', UNDETERMINED_SEX_SHORT = 'I';
    static final String TYPE_OF_DECEASED_DIFUNTO_LETTER = 'D';
    static final String EMPTY_VALUE = '';
    @TestVisible
    static String DEFAULT_INHUMATION_SITE = 'Externo', DEFAULT_INCINERATION_SITE = 'Externo';
    
    public static String buildRequest(CBSARequest request){
        ONE_Expediente__c service = [SELECT ONE_Codigo_Difunto_CBSA__c, ONE_Difunto__r.FirstName, ONE_Difunto__r.LastName, ONE_Difunto__r.ONE_Sexo__c, 
                                        ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc, ONE_Difunto__r.ONE_Provincia__pc, ONE_Difunto__r.Phone,
                                        ONE_Causas_Defuncion__c, ONE_Fecha_De_Defuncion__c, ONE_Estado_Del_Difunto__c, ONE_Tipo_De_Servicio_CB__c,
                                        ONE_Inicio_Incineracion__c, ONE_Difunto__r.ONE_Tipo_de_documento__pc, ONE_Difunto__r.ONE_N_Documento__pc,
                                        ONE_Difunto__r.ONE_Nacionalidad__c, ONE_Difunto__r.ONE_Pais__pc, ONE_Judicial__c, ONE_Asistencia_Familia_CBSA__c,
                                        ONE_Difunto__r.ONE_Calle__pc, ONE_Difunto__r.ONE_BIS__pc, ONE_Difunto__r.ONE_Escalera_Calle__pc, ONE_Difunto__r.ONE_Piso_Calle__pc,
                                        ONE_Difunto__r.ONE_Puerta_Calle__pc, ONE_Difunto__r.ONE_Municipio__pc, ONE_Difunto__r.ONE_Codigo_Postal__pc,
                                        ONE_Difunto__r.ONE_Email__c, ONE_Hora_destino_final__c, ONE_Difunto__r.ONE_Numero_Calle__pc, ONE_Lugar_Incineracion__r.ONE_Codigo_Cementerio_CB__c,
                                        ONE_Fecha_Inicio_Incineracion__c, ONE_Incineracion__c, ONE_Cementerio__c, ONE_Tipo_De_Difunto__c
                                        FROM ONE_Expediente__c WHERE Id = :request.serviceId];
        CBSAJSONRequest JSONrequest = new CBSAJSONRequest(service, request);
        return JSON.serialize(JSONrequest);
    }

    public static CBSAResponse parseResponseAndUpdate(String json, Id serviceId){
        CBSAJSONResponse jsonResponse = (CBSAJSONResponse) System.JSON.deserialize(json, CBSAJSONResponse.class);
        CBSAResponse response = new CBSAResponse();
        if (jsonResponse.rctipsol == 'I' && jsonResponse.rcceminh == null){
            if (jsonResponse.rchorincdis != null){
                response.availableHours = new List<String>();
                for (HorarioIncineracion horario : jsonResponse.rchorincdis){
                    response.availableHours.add(horario.horincdis);
                }
            }
            else{
                response.selectedHour = jsonResponse.rchorinc;
            }
            response.selectedDate = jsonResponse.rcdatinc;
        }
        else{
            if (jsonResponse.rchorinhdis != null){
                response.availableHours = new List<String>();
                for (HorarioInhumacion horario : jsonResponse.rchorinhdis){
                    response.availableHours.add(horario.horinhdis);
                }
            }
            else{
                response.selectedHour = jsonResponse.rchorinh;
            }
            response.selectedDate = jsonResponse.rcdatinh;
        }
        if (jsonResponse.rcestado != 'E') updateService(jsonResponse, serviceId);
        response.responseCode = jsonResponse.rcestado;
        response.responseMessage = jsonResponse.missatges;
        return response;
    }

    private static void updateService(CBSAJSONResponse jsonResponse, Id serviceId){
        ONE_Expediente__c service = new ONE_Expediente__c();
        service.Id = serviceId;
        service.ONE_Llamada_CBSA_Realizada__c = true;
        if(jsonResponse.rctipsol == 'E'){
            service.ONE_Codigo_Difunto_CBSA__c = jsonResponse.rcdifunt;
            service.ONE_Destino_Final__c = ONE_AccountSelector.selectAccount(jsonResponse.rcceminh).Id;
            service.ONE_Tipo_De_Lugar_Destino_Final__c = DEFAULT_INHUMATION_SITE;
            service.ONE_Cementerio__c = true;
        }
        else if (jsonResponse.rctipsol == 'I'){
            service.ONE_Codigo_Difunto_CBSA__c = jsonResponse.rcdifunt;
            if (jsonResponse.rcdatinh != null){
                service.ONE_Destino_Final__c = ONE_AccountSelector.selectAccount(jsonResponse.rcceminh).Id;
                service.ONE_Tipo_De_Lugar_Destino_Final__c = DEFAULT_INHUMATION_SITE;
                service.ONE_Cementerio__c = true;
                service.ONE_InhumacionCenizas__c = true; 
            }
            else{
                service.ONE_Lugar_Incineracion__c = ONE_AccountSelector.selectAccount(jsonResponse.rcceminc).Id;
                service.ONE_Tipo_De_Lugar_De_Incineracion__c = DEFAULT_INCINERATION_SITE;
                service.ONE_Incineracion__c = true;
                service.ONE_Asistencia_Familia_CBSA__c = jsonResponse.rcasistf;
            }
        }
        else if (jsonResponse.rctipsol == 'X'){
            service.ONE_Llamada_CBSA_Realizada__c = false;
            service.ONE_Codigo_Difunto_CBSA__c = null;
            service.ONE_Hora_destino_final__c = null;
            service.ONE_Destino_Final__c = null;
            service.ONE_Inicio_incineracion__c = null;
            service.ONE_Lugar_Incineracion__c = null;
            service.ONE_Tipo_De_Lugar_De_Incineracion__c = null;
            service.ONE_Tipo_De_Lugar_Destino_Final__c = null;
            service.ONE_Incineracion__c = false;
            service.ONE_Cementerio__c = false;
            service.ONE_Asistencia_Familia_CBSA__c = null;
            service.ONE_Fecha_Inicio_Incineracion__c = null;
            service.ONE_InhumacionCenizas__c = false;
        }
        update service;
    }

    public static String parseDocumentType(String docType){
        if(docType == '97'){
            return '1';
        } else if(docType == '95'){
            return '2';
        } else if(docType == '94'){
            return '4';
        } else {
            return '3';
        }
    }

    private static DateTime parseToDateTime(Date fecha, String hora){
        List<String> partesHora = hora.split(':');
        Integer horas = Integer.valueOf(partesHora[0]);
        Integer minutos = Integer.valueOf(partesHora[1]);

        DateTime fechaHora = DateTime.newInstance(fecha.year(), fecha.month(), fecha.day(), horas, minutos, 0);
        return fechaHora;
    }

    public static String formatDate(Datetime unformattedDateTime) {
        return unformattedDateTime == null ? EMPTY_VALUE : unformattedDateTime.format('yyyy-MM-dd');
    }

    public static String formatTime(Datetime unformattedDateTime) {
        return unformattedDateTime == null ? EMPTY_VALUE : String.valueOf(unformattedDateTime.time()).left(5);
    }

    public static String formatSex(String sex) {
        if (sex == MALE_SEX) {
            return MALE_SEX_SHORT;
        } else if (sex == FEMALE_SEX) {
            return FEMALE_SEX_SHORT;
        } else if (sex == UNDETERMINED_SEX) {
            return UNDETERMINED_SEX_SHORT;
        } else {
            return TYPE_OF_DECEASED_DIFUNTO_LETTER;
        }
    }

    public class CBSAJSONRequest{
        public String rcprosol;
        public String rcususol;
        public String rctipsol;
        public String rcdifunt;
        public String rcnom;
        public String rccog1;
        public String rccog2;
        public String rctipdocu;
        public String rcnumdocu;
        public String rcpaidoc;
        public String rcsexe;
        public String rcnaixe;
        public String rcjudicial;
        public String rcpais;
        public String rcprovi;
        public String rcmunic;
        public String rccarrer;
        public String rcnumcar;
        public String rccomnu;
        public String rcescal;
        public String rcpis;
        public String rcporta;
        public String rczip;
        public String rctelef;
        public String rcemail;
        public String rccaumor;
        public String rcdatdef;
        public String rchordef;
        public String rcestdif;
        public String rcceminc;
        public String rcdatarr;
        public String rchorarr;
        public String rcasistf;
        public String rcdatinc;
        public String rcdatinh;
        public String rchorinc;
        public String rchorinh;
        public String rcceminh;
        public String rchoricons;

        public CBSAJSONRequest( ONE_Expediente__c servicio, CBSARequest request){
            this.rcprosol = DEFAULT_IDENTIFICATION;
            this.rcususol = DEFAULT_USERNAME;
            this.rctipsol = (request.cementerioInh != null && request.reservationType == 'I' && !servicio.ONE_Incineracion__c) ? 'E' : request.reservationType;
            this.rcdifunt = servicio.ONE_Codigo_Difunto_CBSA__c != null ? servicio.ONE_Codigo_Difunto_CBSA__c : '';
            this.rcnom = servicio.ONE_Difunto__r.FirstName;
            this.rccog1 = servicio.ONE_Difunto__r.LastName;
            //this.rccog2 = servicio.ONE_Difunto__r.LastName.split(' ')[1] != null? servicio.ONE_Difunto__r.LastName.split(' ')[1] : '';
            this.rctipdocu = servicio.ONE_Difunto__r.ONE_Tipo_de_documento__pc != null ? ONE_CBSA_ReservationHelper.parseDocumentType(servicio.ONE_Difunto__r.ONE_Tipo_de_documento__pc) : '';
            this.rcnumdocu = servicio.ONE_Difunto__r.ONE_N_Documento__pc != null ? servicio.ONE_Difunto__r.ONE_N_Documento__pc : '';
            this.rcpaidoc = servicio.ONE_Difunto__r.ONE_Nacionalidad__c != null ? servicio.ONE_Difunto__r.ONE_Nacionalidad__c : '';
            this.rcsexe = ONE_CBSA_ReservationHelper.formatSex(servicio.ONE_Difunto__r.ONE_Sexo__c);
            this.rcnaixe = servicio.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc != null ? ONE_CBSA_ReservationHelper.formatDate(servicio.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc) : '';
            this.rcjudicial = servicio.ONE_Judicial__c ? 'S' : 'N';
            this.rcpais = servicio.ONE_Difunto__r.ONE_Pais__pc != null ? servicio.ONE_Difunto__r.ONE_Pais__pc : '';
            this.rcprovi = servicio.ONE_Difunto__r.ONE_Provincia__pc != null ? servicio.ONE_Difunto__r.ONE_Provincia__pc : '';
            this.rcmunic = servicio.ONE_Difunto__r.ONE_Municipio__pc != null ? servicio.ONE_Difunto__r.ONE_Municipio__pc : '';
            this.rccarrer = servicio.ONE_Difunto__r.ONE_Calle__pc != null ? servicio.ONE_Difunto__r.ONE_Calle__pc : '';
            this.rcnumcar = servicio.ONE_Difunto__r.ONE_Numero_Calle__pc != null ? servicio.ONE_Difunto__r.ONE_Numero_Calle__pc : '';
            this.rccomnu = servicio.ONE_Difunto__r.ONE_BIS__pc != null ? servicio.ONE_Difunto__r.ONE_BIS__pc : '';
            this.rcescal = servicio.ONE_Difunto__r.ONE_Escalera_Calle__pc != null ? servicio.ONE_Difunto__r.ONE_Escalera_Calle__pc : '';
            this.rcpis = servicio.ONE_Difunto__r.ONE_Piso_Calle__pc != null ? servicio.ONE_Difunto__r.ONE_Piso_Calle__pc : '';
            this.rcporta = servicio.ONE_Difunto__r.ONE_Puerta_Calle__pc != null ? servicio.ONE_Difunto__r.ONE_Puerta_Calle__pc : '';
            this.rczip = servicio.ONE_Difunto__r.ONE_Codigo_Postal__pc != null ? servicio.ONE_Difunto__r.ONE_Codigo_Postal__pc : '';
            this.rctelef = servicio.ONE_Difunto__r.Phone != null ? servicio.ONE_Difunto__r.Phone : '';
            this.rcemail = servicio.ONE_Difunto__r.ONE_Email__c != null ? servicio.ONE_Difunto__r.ONE_Email__c : '';
            this.rccaumor = servicio.ONE_Causas_Defuncion__c != null ? servicio.ONE_Causas_Defuncion__c : '';
            this.rcdatdef = servicio.ONE_Fecha_De_Defuncion__c != null ? ONE_CBSA_ReservationHelper.formatDate(servicio.ONE_Fecha_De_Defuncion__c) : '';
            this.rchordef = servicio.ONE_Fecha_De_Defuncion__c != null ? ONE_CBSA_ReservationHelper.formatTime(servicio.ONE_Fecha_De_Defuncion__c) : '';
            this.rcestdif = (this.rctipsol == 'E' && request.reservationType == 'I' && servicio.ONE_Tipo_De_Difunto__c == '6'/*Cenizas*/) ? 'Z': servicio.ONE_Estado_Del_Difunto__c != null ? servicio.ONE_Estado_Del_Difunto__c : '';
            this.rcceminc = request.reservationType == 'I' ? request.cementerioInc != null ? request.cementerioInc : servicio.ONE_Lugar_Incineracion__r.ONE_Codigo_Cementerio_CB__c != null ? servicio.ONE_Lugar_Incineracion__r.ONE_Codigo_Cementerio_CB__c : '' : '';
            this.rcdatarr = request.llegadaDifunto != null ? ONE_CBSA_ReservationHelper.formatDate(request.llegadaDifunto) : '';
            this.rchorarr = request.llegadaDifunto != null ? ONE_CBSA_ReservationHelper.formatTime(request.llegadaDifunto) : '';
            this.rcasistf = request.asistFam != null ? request.asistFam : servicio.ONE_Asistencia_Familia_CBSA__c != null ? servicio.ONE_Asistencia_Familia_CBSA__c : '';
            this.rcdatinc = request.reservationType == 'I' ? (this.rcasistf == 'A' || this.rcasistf == 'N') ? (servicio.ONE_Fecha_Inicio_Incineracion__c != null ? ONE_CBSA_ReservationHelper.formatDate(servicio.ONE_Fecha_Inicio_Incineracion__c) : '') : (servicio.ONE_Inicio_Incineracion__c != null ? ONE_CBSA_ReservationHelper.formatDate(servicio.ONE_Inicio_Incineracion__c) : '') : '';
            this.rcdatinh = servicio.ONE_Hora_destino_final__c != null ? ONE_CBSA_ReservationHelper.formatDate(servicio.ONE_Hora_destino_final__c) : request.inhumationDate != null ? ONE_CBSA_ReservationHelper.formatDate(request.inhumationDate) : '';
            this.rchorinc = (request.reservationType == 'I' && (this.rcasistf == 'S' || this.rcasistf == 'C') && servicio.ONE_Inicio_Incineracion__c != null) ? ONE_CBSA_ReservationHelper.formatTime(servicio.ONE_Inicio_Incineracion__c) : '';
            this.rchorinh = servicio.ONE_Hora_destino_final__c != null ? ONE_CBSA_ReservationHelper.formatTime(servicio.ONE_Hora_destino_final__c) : '';
            this.rcceminh = request.cementerioInh != null ? request.cementerioInh : '';
            this.rchoricons = request.inhumationDate != null ? ONE_CBSA_ReservationHelper.formatTime(request.inhumationDate) : '';
        }
    }

    public class CBSAJSONResponse {
        public String rcserial;
        public String rcprosol;
        public String rcususol;
        public String rctipsol;
        public String rcdifunt;
        public String rcnom;
        public String rccog1;
        public String rccog2;
        public String rctipdocu;
        public String rcnumdocu;
        public String rcpaidoc;
        public String rcsexe;
        public String rcnaipe;
        public String rcjudicial;
        public String rcpais;
        public String rcprovi;
        public String rcmunic;
        public String rccarrer;
        public String rcnumcar;
        public String rccomu;
        public String recsal;
        public String rcpis;
        public String rcporta;
        public String rczip;
        public String rctelef;
        public String rcemail;
        public String rccaumor;
        public Date rcdatdef;
        public String rchordef;
        public String rcestdif;
        public String rctipser;
        public String rcceminc;
        public Date rcdatar;
        public String rchorarr;
        public String rcasistf;
        public Date rcdatinc;
        public Date rcdatinh;
        public String rchorinc;
        public String rchorinh;
        public String rcceminh;
        public String rcbrigada;
        public String rchoricons;
        public String rcestado; // Posibles valores: C, E, W
        public String missatges;
        public List<HorarioIncineracion> rchorincdis;
        public List<HorarioInhumacion> rchorinhdis;
    }

    public class HorarioIncineracion{
        public String horincdis;
    }

    public class HorarioInhumacion{
        public String horinhdis;
    }

    public class CBSARequest{
        public Id serviceId;
        public String reservationType;
        public String cementerioInh;
        public String cementerioInc;
        public DateTime llegadaDifunto;
        public String asistFam;
        public DateTime inhumationDate;
    }

    public class CBSAResponse {
        public List<String> availableHours;
        public String selectedHour;
        public Date selectedDate;
        public String responseCode;
        public String responseMessage;
    }
}
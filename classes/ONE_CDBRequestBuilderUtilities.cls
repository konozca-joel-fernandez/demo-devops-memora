/**
 * Created by mchruscick001 on 06.10.2021 14:05.
 */ 

public with sharing class ONE_CDBRequestBuilderUtilities {
    //Static variable CB integration definition 
    static final String DATE_FORMAT = 'dd/MM/yyyy', DAY_FORMAT = 'EEEE';
    static final Integer MINUTES_IN_HOUR = 60;
    static Set<String> WEEKEND_DAYS = new Set<String>{
        'Saturday', 'Sunday'
    };
    static final String MALE_SEX = 'Hombre', MALE_SEX_SHORT = 'M';
    static final String FEMALE_SEX = 'Mujer', FEMALE_SEX_SHORT = 'F';
    static final String UNDETERMINED_SEX = 'Indefinido', UNDETERMINED_SEX_SHORT = 'I';
    static final String TYPE_OF_DECEASED_REMAINS_NUMBER = '3', TYPE_OF_DECEASED_ASHES_NUMBER = '6', TYPE_OF_DECEASED_REMAINS_LETTER = 'E';
    static final String TYPE_OF_DECEASED_FETUS_NUMBER = '4', TYPE_OF_DECEASED_FETUS_LETTER = 'F';
    static final String TYPE_OF_DECEASED_MEMBER_NUMBER = '5', TYPE_OF_DECEASED_MEMBER_LETTER = 'R';
    static final String TYPE_OF_DECEASED_ADULT_NUMBER = '2', TYPE_OF_DECEASED_NO_BODY_NUMBER = '7', TYPE_OF_DECEASED_DIFUNTO_LETTER = 'D';
    static final String TYPE_OF_DECEASED_TODDLER_NUMBER = '1', TYPE_OF_DECEASED_TODDLER_LETTER='P';
    static final String COUNTRY_CODE_FRANCE = 'FR', COUNTRY_FULL_NAME_FRANCE = 'Francia';
    static final String COUNTRY_CODE_SPAIN = 'ES', COUNTRY_FULL_NAME_SPAIN = 'España';
    static final String COUNTRY_CODE_PORTUGAL = 'PT', COUNTRY_FULL_NAME_PORTUGAL = 'Portugal';
    static final String DOCUMENT_TYPE_NUMBER_NIF_SF = '97', DOCUMENT_TYPE_NUMBER_NIF_CB = '1';
    static final String DOCUMENT_TYPE_NUMBER_CIF_SF = '96', DOCUMENT_TYPE_NUMBER_CIF_CB = '3';
    static final String DOCUMENT_TYPE_NUMBER_NIE_SF = '95', DOCUMENT_TYPE_NUMBER_NIE_CB = '2';
    static final String DOCUMENT_TYPE_NUMBER_PASSPORT_SF = '94', DOCUMENT_TYPE_NUMBER_PASSPORT_CB = '4';
    static final String BUSINESS_TYPE_SHORT_PARTICULAR_SF = 'Particular', BUSINESS_TYPE_SHORT_PARTICULAR_CB = 'P';
    static final String BUSINESS_TYPE_SHORT_INSURED_SF = 'Asegurado/Acuerdo', BUSINESS_TYPE_SHORT_INSURED_CB = 'C';
    static final String DEFAULT_SF_PROVINCE = '00', DEFAULT_CB_PROVINCE = '99';
    static final String COMMA_SEPARATOR = ',', DOT_SEPARATOR = '.';
    static final String PLACE_OF_DEATH_HOSPITAL_LONG = 'Hospital', PLACE_OF_DEATH_HOSPITAL_SHORT = 'H';
    static final String PLACE_OF_DEATH_RETIREMENT_HOUSE_LONG = 'Residencia', PLACE_OF_DEATH_HOME_SHORT = 'G';
    static final String PLACE_OF_DEATH_HOME_LONG = 'Domicilio Particular';
    static final String PLACE_OF_DEATH_ROAD_LONG = 'Carretera';
    static final String PLACE_OF_DEATH_OTHER_LONG = 'Otros';
    static final String PLACE_OF_DEATH_DEFAULT_SHORT = 'D';
    public static final String EMPTY_VALUE = '';
	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getShortSex(String sex) {
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
	
	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getShortTypeOfDocument(String typeOfDocument) {
        if (typeOfDocument == DOCUMENT_TYPE_NUMBER_NIF_SF) {
            return DOCUMENT_TYPE_NUMBER_NIF_CB;
        } else if (typeOfDocument == DOCUMENT_TYPE_NUMBER_NIE_SF) {
            return DOCUMENT_TYPE_NUMBER_NIE_CB;
        } else if (typeOfDocument == DOCUMENT_TYPE_NUMBER_CIF_SF) {
            return DOCUMENT_TYPE_NUMBER_CIF_CB;
        } else if (typeOfDocument == DOCUMENT_TYPE_NUMBER_PASSPORT_SF) {
            return DOCUMENT_TYPE_NUMBER_PASSPORT_CB;
        } else {
            return EMPTY_VALUE;
        }
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getSFFormOfDocumentType(String CBTypeOfDocument) {
        if (CBTypeOfDocument == DOCUMENT_TYPE_NUMBER_NIF_CB) {
            return DOCUMENT_TYPE_NUMBER_NIF_SF;
        } else if (CBTypeOfDocument == DOCUMENT_TYPE_NUMBER_NIE_CB) {
            return DOCUMENT_TYPE_NUMBER_NIE_SF;
        } else if (CBTypeOfDocument == DOCUMENT_TYPE_NUMBER_CIF_CB) {
            return DOCUMENT_TYPE_NUMBER_CIF_SF;
        } else if (CBTypeOfDocument == DOCUMENT_TYPE_NUMBER_PASSPORT_CB) {
            return DOCUMENT_TYPE_NUMBER_PASSPORT_SF;
        } else {
            return EMPTY_VALUE;
        }
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getSFFormOfCountry(String countryInCBForm) {
        for (Schema.PicklistEntry countryPicklist : Account.ONE_Pais__pc.getDescribe().getPicklistValues()) {
            if (countryPicklist.getLabel().equalsIgnoreCase(countryInCBForm)) {
                return countryPicklist.getValue();
            }
        }
        return EMPTY_VALUE;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getSFFormOfProvince(String provinceInCBForm) {
        if (provinceInCBForm == DEFAULT_CB_PROVINCE) {
            return DEFAULT_SF_PROVINCE;
        } else {
            return provinceInCBForm;
        }
    }
    
	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getShortBusinessType(String longBusinessType) {
        if (longBusinessType == BUSINESS_TYPE_SHORT_INSURED_SF) {
            return BUSINESS_TYPE_SHORT_INSURED_CB;
        } else if (longBusinessType == BUSINESS_TYPE_SHORT_PARTICULAR_SF) {
            return BUSINESS_TYPE_SHORT_PARTICULAR_CB;
        } else {
            return EMPTY_VALUE;
        }
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getShortTypeOfDeceased(String typeOfDeceased) {
        if (typeOfDeceased == TYPE_OF_DECEASED_REMAINS_NUMBER || typeOfDeceased == TYPE_OF_DECEASED_ASHES_NUMBER) {
            return TYPE_OF_DECEASED_REMAINS_LETTER;
        } else if (typeOfDeceased == TYPE_OF_DECEASED_FETUS_NUMBER) {
            return TYPE_OF_DECEASED_FETUS_LETTER;
        } else if (typeOfDeceased == TYPE_OF_DECEASED_MEMBER_NUMBER) {
            return TYPE_OF_DECEASED_MEMBER_LETTER;
        } else if ( typeOfDeceased == TYPE_OF_DECEASED_ADULT_NUMBER || typeOfDeceased == TYPE_OF_DECEASED_NO_BODY_NUMBER) {
            return TYPE_OF_DECEASED_DIFUNTO_LETTER;
        } else if(typeOfDeceased == TYPE_OF_DECEASED_TODDLER_NUMBER ){
            return TYPE_OF_DECEASED_TODDLER_LETTER;
        }else{
            return EMPTY_VALUE;
        }
    }

	//Format date utility
    public static String getFormattedDate(Datetime unformattedDateTime) {
        return unformattedDateTime == null ? EMPTY_VALUE : unformattedDateTime.format(DATE_FORMAT);
    }
	//Format time utility
    public static String getTime(Datetime unformattedDateTime) {
        return unformattedDateTime == null ? EMPTY_VALUE : String.valueOf(unformattedDateTime.time()).left(5);
    }

    public static String getLongCountryName(String shortCountryCode) {
        if (shortCountryCode == COUNTRY_CODE_SPAIN) {
            return COUNTRY_FULL_NAME_SPAIN;
        } else if (shortCountryCode == COUNTRY_CODE_PORTUGAL) {
            return COUNTRY_FULL_NAME_PORTUGAL;
        } else if (shortCountryCode == COUNTRY_CODE_FRANCE) {
            return COUNTRY_FULL_NAME_FRANCE;
        } else {
            return EMPTY_VALUE;
        }
    }
    
	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getShortPlaceOfDeath(String longPlaceOfDeath) {
        if (longPlaceOfDeath == PLACE_OF_DEATH_HOSPITAL_LONG) {
            return PLACE_OF_DEATH_HOSPITAL_SHORT;
        } else if (longPlaceOfDeath == PLACE_OF_DEATH_RETIREMENT_HOUSE_LONG) {
            return PLACE_OF_DEATH_HOME_SHORT;
        } else if (longPlaceOfDeath == PLACE_OF_DEATH_HOME_LONG || longPlaceOfDeath == PLACE_OF_DEATH_ROAD_LONG || longPlaceOfDeath == PLACE_OF_DEATH_OTHER_LONG) {
            return PLACE_OF_DEATH_DEFAULT_SHORT;
        } else {
            return EMPTY_VALUE;
        }
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getLongCountryNameFromAccountCountryPicklist(String shortCountryCode) {
        for (Schema.PicklistEntry countryPicklist : Account.ONE_Pais__pc.getDescribe().getPicklistValues()) {
            if (countryPicklist.getValue().equals(shortCountryCode)) {
                return countryPicklist.getLabel().toUpperCase();
            }
        }
        return EMPTY_VALUE;
    }

 	//Get short name utility for string delimiter separator
   public static String getAsStringWithCommaSeparator(Decimal decimalValue) {
        return String.valueOf(decimalValue).replace(DOT_SEPARATOR, COMMA_SEPARATOR);
    }
    
    /*public static Datetime getReservationPeriod(ONE_CDBReservationModalController.ReservationModel reservationModel, ONE_Expediente__c service) {
        if (service?.ONE_Lugar_Ceremonia__c != null && isCeremonyInInternalPlace(service?.ONE_Lugar_Ceremonia__r)) {
            return addDifferentTimeIfCeremonyInInternalPlace(
                service?.ONE_Inicio_Ceremonia__c,
                ONE_DesplazamientosSelector.getByCustomersCeremony(service?.ONE_Lugar_Ceremonia__c, service?.ONE_Sala_Ceremonia__c, reservationModel?.selectedCemetery)
            );
        } else {
            return addTimeToExternalCeremony(service?.ONE_Inicio_Ceremonia__c);
        }
    }

    static Datetime addDifferentTimeIfCeremonyInInternalPlace(Datetime ceremonyTime, ONE_Desplazamientos_CB__c something) {
        return ceremonyTime?.addMinutes((Integer) ((isReservationAtWeekend(ceremonyTime) ? something?.ONE_Tiempo_Fines_De_Semana__c : something?.ONE_Tiempo_Laborables__c) * MINUTES_IN_HOUR));
    }

    static Datetime addTimeToExternalCeremony(Datetime ceremonyTime) {
        return ceremonyTime?.addHours(1).addMinutes(30);
    }*/

//    static Boolean isCeremonyInInternalPlace(Account place) {
//        return place?.RecordType.DeveloperName == ONE_CommonConstants.ACC_RT_CENTRO_MEMORA;
//    }
//
//    static Boolean isReservationAtWeekend(Datetime ceremonyDate) {
//        return WEEKEND_DAYS.contains(getDayOfTheWeek(ceremonyDate));
//    }
//
//    static String getDayOfTheWeek(Datetime ceremonyDate) {
//        return ceremonyDate?.format(DAY_FORMAT);
//    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTinom(ONE_Presupuesto__c onePresupuesto) {
        String tinom = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Otras_Cuentas').getRecordTypeId()) {
            tinom = onePresupuesto.ONE_Codigo_Titular_CB__r.Name;
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId()) {
            tinom = onePresupuesto.ONE_Codigo_Titular_CB__r.FirstName;
        }
        return tinom;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTicog1(ONE_Presupuesto__c onePresupuesto) {
        String ticog1 = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Otras_Cuentas').getRecordTypeId()) {
            ticog1 = '';
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId()) {
            ticog1 = onePresupuesto.ONE_Codigo_Titular_CB__r.LastName;
        }
        return ticog1;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTinumdocu(ONE_Presupuesto__c onePresupuesto) {
        String tinumdocu = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Otras_Cuentas').getRecordTypeId()) {
            tinumdocu = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_CIF__c;
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId()) {
            tinumdocu = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_N_Documento__pc;
        }
        return tinumdocu;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTicodprovi(ONE_Presupuesto__c onePresupuesto) {
        String ticodprovi = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Otras_Cuentas').getRecordTypeId()) {
            ticodprovi = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Provincia__c;
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId()) {
            ticodprovi = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Provincia__pc;
        }
        return ticodprovi;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTinommunic(ONE_Presupuesto__c onePresupuesto) {
        String tinommunic = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Otras_Cuentas').getRecordTypeId()) {
            tinommunic = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Municipio_Direccion__c;
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId()) {
            tinommunic = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Municipio__pc;
        }
        return tinommunic;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTicarrer(ONE_Presupuesto__c onePresupuesto) {
        String ticarrer = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Otras_Cuentas').getRecordTypeId()) {
            ticarrer = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Direccion__c;
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId()) {
            ticarrer = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Direccion__pc;
        }
        return ticarrer;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTizip(ONE_Presupuesto__c onePresupuesto) {
        String tizip = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Otras_Cuentas').getRecordTypeId()) {
            tizip = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Codigo_Postal__c;
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('ONE_Person_Accout_Particular').getRecordTypeId()) {
            tizip = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Codigo_Postal__pc;
        }
        return tizip;
    }
    
	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getTinompais(ONE_Presupuesto__c onePresupuesto) {
        String country = '';
        if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS)) {
            country = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Pais__c;
        } else if (onePresupuesto.ONE_Codigo_Titular_CB__r.RecordTypeId == ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)) {
            country = onePresupuesto.ONE_Codigo_Titular_CB__r.ONE_Pais__pc;
        }
        return country;
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getValueIfRecordTypeMatch(String value, String recordType, Id recordTypeId) {
        if (recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get(recordType).getRecordTypeId()) {
            return value;
        }
        return '';
    }

	//Get short name utility for converting SF parameter into the appropiate one for the request
    public static String getCausasDefuncion(ONE_Presupuesto__c onePresupuesto) {
        switch on onePresupuesto?.ONE_Expediente__r?.ONE_Causas_Defuncion__c {
            when 'COVID' {
                return 'I';
            }
            when 'Natural' {
                return 'E';
            }
            when else {
                return onePresupuesto?.ONE_Expediente__r?.ONE_Causas_Defuncion__c;
            }
        }
    }
    //Get short name utility for converting SF parameter "parentesco" into the appropiate one for the request for deparentiu
       public static String getDeparentiu(String relatioship, String sexo) {
           System.debug('relationship: '+relatioship);
           System.debug('sexo: '+sexo);
           switch on relatioship {
            when 'Abuelo/a'{
                if(sexo!='Mujer'){return '6';}else{return '7'; }
            }
            when 'Ahijado/a'{
                if(sexo!='Mujer'){return '20';}else{return '19';}
            }
            when 'Amistad'{
                return '46';
            }
            when 'Biznieto/a'{
                if(sexo!='Mujer'){return '32';}else{return '33';}
            }
            when 'Conviviente Civil'{
                return '45';
            }
            when 'Cónyuge'{
                if(sexo!='Mujer'){return '9';}else{return '10';}
            }
            when 'Cuñado/a'{
                if(sexo!='Mujer'){return '16';}else{return '15'; }
            }
            when 'Director/a Comunidad religiosa'{
                return '48';
            }
            when 'Director/a Residencia'{
                return '47';
            }
            when 'Hija'{
               return '4';
            }
            when 'Hijo'{
               return '3';
            }
            when 'Hijo/a polític.'{
                if(sexo!='Mujer'){return '21';}else{return '22';}
            }
            when 'Madre'{
               return '2';
            }
            when 'Madrastra'{
               return '50';
            }
            when 'Otro'{
               return '99';
            }
            when 'Nieto/a'{
                if(sexo!='Mujer'){return '11';}else{return '12';}
            }
            when 'Padrastro'{
               return '51';
            }
            when 'Padre'{
               return '1';
            }
            when 'Pareja'{
               return '49';
            }
            when 'Primo/a'{
                if(sexo!='Mujer'){return '18';}else{return '17';}
            }
            when 'Representante legal'{
               return '98';
            }
            when 'Trabajador social'{
               return '44';
            }
            when 'No se ha seleccionado'{
               return '99';
            }
            when 'Sobrino/a'{
                if(sexo!='Mujer'){return '24';}else{return '23';}
            }
            when 'Suegro/a'{
                if(sexo!='Mujer'){return '26';}else{return '25';}
            }
            when 'Tío/a'{
                if(sexo!='Mujer'){return '13';}else{return '14';}
            }
            when 'Hijastro/a'{
                if(sexo!='Mujer'){return '42';}else{return '43';}
            }
            when 'Hermano/a'{
                if(sexo!='Mujer'){return '8';}else{return '7';}
            }
               
        }
        return '99';
    }
    
}
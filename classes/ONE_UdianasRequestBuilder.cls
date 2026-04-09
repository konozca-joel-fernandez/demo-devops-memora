/**
* File Name: ONE_UdianasRequestBuilder.cls
* Description: 	Service class to build Udianas requests
* Date: 03/12/2025
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		03/12/2025		Adrià Barragán 		Class creation
* 02        03/02/2026      Adrià Barragán      When we send Nombre Coloquial as name, we send LastName as surname
* 03        04/02/2026      Adrià Barragán      Removed logic to set civility based on gender
* ===================================================================================================================
*/
global with sharing class ONE_UdianasRequestBuilder {

    public static String buildRequestJson(ONE_Expediente__c servicio, String enterpriseHashId, String insuranceHashId, String apiKey) {
        // deceasedPerson

        //String civility = (servicio.ONE_Difunto__r != null && servicio.ONE_Difunto__r.ONE_Sexo__c == 'Hombre') ? 'Senor' : 'Senora';
        
        String name =
            (servicio.ONE_Difunto__r != null
            && !String.isBlank(servicio.ONE_Difunto__r.ONE_Nombre_Coloquial__c))
                ? servicio.ONE_Difunto__r.ONE_Nombre_Coloquial__c
                    + (
                        !String.isBlank(servicio.ONE_Difunto__r.LastName)
                            ? ' ' + servicio.ONE_Difunto__r.LastName
                            : ''
                    )
                : (servicio.ONE_Difunto__r != null
                    ? servicio.ONE_Difunto__r.Name
                    : '');
        String dateOfDeath = (servicio.ONE_Fecha_De_Defuncion__c != null) ? servicio.ONE_Fecha_De_Defuncion__c.formatGmt('yyyy-MM-dd') : null;

        Map<String, Object> deceasedPerson = new Map<String, Object>{
            'civility'            => '',
            'firstName'           => '',
            'name'                => name,
            'surname'             => '',
            'publicDenomination'  => '',
            'dateOfDeath'         => dateOfDeath,
            'imageUrl'            => ''
        };

        // family
        String relativeName  = (servicio.ONE_Declarante__r != null && !String.isBlank(servicio.ONE_Declarante__r.Name))
            ? servicio.ONE_Declarante__r.Name : '';

        String relativeEmail = (servicio.ONE_Declarante__r != null && !String.isBlank(servicio.ONE_Declarante__r.ONE_Email__c))
            ? servicio.ONE_Declarante__r.ONE_Email__c : '';

        String zona       = servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
        String delegacion = servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name;

        //1.- Por zona
        String idiomaFinal = forcedLanguageByGeo(zona, delegacion);

        //2.- Por declarente
        if (idiomaFinal == null && servicio.ONE_Declarante__r != null) {
            idiomaFinal = String.valueOf(servicio.ONE_Declarante__r.ONE_Idioma__pc); 
        }

        //3.- Por defecto
        if (idiomaFinal == null) idiomaFinal = 'ES';

        idiomaFinal = idiomaFinal.toLowerCase();

        Boolean noEmail = String.isBlank(relativeEmail);

        // Consentimiento Familia
        Boolean consentCommercial = (servicio.ONE_Declarante__r != null && servicio.ONE_Declarante__r.ONE_Remision_de_info_y_accion_comercial__pc == 'Si');

        Map<String, Object> family = new Map<String, Object>{
            'name'         => relativeName,
            'emailAddress' => relativeEmail,
            'language'     => idiomaFinal,
            'noEmail'      => noEmail,
            'consentCommercialCommunication' => consentCommercial
        };

        // donor
        Map<String, Object> donor = new Map<String, Object>{
            'name'    => 'Memora',
            'message' => 'In memory'
        };

        // businessProfile
        String serfunleApiKey = [
            SELECT ONE_ApiKey__c
            FROM ONE_UdianasApiKey__mdt
            WHERE ONE_Area_Operativa__c = 'SERFUNLE'
            LIMIT 1
        ].ONE_ApiKey__c;

        //si se envia al side SERFUNLE, se fuerza el enterpriseHashId de SERFUNLE
        if (apiKey == serfunleApiKey) {
            enterpriseHashId = [
                SELECT ONE_ApiKey__c
                FROM ONE_UdianasApiKey__mdt
                WHERE DeveloperName = 'SERFUNLE_EnterpriseHashId'
                LIMIT 1
            ].ONE_ApiKey__c;
        }

        Map<String, Object> businessProfile = new Map<String, Object>{
            'funeralEnterpriseHashId' => (enterpriseHashId == null ? '' : enterpriseHashId),
            'insuranceCompanyHashId'  => (insuranceHashId == null ? '' : insuranceHashId)
        };

        // Consentimiento InArboriam
        Boolean hasFamilyName = !String.isBlank(relativeName);
        Boolean consentInArboriam = (servicio.ONE_In_Arboriam__c == 'Si'); 
        
        //Si falta el nombre de la familia, no se puede enviar info a InArboriam, aunque haya consentido.
        Boolean anonymous = !consentInArboriam || !hasFamilyName;

        if (anonymous) {
            family.put('name', '');
            family.put('emailAddress', '');
            family.put('noEmail', true);
        } else {
            family.put('noEmail', String.isBlank(relativeEmail));
        }

        // root
        Map<String, Object> root = new Map<String, Object>{
            'deceasedPerson'              => deceasedPerson,
            'family'                      => family,
            'donor'                       => donor,
            'businessProfile'             => businessProfile,
            'anonymous'                   => anonymous,
            'noTree'                      => false,
            'funeralExterpriseInternalId' => String.valueOf(servicio.Name)
        };

        return JSON.serialize(root);
    }

    private static String forcedLanguageByGeo(String zona, String delegacion) {
        Set<String> ESUKADI_ZONES = new Set<String>{'Z.SAN SEBASTIAN','Z.BIZKAIA', 'Z.ALAVA'};

        if (!String.isBlank(zona) && ESUKADI_ZONES.contains(zona)) {
            return 'EU';
        }
        else if (!String.isBlank(delegacion) && (delegacion == 'SFB' || delegacion == 'CATALUNYA')) {
            return 'CA';
        }
        return null;
    }
}
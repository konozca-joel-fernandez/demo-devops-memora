/**
* File Name: ONE_UdianasInsuranceService.cls
* Description: 	Service class to handle Insurance creation in Udianas
* Date: 03/12/2025
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Test: ONE_UdianasInsuranceServiceTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		03/12/2025		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
global with sharing class ONE_UdianasInsuranceService {

    private static final String METADATA_NAME = 'UDIANAS_INSURANCE_CREATE';

    //Devuelve el InsuranceHashId para "Particular" desde Custom Metadata.
    public static String lookupParticularHash() {
        List<ONE_TreeNationInsuranceCompany__mdt> rows = [
            SELECT ONE_InsuranceCompanyHashId__c
            FROM ONE_TreeNationInsuranceCompany__mdt
            WHERE ONE_CompanyKey__c = 'Particular'
            AND ONE_Active__c = true
            LIMIT 1
        ];

        return rows.isEmpty() ? null : rows[0].ONE_InsuranceCompanyHashId__c;
    }

    public static String createInsurance(String companyName) {
        if (String.isBlank(companyName)) return null;
        return createInsuranceInUdianas(companyName);
    }

    // Callout POST /InsuranceCompanies/Create
    private class InsuranceCreateCallout extends ONE_Integration.IntegrationCallout {
        InsuranceCreateCallout(String jsonBody) {
            super(METADATA_NAME, ONE_Integration.RestMethod.POST);
            putHeader('Content-Type', 'application/json');
            setBody(jsonBody);
        }
    }

    private static String createInsuranceInUdianas(String name) {

        Map<String,Object> body = new Map<String,Object>{
            'name' => name,
            'externalStringId' => name,
            'externalId' => 0,
            'emailAddress' => 'logsonepre@memora.es'
        };

        InsuranceCreateCallout callout =
            new InsuranceCreateCallout(JSON.serialize(body));

        HttpResponse res = callout.invokeCallout();

        if (res.getStatusCode() < 200 || res.getStatusCode() > 299) {
            throw new ONE_Exception(
                ONE_Exception.ExceptionType.INTEGRATION,
                'Failed to create Insurance in Udianas'
            );
        }

        Map<String,Object> parsed =
            (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

        Map<String,Object> insurance =
            parsed != null ? (Map<String,Object>)parsed.get('insuranceCompany') : null;

        Object idVal =
            insurance != null ? insurance.get('insuranceCompanyHashId') : null;

        return idVal == null ? null : String.valueOf(idVal);
    }
}
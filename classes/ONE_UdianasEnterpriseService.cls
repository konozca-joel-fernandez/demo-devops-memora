/**
* File Name: ONE_UdianasEnterpriseService.cls
* Description: 	Service class to handle Enterprise creation in Udianas
* Date: 03/12/2025
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Test: ONE_UdianasEnterpriseServiceTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		03/12/2025		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
global with sharing class ONE_UdianasEnterpriseService {

    private static final String METADATA_NAME = 'UDIANAS_ENTERPRISE_CREATE';

    public static String createEnterprise(String name) {
        if (String.isBlank(name)) return null;
        return createEnterpriseInUdianas(name);
    }

    // Callout POST /Enterprises/Create
    private class EnterpriseCreateCallout extends ONE_Integration.IntegrationCallout {
        EnterpriseCreateCallout(String jsonBody) {
            super(METADATA_NAME, ONE_Integration.RestMethod.POST);
            putHeader('Content-Type', 'application/json');
            setBody(jsonBody);
        }
    }

    private static String createEnterpriseInUdianas(String name) {

        string groupHashId = getGroupHashId();

        Map<String,Object> body = new Map<String,Object>{
            'name' => name,
            'externalStringId' => name,
            'externalId' => 0,
            'emailAddress' => 'logsonepre@memora.es',
            'groupHashId' => groupHashId
        };

        EnterpriseCreateCallout callout =
            new EnterpriseCreateCallout(JSON.serialize(body));

        HttpResponse res = callout.invokeCallout();

        if (res.getStatusCode() < 200 || res.getStatusCode() > 299) {
            throw new ONE_Exception(
                ONE_Exception.ExceptionType.INTEGRATION,
                'Failed to create Enterprise in Udianas'
            );
        }

        Map<String,Object> parsed =
            (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

        Map<String,Object> enterprise =
            parsed != null ? (Map<String,Object>)parsed.get('enterprise') : null;

        Object idVal =
            enterprise != null ? enterprise.get('enterpriseHashId') : null;

        return idVal == null ? null : String.valueOf(idVal);
    }

    private static String getGroupHashId() {
        return [
            SELECT ONE_ApiKey__c 
            FROM ONE_UdianasApiKey__mdt 
            WHERE DeveloperName = 'groupHashId' 
            LIMIT 1
        ].ONE_ApiKey__c;      
    }
}
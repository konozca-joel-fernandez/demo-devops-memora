/**
 * Created by mchruscick001 on 29.09.2021 15:14.
 */

public with sharing class ONE_IntegrationEndpointSelector {

    public static ONE_Integration_endpoint__mdt selectIntegrationEndpoint(String endpointName) {
        return [
                SELECT DeveloperName, ONE_Resource__c, ONE_Active__c, ONE_Named_Credentials__c, ONE_LogActive__c
                FROM ONE_Integration_endpoint__mdt
                WHERE DeveloperName = :endpointName
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
    }
}
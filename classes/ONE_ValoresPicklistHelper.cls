/**
 * Created by mbujak003 on 07.04.2021.
 */

public with sharing class ONE_ValoresPicklistHelper {
    public static List<ONE_Valores_Picklist__c> fetchValoresPicklistsWithAttributes(Set<Id> attributeIds) {
        return [
            SELECT Id, ONE_Atributo__c, ONE_Nombre_ESP__c, ONE_Nombre_EUS__c, ONE_Nombre_CAT__c, ONE_Valor__c
            FROM ONE_Valores_Picklist__c
            WHERE ONE_Atributo__c IN: attributeIds
        ];
    }
}
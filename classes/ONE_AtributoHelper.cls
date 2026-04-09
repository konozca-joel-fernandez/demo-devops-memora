/**
 * Created by mbujak003 on 22.02.2021.
 */

public with sharing class ONE_AtributoHelper {
    public static List<ONE_Atributo__c> fetchAttributesWIthProducts(Set<Id> productIds) {
        return [
            SELECT Id, Name, ONE_Tipologia_De_Producto__c, ONE_Nombre_EUS__c, ONE_Nombre_CAT__c, ONE_Nombre_ESP__c, ONE_Orden__c, ONE_Requerido__c,
                ONE_Tipologia_UX__c, ONE_Campo_En_SF__c/*, ONE_Valores_picklist_ESP__c*/
            FROM ONE_Atributo__c
            WHERE ONE_Tipologia_De_Producto__c IN: productIds
        ];
    }
}
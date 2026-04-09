/**
 * Created by mbujak003 on 22.02.2021.
 */

public with sharing class ONE_RecursoHelper {
    public static List<ONE_Recurso__c> fetchRecursosWithAttributes(Set<Id> attributeIds) {
        return [
            SELECT Id, ONE_Atributo__c, ONE_Categoria_ESP__c, ONE_Categoria_EUS__c, ONE_Categoria_CAT__c, ONE_Tipo_De_Registro__c, ONE_Lugar__c,
                ONE_Descripcion__c, Name
            FROM ONE_Recurso__c
            WHERE ONE_Atributo__c IN: attributeIds
        ];
    }
}
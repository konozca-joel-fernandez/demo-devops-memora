/**
 * Created by bjaworski002 on 24.01.2022.
 */

public with sharing class ONE_CasoSelector {

    public static List<ONE_Caso__c> fetchCasosbyIds(List<Id> casoIds) {
        return [
            SELECT ONE_Numero_De_Siniestro_Texto__c, ONE_Tipo__c
            FROM ONE_Caso__c
            WHERE Id IN :casoIds
        ];
    }
}
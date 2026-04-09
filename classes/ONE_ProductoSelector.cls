/**
 * Created by mchruscick001 on 12.10.2021 08:15.
 */

public with sharing class ONE_ProductoSelector {

    public static List<ONE_Producto__c> selectProductByCommercialProducts(Set<String> commercialCodes) {
        return [
                SELECT Id, ONE_Codigo_Comercial__c
                FROM ONE_Producto__c
                WHERE ONE_Codigo_Comercial__c IN :commercialCodes
        ];
    }
}
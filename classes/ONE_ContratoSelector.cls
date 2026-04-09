public with sharing class ONE_ContratoSelector {
    
    public static List<ONE_Contrato__c> selectContratos(Set<String> electiumSmartCodigos) {
        return [
            SELECT ONE_Codigo_Electium_Smart__c
            FROM ONE_Contrato__c
            WHERE ONE_Codigo_Electium_Smart__c IN :electiumSmartCodigos
        ];
    }
    
    public static List<ONE_Contrato__c> selectContratos(List<ONE_Contrato__c> contratos) {
        return [
            SELECT Name, ONE_Codigo_Electium_Smart__c
            FROM ONE_Contrato__c
            WHERE Id IN :contratos
        ];
    }
}
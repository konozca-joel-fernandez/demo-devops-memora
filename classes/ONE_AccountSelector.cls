public with sharing class ONE_AccountSelector {
    
    public static List<Account> selectAccounts(Set<String> documentNumbers) {
        return [
            SELECT Id, ONE_N_Documento__pc
            FROM Account
            WHERE ONE_N_Documento__pc IN :documentNumbers
        ];
    }
        
    public static Account selectAccount(String cemeteryCode) {
        return [
                SELECT Id
                FROM Account
                WHERE ONE_Codigo_Cementerio_CB__c = :cemeteryCode
                LIMIT 1
        ];
    }

    public static List<Account> selectAccountsByDocumentNumbers(List<String> documentNumbers) {
        return [
                SELECT Id, ONE_N_Documento__pc
                FROM Account
                WHERE ONE_N_Documento__pc IN :documentNumbers
        ];
    }
    
    public static List<Account> selectAccountsByCIF(List<String> CIFs) {
        return [
                SELECT Id, ONE_CIF__c
                FROM Account
                WHERE ONE_CIF__c IN :CIFs
        ];
    }
}
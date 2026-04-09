public without sharing class SelectAccountWithCatalogController  {

    @AuraEnabled
    public static Map<Id, String> getAccountsWithCatalog() {
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id, String> accountsWithCatalog = new Map<Id, String>();

        for (ONE_Catalogo_De_Precios__c catalog : [SELECT ONE_Compania__c, ONE_Compania__r.Name FROM ONE_Catalogo_De_Precios__c WHERE ONE_Compania__c != NULL AND ONE_Compania__r.ONE_Nivel_Jerarquia_Cuentas__c != NULL AND ONE_Compania__r.RecordType.DeveloperName = 'ONE_Otras_Cuentas' ORDER BY ONE_Compania__r.Name ASC]) {
            accountsWithCatalog.put(catalog.ONE_Compania__c, catalog.ONE_Compania__r.Name);
        }
		
        return accountsWithCatalog;
    }    
}
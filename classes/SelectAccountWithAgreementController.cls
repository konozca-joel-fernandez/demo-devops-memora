public without sharing class SelectAccountWithAgreementController  {

    @AuraEnabled
    public static Map<Id, String> getAccountsWithAgreement() {
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id, String> accountsWithAgreement = new Map<Id, String>();

        for (ONE_Segmentacion_Acuerdo__c agreement : [SELECT ONE_Compania__c, ONE_Compania__r.Name FROM ONE_Segmentacion_Acuerdo__c WHERE ONE_Compania__c != NULL AND ONE_Compania__r.ONE_Nivel_Jerarquia_Cuentas__c != NULL AND ONE_Compania__r.RecordType.DeveloperName = 'ONE_Otras_Cuentas' ORDER BY ONE_Compania__r.Name ASC]) {
            accountsWithAgreement.put(agreement.ONE_Compania__c, agreement.ONE_Compania__r.Name);
        }
		
        return accountsWithAgreement;
    }    
}
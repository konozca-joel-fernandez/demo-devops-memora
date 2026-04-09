/**
 * Created by mbujak003 on 14.12.2020.
 */

public with sharing class ONE_ContactSearchController {

    @AuraEnabled
    public static String fetchAccountsData(Object filtersObject) {
        
        Map<String, String> filtersMap = (Map<String, String>)JSON.deserialize(JSON.serialize(filtersObject), Map<String, String>.class);
        List<AccountWrapper> accWrappers = new List<AccountWrapper>();
        Set<String> fieldsToFetch = new Set<String> {
            'Id', 'Name', 'Account.ONE_Edad__c', 'Account.ONE_Fecha_De_Defuncion2__c', 'ONE_N_Documento__pc', 'ONE_Compania_Aseguradora__pr.Name'
        };
		String dynamicQuery;
        Boolean searchByName=false;
        if(filtersMap.containsKey('difundo')&& filtersMap.get('difundo') != null && filtersMap.get('difundo') != ''){
            dynamicQuery='FIND { '+filtersMap.get('difundo')+'* } IN name FIELDS RETURNING Account (Id, Name,ONE_Edad__c,ONE_Fecha_De_Defuncion2__c,ONE_N_Documento__pc,ONE_Compania_Aseguradora__pr.Name WHERE RecordType.DeveloperName = \'' +  ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR + '\' OR RecordType.DeveloperName = \'' +  ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PROFESIONAL + '\' ORDER BY CreatedDate DESC )';
        	searchByName=true;
        }else{
            dynamicQuery = ONE_CommonUtils.buildDynamicQuery(ONE_CommonConstants.ACCOUNT, fieldsToFetch);
            dynamicQuery += ' WHERE (RecordType.DeveloperName = \'' +  ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR + '\'';
            dynamicQuery += ' OR RecordType.DeveloperName = \'' +  ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PROFESIONAL + '\') ';
           if(filtersMap.containsKey('documento') && filtersMap.get('documento') != null && filtersMap.get('documento') != '') {
                dynamicQuery += ' AND ONE_N_Documento__pc LIKE \'' + String.Format('%{0}%', new List<String> { filtersMap.get('documento') })  + '\'';
            }
    
            if(filtersMap.containsKey('cuenta') && filtersMap.get('cuenta') != null  && filtersMap.get('cuenta') != '') {
                dynamicQuery += ' AND ONE_Compania_Aseguradora__pr.Name LIKE \'' + String.Format('%{0}%', new List<String> { filtersMap.get('cuenta') })  + '\'';
            }
           searchByName=false; 
           dynamicQuery += 'Order by CreatedDate DESC';
        
        }
        
        if(searchByName){
            List<Account> accList=new List<Account>();
            accList.addAll((List<Account>)Search.query(dynamicQuery)[0]);
            for(Account acc : accList) {
                System.debug(acc);
                accWrappers.add(
                  new AccountWrapper(acc.Id, acc.Name, acc.ONE_Compania_Aseguradora__pr.Name, acc.ONE_Edad__c, acc.ONE_Fecha_De_Defuncion2__c, acc.ONE_N_Documento__pc,'')
                );
            }  
        }else{
            for(Account acc : Database.query(dynamicQuery)) {
                accWrappers.add(
                    new AccountWrapper(acc.Id, acc.Name, acc.ONE_Compania_Aseguradora__pr.Name, acc.ONE_Edad__c, acc.ONE_Fecha_De_Defuncion2__c, acc.ONE_N_Documento__pc,'')
                );
        	}
        }
        

        return JSON.serialize(accWrappers);
    }

    public class AccountWrapper {
        public String accountId { get; private set; }
        public String accountName { get; private set; }
        public String companiaAseguradoraName { get; private set; }
        public Decimal edad { get; private set; }
        public Datetime fechaDeDefuncion { get; private set; }
        public String documentName { get; private set; }
        public String contractName { get; private set; }

        public AccountWrapper(String accountId, String accountName, String companiaAseguradoraName, Decimal edad, Datetime fechaDeDefuncion, String documentName, String contractName) {
            this.accountId = accountId;
            this.accountName = accountName;
            this.companiaAseguradoraName = companiaAseguradoraName;
            this.edad = edad;
            this.fechaDeDefuncion = fechaDeDefuncion;
            this.documentName = documentName;
            this.contractName = contractName;
        }
    }
}
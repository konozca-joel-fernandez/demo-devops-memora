/**
 * Created by mbujak003 on 31.01.2021.
 */

public with sharing class ONE_AccountHelper {
    public static List<Account> fetchAccountsByDocumento(String nDocumento) {
        return [
            SELECT Id,ONE_Polizas_1__pc,ONE_Polizas_1__pr.ONE_Ramo__c,
                ONE_Polizas_1__pr.ONE_Compania_Aseguradora__c,
                ONE_Polizas_1__pr.ONE_Pol__c,
                ONE_Poliza_2__pc,
                ONE_Poliza_2__pr.ONE_Ramo__c,
                ONE_Poliza_2__pr.ONE_Compania_Aseguradora__c,
                ONE_Poliza_2__pr.ONE_Pol__c
            FROM Account
            WHERE ONE_N_Documento__pc = :nDocumento
        ];
    }

    public static Account fetchAccountsByContractId(String contractId) {
        return [
            SELECT ONE_Contratante__r.Id, ONE_Contratante__r.FirstName, ONE_Contratante__r.LastName,
                ONE_Contratante__r.BillingStreet, ONE_Contratante__r.BillingPostalCode, ONE_Contratante__r.BillingCity,
                ONE_Contratante__r.BillingCountry, ONE_Contratante__r.BillingState, ONE_Contratante__r.ONE_Idioma__pc,
                ONE_Contratante__r.Phone, ONE_Contratante__r.Fax, ONE_Contratante__r.PersonEmail, ONE_Contratante__r.PersonMailingState,
                ONE_Contratante__r.PersonMailingCountry, ONE_Contratante__r.PersonMailingStreet, ONE_Contratante__r.PersonMailingPostalCode,
                ONE_Contratante__r.PersonMailingCity, ONE_Contratante__r.ONE_N_Documento__pc, ONE_Contratante__r.ONE_Direccion__pc,
                ONE_Contratante__r.ONE_Codigo_Postal__pc, ONE_Contratante__r.ONE_Municipio__pc,
                ONE_Contratante__r.ONE_Pais__pc,
                ONE_Contratante__r.ONE_Provincia__pc,
            	ONE_Contratante__r.ONE_Tipo_de_documento__pc
            FROM ONE_Contrato__c
            WHERE Id = :contractId
        ].ONE_Contratante__r;
    }
}
/**
 * Created by mbujak003 on 31.01.2021.
 */

public with sharing class ONE_ContratoHelper {

    public static List<ONE_Contrato__c> fetchContratosByBeneficiaro1(String beneficiaroName) {
        return [
            SELECT Id, ONE_Capital__c, ONE_Fecha_De_Contrato__c,
                ONE_Indicador_De_Prima_Unica__c, ONE_Funeraria_Deseada__c,
                ONE_Beneficiario_1__r.ONE_Fecha_de_nacimiento__pc,
                ONE_Beneficiario_1__r.Id,
                ONE_Beneficiario_1__r.ONE_Sexo__c,
                ONE_Beneficiario_1__r.BillingCity,
                ONE_Beneficiario_1__r.BillingState,
                ONE_Beneficiario_1__r.BillingPostalCode,
            	ONE_Centro_de_Coste_Electium__c
            FROM ONE_Contrato__c
            WHERE ONE_Beneficiario_1__r.Name = :beneficiaroName
        ];
    }

    public static ONE_Contrato__c fetchContratosById(String contractId) {
        return [
            SELECT Id, ONE_Base_Impositiva__c, ONE_Impuestos__c, ONE_Contratante__r.Name, ONE_Base_Imponible__c, ONE_Importe_IVA__c,
                ONE_Numero_Contrato_Anexo__c, Name, ONE_Centro_de_Coste__c, ONE_Total_P_V_P__c, ONE_Tipo_de_Pago__c,
                ONE_Fecha_De_Cobro__c, ONE_Fecha_De_Contrato__c, ONE_Contratante__r.ONE_ID_Cliente_SAP__pc,ONE_Contratante__r.Owner.FirstName,
                ONE_Contratante__r.Owner.LastName, ONE_Beneficiario_1__r.Name, ONE_Centro_de_Coste_Electium__c, ONE_Forma_de_Pago__c, ONE_Num_Mensualidades__c, ONE_Importe_Primera_Mensualidad__c, 
            	ONE_Codigo_Electium_Smart__c, ONE_Cuota_Mensual__c, ONE_Fecha_Primera_Mensualidad__c, ONE_Tipo_De_Contrato__c, ONE_Observaciones_Generales__c, ONE_Tipo_Contrato__c, CreatedDate, ONE_ID_SAP__c, 
            	ONE_Fecha_de_Subida_a_SAP__c, ONE_Datos_Incorrectos_Contrato__c
            FROM ONE_Contrato__c
            WHERE Id = :contractId
        ];
    }

    public static List<ONE_Contrato__c> fetchContratsByParams(String compania, String pol, String ramo) {
        return [
            SELECT Id, ONE_Base_Impositiva__c, ONE_Impuestos__c, ONE_Contratante__r.Name, ONE_Base_Imponible__c, ONE_Importe_IVA__c,
                ONE_Numero_Contrato_Anexo__c, Name, ONE_Centro_de_Coste__c, ONE_Total_P_V_P__c, ONE_Tipo_de_Pago__c,
                ONE_Fecha_De_Cobro__c, ONE_Fecha_De_Contrato__c, ONE_Contratante__r.ONE_ID_Cliente_SAP__pc,ONE_Contratante__r.Owner.FirstName,
                ONE_Contratante__r.Owner.LastName, ONE_Beneficiario_1__r.Name, ONE_Centro_de_Coste_Electium__c, ONE_Codigo_Electium_Smart__c, ONE_Cuota_Mensual__c, ONE_Fecha_Primera_Mensualidad__c, 
            	ONE_Importe_Primera_Mensualidad__c, ONE_Observaciones_Generales__c, ONE_ID_SAP__c, ONE_Fecha_de_Subida_a_SAP__c, ONE_Datos_Incorrectos_Contrato__c
            FROM ONE_Contrato__c
            WHERE ONE_Compania_Aseguradora__c = :compania
            AND ONE_Pol__c = :pol
            AND ONE_Ramo__c = :ramo
        ];
    }
}
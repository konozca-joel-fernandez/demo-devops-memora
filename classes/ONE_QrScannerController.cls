/**
* File Name: ONE_QrScannerController
* Description: 	Controller for the LWC QR Scanner
* Date: 16/10/2024
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: 
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		16/10/2024		Marc Cervilla  		Class creation
* ==================================================s=================================================================
*/

public with sharing class ONE_QrScannerController {

    @AuraEnabled
    public static Boolean verifyQRCode(String qrCode, Id taskId) {
        try {

            System.debug('IN VERIFYQRCODE - inputs:');
            System.debug('qrCode ' + qrCode);
            System.debug('taskId ' + taskId);

            // Get Id to verify
            ONE_Tarea__c tarea = [
                SELECT Id, ONE_Expediente__r.ONE_Difunto__c, ONE_Aviso__r.ONE_Difunto__c, ONE_QR_Escaneado_Correctamente__c
                FROM ONE_Tarea__c
                WHERE Id = :taskId
                LIMIT 1
            ];

            if(tarea == null) {
                System.debug('ERROR: TAREA == NULL');
                return false;
            }
            
            String accountId = tarea.ONE_Expediente__r != null ? tarea.ONE_Expediente__r.ONE_Difunto__c : tarea.ONE_Aviso__r.ONE_Difunto__c;

            System.debug('AccountId: ' + accountId);

            // Verify QRCode = AccountId
            if (qrCode == accountId) {
                // OK
                tarea.ONE_QR_Escaneado_Correctamente__c = true;
                update tarea;
                return true;
            } else {
                // KO
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error en la verificación del código QR.');
        }
    }



}
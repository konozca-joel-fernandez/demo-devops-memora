/**
* File Name: ONE_GetQRWebService
* Description: 	Web Service to get the QR from external services
* Date: 03/10/2024
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: 
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		03/10/2024		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

@RestResource(urlMapping='/ONE_getQR/*')
global with sharing class ONE_GetQRWebService {

    @HttpGet
    global static void getQR() {
        
        RestRequest request = RestContext.request;

        // Get register id from the URL
        String tareaId = request.requestURI.substringAfter('/ONE_getQR/');
        
        // Init response
        RestResponse result = RestContext.response;
        result.addHeader('Content-Type', 'application/json');

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('success', false);
        responseMap.put('error', null);
        responseMap.put('data', null);

        // Verify if Id is valid
        if (String.isBlank(tareaId) || !tareaId.startsWith('a0s')) {
            responseMap.put('error', 'ID de registro no válido.');
            result.statusCode = 400;
            result.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            logIntegration(tareaId, result);
            return;
        }
        
        // Search for QR
        try {

            List<ONE_Tarea__c> tareas = [
                SELECT 
                    ONE_Aviso__r.ONE_Difunto__c,
                    ONE_Aviso__r.ONE_Difunto__r.ONE_QR_Asociado__c,
                    ONE_Aviso__r.ONE_Difunto__r.ONE_QR_Desactualizado_FC__c
                FROM ONE_Tarea__c WHERE Id = :tareaId LIMIT 1
            ];

            String difuntoId;
            Boolean qrAsociado = false;
            Boolean qrDesactualizado = false;

            if (!tareas.isEmpty()) {
                ONE_Tarea__c tarea = tareas[0];
                difuntoId = tarea.ONE_Aviso__r?.ONE_Difunto__c;
                qrAsociado = tarea.ONE_Aviso__r?.ONE_Difunto__r?.ONE_QR_Asociado__c;
                qrDesactualizado = tarea.ONE_Aviso__r?.ONE_Difunto__r?.ONE_QR_Desactualizado_FC__c;
            }

            if(difuntoId == null) {
                responseMap.put('error', 'No hay difunto asociado al Aviso');
                result.statusCode = 402;
                result.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                logIntegration(tareaId, result);
                return;
            }
            else if (qrAsociado == false) {
                responseMap.put('error', 'El difunto no tiene QR asociado');
                result.statusCode = 404;
                result.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                logIntegration(tareaId, result);
                return;
            }

            // Get file related with the record
            List<ContentDocumentLink> contentLinks = [
                SELECT ContentDocument.LatestPublishedVersion.VersionData 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :difuntoId AND ContentDocument.LatestPublishedVersion.CodigoQR__c = true
            ];
            
            if (contentLinks.size() != 1) {
                throw new QRCustomException('No se encontró ningún código QR o se encontró más de uno.');
            }
        
            // Get base64 data
            Blob qrFileBlob = contentLinks[0].ContentDocument.LatestPublishedVersion.VersionData;
            String qrFileBase64 = EncodingUtil.base64Encode(qrFileBlob);
            
            // Exit response
            responseMap.put('success', true);
            responseMap.put('data', new Map<String, Object>{
                'qrBase64' => qrFileBase64
            });
            result.statusCode = 200;
            result.responseBody = Blob.valueOf(JSON.serialize(responseMap));

            // QR Updated in external system, assign to false again
            if (qrDesactualizado) {
                Account accountToUpdate = new Account(
                    Id = difuntoId,
                    ONE_QR_Desactualizado_FC__c = false
                );
                update accountToUpdate;
            }
            
            //logIntegration(tareaId, result);
            return;

        } catch (Exception e) {
            // Manage error and log it
            responseMap.put('error', 'Error al obtener el QR: ' + e.getMessage());
            result.statusCode = 500;
            result.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            logIntegration(tareaId, result);
        }
    }

    // Function to log integration details
    private static void logIntegration(String tareaId, RestResponse result) {
        ONE_CommonUtils.createInboundIntegrationLog(
            'ONE_QrCodeController',
            tareaId,
            result.responseBody.toString(),
            RestContext.request.httpMethod,
            'SF_QR'
        );
    }
    
    global class QRCustomException extends Exception {}

}
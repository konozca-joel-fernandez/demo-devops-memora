/**
* File Name: ONE_Generacion_QR_Esquelas_Controller
* Description: 	Method to save the QR code generated in the linked entity specified in the parameter
* Date: 18/09/2024
*
* Copyright: Konozca Consulting
* @author: Marc Pàmies
* Test: ONE_GeneracionQREsquelasControllerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		27/06/2025		Marc Pàmies  		Class creation
* ===================================================================================================================
*/

public with sharing class ONE_Generacion_QR_Esquelas_Controller {

    @AuraEnabled
    public static String saveAndLinkQrEsquela(String qrCodeBase64, Id linkedEntity) {
        try {
            List<ONE_Tarea__c> tarea = [SELECT ONE_Expediente__r.ONE_Difunto__c, ONE_Expediente__r.Name FROM ONE_Tarea__c WHERE Id = :linkedEntity LIMIT 1];

            ONE_Expediente__c servicio;

            if (tarea.isEmpty()) {
                servicio = [SELECT ONE_Difunto__c, Name FROM ONE_Expediente__c WHERE Id = :linkedEntity LIMIT 1];
            }
            
            Id linkedEntityId = tarea.isEmpty() == true ? servicio.ONE_Difunto__c : tarea[0].ONE_Expediente__r.ONE_Difunto__c;
            String servicioId = tarea.isEmpty() == true ? servicio.Name : tarea[0].ONE_Expediente__r.Name;
			
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Esquela_QR_' + servicioId + '_' + System.now().format('dd-MM-yyyy HH:mm') + '.png';
            contentVersion.PathOnClient = 'Esquela_QR_' + servicioId + '_' + System.now().format('dd-MM-yyyy HH:mm') + '.png';
            contentVersion.VersionData = EncodingUtil.base64Decode(qrCodeBase64);
            contentVersion.IsMajorVersion = true;
            
            insert contentVersion;
            
            String conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = conDocId;
            contentDocumentLink.LinkedEntityId = linkedEntityId;
            contentDocumentLink.ShareType = 'V';

            insert contentDocumentLink;
            
            return contentVersion.Id;

        } catch (Exception e) {
            System.debug('Unexpected Error during QR code creation: ' + e.getMessage());
            return null;
        }
    }

    @InvocableMethod(label='Generate Link for QR Code' description='Generates a link for the QR code')
    public static List<String> generateLinkForQrCode(List<String> difuntoName) {
        List<String> links = new List<String>();
        for (String name : difuntoName) {
            links.add(obtenerUrlEsquela(name));
        }
        return links;
    }

    public static String obtenerUrlEsquela(String nombreDifunto) {
        if (String.isBlank(nombreDifunto)) {
            return '';
        }

        System.debug(nombreDifunto);
        
        String endpoint = [SELECT ONE_Resource__c FROM ONE_Integration_endpoint__mdt WHERE DeveloperName = 'WEB_MEMORA' LIMIT 1].ONE_Resource__c;
        
        String url = endpoint + EncodingUtil.urlEncode(nombreDifunto, 'UTF-8');

        System.debug('URL to fetch: ' + url);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        //request.setHeader('Authorization', 'Basic dXNlcjE6dXNlcjE=');
        try {
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                System.debug('Response Body: ' + response.getBody());
                String responseBody = response.getBody();
                if (responseBody != null && responseBody != '[]') {
                    List<Object> result = (List<Object>) JSON.deserializeUntyped(responseBody);
                    if (!result.isEmpty()) {
                        Map<String, Object> item = (Map<String, Object>) result[0];
                        String urlEsquela = (String) item.get('view_node');
                        urlEsquela = urlEsquela + '?utm_source=pasquines&amp;utm_medium=qr&amp;utm_campaign=tra_esqu_mem_es';
                        return urlEsquela;
                    }
                }
                return '';
            } else {
                System.debug('Error HTTP: ' + response.getStatusCode());
                return 'Error HTTP: ' + response.getStatusCode();
            }
        } catch (Exception ex) {
            System.debug('Error en llamada HTTP: ' + ex.getMessage());
            return 'Error en llamada HTTP: ' + ex.getMessage();
        }
    }
}
/**
* File Name: ONE_QrCodeController
* Description: 	Functions to generate the PDF Document with QR
* Date: 18/09/2024
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: ONE_QrCodeControllerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		18/09/2024		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

public with sharing class ONE_QrCodeController {

    @AuraEnabled
    public static String createQRFlow(String qrCodeBase64, String accountId) {
        try {
            // Check if the Account exists and if a QR is already associated
            List<Account> accounts = [SELECT Id, FirstName, LastName, ONE_QR_Asociado__c FROM Account WHERE Id = :accountId LIMIT 1];

            if (accounts.isEmpty()) {
                System.debug('Account not found');
                return null;
            }

            Account accountToUpdate = accounts[0];
            String accountName = accountToUpdate.FirstName + ' ' + accountToUpdate.LastName;

            // Create QR contentVersion from base64 data
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'QR Code - ' + accountName + '.png';
            contentVersion.PathOnClient = 'QR Code.png';
            contentVersion.VersionData = EncodingUtil.base64Decode(qrCodeBase64);
            contentVersion.IsMajorVersion = true;
            
            insert contentVersion;


            System.debug('contentVersion: ' + contentVersion.Id);
            return contentVersion.Id;

        } catch (Exception e) {
            System.debug('Unexpected Error during QR code creation: ' + e.getMessage());
            return null;
        }

    }

    
    @AuraEnabled
    public static String createQRAuto(String qrCodeBase64, String accountId) {
        
        // statusCode == 0 -> Unexpected error
        // statusCode == 1 -> QR already associated
        // statusCode == 2 -> QR Code generated correctly, we call generateAndLinkPDF
        // statusCode == 3 -> Account not found
        Integer statusCode = 0;
        String contentDocumentId = null;
        
        Map<String, Object> responseMap = new Map<String, Object>();

        try {

            Account accountToUpdate = null;

            List<Account> accounts = [SELECT Id, FirstName, LastName, ONE_QR_Asociado__c, ONE_Fecha_De_Defuncion2__c FROM Account WHERE Id = :accountId LIMIT 1];
            if (!accounts.isEmpty()) {
                accountToUpdate = accounts[0];
            }
    
            if (accountToUpdate == null) {
                System.debug('Account not found');
                statusCode = 3;
                responseMap.put('statusCode', statusCode);
                return JSON.serialize(responseMap);
            }
    
            String accountName = accountToUpdate.FirstName + ' ' + accountToUpdate.LastName;

            String fechaDef = '';
            if (accountToUpdate.ONE_Fecha_De_Defuncion2__c != null) {
                fechaDef = accountToUpdate.ONE_Fecha_De_Defuncion2__c.format('dd/MM/YYYY');
            }
            
            if (accountToUpdate.ONE_QR_Asociado__c) {
                System.debug('QR already associated');
                statusCode = 1;
                responseMap.put('statusCode', statusCode);
                return JSON.serialize(responseMap);
            }
    
            // Create a ContentVersion from the base64 data
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'QR Code - ' + accountName + '.png';
            contentVersion.PathOnClient = 'QRCode.png';
            contentVersion.VersionData = EncodingUtil.base64Decode(qrCodeBase64);
            contentVersion.IsMajorVersion = true;
            insert contentVersion;
    
            // Call @future method to generate PDF with the QR and link it to account
            generateAndLinkPDF(accountId, accountName, contentVersion.Id, fechaDef);
    
            System.debug('generateAndLinkPDF called sucessfully');
            statusCode = 2;
            responseMap.put('statusCode', statusCode);
            return JSON.serialize(responseMap);
    
        } catch (Exception e) {
            System.debug('Unexpected Error during QR code creation: ' + e.getMessage());
            responseMap.put('statusCode', 0);
            responseMap.put('message', 'Unexpected error: ' + e.getMessage());
            return JSON.serialize(responseMap);
        }
    }

    
    // recordId can be from different objects so we need to get Account always
    @AuraEnabled
    public static String getAccountId(String recordId) {

        System.debug('RECORD ID: ' + recordId);

        String prefix = String.valueOf(recordId).substring(0, 3);
        String accountId = null;

        switch on prefix {
            //Account
            when '001' {
                accountId = recordId;
            }
            //ONE_Expediente__c
            when 'a0T' {
                List<ONE_Expediente__c> servicios = [SELECT ONE_Difunto__c FROM ONE_Expediente__c WHERE Id = :recordId LIMIT 1];
                if (!servicios.isEmpty()) {
                    accountId = servicios[0].ONE_Difunto__c;
                }
            }
            //ONE_Caso__c
            when 'a0E' {
                List<ONE_Caso__c> avisos = [SELECT ONE_Difunto__c FROM ONE_Caso__c WHERE Id = :recordId LIMIT 1];
                if (!avisos.isEmpty()) {
                    accountId = avisos[0].ONE_Difunto__c;
                }
            }
        }

        System.debug('ACCOUNT ID: ' + accountId);

        return accountId;
    }

    
    @future(callout=true)
    public static void generateAndLinkPDF(String accountId, String accountName, String qrContentVersionId, String fechaDef) {
        try {

            PageReference pdfPage = Page.oneQrPrinted;
            pdfPage.getParameters().put('accountName', accountName);
            pdfPage.getParameters().put('accountId', accountId);
            pdfPage.getParameters().put('contentVersionId', qrContentVersionId);
            pdfPage.getParameters().put('fechaDef', fechaDef);

            Blob pdfContent = null;
            if(!test.isRunningTest()){
                pdfContent = pdfPage.getContentAsPDF();
            }
            else {
                pdfContent = Blob.valueOf('Simulated PDF Content');
            }

            ContentVersion pdfContentVersion = new ContentVersion();
            pdfContentVersion.Title = 'Etiqueta QR - ' + accountName + '.pdf';
            pdfContentVersion.PathOnClient = 'PDF QR Code.pdf';
            pdfContentVersion.VersionData = pdfContent;
            pdfContentVersion.IsMajorVersion = true;
            pdfContentVersion.CodigoQR__c = true;

            insert pdfContentVersion;

            // Delete QR image
            deleteQRImage(qrContentVersionId);

            // Query to get the ContentDocumentId of the inserted ContentVersion
            ContentVersion insertedPdfContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :pdfContentVersion.Id LIMIT 1];
    
            // Link the ContentDocument to the Account
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = insertedPdfContentVersion.ContentDocumentId;
            contentDocumentLink.LinkedEntityId = accountId;
            contentDocumentLink.ShareType = 'V';  // Viewer permissions
            contentDocumentLink.Visibility = 'AllUsers';
            insert contentDocumentLink;
    
            
            // Update the Account to reference that a QR code is now associated
            Account accountToUpdate  = [SELECT Id, ONE_QR_Asociado__c FROM Account WHERE Id = :accountId LIMIT 1];

            accountToUpdate.ONE_QR_Asociado__c = true;
            update accountToUpdate;
            


        } catch (Exception e) {
            System.debug('Error en el metodo futuro generando el PDF: ' + e.getMessage());
        }
    }



    //generate the PDF from flow
    @InvocableMethod(label='Generate PDF from QR' description='Generates a PDF from a QR Code and Account ID')
    public static List<FlowOutput> generatePDF(List<FlowInput> inputs) {

        List<FlowOutput> outputs = new List<FlowOutput>();

        try {
            // Get inputs
            FlowInput input = inputs.get(0);

            Id accountId = input.flowAccountId;
            Id qrContentVersionId = input.flowQRContentVersionId;

            // Query the account to get the name
            Account account = [SELECT FirstName, LastName, ONE_Fecha_De_Defuncion2__c FROM Account WHERE Id = :accountId LIMIT 1];
            String accountName = account.FirstName + ' ' + account.LastName;

            String fechaDef = '';
            if (account.ONE_Fecha_De_Defuncion2__c != null) {
                fechaDef = account.ONE_Fecha_De_Defuncion2__c.format('dd/MM/YYYY');
            }

            // Generate PDF from Visualforce Page
            PageReference pdfPage = Page.oneQrPrinted;
            pdfPage.getParameters().put('accountName', accountName);
            pdfPage.getParameters().put('accountId', accountId);
            pdfPage.getParameters().put('contentVersionId', qrContentVersionId);
            pdfPage.getParameters().put('fechaDef', fechaDef);

            Blob pdfContent = null;
            if(!test.isRunningTest()){
                pdfContent = pdfPage.getContentAsPDF();
            }
            else {
                pdfContent = Blob.valueOf('Simulated PDF Content');
            }

            // Create ContentVersion for the PDF
            ContentVersion pdfContentVersion = new ContentVersion();
            pdfContentVersion.Title = 'Etiqueta QR - ' + accountName + '.pdf';
            pdfContentVersion.PathOnClient = 'PDF QR Code.pdf';
            pdfContentVersion.VersionData = pdfContent;
            pdfContentVersion.IsMajorVersion = true;
            pdfContentVersion.CodigoQR__c = true;

            insert pdfContentVersion;

            // Delete QR image
            deleteQRImage(qrContentVersionId);

            // Create output
            FlowOutput output = new FlowOutput();
            output.flowPDFContentVersionId = pdfContentVersion.Id;
            output.success = true;
            outputs.add(output);

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());

            // In case of error, return failure status
            FlowOutput output = new FlowOutput();
            output.success = false;
            outputs.add(output);
        }

        return outputs;
    }


    // Once the PDF is created, we delete the image
    public static void deleteQRImage(Id qrContentVersionId) {

        // Get ContentDocument to delete
        ContentVersion[] cvInserted = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :qrContentVersionId];

        if (cvInserted.size() != 1) {
            System.debug('No content version found at delete with ID: ' + qrContentVersionId);
            return;
        }

        Id contentDocId = cvInserted[0].ContentDocumentId;

        ContentDocument cdToDelete = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId LIMIT 1];

        delete cdToDelete;

        return;
    }



    // Class for Flow Inputs
    public class FlowInput {
        @InvocableVariable
        public Id flowAccountId;
        @InvocableVariable
        public Id flowQRContentVersionId;
    }

    // Class for Flow Outputs
    public class FlowOutput {
        @InvocableVariable
        public Id flowPDFContentVersionId;
        @InvocableVariable
        public Boolean success;
    }

}
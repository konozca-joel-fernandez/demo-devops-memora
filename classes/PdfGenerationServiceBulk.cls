/**
* File Name: PdfGenerationServiceBulk
* Description: 	This class generate the pdf from ONE_Documento__c records.
                The original class is PdfGenerationService but this one is bulkified.
* Date: 14/01/2024
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: 
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		14/01/2024		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

public without sharing class PdfGenerationServiceBulk {

    private Set<Id> docIds;
    private Map<Id,String> documento2RecordTypeName;
    private Map<Id,String> documento2RecordTypeLabel;
    private Map<Id,String> documento2ServiceName;
    private Map<Id, Id> documento2serviceId;

    private String language;
    
    public PdfGenerationServiceBulk(List<FlowInput> flowInputs) {
        
        FlowInput flowInput = flowInputs.get(0);

        this.language = flowInput.language;

        this.docIds = new Set<Id>();
        this.documento2RecordTypeName = new Map<Id, String>();
        this.documento2RecordTypeLabel = new Map<Id, String>();
        this.documento2ServiceName = new Map<Id, String>();

        this.documento2serviceId = new Map<Id, Id>();

        for (ONE_Documentos__c doc : flowInput.docList) {
            this.docIds.add(doc.Id);
        }

        // Make a query again to obtain the relation fields
        List<ONE_Documentos__c> documentos = [SELECT Id, RecordType.DeveloperName, RecordType.Name, ONE_Servicio__c, ONE_Servicio__r.Name FROM ONE_Documentos__c WHERE Id IN :this.docIds];

        for(ONE_Documentos__c doc : documentos) {
            this.documento2RecordTypeName.put(doc.Id, doc.RecordType.DeveloperName);
            this.documento2RecordTypeLabel.put(doc.Id, doc.RecordType.Name);
            this.documento2ServiceName.put(doc.Id, doc.ONE_Servicio__r.Name);
            this.documento2serviceId.put(doc.Id, doc.ONE_Servicio__c);
        }
        
    }
    
    @InvocableMethod
    public static List<FlowOutput> createAndLinkPdf(List<FlowInput> flowInputs) {

        // Create an instance of this class and store values from the flow
        PdfGenerationServiceBulk service = new PdfGenerationServiceBulk(flowInputs);

        return service.createAndLinkPdfs();
    }

    
    public List<FlowOutput> createAndLinkPdfs() {

        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<Id> contentDocumentIds = new List<Id>();

        //Integer limitQueries = Limits.getLimitQueries();
        
        try {
            for (Id docId : this.docIds) {
                Blob pdfContent = buildPdfContent(docId);
                String fileName = getTitleLabel(docId);

                ContentVersion versionData = new ContentVersion();
                //doing this we already link with document for default!!
                versionData.firstPublishLocationId = docId;
                versionData.ContentLocation = 'S';
                versionData.VersionData = pdfContent;
                versionData.Title = fileName;
                versionData.PathOnClient = fileName;
                if (ContentVersion.sObjectType.getDescribe().isCreateable()) {
                    contentVersions.add(versionData);
                }
                else {
                    return new List<FlowOutput>{new FlowOutput(false, null, null, 'El usuario no tiene permisos para guardar documentos')};
                }

                //System.debug('LIMITS: ' + Limits.getQueries() + ' / ' + limitQueries);
                
            }

            // Insert Content Versions
            if (!contentVersions.isEmpty()) {
                insert contentVersions;

                // Get new ContentDocument Ids

                List<ContentVersion> newContentVersions = [SELECT Id, ContentDocumentId, Title, FirstPublishLocationId FROM ContentVersion WHERE Id IN :contentVersions];

                // Create links (link with document already created with firstPublishLocationId)
                List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();

                for (ContentVersion cv : newContentVersions) {
                    contentDocumentIds.add(cv.ContentDocumentId);

                    // Link With ONE_Servicio__c record
                    Id relatedServicioId = documento2serviceId.get(cv.FirstPublishLocationId);

                    if (relatedServicioId != null) {
                        
                        // Link With ONE_Servicio__c record
                        ContentDocumentLink linkWithServicio = new ContentDocumentLink(
                            ContentDocumentId = cv.ContentDocumentId,
                            LinkedEntityId = relatedServicioId,
                            ShareType = 'V'
                        );
                        documentLinks.add(linkWithServicio);
                    }

                }

                if (!documentLinks.isEmpty()) {
                    insert documentLinks;
                }

            }

            //System.debug(contentDocumentIds);

            return new List<FlowOutput>{new FlowOutput(true, 'Success', contentDocumentIds, null)};

        } catch (Exception ex) {
            return new List<FlowOutput>{new FlowOutput(false, null, null, ex.getMessage())};
        }
    }

    private Blob buildPdfContent(Id docId) {

        PageReference pageRef = Page.PdfDocument;
        
        pageRef.getParameters().put('documentoId', docId);
        pageRef.getParameters().put('language', this.language);
        pageRef.getParameters().put('documentoRecordTypeName', this.documento2RecordTypeName.get(docId));
        
        if(Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String getTitleLabel(Id docId) {
        String dateTimeString = Datetime.now().format('dd-MM-yyyy HH:mm');
        return documento2RecordTypeLabel.get(docId) + ' ' + documento2ServiceName.get(docId) + ' (' + dateTimeString + ').pdf';
    }

        
    
    public virtual class FlowInput {
        @InvocableVariable
        public List<ONE_Documentos__c> docList;
        @InvocableVariable
        public String language;
    }
    
    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String successMessage;
        @InvocableVariable
        public List<Id> cdList;
        
        public FlowOutput(Boolean success, String successMessage, List<Id> cdList, String errorMessage) {
            this.success = success;
            this.successMessage = successMessage;
            this.cdList = cdList;
            this.errorMessage = errorMessage;
        }
    }
}
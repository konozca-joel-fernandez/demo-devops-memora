//26 Nov 2024 Last Modified by Alex Climent
public without sharing class PdfGenerationService {

    private Id documentoId;
    private String documentoRecordTypeName;
    private String documentoRecordTypeLabel;
    private String serviceName;
    private String language;
    private Boolean anadirListado = false;
    
    public PdfGenerationService(List<FlowInput> flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.documentoId = flowInput.documentoId;
        this.documentoRecordTypeName = flowInput.documentoRecordTypeName;
        this.documentoRecordTypeLabel = flowInput.documentoRecordTypeLabel;
        this.serviceName = flowInput.serviceName;
        this.language = flowInput.language;
        if (flowInput.anadirListado != null && flowInput.anadirListado) this.anadirListado = flowInput.anadirListado;
    }
    
    @InvocableMethod
    public static List<FlowOutput> createAndLinkPdf(List<FlowInput> flowInputs) {

        PdfGenerationService service = new PdfGenerationService(flowInputs);
        return service.createAndLinkPdf();
    }

    public List<FlowOutput> createAndLinkPdf() {
        String contentDocumentId = '';
        try {
            Blob pdfContent = buildPdfContent();
            Id pdfId = savePdf(pdfContent, documentoId, getTitleLabel());
            contentDocumentId = pdfId;    	
        	linkWithParent(pdfId, documentoId);   // Enlazar con el Documento 
            linkWithServicioOrTarea(pdfId, documentoId); // Enlazar con Servicio o Tarea
        	linkWithOpportunity(pdfId, documentoId); // Enlazar con la Oportunidad
        } catch (Exception ex) {
            return new List<FlowOutput>{new FlowOutput(false, null, null, ex.getMessage())};
        }
        return new List<FlowOutput>{new FlowOutput(true, 'Success', contentDocumentId, null)};
    }
    
    private Blob buildPdfContent() {

        PageReference pageRef = Page.PdfDocument;
        
        pageRef.getParameters().put('documentoId', documentoId);
        pageRef.getParameters().put('language', language);
        pageRef.getParameters().put('documentoRecordTypeName', documentoRecordTypeName);
        
        if(Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String getTitleLabel() {

        String dateTimeString = Datetime.now().format('dd-MM-yyyy HH;mm');
        return documentoRecordTypeLabel + ' ' + serviceName + ' ('+ dateTimeString +').pdf';
    }

    private Id savePdf(Blob pdfContent, Id parentId, String fileName) {

        ContentVersion versionData = new ContentVersion();
        versionData.firstPublishLocationId = userinfo.getUserId();
        versionData.ContentLocation = 'S';
        versionData.VersionData = pdfContent;
        versionData.Title = fileName;
        versionData.PathOnClient = fileName;
        if (ContentVersion.sObjectType.getDescribe().isCreateable()) {
            insert versionData;
        }


        Id contentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :versionData.Id
        ].ContentDocumentId;
        return contentDocumentId;
    }

    private void linkWithParent(Id contentDocumentId, Id parentId) {

        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = contentDocumentId;
        conDocLink.LinkedEntityId = parentId;
        if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) {
            insert conDocLink;
        }
    }
    
    
    private void linkWithServicioOrTarea(Id contentDocumentId, Id parentId) {
        
        ONE_Documentos__c documentos = [SELECT Id, RecordType.DeveloperName, ONE_Servicio__c, ONE_Tarea__c FROM ONE_Documentos__c WHERE Id =: parentId];
        if (documentos.ONE_Tarea__c  != null) {
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentDocumentId;
            conDocLink.LinkedEntityId = documentos.ONE_Tarea__c;
            if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) {
                insert conDocLink;
            }
        }
        if (documentos.ONE_Servicio__c  != null) {
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentDocumentId;
            conDocLink.LinkedEntityId = documentos.ONE_Servicio__c;
            if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) {
                insert conDocLink;
            }
            if (anadirListado){
                ONE_Expediente__c servicio = [SELECT Id, ONE_Documentos_en_el_Servicio__c FROM ONE_Expediente__c WHERE Id =: documentos.ONE_Servicio__c];
                if (servicio.ONE_Documentos_en_el_Servicio__c == null){
                    servicio.ONE_Documentos_en_el_Servicio__c = documentos.RecordType.DeveloperName;
                    update servicio;
                } else if (!servicio.ONE_Documentos_en_el_Servicio__c.contains(documentos.RecordType.DeveloperName)){
                    servicio.ONE_Documentos_en_el_Servicio__c += ';' + documentos.RecordType.DeveloperName;
                    update servicio;
                }
            }
        }
    }
    
    
    private void linkWithOpportunity(Id contentDocumentId, Id documentoId) {
            
        
        ONE_Documentos__c documento = [ // consultamos el documento para obtener la oportunidad relacionada
            SELECT Id, ONE_Oportunidad__c
            FROM ONE_Documentos__c
            WHERE Id = :documentoId
            LIMIT 1
        ];
    
        if (documento.ONE_Oportunidad__c != null) { // verificamos si hay una oportunidad asociada
            
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentDocumentId;
            conDocLink.LinkedEntityId = documento.ONE_Oportunidad__c;
    
            if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) { //validamos permisos y creamos el link entre documento y oportunidad
                insert conDocLink;
            } 
        } 
    }

    
  

    
    public virtual class FlowInput {
        @InvocableVariable
        public Id documentoId;
        @InvocableVariable
        public String documentoRecordTypeName;
        @InvocableVariable
        public String documentoRecordTypeLabel;
        @InvocableVariable
        public String serviceName;
        @InvocableVariable
        public String language;
        @InvocableVariable
        public Boolean anadirListado;
    }
    
    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String successMessage;
        @InvocableVariable
        public String contentDocumentId;
        
        public FlowOutput(Boolean success, String successMessage, String contentdocumentId, String errorMessage) {
            this.success = success;
            this.successMessage = successMessage;
            this.contentDocumentId = contentDocumentId;
            this.errorMessage = errorMessage;
        }
    }
}
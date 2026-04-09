public without sharing class ONE_CompanyPDFGenerationService {

    private Id casoId;

    public class FlowInputs {
        @InvocableVariable
        public String casoId;
    }
    
    
    public class FlowOutputs {
        @InvocableVariable
        public Boolean success;
    }

    public ONE_CompanyPDFGenerationService(Id casoId) {

        this.casoId = casoId;
    }

    @InvocableMethod
    public static List<FlowOutputs> createAndLinkPdf(List<FlowInputs> flowInputs) {

        FlowInputs input = flowInputs.get(0);
        Id casoId = input.casoId;
        ONE_CompanyPDFGenerationService service = new ONE_CompanyPDFGenerationService(casoId);
        service.createAndLinkPdf();

        FlowOutputs output = new FlowOutputs();
        output.success = true;

        return new List<FlowOutputs>{output};
    }

    public void createAndLinkPdf() {

        try {
            Blob pdfContent = buildPdfContent();
            Id pdfId = savePdf(pdfContent, getTitleLabel());
            linkWithCaso(pdfId, casoId);
        } catch (Exception ex) {
            // TODO: handle exception
        }
    }
    
    private Blob buildPdfContent() {

        PageReference pageRef = Page.ONE_CompanyPdfDocument;
        
        pageRef.getParameters().put('casoId', casoId);
        
        if(Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String getTitleLabel() {

        String casoName = [SELECT Name FROM ONE_Caso__c WHERE Id = :casoId LIMIT 1]?.Name;
        String dateTimeString = Datetime.now().format('dd-MM-yyyy HH;mm');
        return casoName + ' ('+ dateTimeString +').pdf';
    }

    private Id savePdf(Blob pdfContent, String fileName) {

        ContentVersion versionData = new ContentVersion();
        versionData.ONE_PDF_Compania__c = true;
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

    private void linkWithCaso(Id contentDocumentId, Id casoId) {

        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = contentDocumentId;
        conDocLink.LinkedEntityId = casoId;
        if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) {
            insert conDocLink;
        }
    }
}
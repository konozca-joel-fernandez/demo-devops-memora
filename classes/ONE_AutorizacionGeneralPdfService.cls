public class ONE_AutorizacionGeneralPdfService { 
    private Id documentosId;
    private List<FlowInput> inputs;
    
    
    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_AutorizacionGeneralPdfService service = new ONE_AutorizacionGeneralPdfService(inputs);
        return service.createAndLinkPdf(ONE_PdfGeneratorHelper.getTitleLabel('Solicitud_de_Autorizacion'));
    }
    
    public ONE_AutorizacionGeneralPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }
    
    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.documentosId = datosInput.documentosId;
        String language = datosInput.language;
        
        PageReference pageRef = Page.ONE_AutorizacionGeneralPdf;
        
        pageRef.getParameters().put('documentosId', documentosId);
        pageRef.getParameters().put('language', language);
        
        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }
    
    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(String fileName) {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.documentosId, fileName,ONE_CommonConstants.DOCUMENT_TAG_AUTORIZACION_GENERAL);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.documentosId);
            ONE_PdfGeneratorHelper.linkWithServico(pdfId, input.documentosId);
            
        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
                }
        return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
            }
    
    public virtual class FlowInput {
        @InvocableVariable
        public Id documentosId;
        @InvocableVariable
        public String language;
    }
}
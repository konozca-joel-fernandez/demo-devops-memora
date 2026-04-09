public class ONE_NecrologicaPdfService {
    
    private Id accountOrLugarID;
    private String level;
    private String language;    
    private String startDate;   
    private String endDate;   
    private List<FlowInput> inputs;
      
    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        system.debug('createAndLinkPdf');
        ONE_NecrologicaPdfService service = new ONE_NecrologicaPdfService(inputs);
        return service.createAndLinkPdf(ONE_PdfGeneratorHelper.getTitleLabel('Necrologica'));
    }
    
    public ONE_NecrologicaPdfService(List<FlowInput> inputs) {
        system.debug('ONE_NecrologicaPdfService');
        this.inputs = inputs;
        system.debug('inputs-->' + inputs );
    }
    
    private Blob buildPdfContent(FlowInput input) {
        system.debug('buildPdfContent');
        FlowInput datosInput = (FlowInput) input;
        this.accountOrLugarID = datosInput.accountOrLugarID;
        this.level = datosInput.level;
        this.language = datosInput.language;
        this.startDate = datosInput.startDate;
        this.endDate = datosInput.endDate;
        
        PageReference pageRef = Page.ONE_NecrologicaPdf;
        
        pageRef.getParameters().put('accountOrLugarID', accountOrLugarID);
        pageRef.getParameters().put('level', level);
        pageRef.getParameters().put('language', language);
        pageRef.getParameters().put('startDate', startDate);
        pageRef.getParameters().put('endDate', endDate);
        
        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }
    
    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(String fileName) {
        system.debug('createAndLinkPdf');

        try {
            FlowInput input = inputs.get(0);
        	system.debug('input-->' + input );
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.accountOrLugarID, fileName, ONE_CommonConstants.DOCUMENT_TAG_NECROLOGICA);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.accountOrLugarID);
            
        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
                }
        return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
            }
    
    public virtual class FlowInput {

        @InvocableVariable
        public Id accountOrLugarID;
        @InvocableVariable
        public String level;
        @InvocableVariable
        public String language;
        @InvocableVariable
        public String startDate;
        @InvocableVariable
        public String endDate;
    }
}
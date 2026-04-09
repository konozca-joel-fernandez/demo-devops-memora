public class ONE_SuplidoSegurCaixaPdfService {
    private Id ordenDeVentaID;
    private List<FlowInput> inputs;
    
    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_SuplidoSegurCaixaPdfService service = new ONE_SuplidoSegurCaixaPdfService(inputs);
        return service.createAndLinkPdf(ONE_PdfGeneratorHelper.getTitleLabel('Suplido_Segur_Caixa'));
    }
    
    public ONE_SuplidoSegurCaixaPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }
    
    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.ordenDeVentaID = datosInput.ordenDeVentaID;
        
        PageReference pageRef = Page.ONE_SuplidoSegurCaixaPdf;
        
        pageRef.getParameters().put('ordenDeVentaID', ordenDeVentaID);        
        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }
    
    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(String fileName) {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.ordenDeVentaID, fileName,ONE_CommonConstants.DOCUMENT_TAG_SUPLIDO_SEGUR_CAIXA);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.ordenDeVentaID);
            ONE_PdfGeneratorHelper.linkWithServicoFromOrdenDeVenta(pdfId, input.ordenDeVentaID);
            
        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
                }
        return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
            }
    
    public virtual class FlowInput {
        @InvocableVariable
        public Id ordenDeVentaID;

    }
}
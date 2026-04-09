public with sharing class ONE_ConservacionFrioPdfService {
    private Id accountId;
    private List<FlowInput> inputs;


    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_ConservacionFrioPdfService service = new ONE_ConservacionFrioPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_ConservacionFrioPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.accountId, 'Informe Conservación Frio ' + Datetime.now().format('dd/MM/yyyy hh:mm') + '.pdf', ONE_CommonConstants.DOCUMENT_TAG_CONSERVACION_FRIO);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.accountId);
        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
        }
        return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
    }

    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.accountId = datosInput.accountId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_ConservacionFrioPdf;

        pageRef.getParameters().put('accountId', accountId);
        pageRef.getParameters().put('language', language);

        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    public virtual class FlowInput {
        @InvocableVariable
        public Id accountId;
        @InvocableVariable
        public String language;
    }
}
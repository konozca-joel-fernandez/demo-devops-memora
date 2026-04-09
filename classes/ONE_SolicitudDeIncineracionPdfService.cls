/**
 * Created by msulek003 on 09.04.2021. 
 */

public with sharing class ONE_SolicitudDeIncineracionPdfService {
    private Id documentosId;
    private List<FlowInput> inputs;


    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_SolicitudDeIncineracionPdfService service = new ONE_SolicitudDeIncineracionPdfService(inputs);
        return service.createAndLinkPdf(ONE_PdfGeneratorHelper.getTitleLabel(label.ONE_Doc_Solicitud_De_Incineracion_File_Name));
    }

    public ONE_SolicitudDeIncineracionPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.documentosId = datosInput.documentosId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_SolicitudDeIncineracionPdf;

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
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.documentosId, fileName,ONE_CommonConstants.DOCUMENT_TAG_SOLICITUD_INCINERACION);
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
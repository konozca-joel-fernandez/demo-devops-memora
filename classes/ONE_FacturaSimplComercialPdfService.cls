/**
 * Created by msulek003 on 22.04.2021.
 */

public with sharing class ONE_FacturaSimplComercialPdfService {
    private Id ordenDeVentaId;
    private List<FlowInput> inputs;


    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_FacturaSimplComercialPdfService service = new ONE_FacturaSimplComercialPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_FacturaSimplComercialPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.ordenDeVentaId, ONE_PdfGeneratorHelper.buildCommonExtendedLabel(ordenDeVentaId,true), ONE_CommonConstants.DOCUMENT_TAG_FACTURA_COMERCIAL_SIMPLIFICADA);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.ordenDeVentaId);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, [Select ONE_Servicio__c from ONE_Orden_De_Venta__c where id =: input.ordenDeVentaId].ONE_Servicio__c);

        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
        }
        return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
    }

    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.ordenDeVentaId = datosInput.ordenDeVentaId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_FacturaSimplificadaComercialPdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVentaId);
        pageRef.getParameters().put('language', language);
        pageRef.getParameters().put('isAbono', 'false');

        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    public virtual class FlowInput {
        @InvocableVariable
        public Id ordenDeVentaId;
        @InvocableVariable
        public String language;
    }
}
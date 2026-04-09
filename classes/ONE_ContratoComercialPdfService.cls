/**
 * Created by msulek003 on 20.04.2021.
 */

public with sharing class ONE_ContratoComercialPdfService {
    private Id presupuestoId;
    private List<FlowInput> inputs;

    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_ContratoComercialPdfService service = new ONE_ContratoComercialPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_ContratoComercialPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.presupuestoId, ONE_PdfGeneratorHelper.buildCommonLabel(presupuestoId,'Nº Contrato:'), ONE_CommonConstants.DOCUMENT_TAG_CONTRATO_COMERCIAL);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.presupuestoId);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, [Select ONE_Expediente__c from ONE_Presupuesto__c where id = :input.presupuestoId].ONE_Expediente__c);
        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{
                new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())
            };
        }
        return new List<ONE_PdfServiceBase.FlowOutput>{
            new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)
        };
    }

    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.presupuestoId = datosInput.presupuestoId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_ContratoComercialPdf;

        pageRef.getParameters().put('presupuestoId', presupuestoId);
        pageRef.getParameters().put('language', language);

        if (Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    public virtual class FlowInput {
        @InvocableVariable
        public Id presupuestoId;
        @InvocableVariable
        public String language;
    }
}
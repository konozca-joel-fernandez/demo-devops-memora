/**
 * Created by Miguel Serrat on 21.05.2024. 
 */

public class ONE_PresupuestoM1PdfService {
    private Id ordenDeVentaId;
    private List<FlowInput> inputs;

    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_PresupuestoM1PdfService service = new ONE_PresupuestoM1PdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_PresupuestoM1PdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            System.debug('PRE');
            Blob pdfContent = buildPdfContent(input);
            System.debug('POST');
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.ordenDeVentaId, ONE_PdfGeneratorHelper.buildCommonLabelM1(ordenDeVentaId), ONE_CommonConstants.DOCUMENT_TAG_PRESUPUESTO);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.ordenDeVentaId);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, [SELECT ONE_Servicio__c FROM ONE_Orden_De_Venta__c WHERE Id = :input.ordenDeVentaId].ONE_Servicio__c);

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
        this.ordenDeVentaId = datosInput.ordenDeVentaId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_PresupuestoM1Pdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVentaId);
        pageRef.getParameters().put('language', language);

        if (Test.isRunningTest()) {
            return Blob.valueOf('Some random String');
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
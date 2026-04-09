/**
 * Created by msulek003 on 16.04.2021. 
 */

public with sharing class ONE_PresupuestoComercialPdfService {
    private Id presupuestoId;
    private List<FlowInput> inputs;


    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_PresupuestoComercialPdfService service = new ONE_PresupuestoComercialPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_PresupuestoComercialPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            String tipoDocumento=[SELECT ONE_tipo_Documento__c FROM ONE_Presupuesto__c WHERE Id = :input.presupuestoId].ONE_tipo_Documento__c;
            String labelDocument=tipoDocumento=='ConsultaPrecios'?'Consulta Precios:':'Nº Presupuesto: ';
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.presupuestoId, ONE_PdfGeneratorHelper.buildCommonLabel(presupuestoId,labelDocument), ONE_CommonConstants.DOCUMENT_TAG_PRESUPUESTO);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.presupuestoId);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, [SELECT ONE_Expediente__c FROM ONE_Presupuesto__c WHERE Id = :input.presupuestoId].ONE_Expediente__c);

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

        PageReference pageRef = Page.ONE_PresupuestoComercialPdf;

        pageRef.getParameters().put('presupuestoId', presupuestoId);
        pageRef.getParameters().put('language', language);

        if (Test.isRunningTest()) {
            return Blob.valueOf('Some random String');
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
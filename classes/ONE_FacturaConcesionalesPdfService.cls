public with sharing class ONE_FacturaConcesionalesPdfService {
 private Id ordenDeVentaId;
    private List<FlowInput> inputs;


    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_FacturaConcesionalesPdfService service = new ONE_FacturaConcesionalesPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_FacturaConcesionalesPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    
    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            String filename = 'Anexo a Factura Nº '+ input.numFactura + '.pdf';
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.ordenDeVentaId, filename, ONE_CommonConstants.DOCUMENT_TAG_FACTURA_CONCESIONALES);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.ordenDeVentaId);
            List<String> servicios=new List<String>();
            Id servicioId=[Select ONE_Servicio__c from ONE_Orden_De_Venta__c where id =: input.ordenDeVentaId].ONE_Servicio__c;
            if(servicioId!=null){
            ONE_PdfGeneratorHelper.linkWithParent(pdfId,servicioId);
            }else{
                for(ONE_Expediente_Line_Item__c sli : [SELECT Id,ONE_Expediente__c from ONE_Expediente_Line_Item__c where ONE_Orden_De_Venta__c =: input.ordenDeVentaId]){
                    if(!servicios.contains(sli.ONE_Expediente__c)){
                        servicios.add(sli.ONE_Expediente__c);
                        ONE_PdfGeneratorHelper.linkWithParent(pdfId,sli.ONE_Expediente__c);
                    }
                    
                }
            }
        } catch (Exception ex) {
            return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(false, null, ex.getMessage())};
        }
        return new List<ONE_PdfServiceBase.FlowOutput>{new ONE_PdfServiceBase.FlowOutput(true, 'Success', null)};
    }

    private Blob buildPdfContent(FlowInput input) {
        FlowInput datosInput = (FlowInput) input;
        this.ordenDeVentaId = datosInput.ordenDeVentaId;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_FacturaConcesionalesPdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVentaId);
        pageRef.getParameters().put('language', language);

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
        @InvocableVariable
        public String numFactura;
        
    }
}
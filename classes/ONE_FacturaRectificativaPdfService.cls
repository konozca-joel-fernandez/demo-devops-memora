public with sharing class ONE_FacturaRectificativaPdfService {
    private Id abonoParcialId;
    private List<FlowInput> inputs;

    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_FacturaRectificativaPdfService service = new ONE_FacturaRectificativaPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_FacturaRectificativaPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.abonoParcialId, buildLabel(), ONE_CommonConstants.DOCUMENT_TAG_FACTURA_RECTIFICATIVA);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.abonoParcialId);
            Id servicioId=[SELECT ONE_Servicio_AP__c from ONE_Abono_Parcial__c WHERE Id = :input.abonoParcialId].ONE_Servicio_AP__c;
            if(servicioId!=null){
                ONE_PdfGeneratorHelper.linkWithParent(pdfId, servicioId);
            }else{
                 for(ONE_Expediente_Line_Item__c sli : [SELECT Id,ONE_Expediente__c from ONE_Expediente_Line_Item__c where ONE_Abono_parcial__c =: input.abonoParcialId]){
                    ONE_PdfGeneratorHelper.linkWithParent(pdfId,sli.ONE_Expediente__c);
                }
            }
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
        this.abonoParcialId = datosInput.abonoParcialId;
        String documentType = datosInput.documentType;
        String language = datosInput.language;

        PageReference pageRef = Page.ONE_FacturaRectificativaPdf;

        pageRef.getParameters().put('abonoParcialId', abonoParcialId);
        pageRef.getParameters().put('documentType', documentType);
        pageRef.getParameters().put('language', language);

        if (Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String buildLabel() {
        ONE_Abono_Parcial__c abonoParcial = [SELECT ONE_Numero_de_factura_rectificativa__c, ONE_Presupuesto_AP__r.Name, ONE_Servicio_AP__r.Name, ONE_Fecha_De_Facturacion_Rectificativa__c FROM ONE_Abono_Parcial__c WHERE Id = :abonoParcialId];
        String label = abonoParcial.ONE_Numero_de_factura_rectificativa__c != null ? 'Nº Abono Parcial ' + abonoParcial.ONE_Numero_de_factura_rectificativa__c : 'Nº Abono Parcial ';
		label += abonoParcial.ONE_Presupuesto_AP__r.Name != null ? ' / Nº Contrato: ' + abonoParcial.ONE_Presupuesto_AP__r.Name : '/ Nº Contrato: ';
        label += abonoParcial.ONE_Servicio_AP__r.Name != null ? ' / Nº Servicio: ' + abonoParcial.ONE_Servicio_AP__r.Name : ' / Nº Servicio: ' ;
        label += abonoParcial.ONE_Fecha_De_Facturacion_Rectificativa__c != null ? ' / ' + abonoParcial.ONE_Fecha_De_Facturacion_Rectificativa__c.year() + '-' + abonoParcial.ONE_Fecha_De_Facturacion_Rectificativa__c.month() + '-' + abonoParcial.ONE_Fecha_De_Facturacion_Rectificativa__c.day() : '';

        label += '.pdf';

        return label;
    }



    public virtual class FlowInput {
        @InvocableVariable
        public Id abonoParcialId;
        @InvocableVariable
        public String documentType;
        @InvocableVariable
        public String language;
    }
}
public with sharing class ONE_CancelacionAbonoParcialPdfService {
    private Id abonoParcialId;
    private List<FlowInput> inputs;

    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_CancelacionAbonoParcialPdfService service = new ONE_CancelacionAbonoParcialPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_CancelacionAbonoParcialPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.abonoParcialId, buildLabel(), ONE_CommonConstants.DOCUMENT_TAG_CANCELACION_ABONO_PARCIAL);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.abonoParcialId);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, [SELECT ONE_Servicio_AP__c from ONE_Abono_Parcial__c WHERE Id = :input.abonoParcialId].ONE_Servicio_AP__c);
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

        PageReference pageRef = Page.ONE_CancelacionAbonoParcialPdf;

        pageRef.getParameters().put('abonoParcialId', abonoParcialId);
        pageRef.getParameters().put('documentType', documentType);
        pageRef.getParameters().put('language', language);

        if (Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String buildLabel() {
        ONE_Abono_Parcial__c abonoParcial = [SELECT ONE_Numero_Abono_Factura_Rectificativa__c, ONE_Presupuesto_AP__r.Name, ONE_Servicio_AP__r.Name, ONE_Fecha_Abono_Factura_Rectificativa__c FROM ONE_Abono_Parcial__c WHERE Id = :abonoParcialId];
        String label = abonoParcial.ONE_Numero_Abono_Factura_Rectificativa__c != null ? 'Nº Cancelación de Abono Parcial ' + abonoParcial.ONE_Numero_Abono_Factura_Rectificativa__c : 'Nº Cancelación de Abono Parcial ';
		label += abonoParcial.ONE_Presupuesto_AP__r.Name != null ? ' / Nº Contrato: ' + abonoParcial.ONE_Presupuesto_AP__r.Name : '/ Nº Contrato: ';
        label += abonoParcial.ONE_Servicio_AP__r.Name != null ? ' / Nº Servicio: ' + abonoParcial.ONE_Servicio_AP__r.Name : ' / Nº Servicio: ' ;
        label += abonoParcial.ONE_Fecha_Abono_Factura_Rectificativa__c != null ? ' / ' + abonoParcial.ONE_Fecha_Abono_Factura_Rectificativa__c.format('yyyy-MM-dd') : '';

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
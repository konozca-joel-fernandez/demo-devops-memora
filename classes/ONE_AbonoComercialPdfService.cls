/**
 * Created by msulek003 on 22.04.2021.
 */

public with sharing class ONE_AbonoComercialPdfService {
    private Id ordenDeVentaId;
    private List<FlowInput> inputs;

    @InvocableMethod
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_AbonoComercialPdfService service = new ONE_AbonoComercialPdfService(inputs);
        return service.createAndLinkPdf();
    }

    public ONE_AbonoComercialPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }

    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf() {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.ordenDeVentaId, buildLabel(), ONE_CommonConstants.DOCUMENT_TAG_ABONO_COMERCIAL);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.ordenDeVentaId);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, [Select ONE_Servicio__c from ONE_Orden_De_Venta__c where id = :input.ordenDeVentaId].ONE_Servicio__c);
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

        PageReference pageRef = Page.ONE_AbonoComercialPdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVentaId);
        pageRef.getParameters().put('language', language);
        pageRef.getParameters().put('isAbono', 'true');

        if (Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String buildLabel() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id, Name, ONE_Numero_de_factura__c,ONE_Numero_Abono_Factura__c,ONE_Presupuesto__r.Name, ONE_Servicio__r.Name, ONE_Fecha_Hora_Del_Abono_Factura__c,ONE_Tipo_De_Pagador__c FROM ONE_Orden_De_Venta__c WHERE Id = :ordenDeVentaId];
        String label = ordenDeVenta.ONE_Numero_Abono_Factura__c != null ? 'Nº Abono ' + ordenDeVenta.ONE_Numero_Abono_Factura__c : 'Nº Abono ';
        label += ordenDeVenta.ONE_Numero_de_factura__c != null ? ' / Rectificativa de Factura nº: ' + ordenDeVenta.ONE_Numero_de_factura__c : '/ Rectificativa de Factura nº: ';
        label += ordenDeVenta.ONE_Presupuesto__r.Name != null ? ' / Nº Contrato: ' + ordenDeVenta.ONE_Presupuesto__r.Name : '/ Nº Contrato: ';
        label += ordenDeVenta.ONE_Servicio__r.Name != null ? ' / Nº Servicio: ' + ordenDeVenta.ONE_Servicio__r.Name : ' / Nº Servicio: ' ;
        label += ordenDeVenta.ONE_Fecha_Hora_Del_Abono_Factura__c != null ? ' / ' + ordenDeVenta.ONE_Fecha_Hora_Del_Abono_Factura__c.format('yyyy-mm-dd') : '';
        label += ordenDeVenta.ONE_Tipo_De_Pagador__c != null ? ' / Pagador: ' + ordenDeVenta.ONE_Tipo_De_Pagador__c : ' / Pagador: ';

        label += '.pdf';
        return label;
    }



    public virtual class FlowInput {
        @InvocableVariable
        public Id ordenDeVentaId;
        @InvocableVariable
        public String language;
    }
}
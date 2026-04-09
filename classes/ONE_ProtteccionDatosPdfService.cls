/**
 * Created by msulek003 on 30.03.2021. 
 * Last Modified 11 March 2025
 */

public with sharing class ONE_ProtteccionDatosPdfService {
    //Input from the flow, let us get all the values needed to generate the document   
    private Id documentosId;
    private List<FlowInput> inputs;


    @InvocableMethod
    //Method to call from a Flow to generate the document an linked it to the right Object in Salesforce
    public static List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(List<FlowInput> inputs) {
        ONE_ProtteccionDatosPdfService service = new ONE_ProtteccionDatosPdfService(inputs);
        
        // Obtener el ID del primer documento de la lista de inputs
        Id documentosId = inputs[0].documentosId;

           // Consultar el RecordType del documento
        ONE_Documentos__c documento = [SELECT RecordType.Name FROM ONE_Documentos__c WHERE Id = :documentosId LIMIT 1];
        
        // Determinar el nombre del archivo en función del RecordType
        String fileName;
        if (documento.RecordType.Name == 'D-09-01-Solicitud Reserva de Sala') {
            fileName = ONE_PdfGeneratorHelper.getTitleLabel('Solicitud Reserva de Sala') ;
        } else {
            fileName = ONE_PdfGeneratorHelper.getTitleLabel(label.ONE_Doc_Proteccion_Datos_File_Name);
        }
        
        return service.createAndLinkPdf(fileName);

    }

    public ONE_ProtteccionDatosPdfService(List<FlowInput> inputs) {
        this.inputs = inputs;
    }
	//Method to generate PDF 
    private Blob buildPdfContent(FlowInput input) {
        
        FlowInput datosInput = (FlowInput) input;
        this.documentosId = datosInput.documentosId;
        ONE_Documentos__c documento = [SELECT RecordType.Name 
                                FROM ONE_Documentos__c 
                                WHERE Id = :this.documentosId];
        PageReference PageRef;
        documento.ONE_CheckPdf__c = true;
        
    if (documento.RecordType.Name == 'Autorización para Cesión de Datos') {
        pageRef = Page.ONE_OlympiaAutorizacionPdf;
    } else if (documento.RecordType.Name == 'D-09-01-Solicitud Reserva de Sala') { 	
         
        pageRef = Page.SolicitudSalaExterna;
    }
    
    else{
       pageRef = Page.ONE_ProteccionDatosPdf;
    }
             
        String language = datosInput.language;


        pageRef.getParameters().put('documentosId', documentosId);
        pageRef.getParameters().put('language', language);

        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }

        return pageRef.getContentAsPDF();

    }
	//Method to link PDF to the document
    
   
    
    public List<ONE_PdfServiceBase.FlowOutput> createAndLinkPdf(String fileName) {
        try {
            FlowInput input = inputs.get(0);
            Blob pdfContent = buildPdfContent(input);
            Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, input.documentosId, fileName, ONE_CommonConstants.DOCUMENT_TAG_PROTECCION_DATOS);
            ONE_PdfGeneratorHelper.linkWithParent(pdfId, input.documentosId);
            ONE_PdfGeneratorHelper.linkWithPersonaParticular(pdfId, input.documentosId);
            ONE_PdfGeneratorHelper.linkWithServico(pdfId, input.documentosId);   
            ONE_PdfGeneratorHelper.linkWithOpportunity(pdfId, input.documentosId);

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
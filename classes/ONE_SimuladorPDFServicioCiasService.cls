public class ONE_SimuladorPDFServicioCiasService {
  
    private List<Inputs> flowInputs;
    
    public ONE_SimuladorPDFServicioCiasService(List<Inputs> flowInputs) {
        this.flowInputs = flowInputs;
    }
    
     @InvocableMethod(label='ONE_SimuladorPDFServicioCiasService')
    public static List<Output> createAndLinkPdf(List<Inputs> flowInputs) {
        ONE_SimuladorPDFServicioCiasService service = new ONE_SimuladorPDFServicioCiasService(flowInputs);
        return service.createAndLinkPdf();
    }
    
    public List<Output> createAndLinkPdf() {
        List<Output> outputList= new List<Output>();
        Output output=new Output();
        if(flowInputs!=null){
            try{
                System.debug(flowInputs);
                Blob pdfContent = buildPdfContent(flowInputs[0]);
                Id pdfId = ONE_PdfGeneratorHelper.savePdf(pdfContent, flowInputs[0].presupuestoId,flowInputs[0].cliente + ' '+ (flowInputs[0].validityYear).replace('.','') + ' - '+ flowInputs[0].newAcuerdoName+'.pdf' , null);
                ONE_PdfGeneratorHelper.linkWithParent(pdfId, flowInputs[0].presupuestoId);
                Id servicioId=[Select ONE_Expediente__c from ONE_Presupuesto__c where id =: flowInputs[0].presupuestoId].ONE_Expediente__c;
                if(servicioId!=null){
                ONE_PdfGeneratorHelper.linkWithParent(pdfId,servicioId);
                }
                output.success=true;
                outputList.add(output);
                
                return outputList; 
            }catch(Exception e){
               
                output.success=false;
                output.errorMessage='ERROR: '+ e.getTypeName() + ' | ' + e.getMessage() + ' | ' + e.getStackTraceString();
                outputList.add(output);
                return outputList; 
            }
        	
        }else{
            outputList[0].success=false;
            outputList[0].errorMessage='Null flow input';
            return outputList;
        }
    }
      private Blob buildPdfContent(Inputs input) {
            PageReference pageRef = Page.ONE_SimuladorPDFServicioCias;

        pageRef.getParameters().put('presupuestoId', input.presupuestoId);
        pageRef.getParameters().put('language', input.language);
        pageRef.getParameters().put('servicioId', input.servicioId);
		pageRef.getParameters().put('validityYear', input.validityYear);
        pageRef.getParameters().put('cliente', input.cliente);
        pageRef.getParameters().put('newAcuerdoName', input.newAcuerdoName);
        pageRef.getParameters().put('logo', input.logo);
          
        if(Test.isRunningTest()){
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

	public class Inputs{
        
        @InvocableVariable
        public String presupuestoId;
        
        @InvocableVariable
        public String servicioId;
        
        @InvocableVariable
        public String validityYear;
        
        @InvocableVariable
        public String cliente;
        
        @InvocableVariable
        public String newAcuerdoName;
        
        @InvocableVariable
        public String language;

        @InvocableVariable
        public String logo;
    }
    
	public class Output{
        @InvocableVariable
        public Boolean success;
        
        @InvocableVariable
        public String errorMessage;
       
    }
}
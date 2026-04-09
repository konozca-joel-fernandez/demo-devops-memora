public class ONE_PDFCompaniasGenerationService {

    public class ONE_PDFCompaniasGenerationServiceException extends Exception {}
    
    private String logo;
    private String companias;
    private String accountNameForPdf;
    private Date validityDate;
    private String delegationId;
    private String operationalZoneId;
    private String operationalAreaId;
    private String delegation;
    private String operationalZone;
    private String operationalArea;
    private String centerId;
    private String contentVersionId;
    private Integer agreementCount;
    private Integer catalogCount;
    private Boolean catalogsInNegotiation;
    private Boolean finalCatalogs;
    private List<String> status;
    
    public ONE_PDFCompaniasGenerationService(List<FlowInput> flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.logo = flowInput.logo;
        this.companias = flowInput.companias;
        this.accountNameForPdf = flowInput.accountNameForPdf;
        this.validityDate = flowInput.validityDate;
        this.delegationId = flowInput.delegationId;
        this.operationalZoneId = flowInput.operationalZoneId;
        this.operationalAreaId = flowInput.operationalAreaId;
        this.delegation = flowInput.delegation;
        this.operationalZone = flowInput.operationalZone;
        this.operationalArea = flowInput.operationalArea;
        this.centerId = flowInput.centerId;
        this.catalogsInNegotiation = flowInput.catalogsInNegotiation;
        this.finalCatalogs = flowInput.finalCatalogs;
    }
    
    @InvocableMethod
    public static List<FlowOutput> createAndLinkPdf(List<FlowInput> flowInputs) {

        ONE_PDFCompaniasGenerationService service = new ONE_PDFCompaniasGenerationService(flowInputs);
        return service.createAndLinkPdf();
    }

    public List<FlowOutput> createAndLinkPdf() {
		String url;
        try {
            url=checkRecords();
           
        } catch (Exception ex) {
            return new List<FlowOutput>{new FlowOutput(false, null, ex.getMessage(), null,null)};
        }
        return new List<FlowOutput>{new FlowOutput(true, 'Se han generado '+ catalogCount + ' PDF(s) con '+agreementCount+' acuerdo(s).', null, contentVersionId,url)};
    }
    
    private String checkRecords() {

        List<ONE_Segmentacion_Acuerdo__c> agreements = new List<ONE_Segmentacion_Acuerdo__c>();
        List<ONE_Catalogo_De_Precios__c> catalogos=new List<ONE_Catalogo_De_Precios__c>();
     

        List<ONE_Lugar__c> places = new List<ONE_Lugar__c>();
        if (String.isBlank(delegationId)) {
            places = [SELECT Id FROM ONE_Lugar__c];
        }
        else if (String.isBlank(operationalZoneId)) {
            places = [SELECT Id FROM ONE_Lugar__c
                      WHERE Id = :delegationId OR ONE_Lugar_Superior__c = :delegationId OR ONE_Lugar_Superior__r.ONE_Lugar_Superior__c = :delegationId];
        }
        else if (String.isBlank(operationalAreaId)) {
            places = [SELECT Id FROM ONE_Lugar__c
                      WHERE Id = :operationalZoneId OR ONE_Lugar_Superior__c = :operationalZoneId];
        }
        else {
            places = [SELECT Id FROM ONE_Lugar__c
                      WHERE Id = :operationalAreaId];
        }
        List<String> companiasList = companias.split(';');
        List<Account> accounts =[SELECT Id FROM Account WHERE Id IN :companiasList];
        
        status = new List<String>();
        if (this.finalCatalogs){
            status.add('');
        }
        if (this.catalogsInNegotiation){
            status.add('En negociación');
        }
        
        if (String.isBlank(centerId)) {
            if(accounts.size() > 0){
                catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                           FROM ONE_Catalogo_De_Precios__c 
                           WHERE ONE_Validez_Desde__c <= :validityDate 
                               AND (ONE_Validez_Hasta__c >= :validityDate OR ONE_Validez_Hasta__c = null)
                               AND ONE_Validez_Desde__c != null 
                               AND ONE_Compania__c != NULL 
                               AND ONE_Compania__c IN :accounts 
                               AND (ONE_Lugar__c IN :places OR ONE_Centro__r.ONE_Lugar__c IN :places)
                               AND ONE_Estado__c IN :status];
            } else {
                catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                           FROM ONE_Catalogo_De_Precios__c 
                           WHERE ONE_Validez_Desde__c <= :validityDate 
                               AND (ONE_Validez_Hasta__c >= :validityDate OR ONE_Validez_Hasta__c = null)
                               AND ONE_Validez_Desde__c != null 
                               AND ONE_Compania__c != NULL 
                               AND (ONE_Lugar__c IN :places OR ONE_Centro__r.ONE_Lugar__c IN :places)
                               AND ONE_Estado__c IN :status];
            }
            
        } else {
            if(accounts.size() > 0){
                catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                           FROM ONE_Catalogo_De_Precios__c 
                           WHERE ONE_Validez_Desde__c <= :validityDate 
                               AND (ONE_Validez_Hasta__c >= :validityDate OR ONE_Validez_Hasta__c = null)
                               AND ONE_Validez_Desde__c != null 
                               AND ONE_Compania__c IN :accounts 
                               AND ONE_Centro__c = :centerId
                               AND ONE_Estado__c IN :status];
            } else {
                catalogos=[SELECT Name, ONE_Validez_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                           FROM ONE_Catalogo_De_Precios__c 
                           WHERE ONE_Validez_Desde__c <= :validityDate 
                               AND (ONE_Validez_Hasta__c >= :validityDate OR ONE_Validez_Hasta__c = null)
                               AND ONE_Validez_Desde__c != null 
                               AND ONE_Compania__c != null
                               AND ONE_Centro__c = :centerId
                               AND ONE_Estado__c IN :status];
            }
            
        }
        
        String url=System.Url.getOrgDomainUrl().toExternalForm()+'/sfc/servlet.shepherd/document/download/';
        List<String> catalogosIds=new List<String>();
        for(ONE_Catalogo_De_Precios__c cat:catalogos){
            catalogosIds.add(cat.Id);
            Blob pdfContent = buildPdfContent(cat.Id);
            Id pdfId = savePdf(pdfContent, getTitleLabel(cat.Name));
            url+=pdfId+'/';
        }
        
        agreements = [SELECT Name, ONE_Vigencia_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Catalogo_De_Precios__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), Observaciones__c, ONE_Ajuste_Necesario__c, ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                      FROM ONE_Segmentacion_Acuerdo__c
                      WHERE ONE_Vigencia_Desde__c <= :validityDate 
                      AND (ONE_Vigencia_Hasta__c >= :validityDate OR ONE_Vigencia_Hasta__c = null) 
                      AND ONE_No_Imprimir__c = false
                      AND ONE_Vigencia_Desde__c != null 
                      AND ONE_Compania__c != NULL 
                      AND ONE_Catalogo_De_Precios__c in:catalogosIds];
           
        if (agreements.isEmpty()) {
            throw new ONE_PDFCompaniasGenerationServiceException('No se han encontrado acuerdos.');
        }
        else {
            agreementCount = agreements.size();
            catalogCount=catalogos.size();
        }
        return url;
    }
    
    private Blob buildPdfContent(String catalogo) {

        PageReference pageRef = Page.ONE_PDFCompanias;
        
        pageRef.getParameters().put('logo', logo);
        pageRef.getParameters().put('accountNameForPdf', accountNameForPdf);
        pageRef.getParameters().put('catalogoId', catalogo);
        pageRef.getParameters().put('validityDate', validityDate != null ? validityDate.format() : '');
        pageRef.getParameters().put('delegationId', delegationId);
        pageRef.getParameters().put('operationalZoneId', operationalZoneId);
        pageRef.getParameters().put('operationalAreaId', operationalAreaId);
        pageRef.getParameters().put('delegation', delegation);
        pageRef.getParameters().put('operationalZone', operationalZone);
        pageRef.getParameters().put('operationalArea', operationalArea);
        pageRef.getParameters().put('centerId', centerId);
        pageRef.getParameters().put('companias', companias);
        pageRef.getParameters().put('status', string.join(status,','));
         System.debug('ValidityDate in buildPdfContent'+validityDate);
        if(Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String getTitleLabel(String catalogo) {

        String dateTimeString = Datetime.now().format('dd/MM/yyyy HH:mm');
        return catalogo.replaceAll('[^\\p{ASCII}]', '')+'.pdf';
    }

    private Id savePdf(Blob pdfContent, String fileName) {

        ContentVersion versionData = new ContentVersion();
        versionData.ContentLocation = 'S';
        versionData.VersionData = pdfContent;
        versionData.Title = fileName;
        versionData.PathOnClient = fileName;
        if (ContentVersion.sObjectType.getDescribe().isCreateable()) {
            insert versionData;
        }
        

        contentVersionId = versionData.Id;
		

        Id contentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :versionData.Id
        ].ContentDocumentId;
        return contentDocumentId;
    }

    
    public virtual class FlowInput {
        @InvocableVariable
        public String logo;
        @InvocableVariable
        public String agreementId;
        @InvocableVariable
        public String companias;
        @InvocableVariable
        public String accountNameForPdf;
        @InvocableVariable
        public Date validityDate;
        @InvocableVariable
        public String delegationId;
        @InvocableVariable
        public String operationalZoneId;
        @InvocableVariable
        public String operationalAreaId;
        @InvocableVariable
        public String delegation;
        @InvocableVariable
        public String operationalZone;
        @InvocableVariable
        public String operationalArea;
        @InvocableVariable
        public String centerId;
        @InvocableVariable
        public Boolean catalogsInNegotiation;
        @InvocableVariable
        public Boolean finalCatalogs;
    }
    
    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String successMessage;
		@InvocableVariable
        public String contentVersionId;
        @InvocableVariable
        public String url;
        
        public FlowOutput(Boolean success, String successMessage, String errorMessage, String contentVersionId, String url) {
            this.success = success;
            this.successMessage = successMessage;
            this.errorMessage = errorMessage;
            this.contentVersionId = contentVersionId;
            this.url=url;
        }
    }
}
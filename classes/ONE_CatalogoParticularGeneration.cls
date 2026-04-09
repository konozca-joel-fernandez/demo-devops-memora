public without sharing class ONE_CatalogoParticularGeneration {
    
    public class ONE_CatalogoParticularGenerationException extends Exception {}
    
    //INFO:
    private String catalogId;
    private String contentVersionId;
    private Integer catalogCount;
    
    //DATA OPT:
    private Date validityDate;
    private String delegationId;
    private String operationalZoneId;
    private String operationalAreaId;
    private String delegation;
    private String operationalZone;
    private String operationalArea;
    private String centerId;
    
    //DESSIGN OPT
    private String logo;
    private String language;
    
    //PDF OPT
    private Boolean showIDCol;
    private Boolean showBasePriceCol;
    private Boolean showTaxTypeCol;
    
    private Boolean showGeneralConditions;
    private String dateGeneralConditions;
 
    private Boolean showColTitles;
    //add fields here
    
    
    public ONE_CatalogoParticularGeneration(List<FlowInput> flowInputs) {
        
        FlowInput flowInput = flowInputs.get(0);
        
        this.catalogId = flowInput.catalogId;
        
        this.validityDate = flowInput.validityDate;
        this.delegationId = flowInput.delegationId;
        this.operationalZoneId = flowInput.operationalZoneId;
        this.operationalAreaId = flowInput.operationalAreaId;
        this.delegation = flowInput.delegation;
        this.operationalZone = flowInput.operationalZone;
        this.operationalArea = flowInput.operationalArea;
        this.centerId = flowInput.centerId;
        
        this.logo = flowInput.logo;
        this.language = flowInput.language;
        
        this.showIDCol = flowInput.showIdCol;
    	this.showBasePriceCol = flowInput.showBasePriceCol;
    	this.showTaxTypeCol = flowInput.showTaxTypeCol;
        
        this.showGeneralConditions = flowInput.showGeneralConditions;
        this.dateGeneralConditions = flowInput.dateGeneralConditions;
        
        this.showColTitles = flowInput.showColTitles;
    }
    
    @InvocableMethod
    public static List<FlowOutput> createAndLinkPdf(List<FlowInput> flowInputs) {
        
        ONE_CatalogoParticularGeneration service = new ONE_CatalogoParticularGeneration(flowInputs);
        return service.createAndLinkPdf();
    }
    
    public List<FlowOutput> createAndLinkPdf() {
        
        try {
            checkRecords();
            Blob pdfContent = buildPdfContent();
            Id pdfId = savePdf(pdfContent, getTitleLabel());
        } catch (Exception ex) {
            return new List<FlowOutput>{new FlowOutput(false, null, ex.getMessage(), null)};
                }
        return new List<FlowOutput>{new FlowOutput(true, 'Se ha generado un PDF con '+catalogCount+' catálogo(s) de precios.', null, contentVersionId)};
            }
    
    private void checkRecords() {
        
        List<ONE_Catalogo_De_Precios__c> catalogs = new List<ONE_Catalogo_De_Precios__c>();
        
        if (String.isBlank(catalogId)) {

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


            if (String.isBlank(centerId)) {
                catalogs = [
                    SELECT Name,  ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c) 
                    FROM ONE_Catalogo_De_Precios__c
                    WHERE ONE_Validez_Desde__c != null AND ONE_Compania__c = NULL AND ONE_Lugar__c != NULL
                     AND ONE_Lugar__c IN :places AND ONE_Validez_Desde__c <= :validityDate AND (ONE_Validez_Hasta__c >= :validityDate OR ONE_Validez_Hasta__c = null)
                ];
            }
            else {
                catalogs = [
                    SELECT Name, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c) 
                    FROM ONE_Catalogo_De_Precios__c
                    WHERE ONE_Validez_Desde__c != null AND ONE_Compania__c = NULL AND ONE_Lugar__c != NULL
                    AND ONE_Lugar__c IN :places AND ONE_Centro__c = :centerId AND ONE_Validez_Desde__c <= :validityDate AND (ONE_Validez_Hasta__c >= :validityDate OR ONE_Validez_Hasta__c = null)
                ];
            }
        }
        else {

            catalogs = [
                SELECT Name, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c) 
                FROM ONE_Catalogo_De_Precios__c
                WHERE Id = :catalogId
            ];

        }

        if (catalogs.isEmpty()) {
            throw new ONE_CatalogoParticularGenerationException('No se han encontrado catálogos de precios.');
        }
        else {
            System.debug('CATALOGOS: '+catalogs);
            catalogCount = catalogs.size();
        }
    }
        
    private Blob buildPdfContent() {

        PageReference pageRef = Page.ONE_CatalogoParticularPDF;
        
        pageRef.getParameters().put('catalogId', catalogId);
        
        pageRef.getParameters().put('validityDate', validityDate.format());
        pageRef.getParameters().put('delegationId', delegationId);
        pageRef.getParameters().put('operationalZoneId', operationalZoneId);
        pageRef.getParameters().put('operationalAreaId', operationalAreaId);
        pageRef.getParameters().put('delegation', delegation);
        pageRef.getParameters().put('operationalZone', operationalZone);
        pageRef.getParameters().put('operationalArea', operationalArea);
        pageRef.getParameters().put('centerId', centerId);
        
        pageRef.getParameters().put('logo', logo);
        pageRef.getParameters().put('language', language);
        
        pageRef.getParameters().put('showIDCol', showIDCol ? 'true' : 'false');
        pageRef.getParameters().put('showBasePriceCol', showBasePriceCol ? 'true' : 'false');
        pageRef.getParameters().put('showTaxTypeCol', showTaxTypeCol ? 'true' : 'false');
        
        pageRef.getParameters().put('showColTitles', showColTitles ? 'true' : 'false');
        
        pageRef.getParameters().put('showGeneralConditions', showGeneralConditions ? 'true' : 'false');
        pageRef.getParameters().put('dateGeneralConditions', dateGeneralConditions);
        
        if(Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String getTitleLabel() {

        String dateTimeString = Datetime.now().format('dd/MM/yyyy HH:mm');
        return 'D-06-00 Listado Precios ('+ dateTimeString +').pdf';
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
        public String catalogId;
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
        public String language;
        @InvocableVariable
        public Boolean showIDCol;
        @InvocableVariable
    	public Boolean showBasePriceCol;
        @InvocableVariable
    	public Boolean showTaxTypeCol;
    	@InvocableVariable
    	public Boolean showGeneralConditions;
        @InvocableVariable
        public String dateGeneralConditions;
        @InvocableVariable
        public Boolean showColTitles;
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
        
        public FlowOutput(Boolean success, String successMessage, String errorMessage, String contentVersionId) {
            this.success = success;
            this.successMessage = successMessage;
            this.errorMessage = errorMessage;
            this.contentVersionId = contentVersionId;
        }
    }
}
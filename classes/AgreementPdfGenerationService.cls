public without sharing class AgreementPdfGenerationService {

    public class AgreementPdfGenerationServiceException extends Exception {}
    
    private String logo;
    private String agreementId;
    private String accountId;
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
    
    public AgreementPdfGenerationService(List<FlowInput> flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.logo = flowInput.logo;
        this.agreementId = flowInput.agreementId;
        this.accountId = flowInput.accountId;
        this.accountNameForPdf = flowInput.accountNameForPdf;
        this.validityDate = flowInput.validityDate;
        this.delegationId = flowInput.delegationId;
        this.operationalZoneId = flowInput.operationalZoneId;
        this.operationalAreaId = flowInput.operationalAreaId;
        this.delegation = flowInput.delegation;
        this.operationalZone = flowInput.operationalZone;
        this.operationalArea = flowInput.operationalArea;
        this.centerId = flowInput.centerId;
    }
    
    @InvocableMethod
    public static List<FlowOutput> createAndLinkPdf(List<FlowInput> flowInputs) {

        AgreementPdfGenerationService service = new AgreementPdfGenerationService(flowInputs);
        return service.createAndLinkPdf();
    }

    public List<FlowOutput> createAndLinkPdf() {

        try {
            checkRecords();
            Blob pdfContent = buildPdfContent();
            Id pdfId = savePdf(pdfContent, getTitleLabel());
            if (String.isNotBlank(agreementId)) {
                linkWithAgreement(pdfId, agreementId);
            }
        } catch (Exception ex) {
            return new List<FlowOutput>{new FlowOutput(false, null, ex.getMessage(), null)};
        }
        return new List<FlowOutput>{new FlowOutput(true, 'Se ha generado un PDF con '+agreementCount+' acuerdo(s).', null, contentVersionId)};
    }
    
    private void checkRecords() {

        List<ONE_Segmentacion_Acuerdo__c> agreements = new List<ONE_Segmentacion_Acuerdo__c>();
        
        if (String.isBlank(agreementId)) {

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

            List<Account> accounts = new List<Account>();
            if (String.isBlank(accountId)) {
                accounts = [SELECT Id FROM Account
                            WHERE RecordType.DeveloperName = 'ONE_Otras_Cuentas'
                            AND ONE_Nivel_Jerarquia_Cuentas__c != null];
            }
            else {
                accounts = [SELECT Id FROM Account
                            WHERE Id = :accountId];
            }

            if (String.isBlank(centerId)) {
              agreements = [SELECT Name, ONE_Vigencia_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Catalogo_De_Precios__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), Observaciones__c, ONE_Ajuste_Necesario__c, ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                    			FROM ONE_Segmentacion_Acuerdo__c
                    			WHERE ONE_Vigencia_Desde__c <= :validityDate AND (ONE_Vigencia_Hasta__c >= :validityDate OR ONE_Vigencia_Hasta__c = null) AND ONE_No_Imprimir__c = false
                    			AND ONE_Vigencia_Desde__c != null AND ONE_Compania__c != NULL AND ONE_Catalogo_De_Precios__c != null 
                                AND ONE_Compania__c IN :accounts AND (ONE_Lugar__c IN :places OR ONE_Centro__r.ONE_Lugar__c IN :places)];
            }
            else {
                agreements = [
                    SELECT Name, ONE_Vigencia_Desde__c, ONE_Compania__r.Name, ONE_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c, ONE_Catalogo_De_Precios__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name, ONE_Centro__r.Name, ONE_Centro__r.ONE_Direccion__c, ONE_Centro__r.ONE_Codigo_Postal__c, ONE_Centro__r.ONE_Municipio_Direccion__c, ToLabel(ONE_Centro__r.ONE_Provincia__c), Observaciones__c, ONE_Ajuste_Necesario__c, ONE_Lugar__r.ONE_Tipo_De_Impuesto__c 
                    FROM ONE_Segmentacion_Acuerdo__c
                    WHERE ONE_Vigencia_Desde__c != null AND ONE_Compania__c != NULL AND ONE_Catalogo_De_Precios__c != null 
                    AND ONE_Compania__c IN :accounts AND ONE_Centro__c = :centerId AND ONE_Vigencia_Desde__c <= :validityDate AND (ONE_Vigencia_Hasta__c >= :validityDate OR ONE_Vigencia_Hasta__c = null) AND ONE_No_Imprimir__c = false
                    ORDER BY Delegacion__c ASC, Zona_Operativa__c ASC, Area_Operativa__c ASC
                ];
            }               
        }
        else {

            agreements = [
                SELECT Name,ONE_Vigencia_Desde__c,ONE_Vigencia_Hasta__c, ONE_Compania__r.Name, ONE_Catalogo_De_Precios__c, ONE_Lugar__r.Name, ONE_Lugar__r.ONE_Nivel_Jerarquico__c, ONE_Lugar__r.ONE_Lugar_Superior__r.Name, ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name
                FROM ONE_Segmentacion_Acuerdo__c
                WHERE Id = :agreementId
            ];

            if (agreements.get(0).ONE_Catalogo_De_Precios__c == null) {
                throw new AgreementPdfGenerationServiceException('El acuerdo debe tener asignado un catálogo de precios.');
            }
        }

        if (agreements.isEmpty()) {
            throw new AgreementPdfGenerationServiceException('No se han encontrado acuerdos.');
        }
        else {
            agreementCount = agreements.size();
        }
    }
    
    private Blob buildPdfContent() {

        PageReference pageRef = Page.AgreementPDF;
        
        pageRef.getParameters().put('logo', logo);
        pageRef.getParameters().put('accountId', accountId);
        pageRef.getParameters().put('accountNameForPdf', accountNameForPdf);
        pageRef.getParameters().put('agreementId', agreementId);
        pageRef.getParameters().put('validityDate', validityDate != null ? validityDate.format() : '');
        pageRef.getParameters().put('delegationId', delegationId);
        pageRef.getParameters().put('operationalZoneId', operationalZoneId);
        pageRef.getParameters().put('operationalAreaId', operationalAreaId);
        pageRef.getParameters().put('delegation', delegation);
        pageRef.getParameters().put('operationalZone', operationalZone);
        pageRef.getParameters().put('operationalArea', operationalArea);
        pageRef.getParameters().put('centerId', centerId);
         System.debug('ValidityDate in buildPdfContent'+validityDate);
        if(Test.isRunningTest()) {
            return Blob.valueof('Some random String');
        }
        return pageRef.getContentAsPDF();
    }

    private String getTitleLabel() {

        String dateTimeString = Datetime.now().format('dd/MM/yyyy HH:mm');
        return 'D-06-01 Precios Acuerdos por Tipo Servicio ('+ dateTimeString +').pdf';
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

        if (String.isNotBlank(agreementId)) {
            updateAgreementWithLink(contentVersionId);
        }

        Id contentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :versionData.Id
        ].ContentDocumentId;
        return contentDocumentId;
    }

    private void updateAgreementWithLink(Id contentVersionId) {

        ONE_Segmentacion_Acuerdo__c agreementRecord = new ONE_Segmentacion_Acuerdo__c(Id = agreementId);
        agreementRecord.Documento_PDF__c = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentVersionId;
        update agreementRecord;
    }

    private void linkWithAgreement(Id contentDocumentId, String agreementId) {
        
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = contentDocumentId;
        conDocLink.LinkedEntityId = agreementId;
        if (ContentDocumentLink.sObjectType.getDescribe().isCreateable()) {
            insert conDocLink;
        }
    }
    
    public virtual class FlowInput {
        @InvocableVariable
        public String logo;
        @InvocableVariable
        public String agreementId;
        @InvocableVariable
        public String accountId;
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
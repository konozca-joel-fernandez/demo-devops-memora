//Controller for the abono parcial generation 
public with sharing class ONE_AbonoParcialPdfController {
    //Input PDF generation variable
    public Id abonoParcialId {public get; private set;}
    public String language {public get; private set;}
    public String documentType {public get; private set;}
    public ONE_PresupuestoComercialData data {public get; private set;}
	//Get data from current page and use it for the PDF generation
    public ONE_AbonoParcialPdfController() {
        abonoParcialId = ApexPages.currentPage().getParameters().get('abonoParcialId');
        documentType = ApexPages.currentPage().getParameters().get('documentType');
        language = ApexPages.currentPage().getParameters().get('language');
        
        setupData();
    }
	//Add data to the PDF content
    public void setupData() {
        data = ONE_AbonoParcialDataFactory.buildAbonoParcialData(abonoParcialId, documentType, language);
    }
}
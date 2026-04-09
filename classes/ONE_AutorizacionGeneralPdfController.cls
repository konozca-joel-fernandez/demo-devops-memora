public class ONE_AutorizacionGeneralPdfController { 
    
    public Id documentosId {public get; private set;}
    public String language {public get; private set;}
    public ONE_AutorizacionGeneralData data {public get; private set;}
    
    public ONE_AutorizacionGeneralPdfController() {
        documentosId = ApexPages.currentPage().getParameters().get('documentosId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }
    
    public void setupData() {
        data = ONE_AutorizacionGeneralDataFactory.buildAutorizacionGeneralData(documentosId, language);
    }
}
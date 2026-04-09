public class ONE_SolicitudDeInhumacionPdfController { 
    public Id documentosId {public get; private set;}
    public String language {public get; private set;}
    public ONE_SolicitudDeInhumacionData data {public get; private set;}

    public ONE_SolicitudDeInhumacionPdfController() {
        documentosId = ApexPages.currentPage().getParameters().get('documentosId'); 
        language = ApexPages.currentPage().getParameters().get('language'); 
        setupData();
    }

    public void setupData() {
        data = ONE_SolicitudDeInhumacionDataFactory.buildSolicitudDeInhumacionData(documentosId, language);
    }
}
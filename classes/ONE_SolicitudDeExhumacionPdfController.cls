public class ONE_SolicitudDeExhumacionPdfController{

    public Id documentosId {public get; private set;}
    public String language {public get; private set;}
    public ONE_SolicitudDeExhumacionData data {public get; private set;}

    public ONE_SolicitudDeExhumacionPdfController() {
        documentosId = ApexPages.currentPage().getParameters().get('documentosId'); 
        language = ApexPages.currentPage().getParameters().get('language'); 
        setupData();
    }

    public void setupData() {
        data = ONE_SolicitudDeExhumacionDataFactory.buildSolicitudDeExhumacionData(documentosId, language);
    }
}
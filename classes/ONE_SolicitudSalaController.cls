public class ONE_SolicitudSalaController {
    public Id documentosId {public get; private set;}
    public String language {public get; private set;}
    public ONE_SalaExternaData data {public get; private set;}

    public ONE_SolicitudSalaController() {
        documentosId = ApexPages.currentPage().getParameters().get('documentosId'); 
        language = ApexPages.currentPage().getParameters().get('language'); 
        setupData();
    }

    public void setupData() {
        data = ONE_SalaExternaDataFactory.buildSalaExternaData(documentosId, language);
    }
}
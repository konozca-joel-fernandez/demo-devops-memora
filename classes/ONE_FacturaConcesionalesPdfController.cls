public with sharing class ONE_FacturaConcesionalesPdfController {
    
    public Id ordenDeVentaId {public get; private set;}
    public String language {public get; private set;}
    public ONE_FacturaConcesionalesData data {public get; private set;}
	
    public ONE_FacturaConcesionalesPdfController() {
        ordenDeVentaId = ApexPages.currentPage().getParameters().get('ordenDeVentaId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }
	
    public void setupData() {
        data = ONE_FacturaConcesionalesDataFactory.buildFacturaData(ordenDeVentaId, language);
    }
}
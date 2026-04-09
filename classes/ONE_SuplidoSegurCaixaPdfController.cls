public class ONE_SuplidoSegurCaixaPdfController {
    public Id ordenDeVentaID {public get; private set;}
    public ONE_SuplidoSegurCaixaData data {public get; private set;}
    
    public ONE_SuplidoSegurCaixaPdfController() {
        ordenDeVentaID = ApexPages.currentPage().getParameters().get('ordenDeVentaID');
        setupData();
    }
    
    public void setupData() {
        data = ONE_SuplidoSegurCaixaDataFactory.buildSegurCaixaData(ordenDeVentaID);
    }
}
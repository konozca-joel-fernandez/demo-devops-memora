public class ONE_PedidoMarmolistaPdfController { 

    public Id pedidoProveedorId {public get; private set;}
    public String language {public get; private set;}
    public ONE_PedidoMarmolistaData data {public get; private set;}
    
    public ONE_PedidoMarmolistaPdfController(){
        pedidoProveedorId = ApexPages.currentPage().getParameters().get('pedidoProveedorId');
        language = ApexPages.currentPage().getParameters().get('language'); 
        setupData(); 
    }
    
    public void setupData() {
        data = ONE_PedidoMarmolistaDataFactory.buildPedidoMarmolistaData(pedidoProveedorId, language);
    }
}
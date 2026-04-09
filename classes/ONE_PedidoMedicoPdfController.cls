public class ONE_PedidoMedicoPdfController {
    public Id pedidoProveedorId {public get; private set;} 
    public String language {public get; private set;}
    public ONE_PedidoMedicoData data {public get; private set;}

    public ONE_PedidoMedicoPdfController() {
        pedidoProveedorId = ApexPages.currentPage().getParameters().get('pedidoProveedorId');
        language = ApexPages.currentPage().getParameters().get('language'); 
        setupData();
    }

    public void setupData() {
        data = ONE_PedidoMedicoDataFactory.buildPedidoMedicoData(pedidoProveedorId, language);
    }
}
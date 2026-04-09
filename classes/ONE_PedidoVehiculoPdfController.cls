public with sharing class ONE_PedidoVehiculoPdfController { 

    Id pedidoId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoVehiculoPdfService.VehiculoData data {public get; private set;}

    public ONE_PedidoVehiculoPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        this.data = ONE_PedidoVehiculoDataFactory.buildData(pedidoId, language);
    }
}
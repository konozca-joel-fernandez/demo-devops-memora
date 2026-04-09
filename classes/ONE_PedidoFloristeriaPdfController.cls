public with sharing class ONE_PedidoFloristeriaPdfController { 

    Id pedidoId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoFloristeriaPdfService.FloristeriaData data {public get; private set;}

    public ONE_PedidoFloristeriaPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        this.data = ONE_PedidoFloristeriaDataFactory.buildData(pedidoId, language);
    }
}
public with sharing class ONE_PedidoDatosParroquialesPdfController {

    Id pedidoId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoDatosParroquialesPdfService.DatosParroquialesData data {public get; private set;}

    public ONE_PedidoDatosParroquialesPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language'); 
        setupData();
    }

    public void setupData() {
        this.data = ONE_PedidoDatosParroquialesDataFactory.buildData(pedidoId, language);
    }
}
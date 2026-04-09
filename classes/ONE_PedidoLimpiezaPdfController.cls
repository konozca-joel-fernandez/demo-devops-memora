public with sharing class ONE_PedidoLimpiezaPdfController {

    Id pedidoId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoLimpiezaPdfService.LimpiezaData data {public get; private set;}

    public ONE_PedidoLimpiezaPdfController(){
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData(){
        this.data = ONE_PedidoLimpiezaDataFactory.buildData(pedidoId, language);
    }

}
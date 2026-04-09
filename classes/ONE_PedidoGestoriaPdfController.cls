public with sharing class ONE_PedidoGestoriaPdfController {

    public Id pedidoProveedorId {public get; private set;}
    public String language {public get; private set;}
    public ONE_PedidoGestoriaData data {public get; private set;} 

    public ONE_PedidoGestoriaPdfController() {
        pedidoProveedorId = ApexPages.currentPage().getParameters().get('pedidoProveedorId');
        System.debug('pedidoProveedorId-->' + pedidoProveedorId);
        language = ApexPages.currentPage().getParameters().get('language');
        System.debug('language-->' + language);
        setupData();
    }

    public void setupData() {
        data = ONE_PedidoGestoriaDataFactory.buildPedidoGestoriaData(pedidoProveedorId, language);
    }
}
public with sharing class ONE_PedidoCateringPdfController {

    Id pedidoId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoCateringPdfService.CateringData data {public get; private set;}

    public ONE_PedidoCateringPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        this.data = ONE_PedidoCateringDataFactory.buildData(pedidoId, language);
    }
}
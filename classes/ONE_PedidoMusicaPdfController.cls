public with sharing class ONE_PedidoMusicaPdfController {

    Id pedidoId {get; set;} 
    public String language {public get; private set;}
    public ONE_PedidoMusicaPdfService.MusicaData data {public get; private set;}

    public ONE_PedidoMusicaPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        this.data = ONE_PedidoMusicaDataFactory.buildData(pedidoId, language);
    }
}
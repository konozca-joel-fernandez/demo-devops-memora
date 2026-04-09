public with sharing class ONE_DatosBasicaPdfController { 
    public Id pedidoId {public get; private set;}
    public String language {public get; private set;}
    public ONE_DatosBasicaData data {public get; private set;}

    public ONE_DatosBasicaPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');

        setupData();
    }

    public void setupData() {
        data = ONE_DatosBasicaDataFactory.buildDatosBasicaData(pedidoId, language);
    }
}
/**
 * Created by msulek003 on 29.03.2021. 
 */

public with sharing class ONE_ProtteccionDatosPdfController {
    public Id documentosId {public get; private set;}
    public String language {public get; private set;}
    public ONE_ProtteccionDatosData data {public get; private set;}

    public ONE_ProtteccionDatosPdfController() {
        documentosId = ApexPages.currentPage().getParameters().get('documentosId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        data = ONE_ProtteccionDatosDataFactory.buildProtteccionDatosData(documentosId, language);
    }

}
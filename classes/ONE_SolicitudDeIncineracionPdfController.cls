/**
 * Created by msulek003 on 01.04.2021. 
 */

public with sharing class ONE_SolicitudDeIncineracionPdfController {
    public Id documentosId {public get; private set;}
    public String language {public get; private set;}
    public ONE_SolicitudDeIncineracionData data {public get; private set;}

    public ONE_SolicitudDeIncineracionPdfController() {
        documentosId = ApexPages.currentPage().getParameters().get('documentosId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        data = ONE_SolicitudDeIncineracionDataFactory.buildSolicitudDeIncineracionData(documentosId, language);
    }
}
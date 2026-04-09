/**
 * Created by msulek003 on 12.04.2021. 
 */

//Controller to generate the PDF
public with sharing class ONE_PresupuestoComercialPdfController {
    public Id presupuestoId {public get; private set;}
    public String language {public get; private set;}
    public ONE_PresupuestoComercialData data {public get; private set;}
    public String hojaServicioDocumentCode {public get; private set;}

    //Get parameter from the current page and pass those to the corresponding VFP to generate the PDF  
    public ONE_PresupuestoComercialPdfController() {
        presupuestoId = ApexPages.currentPage().getParameters().get('presupuestoId');
        language = ApexPages.currentPage().getParameters().get('language');
        hojaServicioDocumentCode = getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_HOJA_SERVICIO);
        setupData();
    }

    //Query document code from a custom metada type to display it in the PDF header    
    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }

    //Call Data builder 
    public void setupData() {
        data = ONE_PresupuestoComercialDataFactory.buildPresupuestoComercialData(presupuestoId, language);
        System.debug('dataFact:'+data);
        System.debug('dataFact:'+data.generateSerfunle);
    }
}
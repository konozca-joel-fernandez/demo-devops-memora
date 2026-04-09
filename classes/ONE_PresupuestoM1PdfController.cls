/**
 * Created by Miguel Angel Serrat on 17.05.2024. 
 */

//Controller to generate the PDF
public class ONE_PresupuestoM1PdfController {
    public Id ordenDeVentaId {public get; private set;}
    public String language {public get; private set;}
    public ONE_PresupuestoComercialData data {public get; private set;}
    public String hojaServicioDocumentCode {public get; private set;}

    //Get parameter from the current page and pass those to the corresponding VFP to generate the PDF  
    public ONE_PresupuestoM1PdfController() {
        ordenDeVentaId = ApexPages.currentPage().getParameters().get('ordenDeVentaId');
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
        data = ONE_PresupuestoM1DataFactory.buildPresupuestoM1Data(ordenDeVentaId, language);
        System.debug('dataFact:'+data);
        System.debug('dataFact:'+data.generateSerfunle);
    }
}
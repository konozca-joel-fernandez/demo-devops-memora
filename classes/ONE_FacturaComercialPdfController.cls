/**
 * Created by msulek003 on 21.04.2021.
 */
//Controller for the factura comercial generation 
public with sharing class ONE_FacturaComercialPdfController {
    //Input PDF generation variable
    public Id ordenDeVentaId {public get; private set;}
    public String language {public get; private set;}
    public String isAbono {public get; private set;}
    public ONE_PresupuestoComercialData data {public get; private set;}
	//Get data from current page and use it for the PDF generation
    public ONE_FacturaComercialPdfController() {
        ordenDeVentaId = ApexPages.currentPage().getParameters().get('ordenDeVentaId');
        language = ApexPages.currentPage().getParameters().get('language');
        isAbono = ApexPages.currentPage().getParameters().get('isAbono');
        setupData();
    }
	//Add data to the PDF content
    public void setupData() {
        data = ONE_FacturaComercialDataFactory.buildFacturaComercialData(ordenDeVentaId, language, isAbono);
        System.debug(data.recordtypeName);
    }
}
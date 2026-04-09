/**
* File Name: ONE_QrPDFController
* Description: 	Controller of the VisualForce Page oneQrPrinted
* Date: 10/10/2024
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: ONE_QrPDFControllerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		10/10/2024		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

public with sharing class ONE_QrPDFController {

    public String nombreDifunto { get; set; }
    public String idDifunto { get; set; }
    public String fechaDef { get; set; }
    public String imageUrl { get; set; }
    
    public ONE_QrPDFController() {

        try{
            this.nombreDifunto = ApexPages.currentPage().getParameters().get('accountName');
            this.idDifunto = ApexPages.currentPage().getParameters().get('accountId');
            this.fechaDef = ApexPages.currentPage().getParameters().get('fechaDef');

            String contentQR = ApexPages.currentPage().getParameters().get('contentVersionId');

            if (this.nombreDifunto != null && contentQR != null) {
            this.imageUrl = getDownloadLink() + contentQR;
            System.debug('IMAGE URL: ' + imageUrl);
            }
            else {
                throw new MissingParameterException('Parámetros accountName o contentVersionId faltantes.');
            }

        }
        catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }

    public static String getDownloadLink(){
        return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/';
    }

    public class MissingParameterException extends Exception {}

}
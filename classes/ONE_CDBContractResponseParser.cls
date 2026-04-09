/**
 * Created by mchruscick001 on 06.10.2021 13:28.
 */

public with sharing class ONE_CDBContractResponseParser {
    public static final String CONTRACT_RESPONSE_NODE_PETICIO = 'peticio', CONTRACT_RESPONSE_NODE_SEPULTURA = 'sepultura',
            CONTRACT_RESPONSE_NODE_RETURN = 'retorn', CONTRACT_RESPONSE_NODE_COMPLEMENTS = 'complements', CONTRACT_RESPONSE_NODE_INVOICE = 'titular_fra';
    
    public static final String CONTRACT_RESPONSE_NODE_COMPLEMENT_ARTICLE_CODE = 'coarticle', CONTRACT_RESPONSE_NODE_COMPLEMENT_LINE_HOLDER_CODE = 'cotitular',
            CONTRACT_RESPONSE_NODE_COMPLEMENT_QUANTITY = 'coquantitat', CONTRACT_RESPONSE_NODE_COMPLEMENT_VAT_PERCENTAGE = 'coporiva',
            CONTRACT_RESPONSE_NODE_COMPLEMENT_NETTO_AMOUNT = 'coimpbase', CONTRACT_RESPONSE_NODE_COMPLEMENT_IVA_AMOUNT = 'coimpquota',
            CONTRACT_RESPONSE_NODE_COMPLEMENT_GROSS_AMOUNT = 'coimptotal', CONTRACT_RESPONSE_NODE_COMPLEMENT_FRONT_TEXT = 'cotext_frontal',
            CONTRACT_RESPONSE_NODE_COMPLEMENT_LATERAL_TEXT = 'cotext_lateral';

    public static final String CONTRACT_RESPONSE_NODE_TITULAR_FRA_CODE = 'ticodi', CONTRACT_RESPONSE_NODE_TITULAR_FRA_DOCUMENT_TYPE = 'titipdocu',
            CONTRACT_RESPONSE_NODE_TITULAR_FRA_DOCUMENT_NUMBER = 'tinumdocu', CONTRACT_RESPONSE_NODE_TITULAR_FRA_NAME = 'tinom',
    CONTRACT_RESPONSE_NODE_TITULAR_FRA_NAME_1 = 'ticog1', CONTRACT_RESPONSE_NODE_TITULAR_FRA_COUNTRY = 'tinompais',
    CONTRACT_RESPONSE_NODE_TITULAR_FRA_PROVINCE = 'ticodprovi', CONTRACT_RESPONSE_NODE_TITULAR_FRA_CITY = 'tinommunic',
    CONTRACT_RESPONSE_NODE_TITULAR_FRA_STREET = 'ticarrer', CONTRACT_RESPONSE_NODE_TITULAR_FRA_ZIP_CODE = 'tizip',
    CONTRACT_RESPONSE_NODE_TITULAR_FRA_TELEPHONE = 'titelef', CONTRACT_RESPONSE_NODE_TITULAR_FRA_EMAIL= 'tiemail';

    public static final String CONTRACT_RESPONSE_NODE_ERROR_VALIDITY = 'rttipus', CONTRACT_RESPONSE_NODE_ERROR_MESSAGE = 'rterror';
    
    public static ONE_CDBContractResponse extractContractResponse(Dom.Document serviceResponse) {
        return getContractResponse(ONE_CDBSoapResponseParser.getResponseDocument(serviceResponse));
    }

    static ONE_CDBContractResponse getContractResponse(List<Dom.XmlNode> responseDocument) {
        ONE_CDBContractResponse contractResponse = new ONE_CDBContractResponse();
        List<ONE_CDBContractResponse.Retorn> returnValues = new List<ONE_CDBContractResponse.Retorn>();
        List<ONE_CDBContractResponse.Complements> complementsValues = new List<ONE_CDBContractResponse.Complements>();
        List<ONE_CDBContractResponse.TitularFra> invoiceValues = new List<ONE_CDBContractResponse.TitularFra>();
        if (responseDocument != null) {
            for (Dom.XmlNode documentNode : responseDocument) {
                if (documentNode.getName() == CONTRACT_RESPONSE_NODE_PETICIO) {
                    contractResponse.peticio = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, contractResponse.peticio, CONTRACT_RESPONSE_NODE_PETICIO);
                } else if (documentNode.getName() == CONTRACT_RESPONSE_NODE_SEPULTURA) {
                    contractResponse.sepultura = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, contractResponse.sepultura, CONTRACT_RESPONSE_NODE_SEPULTURA);
                } else if (documentNode.getName() == CONTRACT_RESPONSE_NODE_RETURN) {
                    returnValues.add(getReturnValues(documentNode.getChildElements()));
                } else if (documentNode.getName() == CONTRACT_RESPONSE_NODE_COMPLEMENTS) {
                    complementsValues.add(getComplementValues(documentNode.getChildElements()));
                } else if (documentNode.getName() == CONTRACT_RESPONSE_NODE_INVOICE) {
                    invoiceValues.add(getInvoiceValues(documentNode.getChildElements()));
                }
            }
        }
        contractResponse.retorn = returnValues;
        contractResponse.complements = complementsValues;
        contractResponse.invoices = invoiceValues;
        return contractResponse;
    }
    
    static ONE_CDBContractResponse.Retorn getReturnValues(List<Dom.XmlNode> responseDocument) {
        ONE_CDBContractResponse.Retorn returnValues = new ONE_CDBContractResponse.Retorn();
        for (Dom.XmlNode documentNode : responseDocument) {
            returnValues.rttipus = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, returnValues.rttipus, CONTRACT_RESPONSE_NODE_ERROR_VALIDITY);
            returnValues.rterror = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, returnValues.rterror, CONTRACT_RESPONSE_NODE_ERROR_MESSAGE); 
        }
        return returnValues;
    }

    static ONE_CDBContractResponse.TitularFra getInvoiceValues(List<Dom.XmlNode> responseDocument) {
        ONE_CDBContractResponse.TitularFra invoiceValues = new ONE_CDBContractResponse.TitularFra();
        for (Dom.XmlNode documentNode : responseDocument) {
            invoiceValues.ticodi = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.ticodi, CONTRACT_RESPONSE_NODE_TITULAR_FRA_CODE);
            invoiceValues.titipdocu = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.titipdocu, CONTRACT_RESPONSE_NODE_TITULAR_FRA_DOCUMENT_TYPE);
            invoiceValues.tinumdocu = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.tinumdocu, CONTRACT_RESPONSE_NODE_TITULAR_FRA_DOCUMENT_NUMBER);
            invoiceValues.tinom = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.tinom, CONTRACT_RESPONSE_NODE_TITULAR_FRA_NAME);
            invoiceValues.ticog1 = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.ticog1, CONTRACT_RESPONSE_NODE_TITULAR_FRA_NAME_1);
            invoiceValues.tinompais = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.tinompais, CONTRACT_RESPONSE_NODE_TITULAR_FRA_COUNTRY);
            invoiceValues.ticodprovi = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.ticodprovi, CONTRACT_RESPONSE_NODE_TITULAR_FRA_PROVINCE);
            invoiceValues.tinommunic = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.tinommunic, CONTRACT_RESPONSE_NODE_TITULAR_FRA_CITY);
            invoiceValues.ticarrer = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.ticarrer, CONTRACT_RESPONSE_NODE_TITULAR_FRA_STREET);
            invoiceValues.tizip = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.tizip, CONTRACT_RESPONSE_NODE_TITULAR_FRA_ZIP_CODE);
            invoiceValues.titelef = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.titelef, CONTRACT_RESPONSE_NODE_TITULAR_FRA_TELEPHONE);
            invoiceValues.tiemail = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, invoiceValues.tiemail, CONTRACT_RESPONSE_NODE_TITULAR_FRA_EMAIL);
        }
        return invoiceValues;
    }

    static ONE_CDBContractResponse.Complements getComplementValues(List<Dom.XmlNode> responseDocument) {
        ONE_CDBContractResponse.Complements complementValues = new ONE_CDBContractResponse.Complements();
        for (Dom.XmlNode documentNode : responseDocument) {
            complementValues.coarticle = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.coarticle, CONTRACT_RESPONSE_NODE_COMPLEMENT_ARTICLE_CODE);
            complementValues.cotitular = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.cotitular, CONTRACT_RESPONSE_NODE_COMPLEMENT_LINE_HOLDER_CODE);
            complementValues.coquantitat = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.coquantitat, CONTRACT_RESPONSE_NODE_COMPLEMENT_QUANTITY);
            complementValues.coporiva = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.coporiva, CONTRACT_RESPONSE_NODE_COMPLEMENT_VAT_PERCENTAGE);
            complementValues.coimpbase = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.coimpbase, CONTRACT_RESPONSE_NODE_COMPLEMENT_NETTO_AMOUNT);
            complementValues.coimpquota = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.coimpquota, CONTRACT_RESPONSE_NODE_COMPLEMENT_IVA_AMOUNT);
            complementValues.coimptotal = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.coimptotal, CONTRACT_RESPONSE_NODE_COMPLEMENT_GROSS_AMOUNT);
            complementValues.cotextFrontal = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.cotextFrontal, CONTRACT_RESPONSE_NODE_COMPLEMENT_FRONT_TEXT);
            complementValues.cotextLateral = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, complementValues.cotextLateral, CONTRACT_RESPONSE_NODE_COMPLEMENT_LATERAL_TEXT);
        }
        return complementValues;
    }
}
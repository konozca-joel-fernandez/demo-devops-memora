/**
 * Created by mchruscick001 on 04.10.2021 11:51.
 */

public with sharing class ONE_CDBContractService {
    final static String ERROR_MESSAGES_SEPARATOR = ' / ';
    final static String SF_DECIMAL_SEPARATOR = '.';
    final static String CDB_DECIMAL_SEPARATOR = ',';
    public final static String FATAL_ERROR_VALIDITY_LETTER = 'E';
    final static String SUB_PRODUCTS_CREATED_STATUS = 'OK';
    final static String SUB_PRODUCTS_NOT_CREATED_STATUS = 'KO';
    final static Set<String> SLI_CREATION_CONTRACT_TYPES = new Set<String>{'P', 'C', 'R'};
    final static Set<String> INVOICE_MATCHING_CONTRACT_TYPES = new Set<String>{'C', 'R'};

    @InvocableMethod(Label='Contract Service')
    public static List<ContractResponse> sendContractToCDB(List<Id> presupuestoId) {
        ONE_Presupuesto__c presupuesto = ONE_PresupuestoSelector.selectPresupuesto(presupuestoId[0]);
        ONE_CDBContractResponse contractResponse = processContractResponse(doRequest(presupuesto));
        if (SLI_CREATION_CONTRACT_TYPES.contains(presupuesto.ONE_Tipo_De_Solicitud_CB__c) && areThereNoErrorsAndComplementsReturned(contractResponse)) {
            return insertProductsAndValidateIfAnyErrors(contractResponse, presupuesto);
        }
        return new List<ContractResponse>{new ContractResponse(contractResponse)};
    }
    
    static Dom.Document doRequest(ONE_Presupuesto__c presupuesto) {
        return ONE_CDBService.callCDBContractService(ONE_CDBContractRequestBuilder.buildRequest(presupuesto));
    }

    static ONE_CDBContractResponse processContractResponse(Dom.Document response) {
        return ONE_CDBContractResponseParser.extractContractResponse(response);
    }

    static List<Database.UpsertResult> insertComplements(ONE_CDBContractResponse contractResponse, ONE_Presupuesto__c presupuesto) {
        return Database.upsert(buildSLIProducts(contractResponse, presupuesto));
    }

    static Boolean doesInsertResultedInErrors(List<Database.UpsertResult> saveResults) {
        for (Database.UpsertResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                return true;
            }
        }
        return false;
    }
    
    static List<ONE_SLI_Producto_CB__c> buildSLIProducts(ONE_CDBContractResponse contractResponse, ONE_Presupuesto__c presupuesto) {
        Map<String, ONE_Producto__c> commercialCode2Product = ONE_CDBContractResponseMapper.getCommercialCode2Product(contractResponse.complements);
        Map<String, ONE_SLI_Producto_CB__c> commercialCode2SLIProduct = ONE_CDBContractResponseMapper.getCommercialCode2SLIProduct(presupuesto.Id);
        Map<String, Account> productHeadline2AccountId = INVOICE_MATCHING_CONTRACT_TYPES.contains(presupuesto?.ONE_Tipo_De_Solicitud_CB__c) ? ONE_CDBContractResponseMapper.getProductHeadline2AccountId(contractResponse, presupuesto) : new Map<String, Account>();
        List<ONE_SLI_Producto_CB__c> products = new List<ONE_SLI_Producto_CB__c>();
        if (!commercialCode2Product.isEmpty()) {
            for (ONE_CDBContractResponse.Complements complement : contractResponse.complements) {
                products.add(buildSLIProduct(complement, commercialCode2Product, productHeadline2AccountId, commercialCode2SLIProduct, presupuesto.Id));
            }
        }
        return products;
    }

    static ONE_SLI_Producto_CB__c buildSLIProduct(
            ONE_CDBContractResponse.Complements complement,
            Map<String, ONE_Producto__c> codigoCommercial2Product,
            Map<String, Account> cotitular2AccountId,
            Map<String, ONE_SLI_Producto_CB__c> commercialCode2SLIProduct,
            Id presupuestoId) {
        return new ONE_SLI_Producto_CB__c(
                Id = commercialCode2SLIProduct.get(complement?.coarticle)?.Id,
                ONE_Producto__c = codigoCommercial2Product.get(complement?.coarticle)?.Id,
                ONE_Titular_SLI_CB__c = cotitular2AccountId.isEmpty() ? null : cotitular2AccountId.get(complement?.cotitular)?.Id,
                ONE_Presupuesto__c = presupuestoId,
                ONE_Unidades__c = getDecimalIfNotNull(complement?.coquantitat),
                ONE_Porcentaje_IVA__c = getDecimalIfNotNull(complement?.coporiva),
                ONE_Importe_Base__c = getDecimalIfNotNull(complement?.coimpbase),
                ONE_Importe_IVA__c = getDecimalIfNotNull(complement?.coimpquota),
                ONE_Importe_Neto_Total__c = getDecimalIfNotNull(complement?.coimptotal),
                ONE_Texto_Frontal_Lapida__c = complement?.cotextFrontal,
                ONE_Texto_Lateral_Lapida__c = complement?.cotextLateral
        );
    }

    static Decimal getDecimalIfNotNull(String stringValue) {
        return stringValue != null ? Decimal.valueOf(stringValue.replace(CDB_DECIMAL_SEPARATOR, SF_DECIMAL_SEPARATOR)) : null;
    }

    static List<ContractResponse> insertProductsAndValidateIfAnyErrors(ONE_CDBContractResponse returnedComplements, ONE_Presupuesto__c presupuesto) {
        try {
            List<Database.UpsertResult> complementsSaveResults = insertComplements(returnedComplements, presupuesto);
            if (doesInsertResultedInErrors(complementsSaveResults)) {
                return new List<ContractResponse>{
                        new ContractResponse(getErrorMessageWithoutSlashAtTheEnd(extractErrorsFromSaveResult(complementsSaveResults)))
                };
            }
            return new List<ContractResponse>{new ContractResponse(returnedComplements)};
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            return new List<ContractResponse>{new ContractResponse('Error ' + e.getMessage())};
        }
    }

    static String extractErrorsFromSaveResult(List<Database.UpsertResult> complementsSaveResults) {
        String complementsSaveResultErrors;
        for (Database.UpsertResult saveResult : complementsSaveResults) {
            for (Database.Error saveResultError : saveResult.errors) {
                complementsSaveResultErrors += saveResultError.message + ERROR_MESSAGES_SEPARATOR;
            }
        }
        return complementsSaveResultErrors;
    }

    static Boolean areThereNoErrorsAndComplementsReturned(ONE_CDBContractResponse contractResponse) {
        return !doesResponseContainsFatalError(contractResponse.retorn) && !contractResponse.complements.isEmpty();
    }

    static Boolean doesResponseContainsFatalError(List<ONE_CDBContractResponse.Retorn> errorList) {
        for (ONE_CDBContractResponse.Retorn returnError : errorList) {
            if (returnError.rttipus == FATAL_ERROR_VALIDITY_LETTER) {
                return true;
            }
        }
        return false;
    }
    
    static String getErrorMessageWithoutSlashAtTheEnd(String errorMessage) {
        return String.isNotBlank(errorMessage) ? errorMessage.substring(0, errorMessage.length() - 3) : errorMessage;
    }
    
    public class ContractResponse {
        @InvocableVariable
        public String peticio;
        @InvocableVariable
        public String sepultura;
        @InvocableVariable
        public String rterror;
        @InvocableVariable
        public String lineCreationStatus;
        @InvocableVariable
        public Boolean response;

        public ContractResponse(String errorMessage) {
            this.rterror = errorMessage;
            this.lineCreationStatus = SUB_PRODUCTS_NOT_CREATED_STATUS;
            this.response = false;
        }
        
        public ContractResponse(ONE_CDBContractResponse contractResponse) {
            this.peticio = contractResponse?.peticio;
            this.sepultura = contractResponse?.sepultura;
            this.rterror = getErrorMessageWithoutSlashAtTheEnd(getExtractErrorsToAString(contractResponse.retorn));
            this.lineCreationStatus = !contractResponse?.complements?.isEmpty() ? SUB_PRODUCTS_CREATED_STATUS : SUB_PRODUCTS_NOT_CREATED_STATUS;
            this.response = !doesResponseContainsFatalError(contractResponse.retorn);
        }
        
        String getExtractErrorsToAString(List<ONE_CDBContractResponse.Retorn> returnErrors) {
            String concatenatedErrors = '';
            for (ONE_CDBContractResponse.Retorn returnError : returnErrors) {
                concatenatedErrors += getConcatenateErrorTypeWithErrorMessage(returnError) + ERROR_MESSAGES_SEPARATOR;
            }
            return concatenatedErrors;
        }
        
        String getConcatenateErrorTypeWithErrorMessage(ONE_CDBContractResponse.Retorn returnError) {
            return returnError.rttipus + ' ' + returnError.rterror;
        }
    }
}
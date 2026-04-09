/**
 * Created by mchruscick001 on 08.11.2021 14:44.
 */

public with sharing class ONE_CDBContractResponseMapper {
    static Set<String> PERSONAL_DOCUMENT_TYPES = new Set<String>{'1', '2', '4'};
    static String COMPANY_DOCUMENT_TYPE = '3';
    static final Boolean BUSINESS_TYPE_ACCOUNT = true, PERSONAL_TYPE_ACCOUNT = false;
    
    public static Map<String, ONE_Producto__c> getCommercialCode2Product(List<ONE_CDBContractResponse.Complements> complements) {
        Map<String, ONE_Producto__c> commercialCode2Product = new Map<String, ONE_Producto__c>();
        for (ONE_Producto__c parentProduct : ONE_ProductoSelector.selectProductByCommercialProducts(getExtractArticleCodesFromRequest(complements))) {
            commercialCode2Product.put(parentProduct.ONE_Codigo_Comercial__c, parentProduct);
        }
        return commercialCode2Product;
    }

    public static Map<String, ONE_SLI_Producto_CB__c> getCommercialCode2SLIProduct(Id presupuestoId) {
        Map<String, ONE_SLI_Producto_CB__c> commercialCode2Product = new Map<String, ONE_SLI_Producto_CB__c>();
        for (ONE_SLI_Producto_CB__c existingSLIProduct : [SELECT Id, ONE_Producto__r.ONE_Codigo_Comercial__c FROM ONE_SLI_Producto_CB__c WHERE ONE_Presupuesto__c = :presupuestoId]) {
            commercialCode2Product.put(existingSLIProduct.ONE_Producto__r.ONE_Codigo_Comercial__c, existingSLIProduct);
        }
        return commercialCode2Product;
    }

    public static Set<String> getExtractArticleCodesFromRequest(List<ONE_CDBContractResponse.Complements> complements) {
        Set<String> parentProductIds = new Set<String>();
        for (ONE_CDBContractResponse.Complements complement : complements) {
            parentProductIds.add(complement.coarticle);
        }
        return parentProductIds;
    }

    static List<Account> getAllAccountsByCIF(List<Account> CIFAccounts, String CIF) {
        List<Account> accountsWithTheSameCIF = new List<Account>();
        for (Account CIFAccount : CIFAccounts) {
            if (CIFAccount.ONE_CIF__c == CIF) {
                accountsWithTheSameCIF.add(CIFAccount);
            }
        }
        return accountsWithTheSameCIF;
    }
    
    public static Map<String, String> getProductTitle2InvoiceDocumentNumber(List<ONE_CDBContractResponse.Complements> contractResponseComplements, Map<String, ONE_CDBContractResponse.TitularFra> invoiceCode2Invoice) {
        Map<String, String> productTitle2InvoiceDocumentNumber = new Map<String, String>();
        for (ONE_CDBContractResponse.Complements product : contractResponseComplements) {
            if (getDocumentNumberByDocumentNumber(invoiceCode2Invoice, product?.cotitular) != null) {
                productTitle2InvoiceDocumentNumber.put(product?.cotitular, getDocumentNumberByDocumentNumber(invoiceCode2Invoice, product?.cotitular));
            }
        }
        return productTitle2InvoiceDocumentNumber;
    }

    public static Map<String, Account> getAccountDocumentNumber2AccountId(Map<String, String> productTitle2InvoiceDocumentNumber) {
        Map<String, Account> accountDocumentNumber2AccountId = new Map<String, Account>();
        for (Account acc : ONE_AccountSelector.selectAccountsByDocumentNumbers(productTitle2InvoiceDocumentNumber.values())) {
            accountDocumentNumber2AccountId.put(acc.ONE_N_Documento__pc, acc);
        }
        return accountDocumentNumber2AccountId;
    }
    
    public static Map<String, ONE_CDBContractResponse.TitularFra> getInvoiceCode2Invoice(List<ONE_CDBContractResponse.TitularFra> contractResponseInvoices) {
        Map<String, ONE_CDBContractResponse.TitularFra> invoiceCode2Invoice = new Map<String, ONE_CDBContractResponse.TitularFra>();
        for (ONE_CDBContractResponse.TitularFra invoice : contractResponseInvoices) {
            invoiceCode2Invoice.put(invoice?.ticodi, invoice);
        }
        return invoiceCode2Invoice;
    }

    public static Map<String, List<Account>> getAccountCIFNumber2AccountCIFNumbers(List<String> invoiceDocumentNumbers) {
        Map<String, List<Account>> accountCIFNumber2AccountCIFNumbers = new Map<String, List<Account>>();
        List<Account> CIFAccounts = ONE_AccountSelector.selectAccountsByCIF(invoiceDocumentNumbers);
        for (Account acc : CIFAccounts) {
            accountCIFNumber2AccountCIFNumbers.put(acc.ONE_CIF__c, getAllAccountsByCIF(CIFAccounts, acc.ONE_CIF__c));
        }
        return accountCIFNumber2AccountCIFNumbers;
    }
    
    public static Map<String, Account> getProductHeadline2AccountId(ONE_CDBContractResponse contractResponse, ONE_Presupuesto__c presupuesto) {
        Map<String, ONE_CDBContractResponse.TitularFra> invoiceCode2Invoice = getInvoiceCode2Invoice(contractResponse?.invoices);
        Map<String, String> productTitle2InvoiceDocumentNumber = getProductTitle2InvoiceDocumentNumber(contractResponse?.complements, invoiceCode2Invoice);
        Map<String, Account> accountDocumentNumber2AccountId = getAccountDocumentNumber2AccountId(productTitle2InvoiceDocumentNumber);
        Map<String, List<Account>> accountCIFNumber2AccountCIFNumbers = getAccountCIFNumber2AccountCIFNumbers(productTitle2InvoiceDocumentNumber.values());
        Map<String, Account> productTitle2AccountId = new Map<String, Account>();
        for (String invoiceCode : invoiceCode2Invoice.keySet()) {
            String documentType = getDocumentTypeByDocumentNumber(invoiceCode2Invoice, invoiceCode);
            if (isDocumentOfPersonalType(documentType)) {
                checkIfAccountMatchExistsAndCreateNewOneIfDont(invoiceCode, accountDocumentNumber2AccountId, productTitle2AccountId, invoiceCode2Invoice);
            } else if (isDocumentOfCompanyType(documentType)) {
                List<Account> matchedAccounts = getMatchedAccount(accountCIFNumber2AccountCIFNumbers, invoiceCode2Invoice, invoiceCode);
                checkIfAccountWasMatched(matchedAccounts, invoiceCode, productTitle2AccountId, presupuesto, invoiceCode2Invoice.get(invoiceCode));
            }
        }
        List<Account> accountsToBeInserted = new List<Account>();
        for (Account acc : productTitle2AccountId.values()) {
            if (acc.Id == null) {
                accountsToBeInserted.add(acc);
            }
        }
        insert accountsToBeInserted;
        return productTitle2AccountId;
    }
    
    static List<Account> getMatchedAccount(Map<String, List<Account>> accountCIFNumber2AccountCIFNumbers, Map<String, ONE_CDBContractResponse.TitularFra> invoiceCode2Invoice, String invoiceCode) {
        return (String.isNotBlank(getDocumentNumberByDocumentNumber(invoiceCode2Invoice, invoiceCode)) && doesAccountsExistsInAMap(accountCIFNumber2AccountCIFNumbers, getDocumentNumberByDocumentNumber(invoiceCode2Invoice, invoiceCode))) ? accountCIFNumber2AccountCIFNumbers.get(getDocumentNumberByDocumentNumber(invoiceCode2Invoice, invoiceCode)) : getEmptyAccountsList();
    }
    
    static Map<String, Account> checkIfAccountMatchExistsAndCreateNewOneIfDont(String invoiceCode, Map<String, Account> accountDocumentNumber2AccountId, Map<String, Account> productTitle2AccountId, Map<String, ONE_CDBContractResponse.TitularFra> invoiceCode2Invoice) {
        if (accountDocumentNumber2AccountId.containsKey(getDocumentNumberByDocumentNumber(invoiceCode2Invoice, invoiceCode))) {
            productTitle2AccountId.put(invoiceCode, accountDocumentNumber2AccountId.get(getDocumentNumberByDocumentNumber(invoiceCode2Invoice, invoiceCode)));
        } else {
            productTitle2AccountId.put(invoiceCode, getCreateNewPersonalAccountBasedOnInvoice(invoiceCode2Invoice.get(invoiceCode)));
        }
        return productTitle2AccountId;
    }
    
    static Boolean doesAccountsExistsInAMap(Map<String, List<Account>> accountCIFNumber2AccountCIFNumbers, String documentNumber) {
        return accountCIFNumber2AccountCIFNumbers.get(documentNumber) != null;    
    }
    
    static void checkIfAccountWasMatched(List<Account> matchedAccountsByCIF, String invoiceCode, Map<String, Account> productTitle2AccountId, ONE_Presupuesto__c presupuesto, ONE_CDBContractResponse.TitularFra invoice) {
        if (isThereOneAccountMatchedWithInvoice(matchedAccountsByCIF)) {
            productTitle2AccountId.put(invoiceCode, getFirstAccountFromList(matchedAccountsByCIF));
        } else if (isThereMoreThanOneAccountMatchedWithInvoice(matchedAccountsByCIF)) {
            productTitle2AccountId.put(invoiceCode, getAccountThatMatchesPresupuestoOrAssignFirstOne(matchedAccountsByCIF, presupuesto));
        } else if (isThereNoAccountMatchedWithInvoice(matchedAccountsByCIF)) {
            productTitle2AccountId.put(invoiceCode, getCreateNewBusinessAccountBasedOnInvoice(invoice));
        }
    }
    
    static Account getFirstAccountFromList(List<Account> accounts) {
        return accounts.get(0);
    }
    
    static Account getAccountThatMatchesPresupuestoOrAssignFirstOne(List<Account> matchedAccountsByCIF, ONE_Presupuesto__c presupuesto) {
        return String.isBlank(presupuesto.ONE_Codigo_Titular_CB__c) ? getFirstAccountFromList(matchedAccountsByCIF) : new Account(Id = presupuesto.ONE_Codigo_Titular_CB__c);
    }
    
    static Account getCreateNewPersonalAccountBasedOnInvoice(ONE_CDBContractResponse.TitularFra invoice) {
        return getCreateNewAccountBasedOnInvoice(PERSONAL_TYPE_ACCOUNT, invoice);
    }
    
    static Account getCreateNewBusinessAccountBasedOnInvoice(ONE_CDBContractResponse.TitularFra invoice) {
        return getCreateNewAccountBasedOnInvoice(BUSINESS_TYPE_ACCOUNT, invoice);
    }
    
    static Account getCreateNewAccountBasedOnInvoice(Boolean createBusinessType, ONE_CDBContractResponse.TitularFra invoice) {
        return createBusinessType ? getBuildBusinessAccountFields(invoice) : getBuildPersonalAccountFields(invoice);
    }
    
    static Account getBuildPersonalAccountFields(ONE_CDBContractResponse.TitularFra invoice) {
        Account personAccount = new Account();
        personAccount.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR);
        personAccount.FirstName = invoice?.tinom;
        personAccount.LastName = invoice?.ticog1;
        personAccount.ONE_Tipo_de_documento__pc = ONE_CDBRequestBuilderUtilities.getSFFormOfDocumentType(invoice?.titipdocu);
        personAccount.ONE_N_Documento__pc = invoice?.tinumdocu;
        personAccount.ONE_Pais__pc = ONE_CDBRequestBuilderUtilities.getSFFormOfCountry(invoice?.tinompais);
        personAccount.ONE_Provincia__pc = ONE_CDBRequestBuilderUtilities.getSFFormOfProvince(invoice?.ticodprovi);
        personAccount.ONE_Municipio__pc = invoice?.tinommunic;
        personAccount.ONE_Direccion__pc = invoice?.ticarrer;
        personAccount.ONE_Codigo_Postal__pc = invoice?.tizip;
        personAccount.PersonHomePhone = invoice?.titelef;
        personAccount.PersonEmail = invoice?.tiemail;
        return personAccount;
    }
    
    static Account getBuildBusinessAccountFields(ONE_CDBContractResponse.TitularFra invoice) {
        Account businessAccount = new Account();
        businessAccount.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS);
        businessAccount.Name = invoice?.tinom;
        businessAccount.ONE_CIF__c = invoice?.tinumdocu;
        businessAccount.ONE_Pais__c = ONE_CDBRequestBuilderUtilities.getSFFormOfCountry(invoice?.tinompais);
        businessAccount.ONE_Provincia__c = ONE_CDBRequestBuilderUtilities.getSFFormOfProvince(invoice?.ticodprovi);
        businessAccount.ONE_Municipio_Direccion__c = invoice?.tinommunic;
        businessAccount.ONE_Direccion__c = invoice?.ticarrer;
        businessAccount.ONE_Codigo_Postal__c = invoice?.tizip;
        businessAccount.Phone = invoice?.titelef;
        businessAccount.ONE_Email__c = invoice?.tiemail;
        return businessAccount;
    }

    static Boolean isThereNoAccountMatchedWithInvoice(List<Account> matchedAccountsByCIF) {
        return matchedAccountsByCIF.isEmpty();
    }

    static Boolean isThereOneAccountMatchedWithInvoice(List<Account> matchedAccountsByCIF) {
        return matchedAccountsByCIF.size() == 1;
    }
    
    static Boolean isThereMoreThanOneAccountMatchedWithInvoice(List<Account> matchedAccountsByCIF) {
        return matchedAccountsByCIF.size() > 1;
    }
    
    static Boolean isDocumentOfPersonalType(String documentType) {
        return PERSONAL_DOCUMENT_TYPES.contains(documentType);
    }

    static Boolean isDocumentOfCompanyType(String documentType) {
        return documentType == COMPANY_DOCUMENT_TYPE;
    }

    static String getDocumentTypeByDocumentNumber(Map<String, ONE_CDBContractResponse.TitularFra> invoiceCode2Invoice, String documentType) {
        return invoiceCode2Invoice.get(documentType)?.titipdocu;
    }

    static String getDocumentNumberByDocumentNumber(Map<String, ONE_CDBContractResponse.TitularFra> invoiceCode2Invoice, String documentNumber) {
        return invoiceCode2Invoice.get(documentNumber)?.tinumdocu;
    }

    static List<Account> getEmptyAccountsList() {
        return new List<Account>();
    }
}
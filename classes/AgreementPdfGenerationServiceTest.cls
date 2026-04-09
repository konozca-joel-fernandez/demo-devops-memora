@isTest
public class AgreementPdfGenerationServiceTest {
    
    @testSetup
    private static void testSetup() {

        Account account = new Account(
            Name = 'Company',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
            ONE_Nivel_Jerarquia_Cuentas__c='Jerarquía 2'
        );
        insert account;

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar'
        );
        insert lugar;

        ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Lugar__c = lugar.Id,
            ONE_Compania__c = account.Id
        );
        insert catalogo;

        ONE_Segmentacion_Acuerdo__c agreement = new ONE_Segmentacion_Acuerdo__c(
            ONE_Vigencia_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = account.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Lugar__c = lugar.Id
        );
        insert agreement;
    }

    @isTest
    private static void createAndLinkPdf_1() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        AgreementPdfGenerationService.FlowInput input = new AgreementPdfGenerationService.FlowInput();
        input.logo = '';
        input.agreementId = '';
        input.accountId = String.valueOf(account.Id);
        input.accountNameForPdf = '';
        input.validityDate = Date.today();
        input.delegationId = '';
        input.operationalZoneId = '';
        input.operationalAreaId = '';
        input.delegation = '';
        input.operationalZone = '';
        input.operationalArea = '';
        input.centerId = '';
        List<AgreementPdfGenerationService.FlowInput> inputs = new List<AgreementPdfGenerationService.FlowInput>{input};
        List<AgreementPdfGenerationService.FlowOutput> outputs = AgreementPdfGenerationService.createAndLinkPdf(inputs);
        Test.stopTest();

        AgreementPdfGenerationService.FlowOutput output = outputs[0];
        System.assert(output.success);
        System.assertEquals('Se ha generado un PDF con 1 acuerdo(s).', output.successMessage);
        System.assertEquals(null, output.errorMessage);
        System.assert(String.isNotBlank(output.contentVersionId));
    }

    @isTest
    private static void createAndLinkPdf_2() {

        ONE_Segmentacion_Acuerdo__c agreement = [SELECT Id FROM ONE_Segmentacion_Acuerdo__c LIMIT 1];
        Test.startTest();
        AgreementPdfGenerationService.FlowInput input = new AgreementPdfGenerationService.FlowInput();
        input.logo = '';
        input.agreementId = String.valueOf(agreement.Id);
        input.accountId = '';
        input.accountNameForPdf = '';
        input.validityDate = null;
        input.delegationId = '';
        input.operationalZoneId = '';
        input.operationalAreaId = '';
        input.delegation = '';
        input.operationalZone = '';
        input.operationalArea = '';
        input.centerId = '';
        List<AgreementPdfGenerationService.FlowInput> inputs = new List<AgreementPdfGenerationService.FlowInput>{input};
        List<AgreementPdfGenerationService.FlowOutput> outputs = AgreementPdfGenerationService.createAndLinkPdf(inputs);
        Test.stopTest();

        AgreementPdfGenerationService.FlowOutput output = outputs[0];
        System.assert(output.success);
        System.assertEquals('Se ha generado un PDF con 1 acuerdo(s).', output.successMessage);
        System.assertEquals(null, output.errorMessage);
        System.assert(String.isNotBlank(output.contentVersionId));
    }
    
    
    @isTest
    private static void createAndLinkPdf_Catalogos() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        ONE_PDFCompaniasGenerationService.FlowInput input = new ONE_PDFCompaniasGenerationService.FlowInput();
        input.logo = '';
        input.companias = String.valueOf(account.Id);
        input.accountNameForPdf = '';
        input.validityDate = Date.today();
        input.delegationId = '';
        input.operationalZoneId = '';
        input.operationalAreaId = '';
        input.delegation = '';
        input.operationalZone = '';
        input.operationalArea = '';
        input.centerId = '';
        input.catalogsInNegotiation = true;
        input.finalCatalogs = true;
       
        List<ONE_PDFCompaniasGenerationService.FlowInput> inputs = new List<ONE_PDFCompaniasGenerationService.FlowInput>{input};
        List<ONE_PDFCompaniasGenerationService.FlowOutput> outputs = ONE_PDFCompaniasGenerationService.createAndLinkPdf(inputs);
        Test.stopTest();

        ONE_PDFCompaniasGenerationService.FlowOutput output = outputs[0];
    }
}
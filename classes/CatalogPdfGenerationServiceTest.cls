@isTest
public class CatalogPdfGenerationServiceTest {
    
    @testSetup
    private static void testSetup() {

        Account account = new Account(
            Name = 'Company',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS)
        );
        insert account;

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar'
        );
        insert lugar;

        ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = account.Id,
            ONE_Lugar__c = lugar.Id
        );
        insert catalogo;
        
        ONE_Catalogo_De_Precios__c catalogoParticular = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Lugar__c = lugar.Id
        );
        insert catalogoParticular;
        
    }

    @isTest
    private static void createAndLinkPdf_1() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        CatalogPdfGenerationService.FlowInput input = new CatalogPdfGenerationService.FlowInput();
        input.logo = '';
        input.catalogId = '';
        input.accountId = String.valueOf(account.Id);
        input.validityDate = Date.today();
        input.delegationId = '';
        input.operationalZoneId = '';
        input.operationalAreaId = '';
        input.delegation = '';
        input.operationalZone = '';
        input.operationalArea = '';
        input.centerId = '';
        input.language='Euskera';
        List<CatalogPdfGenerationService.FlowInput> inputs = new List<CatalogPdfGenerationService.FlowInput>{input};
        List<CatalogPdfGenerationService.FlowOutput> outputs = CatalogPdfGenerationService.createAndLinkPdf(inputs);
        Test.stopTest();

        CatalogPdfGenerationService.FlowOutput output = outputs[0];
        System.assert(output.success);
        System.assertEquals('Se ha generado un PDF con 1 catálogo(s) de precios.', output.successMessage);
        System.assertEquals(null, output.errorMessage);
        System.assert(String.isNotBlank(output.contentVersionId));
    }
    @isTest
    private static void createAndLinkPdfParticular() {

      
        Test.startTest();
        ONE_CatalogoParticularGeneration.FlowInput input = new ONE_CatalogoParticularGeneration.FlowInput();
        input.logo = '';
        input.catalogId = '';
        input.validityDate = Date.today();
        input.delegationId = '';
        input.operationalZoneId = '';
        input.operationalAreaId = '';
        input.delegation = '';
        input.operationalZone = '';
        input.operationalArea = '';
        input.centerId = '';
        input.language='Euskera';
        input.showIDCol = true;
    	input.showBasePriceCol = true;
    	input.showTaxTypeCol = true;
        input.showGeneralConditions = true;
        input.dateGeneralConditions = '1 de Enero de 2023';
        input.showColTitles = true;
        
        List<ONE_CatalogoParticularGeneration.FlowInput> inputs = new List<ONE_CatalogoParticularGeneration.FlowInput>{input};
        List<ONE_CatalogoParticularGeneration.FlowOutput> outputs = ONE_CatalogoParticularGeneration.createAndLinkPdf(inputs);
        Test.stopTest();

        ONE_CatalogoParticularGeneration.FlowOutput output = outputs[0];
        System.assert(output.success);
        System.assertEquals('Se ha generado un PDF con 1 catálogo(s) de precios.', output.successMessage);
        System.assertEquals(null, output.errorMessage);
        System.assert(String.isNotBlank(output.contentVersionId));
    }
}
@isTest
public class CatalogPDFControllerTest {
    
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
        ONE_Catalogo_De_Precios__c catalogo2 = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Lugar__c = lugar.Id
        );
        insert catalogo2;

        ONE_Momento__c momento = new ONE_Momento__c(
            Name = ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT
        );
        insert momento;

        ONE_Agrupacion__c agrupacion = new ONE_Agrupacion__c(
            Name = ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = momento.Id
        );
        insert agrupacion;

        ONE_Categoria__c categoria = new ONE_Categoria__c(
            ONE_Agrupacion__c= agrupacion.Id,
            Name = (ONE_MomentoServiceConstants.VELACION_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0))).get(0)
        );
        insert categoria;

        ONE_Producto__c producto = new ONE_Producto__c(
            Name = 'Producto',
            ONE_Categoria__c = categoria.Id
        );
        insert producto;

        ONE_Entrada_De_Precio__c entradaPrecio = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Concepto_Comercial__c = producto.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio;
        ONE_Entrada_De_Precio__c entradaPrecio2 = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo2.Id,
            ONE_Concepto_Comercial__c = producto.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio2;
    }

    @isTest
    private static void catalogPDFController() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.CatalogPDF;
        pageRef.getParameters().put('logo', '');
        pageRef.getParameters().put('catalogId', '');
        pageRef.getParameters().put('accountId', String.valueOf(account.Id));
        pageRef.getParameters().put('validityDate', Date.today().format());
        pageRef.getParameters().put('delegationId', '');
        pageRef.getParameters().put('operationalZoneId', '');
        pageRef.getParameters().put('operationalAreaId', '');
        pageRef.getParameters().put('delegation', '');
        pageRef.getParameters().put('operationalZone', '');
        pageRef.getParameters().put('operationalArea', '');
        pageRef.getParameters().put('centerId', '');
        pageRef.getParameters().put('language', 'Castellano');
        Test.setCurrentPage(pageRef);
        CatalogPDFController controller = new CatalogPDFController();
        Test.stopTest();

        System.assertEquals(1, controller.catalogs.size());
    }
    @isTest
    private static void catalogPDFParticularController1() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.ONE_CatalogoParticularPDF;
        pageRef.getParameters().put('logo', '');
        pageRef.getParameters().put('catalogId', '');
        pageRef.getParameters().put('validityDate', Date.today().format());
        pageRef.getParameters().put('delegationId', '');
        pageRef.getParameters().put('operationalZoneId', '');
        pageRef.getParameters().put('operationalAreaId', '');
        pageRef.getParameters().put('delegation', '');
        pageRef.getParameters().put('operationalZone', '');
        pageRef.getParameters().put('operationalArea', '');
        pageRef.getParameters().put('centerId', '');
        pageRef.getParameters().put('language', 'Castellano');
        pageRef.getParameters().put('showIDCol', 'true');
        pageRef.getParameters().put('showBasePriceCol', 'true');
        pageRef.getParameters().put('showTaxTypeCol', 'true');
        pageRef.getParameters().put('showColTitles', 'true');
        pageRef.getParameters().put('showGeneralConditions', 'true');
        pageRef.getParameters().put('dateGeneralConditions', '1 de Enero de 2023');
        Test.setCurrentPage(pageRef);
        ONE_CatalogoParticularPDFController controller = new ONE_CatalogoParticularPDFController();
        Test.stopTest();

        System.assertEquals(1, controller.catalogs.size());
    }
    
    @isTest
    private static void catalogPDFParticularController2() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.ONE_CatalogoParticularPDF;
        pageRef.getParameters().put('logo', '');
        pageRef.getParameters().put('catalogId', '');
        pageRef.getParameters().put('validityDate', Date.today().format());
        pageRef.getParameters().put('delegationId', '');
        pageRef.getParameters().put('operationalZoneId', '');
        pageRef.getParameters().put('operationalAreaId', '');
        pageRef.getParameters().put('delegation', '');
        pageRef.getParameters().put('operationalZone', '');
        pageRef.getParameters().put('operationalArea', '');
        pageRef.getParameters().put('centerId', '');
        pageRef.getParameters().put('language', 'Catalan');
        pageRef.getParameters().put('showIDCol', 'true');
        pageRef.getParameters().put('showBasePriceCol', 'true');
        pageRef.getParameters().put('showTaxTypeCol', 'true');
        pageRef.getParameters().put('showColTitles', 'true');
        pageRef.getParameters().put('showGeneralConditions', 'true');
        pageRef.getParameters().put('dateGeneralConditions', '1 de Enero de 2023');
        Test.setCurrentPage(pageRef);
        ONE_CatalogoParticularPDFController controller = new ONE_CatalogoParticularPDFController();
        Test.stopTest();

        System.assertEquals(1, controller.catalogs.size());
    }
    
    @isTest
    private static void catalogPDFParticularController3() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.ONE_CatalogoParticularPDF;
        pageRef.getParameters().put('logo', '');
        pageRef.getParameters().put('catalogId', '');
        pageRef.getParameters().put('validityDate', Date.today().format());
        pageRef.getParameters().put('delegationId', '');
        pageRef.getParameters().put('operationalZoneId', '');
        pageRef.getParameters().put('operationalAreaId', '');
        pageRef.getParameters().put('delegation', '');
        pageRef.getParameters().put('operationalZone', '');
        pageRef.getParameters().put('operationalArea', '');
        pageRef.getParameters().put('centerId', '');
        pageRef.getParameters().put('language', 'Euskera');
        pageRef.getParameters().put('showIDCol', 'true');
        pageRef.getParameters().put('showBasePriceCol', 'false');
        pageRef.getParameters().put('showTaxTypeCol', 'false');
        pageRef.getParameters().put('showColTitles', 'false');
        pageRef.getParameters().put('showGeneralConditions', 'false');
        pageRef.getParameters().put('dateGeneralConditions', '');
        Test.setCurrentPage(pageRef);
        ONE_CatalogoParticularPDFController controller = new ONE_CatalogoParticularPDFController();
        Test.stopTest();

        System.assertEquals(1, controller.catalogs.size());
    }
}
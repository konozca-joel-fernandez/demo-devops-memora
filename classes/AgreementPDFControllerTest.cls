@isTest
public class AgreementPDFControllerTest {
    
    @testSetup
    private static void testSetup() {

        Account account = new Account(
            Name = 'Company',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
            ONE_Nivel_Jerarquia_Cuentas__c='Jerarquía 2',
            ONE_Tipo__c = 'Jerarquías'
        );
        insert account;

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar'
        );
        insert lugar;

        ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1)
        );
        insert catalogo;

        ONE_Segmentacion_Acuerdo__c acuerdo = new ONE_Segmentacion_Acuerdo__c(
            ONE_Vigencia_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = account.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Lugar__c = lugar.Id
        );
        insert acuerdo;

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

        ONE_Segmentacion_De_Linea__c segmentacionLinea = new ONE_Segmentacion_De_Linea__c(
            ONE_Segmentacion_Acuerdo__c = acuerdo.Id,
            ONE_Producto__c = producto.Id,
            ONE_Unidades__c = 1,
            ONE_Comportamiento__c = '01'
        );
        insert segmentacionLinea;
    }

    @isTest
    private static void agreementPDFController() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        ONE_Catalogo_De_Precios__c catalogo=[SELECT id FROM ONE_Catalogo_De_Precios__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.AgreementPDF;
        pageRef.getParameters().put('logo', '');
        pageRef.getParameters().put('agreementId', '');
        pageRef.getParameters().put('accountId', String.valueOf(account.Id));
        pageRef.getParameters().put('accountNameForPdf', '');
        pageRef.getParameters().put('validityDate', Date.today().format());
        pageRef.getParameters().put('delegationId', '');
        pageRef.getParameters().put('operationalZoneId', '');
        pageRef.getParameters().put('operationalAreaId', '');
        pageRef.getParameters().put('delegation', '');
        pageRef.getParameters().put('operationalZone', '');
        pageRef.getParameters().put('operationalArea', '');
        pageRef.getParameters().put('centerId', '');
        pageRef.getParameters().put('catalogoId', catalogo.Id);
        pageRef.getParameters().put('companias',String.valueOf(account.Id));
        pageRef.getParameters().put('status', 'En negociación,');
        Test.setCurrentPage(pageRef);
        AgreementPDFController controller = new AgreementPDFController();
        ONE_PDFCompaniasController controller2 =new ONE_PDFCompaniasController();
        Test.stopTest();

        System.assertEquals(1, controller.agreements.size());
    }
}
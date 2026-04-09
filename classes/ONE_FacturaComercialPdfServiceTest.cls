/**
 * Created by msulek003 on 27.04.2021.
 */
//Test class for the factura comercial PDF generation
@isTest
public with sharing class ONE_FacturaComercialPdfServiceTest {
    //Prepare required data for the test
    @TestSetup
    private static void testSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Fecha_De_Defuncion2__c = Datetime.now());
        
        Account accCIF = new Account(Name = 'John Smith', ONE_Nombre_Anexo__c= 'ParticularEmpresa', ONE_Tipo__c= 'Compañías', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
                                 RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                             ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                                  ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Fecha_De_Defuncion2__c = Datetime.now());
        

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);

        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
            ONE_Tipo_De_Impuesto__c = 'IVA',
            ONE_Lugar__c = lugar.Id);

        insert new List<Account> {acc, accCIF, accMemora};
            
        ONE_Interlocutor__c intCIF = new ONE_Interlocutor__c(Name = 'John Smith - INTERLOCUTOR', 
                                               				 ONE_Contacto__c = accCIF.Id);
        insert intCIF;

        ONE_Expediente__c servicio = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Defuncion'),
            ONE_Difunto__c = acc.Id,
            ONE_Centro_Del_Expediente__c = accMemora.Id
        );
        insert servicio;

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name,
                'ONE_Presupuesto_App'),
            ONE_Tipo_De_Contrato__c = 'Particular',
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
            ONE_Importe_IVA_3__c =23,
            ONE_Importe_IVA_21__c = 883,
            ONE_Importe_IVA_10__c = 33,
            ONE_Expediente__c = servicio.Id);
        insert presupuesto;

        ONE_Orden_De_Venta__c ordenDeVenta = new ONE_Orden_De_Venta__c (
            ONE_Tipo_De_Pagador__c = 'Particular',
            ONE_Importe_Base_0__c = 23,
            ONE_Importe_Neto_21__c = 883,
            ONE_Importe_Neto_10__c = 33,
            ONE_Servicio__c = servicio.Id );
        insert ordenDeVenta;
        ONE_Orden_De_Venta__c ordenDeVenta2 = new ONE_Orden_De_Venta__c (
            ONE_Tipo_De_Pagador__c = 'Compañía',
            ONE_Importe_Base_0__c = 23,
            ONE_Importe_Neto_21__c = 883,
            ONE_Importe_Neto_10__c = 33,
            ONE_Servicio__c = servicio.Id,
            ONE_Fecha_Hora_Del_Abono_Factura__c = DateTime.now());
        insert ordenDeVenta2;
        
        ONE_Orden_De_Venta__c ordenDeVenta3 = new ONE_Orden_De_Venta__c (
            ONE_Tipo_De_Pagador__c = 'Particular',
            ONE_Pagador_Particular__c = intCIF.Id,
            ONE_Importe_Base_0__c = 23,
            ONE_Importe_Neto_21__c = 883,
            ONE_Importe_Neto_10__c = 33,
            ONE_Servicio__c = servicio.Id);
        insert ordenDeVenta3;

        ONE_Momento__c velacionMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT);
        ONE_Momento__c ceremonianMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_MOMENT);
        System.debug('ceremonianMomento-->' + ceremonianMomento);
        insert new List<ONE_Momento__c> {velacionMomento, ceremonianMomento};

        ONE_Agrupacion__c composicioneAgrupacion = new ONE_Agrupacion__c(Name = ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = velacionMomento.Id);
        ONE_Agrupacion__c ceremonialAgrupacion = new ONE_Agrupacion__c(Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = ceremonianMomento.Id);
        insert new List<ONE_Agrupacion__c>{composicioneAgrupacion, ceremonialAgrupacion};

        ONE_Categoria__c salasVelatoriolCategoria = new ONE_Categoria__c(ONE_Agrupacion__c= composicioneAgrupacion.Id,
            Name = (ONE_MomentoServiceConstants.VELACION_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0))
            ).get(0)
        );
        ONE_Categoria__c salasCeremonialCategoria = new ONE_Categoria__c(ONE_Agrupacion__c= ceremonialAgrupacion.Id,
            Name = (ONE_MomentoServiceConstants.CEREMONIA_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST.get(0)).
                get(0))
        );
        insert new List<ONE_Categoria__c>{salasCeremonialCategoria, salasVelatoriolCategoria};

        ONE_Producto__c velProducto = new ONE_Producto__c(Name = 'VelProd', ONE_Categoria__c = salasVelatoriolCategoria.Id);
        ONE_Producto__c ceremoniaProducto = new ONE_Producto__c(Name = 'CerProd', ONE_Categoria__c = salasCeremonialCategoria.Id,
            ONE_Codigo_Comercial__c = '1000005887');
        ONE_Producto__c velChildProducto = new ONE_Producto__c(Name = 'VelChildProd', ONE_Categoria__c = salasVelatoriolCategoria.Id,
            ONE_Codigo_Comercial__c = '1000005886');

        insert new List<ONE_Producto__c>{velProducto, ceremoniaProducto, velChildProducto};

        ONE_Expediente_Line_Item__c lineItem1 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 223 , ONE_Impuesto__c = 888, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Orden_De_Venta__c = ordenDeVenta.Id );
        ONE_Expediente_Line_Item__c lineItem2 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 444 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false, ONE_Orden_De_Venta__c = ordenDeVenta.Id);


        insert new List<ONE_Expediente_Line_Item__c>{lineItem1, lineItem2};

        ONE_Expediente_Line_Item__c lineItem3 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velChildProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 0 , ONE_Impuesto__c = 0, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Linea_De_Servicio_Padre__c = lineItem1.Id, ONE_Orden_De_Venta__c = ordenDeVenta.Id);
        ONE_Expediente_Line_Item__c lineItem4 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 55 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = true,
            ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId(), ONE_Orden_De_Venta__c = ordenDeVenta.Id);

        insert new List<ONE_Expediente_Line_Item__c>{lineItem3, lineItem4};
    }
	//Test Factura PDF generation
    @IsTest
    private static void createFacturaPdfFile() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];

        Test.startTest();
        ONE_FacturaComercialPdfService.FlowInput input = new ONE_FacturaComercialPdfService.FlowInput();
        input.ordenDeVentaId = ordenDeVenta.Id;
        input.language = 'es';
        List<ONE_FacturaComercialPdfService.FlowInput> inputs = new List<ONE_FacturaComercialPdfService.FlowInput>{input};
        ONE_FacturaComercialPdfService.createAndLinkPdf(inputs);

        Test.stopTest();


        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ordenDeVenta.Id]);

        System.assertEquals(1, contentDocumentLinks.size());
    }
	//Test Abono PDF generation
    @IsTest
    private static void createAbonoPdfFile() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];

        Test.startTest();
        ONE_AbonoComercialPdfService.FlowInput input = new ONE_AbonoComercialPdfService.FlowInput();
        input.ordenDeVentaId = ordenDeVenta.Id;
        input.language = 'es';
        List<ONE_AbonoComercialPdfService.FlowInput> inputs = new List<ONE_AbonoComercialPdfService.FlowInput>{input};
        ONE_AbonoComercialPdfService.createAndLinkPdf(inputs);

        Test.stopTest();


        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ordenDeVenta.Id]);

        System.assertEquals(1, contentDocumentLinks.size());
    }
	//Test Factura Simplificada PDF generation
    @IsTest
    private static void createFacturaSimpifadaPdfFile() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];

        Test.startTest();
        ONE_FacturaSimplComercialPdfService.FlowInput input = new ONE_FacturaSimplComercialPdfService.FlowInput();
        input.ordenDeVentaId = ordenDeVenta.Id;
        input.language = 'es';
        List<ONE_FacturaSimplComercialPdfService.FlowInput> inputs = new List<ONE_FacturaSimplComercialPdfService.FlowInput>{input};
        ONE_FacturaSimplComercialPdfService.createAndLinkPdf(inputs);

        Test.stopTest();


        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ordenDeVenta.Id]);

        System.assertEquals(1, contentDocumentLinks.size());
    }
	//Test Presupuesto Comercial PDF generation
    @IsTest
    private static void createPresupuestoComercialPdfParticular() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c WHERE ONE_Tipo_De_Pagador__c!='Compañía' LIMIT 1];
        PageReference pageRef = Page.ONE_FacturaComercialPdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVenta.Id);
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('isAbono', 'false');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_FacturaComercialPdfController controller = new ONE_FacturaComercialPdfController();
        Test.stopTest();

        System.assertEquals(1, controller.data.momentoListData.velacionList.size());
        System.assertEquals(1, controller.data.momentoListData.ceremoniaList.size());
        System.assertEquals(1, controller.data.descuentosList.size());
        System.assertEquals(1, controller.data.suplidosList.size());
        System.assertEquals(label.ONE_Doc_IVA, controller.data.taxLabel);

    }
    @IsTest
    private static void createPresupuestoComercialPdfCompania() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c WHERE ONE_Tipo_De_Pagador__c='Compañía'  LIMIT 1];
        PageReference pageRef = Page.ONE_FacturaComercialPdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVenta.Id);
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('isAbono', 'false');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_FacturaComercialPdfController controller = new ONE_FacturaComercialPdfController();
        Test.stopTest();



    }
    //Test Contrato Comercial PDF generation
    @IsTest
    private static void createContractoComercialPdf() {
         ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c WHERE ONE_Tipo_De_Pagador__c='Compañía' AND ONE_Servicio__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c != NULL LIMIT 1];
        PageReference pageRef = Page.ONE_AbonoComercialPdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVenta.Id);
        pageRef.getParameters().put('language', 'EU');
        pageRef.getParameters().put('isAbono', 'true');

        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_FacturaComercialPdfController controller = new ONE_FacturaComercialPdfController();
        Test.stopTest();
     

    }
    
        @IsTest
    	private static void createPresupuestoComercialPdfParticularEmpresa() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c WHERE ONE_Tipo_De_Pagador__c='Particular' AND ONE_Pagador_Empresa__c = true  LIMIT 1];
        PageReference pageRef = Page.ONE_FacturaComercialPdf;

        pageRef.getParameters().put('ordenDeVentaId', ordenDeVenta.Id);
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('isAbono', 'false');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_FacturaComercialPdfController controller = new ONE_FacturaComercialPdfController();
        Test.stopTest();



    }
}
/**
 * Created by Miguel Serrat on 23.05.2024. 
 */

@isTest
//Test class for the PDF Generation
public with sharing class ONE_PresupuestoM1PdfServiceTest {
    @TestSetup
	//Prepare all the required data to test the ONE_PresupuestoComercialPdfService class
    private static void testSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', ONE_Indicativo_Tel_fono__c = '+34 - España', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),ONE_Fecha_De_Defuncion2__c=Datetime.now(),
            ONE_Tipo_De_Impuesto__c = 'IVA');

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);

        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
            ONE_Tipo_De_Impuesto__c = 'IVA',
            ONE_Lugar__c = lugar.Id);

        insert new List<Account> {acc, accMemora};

        ONE_Expediente__c servicio = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_M1'),
            ONE_Difunto__c = acc.Id,
            ONE_Centro_Del_Expediente__c = accMemora.Id
        );
        insert servicio;

        ONE_Orden_De_Venta__c ov = new ONE_Orden_De_Venta__c(
            ONE_Servicio__c = servicio.Id
        );
     	insert ov;

        ONE_Momento__c velacionMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT);
        ONE_Momento__c ceremonianMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_MOMENT);
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

        ONE_Expediente_Line_Item__c lineItem1 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velProducto.Id, ONE_Orden_De_Venta__c = ov.Id,
        ONE_Importe_Neto__c = 223 , ONE_Impuesto__c = 888, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false);
        ONE_Expediente_Line_Item__c lineItem2 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Orden_De_Venta__c = ov.Id,
            ONE_Importe_Neto__c = 444 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false);


        insert new List<ONE_Expediente_Line_Item__c>{lineItem1, lineItem2};

        ONE_Expediente_Line_Item__c lineItem3 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velChildProducto.Id, ONE_Orden_De_Venta__c = ov.Id,
            ONE_Importe_Neto__c = 0 , ONE_Impuesto__c = 0, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Linea_De_Servicio_Padre__c = lineItem1.Id);
        ONE_Expediente_Line_Item__c lineItem4 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Orden_De_Venta__c = ov.Id,
            ONE_Importe_Neto__c = 55 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = true,
            ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId());

        insert new List<ONE_Expediente_Line_Item__c>{lineItem3, lineItem4};
    }
	
    // Test PDF creation
    @IsTest
    private static void createPrepuestoPdfFile() {
        ONE_Orden_De_Venta__c ov = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];

        Test.startTest();
        ONE_PresupuestoM1PdfService.FlowInput input = new ONE_PresupuestoM1PdfService.FlowInput();
        input.ordenDeVentaId = ov.Id;
        input.language = 'es';
        List<ONE_PresupuestoM1PdfService.FlowInput> inputs = new List<ONE_PresupuestoM1PdfService.FlowInput>{input};
        ONE_PresupuestoM1PdfService.createAndLinkPdf(inputs);
        
        Test.stopTest();


        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ov.Id]);

        System.assertEquals(1, contentDocumentLinks.size());
    }
    
    @IsTest
    private static void controladorPrepuestoPdf() {
        ONE_Orden_De_Venta__c ov = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];
        PageReference pageRef = Page.ONE_PresupuestoM1Pdf;

        pageRef.getParameters().put('ordenDeVentaId', ov.Id);
        pageRef.getParameters().put('language', 'ES');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_PresupuestoM1PdfController controller = new ONE_PresupuestoM1PdfController();
        Test.stopTest();

        System.assertEquals(1, controller.data.momentoListData.velacionList.size());
        System.assertEquals(1, controller.data.momentoListData.ceremoniaList.size());
        System.assertEquals(1, controller.data.descuentosList.size());
        System.assertEquals(1, controller.data.suplidosList.size());
        System.assertEquals(label.ONE_Doc_IVA, controller.data.taxLabel);

    }
    
}
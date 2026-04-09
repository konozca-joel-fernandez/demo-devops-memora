//Test class for the factura rectificativa PDF generation
@isTest
public with sharing class ONE_FacturaRectificativaPdfServiceTest {
    //Prepare required data for the test
    @TestSetup
    private static void testSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
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

        ONE_Interlocutor__c interlocutor = ONE_TestDataFactory.createInterlocutor(
                new ONE_Interlocutor__c(
                        ONE_Contacto__c = accMemora.Id
                ), true);

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
            ONE_Tipo_De_Pagador__c = 'Particular',
            ONE_Pagador_Particular__c = interlocutor.Id,
            ONE_Importe_Base_0__c = 23,
            ONE_Importe_Neto_21__c = 883,
            ONE_Importe_Neto_10__c = 33,
            ONE_Servicio__c = servicio.Id );
        insert ordenDeVenta2;

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

        ONE_Expediente_Line_Item__c lineItem5 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velChildProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 0 , ONE_Impuesto__c = 0, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Linea_De_Servicio_Padre__c = lineItem1.Id, ONE_Orden_De_Venta__c = ordenDeVenta2.Id);
        ONE_Expediente_Line_Item__c lineItem6 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 55 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = true,
            ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId(), ONE_Orden_De_Venta__c = ordenDeVenta2.Id);

        insert new List<ONE_Expediente_Line_Item__c>{lineItem5, lineItem6};

        ONE_Abono_Parcial__c abonoParcial1 = new ONE_Abono_Parcial__c(
            ONE_Orden_de_venta_AP__c = ordenDeVenta.Id,
            ONE_Fecha_De_Facturacion_Rectificativa__c = Date.today(),
            ONE_Presupuesto_AP__c = presupuesto.Id,
            ONE_Servicio_AP__c = servicio.Id);

        ONE_Abono_Parcial__c abonoParcial2 = new ONE_Abono_Parcial__c(
            ONE_Orden_de_venta_AP__c = ordenDeVenta2.Id,
            ONE_Fecha_De_Facturacion_Rectificativa__c = Date.today(),
            ONE_Presupuesto_AP__c = presupuesto.Id,
            ONE_Servicio_AP__c = servicio.Id);

        insert new List<ONE_Abono_Parcial__c>{abonoParcial1, abonoParcial2};
    }

    @IsTest
    private static void testPdfService() {
        ONE_Abono_Parcial__c abonoParcial = [SELECT Id FROM ONE_Abono_Parcial__c LIMIT 1];

        Test.startTest();
        ONE_FacturaRectificativaPdfService.FlowInput input = new ONE_FacturaRectificativaPdfService.FlowInput();
        input.abonoParcialId = abonoParcial.Id;
        input.documentType = 'factura_rectificativa';
        input.language = 'es';
        List<ONE_FacturaRectificativaPdfService.FlowInput> inputs = new List<ONE_FacturaRectificativaPdfService.FlowInput>{input};
        ONE_FacturaRectificativaPdfService.createAndLinkPdf(inputs);

        Test.stopTest();

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :abonoParcial.Id]);

        System.assertEquals(1, contentDocumentLinks.size());
    }

    @IsTest
    private static void testVisualforceController1() {
        ONE_Abono_Parcial__c abonoParcial = [SELECT Id FROM ONE_Abono_Parcial__c LIMIT 1];
        PageReference pageRef = Page.ONE_FacturaRectificativaPdf;

        pageRef.getParameters().put('abonoParcialId', abonoParcial.Id);
        pageRef.getParameters().put('documentType', 'factura_rectificativa');
        pageRef.getParameters().put('language', 'ES'); 
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_AbonoParcialPdfController controller = new ONE_AbonoParcialPdfController();
        Test.stopTest();
    }

    @IsTest
    private static void testVisualforceController2() {
        ONE_Abono_Parcial__c abonoParcial = [SELECT Id FROM ONE_Abono_Parcial__c WHERE ONE_Orden_de_venta_AP__r.ONE_Pagador_Empresa__c = true LIMIT 1];
        PageReference pageRef = Page.ONE_FacturaRectificativaPdf;

        pageRef.getParameters().put('abonoParcialId', abonoParcial.Id);
        pageRef.getParameters().put('documentType', 'factura_rectificativa');
        pageRef.getParameters().put('language', 'ES'); 
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_AbonoParcialPdfController controller = new ONE_AbonoParcialPdfController();
        Test.stopTest();
    }
}
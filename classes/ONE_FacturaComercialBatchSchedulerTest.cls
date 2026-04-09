/**
 * Created by msulek003 on 04.05.2021.
 */
@isTest
public with sharing class ONE_FacturaComercialBatchSchedulerTest {
    //Test setup for the batch that generate the factura document's
    @TestSetup
    private static void testSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
            PersonEmail = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
            ONE_Tipo_De_Impuesto__c = 'IVA');

        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_ID_Cliente_SAP__c ='223232');

        insert new List<Account> {acc, accMemora};

        ONE_Expediente__c servicio = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Defuncion'),
            ONE_Difunto__c = acc.Id,
            ONE_Centro_Del_Expediente__c = accMemora.Id
        );
        insert servicio;
        System.debug('Servicio:'+servicio);

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = servicio.Id);
        insert presupuesto;

        ONE_Orden_De_Venta__c ordenDeVenta = new ONE_Orden_De_Venta__c (
            ONE_Tipo_De_Pagador__c = 'Compañía',
            ONE_Importe_Base_0__c = 23,
            ONE_Importe_Neto_21__c = 883,
            ONE_Importe_Neto_10__c = 33,
            ONE_Numero_de_factura__c = 'test',
            ONE_Servicio__c = servicio.Id,
            ONE_Enviar_Factura_a_Cliente__c = true,
            ONE_Factura_Enviada_a_Cliente__c = false,
            ONE_Estado_De_La_Orden_de_Venta__c = 'Facturado',
            ONE_Pagador_Compania__c = accMemora.Id);
        insert ordenDeVenta;

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
            ONE_Codigo_Comercial__c = '1000005886');
        ONE_Producto__c velChildProducto = new ONE_Producto__c(Name = 'VelChildProd', ONE_Categoria__c = salasVelatoriolCategoria.Id,
            ONE_Codigo_Comercial__c = '1000005887');

        insert new List<ONE_Producto__c>{velProducto, ceremoniaProducto, velChildProducto};

        ONE_Expediente_Line_Item__c lineItem1 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velProducto.Id,
            ONE_Importe_Neto__c = 223 , ONE_Impuesto__c = 888, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Orden_De_Venta__c = ordenDeVenta.Id, ONE_Presupuesto__c = presupuesto.Id);
        ONE_Expediente_Line_Item__c lineItem2 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id,
            ONE_Importe_Neto__c = 444 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Orden_De_Venta__c = ordenDeVenta.Id, ONE_Presupuesto__c = presupuesto.Id);
		System.debug('lineItem1:'+lineItem1);
        System.debug('lineItem2:'+lineItem2);

        insert new List<ONE_Expediente_Line_Item__c>{lineItem1, lineItem2};

        ONE_Expediente_Line_Item__c lineItem3 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velChildProducto.Id,
            ONE_Importe_Neto__c = 0 , ONE_Impuesto__c = 0, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Linea_De_Servicio_Padre__c = lineItem1.Id, ONE_Orden_De_Venta__c = ordenDeVenta.Id, ONE_Presupuesto__c = presupuesto.Id);
        ONE_Expediente_Line_Item__c lineItem4 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id,
            ONE_Importe_Neto__c = 55 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = true,
            ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId(), ONE_Orden_De_Venta__c = ordenDeVenta.Id, ONE_Presupuesto__c = presupuesto.Id);

        insert new List<ONE_Expediente_Line_Item__c>{lineItem3, lineItem4};
    }
	//Excecute batch process that generate the fully informed factura
    @IsTest
    private static void runFacturaBatchPdf() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];
        ordenDeVenta.ONE_Tipo_De_Factura__c = '01';
        update ordenDeVenta;

        Test.startTest();
            Database.executeBatch(new ONE_FacturaComercialBatch(), 50);
        Test.stopTest();

        ordenDeVenta = [SELECT Id, ONE_Factura_Enviada_a_Cliente__c, ONE_Resultado_Batch__c FROM ONE_Orden_De_Venta__c LIMIT 1];
        System.assertEquals(true, ordenDeVenta.ONE_Factura_Enviada_a_Cliente__c);

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ordenDeVenta.Id]);
        System.assertEquals(1, contentDocumentLinks.size());
    }
	//Excecute batch process that generate the fully informed simplified factura
    @IsTest
    private static void runFacturaSimplBatchPdf() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];
        ordenDeVenta.ONE_Tipo_De_Factura__c = '02';
        update ordenDeVenta;

        Test.startTest();
        Database.executeBatch(new ONE_FacturaComercialBatch(), 50);
        Test.stopTest();

        ordenDeVenta = [SELECT Id, ONE_Factura_Enviada_a_Cliente__c, ONE_Resultado_Batch__c FROM ONE_Orden_De_Venta__c LIMIT 1];
        System.assertEquals(true, ordenDeVenta.ONE_Factura_Enviada_a_Cliente__c);

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ordenDeVenta.Id]);
        System.assertEquals(1, contentDocumentLinks.size());
    }
	//Test the email send of the factura once is generated
    @IsTest
    private static void runFacturaNoEmailBatchPdf() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];
        ordenDeVenta.ONE_Tipo_De_Factura__c = '01';
        ordenDeVenta.ONE_Pagador_Compania__c = null;
        update ordenDeVenta;

        Test.startTest();
        Database.executeBatch(new ONE_FacturaComercialBatch(), 50);
        Test.stopTest();

        ordenDeVenta = [SELECT Id, ONE_Factura_Enviada_a_Cliente__c, ONE_Resultado_Batch__c FROM ONE_Orden_De_Venta__c LIMIT 1];

        System.assertEquals(label.ONE_Doc_No_Email_Message , ordenDeVenta.ONE_Resultado_Batch__c);
    }
    //Test the email send of the factura simplified once is generated
    @IsTest
    private static void runFacturaSimplNoEmailBatchPdf() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1];
        ordenDeVenta.ONE_Tipo_De_Factura__c = '02';
        ordenDeVenta.ONE_Pagador_Compania__c = null;
        update ordenDeVenta;

        Test.startTest();
        Database.executeBatch(new ONE_FacturaComercialBatch(), 50);
        Test.stopTest();

        ordenDeVenta = [SELECT Id, ONE_Factura_Enviada_a_Cliente__c, ONE_Resultado_Batch__c FROM ONE_Orden_De_Venta__c LIMIT 1];

        System.assertEquals(label.ONE_Doc_No_Email_Message , ordenDeVenta.ONE_Resultado_Batch__c);
    }
	//Generate the factura in case the payer its a particular one instead of a company
    @IsTest
    private static void runFacturaBatchWithPagadorParticular() {
        ONE_Orden_De_Venta__c ordenDeVenta = [SELECT Id, ONE_Pagador_Compania__c, ONE_Tipo_De_Factura__c FROM ONE_Orden_De_Venta__c LIMIT 1];
        Account personAccount = [SELECT Id FROM Account WHERE LastName = 'Smith' LIMIT 1];
        ordenDeVenta.ONE_Tipo_De_Factura__c = '01';
        ordenDeVenta.ONE_Pagador_Compania__c = null;
        ONE_Interlocutor__c interlocutor = new ONE_Interlocutor__c(ONE_Contacto__c = personAccount.Id);
        insert interlocutor;
        ordenDeVenta.ONE_Pagador_Particular__c = interlocutor.Id;
        update ordenDeVenta;

        Test.startTest();
        ONE_FacturaComercialBatchScheduler m = new ONE_FacturaComercialBatchScheduler();
        String sch = '20 20 16 * * ?';
        String jobID = system.schedule('Send email', sch, m);
        m.execute(null);
        Test.stopTest();

        ordenDeVenta = [SELECT Id, ONE_Factura_Enviada_a_Cliente__c, ONE_Resultado_Batch__c FROM ONE_Orden_De_Venta__c LIMIT 1];
        System.assertEquals(true, ordenDeVenta.ONE_Factura_Enviada_a_Cliente__c);

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ordenDeVenta.Id]);
        System.assertEquals(1, contentDocumentLinks.size());
    }

}
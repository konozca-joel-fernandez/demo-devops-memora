/**
 * Created by mbujak003 on 27.07.2021.
 */
@IsTest
public with sharing class ONE_BCControllerTest {

    @TestSetup
    public static void dataSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_External_ID__c = '05TEST');

        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_External_ID__c = '05TEST');
        
        Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS ), ONE_External_ID__c = '04TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA');
        
        insert parentAccount;
        
        Account otras = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='54543321', ONE_Email__c = 'memoraa23455@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS ), ONE_External_ID__c = '05TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA', ParentId = parentAccount.id);

        Account pagadorCompania = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_02',
                Name = 'Cemetery', Phone='54543321', ONE_Email__c = 'memoraa23455@example.com',
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                        ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Tipo_De_Impuesto__c = 'IVA', ONE_ID_Cliente_SAP__c = ONE_TestDataFactory.getRandomName(),
                ONE_Compania_Billing_Companies__c = true, ONE_External_ID__c = '05TEST');

        insert new List<Account> {acc, accMemora, otras, pagadorCompania};


        ONE_Expediente__c servicio = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Defuncion'),
            ONE_Difunto__c = acc.Id,
            ONE_Centro_Del_Expediente__c = accMemora.Id,
            ONE_Compania__c = otras.Id
        );
        insert servicio;
        insertRelatedDocument(servicio.Id);

        ONE_Interlocutor__c interlocutor = ONE_TestDataFactory.createInterlocutor(
            new ONE_Interlocutor__c(
                ONE_Expediente__c = servicio.Id,
                ONE_Contacto__c = acc.Id
            ), true);

        ONE_Orden_De_Venta__c ordenDeVenta = ONE_TestDataFactory.createOrdenDeVenta(
            new ONE_Orden_De_Venta__c(
                ONE_Pagador_Compania__c = pagadorCompania.Id,
                ONE_Pagador_Particular__c = interlocutor.Id,
                ONE_Servicio__c = servicio.Id,
                ONE_Fecha_De_Facturacion__c = Date.today(),
                ONE_Numero_de_factura__c = 'FV25/02/21',
                ONE_Forma_De_Pago__c = 'A',
                ONE_Moneda__c = 'EUR',
                ONE_IBAN__c = 'ES3621082850270010500972',
                ONE_Titular_De_La_Cuenta_Bancaria__c = 'José Carreño Iborra',
                ONE_El_Pagador_Es_El_Difunto__c = false
            ), true);
        insertRelatedDocument(ordenDeVenta.Id);
        
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

        ONE_Expediente_Line_Item__c lineItem1 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 223 , ONE_Impuesto__c = 888, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false, ONE_Orden_De_Venta__c = ordenDeVenta.Id);
        ONE_Expediente_Line_Item__c lineItem2 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id, ONE_Orden_De_Venta__c = ordenDeVenta.Id,
            ONE_Importe_Neto__c = 444 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false);


        insert new List<ONE_Expediente_Line_Item__c>{lineItem1, lineItem2};

        ONE_Expediente_Line_Item__c lineItem3 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velChildProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 0 , ONE_Impuesto__c = 0, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
            ONE_Linea_De_Servicio_Padre__c = lineItem1.Id);
        ONE_Expediente_Line_Item__c lineItem4 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
            ONE_Importe_Neto__c = 55 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = true,
            ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId());

        insert new List<ONE_Expediente_Line_Item__c>{lineItem3, lineItem4};
    }

    @IsTest
    public static void fetchRecordsTest() {
        Map<String, Object> filters = new Map<String, Object> {
            'insuranceCompanyVal' => [SELECT Id FROM Account WHERE Name = 'Cemetery' LIMIT 1].Id,
            'estadoFacturaVal' => null,
            'sociedadGrupoMemoraVal'=> null,
            'codigoCompaniaVal'=> null,
            'fechaFacturaDesdeVal'=> String.valueOf(Date.today().addDays(-1)),
            'fechafacturaHastaVal'=> String.valueOf(Date.today().addDays(1)),
            'numeroSiniestroVal'=> null,
            'numeroPolizaVal'=> null
        };
        Test.startTest();
        ONE_BCController.fetchRecords(filters);
        Test.stopTest();
    }

    @IsTest
    public static void fetchDocumentsTest() {
        List<String> ordenIds = new List<String> { [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id };
        Test.startTest();
        ONE_BCController.fetchDocuments(JSON.serialize(ordenIds));
        Test.stopTest();
    }

    @IsTest
    public static void sendEmailTest() {
        Test.startTest();
        String ordenId = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id ;
        Map<String, Object> att = new Map<String, Object> {
            'fileName' => 'someFilename',
            'data' => 'dGVzdA=='
        };
        ONE_BCController.sendEmail('someTitle', 'someBody', new List<Object>{ att }, ordenId);
        Test.stopTest();
    }

    @IsTest
    public static void fetchInsuranceCompaniesTest() {
        Test.startTest();
        ONE_BCController.fetchInsuranceCompanies();
        Test.stopTest();
    }
    
    @IsTest
    public static void updateEstadoTest(){
        ONE_Orden_De_Venta__c enviadoOrdenDeVenta =
                ONE_TestDataFactory.createOrdenDeVenta(
                        new ONE_Orden_De_Venta__c(ONE_Estado_envio_Documentacion_Asegur__c = ONE_CommonConstants.ESTADO_ENVIADO), true
                );
        
        ONE_BCController.updateEstado(enviadoOrdenDeVenta.Id);
        
        ONE_Orden_De_Venta__c updatedOrdenDeVenta = [SELECT Id, ONE_Estado_envio_Documentacion_Asegur__c, ONE_Fecha_envio_documentacion_asegurad__c FROM ONE_Orden_De_Venta__c WHERE Id = :enviadoOrdenDeVenta.Id];
        System.assertEquals(ONE_CommonConstants.ESTADO_REENVIADO, updatedOrdenDeVenta.ONE_Estado_envio_Documentacion_Asegur__c);
        System.assertEquals(Datetime.now().date(), updatedOrdenDeVenta.ONE_Fecha_envio_documentacion_asegurad__c.date());
    }

    static void insertRelatedDocument(Id parentId) {
        Id contentVersionId = Database.insert(new ContentVersion(
                Title = ONE_TestDataFactory.getRandomName(),
                VersionData = EncodingUtil.base64Decode(ONE_TestDataFactory.getRandomName()),
                PathOnClient = 'Path',
                ContentLocation = 'S',
                TagCsv = ONE_CommonConstants.DOCUMENT_TAG_FACTURA_COMERCIAL
        )).getId();
        insert new ContentDocumentLink(
                ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId].ContentDocumentId,
                LinkedEntityId = parentId
        );
    }
}
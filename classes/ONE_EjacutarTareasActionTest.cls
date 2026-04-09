/**
 * Created by motykak on 15.09.2021. 
 */
//Test class for the automatic task creation and assignation to the corresponding person or provider
@IsTest
public with sharing class ONE_EjacutarTareasActionTest {
	//Test task creation
    @IsTest
    public static void invokeTest() {
        List<ONE_EjacutarTareasAction.FlowInputs> flowInputs = new List<ONE_EjacutarTareasAction.FlowInputs>();

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null, true);

        Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
            ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS ), ONE_External_ID__c = '04TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Tipo__c = 'Tanatorio');
        
        insert parentAccount;
        
        Account compania = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = ONE_TestDataFactory.createLugar(null, true).Id,
                ONE_External_ID__c = '05TEST',
                ParentId = parentAccount.id
            ),
            true);

        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );

        Account proveedor = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                ONE_Lugar__c = lugar.Id,
                ONE_Metodo_De_Contacto_De_Proveedor__c = 'Aplicacion',
                ONE_Proveedor__c=true,
                ONE_Tipo__c = 'Proveedores'
            ), true
        );


        ONE_Proveedor_De_Producto__c proveedorDeProducto = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto;
        
        ONE_Proveedor_De_Producto__c proveedorDeProducto2 = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto2;

        ONE_Configuracion_De_Tarea__c configuracionDeTarea = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id
        );
        insert configuracionDeTarea;
        
        ONE_Configuracion_De_Tarea__c configuracionDeTarea2 = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR
        );
        insert configuracionDeTarea2;

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id,
                ONE_Compania__c = compania.Id
        ), true);

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id);
        insert presupuesto;

        ONE_Expediente_Line_Item__c eli = new ONE_Expediente_Line_Item__c(
                ONE_Expediente__c = expediente.Id,
                ONE_Producto__c = producto.Id,
                ONE_Presupuesto__c = presupuesto.Id
        );

        insert eli;
        
        ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
        fi.expedienteLineItemId = eli.Id;
        flowInputs.add(fi);


        Test.startTest();
        List<ONE_EjacutarTareasAction.FlowOutputs> flowOutputsUnderTest = ONE_EjacutarTareasAction.invoke(flowInputs);
        Test.stopTest();

        System.assert(flowOutputsUnderTest.size() > 0);

        for (ONE_EjacutarTareasAction.FlowOutputs fo : flowOutputsUnderTest) {
            System.assert(fo.status, true);
            System.assert(!fo.tareaIds.isEmpty(), 'La lista de tareaIds no debería estar vacía');

        }
    }
    
    @IsTest
    public static void invokeTest2() {
        List<ONE_EjacutarTareasAction.FlowInputs> flowInputs = new List<ONE_EjacutarTareasAction.FlowInputs>();

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null, true);

        Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
            ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS ), ONE_External_ID__c = '04TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Tipo__c = 'Tanatorio');
        
        insert parentAccount;
        
        Account compania = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = ONE_TestDataFactory.createLugar(null, true).Id,
                ONE_External_ID__c = '05TEST',
                ParentId = parentAccount.id
            ),
            true);

        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );

        Account proveedor = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                ONE_Lugar__c = lugar.Id,
                ONE_Metodo_De_Contacto_De_Proveedor__c = 'Aplicacion',
                ONE_Proveedor__c=true,
                ONE_Tipo__c = 'Proveedores'
            ), true
        );


        ONE_Proveedor_De_Producto__c proveedorDeProducto = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Compania__c = compania.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto;
        
        ONE_Proveedor_De_Producto__c proveedorDeProducto2 = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Compania__c = compania.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto2;

        ONE_Configuracion_De_Tarea__c configuracionDeTarea = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id
        );
        insert configuracionDeTarea;
        
        ONE_Configuracion_De_Tarea__c configuracionDeTarea2 = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR
        );
        insert configuracionDeTarea2;

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id,
                ONE_Compania__c = compania.Id
        ), true);
        
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_SERVICIO,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id);
        insert presupuesto;

        ONE_Expediente_Line_Item__c eli = new ONE_Expediente_Line_Item__c(
                ONE_Expediente__c = expediente.Id,
                ONE_Producto__c = producto.Id,
                ONE_Presupuesto__c = presupuesto.Id
        );
        insert eli;
        
        ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
        fi.expedienteLineItemId = eli.Id;
        flowInputs.add(fi);


        Test.startTest();
        List<ONE_EjacutarTareasAction.FlowOutputs> flowOutputsUnderTest = ONE_EjacutarTareasAction.invoke(flowInputs);
        Test.stopTest();

        System.assert(flowOutputsUnderTest.size() > 0);

        for (ONE_EjacutarTareasAction.FlowOutputs fo : flowOutputsUnderTest) {
            System.assert(fo.status, true);
            System.assert(!fo.tareaIds.isEmpty(), 'La lista de tareaIds no debería estar vacía');

        }
    }
    
    @IsTest
    public static void invokeTest3() {
        List<ONE_EjacutarTareasAction.FlowInputs> flowInputs = new List<ONE_EjacutarTareasAction.FlowInputs>();

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null, true);

        Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
            ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS ), ONE_External_ID__c = '04TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Tipo__c = 'Tanatorio');
        
        insert parentAccount;
        
        Account compania = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = ONE_TestDataFactory.createLugar(null, true).Id,
                ONE_External_ID__c = '05TEST',
                ParentId = parentAccount.id
            ),
            true);

        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );

        Account proveedor = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                ONE_Lugar__c = lugar.Id,
                ONE_Metodo_De_Contacto_De_Proveedor__c = 'Aplicacion',
                ONE_Proveedor__c=true,
                ONE_Tipo__c = 'Proveedores'
            ), true
        );


        ONE_Proveedor_De_Producto__c proveedorDeProducto = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto;
        
        ONE_Proveedor_De_Producto__c proveedorDeProducto2 = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto2;

        ONE_Configuracion_De_Tarea__c configuracionDeTarea = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id
        );
        insert configuracionDeTarea;
        
        ONE_Configuracion_De_Tarea__c configuracionDeTarea2 = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR
        );
        insert configuracionDeTarea2;

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id,
                ONE_Compania__c = compania.Id
        ), true);
        
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_SERVICIO,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id);
        insert presupuesto;

        ONE_Expediente_Line_Item__c eli = new ONE_Expediente_Line_Item__c(
                ONE_Expediente__c = expediente.Id,
                ONE_Producto__c = producto.Id,
                ONE_Presupuesto__c = presupuesto.Id
        );
        insert eli;
        
        ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
        fi.expedienteLineItemId = eli.Id;
        flowInputs.add(fi);


        Test.startTest();
        List<ONE_EjacutarTareasAction.FlowOutputs> flowOutputsUnderTest = ONE_EjacutarTareasAction.invoke(flowInputs);
        Test.stopTest();

        System.assert(flowOutputsUnderTest.size() > 0);

        for (ONE_EjacutarTareasAction.FlowOutputs fo : flowOutputsUnderTest) {
            System.assert(fo.status, true);
            System.assert(!fo.tareaIds.isEmpty(), 'La lista de tareaIds no debería estar vacía');

        }
    }
   
    @IsTest
    public static void invokeTest4() {
        List<ONE_EjacutarTareasAction.FlowInputs> flowInputs = new List<ONE_EjacutarTareasAction.FlowInputs>();

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null, true);

        Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
            ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS), ONE_External_ID__c = '04TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Tipo__c = 'Tanatorio');
        
        insert parentAccount;
        
        Account compania = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = ONE_TestDataFactory.createLugar(null, true).Id,
                ONE_External_ID__c = '05TEST',
                ParentId = parentAccount.id
            ),
            true);

        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );

        Account proveedor = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                ONE_Lugar__c = lugar.Id,
                ONE_Proveedor__c=true,
                ONE_Tipo__c = 'Proveedores'
            ), true
        );


        ONE_Proveedor_De_Producto__c proveedorDeProducto = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Compania__c = compania.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto;
        
        ONE_Configuracion_De_Tarea__c configuracionDeTarea = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id
        );
        insert configuracionDeTarea;
        
        ONE_Configuracion_De_Tarea__c configuracionDeTarea2 = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR
        );
        insert configuracionDeTarea2;

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id,
                ONE_Compania__c = compania.Id
        ), true);

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_SERVICIO,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id);
        insert presupuesto;

        ONE_Expediente_Line_Item__c eli = new ONE_Expediente_Line_Item__c(
                ONE_Expediente__c = expediente.Id,
                ONE_Producto__c = producto.Id,
                ONE_Presupuesto__c = presupuesto.Id, 
            	ONE_Cantidad__c=1
        );

        insert eli;
        
        ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
        fi.expedienteLineItemId = eli.Id;
        flowInputs.add(fi);


        Test.startTest();
        List<ONE_EjacutarTareasAction.FlowOutputs> flowOutputsUnderTest = ONE_EjacutarTareasAction.invoke(flowInputs);
        Test.stopTest();

        System.assert(flowOutputsUnderTest.size() > 0);

     }
     
   @IsTest
    public static void invokeTest5() {
        List<ONE_EjacutarTareasAction.FlowInputs> flowInputs = new List<ONE_EjacutarTareasAction.FlowInputs>();

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null, true);

        Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
            ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS), ONE_External_ID__c = '04TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Tipo__c = 'Tanatorio');
        
        insert parentAccount;
        
        Account compania = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = ONE_TestDataFactory.createLugar(null, true).Id,
                ONE_External_ID__c = '05TEST',
                ParentId = parentAccount.id
            ),
            true);

        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );

        Account proveedor = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                ONE_Lugar__c = lugar.Id,
                ONE_Proveedor__c=true,
                ONE_Tipo__c = 'Proveedores'
            ), true
        );


        ONE_Proveedor_De_Producto__c proveedorDeProducto = new ONE_Proveedor_De_Producto__c(
            ONE_Producto__c = producto.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
        );

        insert proveedorDeProducto;
        
        ONE_Configuracion_De_Tarea__c configuracionDeTarea = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id
        );
        insert configuracionDeTarea;
        
        ONE_Configuracion_De_Tarea__c configuracionDeTarea2 = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = false,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR
        );
        insert configuracionDeTarea2;

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id
        ), true);

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id);
        insert presupuesto;

        ONE_Expediente_Line_Item__c eli = new ONE_Expediente_Line_Item__c(
                ONE_Expediente__c = expediente.Id,
                ONE_Producto__c = producto.Id,
                ONE_Presupuesto__c = presupuesto.Id
        );

        insert eli;
        
        ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
        fi.expedienteLineItemId = eli.Id;
        flowInputs.add(fi);


        Test.startTest();
        List<ONE_EjacutarTareasAction.FlowOutputs> flowOutputsUnderTest = ONE_EjacutarTareasAction.invoke(flowInputs);
        Test.stopTest();

        System.assert(flowOutputsUnderTest.size() > 0);

     }

     @IsTest
     public static void invokeTest6() {
         List<ONE_EjacutarTareasAction.FlowInputs> flowInputs = new List<ONE_EjacutarTareasAction.FlowInputs>();
 
         ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
         ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
         ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
         ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null, true);
 
         Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
             Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
             RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
             ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS ), ONE_External_ID__c = '04TEST',
             ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Tipo__c = 'Tanatorio');
         
         insert parentAccount;
         
         Account compania = ONE_TestDataFactory.createAccount(
             new Account(
                 RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                     ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                 ONE_Lugar__c = ONE_TestDataFactory.createLugar(null, true).Id,
                 ONE_External_ID__c = '05TEST',
                 ParentId = parentAccount.id
             ),
             true);
 
         Account centro = ONE_TestDataFactory.createAccount(
             new Account(
                 RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                     ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                 ONE_Lugar__c = lugar.Id,
                 ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
             ), true
         );
 
         Account proveedor = ONE_TestDataFactory.createAccount(
             new Account(
                 RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                     ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                 ONE_Lugar__c = lugar.Id,
                 ONE_Proveedor__c=true,
                 ONE_Tipo__c = 'Proveedores'
             ), true
         );
 
 
         ONE_Proveedor_De_Producto__c proveedorDeProducto = new ONE_Proveedor_De_Producto__c(
             ONE_Producto__c = producto.Id,
             ONE_Compania__c = null,
             ONE_Proveedor__c = proveedor.Id,
             ONE_Validez_Desde__c = Date.today() - 1,
             ONE_Validez_Hasta__c = Date.today() + 1,
             ONE_Lugar__c = lugar.Id,
             ONE_Centro__c = centro.Id,
             ONE_Precio_De_Compra__c = 2
         );
 
         insert proveedorDeProducto;
         
         ONE_Configuracion_De_Tarea__c configuracionDeTarea = new ONE_Configuracion_De_Tarea__c(
             OwnerId = UserInfo.getUserId(),
             ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
             //  ONE_Tipologia_De_Producto_Lookup__c=,
             ONE_Requiere_Planificacion__c = false,
             ONE_Producto__c = producto.Id,
             ONE_Lugar__c = lugar.Id,
             ONE_Centro__c = centro.Id
         );
         insert configuracionDeTarea;
         
         ONE_Configuracion_De_Tarea__c configuracionDeTarea2 = new ONE_Configuracion_De_Tarea__c(
             OwnerId = UserInfo.getUserId(),
             ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
             //  ONE_Tipologia_De_Producto_Lookup__c=,
             ONE_Requiere_Planificacion__c = false,
             ONE_Producto__c = producto.Id,
             ONE_Lugar__c = lugar.Id,
             ONE_Centro__c = centro.Id,
             ONE_Tipo_De_Recurso__c = ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR
         );
         insert configuracionDeTarea2;
 
         ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                 ONE_Centro_Del_Expediente__c = centro.Id,
                 ONE_Compania__c = compania.Id
         ), true);
 
         ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                 RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                 ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_SERVICIO,
                 ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                 ONE_Importe_IVA_3__c = 23,
                 ONE_Importe_IVA_21__c = 883,
                 ONE_Importe_IVA_10__c = 33,
                 ONE_Expediente__c = expediente.Id);
         insert presupuesto;
 
         ONE_Expediente_Line_Item__c eli = new ONE_Expediente_Line_Item__c(
                 ONE_Expediente__c = expediente.Id,
                 ONE_Producto__c = producto.Id,
                 ONE_Presupuesto__c = presupuesto.Id, 
                 ONE_Cantidad__c=1
         );
 
         insert eli;
         
         ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
         fi.expedienteLineItemId = eli.Id;
         flowInputs.add(fi);
 
 
         Test.startTest();
         List<ONE_EjacutarTareasAction.FlowOutputs> flowOutputsUnderTest = ONE_EjacutarTareasAction.invoke(flowInputs);
         Test.stopTest();
 
         System.assert(flowOutputsUnderTest.size() > 0);
 
      }
          
	//Test negative test
    @IsTest
    public static void invokeNegativeTest() {
        List<ONE_EjacutarTareasAction.FlowInputs> flowInputs = new List<ONE_EjacutarTareasAction.FlowInputs>();

		ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);

        ONE_Producto__c producto = ONE_TestDataFactory.createProducto(null, true);
        
        Account parentAccount = new Account(ONE_Forma_de_envio_de_los_documentos__c = 'Formato_03',
            Name = 'Insurance', Phone='5454333451', ONE_Email__c = 'memoraa2345556@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS ), ONE_External_ID__c = '04TEST',
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Tipo__c = 'Tanatorio');
        
        insert parentAccount;

        Account compania = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = ONE_TestDataFactory.createLugar(null, true).Id,
                ONE_External_ID__c = '05TEST',
                ParentId = parentAccount.id
            ),
            true);

        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id
            ), true
        );

        Account proveedor = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                ONE_Lugar__c = lugar.Id,
                ONE_Metodo_De_Contacto_De_Proveedor__c = 'Aplicacion',
                ONE_Proveedor__c=true,
                ONE_Tipo__c = 'Proveedores'
            ), true
        );


        ONE_Proveedor_De_Producto__c proveedorDeProducto = new ONE_Proveedor_De_Producto__c(
            ONE_Compania__c = compania.Id,
            ONE_Proveedor__c = proveedor.Id,
            ONE_Validez_Desde__c = Date.today() - 1,
            ONE_Validez_Hasta__c = Date.today() + 1,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id,
            ONE_Precio_De_Compra__c = 2
            
        );

        insert proveedorDeProducto;

        ONE_Configuracion_De_Tarea__c configuracionDeTarea = new ONE_Configuracion_De_Tarea__c(
            OwnerId = UserInfo.getUserId(),
            ONE_Tipo_De_Tarea__c = 'ONE_Tarea_De_Flores',
            //  ONE_Tipologia_De_Producto_Lookup__c=,
            ONE_Requiere_Planificacion__c = true,
            ONE_Producto__c = producto.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Centro__c = centro.Id
        );
        insert configuracionDeTarea;

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id,
                ONE_Compania__c = compania.Id
        ), true);

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id);
        insert presupuesto;

        ONE_Expediente_Line_Item__c eli = new ONE_Expediente_Line_Item__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Producto__c = producto.Id,
            ONE_Presupuesto__c = presupuesto.Id
        );

        insert eli;
        ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
        fi.expedienteLineItemId = eli.Id;
        flowInputs.add(fi);


        Test.startTest();
        List<ONE_EjacutarTareasAction.FlowOutputs> flowOutputsUnderTest = ONE_EjacutarTareasAction.invoke(flowInputs);
        Test.stopTest();

        System.assert(flowOutputsUnderTest.size() > 0);

        for (ONE_EjacutarTareasAction.FlowOutputs fo : flowOutputsUnderTest) {
            System.debug(fo.status);
            System.assert(!fo.status);


        }
    }
}
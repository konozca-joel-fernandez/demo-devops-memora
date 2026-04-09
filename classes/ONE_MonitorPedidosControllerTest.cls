@IsTest
public with sharing class ONE_MonitorPedidosControllerTest {
    
    public static final List<String> sorting = new List<String>{'tareaURL', 'pedidoURL', 'proveedorURL', 'servicioURL', 'nombreDifunto', 'fechaDefuncion', 'lugarURL', 'codigoRetornoSAP', 'fechaCodigoRetornoSAP', 'productoURL', 'fechaPedido', 'fechaContabilizacion', 'estadoOV', 'estadoTarea', 'fechaFacturacionOV', 'fechaAbonoOV'};
    
    @TestSetup
    private static void dataSetup() {

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);

        Account acc1 = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id),true);
        ONE_Pedido_De_Proveedor__c pedido = ONE_TestDataFactory.createPedidoDeProveedor(
            new ONE_Pedido_De_Proveedor__c(ONE_Fecha__c = Date.today()), true
        );

        ONE_Expediente__c expedient = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = acc1.Id
        ), true);

        ONE_TestDataFactory.createTarea(new ONE_Tarea__c(
            ONE_Expediente__c = expedient.Id,
            ONE_Pedido_De_Proveedor__c = pedido.Id
        ), true);
       
    }

    @IsTest
    private static void getLineasTest1() {
        List<String> accounts = new List<String>();
        List<String> servicios = new List<String>();
        List<String> lugares = new List<String>();
        List<String> productos = new List<String>();
        List<String> estadosTarea = new List<String>();
        Test.startTest();
        String lineas = ONE_MonitorPedidosController.getLineas('Mes actual', 'Otros', '', estadosTarea, '', accounts, servicios,'',lugares,'',1,1,null,null,'Mes actual',null,null, 'sliURL','');
        //System.assertEquals(1, lineas.size());
    }
    
    @IsTest
    private static void getLineasTest2() {
        List<String> accounts = new List<String>();
        List<String> servicios = new List<String>();
        List<String> lugares = new List<String>();
        List<String> productos = new List<String>();
        List<String> estadosTarea = new List<String>();
        Test.startTest();
        String lineas = ONE_MonitorPedidosController.getLineas('Mes anterior', 'E8', 'Facturado', estadosTarea,  '', accounts, servicios,'',lugares,'',1,1,null,null,'Mes anterior',null,null, '','');
        Test.stopTest();

        //System.assertEquals(1, lineas.size());
    }
    
    @IsTest
    private static void getLineasTestSort() {
        List<String> accounts = new List<String>();
        List<String> servicios = new List<String>();
        List<String> lugares = new List<String>();    
        List<String> productos = new List<String>();
        List<String> estadosTarea = new List<String>();
        Test.startTest();
        for(String sortField : sorting){
            String lineas = ONE_MonitorPedidosController.getLineas('Mes anterior', 'Otros', '', estadosTarea,  '', accounts, servicios,'',lugares,'',1,1,null,null,'Mes anterior',null,null, sortField,'');
        }
        Test.stopTest();

        //System.assertEquals(1, lineas.size());
    }
    
    @IsTest
    private static void getAllLineas() {
        String soql = 'SELECT Id from ONE_Tarea__c';
        Test.startTest();
        List<ONE_Tarea__c> lineas = ONE_MonitorPedidosController.getAllLineas(soql);
        Test.stopTest();

        //System.assertEquals(1, lineas.size());
    }

    @IsTest
    private static void updateLineasTest() {

        Id tareaId = [SELECT Id FROM ONE_Tarea__c LIMIT 1].Id;

        Test.startTest();
        ONE_MonitorPedidosController.updateLineas('[ { "id": "'+tareaId+'", "fechaPedido": "2023-05-03", "precioCompra": 99.9 } ]');
        Test.stopTest();
    }

    @IsTest
    private static void proveedorSearchTest() {

        List<String> selectedIds = new List<String>();

        Test.startTest();
        List<LookupSearchResult> results = ONE_MonitorPedidosController.proveedorSearch('', selectedIds);
        Test.stopTest();
    }

    @IsTest
    private static void centroSearchTest() {

        List<String> selectedIds = new List<String>();

        Test.startTest();
        List<LookupSearchResult> results = ONE_MonitorPedidosController.centroSearch('', selectedIds);
        Test.stopTest();
    }

    @IsTest
    private static void servicioSearchTest() {

        List<String> selectedIds = new List<String>();

        Test.startTest();
        List<LookupSearchResult> results = ONE_MonitorPedidosController.servicioSearch('', selectedIds);
        Test.stopTest();
    }

    @IsTest
    private static void productoTypesTest() {

        List<String> selectedIds = new List<String>();

        Test.startTest();
        List<String> typeProds = ONE_MonitorPedidosController.getTypeProducts();
        //List<LookupSearchResult> results = ONE_MonitorPedidosController.productoSearch('', selectedIds);
        Test.stopTest();
    }

    @IsTest
    private static void lugarSearchTest() {

        List<String> selectedIds = new List<String>();

        Test.startTest();
        List<LookupSearchResult> results = ONE_MonitorPedidosController.lugarSearch('', selectedIds);
        Test.stopTest();
    }
}
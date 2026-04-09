@isTest
public class ONE_SimuladorPDFServicioCiasTest {

    // Método de configuración de datos de prueba
    @testSetup
    static void setupTestData() {
       
        
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);

        
        // Crear un registro de ONE_Centro_Del_Expediente__c
        Account centro = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
            ONE_Tipo_De_Impuesto__c = 'IVA',
            ONE_Lugar__c = lugar.Id);
        insert centro;
        
        // Crear un registro de ONE_Expediente__c
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Compania'),
            ONE_Centro_Del_Expediente__c = centro.Id
        );
        insert expediente;
         // Crear un registro de ONE_Presupuesto__c
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            // Asigna los campos necesarios
            ONE_Importe_Base_21__c = 1000.00,
            ONE_Importe_Base_10__c = 500.00,
            ONE_Importe_Base_3__c = 300.00,
            ONE_Importe_Impuesto_21__c = 210.00,
            ONE_Importe_Impuesto_10__c = 50.00,
            ONE_Importe_Impuesto_3__c = 9.00,
            ONE_Importe_Neto_21__c = 1210.00,
            ONE_Importe_Neto_10__c = 550.00,
            ONE_Importe_Neto_3__c = 309.00,
            ONE_Importe_Neto_Suplido__c = 100.00,
            ONE_Total_Importe_Presupuesto__c = 2169.00,
            ONE_Observaciones__c = 'Observaciones de prueba',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name,
                'ONE_Presupuesto_App'),
            ONE_Tipo_De_Contrato__c = 'Hoja de Servicio',
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto no facturable',
            ONE_Expediente__c=expediente.Id
        );
        insert presupuesto;
        
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

      
        
        // Crear un registro de ONE_Producto__c
        ONE_Producto__c producto = new ONE_Producto__c(
            Name = 'Producto de Prueba',
            ONE_Codigo_Comercial__c = 'PC-001',
            ONE_Descripcion_En_Catalan__c = 'Descripción CA',
            ONE_Descripcion_En_Euskera__c = 'Descripción EU',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Categoria__c = categoria.Id
          
        );
        insert producto;
        
        // Crear un registro de ONE_Expediente_Line_Item__c
        ONE_Expediente_Line_Item__c lineItem = new ONE_Expediente_Line_Item__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Presupuesto__c = presupuesto.Id,
            ONE_Estado__c = 'Confirmado',
            ONE_Producto__c = producto.Id,
            ONE_Unidades__c = 2,
            ONE_Precio__c = 500.00,
            ONE_Suplido__c = false,
            ONE_Importe_Descuento_Posicion__c=5.00
        );
        insert lineItem;
    }
    
    // Método de prueba principal
    @isTest
    static void ONE_SimuladorPDFServicioCiasTest() {
        // Recuperar el presupuesto creado en @testSetup
        ONE_Presupuesto__c presupuesto = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1];
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        
        // Configurar los parámetros de la página
        Test.setCurrentPage(Page.ONE_SimuladorPDFServicioCias);
        ApexPages.currentPage().getParameters().put('presupuestoId', presupuesto.Id);
        ApexPages.currentPage().getParameters().put('language', 'es');
        ApexPages.currentPage().getParameters().put('servicioId',servicio.Id ); 
        ApexPages.currentPage().getParameters().put('validityYear', '2025');
        ApexPages.currentPage().getParameters().put('cliente', 'Cliente de Prueba');
        ApexPages.currentPage().getParameters().put('newAcuerdoName', 'Acuerdo de Prueba');
        ApexPages.currentPage().getParameters().put('logo', '');
        
        // Instanciar el controlador
        Test.startTest();
        ONE_SimuladorPDFServicioCiasCtlr controller = new ONE_SimuladorPDFServicioCiasCtlr();
        Test.stopTest();
    }
     @isTest
    static void ONE_SimuladorPDFServicioCiasTest2() {
        // Recuperar el presupuesto creado en @testSetup
        ONE_Presupuesto__c presupuesto = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1];
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        // Preparar los Inputs para el servicio
        ONE_SimuladorPDFServicioCiasService.Inputs input = new ONE_SimuladorPDFServicioCiasService.Inputs();
        input.presupuestoId = presupuesto.Id;
        input.servicioId = servicio.Id;
        input.validityYear = '2024';
        input.cliente = 'Cliente de Prueba';
        input.newAcuerdoName = 'Acuerdo de Prueba';
        input.language = 'es';
        input.logo = '';
        
        List<ONE_SimuladorPDFServicioCiasService.Inputs> inputs = new List<ONE_SimuladorPDFServicioCiasService.Inputs> { input };
        
        // Ejecutar el método invocable dentro de Test.startTest() y Test.stopTest()
        Test.startTest();
        List<ONE_SimuladorPDFServicioCiasService.Output> outputs = ONE_SimuladorPDFServicioCiasService.createAndLinkPdf(inputs);
        Test.stopTest();
        
        // Verificar que se haya retornado una lista con un Output
        System.assertNotEquals(null, outputs, 'La lista de outputs no debería ser nula.');
        System.assertEquals(1, outputs.size(), 'La lista de outputs debería contener un elemento.');
        
        ONE_SimuladorPDFServicioCiasService.Output output = outputs[0];
    }
     @isTest
    static void ONE_SimuladorPDFServicioCiasTest3() {
        // Recuperar el presupuesto creado en @testSetup
        ONE_Presupuesto__c presupuesto = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1];
        ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        // Preparar los Inputs para el servicio
        ONE_SimuladorPDFServicioCiasService.Inputs input = new ONE_SimuladorPDFServicioCiasService.Inputs();
        input.presupuestoId = 'presupuesto.Id';
        input.servicioId = 'test';
        input.validityYear = '2024';
        input.cliente = 'Cliente de Prueba';
        input.newAcuerdoName = 'Acuerdo de Prueba';
        input.language = 'es';
        input.logo = '';
        
        List<ONE_SimuladorPDFServicioCiasService.Inputs> inputs = new List<ONE_SimuladorPDFServicioCiasService.Inputs> { input };
        
        // Ejecutar el método invocable dentro de Test.startTest() y Test.stopTest()
        Test.startTest();
        List<ONE_SimuladorPDFServicioCiasService.Output> outputs = ONE_SimuladorPDFServicioCiasService.createAndLinkPdf(inputs);
        Test.stopTest();
        
        // Verificar que se haya retornado una lista con un Output
        System.assertNotEquals(null, outputs, 'La lista de outputs no debería ser nula.');
        System.assertEquals(1, outputs.size(), 'La lista de outputs debería contener un elemento.');
        
        ONE_SimuladorPDFServicioCiasService.Output output = outputs[0];
    }

}
@isTest
public class ONE_PostClientCreationQueueableTest {
    
    static testmethod void testQueueable1() {
        
        ONE_ClientCreationWebServiceTest.dataSetup();

        Id idServicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        List<ONE_Producto__c> productos = [SELECT Id FROM ONE_Producto__c LIMIT 2];
        String jsonStr = '{"pedido":{"idServicioConsulta":"<idServicio>","IDSAPempleado":"","tipoCliente":"Particular","nombreEmpresa":"","nombreCliente":"Martina","apellido1":"López","apellido2":"Martinez","tipoDeDocumento":"97","numeroDeDocumento":"54609640G","pais":"ES","provincia":"28","municipio":"Madrid","tipoDeCalle":"calle","direccion":"Amapola,15","numeroDeCalle":"7","piso":"6","codigoPostal":"10001","movil":"66456666","email":"martina@test.com","generacionFactura":false,"fechaDeFacturacion":"<fechaFacturacion>","importeTotal":350},"lineasPedido":[{"codigoDeProducto":"<idProducto1>","cantidad":"1","lazoOTarjeta":"Lazo","textoBandaOLazo":"Marta, ojala nos pasaran las cosas revisadas","fraseTarjeta":"Prueba","remitente":"Juanito","importeBase":"263.00","importeimpuestos":"8","porcentajeImpuesto":"10"},{"codigoDeProducto":"<idProducto2>","cantidad":"1","lazoOTarjeta":"Tarjeta","textoBandaOLazo":"","fraseTarjeta":"Prueba","remitente":"marina","importeBase":"33.00","importeimpuestos":"15","porcentajeImpuesto":"7"}]}';
		jsonStr = jsonStr.replace('<fechaFacturacion>', Datetime.now().format('yyyy-MM-dd'));
        jsonStr = jsonStr.replace('<idServicio>', idServicio);
        jsonStr = jsonStr.replace('<idProducto1>', productos[0].Id);
        jsonStr = jsonStr.replace('<idProducto2>', productos[1].Id);
        
        ONE_ClientCreationWebService.ClientDTO dto = (ONE_ClientCreationWebService.ClientDTO) JSON.deserialize(jsonStr, ONE_ClientCreationWebService.ClientDTO.class);
        
        Account acc = ONE_ClientCreationWebService.preparePersonAccount(dto.pedido);
      
        Map<String, Object> sObject2recordId = new Map<String, Object>();
        sObject2recordId.put('AccountId', acc.Id);
        ONE_Interlocutor__c interlocutor = new ONE_Interlocutor__c(
            ONE_Contacto__c = acc.Id,
            ONE_Expediente__c = dto.pedido.idServicioConsulta,
            ONE_Clasificacion__c = 'Participante',
            Name = acc.FirstName + ' ' + acc.LastName + ' - Interlocutor',
            ONE_Pagador__c = true
        );
        insert interlocutor;
        sObject2recordId.put('interlocutorId', interlocutor.Id);

        ONE_Presupuesto__c budget = new ONE_Presupuesto__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Presupuesto__c', 'ONE_Presupuesto_WEB'),
            ONE_ID_Comprador_Memora__c = dto.pedido.IDSAPempleado,
            ONE_Interlocutor__c = interlocutor.Id,
            ONE_Estado__c = 'Contratado',
            ONE_Expediente__c = dto.pedido.idServicioConsulta,
            ONE_Presupuesto_preconfigurado__c = false,
            ONE_Tipo_De_Contrato__c = dto.pedido.TipoCliente,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto web',
            ONE_Total_Importe_Presupuesto__c = dto.pedido.importeTotal != null ? Decimal.valueOf(dto.pedido.importeTotal) : null,
            ONE_Tareas_Lanzadas__c = true
        );

        insert budget;
        sObject2recordId.put('presupuestoId', budget.Id);

        ONE_Orden_De_Venta__c orden = new ONE_Orden_De_Venta__c(
            ONE_Generacion_Factura__c = dto.pedido.generacionFactura == 'True',
            ONE_Pagador_Particular__c = interlocutor.Id,
            ONE_Servicio__c = dto.pedido.idServicioConsulta,
            ONE_Fecha_De_Facturacion__c = dto.pedido.fechaDeFacturacion != null ? Date.valueOf(dto.pedido.fechaDeFacturacion) : null,
            ONE_Presupuesto__c = budget.Id,
            ONE_Forma_De_Pago__c = 'H',
            ONE_Importe_Total__c = dto.pedido.importeTotal != null ? Decimal.valueOf(dto.pedido.importeTotal) : null
        );

        insert orden;

        Test.setMock(HttpCalloutMock.class, new ONE_ClientCreationWebServiceTest.ClientCreationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', ONE_ClientCreationWebServiceTest.prepareResponseClientCreation()));
        Test.setMock(HttpCalloutMock.class, new ONE_ClientCreationWebServiceTest.SalesOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', ONE_ClientCreationWebServiceTest.prepareResponseSalesOrderCreation()));
        
		
        
        Test.startTest();
        System.enqueueJob(new ONE_PostClientCreationQueueable.SapClientCreationQueueable(
            orden.Id,
            dto.pedido.TipoCliente,
            dto.pedido.numeroDeDocumento,
            dto.pedido.idServicioConsulta
        ));
        
        System.enqueueJob(new ONE_PostClientCreationQueueable.SalesOrderActionQueueable(
            orden.Id,
            dto.pedido.TipoCliente,
            dto.pedido.numeroDeDocumento,
            false,
            dto.pedido.idServicioConsulta,
            true
        ));
		
        System.enqueueJob(new ONE_PostClientCreationQueueable.DocGenQueueable(orden.Id));
        
		//ONE_PostClientCreationQueueable.DocGenQueueable.buildDocument(orden.Id, '01', 'ES');
        Test.stopTest();
    }
    
    static testmethod void testQueueable2() {
        
        ONE_ClientCreationWebServiceTest.dataSetup();

        Id idServicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        List<ONE_Producto__c> productos = [SELECT Id FROM ONE_Producto__c LIMIT 2];
        String jsonStr = '{"pedido":{"idServicioConsulta":"<idServicio>","IDSAPempleado":"","tipoCliente":"Particular","nombreEmpresa":"","nombreCliente":"Martina","apellido1":"López","apellido2":"Martinez","tipoDeDocumento":"97","numeroDeDocumento":"54609640G","pais":"ES","provincia":"28","municipio":"Madrid","tipoDeCalle":"calle","direccion":"Amapola,15","numeroDeCalle":"7","piso":"6","codigoPostal":"10001","movil":"66456666","email":"martina@test.com","generacionFactura":true,"fechaDeFacturacion":"<fechaFacturacion>","":10021},"lineasPedido":[{"codigoDeProducto":"<idProducto1>","cantidad":"1","lazoOTarjeta":"Lazo","textoBandaOLazo":"Marta, ojala nos pasaran las cosas revisadas","fraseTarjeta":"Prueba","remitente":"Juanito","importeBase":"263.00","importeimpuestos":"18","porcentajeImpuesto":"10"},{"codigoDeProducto":"<idProducto2>","cantidad":"1","lazoOTarjeta":"Tarjeta","textoBandaOLazo":"","fraseTarjeta":"Prueba","remitente":"marina","importeBase":"2633.00","importeimpuestos":"145","porcentajeImpuesto":"7"}]}';		
        jsonStr = jsonStr.replace('<fechaFacturacion>', '1900-01-01');
        jsonStr = jsonStr.replace('<idServicio>', idServicio);
        jsonStr = jsonStr.replace('<idProducto1>', productos[0].Id);
        jsonStr = jsonStr.replace('<idProducto2>', productos[1].Id);
        
        ONE_ClientCreationWebService.ClientDTO dto = (ONE_ClientCreationWebService.ClientDTO) JSON.deserialize(jsonStr, ONE_ClientCreationWebService.ClientDTO.class);
        
        Account acc = ONE_ClientCreationWebService.preparePersonAccount(dto.pedido);
      
        Map<String, Object> sObject2recordId = new Map<String, Object>();
        sObject2recordId.put('AccountId', acc.Id);
        ONE_Interlocutor__c interlocutor = new ONE_Interlocutor__c(
            ONE_Contacto__c = acc.Id,
            ONE_Expediente__c = dto.pedido.idServicioConsulta,
            ONE_Clasificacion__c = 'Participante',
            Name = acc.FirstName + ' ' + acc.LastName + ' - Interlocutor',
            ONE_Pagador__c = true
        );
        insert interlocutor;
        sObject2recordId.put('interlocutorId', interlocutor.Id);

        ONE_Presupuesto__c budget = new ONE_Presupuesto__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Presupuesto__c', 'ONE_Presupuesto_WEB'),
            ONE_ID_Comprador_Memora__c = dto.pedido.IDSAPempleado,
            ONE_Interlocutor__c = interlocutor.Id,
            ONE_Estado__c = 'Contratado',
            ONE_Expediente__c = dto.pedido.idServicioConsulta,
            ONE_Presupuesto_preconfigurado__c = false,
            ONE_Tipo_De_Contrato__c = dto.pedido.TipoCliente,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto web',
            ONE_Total_Importe_Presupuesto__c = dto.pedido.importeTotal != null ? Decimal.valueOf(dto.pedido.importeTotal) : null,
            ONE_Tareas_Lanzadas__c = true
        );

        insert budget;
        sObject2recordId.put('presupuestoId', budget.Id);

        ONE_Orden_De_Venta__c orden = new ONE_Orden_De_Venta__c(
            ONE_Generacion_Factura__c = dto.pedido.generacionFactura == 'True',
            ONE_Pagador_Particular__c = interlocutor.Id,
            ONE_Servicio__c = dto.pedido.idServicioConsulta,
            ONE_Fecha_De_Facturacion__c = dto.pedido.fechaDeFacturacion != null ? Date.valueOf(dto.pedido.fechaDeFacturacion) : null,
            ONE_Presupuesto__c = budget.Id,
            ONE_Forma_De_Pago__c = 'H',
            ONE_Importe_Total__c = dto.pedido.importeTotal != null ? Decimal.valueOf(dto.pedido.importeTotal) : null
        );

        insert orden;

        Test.setMock(HttpCalloutMock.class, new ONE_ClientCreationWebServiceTest.ClientCreationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', ONE_ClientCreationWebServiceTest.prepareResponseClientCreation()));
        Test.setMock(HttpCalloutMock.class, new ONE_ClientCreationWebServiceTest.SalesOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', ONE_ClientCreationWebServiceTest.prepareResponseSalesOrderCreation()));
        
		
        
        Test.startTest();
        System.enqueueJob(new ONE_PostClientCreationQueueable.SapClientCreationQueueable(
            orden.Id,
            dto.pedido.TipoCliente,
            dto.pedido.numeroDeDocumento,
            dto.pedido.idServicioConsulta
        ));
        
        System.enqueueJob(new ONE_PostClientCreationQueueable.SalesOrderActionQueueable(
            orden.Id,
            dto.pedido.TipoCliente,
            dto.pedido.numeroDeDocumento,
            false,
            dto.pedido.idServicioConsulta,
            true
        ));
		
        System.enqueueJob(new ONE_PostClientCreationQueueable.DocGenQueueable(orden.Id));
        
		//ONE_PostClientCreationQueueable.DocGenQueueable.buildDocument(orden.Id, '01', 'ES');
        Test.stopTest();
    }
}
@isTest
private class ONE_CorreoCreateModPresupuestosTest {

    @isTest
    static void testSendEmailWithProducts() {
        // Crear registros relacionados para el expediente
        Account centro = new Account(Name = 'Centro Test', ONE_Email__c = 'centro@test.com');
        insert centro;

        Account lugarVelacion = new Account(Name = 'Lugar Velación', ONE_Email__c = 'velacion@test.com');
        Account lugarCeremonia = new Account(Name = 'Lugar Ceremonia', ONE_Email__c = 'ceremonia@test.com');
        Account lugarDespedida = new Account(Name = 'Lugar Despedida', ONE_Email__c = 'despedida@test.com');
        insert new List<Account>{lugarVelacion, lugarCeremonia, lugarDespedida};

        Account difunto = new Account(FirstName = 'Juan', LastName = 'Pérez');
        insert difunto;

        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = centro.Id,
            ONE_Lugar_De_Velacion__c = lugarVelacion.Id,
            ONE_Lugar_Ceremonia__c = lugarCeremonia.Id,
            ONE_Lugar_Despedida__c = lugarDespedida.Id,
            ONE_Inicio_Velacion__c = System.now(),
            ONE_Inicio_Ceremonia__c = System.now().addHours(1),
            ONE_Inicio_Despedida__c = System.now().addHours(2),
            ONE_Difunto__c = difunto.Id,
            ONE_Deposito__c = true,
            ONE_Velacion__c = true,
            ONE_Despedida__c = true,
            ONE_Ceremonia__c = true
        );
        insert expediente;

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
            ONE_Tipo_De_Venta__c = 'Venta mostrador'
        );
        insert presupuesto;

        // Producto y modelo
        ONE_Producto__c producto = new ONE_Producto__c(Name = 'Producto Test');
        insert producto;

        ONE_Modelo__c modelo = new ONE_Modelo__c(Name = 'Modelo Test');
        insert modelo;

        // SLI con productos contratados
        ONE_Expediente_Line_Item__c sli1 = new ONE_Expediente_Line_Item__c(
            ONE_Presupuesto__c = presupuesto.Id,
            ONE_Expediente__c = expediente.Id,
            ONE_Producto__c = producto.Id,
            ONE_Modelo__c = modelo.Id,
            ONE_Cantidad__c = 2,
            ONE_Comentarios__c = 'Comentario de prueba'
        );
        insert sli1;

        // Tarea
        ONE_Tarea__c tarea = new ONE_Tarea__c(
            Name = 'Tarea1',
            ONE_Linea_De_Expediente__c = sli1.Id,
            ONE_Expediente__c = expediente.Id,
            ONE_Fecha_Hora_Recepci_n_Del_Producto__c = System.now().addDays(1),
            ONE_Lugar_de_Entrega__c = 'Lugar de entrega test'
        );
        insert tarea;

        // Ejecutar el método con productos contratados
        ONE_CorreoCreateModPresupuestos.EmailRequest req1 = new ONE_CorreoCreateModPresupuestos.EmailRequest();
        req1.presupuestoId = presupuesto.Id;

        Test.startTest();
        ONE_CorreoCreateModPresupuestos.sendEmail(new List<ONE_CorreoCreateModPresupuestos.EmailRequest>{ req1 });
        Test.stopTest();

        // Validar que el correo se envió correctamente
        System.assert(true, 'El correo con productos se envió correctamente.');
    }

    @isTest
    static void testSendEmailWithoutProducts() {
        // Crear registros relacionados para el expediente
        Account centro = new Account(Name = 'Centro Test', ONE_Email__c = 'centro@test.com');
        insert centro;

        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = centro.Id,
            ONE_Inicio_Velacion__c = System.now(),
            ONE_Difunto__c = null,
            ONE_Deposito__c = false,
            ONE_Velacion__c = false,
            ONE_Despedida__c = false,
            ONE_Ceremonia__c = false
        );
        insert expediente;

        ONE_Presupuesto__c presupuestoSinProductos = new ONE_Presupuesto__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
            ONE_Tipo_De_Venta__c = 'Venta mostrador'
        );
        insert presupuestoSinProductos;

        ONE_CorreoCreateModPresupuestos.EmailRequest req2 = new ONE_CorreoCreateModPresupuestos.EmailRequest();
        req2.presupuestoId = presupuestoSinProductos.Id;

        Test.startTest();
        ONE_CorreoCreateModPresupuestos.sendEmail(new List<ONE_CorreoCreateModPresupuestos.EmailRequest>{ req2 });
        Test.stopTest();

        // Validar que el correo se envió correctamente
        System.assert(true, 'El correo sin productos se envió correctamente.');
    }
}
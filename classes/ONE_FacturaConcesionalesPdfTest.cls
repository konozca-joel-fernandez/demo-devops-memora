@isTest
public class ONE_FacturaConcesionalesPdfTest {
   			@testSetup
			static void setupData() {

            // Sociedad (Account)
            Account sociedad = new Account(
                Name = 'Sociedad Test',
                Website = 'https://test.com'
            );
            insert sociedad;
        
            // Centro del expediente (Account)
            Account centro = new Account(
                Name = 'Centro Test',
                BillingStreet = 'Calle Test',
                BillingCity = 'Ciudad',
                BillingState = 'Provincia',
                BillingPostalCode = '08001',
                Phone = '123456789'
            );
            insert centro;
        
            // Servicio
            ONE_Expediente__c servicio = new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id, // lookup a Account
                ONE_Difunto__c = null // puedes asignar un difunto Account si quieres
            );
            insert servicio;
        
            // RecordType Orden de Venta
            RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'ONE_Orden_De_Venta__c'
                LIMIT 1
            ];
        
            // Orden de Venta
            ONE_Orden_De_Venta__c orden = new ONE_Orden_De_Venta__c(
                RecordTypeId = rt.Id,
                ONE_Servicio__c = servicio.Id,
                ONE_Fecha_De_Facturacion__c = Date.today(),
                ONE_Numero_de_factura__c = 'F-001'
            );
            insert orden;
        
            // Producto concesional
            ONE_Producto__c producto = new ONE_Producto__c(
                Name = 'Producto Test',
                ONE_Concesion__c = true
            );
            insert producto;
        
            // Línea de expediente
            ONE_Expediente_Line_Item__c linea = new ONE_Expediente_Line_Item__c(
                ONE_Orden_De_Venta__c = orden.Id,
                ONE_Producto__c = producto.Id,
                ONE_Importe_Base__c = 100,
                ONE_Impuesto__c = 21,
                ONE_Importe_Impuesto__c = 21,
                ONE_Importe_Neto__c = 121,
                ONE_Cantidad__c = 1,
                ONE_Expediente__c = servicio.Id
            );
            insert linea;
        }

    @IsTest
    static void testCreateAndLinkPdf_success() {

        ONE_Orden_De_Venta__c orden = [
            SELECT Id, ONE_Numero_de_factura__c
            FROM ONE_Orden_De_Venta__c
            LIMIT 1
        ];

        ONE_FacturaConcesionalesPdfService.FlowInput input =
            new ONE_FacturaConcesionalesPdfService.FlowInput();
        input.ordenDeVentaId = orden.Id;
        input.language = 'es';
        input.numFactura = orden.ONE_Numero_de_factura__c;

        Test.startTest();
        List<ONE_PdfServiceBase.FlowOutput> result =
            ONE_FacturaConcesionalesPdfService.createAndLinkPdf(
                new List<ONE_FacturaConcesionalesPdfService.FlowInput>{ input }
            );
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(true, result[0].success);
    }

    @IsTest
    static void testPdfControllerAndFactory() {

        ONE_Orden_De_Venta__c orden = [
            SELECT Id
            FROM ONE_Orden_De_Venta__c
            LIMIT 1
        ];

        Test.setCurrentPage(Page.ONE_FacturaConcesionalesPdf);
        ApexPages.currentPage().getParameters().put('ordenDeVentaId', orden.Id);
        ApexPages.currentPage().getParameters().put('language', 'es');

        ONE_FacturaConcesionalesPdfController controller =
            new ONE_FacturaConcesionalesPdfController();

        System.assertNotEquals(null, controller.data);
        System.assertEquals('es', controller.data.language);
        System.assert(controller.data.productRows.size() > 0);
        System.assert(controller.data.taxTotals.size() > 0);
        System.assertEquals('100.00', controller.data.totalBase);
        System.assertEquals('21.00', controller.data.totalImpuesto);
        System.assertEquals('121.00', controller.data.totalNeto);
    }
    
    
}
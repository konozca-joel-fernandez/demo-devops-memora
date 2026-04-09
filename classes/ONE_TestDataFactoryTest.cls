/**
 * Created by Miguel Serrat on 29.03.2023.
 *
 * LOGs:
 * ------------------------------------------
 * DATA       USER            CHANGE
 * ------------------------------------------
 */
@IsTest
public with sharing class ONE_TestDataFactoryTest {
    
    @IsTest
    public static void factoryTest() {
        ONE_Catalogo_De_Precios__c cp = ONE_TestDataFactory.createCatalogoDePrecios(null,false);
        ONE_Entrada_De_Modelo__c em = ONE_TestDataFactory.createEntradaDeModelo(null,false);
        ONE_Entrada_De_Precio__c ep = ONE_TestDataFactory.createEntradaDePrecio(null,false);
        ONE_Imagen__c img = ONE_TestDataFactory.createImagen(null,false);
        ONE_Tipologia_Producto__c tp = ONE_TestDataFactory.createTipologiaProducto(null,false);
        ONE_Atributo__c attb = ONE_TestDataFactory.createAttribute(null, false);
        ONE_Presupuesto__c p = ONE_TestDataFactory.createPresupuesto(null, false);
        ONE_Producto__c prod = ONE_TestDataFactory.createProducto(null, false);
        ONE_Relacion_De_Productos__c rp = ONE_TestDataFactory.createRelacionDeProductos(null, false);
        ONE_Pedido_De_Proveedor__c pp = ONE_TestDataFactory.createPedidoDeProveedor(null, false);
        ONE_Tarea__c t = ONE_TestDataFactory.createTarea(null, false);
        ONE_Contrato__c c = ONE_TestDataFactory.createContrato(null, false);
        ONE_Interlocutor__c i = ONE_TestDataFactory.createInterlocutor(null, false);
        ONE_Expediente__c e = ONE_TestDataFactory.createExpediente(null, false);
        ONE_Orden_De_Venta__c ov = ONE_TestDataFactory.createOrdenDeVenta(null, false);
        ONE_Recurso__c r = ONE_TestDataFactory.createRecurso(null, false);
        Account accC = ONE_TestDataFactory.createCentro(null, false);
        Account accNCA = ONE_TestDataFactory.createNonCompAccount(null, false);
        Account acc = ONE_TestDataFactory.createAccount(null, false);
        //Account accCC = ONE_TestDataFactory.createCentroCemetary(null, false);
        Account accP = ONE_TestDataFactory.createPersonAccount(null,false);
        Account accB = ONE_TestDataFactory.createBusinessAccount(null, false);
        ONE_Integration_endpoint__mdt iEndPoint = ONE_TestDataFactory.createIntegrationEndpointMeta(null);
        ONE_Contracto_Line_Item__c cli = ONE_TestDataFactory.createContractoLineItem(null, false);
        ONE_Configuracion_De_Tarea__c ct = ONE_TestDataFactory.createConfiguracionDeTarea(null, false);
        ONE_Lugar__c l = ONE_TestDataFactory.createLugar(null, false);
        ONE_Modelo__c m = ONE_TestDataFactory.createModelo(null, false);
        User u = ONE_TestDataFactory.createUser('12345', false);
    }
}
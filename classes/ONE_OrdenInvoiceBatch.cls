/**
 * Created by kmotyka005 on 19.10.2021.
 */
//Invoice batch class definition
public with sharing class ONE_OrdenInvoiceBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Query definiton to get register to operate
        String query = 'SELECT Id, ONE_estado__c, ONE_Tipo_De_Factura__c,Name, ONE_Enviar_Factura_a_Cliente__c, ONE_Factura_Enviada_a_Cliente__c, ONE_Numero_de_factura__c,ONE_N_Factura_Plataforma__c, ONE_Fecha_de_facturaci_n_Plataforma__c,' +
            ' ONE_Idioma_de_la_factura__c, ONE_Tipo_De_Factura_M1__c,ONE_Facturado_Generali__c, ONE_GeneraliOCajamar__c, ONE_Servicio__c,ONE_Fecha_De_Facturacion__c,ONE_budgetNumber__c, ONE_Historial_Errores__c   ' +
            ' FROM ONE_Orden_De_Venta__c' +
            ' WHERE ONE_estado__c = \'A\'' +
            ' AND ONE_Facturado_Generali__c  = false';
        return Database.getQueryLocator(query);
    }
	//Execute process
    public void execute(Database.BatchableContext BC, List<ONE_Orden_De_Venta__c> ordenDeVentaList) {
        ONE_OrdenInvoice.processOrders(ordenDeVentaList);
    }
	//Method with the definition od action to do at the end of the execution
    public void finish(Database.BatchableContext param1) {

    }
}
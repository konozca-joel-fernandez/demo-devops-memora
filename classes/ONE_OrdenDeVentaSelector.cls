/**
 * Created by mchruscick001 on 17.11.2021 11:14.
 */
//Calls to obtain sales order infromation based on salesorder input ID
public with sharing class ONE_OrdenDeVentaSelector {
	//Method to query information
    public static List<ONE_Orden_De_Venta__c> selectSalesOrders(List<Id> salesOrderIds) {
        return [
                SELECT Id, ONE_Tipo_De_Factura__c,Name, ONE_Enviar_Factura_a_Cliente__c, ONE_Historial_Errores__c,
                        ONE_Factura_Enviada_a_Cliente__c, ONE_Numero_de_factura__c, ONE_Idioma_de_la_factura__c,
                        ONE_Facturado_Generali__c, ONE_GeneraliOCajamar__c, ONE_Servicio__c,
                        ONE_Fecha_De_Facturacion__c, ONE_budgetNumber__c, ONE_Tipo_De_Factura_M1__c, ONE_N_Factura_Plataforma__c,
            			ONE_Fecha_de_facturaci_n_Plataforma__c
                FROM ONE_Orden_De_Venta__c
                WHERE Id IN :salesOrderIds
        ];
    }
}
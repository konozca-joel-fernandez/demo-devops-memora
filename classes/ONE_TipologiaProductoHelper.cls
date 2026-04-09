/**
 * Created by mbujak003 on 22.02.2021.
 */

public with sharing class ONE_TipologiaProductoHelper {
    public static List<ONE_Tipologia_Producto__c> fetchTipologiaProductos() {
        return [
            SELECT Id, ONE_Nombre_ESP__c, ONE_Nombre_CAT__c, ONE_Nombre_EUS__c, ONE_Orden__c,
                ONE_Tipologia_UX__c, ONE_Cantidad__c, ONE_Localizacion_Atributos__c, ONE_Excepcion__c,
                ONE_Boton_No_Servir_Marcar_Como_Mejora__c, ONE_Varias_lineas_producto_por_unidad__c
            FROM ONE_Tipologia_Producto__c
        ];
    }
}
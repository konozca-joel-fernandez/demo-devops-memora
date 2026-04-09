public with sharing class ONE_PedidoDeProveedorSelector {
    
    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedorForPdfGeneration(Id pedidoId) {
        return [
            SELECT ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name, ONE_Expediente__r.Owner.FirstName,
                ONE_Expediente__r.Owner.LastName, ONE_Expediente__r.Name, ONE_Expediente__r.ONE_Difunto__r.FirstName,
                ONE_Expediente__r.ONE_Difunto__r.LastName, ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                ONE_Expediente__r.ONE_Numero_de_Documento__c, toLabel(ONE_Expediente__r.ONE_Difunto__r.ONE_Nacionalidad__c),
           		ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_nacimiento__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Altura_Cm__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Peso_Kg__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Padres__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_De_La_Madre__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Estado_Civil__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Conyuge__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Direccion__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Municipio__pc, toLabel(ONE_Expediente__r.ONE_Difunto__r.ONE_Provincia__pc),
                ONE_Expediente__r.ONE_Difunto__r.ONE_Pais__pc, ONE_Expediente__c, 
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,  ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
                toLabel(ONE_Expediente__r.ONE_Provincia_De_Defuncion__c), ONE_Expediente__r.ONE_Fecha_De_Defuncion__c,
                ONE_Expediente__r.ONE_Causas_Defuncion__c, ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name, ONE_Expediente__r.ONE_Declarante__c, 
            	ONE_Expediente__r.ONE_Difunto__r.ONE_Codigo_Postal__c,
            	ONE_Expediente__r.ONE_Difunto__r.ONE_Numero_de_los_hijos__c,
                Name, ONE_Fecha__c, ONE_Proveedor__r.Name,ONE_Email_De_Remitente__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Codigo_Postal__pc,
            	ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,ONE_Expediente__r.ONE_Tipo_De_Lugar_De_Defuncion__c,ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.Name,
                ONE_Expediente__r.ONE_Compania__r.Name, ONE_Expediente__r.ONE_Numero_de_Poliza__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
                toLabel(ONE_Expediente__r.ONE_Difunto__r.ONE_Provincia_nacimiento__c),
                ONE_Expediente__r.ONE_Nombre_Mascota__c,ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Tipo_de_Mascota__c,
            	ONE_Expediente__r.ONE_Peso__c,ONE_Expediente__r.ONE_Tipo_de_Incineracion__c,ONE_Expediente__r.ONE_Observaciones__c
            FROM ONE_Pedido_De_Proveedor__c
            WHERE Id = :pedidoId
        ];
    }
    
    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedorForEmail(Id pedidoId) {
        return [
            SELECT Name, ONE_Expediente__r.Owner.FirstName, ONE_Expediente__r.Owner.LastName, ONE_Expediente__r.Name,
                ONE_Proveedor__r.Name, ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.FirstName,
                ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Difunto__r.LastName, ONE_Email_Proveedor__c, ONE_Email_De_Remitente__c, 
            	ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,ONE_Expediente__r.ONE_Nombre_Mascota__c,ONE_Pedido_De_Proveedor__c.ONE_Expediente__r.ONE_Tipo_de_Mascota__c,
            	ONE_Expediente__r.ONE_Peso__c,ONE_Expediente__r.ONE_Tipo_de_Incineracion__c,ONE_Expediente__r.ONE_Observaciones__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            FROM ONE_Pedido_De_Proveedor__c
            WHERE Id = :pedidoId
        ];
    }
}
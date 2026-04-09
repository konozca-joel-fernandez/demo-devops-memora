public class ONE_PedidoMedicoDataFactory {
 
    public static ONE_PedidoMedicoData buildPedidoMedicoData(String pedidoProveedorId, String language) {
        
        ONE_Tarea__c tarea = selectTareaForPdfGeneration(pedidoProveedorId);
        ONE_Pedido_De_Proveedor__c pedidoProveedor = selectPedidoProveedorForPdfGeneration(pedidoProveedorId);
        ONE_Interlocutor__c interlocutor = selectInterlocutorForPdfGeneration(pedidoProveedor.ONE_Expediente__c);
                
        System.debug('tarea query: ' + tarea);
        
        ONE_PedidoMedicoData data = new ONE_PedidoMedicoData(
            getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_MEDICO),
            tarea,
            pedidoProveedor,
            interlocutor, 
            language
        );
        
        System.debug('DATA: ' + data);
        return data;
    }
    
    
    public static ONE_Tarea__c selectTareaForPdfGeneration(Id pedidoProveedorId) {
        
        return [
            Select
                 ONE_Tanatoestetica__c,
                 ONE_Tanatopraxia__c,
                 ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                 ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                 ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
            	 ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                 ONE_Fecha_Y_Hora__c,
                 ONE_Lugar__r.Name,
                 ONE_Cantidad__c,
                 ONE_Comentarios__c,
                 ONE_Producto__r.ONE_Descriptivo_Producto_ESP__c,
                 ONE_Producto__r.ONE_Descriptivo_Producto_CAT__c,
                 ONE_Producto__r.ONE_Descriptivo_Producto_EUS__c
             from
             	ONE_Tarea__c 
             where
             	ONE_Pedido_De_Proveedor__c =: pedidoProveedorId Limit 1];
    }
    
    public static ONE_Pedido_De_Proveedor__c selectPedidoProveedorForPdfGeneration(Id pedidoProveedorId) {
        
        return [
            SELECT
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                ONE_Expediente__r.Owner.FirstName,
                ONE_Expediente__r.Owner.LastName,
                Name,
                ONE_Fecha__c,
                ONE_Proveedor__r.Name,
                ONE_Expediente__r.Name,
                ONE_Expediente__r.ONE_Difunto__r.FirstName,
                ONE_Expediente__r.ONE_Difunto__r.LastName,
                ONE_Expediente__r.ONE_Tipo_de_documento_de_identidad__c,
                ONE_Expediente__r.ONE_Numero_de_Documento__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_nacimiento__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Sexo__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Padres__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_De_La_Madre__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Direccion__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Municipio__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Provincia__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Pais__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Estado_Civil__c,
                ONE_Expediente__r.ONE_Fecha_De_Defuncion__c,
                ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
            	ONE_Expediente__r.ONE_Causas_Defuncion__c,
            	ONE_Expediente__r.ONE_Direccion_Velacion__c,
           		ONE_Expediente__r.ONE_Municipio_Velacion__c,
            	ONE_Expediente__r.ONE_Provincia_Velacion__c,
            	ONE_Expediente__r.ONE_Codigo_Postal_Velacion__c,
            	ONE_Expediente__r.ONE_Inicio_Velacion__c,
            	ONE_Expediente__r.ONE_Destino_Final__r.ONE_Lugar_De_Entrega__c,
            	ONE_Expediente__r.ONE_Hora_Destino_Final__c,
            	ONE_Expediente__r.ONE_Tipo_De_Lugar_Destino_Final__c
            
            FROM
                ONE_Pedido_De_Proveedor__c
            WHERE
                ID =:  pedidoProveedorId Limit 1];
    }
    
    public static ONE_Interlocutor__c selectInterlocutorForPdfGeneration(Id servicioId) {
        
        return [
            SELECT
                ONE_Contacto__r.FirstName,
                ONE_Contacto__r.LastName,
                ONE_Relacion_con_el_difunto__c,
                ONE_Contacto__r.ONE_Direccion__pc,
                ONE_Contacto__r.ONE_Municipio__pc,
                ONE_Contacto__r.ONE_Provincia__pc,
                ONE_Contacto__r.Phone,
                ONE_Contacto__r.PersonEmail
            FROM
                ONE_Interlocutor__c           
            WHERE
                ONE_Expediente__c =: servicioId and ONE_Pagador__c = True Limit 1];
    }
        
    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }
    
}
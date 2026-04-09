public class ONE_PedidoGestoriaDataFactory {

    public static ONE_PedidoGestoriaData buildPedidoGestoriaData(String pedidoProveedorId, String language) {
        
        ONE_Tarea__c tarea = selectTareaForPdfGeneration(pedidoProveedorId);
        System.debug('tarea query: ' + tarea);
        ONE_Pedido_De_Proveedor__c pedidoProveedor = selectPedidoProveedorForPdfGeneration(pedidoProveedorId);
        System.debug('pedidoProveedor query: ' + pedidoProveedor);
        ONE_Interlocutor__c interlocutor = selectInterlocutorForPdfGeneration(pedidoProveedor.ONE_Expediente__c);                
        System.debug('interlocutor query: ' + interlocutor);
        
        ONE_PedidoGestoriaData data = new ONE_PedidoGestoriaData(
            getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_GESTORIA),
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
            SELECT
                ONE_Producto__r.ONE_Descripcion_En_Castellano__c, 
                ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
            	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                ONE_Cantidad__c,
                ONE_Producto__r.ONE_Descriptivo_Producto_ESP__c,
                ONE_Producto__r.ONE_Descriptivo_Producto_CAT__c,
                ONE_Producto__r.ONE_Descriptivo_Producto_EUS__c,
            	ONE_Producto__r.ONE_Descriptivo_Producto_ENG__c,
                ONE_Comentarios__c
            FROM 
            	ONE_Tarea__c
            WHERE
            	ONE_Pedido_De_Proveedor__c =: pedidoProveedorId Limit 1];
    }
    
    public static ONE_Pedido_De_Proveedor__c selectPedidoProveedorForPdfGeneration(Id pedidoProveedorId) {
        
        return [
            SELECT       
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                ONE_Expediente__r.Owner.FirstName,
                ONE_Expediente__r.Owner.LastName,
                Name,
                ONE_Fecha__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                ONE_Proveedor__r.Name,
                ONE_Expediente__r.Name,
                ONE_Expediente__r.ONE_Difunto__r.FirstName,
                ONE_Expediente__r.ONE_Difunto__r.LastName,
                toLabel(ONE_Expediente__r.ONE_Tipo_de_documento_de_identidad__c),
                ONE_Expediente__r.ONE_Numero_de_Documento__c,
            	ONE_Expediente__r.ONE_Difunto__r.ONE_N_Documento__pc,
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
            	ONE_Expediente__r.ONE_Municipio_De_Defuncion__c
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
                ONE_Contacto__r.PersonEmail,
                ONE_Contacto__r.PersonHomePhone,
                ONE_Contacto__r.ONE_Email__c
            FROM 
            	ONE_Interlocutor__c         
            WHERE
                ONE_Expediente__c =: servicioId and ONE_Declarante__c = True Limit 1];
    }
    
    
    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }
    
}
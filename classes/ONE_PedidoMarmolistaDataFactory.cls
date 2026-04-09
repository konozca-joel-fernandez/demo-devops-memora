public class ONE_PedidoMarmolistaDataFactory {
    
    //Method to call all queryes to get the data and generate the data structure for the PDF 
    public static ONE_PedidoMarmolistaData buildPedidoMarmolistaData(String pedidoProveedorId, String language) {
        
        ONE_Tarea__c tarea = selectTareaForPdfGeneration(pedidoProveedorId);
        System.debug('tarea query: ' + tarea);
        ONE_Pedido_De_Proveedor__c pedidoProveedor = selectPedidoProveedorForPdfGeneration(pedidoProveedorId);
        System.debug('PedidoProveedor query: ' + pedidoProveedor);

        ONE_PedidoMarmolistaData data = new ONE_PedidoMarmolistaData(
            getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_MARMOLISTA),
            tarea,
            pedidoProveedor,
            language
        );
        
        System.debug('DATA: ' + data);
        return data;
    }
    
    //Method to query tareas
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
            ONE_LocalizacionUnidadEnterramiento__c,
            ONE_Concesion__c,
            ONE_Comentarios__c,
            ONE_Reproduccion__c,
            ONE_Inscripcion__c,
            ONE_Color_Del_Marmol__c,
            ONE_Tipografia__c,
            ONE_Tamano__c
            FROM 
            ONE_Tarea__c
            WHERE
            ONE_Pedido_De_Proveedor__c =: pedidoProveedorId Limit 1];
    }
    
    //Method to query pedido de proveedor information 
    public static ONE_Pedido_De_Proveedor__c selectPedidoProveedorForPdfGeneration(Id pedidoProveedorId) {
        
        return [
            SELECT
            ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
            ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
            ONE_Expediente__r.Owner.FirstName,
            ONE_Expediente__r.Owner.LastName,
            Name,
            ONE_Fecha__c,
            ONE_Proveedor__r.Name,
            ONE_Expediente__r.Name,
            ONE_Expediente__r.ONE_Difunto__r.FirstName,
            ONE_Expediente__r.ONE_Difunto__r.LastName,
            toLabel(ONE_Expediente__r.ONE_Tipo_de_documento_de_identidad__c),
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
            ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Phone,
            ONE_Expediente__r.ONE_Destino_Final__r.Name,
            ONE_Expediente__r.ONE_Destino_Final__r.ONE_Direccion__c,
            ONE_Expediente__r.ONE_Destino_Final__r.ONE_Municipio__c,
            ONE_Expediente__r.ONE_Destino_Final__r.ONE_Municipio_Direccion__c,
            ONE_Expediente__r.ONE_Destino_Final__r.ONE_Provincia__c,
            ONE_Expediente__r.ONE_Destino_Final__r.ONE_Pais__c,
            ONE_Expediente__r.ONE_Declarante__r.FirstName,
            ONE_Expediente__r.ONE_Declarante__r.LastName,
            ONE_Expediente__r.ONE_Declarante__r.PersonHomePhone,
            ONE_Expediente__r.ONE_Declarante__r.ONE_Email__c,
            ONE_Expediente__r.ONE_Declarante__r.ONE_Direccion__pc,
            ONE_Expediente__r.ONE_Declarante__r.ONE_Municipio__pc,
            toLabel(ONE_Expediente__r.ONE_Declarante__r.ONE_Provincia__pc),
            ONE_Expediente__r.ONE_Declarante__r.ONE_Codigo_Postal__pc,
            toLabel(ONE_Expediente__r.ONE_Declarante__r.ONE_Pais__pc)
            FROM
            ONE_Pedido_De_Proveedor__c
            WHERE
            ID =:  pedidoProveedorId Limit 1];
    }
    //query to get document code to display into the document header    
    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }
    
}
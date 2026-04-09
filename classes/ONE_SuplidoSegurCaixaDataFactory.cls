public class ONE_SuplidoSegurCaixaDataFactory {
    
    public static ONE_SuplidoSegurCaixaData buildSegurCaixaData(String ordenDeVentaID) {
        ONE_Orden_De_Venta__c ordenDeVenta = selectOrdenDeVentaForPdfGeneration(ordenDeVentaID);
        String signatureUrl = getSignatureImgUrl(ordenDeVentaID);
        
        System.debug('Orden de Venta query: ' + ordenDeVenta);
        
        ONE_SuplidoSegurCaixaData data = new ONE_SuplidoSegurCaixaData(ordenDeVenta);
        
        System.debug('DATA: ' + data);
        return data;
    }
       
    public static ONE_Orden_De_Venta__c selectOrdenDeVentaForPdfGeneration(Id ordenDeVentaID) {
        return [            
            Select
  				id,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.name,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_CIF__c,
                ONE_Numero_de_factura__c,
                ONE_Fecha_De_Facturacion__c,
                ONE_Servicio__r.ONE_Difunto__c,
                ONE_Servicio__r.ONE_Numero_de_Poliza__c,
            	ONE_Servicio__r.Name,
            	ONE_Servicio__r.ONE_Difunto__r.Name,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Direccion__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Codigo_Postal__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Municipio_Direccion__c,
            	toLabel(ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Provincia__c), 
            	Name
            	
            from
               ONE_Orden_De_Venta__c 
            where
               id =: ordenDeVentaID
        ];
    }
    
    /*private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }*/
    
    private static String getSignatureImgUrl(Id documentosId) {
        List<Attachment> attachments = new List<Attachment>([
            SELECT Id
            FROM Attachment
            WHERE ParentId = :documentosId AND Name = 'Signature.png'
            ORDER BY CreatedDate DESC
        ]);
        
        if (attachments.isEmpty()) {
            return '';
        } else {
            String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
            fileURL = fileURL.replace('visualforce.com','documentforce.com');
            fileURL += '/servlet/servlet.FileDownload?file=' + attachments.get(0).Id;
            System.debug('Signature url: ' + fileURL);
            return fileURL;
        }
    }
}
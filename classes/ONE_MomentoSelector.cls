/**
 * Created by msulek003 on 21.04.2021.
 */

public with sharing class ONE_MomentoSelector {
	//Query all ONE_Expediente_Line_Item__c that are not canceled or the product related has comercial code 1000005886
    public static List<ONE_Expediente_Line_Item__c> getAllRelatedLineItems (Id presupuestoId){
        return new List<ONE_Expediente_Line_Item__c>([
            SELECT ONE_Cantidad__c,
                ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
            	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                ONE_Importe_Base__c,
                ONE_Impuesto__c,
                ONE_Importe_Neto__c,
                ONE_Precio__c,
                ONE_Importe_Descuento_Posicion__c,
                ONE_Importe_Impuesto__c,
                ONE_Linea_De_Servicio_Padre__c,
                ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                ONE_Producto__r.ONE_Categoria__r.Name,
                ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,
                ONE_Texto_Banda_O_Lazo__c,
            	ONE_Numero_SLI__c,
            	ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
            FROM   ONE_Expediente_Line_Item__c
            WHERE  ONE_Presupuesto__c = : presupuestoId
                AND one_suplido__c = false
                AND ( ONE_Linea_De_Servicio_Padre__c = NULL )
                AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
            	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
        ]);
    }
	//Query all ONE_Expediente_Line_Item__c parents (for those cases of bundles products) that are not canceled or the product related has comercial code 1000005886
    public static List<ONE_Expediente_Line_Item__c> getPrestacionLineItemsWithParents (Id presupuestoId){
        return new List<ONE_Expediente_Line_Item__c>([
            SELECT ONE_Cantidad__c,
                ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
            	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                ONE_Importe_Base__c,
                ONE_Impuesto__c,
                ONE_Importe_Neto__c,
                ONE_Precio__c,
                ONE_Importe_Descuento_Posicion__c,
                ONE_Importe_Impuesto__c,
                ONE_Linea_De_Servicio_Padre__c,
                ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                ONE_Producto__r.ONE_Categoria__r.Name,
                ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                ONE_Texto_Banda_O_Lazo__c,
            	ONE_Numero_SLI__c,
            	ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
            FROM   ONE_Expediente_Line_Item__c
            WHERE  ONE_Presupuesto__c = : presupuestoId
                AND one_suplido__c = false
                AND ( ONE_Numero_SLI_Padre__c != NULL )
                AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'           
        ]);
    }
	
    //Query all ONE_Expediente_Line_Item__c from the object ONE_Orden_De_Venta__c that are not canceled or the product related has comercial code 1000005886
    public static List<ONE_Expediente_Line_Item__c> getAllRelatedFacturaLineItems (Id ordenDeVentaId){
        List<ONE_Expediente_Line_Item__c> returnLineas;
        String tipoDocumento = [Select ONE_tipoDocumento__c  from ONE_Orden_De_Venta__c where id =:ordenDeVentaId ].ONE_tipoDocumento__c;
        
        System.debug('tipoDocumento-->' + tipoDocumento);
        
        if(tipoDocumento == 'Abono'){ // For abono's document type we need to take Canceled ones
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c = NULL
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);
        }else{ //Not canceled and not discount
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c = NULL
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);            
        }
        
        return returnLineas;
    }

    //Query all ONE_Expediente_Line_Item__c with his parents (case for bundles) from the object ONE_Orden_De_Venta__c that are/or not canceled or the product related has comercial code 1000005886
    public static List<ONE_Expediente_Line_Item__c> getFacturaLineItemsWithParents (Id ordenDeVentaId){
        List<ONE_Expediente_Line_Item__c> returnLineas;
        String tipoDocumento = [Select ONE_tipoDocumento__c  from ONE_Orden_De_Venta__c where id =:ordenDeVentaId ].ONE_tipoDocumento__c;
        
        System.debug('tipoDocumento-->' + tipoDocumento);
        
        if(tipoDocumento == 'Abono'){ // For abono's document type we need to take Canceled ones
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c != NULL
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);
        }else{ //Not canceled and not discount
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c != NULL
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);   
        }
        
        return returnLineas;
    }

    //Query all ONE_Expediente_Line_Item__c from the object ONE_Abono_Parcial__c that are not canceled or the product related has comercial code 1000005886
    public static List<ONE_Expediente_Line_Item__c> getAllRelatedAbonoParcialLineItems (Id abonoParcialId, String documentType){
        List<ONE_Expediente_Line_Item__c> returnLineas;
        
        System.debug('documentType-->' + documentType);
        
        if (documentType == 'factura_rectificativa') { // Documento "Factura rectificativa". Mostramos las SLIs no canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_parcial__c = : abonoParcialId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c = NULL
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);
        }
        else if (documentType == 'cancelacion_abono_parcial') { // Documento "Cancelación de abono parcial". Mostramos las SLIs canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_parcial__c = : abonoParcialId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c = NULL
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado' 
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);            
        }
        
        return returnLineas;
    }

    //Query all ONE_Expediente_Line_Item__c with his parents (case for bundles) from the object ONE_Abono_Parcial__c that are/or not canceled or the product related has comercial code 1000005886
    public static List<ONE_Expediente_Line_Item__c> getAbonoParcialLineItemsWithParents (Id abonoParcialId, String documentType){
        List<ONE_Expediente_Line_Item__c> returnLineas;
        
        System.debug('documentType-->' + documentType);
        
        if(documentType == 'factura_rectificativa') { // Documento "Factura rectificativa". Mostramos las SLIs no canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_Parcial__c = : abonoParcialId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c != NULL
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);
        }
        else if (documentType == 'cancelacion_abono_parcial') { // Documento "Cancelación de abono parcial". Mostramos las SLIs canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Linea_De_Servicio_Padre__c,
                    ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.Name,
                    ONE_Producto__r.ONE_Categoria__r.Name,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_Parcial__c = : abonoParcialId
                    AND one_suplido__c = false
                    AND ONE_Numero_SLI_Padre__c != NULL 
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);   
        }
        
        return returnLineas;
    }

    // Query all the ONE_Expediente_Line_Item__c based on an input ONE_Presupuesto__c ID, line not canceled and with discount
    public static List<ONE_Expediente_Line_Item__c> getAllDescuentosLineItems (Id presupuestoId){
        return new List<ONE_Expediente_Line_Item__c>([
            SELECT ONE_Cantidad__c,
                ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
            	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                ONE_Importe_Base__c,
                ONE_Impuesto__c,
                ONE_Importe_Neto__c,
                ONE_Precio__c,
                ONE_Importe_Descuento_Posicion__c,
                ONE_Importe_Impuesto__c,
                ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                ONE_Texto_Banda_O_Lazo__c,
            	ONE_Numero_SLI__c,
                ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
            FROM   ONE_Expediente_Line_Item__c
            WHERE  ONE_Presupuesto__c = : presupuestoId
                AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                AND (ONE_Producto__r.ONE_Codigo_Comercial__c = '1000005886'
                OR ONE_Producto__r.ONE_Codigo_Comercial__c = '600004599')
        ]);
    }

    // Query all the ONE_Expediente_Line_Item__c based on an input ONE_Presupuesto__c ID that also are suplidos, line not canceledn and no discount
    public static List<ONE_Expediente_Line_Item__c> getAllSuplidosLineItems (Id presupuestoId){
        return new List<ONE_Expediente_Line_Item__c>([
            SELECT ONE_Cantidad__c,
                ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
            	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                ONE_Importe_Base__c,
                ONE_Impuesto__c,
                ONE_Importe_Neto__c,
                ONE_Precio__c,
                ONE_Importe_Descuento_Posicion__c,
                ONE_Importe_Impuesto__c,
                ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                ONE_Texto_Banda_O_Lazo__c,
                ONE_Numero_SLI__c,
                ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
            FROM   ONE_Expediente_Line_Item__c
            WHERE  ONE_Presupuesto__c = : presupuestoId
                AND ONE_Suplido__c = true
                AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
        ]);
    }

    // Query all the ONE_Expediente_Line_Item__c based on an input ONE_Orden_De_Venta__c ID  and has ONE_Codigo_Comercial__c = '1000005886'
    public static List<ONE_Expediente_Line_Item__c> getAllFacturaDescuentosLineItems (Id ordenDeVentaId){
        List<ONE_Expediente_Line_Item__c> returnLineas;
        String tipoDocumento = [Select ONE_tipoDocumento__c  from ONE_Orden_De_Venta__c where id =:ordenDeVentaId ].ONE_tipoDocumento__c;
        
        System.debug('tipoDocumento-->' + tipoDocumento);
        
        if(tipoDocumento == 'Abono'){ // For abono's document type we need to take Canceled ones, with discounts
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND (ONE_Producto__r.ONE_Codigo_Comercial__c = '1000005886'
                    OR ONE_Producto__r.ONE_Codigo_Comercial__c = '600004599')
            ]);            

        } else{ // not canceled with discount
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                    WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND (ONE_Producto__r.ONE_Codigo_Comercial__c = '1000005886'
                    OR ONE_Producto__r.ONE_Codigo_Comercial__c = '600004599')
            ]);            
        }
                
        return returnLineas;
    }

    // Query all the ONE_Expediente_Line_Item__c based on an input ONE_Orden_De_Venta__c ID  that are/or not canceled or the product related has comercial code 1000005886      
    public static List<ONE_Expediente_Line_Item__c> getAllFacturaSuplidosLineItems (Id ordenDeVentaId){
        
        List<ONE_Expediente_Line_Item__c> returnLineas;
        String tipoDocumento = [Select ONE_tipoDocumento__c  from ONE_Orden_De_Venta__c where id =:ordenDeVentaId ].ONE_tipoDocumento__c;
        
        System.debug('tipoDocumento-->' + tipoDocumento);
        
        if(tipoDocumento == 'Abono'){ // For abono's document type we need to take Canceled ones
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND ONE_Suplido__c = true
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);    
        }else{ //Not canceled, not discount
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Orden_De_Venta__c = : ordenDeVentaId
                    AND ONE_Suplido__c = true
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                	AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Eliminado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);     
        }
        return returnLineas;
    }

    // Query all the ONE_Expediente_Line_Item__c based on an input ONE_Abono_Parcial__c ID  and has ONE_Codigo_Comercial__c = '1000005886'
    public static List<ONE_Expediente_Line_Item__c> getAllAbonoParcialDescuentosLineItems (Id abonoParcialId, String documentType) {
        List<ONE_Expediente_Line_Item__c> returnLineas;
        
        System.debug('documentType-->' + documentType);
        
        if(documentType == 'factura_rectificativa') { // Documento "Factura rectificativa". Mostramos las SLIs no canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_parcial__c = : abonoParcialId
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                    AND (ONE_Producto__r.ONE_Codigo_Comercial__c = '1000005886'
                    OR ONE_Producto__r.ONE_Codigo_Comercial__c = '600004599')
            ]);            

        }
        else if (documentType == 'cancelacion_abono_parcial') { // Documento "Cancelación de abono parcial". Mostramos las SLIs canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_parcial__c = : abonoParcialId
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado'
                    AND (ONE_Producto__r.ONE_Codigo_Comercial__c = '1000005886'
                    OR ONE_Producto__r.ONE_Codigo_Comercial__c = '600004599')
            ]);            
        }
                
        return returnLineas;
    }

    // Query all the ONE_Expediente_Line_Item__c based on an input ONE_Abono_Parcial__c ID  that are/or not canceled or the product related has comercial code 1000005886      
    public static List<ONE_Expediente_Line_Item__c> getAllAbonoParcialSuplidosLineItems (Id abonoParcialId, String documentType){
        
        List<ONE_Expediente_Line_Item__c> returnLineas;
        
        System.debug('documentType-->' + documentType);
        
        if(documentType == 'factura_rectificativa') { // Documento "Factura rectificativa". Mostramos las SLIs no canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_parcial__c = : abonoParcialId
                    AND ONE_Suplido__c = true
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c != 'Cancelado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                	AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);    
        }
        else if (documentType == 'cancelacion_abono_parcial') { // Documento "Cancelación de abono parcial". Mostramos las SLIs canceladas e ignoramos los descuentos.
            returnLineas = new List<ONE_Expediente_Line_Item__c>([
                SELECT ONE_Cantidad__c,
                    ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                    ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                    ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                	ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                    ONE_Importe_Base__c,
                    ONE_Impuesto__c,
                    ONE_Importe_Neto__c,
                    ONE_Precio__c,
                    ONE_Importe_Descuento_Posicion__c,
                    ONE_Importe_Impuesto__c,
                    ONE_Presupuesto__r.ONE_Expediente__r.ONE_Centro_del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                    ONE_Texto_Banda_O_Lazo__c,
                    ONE_Numero_SLI__c,
                    ONE_Numero_SLI_Padre__c,
            	ONE_Orden_De_Venta__r.Recordtype.Developername,
            	ONE_Expediente__r.Name,
            	ONE_Expediente__r.ONE_Difunto__r.Name,
            	ONE_Expediente__r.ONE_Numero_de_Siniestro__c
                FROM   ONE_Expediente_Line_Item__c
                WHERE  ONE_Abono_parcial__c = : abonoParcialId
                    AND ONE_Suplido__c = true
                    AND ONE_Expediente_Line_Item__c.ONE_Estado__c = 'Cancelado'
                    AND ONE_Producto__r.ONE_Codigo_Comercial__c != '1000005886'
                	AND ONE_Producto__r.ONE_Codigo_Comercial__c != '600004599'
            ]);     
        }
        return returnLineas;
    }
}
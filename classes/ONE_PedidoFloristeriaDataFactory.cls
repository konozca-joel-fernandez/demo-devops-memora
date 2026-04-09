public with sharing class ONE_PedidoFloristeriaDataFactory { 

    //Method to call all queryes to get the data and generate the data structure for the PDF 
    public static ONE_PedidoFloristeriaPdfService.FloristeriaData buildData(Id pedidoId, String language) {

        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);
        
        string logo = pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;

        ONE_PdfServiceBase.HeaderData headerData = new ONE_PdfServiceBase.HeaderData(
                pedido?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Name,
                null,
                pedido?.ONE_Expediente__r?.Owner.FirstName + ' ' + pedido?.ONE_Expediente__r?.Owner.LastName, 
                pedido?.Name,
                pedido?.ONE_Hora_De_Envio__c?.format(),	
                pedido?.ONE_Proveedor__r?.Name,
                pedido?.ONE_Expediente__r?.Name,
                pedido.ONE_Expediente__r?.ONE_Difunto__r?.FirstName + ' ' + pedido?.ONE_Expediente__r?.ONE_Difunto__r?.LastName,
                logo,
                pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name
        );

        headerData.lugarDeVelacion = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.Name) + ' - '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Velacion__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Velacion__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Velacion__c);
        if (pedido?.ONE_Expediente__r?.ONE_Tipo_De_Lugar_De_Velacion__c == 'Externo') {
            headerData.salaVelacion = pedido?.ONE_Expediente__r?.Numero_Sala_Velacion_Ext__c;
        }
        else {
            headerData.salaVelacion = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Sala_De_Velacion__r?.ONE_Numero_De_Sala__c);
        }
        headerData.fechaHoraVelacion = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Velacion__c?.format());
        headerData.lugarDeCeremonia = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name) + ' - '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Ceremonia__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Ceremonia__c);
        headerData.fechaHoraCeremonia = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c?.format());

        ONE_PedidoFloristeriaPdfService.FloristeriaData floresData = new ONE_PedidoFloristeriaPdfService.FloristeriaData(language, headerData);
        floresData.logoUrl = logo;
        floresData.documentCode = getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PEDIDO_FLORES);

        List<ONE_Tarea__c> tareas = selectTarea(pedidoId, '');
        floresData.tareaData = new List<ONE_PedidoFloristeriaPdfService.TareaData>();

        for (Integer i = 0; i < tareas.size(); i++) {
            ONE_Tarea__c tarea = tareas.get(i);
            ONE_PedidoFloristeriaPdfService.TareaData tareaItem = new ONE_PedidoFloristeriaPdfService.TareaData();

            tareaItem.id = i + 1;

            tareaItem.lugarDeEntrega = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Lugar__r.Name) + ' - '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Direccion__c) + ' '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Municipio__c)  + ' '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Provincia__c) + ' '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Pais__c);      
            tareaItem.sala = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Sala__r?.Name);
            
            if (tarea.ONE_Modelo__c != null){
                tareaItem.materialContratado = 
                	language == 'CA'
                    	? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Catalan__c) + ' - ' + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Modelo__r?.ONE_Nombre_CAT__c)
                    	:language == 'EU'
                            ? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Euskera__c) + ' - ' + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Modelo__r?.ONE_Nombre_EUS__c)
                            : ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c) + ' - ' + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Modelo__r?.ONE_Nombre_ESP__c);
            } else {
                tareaItem.materialContratado = 
                	language == 'CA'
                    	? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Catalan__c)
                    	:language == 'EU'
                            ? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Euskera__c)
                            :ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c);
            }
            tareaItem.unidades = tarea?.ONE_Cantidad__c;
            tareaItem.fecha = tarea?.ONE_Fecha_Y_Hora__c?.format();
            tareaItem.observaciones = tarea?.ONE_Comentarios__c;
            tareaItem.cinta = tarea?.ONE_Tarjeta_O_Lazo__c;
            tareaItem.lazo = tarea?.ONE_Texto_Banda_O_Lazo__c;

            floresData.tareaData.add(tareaItem);
        }

        return floresData;
    }
    //Query to get document code to display into the document header    
    private static String getDocumentCode(String mtName) {
        return [
                SELECT Label
                FROM ONE_Codigo_de_documento__mdt
                WHERE DeveloperName = :mtName
        ].Label;
    }
    
    //Method to query tareas data
    public static List<ONE_Tarea__c> selectTarea(Id pedidoId, String type) {
        return [
                SELECT ONE_Lugar__r.Name,
                        ONE_Sala__r.Name,
                        ONE_Producto__r.Name,
            			ONE_Modelo__c,
            			ONE_Modelo__r.ONE_Nombre_CAT__c,
            			ONE_Modelo__r.ONE_Nombre_EUS__c,
            			ONE_Modelo__r.ONE_Nombre_ESP__c,
                        ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                        ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                        ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                        ONE_Cantidad__c,
                        ONE_Comentarios__c,
                        ONE_Direccion__c,
                        ONE_Municipio__c ,
                        ONE_Provincia__c,
                        ONE_Codigo_Postal__c,
                        ONE_Pais__c,
            			ONE_Fecha_Y_Hora__c,
            			ONE_Tarjeta_O_Lazo__c,
            			ONE_Texto_Banda_O_Lazo__c
                FROM  ONE_Tarea__c
                WHERE ONE_Pedido_De_Proveedor__c = :pedidoId
        ];
    }
	//Method to query pedido de proveedor data
    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedor(Id pedidoId) {
        return [
                SELECT Id,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                       ONE_Expediente__r.Owner.FirstName,
                       ONE_Expediente__r.Owner.LastName,
                       Name,
                       ONE_Fecha__c,
                       ONE_Proveedor__r.Name,
                       ONE_Expediente__r.Name,
                       ONE_Expediente__r.ONE_Difunto__r.FirstName,
                       ONE_Expediente__r.ONE_Difunto__r.LastName,
            		   ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            		   ONE_Hora_De_Envio__c,
                       ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
                       ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                       ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                       ONE_Expediente__r.ONE_Provincia_Ceremonia__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c,
                       ONE_Expediente__r.ONE_Inicio_Ceremonia__c,
                       ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name,
                       ONE_Expediente__r.ONE_Lugar_De_Velacion__c,
                       ONE_Expediente__r.ONE_Direccion_Velacion__c,
                       ONE_Expediente__r.ONE_Municipio_Velacion__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_Velacion__c,
                       ONE_Expediente__r.ONE_Inicio_Velacion__c,
                       ONE_Expediente__r.ONE_Sala_De_Velacion__r.ONE_Numero_De_Sala__c,
                       ONE_Expediente__r.ONE_Tipo_De_Lugar_De_Velacion__c,
                       ONE_Expediente__r.Numero_Sala_Velacion_Ext__c
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }

}
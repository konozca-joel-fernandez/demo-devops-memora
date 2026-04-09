public with sharing class ONE_PedidoMusicaDataFactory {
 
    public static ONE_PedidoMusicaPdfService.MusicaData buildData(Id pedidoId, String language) {
		
        System.debug('pedidoId--> ' + pedidoId);
        System.debug('language--> ' + language);

        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);

        string logo = pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        
        ONE_PdfServiceBase.HeaderData headerData = new ONE_PdfServiceBase.HeaderData(
                pedido?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Name,
                null,
                pedido?.ONE_Expediente__r?.Owner.FirstName + ' ' + pedido?.ONE_Expediente__r?.Owner.LastName,
                pedido?.Name,
                String.valueOf(pedido?.ONE_Fecha__c?.format()),
                pedido?.ONE_Proveedor__r?.Name,
                pedido?.ONE_Expediente__r?.Name,
                pedido.ONE_Expediente__r?.ONE_Difunto__r?.FirstName + ' ' + pedido?.ONE_Expediente__r?.ONE_Difunto__r?.LastName,
                logo,
                pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name
        );

        ONE_PedidoMusicaPdfService.MusicaData musicaData = new ONE_PedidoMusicaPdfService.MusicaData(
            language,
            headerData,
            ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r?.ONE_Declarante__r?.FirstName) + ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r?.ONE_Declarante__r?.LastName),
            pedido.ONE_Expediente__r?.ONE_Declarante__r?.PersonEmail,
            pedido.ONE_Expediente__r?.ONE_Declarante__r?.PersonHomePhone
        );
        musicaData.logoUrl = logo;
        musicaData.documentCode = getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PEDIDO_MUSICA);
        
        List<ONE_Tarea__c> tareas = selectTarea(pedidoId, ONE_CommonConstants.TAREA_TYPE_MUSICA);
        musicaData.tareaData = new List<ONE_PedidoMusicaPdfService.TareaData>();

        for (Integer i = 0; i < tareas.size(); i++) {
            ONE_Tarea__c tarea = tareas.get(i);
            ONE_PedidoMusicaPdfService.TareaData tareaItem = new ONE_PedidoMusicaPdfService.TareaData();

            tareaItem.id = i + 1;
			
            tareaItem.materialContratado = 
                language == 'CA'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Catalan__c):
            	language == 'EU'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Euskera__c):
                ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c);
            tareaItem.cantidad = tarea?.ONE_Cantidad__c;
            tareaItem.piezas = tarea?.ONE_Piezas_Seleccionadas__c;
            tareaItem.fecha = String.valueOf(tarea?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c?.format());    
            tareaItem.direccion = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name) + ' - '
                + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Ceremonia__c) + ' '
                + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c)+ ' '
                + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Ceremonia__c) + ' - '
                + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Sala_Ceremonia__r?.Name);
       
            tareaItem.observaciones = tarea.ONE_Comentarios__c;

            musicaData.tareaData.add(tareaItem);
        }

        return musicaData;
    }

    private static String getDocumentCode(String mtName) {
        return [
                SELECT Label
                FROM ONE_Codigo_de_documento__mdt
                WHERE DeveloperName = :mtName
        ].Label;
    }


    public static List<ONE_Tarea__c> selectTarea(Id pedidoId, String type) {
        return [
                SELECT
                        ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
                        ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                        ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                        ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c,
                        ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                        ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                        ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                        ONE_Cantidad__c,
                        ONE_Piezas_Seleccionadas__c,
                        ONE_Comentarios__c,
                        ONE_Expediente__r.ONE_Inicio_Ceremonia__c
                FROM  ONE_Tarea__c
                WHERE ONE_Pedido_De_Proveedor__c = :pedidoId
                    AND
                      ONE_Tipo_De_Pedido__c = :type
        ];
    }

    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedor(Id pedidoId) {
        System.debug('selectPedidoDeProveedorID-->' + pedidoId);
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
            		   ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
            		   ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                       ONE_Expediente__r.ONE_Municipio_Ceremonia__c, 
                       ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c, 
                       ONE_Expediente__r.ONE_Declarante__r.FirstName,
                       ONE_Expediente__r.ONE_Declarante__r.LastName,
                       ONE_Expediente__r.ONE_Declarante__r.PersonEmail,
                       ONE_Expediente__r.ONE_Declarante__r.PersonHomePhone,
            		   ONE_Expediente__r.ONE_Sala_Ceremonia__r.Name
            
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }

}
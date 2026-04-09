public with sharing class ONE_PedidoCateringDataFactory {

    public static ONE_PedidoCateringPdfService.CateringData buildData(Id pedidoId, String language) {
		//Query to get pedido de proveedor
        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);
		
        //Generate header data
        
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

        headerData.lugarDeVelacion = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.Name) + ' - '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Velacion__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Velacion__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Velacion__c);
        headerData.salaVelacion = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Sala_De_Velacion__r?.ONE_Numero_De_Sala__c);
        headerData.fechaHoraVelacion = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Velacion__c?.format());
        headerData.lugarDeCeremonia = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name) + ' - '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Ceremonia__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Ceremonia__c);
        headerData.fechaHoraCeremonia = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c?.format());

        ONE_PedidoCateringPdfService.CateringData cateringData = new ONE_PedidoCateringPdfService.CateringData(language, headerData);
        cateringData.logoUrl = logo;
        cateringData.documentCode = getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PEDIDO_CATERING);

        List<ONE_Tarea__c> tareas = selectTarea(pedidoId, ONE_CommonConstants.TAREA_TYPE_CATERING);
        cateringData.tareaData = new List<ONE_PedidoCateringPdfService.TareaData>();

        for (Integer i = 0; i < tareas.size(); i++) {
            ONE_Tarea__c tarea = tareas.get(i);
            ONE_PedidoCateringPdfService.TareaData tareaItem = new ONE_PedidoCateringPdfService.TareaData();

            tareaItem.id = i + 1;

            tareaItem.lugarDeEntrega = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Lugar__r.Name) + ' - '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Direccion__c) + ' '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Municipio__c)  + ' '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Provincia__c) + ' '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Pais__c);      
            tareaItem.sala = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Sala__r?.Name);
            tareaItem.materialContratado = 
                language == 'CA'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Catalan__c):
            	language == 'EU'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Euskera__c):
            	language == 'EN_US'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Ingles__c):
            	ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c);
            tareaItem.unidades = tarea?.ONE_Cantidad__c;
            tareaItem.fecha = tarea?.ONE_Fecha_Y_Hora__c?.format();
            tareaItem.observaciones = tarea?.ONE_Comentarios__c;

            cateringData.tareaData.add(tareaItem);
        }

        return cateringData;
    }
	//Query to select documento code that should be display
    private static String getDocumentCode(String mtName) {
        return [
                SELECT Label
                FROM ONE_Codigo_de_documento__mdt
                WHERE DeveloperName = :mtName
        ].Label;
    }
	//Query to select ONE_Pedido_De_Proveedor__c data for a particular type
    public static List<ONE_Tarea__c> selectTarea(Id pedidoId, String type) {
        return [
                SELECT ONE_Lugar__r.Name,
                        ONE_Sala__r.Name,
                        ONE_Producto__r.Name,
                        ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                        ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                        ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
            			ONE_Producto__r.ONE_Descripcion_En_Ingles__c,
                        ONE_Cantidad__c,
                        ONE_Comentarios__c,
                        ONE_Direccion__c,
                        ONE_Municipio__c ,
                        ONE_Provincia__c,
                        ONE_Codigo_Postal__c,
                        ONE_Pais__c,
            			ONE_Fecha_Y_Hora__c
                FROM  ONE_Tarea__c
                WHERE ONE_Pedido_De_Proveedor__c = :pedidoId
                    AND
                      ONE_Tipo_De_Pedido__c = :type
        ];
    }
	//Query to select ONE_Pedido_De_Proveedor__c data
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
                       ONE_Expediente__r.ONE_Sala_De_Velacion__r.ONE_Numero_De_Sala__c
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }

}
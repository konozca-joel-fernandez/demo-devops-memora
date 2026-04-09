public with sharing class ONE_PedidoVehiculoDataFactory { 
	//Get all the data and store in the Data object created
    public static ONE_PedidoVehiculoPdfService.VehiculoData buildData(Id pedidoId, String language) {

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
                pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name);


        if (String.isNotBlank(pedido.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__r?.Name)) {
            headerData.domicilioMortuorio = pedido.ONE_Expediente__r?.ONE_Direccion_De_Defuncion__c;
        } else {
            headerData.domicilioMortuorio = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.Name) + ' - '
                    + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Velacion__c) + ', '
                    + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Velacion__c);
        }
        headerData.lugarDeVelacion = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.Name) + ' - '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Velacion__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Velacion__c) + ', '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Velacion__c);
        headerData.fechaHoraVelacion = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Velacion__c?.format());
        headerData.lugarDeCeremonia = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name) + ' - '
                + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Ceremonia__c) + ', '
                + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c) + ', '
                + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Ceremonia__c);
        headerData.fechaHoraCeremonia = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c?.format());
        headerData.lugarDestinoFinal = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Destino_Final__r?.Name);
        headerData.fechaHoraDestino = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Hora_Destino_Final__c?.format());

        ONE_PedidoVehiculoPdfService.VehiculoData vehiculoData = new ONE_PedidoVehiculoPdfService.VehiculoData(language, headerData);
        vehiculoData.logoUrl = logo;
        vehiculoData.documentCode = getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PEDIDO_VEHICULOS);

        List<ONE_Tarea__c> tareas = selectTarea(pedidoId, ONE_CommonConstants.TAREA_TYPE_VEHICULO);
        vehiculoData.tareaData = new List<ONE_PedidoVehiculoPdfService.TareaData>();

        for (Integer i = 0; i < tareas.size(); i++) {
            ONE_Tarea__c tarea = tareas.get(i);
            ONE_PedidoVehiculoPdfService.TareaData tareaItem = new ONE_PedidoVehiculoPdfService.TareaData();

            tareaItem.id = i + 1;
            tareaItem.materialContratado = 
                language == 'CA'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Catalan__c):
            	language == 'EU'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Euskera__c):
            	ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c);
            tareaItem.cantidad = String.valueOf(tarea?.ONE_Cantidad__c);
            tareaItem.fecha = String.valueOf(tarea?.ONE_Fecha_Y_Hora__c?.format());
			tareaItem.origen = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Lugar_De_Origen__r.Name) + ' - '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Direccion_Origen__c) + ', '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Municipio_Origen__c) + ', '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Codigo_Postal_Origen__c);
            tareaItem.destino = 
                ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Lugar_De_Destino__r?.Name) + ' - '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Direccion_De_Destino__c) + ', '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Municipio_Destino__c) + ', '
                + ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Codigo_Postal_Destino__c);
            
            tareaItem.observacionesOrigen = tarea?.ONE_Comentarios_Adicionales_Origen__c;
            tareaItem.observacionesDestino = tarea?.ONE_Comentarios_Adicionales_Destino__c;
            tareaItem.comentarios = tarea?.ONE_Comentarios__c;

            vehiculoData.tareaData.add(tareaItem);
        }

        //we add DeclaranteData
        vehiculoData.declaranteData = new ONE_PedidoVehiculoPdfService.DeclaranteData();
        vehiculoData.declaranteData.name = pedido?.ONE_Expediente__r?.ONE_Declarante__r?.Name;
        vehiculoData.declaranteData.phone = pedido?.ONE_Expediente__r?.ONE_Telefono_Del_Declarante__c;
        vehiculoData.declaranteData.email = pedido?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Email__c;


        return vehiculoData;
    }
	//Query document code from a custom metada type to display it in the PDF header
    private static String getDocumentCode(String mtName) {
        return [
                SELECT Label
                FROM ONE_Codigo_de_documento__mdt
                WHERE DeveloperName = :mtName
        ].Label;
    }
	//Query tarea data
    public static List<ONE_Tarea__c> selectTarea(Id pedidoId, String type) {
        return [
                SELECT ONE_Producto__r.ONE_Descripcion_En_Castellano__c,
                        ONE_Producto__r.ONE_Descripcion_En_Catalan__c,
                        ONE_Producto__r.ONE_Descripcion_En_Euskera__c,
                        ONE_Cantidad__c,
                        ONE_Fecha_Y_Hora__c,
                        ONE_Lugar_De_Origen__r.Name,
                        ONE_Direccion_Origen__c,
                        ONE_Municipio_Origen__c,
                        ONE_Codigo_Postal_Origen__c,
                        ONE_Expediente__r.ONE_Difunto__r.FirstName,
                        ONE_Expediente__r.ONE_Difunto__r.LastName,
                        ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.Name,
                        ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
                        ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,
                        ONE_Expediente__r.ONE_Codigo_Postal_De_Defuncion__c,
                        ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                        ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                        ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                        ONE_Expediente__r.ONE_Provincia_Ceremonia__c,
                        ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c,
                        ONE_Expediente__r.ONE_Inicio_Ceremonia__c ,
                        ONE_Expediente__r.ONE_Destino_Final__r.ONE_Lugar_De_Entrega__c,
                        ONE_Expediente__r.ONE_Hora_Destino_Final__c,
                        ONE_Lugar_De_Destino__r.Name,
                        ONE_Direccion_De_Destino__c,
                        ONE_Municipio_Destino__c,
                        ONE_Codigo_Postal_Destino__c,
            			ONE_Comentarios_Adicionales_Origen__c,
            			ONE_Comentarios_Adicionales_Destino__c,
                        ONE_Comentarios__c,
            			ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name,
            			ONE_Expediente__r.ONE_Lugar_De_Velacion__c,
            			ONE_Expediente__r.ONE_Direccion_Velacion__c,
            			ONE_Expediente__r.ONE_Municipio_Velacion__c
                FROM  ONE_Tarea__c
                WHERE ONE_Pedido_De_Proveedor__c = :pedidoId
                    AND
                      ONE_Tipo_De_Pedido__c = :type
        ];
    }
	//Query pedido de proveedor data
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
                       ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.Name,
                       ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
                       ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_De_Defuncion__c,
                       ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                       ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                       ONE_Expediente__r.ONE_Provincia_Ceremonia__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c,
                       ONE_Expediente__r.ONE_Inicio_Ceremonia__c ,
                       ONE_Expediente__r.ONE_Destino_Final__r.Name,
                       ONE_Expediente__r.ONE_Hora_Destino_Final__c,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Idioma_De_Comunicacion__c,
                       ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name,
                       ONE_Expediente__r.ONE_Lugar_De_Velacion__c,
                       ONE_Expediente__r.ONE_Direccion_Velacion__c,
                       ONE_Expediente__r.ONE_Municipio_Velacion__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_Velacion__c,
                       ONE_Expediente__r.ONE_Inicio_Velacion__c,
            		   ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
                       ONE_Expediente__r.ONE_Declarante__r.Name,
                       ONE_Expediente__r.ONE_Telefono_Del_Declarante__c,
                       ONE_Expediente__r.ONE_Declarante__r.ONE_Email__c
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }

}
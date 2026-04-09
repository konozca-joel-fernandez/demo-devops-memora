public with sharing class ONE_PedidoMesaFirmasPdfController {

    Id pedidoId {get; set;}
    Id expedienteId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoMesaFirmasPdfService.MesaFirmasData data {public get; private set;}

    public ONE_PedidoMesaFirmasPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {
        
        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);

        ONE_PdfServiceBase.HeaderData headerData = new ONE_PdfServiceBase.HeaderData(
                pedido?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Name,
                null,
                pedido?.ONE_Expediente__r?.Owner.FirstName + ' ' + pedido?.ONE_Expediente__r?.Owner.LastName, 
                pedido?.Name,
                pedido?.ONE_Hora_De_Envio__c?.format(),	
                pedido?.ONE_Proveedor__r?.Name,
                pedido?.ONE_Expediente__r?.Name,
                pedido.ONE_Expediente__r?.ONE_Difunto__r?.FirstName + ' ' + pedido?.ONE_Expediente__r?.ONE_Difunto__r?.LastName,
                pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c,
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
        

        ONE_PedidoMesaFirmasPdfService.MesaFirmasData dataMesaFirmas = new ONE_PedidoMesaFirmasPdfService.MesaFirmasData (language, headerData);

        dataMesaFirmas.logoUrl = pedido?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;

        dataMesaFirmas.documentCode = '';


        //rellenar info momentos
        dataMesaFirmas.momentosData = new ONE_PedidoMesaFirmasPdfService.MomentosData();
        
        dataMesaFirmas.momentosData.lugarDespedida = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Despedida__r?.Name);
        dataMesaFirmas.momentosData.fechaHoraDespedida = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Despedida__c?.format());

        //rellenar campos tarea de mesa firmas
        ONE_Tarea__c t = selectTarea(pedidoId);

        dataMesaFirmas.tarea = new ONE_PedidoMesaFirmasPdfService.TareaData();

        dataMesaFirmas.tarea.producto = t.ONE_Producto__r?.Name;
        dataMesaFirmas.tarea.cantidad = t.ONE_Cantidad__c;
        dataMesaFirmas.tarea.comentarios = t.ONE_Comentarios__c;
        

        //set expedienteId
        expedienteId = pedido?.ONE_Expediente__c;

        List<ONE_Expediente_Line_Item__c> slis = selectSLIs(expedienteId);

        //lista de SLIs de flores
        dataMesaFirmas.slisFloresData = new List<ONE_PedidoMesaFirmasPdfService.SLIData>();
        //lista de SLIs de recordatorios
        dataMesaFirmas.slisRecordatoriosData = new List<ONE_PedidoMesaFirmasPdfService.SLIData>();

        for (Integer i = 0; i < slis.size(); i++) {
            ONE_Expediente_Line_Item__c sli = slis.get(i);
            ONE_PedidoMesaFirmasPdfService.SLIData sliItem = new ONE_PedidoMesaFirmasPdfService.SLIData();

            sliItem.productoSLI = sli.ONE_Nombre_del_Producto__c;
            sliItem.cantidadSLI = sli.ONE_Cantidad__c;
            sliItem.comentariosSLI = sli.ONE_Comentarios__c;

            //system.debug(sliItem);

            if (sli.ONE_Orden_Momento__c == '4 - Arte Floral') {
                dataMesaFirmas.slisFloresData.add(sliItem);
            }
            else {
                dataMesaFirmas.slisRecordatoriosData.add(sliItem);
            }
            
        }

        //check if lists are empty
        dataMesaFirmas.floresEmpty = false;
        dataMesaFirmas.recordatorioEmpty = false;
        
        if (dataMesaFirmas.slisFloresData.size() == 0) {
            dataMesaFirmas.floresEmpty = true;
        }
        if (dataMesaFirmas.slisRecordatoriosData.size() == 0) {
            dataMesaFirmas.recordatorioEmpty = true;
        }


        this.data = dataMesaFirmas;
        
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
                       ONE_Expediente__r.Numero_Sala_Velacion_Ext__c,
                       ONE_Expediente__r.ONE_Lugar_Despedida__r.Name,
                       ONE_Expediente__r.ONE_Inicio_Despedida__c
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }

    //Method to query tarea data
    public static ONE_Tarea__c selectTarea(Id pedidoId) {
        return [
                SELECT ONE_Lugar__r.Name,
                        ONE_Sala__r.Name,
                        ONE_Producto__r.Name,
                        ONE_Modelo__c,
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
                LIMIT 1
        ];
    }


    //Method to query slis data
    public static List<ONE_Expediente_Line_Item__c> selectSLIs(Id expedienteId) {
        return [
                SELECT Id,
                    ONE_Nombre_del_Producto__c,
                    ONE_Cantidad__c,
                    ONE_Comentarios__c,
                    ONE_Orden_Momento__c
                FROM  ONE_Expediente_Line_Item__c
                WHERE ONE_Expediente__c = :expedienteId AND
                (ONE_Nombre_del_Producto__c LIKE '%Recordatorio%' OR ONE_Orden_Momento__c = '4 - Arte Floral') AND
                ONE_Estado__c <> 'Cancelado' AND
                ONE_Estado__c <> 'Eliminado' 
        ];
    }

}
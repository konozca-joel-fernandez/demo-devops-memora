/**
* File Name: ONE_PedidoRecordatorioPdfController
* Description: 	Controller of the VisualForce Page ONE_PedidoRecordatorioPdf
* Date: 02/04/2025
*
* Copyright: Konozca Consulting
* @author: Marc Cervilla
* Test: ONE_PedidoRecordatorioPdfControllerTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		02/04/2025		Marc Cervilla  		Class creation
* ===================================================================================================================
*/

public with sharing class ONE_PedidoRecordatorioPdfController {

    Id pedidoId {get; set;}
    public String language {public get; private set;}
    public ONE_PedidoRecordatorioPdfService.RecordatorioData data {public get; private set;}

    public ONE_PedidoRecordatorioPdfController() {
        pedidoId = ApexPages.currentPage().getParameters().get('pedidoId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }

    public void setupData() {

        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);

        string logo = pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
        ? pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
        : pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;

        ONE_PdfServiceBase.HeaderData headerData = new ONE_PdfServiceBase.HeaderData(
                pedido?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Name,
                null,
                //get running user name
                getRunningUserName(),
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

        this.data = new ONE_PedidoRecordatorioPdfService.RecordatorioData(language, headerData);

        this.data.documentCode = '';

        // Rellenar info momentos
        this.data.momentosData = new ONE_PedidoRecordatorioPdfService.MomentosData();

        this.data.momentosData.lugarDespedida = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Despedida__r?.Name);
        this.data.momentosData.fechaHoraDespedida = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Despedida__c?.format());
        this.data.momentosData.lugarDeposito = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_De_Deposito__r?.Name);
        this.data.momentosData.fechaHoraDeposito = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Deposito__c?.format());

        // TareaData

        this.data.tareaData = new List<ONE_PedidoRecordatorioPdfService.TareaData>();

        List<ONE_Tarea__c> tareas = selectTarea(pedidoId);

        for (Integer i = 0; i < tareas.size(); i++) {
            ONE_Tarea__c tarea = tareas.get(i);
            ONE_PedidoRecordatorioPdfService.TareaData tareaItem = new ONE_PedidoRecordatorioPdfService.TareaData();

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
            	ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c);
            tareaItem.unidades = tarea?.ONE_Cantidad__c;
            tareaItem.fecha = tarea?.ONE_Fecha_Y_Hora__c?.format();
            tareaItem.observaciones = tarea?.ONE_Comentarios__c;

            this.data.tareaData.add(tareaItem);
        }
        
    }

    private static String getRunningUserName() {
        User currentUser = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.Name;
    }

    //Method to query tarea data
    public static List<ONE_Tarea__c> selectTarea(Id pedidoId) {
        return [
                SELECT ONE_Lugar__r.Name,
                        ONE_Sala__r.Name,
                        ONE_Producto__r.Name,
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
                        ONE_Fecha_Y_Hora__c
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
                       ONE_Expediente__r.Numero_Sala_Velacion_Ext__c,
                       ONE_Expediente__r.ONE_Lugar_Despedida__r.Name,
                       ONE_Expediente__r.ONE_Inicio_Despedida__c,
                       ONE_Expediente__r.ONE_Lugar_De_Deposito__r.Name,
                       ONE_Expediente__r.ONE_Inicio_Deposito__c
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }
}
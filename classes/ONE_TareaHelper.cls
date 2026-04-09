/**
 * Created by mbujak003 on 31.01.2021.
 */

public with sharing class ONE_TareaHelper {
    public static final String FUNEFLOR = 'Funeflor';

    //Helper to get Tareas by ID

    public static List<ONE_Tarea__c> fetchTareasByIds(Set<String> tareaIds) {
        return [
            SELECT Id, ONE_Pedido_De_Proveedor__r.Name, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                ONE_Proveedor__r.ONE_ID_Proveedor_SAP__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Organizacion_De_Compras__c,
                ONE_Pedido_De_Proveedor__r.ONE_Fecha__c, ONE_Pedido_De_Proveedor__r.ONE_Fecha_contabilizaci_n__c, ONE_Expediente__r.Name, ONE_Producto__r.Name, ONE_Precio_De_Compra__c,
                ONE_Producto__r.ONE_Codigo_SAP__c, ONE_Cantidad__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Moneda__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c, ONE_Posicion_Pedido__c
            FROM ONE_Tarea__c
            WHERE Id IN:tareaIds
        ];
    }

    //Helper to get Tareas by ID Pedido

    public static List<ONE_Tarea__c> fetchTareasByPedidoId(Set<String> pedidoIds) {
        return [
            SELECT Id, ONE_Pedido_De_Proveedor__r.Name, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                ONE_Proveedor__r.ONE_ID_Proveedor_SAP__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Organizacion_De_Compras__c,
                ONE_Pedido_De_Proveedor__r.ONE_Fecha__c, ONE_Pedido_De_Proveedor__r.ONE_Fecha_contabilizaci_n__c, ONE_Expediente__r.Name, ONE_Producto__r.Name, ONE_Precio_De_Compra__c,
                ONE_Producto__r.ONE_Codigo_SAP__c, ONE_Cantidad__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Moneda__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c, ONE_Posicion_Pedido__c, ONE_Pedido_De_Proveedor__c,
                ONE_Pedido_De_Proveedor__r.ONE_Codigo_Retorno_SAP__c, ONE_Pedido_De_Proveedor__r.ONE_Mensaje_Respuesta_SAP__c,
                ONE_Pedido_De_Proveedor__r.ONE_Proveedor__r.ONE_ID_Proveedor_SAP__c, ONE_Pedido_De_Proveedor__r.ONE_Expediente__r.Name,
                ONE_Pedido_De_Proveedor__r.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Moneda__c,
                ONE_Pedido_De_Proveedor__r.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Organizacion_De_Compras__c,
                ONE_Pedido_De_Proveedor__r.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                ONE_Aviso__r.ONE_Centro_del_Servicio__r.ONE_Sociedad__c,
                ONE_Aviso__r.ONE_Centro_del_Servicio__r.ONE_Organizacion_De_Compras__c,
                ONE_Aviso__r.ONE_Centro_del_Servicio__r.ONE_Moneda__c,
                ONE_Aviso__r.ONE_Centro_del_Servicio__r.ONE_Codigo_De_Centro__c
            FROM ONE_Tarea__c
            WHERE ONE_Pedido_De_Proveedor__c IN:pedidoIds
        ];
    }
    
    //This function is called from a Tarea trigger and is used to call Frotcom integration in case the task fullfill the requirements,
    // it get the required tareas and see if it is needed to send to Frotcom.
    
    public static List<Id> getTareaIdsToSendToFrotcom(List<ONE_Tarea__c> newTareas, Map<Id, ONE_Tarea__c> idToOldTarea) {
        List<Id> tareaIdsToSend = new List<Id>();
        for (ONE_Tarea__c tarea : newTareas) {
            ONE_Tarea__c oldTarea = idToOldTarea.get(tarea.Id);
            if (isTareaToSendToFrotcom(tarea, oldTarea)) {
                tareaIdsToSend.add(tarea.Id);
            }
        }

        return tareaIdsToSend;
    }

    //This function review if the task should be send to Frotcom

    public static Boolean isTareaToSendToFrotcom(ONE_Tarea__c newTarea, ONE_Tarea__c oldTarea) {
       
        return 
            !wasTareaSentToFrotcomAlready(newTarea, oldTarea) && // Check is task was already send to frotcom
            String.isBlank(newTarea?.ONE_ID_Tarea_Frotcom__c) && 
            (
                newTarea?.ONE_Mandar_A_Frotcom__c && !oldTarea?.ONE_Mandar_A_Frotcom__c || //Check ONE_Mandar_A_Frotcom__c has been set to TRUE
                (
                    (isTaskOfConduccionType(newTarea) && oldTarea == null) || //Task (Tarea) of record type Conducción has been created.-
                    (isTaskOfTaxiTypeAndRecursoType(newTarea) && oldTarea == null)|| //Task with record type vehiculo de acompañamiento and ONE_Tipo_De_Recurso__c equals to Conduccion newly created
                    (isTaskOfTaxiTypeAndRecursoType(newTarea) && !isTaskOfRecursoType(oldTarea)) //Task with record type vehiculo de acompañamiento and field ONE_Tipo_De_Recurso__c updated to Conduccion
                )
            );
            // ----------------------------------------------------------OLD LOGIC------------------------------------------------------------           
            //        return newTarea.RecordTypeId == conduccionRtId
            //            && oldTarea == null
            //            ||
            //            (newTarea.RecordTypeId == vehiculoDeAcompanamientoRtId
            //                && newTarea.ONE_Tipo_De_Recurso__c == ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION
            //                && (
            //                oldTarea == null
            //                    || oldTarea.ONE_Tipo_De_Recurso__c != ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION
            //            )
            //            ) && wasTareaSentToFrotcomAlready(newTarea, oldTarea);
            //    }
            // ----------------------------------------------------------OLD LOGIC------------------------------------------------------------           
    }
    
    //Check if the task has ONE_Tipo_De_Recurso__c = TIPO_DE_RECURSO_CONDUCCION

    static Boolean isTaskOfRecursoType(ONE_Tarea__c task) {
        return task?.ONE_Tipo_De_Recurso__c == ONE_CommonConstants.TIPO_DE_RECURSO_CONDUCCION;
    }

    //Check if the task has RecordType = TAREA_RT_TAREA_DE_VEHICULO_DE_ACOMPANIAMIENTO and ONE_Tipo_De_Recurso__c = TIPO_DE_RECURSO_CONDUCCION

    static Boolean isTaskOfTaxiTypeAndRecursoType(ONE_Tarea__c task) {
        return isTaskOfTaxiType(task) && isTaskOfRecursoType(task);
    }

    //Check if the task has RecordType = TAREA_RT_TAREA_DE_VEHICULO_DE_ACOMPANIAMIENTO

    static Boolean isTaskOfTaxiType(ONE_Tarea__c task) {
        return task.RecordTypeId == ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_VEHICULO_DE_ACOMPANIAMIENTO);
    }

    //Check if the task has RecordType = TAREA_RT_TAREA_DE_CONDUCCION

    static Boolean isTaskOfConduccionType(ONE_Tarea__c task) {
        return task.RecordTypeId == ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_CONDUCCION);
    }
    
    //Check if the task was send to Frotcom already, checking ONE_ID_Tarea_Frotcom__c = null

    static Boolean wasTareaSentToFrotcomAlready(ONE_Tarea__c newTarea, ONE_Tarea__c oldTarea) {
        return String.isBlank(oldTarea?.ONE_ID_Tarea_Frotcom__c) == null && String.isNotBlank(newTarea?.ONE_ID_Tarea_Frotcom__c);
    }
    
    //Call Frotcom integration for the ID's indicated
    public static void sendTareas(List<Id> tareaIds) {
        /* if (!tareaIds.isEmpty()) {
             ONE_FrotcomIntegrationService.sendTasks(tareaIds);
         }*/
        for (Id tareaId : tareaIds) {
            ONE_FrotcomIntegrationService.sendTask(tareaId);
        }
    }

    //Call Funeflor integration for the ID's indicated

    public static void sendPedidos(Map<Id, ONE_Tarea__c> tareasNewMap, Map<Id, ONE_Tarea__c> tareasOldMap) {
        //funeflor
        List<Id> funeflorTareas = new List<Id>();
        //floresmemora
        List<Id> funeflor2Tareas = new List<Id>();
        //mediagen
        List<Id> funeflor3Tareas = new List<Id>();
        Set<Id> proveedorIds = new Set<Id>();
        Map<Id, Account> proveedorsMap = new Map<Id, Account>();

        for (Id t : tareasNewMap.keySet()) {
            proveedorIds.add(tareasNewMap.get(t).ONE_Proveedor__c);
        }

        for (Account p : [SELECT Id, ONE_Metodo_De_Contacto_De_Proveedor__c, ONE_Tipo_De_Aplicacion__c FROM Account WHERE Id IN :proveedorIds]) {
            proveedorsMap.put(p.Id, p);
        }

        for (Id t : tareasNewMap.keySet()) {
            ONE_Tarea__c newTarea = tareasNewMap.get(t);
            ONE_Tarea__c oldTarea = tareasOldMap.get(t);
            if (newTarea.ONE_Pedido_De_Proveedor__c != null
                && newTarea.ONE_Pedido_De_Proveedor__c != oldTarea.ONE_Pedido_De_Proveedor__c
                && proveedorsMap.get(newTarea.ONE_Proveedor__c).ONE_Metodo_De_Contacto_De_Proveedor__c == ONE_CommonConstants.CM_APLICACION)
            {
                if(proveedorsMap.get(newTarea.ONE_Proveedor__c).ONE_Tipo_De_Aplicacion__c == ONE_CommonConstants.CM_FUNEFLOR)
                {
                    funeflorTareas.add(t);
                } else if(proveedorsMap.get(newTarea.ONE_Proveedor__c).ONE_Tipo_De_Aplicacion__c == ONE_CommonConstants.CM_FLORESMEMORA)
                {
                    funeflor2Tareas.add(t);
                } else if(proveedorsMap.get(newTarea.ONE_Proveedor__c).ONE_Tipo_De_Aplicacion__c == ONE_CommonConstants.CM_MEDIAGEN)
                {
                    funeflor3Tareas.add(t);
                }
                
            }
        }

        if (!funeflorTareas.isEmpty()) {
            sendPedidosCallout(funeflorTareas, ONE_CommonConstants.CM_FUNEFLOR);
        }

        if (!funeflor2Tareas.isEmpty()) {
            sendPedidosCallout(funeflor2Tareas, ONE_CommonConstants.CM_FLORESMEMORA);
        }

        if (!funeflor3Tareas.isEmpty()) {
            sendPedidosCallout(funeflor3Tareas, ONE_CommonConstants.CM_MEDIAGEN);
        }
    }
    
    //Call Funeflor integration for the ID's indicated in an Async perspective

    public static void sendPedidosCallout(List<Id> tareaIds, String ContactMethod) {
        System.enqueueJob(new ONE_SendPedidosQueueable(tareaIds, ContactMethod));
    }

    public static void notifyTareaConduccionError(Map<Id, ONE_Tarea__c> tareasNewMap, Map<Id, ONE_Tarea__c> tareasOldMap) {

        String tareaConduccionRecordTypeId = Schema.SObjectType.ONE_Tarea__c.getRecordTypeInfosByDeveloperName().get('ONE_Tarea_De_Conduccion').getRecordTypeId();
        Boolean estadoAsignacionHasChanged = false;
        for (Id t : tareasNewMap.keySet()) {
            if (tareasNewMap.get(t).RecordTypeId == tareaConduccionRecordTypeId &&
                tareasNewMap.get(t).ONE_FechaHoraPlanificada__c != null &&
                String.isNotBlank(tareasNewMap.get(t).ONE_EstadoAsignacionFrotcom__c) &&
                tareasNewMap.get(t).ONE_EstadoAsignacionFrotcom__c != tareasOldMap.get(t).ONE_EstadoAsignacionFrotcom__c)
            {
                estadoAsignacionHasChanged = true;
                break;
            }
        }

        if (estadoAsignacionHasChanged) {
            Map<String, String> colasMap = new Map<String, String>();
            for (Group cola : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
                colasMap.put(cola.DeveloperName, cola.Id);
            }

            CustomNotificationType cnt = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Tarea_Rechazada' LIMIT 1];

            for (Id t : tareasNewMap.keySet()) {
                if (tareasNewMap.get(t).RecordTypeId == tareaConduccionRecordTypeId &&
                    tareasNewMap.get(t).ONE_FechaHoraPlanificada__c != null &&
                    String.isNotBlank(tareasNewMap.get(t).ONE_EstadoAsignacionFrotcom__c) &&
                    tareasNewMap.get(t).ONE_EstadoAsignacionFrotcom__c != tareasOldMap.get(t).ONE_EstadoAsignacionFrotcom__c)
                {
                    String grupoPlanificadoresResponsable = tareasNewMap.get(t).ONE_Grupo_De_Planificadores_Responsable__c;
                    String colaId = colasMap.get(grupoPlanificadoresResponsable);
                    if (colaId != null) {
                        sendNotifications(tareasNewMap.get(t).ONE_EstadoAsignacionFrotcom__c, '', t, 'Error al asignar tarea de conducción en Frotcom', cnt.Id, new set<String>{colaId});
                    }
                }
            }
        }
    }

    @future
    public static void sendNotifications(String strBody, String strSenderId, String strTargetId, String strTitle, String strNotificationId, Set<String> queueIds) {
       
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        
        // Custom notification type Id
        obj.setNotificationTypeId(strNotificationId);
        
        // when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(strTargetId);
        
        // Notification Title
        obj.setTitle(strTitle);
        
        // Notification Body
        obj.setBody(strBody);
        
        // send used to send the notification, pass the set of user ids , Group or Queue member
        obj.send(queueIds);
    }

    public static void fillFechaProgramada(List<ONE_Tarea__c> tareasNew) {

        String tareaConduccionRecordTypeId = Schema.SObjectType.ONE_Tarea__c.getRecordTypeInfosByDeveloperName().get('ONE_Tarea_De_Conduccion').getRecordTypeId();
        Set<Id> servicios = new Set<Id>();

        for (ONE_Tarea__c tarea : tareasNew) {
            system.debug(tarea);
            if (isTareaConduccionDestinoFinal(tarea)) {
                if (tarea.ONE_Expediente__c != null) {
                    servicios.add(tarea.ONE_Expediente__c);
                }
            }
        }

        if (!servicios.isEmpty()) {

            Map<Id, ONE_Expediente__c> serviciosMap = new Map<Id, ONE_Expediente__c>();

            for (ONE_Expediente__c servicioConCentroSFB : [SELECT Id, ONE_Inicio_Ceremonia__c, ONE_Fin_Deposito__c, ONE_Fin_Velacion__c FROM ONE_Expediente__c WHERE Id IN :servicios AND ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_ProponerFechaTareasConduccion__c = true]) {
                serviciosMap.put(servicioConCentroSFB.Id, servicioConCentroSFB);
            }

            for (ONE_Tarea__c tarea : tareasNew) {
                if (isTareaConduccionDestinoFinal(tarea) && serviciosMap.keySet().contains(tarea.ONE_Expediente__c)) {
                    if (serviciosMap.get(tarea.ONE_Expediente__c).ONE_Inicio_Ceremonia__c != null) {
                        tarea.ONE_Fecha_Y_Hora__c = serviciosMap.get(tarea.ONE_Expediente__c).ONE_Inicio_Ceremonia__c;
                    }
                    else if (serviciosMap.get(tarea.ONE_Expediente__c).ONE_Fin_Deposito__c != null) {
                        tarea.ONE_Fecha_Y_Hora__c = serviciosMap.get(tarea.ONE_Expediente__c).ONE_Fin_Deposito__c;
                    }
                    else if (serviciosMap.get(tarea.ONE_Expediente__c).ONE_Fin_Velacion__c != null) {
                        tarea.ONE_Fecha_Y_Hora__c = serviciosMap.get(tarea.ONE_Expediente__c).ONE_Fin_Velacion__c;
                    }
                }
            }
        }
    }

    public static Boolean isTareaConduccionDestinoFinal(ONE_Tarea__c tarea) {

        String tareaConduccionRecordTypeId = Schema.SObjectType.ONE_Tarea__c.getRecordTypeInfosByDeveloperName().get('ONE_Tarea_De_Conduccion').getRecordTypeId();
        
        //return tarea.RecordTypeId == tareaConduccionRecordTypeId && tarea.ONE_Tipo_De_Recurso__c == 'Conducción' && tarea.ONE_Tipo_De_Traslado__c == 'Destino final';
        return tarea.RecordTypeId == tareaConduccionRecordTypeId && tarea.ONE_Tipo_De_Traslado__c == 'Destino final';
    }
}
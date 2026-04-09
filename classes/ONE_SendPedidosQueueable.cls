/**
 * Created by bjaworski002 on 12.01.2022.
 */

public with sharing class ONE_SendPedidosQueueable implements Queueable, Database.AllowsCallouts {

    List<Id> tareaIds = new List<Id>();
    String ContactMethod;

    public ONE_SendPedidosQueueable(List<Id> tareaIds, String ContactMethod) {
        this.tareaIds = tareaIds;
        this.ContactMethod = ContactMethod;
    }

    public void execute(QueueableContext qc) {
        List<ONE_Tarea__c> funeflorTareas = [
                SELECT Id, ONE_Pedido_De_Proveedor__c
                FROM ONE_Tarea__c
                WHERE Id IN :tareaIds
        ];

        Set<Id> pedidoIds = new Set<Id>();

        for (ONE_Tarea__c t : funeflorTareas) {
            pedidoIds.add(t.ONE_Pedido_De_Proveedor__c);
        }

        Map<Id, ONE_Pedido_De_Proveedor__c> pedidosMap = new Map<Id, ONE_Pedido_De_Proveedor__c>([
                SELECT Id, ONE_Ya_Procesado__c
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id IN :pedidoIds
        ]);

        List<ONE_Pedido_De_Proveedor__c> pedidosToUpdate = new List<ONE_Pedido_De_Proveedor__c>();
        List<Task> tasksToInsert = new List<Task>();

        for (ONE_Tarea__c t : funeflorTareas) {
            ONE_Pedido_De_Proveedor__c pedido = pedidosMap.get(t.ONE_Pedido_De_Proveedor__c);
            List<ONE_FuneflorIntegrationService.FlowOutputs> result = ONE_FuneflorEnvioDePedidosIntService.envioDePedidos(t, pedido, ContactMethod);
            if (result[0].success) {
                pedido.ONE_Ya_Procesado__c = true;
                pedidosToUpdate.add(pedido);

                Task successTask = new Task (
                        Description = Label.OrderSentToFuneflor,
                        Status = 'Completed',
                        Subject = Label.OrderSentToFuneflor,
                        Type = 'Other',
                        WhatId = pedido.Id,
                        ActivityDate = Date.today()
                );
                tasksToInsert.add(successTask);
            } else {
                Task errorTask = new Task (
                        Description = Label.OrderFuneflorError,
                        Status = 'Open',
                        Subject = Label.OrderFuneflorError,
                        Type = 'Other',
                        WhatId = pedido.Id,
                        ActivityDate = Date.today()
                );
                tasksToInsert.add(errorTask);
            }
        }

        if (!pedidosToUpdate.isEmpty()) {
            update pedidosToUpdate;
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}
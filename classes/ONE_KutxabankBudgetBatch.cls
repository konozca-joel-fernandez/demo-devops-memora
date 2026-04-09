/**
* File Name: ONE_KutxabankBudgetBatch
* Description: 	Batch created to send orders to Kutxabank for budget generation
* Date: 04/08/2025
*
* Copyright: Konozca Consulting
* @author: Marc Pàmies
* Test: ONE_KutxabankBudgetBatchTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		04/08/2025		Marc Pàmies  		Class creation
* ===================================================================================================================
*/

global class ONE_KutxabankBudgetBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    private List<String> ordenErrorsNames = new List<String>();
    private List <String> ordenesFlagNames = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, ONE_Factura_Enviada_a_Cliente__c, ONE_budgetNumber__c, ONE_KBSErrorFlag__c, ONE_budgetNumberAbono__c FROM ONE_Orden_De_Venta__c WHERE ((ONE_Numero_de_factura__c != null AND ONE_budgetNumber__c = null) OR (ONE_Numero_Abono_Factura__c != null AND ONE_budgetNumberAbono__c = null)) AND ONE_Servicio__r.ONE_Caso__r.ONE_Tipo__c = 'Kutxabank' AND ONE_Servicio__r.RecordType.DeveloperName = 'ONE_Servicio_M1' AND CREATEDDATE > 2025-11-11T08:00:00.000Z AND ONE_Servicio__r.ONE_Caso__r.ONE_Numero_De_Siniestro_Texto__c != null
        ]);
    }

    global void execute(Database.BatchableContext bc, List<ONE_Orden_De_Venta__c> scope) {
        List<Id> ordenIds = new List<Id>();
        Map<Id, ONE_Orden_De_Venta__c> ordenIdToName = new Map<Id, ONE_Orden_De_Venta__c>();
        for (ONE_Orden_De_Venta__c s : scope) {
            if (s.ONE_KBSErrorFlag__c) {
                ordenesFlagNames.add('- ' + s.Name + ' (' + s.Id + ')\n');
                continue;
            }
            ordenIds.add(s.Id);
            ordenIdToName.put(s.Id, s);
        }

        Map<Id, ONE_KutxabankBudgetController.FlowOutputs> resultados = ONE_KutxabankBudgetController.sendOrders(ordenIds);

        List<ONE_Orden_De_Venta__c> ordenesActualizadas = new List<ONE_Orden_De_Venta__c>();

        for (Id ordenId : resultados.keySet()) {
            ONE_KutxabankBudgetController.FlowOutputs res = resultados.get(ordenId);
            ONE_Orden_De_Venta__c orden = new ONE_Orden_De_Venta__c(Id = ordenId);
            if (res.success) {
                if (!ordenIdToName.get(ordenId).ONE_Factura_Enviada_a_Cliente__c) {
                    orden.ONE_budgetNumber__c = res.returnValue;
                    orden.ONE_Factura_Enviada_a_Cliente__c = true;
                } else {
                    orden.ONE_budgetNumberAbono__c = res.returnValue;
                }
                ordenesActualizadas.add(orden);
            }
            else {
                ordenErrorsNames.add('- ' + ordenIdToName.get(ordenId).Name + ' (' + ordenId + '): ' + res.returnValue + '\n');
                if (res.errorCode != 503){
                    orden.ONE_KBSErrorFlag__c = true;
                    ordenesActualizadas.add(orden);
                }
            }
        }

        update ordenesActualizadas;
    }

    global void finish(Database.BatchableContext bc) {
        Boolean sendMail = false;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Errores en el batch de envío de facturas a Kutxabank');
        String body = '';
        if (!ordenErrorsNames.isEmpty()) {
            sendMail = true;
            body = 'Las siguientes ordens de venta han dado errores durante el envío a KBS:\n\n' + String.join(ordenErrorsNames, '') + '\n\n';
        }
        if (!ordenesFlagNames.isEmpty()) {
            sendMail = true;
            body += 'Las siguientes ordens de venta tienen el flag de error activado y no se han procesado en el envío a KBS:\n\n' + String.join(ordenesFlagNames, '');
        }
        if (sendMail) {
            email.setToAddresses(new List<String>{'marc.pamies@konozca.com', 'antonio.saiz@asistea.com', 'palcover@memora.es'});
            email.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}
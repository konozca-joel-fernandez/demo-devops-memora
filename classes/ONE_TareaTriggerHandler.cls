public with sharing class ONE_TareaTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        //Fill the Fecha Programada field if necessary
        ONE_TareaHelper.fillFechaProgramada(Trigger.new);
    }

    public override void afterInsert() {
        //Check if tarea needs to be send to Frotcom
        ONE_TareaHelper.sendTareas(ONE_TareaHelper.getTareaIdsToSendToFrotcom(Trigger.new, new Map<Id, ONE_Tarea__c>()));
    }
    public override void afterUpdate() {
        //Check if tarea needs to be send to Frotcom
        ONE_TareaHelper.sendTareas(ONE_TareaHelper.getTareaIdsToSendToFrotcom(Trigger.new, (Map<Id, ONE_Tarea__c>)Trigger.oldMap));
        //Check if tarea needs to be send to Funeflor
        ONE_TareaHelper.sendPedidos((Map<Id, ONE_Tarea__c>)Trigger.newMap, (Map<Id, ONE_Tarea__c>)Trigger.oldMap);
        //Notify error on tarea de conducción
        ONE_TareaHelper.notifyTareaConduccionError((Map<Id, ONE_Tarea__c>)Trigger.newMap, (Map<Id, ONE_Tarea__c>)Trigger.oldMap);
    }
}
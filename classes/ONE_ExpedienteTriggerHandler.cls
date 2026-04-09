/**
 * Created by mbujak003 on 27.11.2020.
 */
//Trigger class for the Expedient object
public without sharing class ONE_ExpedienteTriggerHandler extends TriggerHandler {

    public static Boolean isExecuting = false;
    public static Boolean hasRunDeleteObsoleteLP = false;

    public override void afterInsert() {
        ONE_ExpedienteHelper.createLineasPlanificacion(Trigger.new);
    }

    public override void afterUpdate() {

        ONE_ExpedienteHelper.updateLineasPlanificacion((Map<Id, ONE_Expediente__c>)Trigger.oldMap, (Map<Id, ONE_Expediente__c>)Trigger.newMap);
        if (!hasRunDeleteObsoleteLP) {
            hasRunDeleteObsoleteLP = true;
            ONE_ExpedienteHelper.deleteObsoleteLineasPlanificacion((Map<Id, ONE_Expediente__c>)Trigger.oldMap, (Map<Id, ONE_Expediente__c>)Trigger.newMap);
        }
        //ONE_ExpedienteHelper.deleteReservasServicio((Map<Id, ONE_Expediente__c>)Trigger.oldMap, (Map<Id, ONE_Expediente__c>)Trigger.newMap);
    }
}
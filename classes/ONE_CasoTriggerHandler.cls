//Trigger class for the Caso object
public without sharing class ONE_CasoTriggerHandler extends TriggerHandler {

    public static Boolean isExecuting = false;
    
    public override void beforeInsert(){
        
        ONE_CasoHelper.checkFieldsOcaso(Trigger.new);
    }

    public override void afterInsert() {

        ONE_CasoHelper.createLineasPlanificacion(Trigger.new);
    }

    public override void afterUpdate() {

        ONE_CasoHelper.updateLineasPlanificacion((Map<Id, ONE_Caso__c>)Trigger.oldMap, (Map<Id, ONE_Caso__c>)Trigger.newMap);
    }
}
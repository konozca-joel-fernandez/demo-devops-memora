public with sharing class ONE_PresupuestoTriggerHandler extends TriggerHandler {

	public override void beforeUpdate() {
        //Orden de Venta status validation
        ONE_PresupuestoHelper.getStatusOfOV((Map<Id, ONE_Presupuesto__c>)Trigger.newMap, (Map<Id, ONE_Presupuesto__c>)Trigger.oldMap);
    }

}
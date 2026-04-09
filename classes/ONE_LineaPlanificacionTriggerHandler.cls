public without sharing class ONE_LineaPlanificacionTriggerHandler extends TriggerHandler {

    public static Boolean isExecuting = false;
    public static Boolean isUpdatingRelatedLineasPlanificacion = false;

    public override void beforeInsert() {

        ONE_LineaPlanificacionHelper.autoCompleteFields(Trigger.new);
    }

    public override void beforeUpdate() {

        ONE_LineaPlanificacionHelper.preventImportantFieldsEmptying(Trigger.new, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.oldMap, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.newMap);
        //ONE_LineaPlanificacionHelper.emptyDestinoIntermedioLibre(Trigger.new, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.oldMap, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.newMap);
        ONE_LineaPlanificacionHelper.saveFechaHoraProgramada(Trigger.new, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.oldMap, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.newMap);

        if(!ONE_ExpedienteTriggerHandler.isExecuting) {
            ONE_LineaPlanificacionHelper.markAsUpdatedByPlanificador(Trigger.new, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.oldMap, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.newMap);
        }
    }

    public override void afterUpdate() {

        if (!ONE_ExpedienteTriggerHandler.isExecuting && !ONE_LineaPlanificacionTriggerHandler.isUpdatingRelatedLineasPlanificacion) {
            ONE_LineaPlanificacionHelper.updateServicioAndRelatedLineasPlanificacion((Map<Id, ONE_LineaPlanificacion__c>)Trigger.oldMap, (Map<Id, ONE_LineaPlanificacion__c>)Trigger.newMap);
        }
    }

    public override void afterDelete() {

        ONE_LineaPlanificacionHelper.cancelTasks((Map<id, ONE_LineaPlanificacion__c>)Trigger.oldMap);
    }

    public override void afterInsert() {
        // Lógica ya existente si la hubiera (aquí no hay, así que añadimos la nueva directamente)
    
        Set<Id> servicioIds = new Set<Id>();
        for (ONE_LineaPlanificacion__c lp : (List<ONE_LineaPlanificacion__c>) Trigger.new) {
            if (lp.ONE_Servicio__c != null) {
                servicioIds.add(lp.ONE_Servicio__c);
            }
        }
    
        if (!servicioIds.isEmpty()) {
            ONE_InterlocutorHandler.updateDeclarantes(servicioIds);
        }
    }
    
}
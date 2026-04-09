/**
 * Created by mbujak003 on 27.11.2020.
 */

public with sharing class ONE_ReservasTriggerHandler extends TriggerHandler { 
    public override void beforeInsert() {
        //ONE_ReservasHelper.validateSFB(Trigger.new);
        ONE_ReservasHelper.validateHorario(Trigger.new);
        ONE_ReservasHelper.validateOverlappingReservas(Trigger.new, null);
        ONE_ReservasHelper.validateDisponibilidad(Trigger.new);
    }

    public override void afterInsert() {
        ONE_ReservasHelper.mapFieldsToExpedient((Map<id, ONE_Reservas__c>)Trigger.newMap);
    }

    public override void beforeUpdate() {
        ONE_ReservasHelper.validateHorario(Trigger.new);
        ONE_ReservasHelper.validateOverlappingReservas(Trigger.new, (Map<Id, ONE_Reservas__c>)Trigger.oldMap);
        ONE_ReservasHelper.validateDisponibilidad(Trigger.new);
    }
    public override void afterUpdate() {
        ONE_ReservasHelper.mapFieldsToExpedient((Map<id, ONE_Reservas__c>)Trigger.newMap);
    }
    public override void afterDelete() {
        System.debug('Estoy entrando en delete?');
        ONE_ReservasHelper.clearFieldsFromExpedient((Map<id, ONE_Reservas__c>)Trigger.oldMap);
    }
}
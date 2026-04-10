//Trigger class for the Caso object
public without sharing class ONE_CasoTriggerHandler extends TriggerHandler {

    public static Boolean isExecuting = false;
    
    public override void beforeInsert(){
        
        ONE_CasoHelper.FuncionTest1(Trigger.new);
    }

    public override void afterInsert() {

        ONE_CasoHelper.FuncionTest2(Trigger.new);
    }

    public override void afterUpdate() {

        ONE_CasoHelper.FuncionTest3((Map<Id, ONE_Caso__c>)Trigger.oldMap, (Map<Id, ONE_Caso__c>)Trigger.newMap);
    }

    public override void beforeUpdate() {

        ONE_CasoHelper.FuncionTest4((Map<Id, ONE_Caso__c>)Trigger.oldMap, (Map<Id, ONE_Caso__c>)Trigger.newMap);
    }
}
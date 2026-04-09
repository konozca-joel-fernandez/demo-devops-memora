/**
 * Created by mbujak003 on 29.01.2021.
 */

public with sharing class ONE_PurchaseOrderActionController {

    @AuraEnabled
    public static String invokeSapIntegration(String tareaId) {

        /*List<ONE_PurchaseOrderIntegrationService.FlowOutputs> output = ONE_PurchaseOrderIntegrationService.invokeIntegration(new List<String> { tareaId });
        System.debug(JSON.serialize(output[0]));

        if(output[0].status = true) {
            updateTareaCheckbox(tareaId);
        }

        return JSON.serialize(output[0]);*/
        return '';
    }

    @Future
    public static void updateTareaCheckbox(String tareaId) {
        ONE_Tarea__c tarea = [SELECT Id, ONE_Memora_Confirma_Entrega_O_Ejecucion__c FROM ONE_Tarea__c WHERE Id =: tareaId];
        tarea.ONE_Memora_Confirma_Entrega_O_Ejecucion__c = true;
        update tarea;
    }
}
public class ONE_PresupuestoHelper {

    public static void getStatusOfOV(Map<Id, ONE_Presupuesto__c> presupuestosNewMap, Map<Id, ONE_Presupuesto__c> presupuestosOldMap) {
        Boolean statusFacturado=false;
        List<ONE_Orden_De_Venta__c> OVList = [SELECT Id, ONE_Estado_De_La_Orden_de_Venta__c, ONE_Presupuesto__c FROM ONE_Orden_De_Venta__c WHERE ONE_Presupuesto__c IN :presupuestosNewMap.keySet()];
        System.debug('Ordenes de venta: '+ OVList);
        for (Id presupuestoId : presupuestosNewMap.keySet()) {
            ONE_Presupuesto__c newPresupuesto = presupuestosNewMap.get(presupuestoId);
            ONE_Presupuesto__c oldPresupuesto = presupuestosOldMap.get(presupuestoId);
            System.debug('Nuevo Presupuesto.presupuestoCancelado: '+newPresupuesto.ONE_Presupuesto_Cancelado__c);
            System.debug('Antiguo Presupuesto.presupuestoCancelado: '+oldPresupuesto.ONE_Presupuesto_Cancelado__c);
             if (newPresupuesto.ONE_Presupuesto_Cancelado__c != oldPresupuesto.ONE_Presupuesto_Cancelado__c && newPresupuesto.ONE_Presupuesto_Cancelado__c){
                 for(ONE_Orden_De_Venta__c ov: OVList){
                     if(ov.ONE_Presupuesto__c==newPresupuesto.Id && ov.ONE_Estado_De_La_Orden_de_Venta__c=='Facturado'){
                         statusFacturado=true;
                     }
                 }
                 if(statusFacturado){
					newPresupuesto.addError('No se puede cancelar un presupuesto si tiene una orden de venta facturada');
                 }
                 
             }
                
         }
    }
}
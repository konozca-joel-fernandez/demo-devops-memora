/**
 * Created by mchruscick001 on 11.10.2021 11:22.
 */

public with sharing class ONE_PresupuestoTestDataFactory {
    static final String INCINERATION_TYPE_CONTRACT = 'Contratar Incineración'; 
    static final String INCINERATION_TYPE_CONTRACT_SHORT = 'C'; 
    
    public static ONE_Presupuesto__c getInsertBudgetWithExpediente(Id expedienteId) {
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c();
        presupuesto.ONE_Codigo_General_Sepultura_CB__c = '';
        presupuesto.ONE_Expediente__c = expedienteId;
        presupuesto.ONE_Tipo_De_Venta__c = null;
        presupuesto.ONE_Tipo_De_Compra_CB__c = INCINERATION_TYPE_CONTRACT;
        presupuesto.ONE_Tipo_De_Solicitud_CB__c = INCINERATION_TYPE_CONTRACT_SHORT;
        insert presupuesto;
        return presupuesto;
    }
}
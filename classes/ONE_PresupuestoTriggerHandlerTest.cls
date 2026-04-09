@IsTest
public class ONE_PresupuestoTriggerHandlerTest {
    @testSetup
    private static void setup() {
        
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        
        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );
        
		Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        
        ONE_Expediente__c servicio = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id,  ONE_Centro_Del_Expediente__c = centro.Id), true);
        
        ONE_Presupuesto__c presupuesto= new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = servicio.Id, 
        		ONE_Presupuesto_Cancelado__c=false);
        insert presupuesto;
       
        ONE_Orden_de_venta__c ov=ONE_TestDataFactory.createOrdenDeVenta(new ONE_Orden_de_venta__c(ONE_Presupuesto__c = presupuesto.Id, ONE_Estado_De_La_Orden_de_Venta__c='Facturado'), true);
    }
     @IsTest
    private static void testCancelPresupuesto() {
        ONE_Presupuesto__c presupuesto =[SELECT Id, ONE_Presupuesto_Cancelado__c FROM ONE_Presupuesto__c limit 1];
        presupuesto.ONE_Presupuesto_Cancelado__c=true;
        try{
			update presupuesto;            
        }catch(Exception e){
                system.assertEquals(true,e.getMessage().contains('No se puede cancelar un presupuesto si tiene una orden de venta facturada'));
        }
    }
}
/**
 * Created by msulek003 on 29.04.2021.
 */
//Schedulable class for the automatic factura generation
public with sharing class ONE_FacturaComercialBatchScheduler implements Schedulable {

    public void execute(SchedulableContext param1) {
        Database.executeBatch(new ONE_FacturaComercialBatch(), 10);
    }
}
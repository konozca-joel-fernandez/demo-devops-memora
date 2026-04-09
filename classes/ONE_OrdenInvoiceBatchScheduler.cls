/**
 * Created by kmotyka005 on 05.11.2021.
 */
//Invocable class to execute the batch via floe
public with sharing class ONE_OrdenInvoiceBatchScheduler {

    @InvocableMethod(Label='InvokeOrdenInvoiceBatch')
    public static void execute() {
        Database.executeBatch(new ONE_OrdenInvoiceBatch(), 1); // Buffer set to 1 so we don't have timeouts
    }

}
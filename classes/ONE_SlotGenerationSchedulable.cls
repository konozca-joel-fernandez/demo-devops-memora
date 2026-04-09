public with sharing class ONE_SlotGenerationSchedulable implements Schedulable {

    public void execute(SchedulableContext ctx) {

        List<ONE_SlotSala__c> generatedSlots = ONE_SlotGenerator.generateSlotsForNextDays(7);
    }
    
    public static void scheduleJob() {
        
        ONE_SlotGenerationSchedulable sched = new ONE_SlotGenerationSchedulable();
        System.schedule('Generación de slots', '0 0 3 * * ? *', sched);
    }
}
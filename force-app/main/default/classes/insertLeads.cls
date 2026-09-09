public with sharing class insertLeads {
    @InvocableMethod(label='Insert Leads')
    public static void insertLeads(List<Id> leadIds) {
        if (leadIds != null && !leadIds.isEmpty()) {
            List<Lead> leadsToInsert = [SELECT Id FROM Lead WHERE Id IN :leadIds];
            List<Lead> updatedLeads = new List<Lead>();
            
            for (Lead lead : leadsToInsert) {
                Lead newLead = lead.clone();
                newLead.Status = 'New';
                updatedLeads.add(newLead);
            }
            
            if (!updatedLeads.isEmpty()) {
                upsert updatedLeads Id;
            }
        }
    }
}
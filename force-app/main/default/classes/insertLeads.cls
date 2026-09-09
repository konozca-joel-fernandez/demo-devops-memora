public with sharing class insertLeads {
    @InvocableMethod(label='Insert Leads')
    public static void insertLeads(List<Id> leadIds) {
        if (leadIds != null && !leadIds.isEmpty()) {
            List<Lead> leadsToInsert = [SELECT Id FROM Lead WHERE Id IN :leadIds WITH USER_MODE];
            List<Lead> updatedLeads = new List<Lead>();
            
            for (Lead lead : leadsToInsert) {
                Lead newLead = lead.clone();
                newLead.Status = 'New';
                updatedLeads.add(newLead);
            }
            
            if (!updatedLeads.isEmpty() && Schema.sObjectType.Lead.isCreateable() && Schema.sObjectType.Lead.isUpdateable()) {
                upsert updatedLeads Id;
            }
        }
    }
}
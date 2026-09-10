public with sharing class insertLeads {
    @InvocableMethod(label='Insert Leads')
    public static void insertLeads(List<Id> leadIds) {
        if (leadIds != null && !leadIds.isEmpty()) {
            // Consulta de campos obligatorios para el clon
            List<Lead> leadsToInsert = [SELECT Id, LastName, Company, CreatedDate, LastModifiedDate FROM Lead WHERE Id IN :leadIds WITH USER_MODE];
            List<Lead> newLeads = new List<Lead>();
            
            for (Lead lead : leadsToInsert) {
                Lead newLead = lead.clone(false, true, false, false);
                newLead.Status = 'New';
                newLead.Company = 'Konozca';
                newLeads.add(newLead);
            }
            
            if (!newLeads.isEmpty() && Schema.sObjectType.Lead.isCreateable()) {
                insert newLeads;
            }
        }
    }
}
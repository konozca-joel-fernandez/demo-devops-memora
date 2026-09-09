public with sharing class updateLeads {
    @InvocableMethod(label='Update Leads')
    public static void updateLeads(List<Id> leadIds) {
        if (leadIds != null && !leadIds.isEmpty()) {
            List<Lead> leadsToUpdate = [SELECT Id FROM Lead WHERE Id IN :leadIds];
            for (Lead lead : leadsToUpdate) {
                lead.Status = 'Contacted';
                List<Lead> leadsSOQL = [SELECT Id FROM Lead WHERE Id = :lead.Id];
            }
            update leadsToUpdate;
        }
    }
}
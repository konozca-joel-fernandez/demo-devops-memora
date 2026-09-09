public with sharing class updateLeads {
    @InvocableMethod(label='Update Leads')
    public static void updateLeads(List<Id> leadIds) {
        if (leadIds != null && !leadIds.isEmpty()) {
            List<Lead> leadsToUpdate = [SELECT Id FROM Lead WHERE Id IN :leadIds WITH USER_MODE];
            for (Lead lead : leadsToUpdate) {
                lead.Status = 'Contacted';
            }
            //Solo si el usuario puede actualizar
            if (Schema.sObjectType.Lead.isUpdateable()) {
                update leadsToUpdate;
            }
        }
    }
}
@IsTest
public with sharing class Test_insertLeads {
    @IsTest
    public static void testInsertLeadsSuccess() {
        Lead lead = new Lead();
        lead.FirstName = 'John';
        lead.LastName = 'Doe';
        lead.Email = 'joel.fernandez@konozca.com';
        lead.Company = 'Konozca';
        insert lead;

        Test.startTest();
        insertLeads.insertLeads(new List<Id>{lead.Id});
        Test.stopTest();

        // Validamos que se creó el nuevo registro clonado con estado 'New'
        List<Lead> clonedLeads = [SELECT Id, Status, CreatedDate FROM Lead WHERE Status = 'New'];
        System.assertEquals(1, clonedLeads.size(), 'Debería haberse creado 1 clon con estado New.');
    }
}
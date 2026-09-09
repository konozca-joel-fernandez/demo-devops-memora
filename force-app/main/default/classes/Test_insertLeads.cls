@IsTest
public with sharing class Test_insertLeads {
    @IsTest
    public static void Test_insertLeads() {
        Lead lead = new Lead();
        lead.FirstName = 'John';
        lead.LastName = 'Doe';
        lead.Email = 'joel.fernandez@konozca.com';
        lead.Company = 'Konozca'
        insert lead;

        Test.startTest();
        insertLeads.insertLeads(new List<Id>{lead.Id});
        Test.stopTest();

        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(updatedLead.Status, 'New');
    }
}
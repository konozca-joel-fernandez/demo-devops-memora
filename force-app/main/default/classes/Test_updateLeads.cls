@isTest
private class Test_updateLeads {

    @testSetup
    static void setupData() {
        // Creamos Leads de prueba con los campos obligatorios estándar
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            testLeads.add(new Lead(
                LastName = 'TestLead ' + i,
                Company = 'Empresa Test ' + i,
                Status = 'Open - Not Contacted'
            ));
        }
        insert testLeads;
    }

    @isTest
    static void testUpdateLeadsSuccess() {
        List<Lead> leadsBefore = [SELECT Id FROM Lead WHERE LastName LIKE 'TestLead%'];
        List<Id> leadIds = new List<Id>();
        for (Lead l : leadsBefore) {
            leadIds.add(l.Id);
        }

        Test.startTest();
        updateLeads.updateLeads(leadIds);
        Test.stopTest();

        // Validamos que el estado cambió a 'Contacted' en el 100% de los registros
        List<Lead> leadsAfter = [SELECT Id, Status FROM Lead WHERE Id IN :leadIds];
        for (Lead l : leadsAfter) {
            System.assertEquals('Contacted', l.Status, 'El estado del Lead debería haber cambiado a Contacted.');
        }
    }

    @isTest
    static void testUpdateLeadsNullOrEmpty() {
        Test.startTest();
        // Probamos casos límite para asegurar cobertura de las comprobaciones de nulos/vacíos
        updateLeads.updateLeads(null);
        updateLeads.updateLeads(new List<Id>());
        Test.stopTest();

        // Verificamos que no hubo excepciones ni modificaciones no deseadas
        List<Lead> leadsAfter = [SELECT Id, Status FROM Lead WHERE LastName LIKE 'TestLead%'];
        for (Lead l : leadsAfter) {
            System.assertEquals('Open - Not Contacted', l.Status, 'El estado no debe cambiar si la lista es nula o vacía.');
        }
    }
}
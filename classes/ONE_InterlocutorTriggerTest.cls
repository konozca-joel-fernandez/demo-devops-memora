@isTest
public class ONE_InterlocutorTriggerTest {

        @testSetup
        static void setupData() {
            
            List<ONE_Expediente__c> servicios = new List<ONE_Expediente__c>();
            for (Integer i = 0; i < 3; i++) {
                servicios.add(new ONE_Expediente__c());
            }
            insert servicios;
    
            
            List<ONE_Interlocutor__c> interlocutores = new List<ONE_Interlocutor__c>{
                new ONE_Interlocutor__c(
                    Name = 'Interlocutor Insert',
                    ONE_Declarante__c = true,
                    ONE_Expediente__c = servicios[0].Id
                ),
                new ONE_Interlocutor__c(
                    Name = 'Interlocutor Update',
                    ONE_Declarante__c = false,
                    ONE_Expediente__c = servicios[1].Id
                )
            };
            insert interlocutores;
        }
    
        @isTest
        static void testAfterInsert() {
            ONE_Expediente__c servicio = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
    
            Test.startTest();
            ONE_Interlocutor__c i = new ONE_Interlocutor__c(
                Name = 'Nuevo Insert',
                ONE_Declarante__c = true,
                ONE_Expediente__c = servicio.Id
            );
            insert i;
            Test.stopTest();
    
            // Puedes agregar asserts si el método `updateDeclarantes` actualiza algún campo visible
        }
    
        @isTest
        static void testAfterUpdateChangeDeclarante() {
            ONE_Interlocutor__c i = [SELECT Id, ONE_Declarante__c FROM ONE_Interlocutor__c WHERE Name = 'Interlocutor Update' LIMIT 1];
    
            i.ONE_Declarante__c = true;
    
            Test.startTest();
            update i;
            Test.stopTest();
        }
    
        @isTest
        static void testAfterDelete() {
            ONE_Interlocutor__c i = [SELECT Id FROM ONE_Interlocutor__c WHERE Name = 'Interlocutor Insert' LIMIT 1];
    
            Test.startTest();
            delete i;
            Test.stopTest();
        }


    }
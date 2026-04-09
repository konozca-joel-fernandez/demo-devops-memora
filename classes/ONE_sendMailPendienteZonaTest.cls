@isTest
public class ONE_sendMailPendienteZonaTest {

    @isTest
    static void testInvokerFromFlow() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u1 = new User(
            FirstName = 'Test',
            LastName = 'User First',
            Alias = 'testu1',
            Email = 'testuser1@test.com',
            Username = 'testuser1@test.com4321543255432532432142',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es'
        );
        insert u1;

        User u2 = new User(
            FirstName = 'Test',
            LastName = 'User Second',
            Alias = 'testu2',
            Email = 'testuser2@test.com',
            Username = 'testuser2@test.com5215231454253542353452',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es'
        );
        insert u2;

        Group queue = new Group(Name = 'Test Queue', Type = 'Queue', Email = 'queuetest@test.com', DoesSendEmailToMembers = true);
        insert queue;

        insert new List<GroupMember>{
            new GroupMember(GroupId = queue.Id, UserOrGroupId = u1.Id),
            new GroupMember(GroupId = queue.Id, UserOrGroupId = u2.Id)
        };
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
        System.runAs(thisUser) {
            
            Id recordTypeIdAcc = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Person_Accout_Particular' LIMIT 1].Id;

            Account account = new Account(FirstName = 'Test', LastName = 'Difunto', RecordTypeId = recordTypeIdAcc);
            insert account;
    
            Id recordTypeIdCaso = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Avisos_De_Defuncion' LIMIT 1].Id;
            
            ONE_Caso__c caso = new ONE_Caso__c(
                ONE_Tipo__c = 'Asegurado/Acuerdo',
                ONE_Tipo_De_Servicio__c = 'Servicio Integral',
                ONE_Relacion_Con_El_Difunto__c = 'Amistad',
                ONE_Difunto__c = account.Id,
                RecordTypeId = recordTypeIdCaso
            );
            insert caso;
    
            EmailTemplate template = new EmailTemplate(
                Name = 'Test Template',
                DeveloperName = 'Test_Template',
                TemplateType = 'custom',
                Subject = 'Correo de prueba',
                HtmlValue = '<p>Hola {!User.FirstName}</p>',
                FolderId = UserInfo.getUserId()
            );
            insert template;
        
            ONE_sendMailPendienteZona.Input input = new ONE_sendMailPendienteZona.Input();
            input.templateId = template.Id;
            input.queueId = queue.Id;
            input.recordId = caso.Id;
            input.orgWideAddress = 'clientes@memora.es';
    
            Test.startTest();
            ONE_sendMailPendienteZona.enqueueEmailJob(new List<ONE_sendMailPendienteZona.Input>{ input });
            Test.stopTest();
    
            System.assert(true);
        }
    }
}
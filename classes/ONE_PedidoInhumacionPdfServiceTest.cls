@isTest
public class ONE_PedidoInhumacionPdfServiceTest { 
    @TestSetup
    private static void testSetup() {
        Account acc = new Account(FirstName = 'TEST', LastName = 'TEST', Phone='532944', ONE_Email__c = 'martaJtest@example.com',
                                  RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        
        Account proveedor = new Account( Name = 'Test Proveedor');
        insert proveedor;
                        
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = acc.id
        );
        insert expediente;
                
        ONE_Interlocutor__c interlocutor = new ONE_Interlocutor__c(
            ONE_Expediente__c =expediente.id,
            ONE_Pagador__c = true
        );
        insert interlocutor;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(
            ONE_Expediente__c = expediente.id,
            ONE_Email_Proveedor__c = 'martaJtest@example.com',
            ONE_Email_De_Remitente__c = 'martaJtest@example.com',
            Name = 'Test Nombre Test',
            ONE_Proveedor__c = proveedor.id
            
        );
        insert pedido;
        
        ONE_Tarea__c tarea = new ONE_Tarea__c(
            ONE_Pedido_De_Proveedor__c = pedido.id
            
        );
        insert tarea;
        
        ONE_Documentos__c documentoTarea34 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC034_CE_Pedido_Tarea_Inhumacion').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id,
            ONE_Servicio__c = expediente.Id
        );
        insert documentoTarea34;
    }

    @IsTest
    private static void createPdfFile() {
        ONE_Documentos__c documento = [SELECT Id FROM ONE_Documentos__c LIMIT 1];
        ONE_Pedido_De_Proveedor__c pedido = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];

        Test.startTest();
        
        ONE_PdfServiceBase.FlowInput input = new ONE_PdfServiceBase.FlowInput();
        input.language = 'ES';
        input.documentoId = documento.Id;
        input.documentoRecordTypeName = 'DOC034_CE_Pedido_Tarea_Inhumacion';
        input.pedidoId = pedido.Id;
        List<ONE_PdfServiceBase.FlowInput> inputs = new List<ONE_PdfServiceBase.FlowInput>{input};
        ONE_PedidoInhumacionPdfService.sendEmailWithPdf(inputs);
        
        Test.stopTest();

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :pedido.Id
        ]);

        System.assertEquals(1, contentDocumentLinks.size());
    }
}
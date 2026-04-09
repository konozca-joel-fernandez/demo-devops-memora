@isTest

public class ONE_PedidoGestoriaPdfServiceTest {
    @TestSetup
    private static void testSetup() {
        Account acc = new Account(FirstName = 'TEST', LastName = 'TEST', Phone='532944', ONE_Email__c = 'martaJtest@example.com',
                                  RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = acc.id
        );
        insert expediente;
        
        ONE_Interlocutor__c interlocutor = new ONE_Interlocutor__c(
            ONE_Expediente__c =expediente.id,
        	ONE_Declarante__c = true
        );
        insert interlocutor;
        
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(
            ONE_Expediente__c = expediente.id,
            ONE_Email_Proveedor__c = 'martaJtest@example.com',
            ONE_Email_De_Remitente__c = 'martaJtest@example.com',
            Name = 'Test Nombre Test'
        );
        insert pedido;
        
        ONE_Tarea__c tarea = new ONE_Tarea__c(
            ONE_Pedido_De_Proveedor__c = pedido.id
        );
        insert tarea;
        
        
    }
    
    @IsTest
    private static void createPdfFile() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE LastName='TEST' LIMIT 1];
        
        Test.startTest();
        //ONE_PedidoGestoriaPdfService.FlowInput input = new ONE_PedidoGestoriaPdfService.FlowInput(); ONE_PdfServiceBase
        ONE_PedidoGestoriaPdfService.FlowInput input = new ONE_PedidoGestoriaPdfService.FlowInput(); 
        input.pedidoProveedorId = pedidos.Id;
        input.language = 'ES';
        List<ONE_PedidoGestoriaPdfService.FlowInput> inputs = new List<ONE_PedidoGestoriaPdfService.FlowInput>{input};
            ONE_PedidoGestoriaPdfService.createAndLinkPdf(inputs);
        
        Test.stopTest();
        
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id OR LinkedEntityId =:pedidos.Id]);
        
        System.assertEquals(1, contentDocumentLinks.size());
    }
    
    @IsTest
    private static void createPdf() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        system.debug('pedidos--> ' + pedidos);
        Account account = [SELECT Id FROM Account WHERE LastName='TEST' LIMIT 1];
        system.debug('account--> ' + account);
        PageReference pageRef = Page.ONE_PedidoGestoriaPdf;
        
        pageRef.getParameters().put('pedidoProveedorId', pedidos.Id);
        pageRef.getParameters().put('language', 'ES');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_PedidoGestoriaPdfController controller = new ONE_PedidoGestoriaPdfController();
        Test.stopTest();
        
    }
}
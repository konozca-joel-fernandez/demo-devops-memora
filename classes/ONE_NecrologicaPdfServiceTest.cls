@isTest
//Test class for the PDF Generation
public class ONE_NecrologicaPdfServiceTest {
    @TestSetup
    //Method to create all the data for the test
    private static void testSetup() {
        Account acc = new Account(FirstName = 'TEST', LastName = 'TEST', Phone='532944', ONE_Email__c = 'martaJtest@example.com',
                                  RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        
        Account centro = new Account(name= 'centro test', RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_CENTRO_MEMORA), ONE_Estado__c='Pendiente de comprobación');
        insert centro;
                        
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = acc.id,
            ONE_Centro_Del_Expediente__c = centro.id,
            ONE_Fecha_De_Defuncion__c= date.valueOf('2020-01-01'), 
            ONE_Inicio_Ceremonia__c = date.valueOf('2020-01-01'), 
            ONE_Fin_Ceremonia__c = date.valueOf('2020-01-01'), 
            ONE_Publicar_en_Web__c = 'Si'
        );
        insert expediente;
                
        ONE_Pedido_De_Proveedor__c pedido = new ONE_Pedido_De_Proveedor__c(
            ONE_Expediente__c = expediente.id,
            ONE_Email_Proveedor__c = 'martaJtest@example.com',
            Name = 'Test Nombre Test'
        );
        insert pedido;
        
        ONE_Tarea__c tarea = new ONE_Tarea__c(ONE_Pedido_De_Proveedor__c = pedido.id);
        insert tarea;
        
        ONE_Lugar__c lugar = new ONE_Lugar__c(
            ONE_Nivel_Jerarquico__c = '', 
            Name = 'testLugarName'

        );
        insert lugar;


    }

    @IsTest
    //Test Service     
    private static void createPdfFile() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Name='centro test' LIMIT 1];

        Test.startTest();
            ONE_NecrologicaPdfService.FlowInput input = new ONE_NecrologicaPdfService.FlowInput();
            input.accountOrLugarID = account.Id;
            input.level =  'area_operativa'; //centro
            input.startDate =  '2020-01-01';
            input.endDate =  '2020-01-01';
            input.language = 'ES';
            List<ONE_NecrologicaPdfService.FlowInput> inputs = new List<ONE_NecrologicaPdfService.FlowInput>{input};
            system.debug('createAndLinkPdf inputs' + inputs);
        	system.debug('inputs-->' + inputs);
            ONE_NecrologicaPdfService.createAndLinkPdf(inputs);
        	
		
        Test.stopTest();
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id OR LinkedEntityId =:pedidos.Id]);

        System.assertEquals(1, contentDocumentLinks.size());
    }
    
    @IsTest
    //Test Controller for PDF type Area Operativa  
    private static void createPdf_area_operativa() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        system.debug('pedidos--> ' + pedidos);
        Account account = [SELECT Id FROM Account WHERE Name='centro test' LIMIT 1];
        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c LIMIT 1];
        PageReference pageRef = Page.ONE_NecrologicaPdf;

        pageRef.getParameters().put('accountOrLugarID', lugar.Id);
        pageRef.getParameters().put('level', 'area_operativa');
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('startDate', '2019-01-01');
        pageRef.getParameters().put('endDate', '2021-01-01');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_NecrologicaPdfController controller = new ONE_NecrologicaPdfController();
        Test.stopTest();

    }
    
    
    @IsTest
    //Test Controller for PDF type Centro  
    private static void createPdf_centro() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        system.debug('pedidos--> ' + pedidos);
        Account account = [SELECT Id FROM Account WHERE Name='centro test' LIMIT 1];
        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c LIMIT 1];
        PageReference pageRef = Page.ONE_NecrologicaPdf;

        pageRef.getParameters().put('accountOrLugarID', account.Id);
        pageRef.getParameters().put('level', 'centro');
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('startDate', '2019-01-01');
        pageRef.getParameters().put('endDate', '2021-01-01');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_NecrologicaPdfController controller = new ONE_NecrologicaPdfController();
        Test.stopTest();

    }
    
    @IsTest
    //Test Controller for PDF type Zona Operativa    
    private static void createPdf_zona_operativa() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        system.debug('pedidos--> ' + pedidos);
        Account account = [SELECT Id FROM Account WHERE Name='centro test' LIMIT 1];
        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c LIMIT 1];
        PageReference pageRef = Page.ONE_NecrologicaPdf;
        
        pageRef.getParameters().put('accountOrLugarID', lugar.Id);
        pageRef.getParameters().put('level', 'zona_operativa');
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('startDate', '2019-01-01');
        pageRef.getParameters().put('endDate', '2021-01-01');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_NecrologicaPdfController controller = new ONE_NecrologicaPdfController();
        Test.stopTest();
        
    }
    
    @IsTest
    //Test Controller for PDF type delegacion    
    private static void createPdf_delegacion() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        system.debug('pedidos--> ' + pedidos);
        Account account = [SELECT Id FROM Account WHERE Name='centro test' LIMIT 1];
        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c LIMIT 1];
        PageReference pageRef = Page.ONE_NecrologicaPdf;
        
        pageRef.getParameters().put('accountOrLugarID', lugar.Id);
        pageRef.getParameters().put('level', 'delegacion');
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('startDate', '2019-01-01');
        pageRef.getParameters().put('endDate', '2021-01-01');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_NecrologicaPdfController controller = new ONE_NecrologicaPdfController();
        Test.stopTest();
        
    }
    
    @IsTest
    //Test Controller for PDF type Ambito   
    private static void createPdf_ambito() {
        ONE_Pedido_De_Proveedor__c pedidos = [SELECT Id FROM ONE_Pedido_De_Proveedor__c LIMIT 1];
        system.debug('pedidos--> ' + pedidos);
        Account account = [SELECT Id FROM Account WHERE Name='centro test' LIMIT 1];
        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c LIMIT 1];
        PageReference pageRef = Page.ONE_NecrologicaPdf;
        
        pageRef.getParameters().put('accountOrLugarID', lugar.Id);
        pageRef.getParameters().put('level', 'ambito');
        pageRef.getParameters().put('language', 'ES');
        pageRef.getParameters().put('startDate', '2019-01-01');
        pageRef.getParameters().put('endDate', '2021-01-01');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_NecrologicaPdfController controller = new ONE_NecrologicaPdfController();
        Test.stopTest();
        
    }

    
}
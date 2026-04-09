@isTest
public class ONE_SendContractEmailControllerTest {
 @testSetup
    private static void testSetup() {
        
        Account difunto = new Account();
        difunto.FirstName = 'Test Data Factory';
        difunto.LastName = 'envioEmail';
        difunto.Phone = '789456123';
        difunto.ONE_N_Documento__pc = '98288564L';
        difunto.RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR);
        insert difunto;
        
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        
        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );
        
        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = centro.Id), true);
        
        ONE_Presupuesto__c presupuesto= new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name, ONE_CommonConstants.PRES_RT_PRESUPUESTO_APP),
                ONE_Tipo_De_Contrato__c = ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR,
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expediente.Id, 
            ONE_Presupuesto_Cancelado__c=false);
        insert presupuesto;
           
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.pdf'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.TagCsv='CONTRATO_COMERCIAL';
        content.IsMajorVersion=true;
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=presupuesto.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
    }
    
    @isTest
    private static void sendEmail() {
       
        Test.startTest();
        ONE_SendContractEmailController.FlowInput input = new ONE_SendContractEmailController.FlowInput();
        input.tipoPresupuesto = 'Particular';
        input.presupuestoId = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1].Id;
        input.servicioId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        input.bodyEmail = 'TEST BODY';
        input.asuntoEmail = 'TEST ASUNTO';
        
        List<ONE_SendContractEmailController.FlowInput> inputs = new List<ONE_SendContractEmailController.FlowInput>{input};
        List<ONE_SendContractEmailController.FlowOutput> outputs = ONE_SendContractEmailController.sendContractByEmail(inputs);
        
        Test.stopTest();
    }
    
        @isTest
    private static void test_ParticularEmail() {
        
        Test.startTest();
        ONE_SendContractEmailController.FlowInput input = new ONE_SendContractEmailController.FlowInput();
        input.tipoPresupuesto = 'Particular';
        input.presupuestoId = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1].Id;
        input.servicioId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        input.bodyEmail = 'Body';
        input.asuntoEmail = 'Asunto';
        input.titularEmail = 'test@example.com';
        List<ONE_SendContractEmailController.FlowInput> inputs = new List<ONE_SendContractEmailController.FlowInput>{input};

        
        ONE_SendContractEmailController.sendContractByEmail(inputs);
        Test.stopTest();
    }
    
        @isTest
    private static void test_HojaDeServicio() {
        
        Test.startTest();
        ContentVersion content = new ContentVersion(
            Title = 'HojaServicio',
            PathOnClient = '/HojaServicio.pdf',
            VersionData = Blob.valueOf('Data'),
            TagCsv = 'HOJA_SERVICIO',
            IsMajorVersion = true
        );
        insert content;

        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1].Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id].ContentDocumentId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert link;

        ONE_SendContractEmailController.FlowInput input = new ONE_SendContractEmailController.FlowInput();
        input.tipoPresupuesto = 'Hoja de servicio';
        input.presupuestoId = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1].Id;
        input.titularEmail = 'test@example.com';
        input.bodyEmail = 'Body';
        input.asuntoEmail = 'Asunto';

        
        ONE_SendContractEmailController.sendContractByEmail(new List<ONE_SendContractEmailController.FlowInput>{input});
        Test.stopTest();
    }

    @isTest
    private static void test_OportunidadOlympia() {
        Test.startTest();
        ONE_Documentos__c doc = new ONE_Documentos__c(
            ONE_Servicio__c = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id,
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Documentos__c', 'Autorizaci_n_para_Cesi_n_de_Datos')
        );
        insert doc;

        ContentVersion content = new ContentVersion(
            Title = 'Documento Olympia',
            PathOnClient = '/doc.pdf',
            VersionData = Blob.valueOf('Data'),
            TagCsv = 'CONTRATO_COMERCIAL',
            IsMajorVersion = true
        );
        insert content;

        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = doc.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id].ContentDocumentId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert link;

        ONE_SendContractEmailController.FlowInput input = new ONE_SendContractEmailController.FlowInput();
        input.tipoPresupuesto = 'Oportunidad Olympia';
        input.servicioId = doc.ONE_Servicio__c;
        input.titularEmail = 'test@example.com';
        input.bodyEmail = 'Body';
        input.asuntoEmail = 'Asunto';

        
        ONE_SendContractEmailController.sendContractByEmail(new List<ONE_SendContractEmailController.FlowInput>{input});
        Test.stopTest();
    }
    
    @isTest
    private static void test_UserEmailNotVerified() {
        Test.startTest();
        
        
        ONE_SendContractEmailController.FlowInput input = new ONE_SendContractEmailController.FlowInput();
        input.tipoPresupuesto = 'Particular';
        input.presupuestoId = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1].Id;
        input.titularEmail = 'test@example.com';
        List<ONE_SendContractEmailController.FlowInput> inputs = new List<ONE_SendContractEmailController.FlowInput>{input};
            
            List<ONE_SendContractEmailController.FlowOutput> result = ONE_SendContractEmailController.sendContractByEmail(inputs);
        Test.stopTest();
        
        System.assertEquals(false, result[0].success); 
    }
    
    @isTest
    private static void testCubreBloqueAdjuntoYWhatId() {
        // Recuperar datos de setup
        ONE_Presupuesto__c presupuesto = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];

        // Crear input para cubrir el bloque deseado
        ONE_SendContractEmailController.FlowInput input = new ONE_SendContractEmailController.FlowInput();
        input.tipoPresupuesto = 'Particular';
        input.presupuestoId = presupuesto.Id;
        input.titularEmail = 'test@correo.com';
        input.bodyEmail = 'Contenido del correo';
        input.asuntoEmail = 'Asunto del correo';
       

        Test.startTest();
        List<ONE_SendContractEmailController.FlowOutput> result = ONE_SendContractEmailController.sendContractByEmail(
            new List<ONE_SendContractEmailController.FlowInput>{input}
        );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Debe retornar una salida');
    }
    
        @isTest
    private static void sendEmailCasuistica2() {

    Test.startTest();
    ONE_SendContractEmailController.FlowInput input = new ONE_SendContractEmailController.FlowInput();
    input.tipoPresupuesto = 'Particular';
    input.presupuestoId = [SELECT Id FROM ONE_Presupuesto__c LIMIT 1].Id;
    input.servicioId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
    input.bodyEmail = 'TEST BODY';
    input.asuntoEmail = 'TEST ASUNTO';


    List<ONE_SendContractEmailController.FlowInput> inputs = new List<ONE_SendContractEmailController.FlowInput>{input};
    List<ONE_SendContractEmailController.FlowOutput> outputs = ONE_SendContractEmailController.sendContractByEmail(inputs);
    Test.stopTest();

    }

    



}
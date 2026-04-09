@isTest
public class PdfGenerationServiceTest {
    
    @testSetup
    private static void testSetup() {

        Account acc = new Account(FirstName = 'TEST', LastName = 'TEST', Phone='532944', ONE_Email__c = 'martaJtest@example.com',
                                  RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = acc.id
        );
        insert expediente;

        ONE_Tarea__c tarea = new ONE_Tarea__c(
            RecordTypeId = Schema.SObjectType.ONE_Tarea__c.getRecordTypeInfosByDeveloperName().get('ONE_Tarea_De_Cremacion').getRecordTypeId(),
            ONE_Expediente__c = expediente.Id
        );
        insert tarea;
        
        ONE_Documentos__c documentoServicio = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC002_Acta_de_reconocimiento').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        insert documentoServicio;

        ONE_Documentos__c documentoTarea = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC002_Acta_de_reconocimiento').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id
        );
        insert documentoTarea;
    }

    @isTest
    private static void createAndLinkPdfServicio() {

        ONE_Documentos__c documento = [SELECT Id FROM ONE_Documentos__c WHERE ONE_Servicio__c != null LIMIT 1];

        Test.startTest();
        PdfGenerationService.FlowInput input = new PdfGenerationService.FlowInput();
        input.documentoId = documento.Id;
        input.language = 'es';
        List<PdfGenerationService.FlowInput> inputs = new List<PdfGenerationService.FlowInput>{input};
        List<PdfGenerationService.FlowOutput> outputs = PdfGenerationService.createAndLinkPdf(inputs); 
        Test.stopTest();

        PdfGenerationService.FlowOutput output = outputs[0];
        System.assert(output.success);
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:documento.Id]);
        
        System.assertEquals(1, contentDocumentLinks.size());
    }

    
    @isTest
    private static void createAndLinkPdfTarea() {

        ONE_Documentos__c documento = [SELECT Id FROM ONE_Documentos__c WHERE ONE_Tarea__c != null LIMIT 1];

        Test.startTest();
        PdfGenerationService.FlowInput input = new PdfGenerationService.FlowInput();
        input.documentoId = documento.Id;
        input.language = 'es';
        List<PdfGenerationService.FlowInput> inputs = new List<PdfGenerationService.FlowInput>{input};
        List<PdfGenerationService.FlowOutput> outputs = PdfGenerationService.createAndLinkPdf(inputs); 
        Test.stopTest();

        PdfGenerationService.FlowOutput output = outputs[0];
        System.assert(output.success);
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:documento.Id]);
        
        System.assertEquals(1, contentDocumentLinks.size());
    }
    
    
    
    @isTest
    private static void testLinkWithParent() {
        ONE_Documentos__c doc = [SELECT Id FROM ONE_Documentos__c LIMIT 1];
        Blob pdfContent = Blob.valueOf('Test pdf');
        Id contentDocId = ONE_PdfGeneratorHelper.savePdf(pdfContent, doc.Id, 'Testpdf', 'test');
        
        Test.startTest();
        ONE_PdfGeneratorHelper.linkWithParent(contentDocId, doc.Id);
        Test.stopTest();
        
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocId];
        System.assert(links.size() > 0);
    }


    @isTest
    private static void testGetTitleLabel() {
        String title = ONE_PdfGeneratorHelper.getTitleLabel('Test pdf');
        System.assert(title.startsWith('Test pdf'));
        System.assert(title.endsWith('pdf'));
    }
    
    
    
    @isTest
    private static void testSavePdf() {
        Blob pdfContent = Blob.valueOf('Test pdf');
        String fileName = 'Testpdf';
        
        ONE_Documentos__c doc = [SELECT Id FROM ONE_Documentos__c LIMIT 1];
        
        Test.startTest();
        Id contentDocId = ONE_PdfGeneratorHelper.savePdf(pdfContent, doc.Id, fileName, 'test');
        Test.stopTest();
        
        System.assertNotEquals(null, contentDocId);
    }
    
    
    @isTest
    private static void testLinkWithOpportunity() {
        ONE_Oportunidad__c oportunidad = new ONE_Oportunidad__c(ONE_Tel_fono_de_contacto__c = '123456789');
        insert oportunidad;
        
        ONE_Documentos__c documento = new ONE_Documentos__c(ONE_Oportunidad__c = oportunidad.Id);
        insert documento;
       
        Blob pdfContent = Blob.valueOf('Test PDF Content');
        Id contentDocId = ONE_PdfGeneratorHelper.savePdf(pdfContent, documento.Id, 'Testpdf', 'test');
        
        Test.startTest();
        ONE_PdfGeneratorHelper.linkWithOpportunity(contentDocId, documento.Id);
        Test.stopTest();
        
        ONE_Oportunidad__c updatedOpp = [SELECT ONE_CheckPdf__c FROM ONE_Oportunidad__c WHERE Id = :oportunidad.Id];
        System.assertEquals(true, updatedOpp.ONE_CheckPdf__c);
    }
    
    
    @isTest
    private static void testSetupEmailWithAttachment() {
        Blob pdfContent = Blob.valueOf('Test PDF Content');
        String email = 'test@example.com';
        String fileName = 'TestFile.pdf';
        Id templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
        
        Messaging.SingleEmailMessage emailMessage = ONE_PdfGeneratorHelper.setupEmailWithAttachment(pdfContent, email, fileName, templateId);
        
        System.assertNotEquals(null, emailMessage);
        System.assert(emailMessage.toAddresses.contains(email));
    }
    

    
    @isTest
    private static void testLinkWithPersonaParticular() {
        ONE_Oportunidad__c oportunidad = new ONE_Oportunidad__c(ONE_Tel_fono_de_contacto__c = '123456789');
        insert oportunidad;
        

        
        Account acc = new Account(FirstName = 'TEST', LastName = 'TEST', Phone='532944', ONE_Email__c = 'martaJtest@example.com',
                                  RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = acc.id
        );
        insert expediente;
        ONE_Expediente__c expediente2= new ONE_Expediente__c(
            ONE_Difunto__c = acc.id
        );
        insert expediente2;
        
		expediente = [SELECT Id, Name FROM ONE_Expediente__c WHERE Id = :expediente.Id LIMIT 1];
        update expediente;
        
        
        ONE_Documentos__c documento = new ONE_Documentos__c(ONE_Oportunidad__c = oportunidad.Id, ONE_Persona_Particular__c = acc.Id, ONE_Servicio__c = expediente.Id);
        insert documento;
        
        ContentVersion cv = new ContentVersion(
            Title = 'DemoFile',
            VersionData = Blob.valueOf('Random String Data'),
            PathOnClient = 'DemoFile.png'
        );
        insert cv;
        
        
        ONE_Pedido_De_Proveedor__c pdp = new ONE_Pedido_De_Proveedor__c(ONE_Expediente__c = expediente.Id, Name = 'aaaa');

        
        
        Id demoFileId = [SELECT Id FROM ContentDocument WHERE Title = 'DemoFile'].Id;
        
        EmailTemplate template =              
            [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :ONE_CommonConstants.EMAIL_TEMPLATE_MARMOLISTA_MEDICO_GESTORIA_CA];
                               


        
        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
                                        RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                                        ONE_Tipo_De_Impuesto__c = 'IVA', ONE_ID_Cliente_SAP__c ='223232');
        
        insert accMemora;
        
        
        ONE_Orden_De_Venta__c ordenDeVenta = 
            new ONE_Orden_De_Venta__c(
                ONE_Servicio__c = expediente.Id,
                ONE_Fecha_De_Facturacion__c = Date.today(),
                ONE_Numero_de_factura__c = 'FV25/02/21',
                ONE_Forma_De_Pago__c = 'A',
                ONE_Moneda__c = 'EUR',
                ONE_IBAN__c = 'ES3621082850270010500972',
                ONE_Titular_De_La_Cuenta_Bancaria__c = 'José Carreño Iborra',
                ONE_El_Pagador_Es_El_Difunto__c = false,
                ONE_Pagador_Compania__c = accMemora.Id
            ); 
           insert ordenDeVenta;
        
        ONE_Orden_De_Venta__c ordenDeVenta2 = 
            new ONE_Orden_De_Venta__c(
                ONE_Servicio__c = expediente2.Id,
                ONE_Fecha_De_Facturacion__c = Date.today(),
                ONE_Numero_de_factura__c = 'FV25/02/21',
                ONE_Forma_De_Pago__c = 'A',
                ONE_Moneda__c = 'EUR',
                ONE_IBAN__c = 'ES3621082850270010500972',
                ONE_Titular_De_La_Cuenta_Bancaria__c = 'José Carreño Iborra',
                ONE_El_Pagador_Es_El_Difunto__c = false,
                ONE_Pagador_Compania__c = accMemora.Id
            ); 
           insert ordenDeVenta2;
        
        ordenDeVenta = [SELECT Id, Name FROM ONE_Orden_De_Venta__c WHERE Id = :ordenDeVenta.Id LIMIT 1];
        
        
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name,
                                                                        'ONE_Presupuesto_App'),
            ONE_Tipo_De_Contrato__c = 'Particular',
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
            ONE_Importe_IVA_3__c =23,
            ONE_Importe_IVA_21__c = 883,
            ONE_Importe_IVA_10__c = 33,
            ONE_Expediente__c = expediente.Id,
            ONE_tipo_Documento__c='presupuesto'
        );
            
        
        insert presupuesto;
        presupuesto = [SELECT Id, Name FROM ONE_Presupuesto__c WHERE Id = :presupuesto.Id LIMIT 1];
        
		ONE_PdfGeneratorHelper.linkWithServico(demoFileId, documento.Id);
        ONE_PdfGeneratorHelper.linkWithPersonaParticular(demoFileId, documento.Id);
		ONE_PdfGeneratorHelper.buildCommonLabelM1(ordenDeVenta.Id);
        //ONE_PdfGeneratorHelper.getNameOrNombreFiscalDeLaCuenta(ordenDeVenta.Id);
        ONE_PdfGeneratorHelper.buildCommonExtendedLabel(ordenDeVenta.Id, false);
        ONE_PdfGeneratorHelper.buildCommonLabel(presupuesto.Id, 'prefix');
        ONE_PdfGeneratorHelper.linkWithServicoFromOrdenDeVenta(demoFileId, ordenDeVenta2.Id);
        // Verifica que el ContentDocumentLink fue creado
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :documento.ONE_Persona_Particular__c];
        System.assertEquals(1, links.size(), 'Debe haber un enlace con la persona particular');
       
    }
    
    


    
    
    
    
    
    
    
   
                      

}
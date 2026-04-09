/**
 * Created by msulek003 on 31.03.2021. 
 */
@isTest
public with sharing class ONE_ProtteccionDatosPdfServiceTest {
    @TestSetup
    private static void testSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
            ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        
        
        Account acc2 = new Account(Name = 'Tanatorio Vara de Quart', Phone='900231132', ONE_Email__c = 'logsone@memora.es',
                                  RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_CENTRO_MEMORA));
        insert acc2;
        
		 ONE_Oportunidad__c oportunidad = new ONE_Oportunidad__c(ONE_Tel_fono_de_contacto__c = '123456789');
        insert oportunidad;
        
        ONE_Expediente__c servicio = new ONE_Expediente__c(
            ONE_Centro_del_Expediente__c = acc2.Id);
        
        
            insert servicio;
        
        
        ONE_Documentos__c documentos = new ONE_Documentos__c(
            ONE_Persona_Particular__c = acc.Id,
            ONE_Domicialiado_en_Poblacion__c = 'Test 123',
            ONE_Provincia2__c = '28',
            ONE_Calle__c = '111111',
            ONE_CheckAutoriza__c = true);
        insert documentos;
        
         ONE_Documentos__c documentos2 = new ONE_Documentos__c(
            ONE_Persona_Particular__c = acc.Id,
            ONE_Domicialiado_en_Poblacion__c = 'Test 123',
            ONE_Parentesco_Tratamiento__c ='Padre',
            ONE_Provincia2__c = '28',
            ONE_Calle__c = '2222222',
            ONE_CheckAutoriza__c = true, 
            ONE_Servicio__c = servicio.Id);
        insert documentos2;
        
        
        ONE_Documentos__c documentos3 = new ONE_Documentos__c(
            ONE_Persona_Particular__c = acc.Id,
            ONE_Domicialiado_en_Poblacion__c = 'Test 123',
            ONE_Parentesco_Tratamiento__c ='Padre',
            ONE_Provincia2__c = '28',
            ONE_Calle__c = '3333333',
            ONE_CheckAutoriza__c = true,
            ONE_Sala_N__c = '5',
        	ONE_Oportunidad__c=oportunidad.Id);
        insert documentos3;
    }

    @IsTest
    private static void createPdfFile() {
        ONE_Documentos__c documentos = [SELECT Id, ONE_Calle__c FROM ONE_Documentos__c WHERE ONE_Oportunidad__c=null LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE LastName='Smith' LIMIT 1];
        System.debug('Estoy testeando el documento... ' + documentos.ONE_Calle__c);

        Test.startTest();
            ONE_ProtteccionDatosPdfService.FlowInput input = new ONE_ProtteccionDatosPdfService.FlowInput();
        	System.debug('Estoy testeando el documento1.1... ' + documentos.ONE_Calle__c);
            input.documentosId = documentos.Id;
        	System.debug('Estoy testeando el documento1.2... ' + documentos.ONE_Calle__c);
            input.language = 'es';
        	System.debug('Estoy testeando el documento1.3... ' + documentos.ONE_Calle__c);
            List<ONE_ProtteccionDatosPdfService.FlowInput> inputs = new List<ONE_ProtteccionDatosPdfService.FlowInput>{input};
            System.debug('Estoy testeando el documento...1.4 ' + documentos.ONE_Calle__c);
            ONE_ProtteccionDatosPdfService.createAndLinkPdf(inputs);
        	System.debug('Estoy testeando el documento1.5... ' + documentos.ONE_Calle__c);

        Test.stopTest();


        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id OR LinkedEntityId =:documentos.Id]);

        System.assertEquals(2, contentDocumentLinks.size());
    }
      @IsTest
    private static void createPdfFile2() {
        ONE_Documentos__c documentos = [SELECT Id, ONE_Calle__c FROM ONE_Documentos__c WHERE ONE_Oportunidad__c!=null LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE LastName='Smith' LIMIT 1];
		System.debug('Estoy testeando el documento... ' + documentos.ONE_Calle__c);
        Test.startTest();
            ONE_ProtteccionDatosPdfService.FlowInput input = new ONE_ProtteccionDatosPdfService.FlowInput();
        	System.debug('Estoy testeando el documento.3,1.. ' + documentos.ONE_Calle__c);
            input.documentosId = documentos.Id;
        	System.debug('Estoy testeando el documento3.2... ' + documentos.ONE_Calle__c);
            input.language = 'es';
            List<ONE_ProtteccionDatosPdfService.FlowInput> inputs = new List<ONE_ProtteccionDatosPdfService.FlowInput>{input};
            System.debug('Estoy testeando el documento3.3... ' + documentos.ONE_Calle__c);
            ONE_ProtteccionDatosPdfService.createAndLinkPdf(inputs);
        	System.debug('Estoy testeando el documento3.4... ' + documentos.ONE_Calle__c);
			ONE_ProtteccionDatosData data = ONE_ProtteccionDatosDataFactory.buildProtteccionDatosData(documentos.Id, 'es');
        	System.debug('Estoy testeando el documento3.5... ' + documentos.ONE_Calle__c);
        Test.stopTest();


        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id OR LinkedEntityId =:documentos.Id]);

        System.assertEquals(2, contentDocumentLinks.size());
    }

    @IsTest
    private static void createPdfFile3() {
        ONE_Documentos__c documentos = [SELECT Id, ONE_Calle__c FROM ONE_Documentos__c WHERE ONE_Calle__c = '2222222'  LIMIT 1];
        System.debug('Estoy testeando el documento... ' + documentos.ONE_Calle__c);
        Account account = [SELECT Id FROM Account WHERE LastName='Smith' LIMIT 1];
        
        Test.startTest();
        ONE_ProtteccionDatosPdfService.FlowInput input = new ONE_ProtteccionDatosPdfService.FlowInput();
        System.debug('Estoy testeando el documento2.1... ' + documentos.ONE_Calle__c);
        input.documentosId = documentos.Id;
        System.debug('Estoy testeando el documento2.2... ' + documentos.ONE_Calle__c);
        input.language = 'es';
        System.debug('Estoy testeando el documento2.3... ' + documentos.ONE_Calle__c);
        List<ONE_ProtteccionDatosPdfService.FlowInput> inputs = new List<ONE_ProtteccionDatosPdfService.FlowInput>{input};
        System.debug('Estoy testeando el documento...2.4 ' + documentos.ONE_Calle__c);
            ONE_ProtteccionDatosPdfService.createAndLinkPdf(inputs);
        System.debug('Estoy testeando el documento2.5... ' + documentos.ONE_Calle__c);
        ONE_SalaExternaData data = ONE_SalaExternaDataFactory.buildSalaExternaData(documentos.Id, 'es');
        System.debug('Estoy testeando el documento2.6... ' + documentos.ONE_Calle__c);
        ONE_ProtteccionDatosData data2 = ONE_ProtteccionDatosDataFactory.buildProtteccionDatosData(documentos.Id, 'es');
        System.debug('Estoy testeando el documento2.7... ' + documentos.ONE_Calle__c);

        Test.stopTest();
        
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id OR LinkedEntityId =:documentos.Id]);
        
        System.assertEquals(2, contentDocumentLinks.size());
    }
    @IsTest
    private static void createPdf() {
        ONE_Documentos__c documentos = [SELECT Id, ONE_Calle__c FROM ONE_Documentos__c LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE LastName='Smith' LIMIT 1];
        PageReference pageRef = Page.ONE_ProteccionDatosPdf;

        pageRef.getParameters().put('documentosId', documentos.Id);
        pageRef.getParameters().put('language', 'ES');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_ProtteccionDatosPdfController controller = new ONE_ProtteccionDatosPdfController();
        Test.stopTest();

        System.assertEquals('Madrid', controller.data.provincia);

    }
    
    
    @IsTest
    private static void createPdf2() {
        ONE_Documentos__c documentos = [SELECT Id, ONE_Calle__c FROM ONE_Documentos__c WHERE ONE_Funeraria__c!=null AND ONE_Pagador__c != null LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE LastName='Smith' LIMIT 1];
        PageReference pageRef = Page.SolicitudSalaExterna;
        
        pageRef.getParameters().put('documentosId', documentos.Id);
        pageRef.getParameters().put('language', 'ES');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_SolicitudSalaController controller = new ONE_SolicitudSalaController();
        Test.stopTest();
        
        System.assertEquals('Madrid', controller.data.ONE_Provincia);
        
    }
}
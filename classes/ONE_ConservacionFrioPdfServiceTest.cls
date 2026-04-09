@isTest
public with sharing class ONE_ConservacionFrioPdfServiceTest {
    
    @TestSetup
    private static void testSetup() {
        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
            ONE_Tipo_De_Impuesto__c = 'IVA');

        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
            ONE_Tipo_De_Impuesto__c = 'IVA', ONE_Centro_Memora_Codigo_SAP__c = '1257');

        insert new List<Account> {acc, accMemora};

        ONE_Expediente__c servicio = new ONE_Expediente__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                'ONE_Servicio_Defuncion'),
            ONE_Difunto__c = acc.Id,
            ONE_Centro_Del_Expediente__c = accMemora.Id,
            ONE_Inicio_Incineracion__c = Datetime.newInstance(Datetime.now().year(), Datetime.now().month(), Datetime.now().day()).addDays(1).addHours(17),
            ONE_Incineracion__c = true,
            ONE_Tipo_De_Lugar_De_Incineracion__c = 'Interno',
            ONE_Deposito__c = true,
            ONE_Inicio_Deposito__c = Datetime.newInstance(Datetime.now().year(), Datetime.now().month(), Datetime.now().day())
        );
        insert servicio;
        system.debug(servicio.ONE_Inicio_Deposito__c);
        system.debug(servicio.ONE_Inicio_Incineracion__c);
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name,
                'ONE_Presupuesto_App'),
            ONE_Tipo_De_Contrato__c = 'Particular',
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto servicio completo',
            ONE_Importe_IVA_3__c =23,
            ONE_Importe_IVA_21__c = 883,
            ONE_Importe_IVA_10__c = 33,
            ONE_Expediente__c = servicio.Id,
            ONE_tipo_Documento__c='presupuesto',
            ONE_Tipo_De_Venta__c=''
        );
        insert presupuesto;
    }
    
    @IsTest
    private static void createConservacionFrioPdfFile() {
        Account account = [SELECT Id FROM Account where ONE_Centro_Memora_Codigo_SAP__c = '1257' LIMIT 1];

        Test.startTest();
        ONE_ConservacionFrioPdfService.FlowInput input = new ONE_ConservacionFrioPdfService.FlowInput();
        input.accountId = account.Id;
        input.language = 'es';
        List<ONE_ConservacionFrioPdfService.FlowInput> inputs = new List<ONE_ConservacionFrioPdfService.FlowInput>{input};
        ONE_ConservacionFrioPdfService.createAndLinkPdf(inputs);

        Test.stopTest();


        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id]);

        System.assertEquals(1, contentDocumentLinks.size());
    }
    
    @IsTest
    private static void createConservacionFrioPdf() {
        Account account = [SELECT Id FROM Account where ONE_Centro_Memora_Codigo_SAP__c = '1257' LIMIT 1];
        PageReference pageRef = Page.ONE_ConservacionFrioPdf;

        pageRef.getParameters().put('accountId', account.Id);
        pageRef.getParameters().put('language', 'ES');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONE_ConservacionFrioPdfController controller = new ONE_ConservacionFrioPdfController();
        Test.stopTest();
        
        System.assertEquals(1, controller.data.conservacionesList.size());
    }
    
}
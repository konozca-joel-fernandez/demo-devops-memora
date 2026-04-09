@isTest
public class ONE_SuplidoSegurCaixaPdfServiceTest {
    
    @testSetup
    private static void testSetup() {
        
        ONE_Lugar__c l3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c l2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = l3.Id), true);
        ONE_Lugar__c l = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = l2.Id), true);
        
        Account s = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_ACCOUNT_SOCIEDADES),
                ONE_Lugar__c = l3.Id,
                Name = 'Sociedad',
                ONE_URL_logo__c = 'no image'
            ), true
        );
        
        Account c = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = l.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN',
                ONE_URL_logo__c = 'no image',
                ONE_CIF__c = 'XXXX',
                ONE_Sociedad2__c = s.Id
            ), true
        );
        
        Account d = new Account(
            FirstName = 'TEST', LastName = 'TEST', Phone='532944', 
            ONE_Email__c = 'test@example.com', ONE_N_Documento__pc = '44445555X',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
			ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR)
        );
        insert d;
        
        System.debug('Acc ' + s.Id + ' ' + c.Id + ' ' + d.Id);
        
        ONE_Expediente__c e = ONE_TestDataFactory.createExpediente(
            new ONE_Expediente__c(
            	ONE_Centro_Del_Expediente__c = c.Id,
                ONE_Difunto__c = d.Id,
                ONE_Numero_de_Poliza__c = '0'
            ), true
        );
        
        System.debug('Exp ' + e.Id);
        
        ONE_Orden_De_Venta__c ov = ONE_TestDataFactory.createOrdenDeVenta(
            new ONE_Orden_De_Venta__c(
                ONE_Fecha_De_Facturacion__c = Date.today(),
                ONE_Numero_de_factura__c = '0',
                ONE_Servicio__c = e.Id
        	), 
            true
        );
       
        System.debug('OVsu -- ' + ov.Id);
    }
    
    @isTest
    private static void serviceTest() {
        Test.startTest();
        
		Id ordenDeVentaID = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id;  
        
        System.debug('OV -- ' + ordenDeVentaID);
        
        ONE_SuplidoSegurCaixaPdfService.FlowInput fi = new ONE_SuplidoSegurCaixaPdfService.FlowInput();
        fi.ordenDeVentaID = ordenDeVentaID;
        List<ONE_SuplidoSegurCaixaPdfService.FlowInput> inputs = new List<ONE_SuplidoSegurCaixaPdfService.FlowInput>{fi};
        
        ONE_SuplidoSegurCaixaPdfService.createAndLinkPdf(inputs);

        Test.stopTest();
    }
    
    @isTest
    private static void createPdfTest() {
        Id ordenDeVentaID = [SELECT Id FROM ONE_Orden_De_Venta__c LIMIT 1].Id;
        
        PageReference pageRef = Page.ONE_SuplidoSegurCaixaPdf;
        
        pageRef.getParameters().put('ordenDeVentaID', ordenDeVentaID);  
        
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ONE_SuplidoSegurCaixaPdfController controller = new ONE_SuplidoSegurCaixaPdfController(); 
        Test.stopTest();
        
    }
    
    
}
@isTest
public class ONE_CompanyPDFGenerationServiceTest {
    
    private static String CONTRATO_POL = 'pol';
    private static String COMPANIA_ASEGURADORA = 'G';
    private static final String CONTRATO_RAMO = 'br';
    private static final String CONTRACTO_DIGITO_DE_CONTROL = '2';
    private static String DATA_TIPOLOGY = 'F';
    
    private static final Integer DAY = 1;
    private static final Integer MONTH = 1;
    private static final Integer YEAR = 1999;
    private static final Integer HOUR = 1;
    private static final Integer MINUTE = 1;
    
    private static final String DIRECCION_DE_DEFUNCION = 'direccion de defuncion';
    private static final String PROVINCIA_DE_DEFUNCION = '15';
    private static final String CODIGO_POSTAL_DE_DEFUNCION = 'codigo postal de defuncion';
    private static final String PAIS_DE_DEFUNCION = 'ES';
    
    private static final String NUMERO_DE_DOCUMENTO = 'numero';
    private static final String OBSERVACIONES = 'observaciones';
    private static final String NO_INFORMADO = 'No Informado';
    private static final String CAUSAS_DEFUNCION = 'Natural';
    private static final String NOMBRE_DE_LA_PERSONA_DE_CONTACTO = 'nombre de la person de contacto';
    private static final String RELACION_CON_EL_DIFUNTO = 'Padre';
    
    private static final String FIRST_NAME = 'first';
    private static final String LAST_NAME = 'last';

    @testSetup
    private static void testSetup() {

        Account acc = new Account(
            FirstName = FIRST_NAME, 
            LastName = LAST_NAME, 
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().Name, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        ONE_Contrato__c contrato = new ONE_Contrato__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Contrato__c', 'ONE_Contrato_M1'), ONE_Pol__c = CONTRATO_POL, ONE_Ramo__c = CONTRATO_RAMO, ONE_Compania_Aseguradora__c = COMPANIA_ASEGURADORA,ONE_Beneficiario_1__c=acc.Id);
        insert contrato;
        DateTime fechaDeDefuncion = DateTime.newInstance(Date.newInstance(YEAR, MONTH, DAY), Time.newInstance(HOUR, MINUTE, 0, 0));
        ONE_Caso__c caso = new ONE_Caso__c(
            RecordTypeId = Schema.SObjectType.ONE_Caso__c.getRecordTypeInfosByDeveloperName().get('ONE_Avisos_M1').getRecordTypeId(),
            ONE_Difunto__c = acc.Id, ONE_Contrato__c = contrato.Id, ONE_Fecha_De_Defuncion__c = fechaDeDefuncion,
            ONE_Direccion_De_Defuncion__c = DIRECCION_DE_DEFUNCION, ONE_Provincia_De_Defuncion__c = PROVINCIA_DE_DEFUNCION, ONE_Codigo_Postal_De_Defuncion__c = CODIGO_POSTAL_DE_DEFUNCION,
            ONE_Pais_De_Defuncion__c = PAIS_DE_DEFUNCION, ONE_Numero_De_Documento__c = NUMERO_DE_DOCUMENTO, ONE_Observaciones__c = OBSERVACIONES,
            ONE_Causas_Defuncion__c = CAUSAS_DEFUNCION, ONE_Nombre_De_La_Persona_De_Contacto__c = NOMBRE_DE_LA_PERSONA_DE_CONTACTO,
            ONE_Relacion_Con_El_Difunto__c = RELACION_CON_EL_DIFUNTO
        );
        insert caso;
    }

    @isTest
    private static void createAndLinkPdf() {

        ONE_Caso__c caso = [SELECT Id FROM ONE_Caso__c LIMIT 1];

        Test.startTest();
        ONE_CompanyPdfGenerationService.FlowInputs input = new ONE_CompanyPdfGenerationService.FlowInputs();
        input.casoId = caso.Id;
        List<ONE_CompanyPdfGenerationService.FlowInputs> inputs = new List<ONE_CompanyPdfGenerationService.FlowInputs>{input};
        List<ONE_CompanyPdfGenerationService.FlowOutputs> outputs = ONE_CompanyPdfGenerationService.createAndLinkPdf(inputs); 
        Test.stopTest();

        ONE_CompanyPdfGenerationService.FlowOutputs output = outputs[0];
        System.assert(output.success);
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:caso.Id]);
        
        System.assertEquals(1, contentDocumentLinks.size());
    }
}
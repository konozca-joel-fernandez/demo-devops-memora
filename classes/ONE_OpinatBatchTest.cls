/**
 * Created by mkuzak001 on 01.02.2021.
 */

@IsTest
private class ONE_OpinatBatchTest {
    private static final String COMENTARIO = 'Comment';
    private static final String MOTIVO_0 = 'Motivo 0';
    private static final String MOTIVO_1 = 'Motivo 1';
    private static final String MOTIVO_2 = 'Motivo 2';
    private static final String MOTIVOS = String.join(new List<String>{MOTIVO_0, MOTIVO_1, MOTIVO_2}, '\n');
    private static final String LINK = '/index.php/url/view?id=423532';
    private static final String URGENTE = '1';
    private static final Integer VALORACION = 3;
    private static final String CODIGO_CAMPANYA = '123';
    private static final String FECHA_RESPUESTA = '2016-10-28 11:29:06';
    
    @IsTest
    static void getExpedienteValuesWorksCorrectlyWhenSuccessResponse() {
        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;
        expediente = [
            SELECT Name
            FROM ONE_Expediente__c
            WHERE Id = :expediente.Id
        ];
        
        String url = new ONE_OpinatIntegrationService.OpinatIntegrationCallout(CODIGO_CAMPANYA, Date.today().addDays(-1), Date.today()).buildEndpoint();
        
        List<ONE_OpinatIntegrationService.ResponseWrapper> responseWrappers = new List<ONE_OpinatIntegrationService.ResponseWrapper>{
            new ONE_OpinatIntegrationService.ResponseWrapper(COMENTARIO, MOTIVOS, LINK, URGENTE,
                String.valueOf(VALORACION), expediente.Name, FECHA_RESPUESTA)
        };
        
        Test.setMock(HttpCalloutMock.class, new ONE_OpinatIntegrationServiceTest.OpinatIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE,
            'success', new Map<String, String>(), responseWrappers));
        
        Test.startTest();
        
        Database.executeBatch(new ONE_OpinatBatch(), 50);
        
        Test.stopTest();
        
        expediente = [
            SELECT ONE_Comentario_De_La_Encuesta__c, ONE_Motivos__c, ONE_Link_A_La_Encuesta__c, ONE_Valoracion_NPS__c, ONE_Fecha_respuesta__c, ONE_Contacto_urgente__c
            FROM ONE_Expediente__c
            WHERE Name = :expediente.Name
        ];
        System.assertEquals(COMENTARIO, expediente.ONE_Comentario_De_La_Encuesta__c);
        System.assertEquals(url.split('\\/ws')[0] + LINK, expediente.ONE_Link_A_La_Encuesta__c);
        System.assertEquals(VALORACION, expediente.ONE_Valoracion_NPS__c);
        System.assertEquals(MOTIVOS, expediente.ONE_Motivos__c);
        System.assertEquals(true, expediente.ONE_Contacto_urgente__c);
        System.assertEquals(DateTime.valueOF(FECHA_RESPUESTA), expediente.ONE_Fecha_respuesta__c);
    }
    @IsTest
    
    static void getExpedienteValuesNotChangedWhenSuccessError() {
        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;
        expediente = [
            SELECT Name
            FROM ONE_Expediente__c
            WHERE Id = :expediente.Id
        ];
        
        String url = new ONE_OpinatIntegrationService.OpinatIntegrationCallout(CODIGO_CAMPANYA, Date.today().addDays(-1), Date.today()).buildEndpoint();
        
        Test.setMock(HttpCalloutMock.class, new ONE_OpinatIntegrationServiceTest.OpinatIntegrationMock(ONE_CommonConstants.HTPP_SERVER_ERROR_CODE,
            'success', new Map<String, String>(), new List<ONE_OpinatIntegrationService.ResponseWrapper>()));
        
        Test.startTest();
        
        Database.executeBatch(new ONE_OpinatBatch(), 50);
        
        Test.stopTest();
        
        expediente = [
            SELECT ONE_Comentario_De_La_Encuesta__c, ONE_Motivos__c, ONE_Link_A_La_Encuesta__c, ONE_Valoracion_NPS__c, ONE_Fecha_respuesta__c, ONE_Contacto_urgente__c
            FROM ONE_Expediente__c
            WHERE Name = :expediente.Name
        ];
        System.assertNotEquals(COMENTARIO, expediente.ONE_Comentario_De_La_Encuesta__c);
        System.assertNotEquals(url.split('\\/ws')[0] + LINK, expediente.ONE_Link_A_La_Encuesta__c);
        System.assertNotEquals(VALORACION, expediente.ONE_Valoracion_NPS__c);
        System.assertNotEquals(MOTIVOS, expediente.ONE_Motivos__c);
        System.assertNotEquals(true, expediente.ONE_Contacto_urgente__c);
        System.assertNotEquals(DateTime.valueOF(FECHA_RESPUESTA), expediente.ONE_Fecha_respuesta__c);
    }
}
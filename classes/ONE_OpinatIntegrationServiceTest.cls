/**
 * Created by mkuzak001 on 01.02.2021.
 */

@IsTest
@TestVisible
private class ONE_OpinatIntegrationServiceTest {
    private static final String COMENTARIO = 'Comment';
    private static final String MOTIVO_0 = 'Motivo 0';
    private static final String MOTIVO_1 = 'Motivo 1';
    private static final String MOTIVO_2 = 'Motivo 2';
    private static final String MOTIVOS = String.join(new List<String>{MOTIVO_0, MOTIVO_1, MOTIVO_2}, '\n');
    private static final String LINK = '/index.php/url/view?id=423532';
    private static final String URGENTE = '1';
    private static final Integer VALORACION = 3;
    private static final String CODIGO_ENCUESTADO = '123';
    private static final String FECHA_RESPUESTA = '2016-10-28 11:29:06';
    
    @IsTest
    static void correctDataReceivedWhenCorrectRequestIsSent() {
        List<ONE_OpinatIntegrationService.ResponseWrapper> responseWrappers = new List<ONE_OpinatIntegrationService.ResponseWrapper>{
            new ONE_OpinatIntegrationService.ResponseWrapper(COMENTARIO, MOTIVOS, LINK, URGENTE,
                String.valueOf(VALORACION), CODIGO_ENCUESTADO, FECHA_RESPUESTA)
        };
        
        Test.setMock(HttpCalloutMock.class, new OpinatIntegrationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success',
            new Map<String, String>(), responseWrappers));
        
        Test.startTest();
        
        ONE_OpinatIntegrationService.OpinatIntegrationCallout callout =
            new ONE_OpinatIntegrationService.OpinatIntegrationCallout(CODIGO_ENCUESTADO, Date.today(), Date.today());
        HttpResponse res = callout.invokeCallout();
    
        Map<String, ONE_OpinatIntegrationService.ResponseWrapper> codigoEncuestadoToWrapper = ONE_OpinatIntegrationService.parseResponse(res);
        
        Test.stopTest();
        
        System.assertEquals(responseWrappers.size(), codigoEncuestadoToWrapper.size());
        ONE_OpinatIntegrationService.ResponseWrapper encuesta = codigoEncuestadoToWrapper.get(CODIGO_ENCUESTADO);
        System.assertNotEquals(null, encuesta);
        System.assertEquals(LINK, encuesta.getLink());
        System.assertEquals(URGENTE, encuesta.getContactoUrgente());
        System.assertEquals(COMENTARIO, encuesta.getComentario());
        System.assertEquals(MOTIVOS, encuesta.getMotivos());
        System.assertEquals(VALORACION, Integer.valueOf(encuesta.getValoracion()));
    }
    
    @IsTest
    static void correctDataReceivedInCaseOfRedirect() {
        List<ONE_OpinatIntegrationService.ResponseWrapper> responseWrappers = new List<ONE_OpinatIntegrationService.ResponseWrapper>{
            new ONE_OpinatIntegrationService.ResponseWrapper(COMENTARIO, MOTIVOS, LINK, URGENTE,
                String.valueOf(VALORACION), CODIGO_ENCUESTADO, FECHA_RESPUESTA)
        };
        
        Test.setMock(HttpCalloutMock.class, new OpinatIntegrationMock(ONE_CommonConstants.HTTP_TEMPORARY_REDIRECT_CODE, 'success',
            new Map<String, String>{'Location' => LINK}, responseWrappers));
        
        Test.startTest();
        
        ONE_OpinatIntegrationService.OpinatIntegrationCallout callout =
            new ONE_OpinatIntegrationService.OpinatIntegrationCallout(CODIGO_ENCUESTADO, Date.today(), Date.today());
        HttpResponse res = callout.invokeCallout();
        
        Map<String, ONE_OpinatIntegrationService.ResponseWrapper> codigoEncuestadoToWrapper = ONE_OpinatIntegrationService.parseResponse(res);
        
        Test.stopTest();
        
        System.assertEquals(responseWrappers.size(), codigoEncuestadoToWrapper.size());
        ONE_OpinatIntegrationService.ResponseWrapper encuesta = codigoEncuestadoToWrapper.get(CODIGO_ENCUESTADO);
        System.assertNotEquals(null, encuesta);
        System.assertEquals(LINK, encuesta.getLink());
        System.assertEquals(URGENTE, encuesta.getContactoUrgente());
        System.assertEquals(COMENTARIO, encuesta.getComentario());
        System.assertEquals(MOTIVOS, encuesta.getMotivos());
        System.assertEquals(VALORACION, Integer.valueOf(encuesta.getValoracion()));
    }
    
    @TestVisible
    private class OpinatIntegrationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected Map<String, String> responseHeaders;
        protected List<ONE_OpinatIntegrationService.ResponseWrapper> encuestas;
        
        public OpinatIntegrationMock(Integer code, String status, Map<String, String> responseHeaders, List<ONE_OpinatIntegrationService.ResponseWrapper> encuestas) {
            this.code = code;
            this.status = status;
            this.responseHeaders = responseHeaders;
            this.encuestas = encuestas;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            res.setBody(buildResponseBody(encuestas));
            return res;
        }
        
        private String buildResponseBody(List<ONE_OpinatIntegrationService.ResponseWrapper> encuestas) {
            Dom.Document doc = new Dom.Document();
            Dom.XmlNode encuestadoNode = doc.createRootElement('encuestado', null, null);
            
            for (ONE_OpinatIntegrationService.ResponseWrapper encuesta : encuestas) {
                Dom.XmlNode encuestaNode = encuestadoNode.addChildElement('encuesta', null, null);
                encuestaNode.addChildElement('codigo_encuestado', null, null)
                    .addTextNode(encuesta.getCodigoEncuestado());
                encuestaNode.addChildElement('link', null, null)
                    .addTextNode(encuesta.getLink());
                
                encuestaNode.addChildElement('contacto_urgente', null, null)
                    .addTextNode(encuesta.getContactoUrgente());

                encuestaNode.addChildElement('fecha_respuesta', null, null)
                    .addTextNode(encuesta.getFechaRespuesta());
                
                Dom.XmlNode respuestaNode = encuestaNode.addChildElement('respuesta', null, null);
                respuestaNode.addChildElement('valoracion', null, null)
                    .addTextNode(encuesta.getValoracion());
                
                Dom.XmlNode motivosNode = respuestaNode.addChildElement('motivos', null, null);
                List<String> motivos = encuesta.getMotivos().split('\n');
                Integer idx = 0;
                for (String motivo : motivos) {
                    motivosNode.addChildElement('motivo_' + idx, null, null).addTextNode(motivo);
                    idx++;
                }
                
                respuestaNode.addChildElement('comentario', null, null).addTextNode(encuesta.getComentario());
            }
            
            return doc.toXmlString();
        }
    }
}
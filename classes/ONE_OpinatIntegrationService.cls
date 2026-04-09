/**
 * Created by mkuzak001 on 21.01.2021.
 */

public with sharing class ONE_OpinatIntegrationService {
    private static final String OPINAT_NIF_CLIENTE = 'B85012441';
    private static final String DATE_FORMAT = 'dd/MM/yyyy';
    
    public class OpinatIntegrationCallout extends ONE_Integration.IntegrationCallout {
        public OpinatIntegrationCallout(String codigoCampanya, Date fromDate, Date toDate) {
            super(ONE_CommonConstants.CM_OPINAT_LEAD_SERVICE, ONE_Integration.RestMethod.GET);
            fromDate = fromDate.addDays(-1); // Subtracts one day from the fromDate
            buildEndpoint();
            setBody(buildBody(OPINAT_NIF_CLIENTE, codigoCampanya, fromDate, toDate));
        }
        
        public override String buildEndpoint() {
            String endpoint = [
                SELECT Endpoint
                FROM NamedCredential
                WHERE DeveloperName = :endpointData.ONE_Named_Credentials__c
            ].Endpoint;
            return endpoint;
        }
        
        public String buildBody(String nifCliente, String codigoCampanya, Date fromDate, Date toDate) {
            DOM.Document doc = new DOM.Document();
            
            Dom.XmlNode historicoNode = doc.createRootElement('historico', null, null);
            
            addClienteNode(historicoNode, nifCliente, codigoCampanya);
            addEncuestadoNode(historicoNode, nifCliente, codigoCampanya, fromDate, toDate);
            
            return doc.toXmlString();
        }
        
        public void addEncuestadoNode(Dom.XmlNode historicoNode, String nifCliente, String codigoCampanya, Date fromDate, Date toDate) {
            Dom.XmlNode encuestadoNode = historicoNode.addChildElement('encuestado', null, null);
            encuestadoNode.addChildElement('nif_cliente', null, null)
                .addTextNode(nifCliente);
            encuestadoNode.addChildElement('codigo_campanya', null, null)
                .addTextNode(codigoCampanya);
            encuestadoNode.addChildElement('fecha_desde', null, null)
                .addTextNode(((DateTime) fromDate).format(DATE_FORMAT));
            encuestadoNode.addChildElement('fecha_hasta', null, null)
                .addTextNode(((DateTime) toDate).format(DATE_FORMAT));
            encuestadoNode.addChildElement('estado', null, null)
                .addTextNode('R');
        }
        
        public void addClienteNode(Dom.XmlNode historicoNode, String nifCliente, String codigoCampanya) {
            Dom.XmlNode clienteNode = historicoNode.addChildElement('cliente', null, null);
            
            clienteNode.addChildElement('username', null, null)
                .addTextNode('salesforce.memora');
            clienteNode.addChildElement('contrasenya', null, null)
                .addTextNode(EncodingUtil.convertToHex(getPassword(nifCliente, codigoCampanya)));
        }
        
        private Blob getPassword(String idNumber, String campaignCode) {
            String passwordStr = 'salesforce.memorac{0}ocen{1}citp{2}';
            Blob passwordMd5 = Crypto.generateDigest('MD5', Blob.valueOf('Memora.2021'));
            
            return Crypto.generateDigest('SHA1',
                Blob.valueOf(
                    String.format(passwordStr,
                        new List<String>{
                            campaignCode, idNumber, EncodingUtil.convertToHex(passwordMd5)
                        }
                    )
                )
            );
        }
        
        public override HttpResponse invokeCallout() {
            if (!isActive()) {
                throw new ONE_Exception(
                    ONE_Exception.ExceptionType.INTEGRATION,
                    String.format(
                        'Integration endpoint {0} is inactive',
                        new List<String>{
                            endpointData.ONE_Named_Credentials__c
                        }
                    )
                );
            }
            
            HttpRequest req = buildRequest();
            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() == ONE_CommonConstants.HTTP_TEMPORARY_REDIRECT_CODE) {
                req = buildRequest();
                String location = res.getHeader('Location');
                req.setEndpoint(location);
                res = new Http().send(req);
            }

            if(isLogActive() && !Test.isRunningTest()) {
                ONE_IntegrationLog integrationLog = new ONE_IntegrationLog(
                    String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')),
                    req.getBody(),
                    res.getBody(),
                    req.getMethod(),
                    req.getEndpoint(),
                    ONE_IntegrationLog.Direction.OUTBOUND
                );

                System.debug(integrationLog);
                ONE_IntegrationLog.commitLog(integrationLog, true, true);
            }

            return res;
        }
    }
    
    public static Map<String, ResponseWrapper> parseResponse(HttpResponse res) {
        System.debug('res-->' + res); 
        Dom.Document body = res.getBodyDocument();
        System.debug('body-->' + body);
        Map<String, ResponseWrapper> codigoEncuestadoToWrapper = new Map<String, ResponseWrapper>();
        Dom.XmlNode encuestadoNode = body.getRootElement();
        for (Dom.XmlNode encuestaNode : encuestadoNode.getChildElements()) {
            //System.debug('encuestaNode-->' + encuestaNode);
            Dom.XmlNode codigoEncuestadoNode = encuestaNode.getChildElement('codigo_encuestado', null);
            //System.debug('codigoEncuestadoNode-->' + codigoEncuestadoNode);
            String codigoEncuestado = codigoEncuestadoNode ?.getText();
            System.debug('codigoEncuestado-->' + codigoEncuestado);

            if (String.isNotBlank(codigoEncuestado)) {
                
                String link = encuestaNode.getChildElement('link', null) ?.getText();
                String contactoUrgente = encuestaNode.getChildElement('contacto_urgente', null) ?.getText();
                String fechaRespuesta = encuestaNode.getChildElement('fecha_respuesta', null) ?.getText();
                system.debug('fechaRespuesta--> ' + fechaRespuesta);
                
                Dom.XmlNode respuestaNode = encuestaNode.getChildElement('respuesta', null);    
                System.debug('respuestaNode-->' + respuestaNode);

                String cometario = respuestaNode.getChildElement('comentario', null) ?.getText();
                String motivos = getMotivosString(respuestaNode.getChildElement('motivos', null));
                String valoracion = respuestaNode.getChildElement('valoracion', null) ?.getText();
                //System.debug('cometario-->' + cometario);
                //System.debug('motivos-->' + motivos);
                //System.debug('valoracion-->' + valoracion);
                codigoEncuestadoToWrapper.put(
                    codigoEncuestado,
                    new ResponseWrapper(cometario, motivos, link, contactoUrgente, valoracion, codigoEncuestado, fechaRespuesta)
                );
            }
        }
        return codigoEncuestadoToWrapper;
    }
    
    private static String getMotivosString(Dom.XmlNode motivosNode) {
        String motivosString = '';
        
        Integer index = 0;
        Dom.XmlNode node = motivosNode.getChildElement('motivo_' + index, null);
        while (node != null) {
            motivosString += node.getText();
            node = motivosNode.getChildElement('motivo_' + (++index), null);
            if (node != null) {
                motivosString += '\n';
            }
        }
        
        return motivosString;
    }
    
    public class ResponseWrapper {
        private String comentario;
        private String motivos;
        private String link;
        private String contactoUrgente;
        private String valoracion;
        private String codigoEncuestado;
        private String fechaRespuesta;
        
        public ResponseWrapper(String comentario, String motivos, String link, String contactoUrgente, String valoracion, String codigoEncuestado, String fechaRespuesta) {
            this.comentario = comentario;
            this.motivos = motivos;
            this.link = link;
            this.contactoUrgente = contactoUrgente;
            this.valoracion = valoracion;
            this.codigoEncuestado = codigoEncuestado;
            this.fechaRespuesta = fechaRespuesta;
        }
        
        public String getComentario() {
            return comentario;
        }
        
        public String getMotivos() {
            return motivos;
        }
        
        public String getLink() {
            return link;
        }

        public String getContactoUrgente() {
            return contactoUrgente;
        }
        
        public String getValoracion() {
            return valoracion;
        }
        
        public String getCodigoEncuestado() {
            return codigoEncuestado;
        }

        public String getFechaRespuesta() {
            return fechaRespuesta;
        }
    }
}
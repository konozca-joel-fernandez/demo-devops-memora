/**
 * Created by mkuzak001 on 02.02.2021.
 * Modified by Marc Cervilla on 27.01.2025 - Add momento
 */

 public abstract with sharing class ONE_FuneflorIntegrationCallout extends ONE_Integration.IntegrationCallout {
    public ONE_FuneflorIntegrationCallout(String endpointMetadataName, ONE_Integration.RestMethod restMethod) {
        super(endpointMetadataName, restMethod);
        putHeader(ONE_Integration.HEADER_ACCEPT_CHARSET, ONE_Integration.ENCODING_UTF8);
        putHeader(ONE_Integration.HEADER_CT, ONE_Integration.CT_JSON + '; charset=UTF-8');
        putHeader(ONE_Integration.HEADER_X_REQUESTED_WITH, 'X');
        putHeader(ONE_Integration.HEADER_ACCEPT, ONE_Integration.CT_JSON);
        if(ONE_CommonConstants.CM_FUNEFLOR == endpointMetadataName) {
            putHeader(ONE_Integration.TOKEN, ONE_FuneflorIntegrationCredentials__c.getInstance().ONE_Token__c);
        }
        else if(ONE_CommonConstants.CM_FLORESMEMORA == endpointMetadataName) {
            putHeader(ONE_Integration.TOKEN, ONE_FloresMemoraIntegrationCredentials__c.getInstance().ONE_Token__c);
        }
        else if(ONE_CommonConstants.CM_MEDIAGEN == endpointMetadataName) {
            putHeader(ONE_Integration.TOKEN, ONE_MediagenIntegrationCredentials__c.getInstance().ONE_Token__c);
        }
    }
    
    public String buildRequestBody(ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        ONE_FuneflorIntegrationCallout.Cabecera cabecera = buildRequestCabecera(pedido, tarea);
        ONE_FuneflorIntegrationCallout.Linea linea = buildRequestLinea(tarea);
        List<ONE_FuneflorIntegrationCallout.Momento> momentos = buildRequestMomentos(tarea);
        
        ONE_FuneflorIntegrationCallout.RequestEntryWrapper requestEntryWrapper =
            new ONE_FuneflorIntegrationCallout.RequestEntryWrapper(cabecera, new List<ONE_FuneflorIntegrationCallout.Linea>{linea}, momentos);
        System.debug('### body ' + JSON.serialize(new List<ONE_FuneflorIntegrationCallout.RequestEntryWrapper>{requestEntryWrapper}));
        return JSON.serialize(new List<ONE_FuneflorIntegrationCallout.RequestEntryWrapper>{requestEntryWrapper});
    }
    
    protected virtual Cabecera buildRequestCabecera(ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        return null;
    }
    
    protected virtual Linea buildRequestLinea(ONE_Tarea__c tarea) {
        return null;
    }

    protected virtual List<Momento> buildRequestMomentos(ONE_Tarea__c tarea) {
        return null;
    }
    
    public class RequestEntryWrapper {
        private Cabecera CABECERA;
        private List<Linea> LINEAS;
        private List<Momento> MOMENTOS;
        
        public RequestEntryWrapper(Cabecera cab, List<Linea> lineas, List<Momento> momentos) {
            this.CABECERA = cab;
            this.LINEAS = lineas;
            this.MOMENTOS = momentos;
        }
    }
    
    public abstract class Cabecera {
    }
    
    public abstract class Linea {
    }

    public class Momento {
        public String id_mom;
        public String nomenv;
        public String direnv;
        public String id_posenv;
        public String pobenv;
        public String telcontacto;
        public String movcontacto;
        public Integer sala;
        public String fecini;
        public String fecfin;
        public String horini;
        public String horfin;
    }
    
    public class ONE_FuneflorIntegrationCalloutException extends Exception {}
}
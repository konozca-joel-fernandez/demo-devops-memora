/**
 * Created by Miguel Serrat on 10.11.2023
 * 
 * LOGs:
 * -------------------------------------------
 * DATE       USER            CHANGE
 * -------------------------------------------
 */

public class ONE_ObispadoCanariasIntegrationCallout {
    
    public static final Map<String, Object> jsonHeaders = new Map<String, Object>{
        ONE_Integration.HEADER_CT => ONE_Integration.CT_JSON
    };
        
    public static final Map<String, Object> webFormHeaders = new Map<String, Object>{
        ONE_Integration.HEADER_CT => 'application/x-www-form-urlencoded'
    };

    public virtual class ExequiaTokenCallout extends ONE_Integration.IntegrationCallout {
        public ExequiaTokenCallout() {
            super('ONE_EXEQUIA_TOKEN', ONE_Integration.RestMethod.POST);
            //System.debug('ONE_EXEQUIA_TOKEN');
            putHeaders(jsonHeaders);
            putParam('gettoken', 1);
            putParam('usuario', 'memora');
            putParam('clave', '123asAd24*23a');
            setBody('');
        }
    }
    
    public static String getToken(){
        ONE_Integration.IntegrationCallout callout;
        callout = new ExequiaTokenCallout();
        system.debug('callout: ' + callout);
        HttpResponse res = callout.invokeCallout(true);
        System.debug('maya: RES BODY:' + res.getBody());
        Map<String, String> returnMap = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);
        System.debug('maya: TOKEN ' + returnMap.get('data'));
        return returnMap.get('data');
    }
        
    public class CrearActualizarExequiaCallout extends ONE_Integration.IntegrationCallout {
        public CrearActualizarExequiaCallout(Map<String, Object> params){
        	super('ONE_EXEQUIA_CREAR_ACTUALIZAR', ONE_Integration.RestMethod.POST);
            System.debug('ONE_EXEQUIA_CREAR_ACTUALIZAR');
            putheaders(jsonHeaders);
            params.put(token, getToken());
            for(String key : params.keySet()){
                putParam(key, params.get(key));
            }
            setBody('');
        }
    }
    
    public class ValidacionPagoBase64Callout extends ONE_Integration.IntegrationCallout {
        public ValidacionPagoBase64Callout(Map<String, Object> params, String body) {
            super('ONE_EXEQUIA_CREAR_ACTUALIZAR', ONE_Integration.RestMethod.POST);
            System.debug('ONE_EXEQUIA_CREAR_ACTUALIZAR');
            putHeaders(webFormHeaders);
            params.put(token, getToken());
           	for(String key : params.keySet()){
                putParam(key, params.get(key));
            }
            setBody(body);
        }
    }
}
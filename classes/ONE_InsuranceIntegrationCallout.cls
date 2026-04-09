/**
 * Created by mbujak003 on 19.01.2021.
 */

public without sharing class ONE_InsuranceIntegrationCallout {

    public enum InsuranceService {
        CAJAMAR,
        GENERALI,
        KUTXABANK,
        KUTXABANKBATCH
    }

    public static final Map<String, Object> jsonInsuranceServiceHeaders = new Map<String, Object>{
        ONE_Integration.HEADER_CT => ONE_Integration.CT_JSON,
        ONE_Integration.HEADER_VINSHIELD => ONE_Integration.VINSHIELD
    };

    public static final Map<String, Object> xmlInsuranceServiceHeaders = new Map<String, Object>{
        ONE_Integration.HEADER_CT => ONE_Integration.CT_TEXT_XML,
        ONE_Integration.HEADER_ACCEPT => ONE_Integration.CT_APP_XML
    };

    public abstract class InsuranceLoginCallout extends ONE_Integration.IntegrationCallout {
        public InsuranceLoginCallout(InsuranceService service) {
            super((service == InsuranceService.CAJAMAR ? ONE_CommonConstants.CM_CAJAMAR_LOGIN : ONE_CommonConstants.CM_GENERALI_LOGIN), ONE_Integration.RestMethod.POST);
            ONE_InsuranceIntegrationCredentials__c integrationCredentials = ONE_InsuranceIntegrationCredentials__c.getValues(String.valueOf(service));
            System.debug([Select id from ONE_InsuranceIntegrationCredentials__c]);
            Map<String, String> loginRequest = new Map<String, String>{
                'company' => integrationCredentials.ONE_Company__c,
                'user' => integrationCredentials.ONE_Username__c,
                'password' => integrationCredentials.ONE_Password__c
            };
            setBody(JSON.serialize(loginRequest));
            putHeaders(jsonInsuranceServiceHeaders);
        }
    }

    public class CajamarLoginCallout extends InsuranceLoginCallout {
        public CajamarLoginCallout() {
            super(InsuranceService.CAJAMAR);
        }
    }

    public class GeneraliLoginCallout extends InsuranceLoginCallout {
        public GeneraliLoginCallout() {
            super(InsuranceService.GENERALI);
        }
    }

    public static String getSessionId(InsuranceService service) {
        ONE_Integration.IntegrationCallout callout;
        switch on service {
            when CAJAMAR {
                callout = new CajamarLoginCallout();
            }
            when GENERALI {
                callout = new GeneraliLoginCallout();
            }
        }
        HttpResponse res = callout.invokeCallout(true);
        Map<String, String> returnMap = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);
        return returnMap.get('sesion');
    }

    public abstract class InsuranceCallout extends ONE_Integration.IntegrationCallout {
        public InsuranceCallout(Object params, InsuranceService service) {

            super((service == InsuranceService.CAJAMAR ? ONE_CommonConstants.CM_CAJAMAR_SERVALIDA : service == InsuranceService.GENERALI ? ONE_CommonConstants.CM_GENERALI_SERVALIDA : service == InsuranceService.KUTXABANK ? ONE_CommonConstants.CM_MIDDLEWARE_KBS_CP : ''), ONE_Integration.RestMethod.POST);

            if(service == InsuranceService.CAJAMAR || service == InsuranceService.GENERALI){
                putheaders(jsonInsuranceServiceHeaders);
                putHeader(ONE_Integration.HEADER_AUTHORIZATION, 'Bearer ' + getSessionId(service));
                setBody(JSON.serialize(params));
            } else if (service == InsuranceService.KUTXABANK){ 
                // putheaders(xmlInsuranceServiceHeaders);
                // putHeader('SOAPAction', 'http://wcf.catalanaoccidente.com/VID/Gestion/Asistea/BE/KBS/ConsultaPoliza');
                // Map<String, String> values = (Map<String, String>)JSON.deserialize(JSON.serialize(params), Map<String, String>.class);
                // setBody(buildConsultaPolizaXML(values));
                putHeader(ONE_Integration.HEADER_CT, ONE_Integration.CT_JSON);
                ONE_InsuranceIntegrationCredentials__c credentials = ONE_InsuranceIntegrationCredentials__c.getValues(ONE_CommonConstants.CM_KUTXABANK);
                Map<String, Object> values = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(params));
                values.put('username', credentials.ONE_Username__c);
                values.put('password', credentials.ONE_Password__c);
                setBody(JSON.serialize(values));
            }
        }

    //     public String buildConsultaPolizaXML(Map<String, String> params){
    //         System.debug('PARAMS:' + params);
    //         String nif = params.get('NIFAsegurado');
    //         String nPoliza = params.get('NumPoliza');
    //         String occDate = params.get('FechaOcurrencia');
    //         return ('<s:Envelope' + '\n' +
    //             'xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' + '\n' +
    //             '<s:Body>' + '\n' +
    //                 '<ConsultaPoliza' + '\n' +
    //                     'xmlns="http://wcf.catalanaoccidente.com/VID/Gestion/Asistea/BE/KBS/ConsultaPoliza">' + '\n' +
    //                     '<entrada' + '\n' +
    //                         'xmlns:d4p1="http://schemas.datacontract.org/2004/07/VID.Gestion.Asistea.BE.KBS"' + '\n' +
    //                         'xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' + '\n' +
    //                         '<d4p1:FechaOcurrencia>'+ occDate +'</d4p1:FechaOcurrencia>' + '\n' +
    //                         '<d4p1:NIFAsegurado>'+ nif +'</d4p1:NIFAsegurado>' + '\n' +
    //                         '<d4p1:NumPoliza>'+ nPoliza +'</d4p1:NumPoliza>' + '\n' +
    //                         '<d4p1:Proveedor>'+ Label.Asistea +'</d4p1:Proveedor>' + '\n' +
    //                     '</entrada>' + '\n' +
    //                 '</ConsultaPoliza>' + '\n' +
    //             '</s:Body>' + '\n' +
    //         '</s:Envelope>');
    //     }
    }

    public virtual class KutxabankInsuranceCallout extends InsuranceCallout {
        public KutxabankInsuranceCallout(Object params) {
            super(params, InsuranceService.KUTXABANK);
        }
    }

    public virtual class CajamarInsuranceCallout extends InsuranceCallout {

        public CajamarInsuranceCallout(Object params) {
            super(params, InsuranceService.CAJAMAR);
        }
    }

    public virtual class GeneraliInsuranceCallout extends InsuranceCallout {

        public GeneraliInsuranceCallout(Object params) {
            super(params, InsuranceService.GENERALI);
        }
    }

    public abstract class InsuranceBudgetCallout extends ONE_Integration.IntegrationCallout {                
        public InsuranceBudgetCallout(Object params, InsuranceService service) { 
            super((
                service == InsuranceService.KUTXABANK ? ONE_CommonConstants.CM_MIDDLEWARE_KBS_AF :
                service == InsuranceService.KUTXABANKBATCH ? ONE_CommonConstants.CM_MIDDLEWARE_KBS_AF_NOLOGS :
                (service == InsuranceService.CAJAMAR ? ONE_CommonConstants.CM_CAJAMAR_NEW_BUDGET : ONE_CommonConstants.CM_GENERALI_NEW_BUDGET)),
                ONE_Integration.RestMethod.POST
            );
            if (service == InsuranceService.KUTXABANK || service == InsuranceService.KUTXABANKBATCH) {
                putHeader(ONE_Integration.HEADER_CT, ONE_Integration.CT_JSON);
                ONE_InsuranceIntegrationCredentials__c credentials = ONE_InsuranceIntegrationCredentials__c.getValues(ONE_CommonConstants.CM_KUTXABANK);
                Map<String, Object> values = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(params));
                values.put('username', credentials.ONE_Username__c);
                values.put('password', credentials.ONE_Password__c);
                setBody(JSON.serialize(values));
            }
            else {
                putHeaders(jsonInsuranceServiceHeaders);
                putHeader(ONE_Integration.HEADER_AUTHORIZATION, 'Bearer ' + getSessionId(service));
                setBody(JSON.serialize(params));
            }
        }
    }

    public virtual class CajamarCreateBudgetCallout extends InsuranceBudgetCallout {
        public CajamarCreateBudgetCallout(Object params) {
            super(params, InsuranceService.CAJAMAR);
        }
    }

    public virtual class GeneraliCreateBudgetCallout extends InsuranceBudgetCallout {
        public GeneraliCreateBudgetCallout(Object params) {
            super(params, InsuranceService.GENERALI);
        }
    }

    public virtual class KutxabankCreateBudgetCallout extends InsuranceBudgetCallout {
        public KutxabankCreateBudgetCallout(Object params) {
            super(params, InsuranceService.KUTXABANK);
        }
    }

    public virtual class KutxabankBatchCreateBudgetCallout extends InsuranceBudgetCallout {
        public KutxabankBatchCreateBudgetCallout(Object params) {
            super(params, InsuranceService.KUTXABANKBATCH);
        }
    }

    public abstract class InsuranceEditBudgetCallout extends ONE_Integration.IntegrationCallout {
        public InsuranceEditBudgetCallout(Object params, InsuranceService service) {
            super((service == InsuranceService.CAJAMAR ? ONE_CommonConstants.CM_CAJAMAR_EDIT_BUDGET : ONE_CommonConstants.CM_GENERALI_EDIT_BUDGET), ONE_Integration.RestMethod.POST);
            putHeaders(jsonInsuranceServiceHeaders);
            putHeader(ONE_Integration.HEADER_AUTHORIZATION, 'Bearer ' + getSessionId(service));
            setBody(JSON.serialize(params));
        }
    }

    public virtual class CajamarEditBudgetCallout extends InsuranceEditBudgetCallout {
        public CajamarEditBudgetCallout(Object params) {
            super(params, InsuranceService.CAJAMAR);
        }
    }

    public virtual class GeneraliEditBudgetCallout extends InsuranceEditBudgetCallout {
        public GeneraliEditBudgetCallout(Object params) {
            super(params, InsuranceService.GENERALI);
        }
    }

    public abstract class InsuranceInvoiceCallout extends ONE_Integration.IntegrationCallout {
        public InsuranceInvoiceCallout(Object params, InsuranceService service) {
            super((service == InsuranceService.CAJAMAR ? ONE_CommonConstants.CM_CAJAMAR_INVOICE : ONE_CommonConstants.CM_GENERALI_INVOICE), ONE_Integration.RestMethod.POST);
            putHeaders(jsonInsuranceServiceHeaders);
            putHeader(ONE_Integration.HEADER_AUTHORIZATION, 'Bearer ' + getSessionId(service));
            setBody(JSON.serialize(params));
        }
    }

    public virtual class CajamarInvoiceCallout extends InsuranceInvoiceCallout {
        public CajamarInvoiceCallout(Object params) {
            super(params, InsuranceService.CAJAMAR);
        }
    }

    public virtual class GeneraliInvoiceCallout extends InsuranceInvoiceCallout {
        public GeneraliInvoiceCallout(Object params) {
            super(params, InsuranceService.GENERALI);
        }
    }

    public virtual class Base64Callout extends ONE_Integration.IntegrationCallout {
        public Base64Callout(String body, InsuranceService service) {
            super((service == InsuranceService.CAJAMAR ? ONE_CommonConstants.CM_CAJAMAR_BASE64 : ONE_CommonConstants.CM_GENERALI_BASE64), ONE_Integration.RestMethod.POST);
            putHeaders(jsonInsuranceServiceHeaders);
            putHeader(ONE_Integration.HEADER_AUTHORIZATION, 'Bearer ' + getSessionId(service));
            setBody(body);
        }
    }

    public virtual class CajamarBase64Callout extends Base64Callout {
        public CajamarBase64Callout(String body) {
            super(body, InsuranceService.CAJAMAR);
        }
    }

    public virtual class GeneraliBase64Callout extends Base64Callout {
        public GeneraliBase64Callout(String body) {
            super(body, InsuranceService.GENERALI);
        }
    }






//    public virtual class GeneraliBase64Callout extends ONE_Integration.IntegrationCallout {
//        public GeneraliBase64Callout(String body) {
//            super(ONE_CommonConstants.CM_GENERALI_BASE64, ONE_Integration.RestMethod.POST);
//            putHeaders(jsonInsuranceServiceHeaders);
//            putHeader(ONE_Integration.HEADER_AUTHORIZATION, 'Bearer ' + getSessionId(InsuranceService.GENERALI));
//            setBody(body);
//        }
//    }
}
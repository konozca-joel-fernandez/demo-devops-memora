/**
 * Created by  on  .
 */

public with sharing class ONE_CDBGraveStatusRequestBuilder {
    
    public static Dom.Document buildRequest(ONE_Presupuesto__c onePresupuesto) {
        Dom.Document soapXMLDocument = new Dom.Document();
        buildBaseParameters(ONE_CDBSoapRequestBuilder.buildRequestBodyBase(soapXMLDocument), onePresupuesto);
        return soapXMLDocument;
    }

    static void buildBaseParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'codi', onePresupuesto?.ONE_Codigo_General_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'cement', onePresupuesto?.ONE_Expediente__r?.ONE_Destino_Final__r?.ONE_Codigo_Cementerio_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'recint', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_De_Recinto_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'depart', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_De_Departamento_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'villaz', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_De_Via_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'agrupa', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_De_Agrupacion_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'tipsep', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_Tipo_De_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'clasep', onePresupuesto?.ONE_Expediente__r?.ONE_Clase_De_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'numsep', onePresupuesto?.ONE_Expediente__r?.ONE_Numero_De_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'bissep', onePresupuesto?.ONE_Expediente__r?.ONE_BIS_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'pissep', onePresupuesto?.ONE_Expediente__r?.ONE_PIS_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'nomtit', onePresupuesto?.ONE_Expediente__r?.ONE_Nombre_Titular_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'cog1tit', onePresupuesto?.ONE_Expediente__r?.ONE_Primer_Apellido_Titular_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'cog2tit', onePresupuesto?.ONE_Expediente__r?.ONE_Segundo_Apellido_Titular_Sepultur_CB__c);
    }
}
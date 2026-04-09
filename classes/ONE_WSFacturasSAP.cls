/*****************************************************************************************************************************************
Apex class Name:  	ONE_WSFacturasSAP.cls
Version:            1.0
Created Date:       27/06/2023
Function:           Apex class que implementa el Web Service para recibir facturas de SAP.
Author:             Joan Marinel·lo
Company:            Konozca

History: 
<Date>                  <Dev Name>                              <Change Description>
27/06/2023              Joan Marinel·lo	                 		Creación de la clase 

*****************************************************************************************************************************************/


@RestResource(urlMapping='/ONE_Orden_De_Venta__c/*')
global with sharing class ONE_WSFacturasSAP {

    @HttpPatch
    global static Map<String, List<ONE_Orden_De_Venta__c>> updateOrdenDeVenta() {

        Map<String, Object> dataMap = new Map<String, Object>();
        Map<String, Boolean> OVMap = new Map<String, Boolean>();
        Map<String, List<ONE_Orden_De_Venta__c>> res = new Map<String, List<ONE_Orden_De_Venta__c>>();
        String msg;
        RestResponse result = RestContext.response;
        String NFactura;
        Boolean Compensado;

        //log info
        String CLASS_NAME = 'ONE_WSFacturasSAP';
        String ENDPOINT_NAME = 'SF_FACTURAS';

        RestRequest request = RestContext.request;

        // Get String Body
        String requestStr = RestContext.request.requestBody.toString();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        List<Object> dataList = (List<Object>)responseMap.get('data');

        for(Object Factura : dataList){
            dataMap = (Map<String, Object>)Factura;
            NFactura = (String)dataMap.get('factura');
            Compensado = (Boolean)dataMap.get('compensado');
            OVMap.put(NFactura, Compensado);
        }     

        List<ONE_Orden_De_Venta__c> thisOV = [SELECT Id, ONE_Numero_de_factura__c, ONE_Compensado__c, ONE_Fecha_de_compensaci_n__c FROM ONE_Orden_De_Venta__c WHERE ONE_Numero_de_factura__c IN :OVMap.keySet()];

        System.debug('Nana 4: thisOV - ' + thisOV);
        for(ONE_Orden_De_Venta__c OV : thisOV) {
            if(OVMap.get(OV.ONE_Numero_de_factura__c)){
                OV.ONE_Fecha_de_compensaci_n__c = System.today();
            } else{
                OV.ONE_Fecha_de_compensaci_n__c = null;
            }
            OV.ONE_Compensado__c = OVMap.get(OV.ONE_Numero_de_factura__c);
        }

        try{
            update thisOV;
        }catch(Exception ex){
            result.statusCode = 500;
            msg = ex.getMessage();
            res.put(msg, thisOV);
            return res;
        }
        
        if(thisOV.size() == 0){
            result.statusCode = 204;
            msg = 'No se han encontrado registros que coincidan con los números de factura introducidos.';
        } else if(thisOV.size() != dataList.size()){
            result.statusCode = 206;
            msg = 'No se han encontrado registros que coincidan con todos los números de factura. Se han actualizado solo aquellos registros encontrados.';
        } else{
            result.statusCode = 200;
            msg = 'Se han actualizado correctamente todos los registros.';
        }
        
        res.put(msg, thisOV);

        // Create entry in the integration log object

        ONE_CommonUtils.createInboundIntegrationLog(
            CLASS_NAME,
            requestStr,
            JSON.serialize(res),
            RestContext.request.httpMethod,
            ENDPOINT_NAME
        );

        return res;
    }

}
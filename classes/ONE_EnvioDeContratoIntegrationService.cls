/**
* Created by mbujak003 on 02.02.2021.
*/
//Class for the SAP factura/contract creation integration 
public with sharing class ONE_EnvioDeContratoIntegrationService {
    //Static variable definition for the integration
    public static final String BUKRS_1140 = '1140';
    public static final String BKTXT_FACTURA_ELECTIUM = 'FACTURA ELECTIUM';
    public static final String CONTRAPARTIDA_1 = '1';
    public static  String ELECCION_METADATA_WEBSERVICE = 'SAP_ELECTIUM_MES_COBROS';
    public static  String ELECCION_SCOPE_WEBSERVICE = 'ZONE_ELECTIUM_MES_COBROS_SRV_0001';
    
    public class ClientCreationCallout extends ONE_SAPCallout {
        public ClientCreationCallout(ClientCreationRequestOldWS orderRequest) {
            super(ELECCION_METADATA_WEBSERVICE, ONE_Integration.RestMethod.POST, ELECCION_SCOPE_WEBSERVICE);
            setBody(JSON.serialize(orderRequest).replace('null', '""').replace('x_Import', 'Import').replace('ZfechaCuota1":"","', ''));        
        }
        
        public ClientCreationCallout(ClientCreationRequestNewWS orderRequest) { 
            super(ELECCION_METADATA_WEBSERVICE, ONE_Integration.RestMethod.POST, ELECCION_SCOPE_WEBSERVICE);
            setBody(JSON.serialize(orderRequest).replace('null', '""').replace('x_Import', 'Import').replace('ZfechaCuota1":"","', ''));        
        }
    }
    //Invocable class for calling the integration via flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        
        System.debug('makineta6');
        ONE_Contrato__c aux = ONE_ContratoHelper.fetchContratosById(flowInputs[0].contractId);
        HttpResponse resp = new HttpResponse();
        Map<String, Object> errorMsg =  new Map<String, Object>();
        Map<String, Object> errorMsgValue = new Map<String, Object>();
        System.debug('makineta7');
        if(aux.ONE_Tipo_Contrato__c == 'Línea a Línea' || aux.ONE_Forma_de_Pago__c == '6' || aux.ONE_Total_P_V_P__c < 0)
        
        {
            
            System.debug('makineta1');
            Map<Id, ClientCreationRequestOldWS> accId2PurchaseOrderRequest = prepareDTORequestsOldWS(
                flowInputs[0].contractId,
                flowInputs[0].sapClientId     
       		 );
            
            ClientCreationCallout callout = new ClientCreationCallout(accId2PurchaseOrderRequest.values()[0]);
        	resp = callout.invokeCallout();
            if(resp.getBody().contains('error')){
                System.debug('makineta2');
                System.debug('MUDD DRAGGIN ' + resp.getBody());
                Map<String, Object> returnObject = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody()); // deserialize object
                aux.ONE_Fecha_de_Subida_a_SAP__c = Datetime.now().date();
                errorMsg = (Map<String, Object>)returnObject.get('error');
                errorMsgValue = (Map<String, Object>)returnObject.get('message');
                System.debug('coxedeljairo ' + errorMsgValue); 
                String aux2 = (String)errorMsgValue.get('value'); 
                aux.ONE_Datos_Incorrectos_Contrato__c = aux2; 
                update aux;
            }
           
        }
        
        else if(aux.ONE_Tipo_De_Contrato__c == 'Anexo' && aux.CreatedDate.year() <= 2023 && aux.CreatedDate.month() <= 12){
            System.debug('makineta3');
            Map<Id, ClientCreationRequestOldWS> accId2PurchaseOrderRequest = prepareDTORequestsOldWS(
                flowInputs[0].contractId,
                flowInputs[0].sapClientId     
       		 );
            ClientCreationCallout callout = new ClientCreationCallout(accId2PurchaseOrderRequest.values()[0]);
        	resp = callout.invokeCallout();
            if(resp.getBody().contains('error')){
                System.debug('makineta4');
                System.debug('GRECARIO ' + resp.getBody());
                Map<String, Object> returnObject = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody()); // deserialize object
                aux.ONE_Fecha_de_Subida_a_SAP__c = Datetime.now().date();
                errorMsg = (Map<String, Object>)returnObject.get('error');
                errorMsgValue = (Map<String, Object>)errorMsg.get('message');
                System.debug('coxedeljairo2 ' + errorMsgValue); 
                aux.ONE_Datos_Incorrectos_Contrato__c = (String)errorMsgValue.get('value'); 
                update aux;
            }
        }
        
        else{
            System.debug('makineta5');
            Map<Id, ClientCreationRequestNewWS> accId2PurchaseOrderRequest = prepareDTORequestsNewWS(
                flowInputs[0].contractId,
                flowInputs[0].sapClientId     
       		 );
            
            ClientCreationCallout callout = new ClientCreationCallout(accId2PurchaseOrderRequest.values()[0]);
        	resp = callout.invokeCallout();
            if(resp.getBody().contains('error')){
                System.debug('makineta5');
                System.debug('ctds cartel' + resp.getBody());
                Map<String, Object> returnObject = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody()); // deserialize object
                aux.ONE_Fecha_de_Subida_a_SAP__c = Datetime.now().date();
                errorMsg = (Map<String, Object>)returnObject.get('error');
                errorMsgValue = (Map<String, Object>)errorMsg.get('message');
                System.debug('coxedeljairo4 ' + errorMsg); 
                System.debug('coxedeljairo3 ' + errorMsgValue); 
                aux.ONE_Datos_Incorrectos_Contrato__c = (String)errorMsgValue.get('value'); 
                update aux;
            }
        }
        
        


        FlowOutputs fo = new FlowOutputs();
        
        
        fo.success = false;
        //Get response an parse to extract the information
        Map<String, Object> respObject = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        String msg = '';
        String msgV2 = '';
        String eResult = 'E';
        try {
            Map<String, Object> innerObject = (Map<String, Object>) respObject.get('d');
            Map<String, Object> TiReturn = (Map<String, Object>) innerObject.get('TiReturn');
            List<Object> results = (List<Object>) TiReturn.get('results');
            
            msg = String.valueOf(((Map<String, Object>) results[0]).get('Message'));
            msgV2 = String.valueOf(((Map<String, Object>) results[0]).get('MessageV2')); // In this field the KO and OK message is store
            
            Map<String, Object> resultObject = (Map<String, Object>) innerObject.get('result');
            eResult = String.valueOf(resultObject.get('EResult'));
        } catch (Exception ex) {
            
        }
        
        fo.message = msg;
        fo.messageV2 = msgV2;
        
        if (eResult == 'S') {
            fo.success = true;
        } else {
            fo.success = false;
        }
        
        return new List<FlowOutputs>{
            fo
                };
                    }
    //Flow input variable definition
    public class FlowInputs {
        @InvocableVariable
        public String contractId;
        @InvocableVariable
        public String sapClientId;
    }
    //Flow output variable definition
    public class FlowOutputs {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String message;
        @InvocableVariable 
        public String messageV2;
    }
    //Prepare request
    public static Map<Id, ClientCreationRequestOldWS> prepareDTORequestsOldWS(String contractId, String sapClientId) {
        
        ONE_Contrato__c contracto = ONE_ContratoHelper.fetchContratosById(contractId);      
        Map<Id, ClientCreationRequestOldWS> accId2PurchaseOrderRequest = new Map<Id, ClientCreationRequestOldWS>();
        ClientCreationRequestOldWS request = new ClientCreationRequestOldWS(contracto, sapClientId);
        accId2PurchaseOrderRequest.put(contracto.Id, request);
        return accId2PurchaseOrderRequest;

            


    }
    
    
    public static Map<Id, ClientCreationRequestNewWS> prepareDTORequestsNewWS(String contractId, String sapClientId) {
        
        ONE_Contrato__c contracto = ONE_ContratoHelper.fetchContratosById(contractId);      
        Map<Id, ClientCreationRequestNewWS> accId2PurchaseOrderRequest = new Map<Id, ClientCreationRequestNewWS>();
        ClientCreationRequestNewWS request = new ClientCreationRequestNewWS(contracto, sapClientId);
        accId2PurchaseOrderRequest.put(contracto.Id, request);
        return accId2PurchaseOrderRequest;

            
    }
    //utility class for the date parse into a string
    private static String convertDate(Date dt) {
        return String.format(
            '\\/Date({0})\\/',
            new List<String>{
                String.valueOf(
                    Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0).addHours(2)).getTime()
                )
                    }
        );
    }

    public class ClientCreationRequestNewWS {
        
        public String IdXblnr { get; private set; }
        public String XblnrFra { get; private set; }
        public String XblnrCbr { get; private set; }	
        public String Kunnr { get; private set; }
        public String Bukrs { get; private set; }
        public String Bldat { get; private set; }
        public String Zlsch { get; private set; }
        public String Xref1 { get; private set; }
        public String Xref3 { get; private set; }
        public String ZformPago { get; private set; }
        public String ZtipoContrato {get; private set; }
        public String ZimpCuota1 {get; private set; }
        public String Mwskz { get; private set; }
        public String Kostl { get; private set; }
        public Integer Zcuotas {get; private set; }
        public String ZimpCuota {get; private set; }
        public String Bktxt { get; private set; }
        public String ZfechaCuota1 {get; private set; }
        public String ZcodPreventiva {get; private set; }
        public String Bvtyp {get; private set; }
        public String Zobserv {get; private set; }
        public String Sgtxt {get; private set; }
        
        
        public ClientCreationRequestNewWS(ONE_Contrato__c contracto, String sapClientId) {
            
            IdXblnr = '';
            XblnrFra = '';
            XblnrCbr = '';

            
            Kunnr = sapClientId;
            Bukrs = BUKRS_1140;

            if(contracto.ONE_Tipo_de_Pago__c != '1'){
                Zlsch = 'V';
            }
            else Zlsch = '1';
            if(contracto.ONE_Tipo_De_Contrato__c == 'Principal'){
                Xref1 = contracto.Name;
            }
            
            else{
                Xref1 = contracto.ONE_Numero_Contrato_Anexo__c;
            }
            
            if (contracto.ONE_Contratante__c != null) {
                if (contracto?.ONE_Contratante__r?.Owner.FirstName.length() + contracto?.ONE_Contratante__r?.Owner.LastName.length() + 1 > 20) {
                    Xref3 = (contracto?.ONE_Contratante__r?.Owner.FirstName + ' ' + contracto?.ONE_Contratante__r?.Owner.LastName).substring(0, 20);
                } else {
                    Xref3 = contracto?.ONE_Contratante__r?.Owner.FirstName + ' ' + contracto?.ONE_Contratante__r?.Owner.LastName;
                }
            }
            ZformPago = '0' + contracto.ONE_Forma_De_Pago__c;
            if (contracto.ONE_Forma_De_Pago__c == '5'){
                ZtipoContrato= '02'; 
                    }
            else ZtipoContrato = '01'; 
            if (contracto.ONE_Base_Impositiva__c != null){
                if (contracto.ONE_Base_Impositiva__c == '21') Mwskz = 'R7';
                else if (contracto.ONE_Base_Impositiva__c == '3') Mwskz = 'RT';
            }

            Bldat = convertDate(contracto.ONE_Fecha_De_Contrato__c);

            Kostl = contracto.ONE_Centro_de_Coste_Electium__c;
            Bktxt = BKTXT_FACTURA_ELECTIUM;
            if(contracto.ONE_Forma_De_Pago__c != '5') {
                Zcuotas = contracto.ONE_Num_Mensualidades__c.intValue();
                ZimpCuota = String.valueOf(contracto.ONE_Cuota_Mensual__c);
                //
            }	
            else {
                Zcuotas = 1;
				ZimpCuota = String.valueOf(contracto.ONE_Total_P_V_P__c); 
            }
            if (contracto.ONE_Importe_Primera_Mensualidad__c != null) {
                if(contracto.ONE_Forma_De_Pago__c != '5'){
                	ZimpCuota1 = String.valueOf(contracto.ONE_Importe_Primera_Mensualidad__c);
                }
                else ZimpCuota1 = '0.00';
            }
            
          
            if (contracto.ONE_Importe_Primera_Mensualidad__c == null){
                if(contracto.ONE_Fecha_Primera_Mensualidad__c != null){
                    ZfechaCuota1 =  convertDate(contracto.ONE_Fecha_Primera_Mensualidad__c);
                    ZimpCuota1 = '0.00';   
                }
                else{
                  ZfechaCuota1 =  convertDate(contracto.ONE_Fecha_De_Contrato__c);
            	  ZimpCuota1 = '0.00'; 
                }
            }
         
            else {
                if(contracto.ONE_Fecha_Primera_Mensualidad__c != null){
                    if(contracto.ONE_Forma_De_Pago__c != '5'){
                        ZfechaCuota1 =  convertDate(contracto.ONE_Fecha_Primera_Mensualidad__c);
                        ZimpCuota1 = String.valueOf(contracto.ONE_Importe_Primera_Mensualidad__c);
                    }
                    else{
                        ZimpCuota1 = '0.00';
                    }
                }
                else{
                    if(contracto.ONE_Forma_De_Pago__c != '5'){
                        ZfechaCuota1 =  convertDate(contracto.ONE_Fecha_De_Contrato__c);
                        ZimpCuota1 = String.valueOf(contracto.ONE_Importe_Primera_Mensualidad__c);
                }
                    else{
                         ZimpCuota1 = '0.00';
                    }
                }
                    
            }
            ZcodPreventiva = contracto.ONE_Codigo_Electium_Smart__c;
            Bvtyp = '';
            Zobserv = contracto.ONE_Observaciones_Generales__c;
            if(contracto?.ONE_Beneficiario_1__c != null){
                if ((contracto?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/') + ' - ' + contracto?.ONE_Beneficiario_1__r?.Name).length() < 50) {
                    Sgtxt = contracto?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/') + ' - ' + contracto?.ONE_Beneficiario_1__r?.Name != null? contracto?.ONE_Beneficiario_1__r?.Name:'';
                } else {
                    Sgtxt = (contracto?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/') + ' - ' + contracto?.ONE_Beneficiario_1__r?.Name != null? contracto?.ONE_Beneficiario_1__r?.Name:'').substring(50);
                }               
            }else{
                if ((contracto?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/')).length() < 50) {
                    Sgtxt = '';
                } else {
                    Sgtxt = '';
                }      
            }
        }
    }
    
    	//JSON structute header definition
    public class TFCabecera {
        public String IdXblnr { get; private set; }
        public String XblnrFra { get; private set; }
        public String XblnrCbr { get; private set; }
        public String Kunnr { get; private set; }
        public String Bukrs { get; private set; }
        public String Bldat { get; private set; }
        public String Budat { get; private set; }
        public String Zlsch { get; private set; }
        public String Xref1 { get; private set; }
        public String Xref3 { get; private set; }
        public String x_Import { get; private set; }
        public String Bktxt { get; private set; }

        public TFCabecera(ONE_Contrato__c contrato, String sapClientId) {
            IdXblnr = '';
            XblnrFra = '';
            XblnrCbr = '';
            Kunnr = sapClientId;
            Bukrs = BUKRS_1140;
            Bldat = contrato.ONE_Fecha_De_Cobro__c != null ? convertDate(contrato.ONE_Fecha_De_Cobro__c) : null;
            Budat = contrato.ONE_Fecha_De_Cobro__c != null ? convertDate(contrato.ONE_Fecha_De_Cobro__c) : null;
            Zlsch = contrato.ONE_Tipo_de_Pago__c;
            Xref1 = contrato.ONE_Numero_Contrato_Anexo__c;
            if (contrato.ONE_Contratante__c != null) {
                if (contrato?.ONE_Contratante__r?.Owner.FirstName.length() + contrato?.ONE_Contratante__r?.Owner.LastName.length() + 1 > 20) {
                    Xref3 = (contrato?.ONE_Contratante__r?.Owner.FirstName + ' ' + contrato?.ONE_Contratante__r?.Owner.LastName).substring(0, 20);
                } else {
                    Xref3 = contrato?.ONE_Contratante__r?.Owner.FirstName + ' ' + contrato?.ONE_Contratante__r?.Owner.LastName;
                }
            }
            x_Import = String.valueOf(contrato.ONE_Total_P_V_P__c);
            Bktxt = BKTXT_FACTURA_ELECTIUM;
        }
    }
	//JSON structute position definition
    public class TFPosicion {
        public String IdXblnr { get; private set; }
        public String WrbtrIng { get; private set; }
        public String Contrapartida { get; private set; }
        public String Kostl { get; private set; }
        public String ZuonrCp { get; private set; }
        public String SgtxtCp { get; private set; }
        public String Mwskz { get; private set; }
        public String Fwste { get; private set; }

        public TFPosicion(ONE_Contrato__c contrato, String key, List<ONE_Contracto_Line_Item__c> ocliList) {
            IdXblnr = '';
            Contrapartida = CONTRAPARTIDA_1;
            Kostl = contrato.ONE_Centro_de_Coste_Electium__c;
            ZuonrCp = contrato?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/');
            
            //If beneficiario is null we should not send any information, also we should check the size of the final string, it should not be more tan 50 characters
            if(contrato?.ONE_Beneficiario_1__c != null){
                if ((contrato?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/') + ' - ' + contrato?.ONE_Beneficiario_1__r?.Name).length() < 50) {
                    SgtxtCp = contrato?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/') + ' - ' + contrato?.ONE_Beneficiario_1__r?.Name != null? contrato?.ONE_Beneficiario_1__r?.Name:'';
                } else {
                    SgtxtCp = (contrato?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/') + ' - ' + contrato?.ONE_Beneficiario_1__r?.Name != null? contrato?.ONE_Beneficiario_1__r?.Name:'').substring(50);
                }               
            }else{
                if ((contrato?.ONE_Numero_Contrato_Anexo__c.replace('/', '\\/')).length() < 50) {
                    SgtxtCp = '';
                } else {
                    SgtxtCp = '';
                }      
            }
            
            Mwskz = key;
            Decimal wrbtrIngTmp = 0;
            Decimal fwsteTmp = 0;

            if (!ocliList.isEmpty()) {
                for (ONE_Contracto_Line_Item__c ocli : ocliList) {
                    wrbtrIngTmp += ocli?.ONE_Base_Imponible__c;
                    fwsteTmp += (ocli?.ONE_Total_Impuestos_Electium__c);

                }
            }

            WrbtrIng = String.valueOf(wrbtrIngTmp?.setScale(2));
            Fwste = String.valueOf(fwsteTmp?.setScale(2));
        }
    }
    
    	//JSON structute result definition
    public class Result {
        public String EResult;

        public Result() {
            EResult = '';
        }
    }
    
    
    public class ClientCreationRequestOldWS {

        

        public String PI { get; set; }
        public List<TFCabecera> TiFraCabecera { get; private set; }
        public List<TFPosicion> TiFraPosicion { get; private set; }
        public List<String> TiReturn { get; private set; }
        public Result result { get; private set; }
        

        
        public ClientCreationRequestOldWS(ONE_Contrato__c contracto, String sapClientId) {
                    
        ELECCION_METADATA_WEBSERVICE = 'SAP_ELECTUM_COBROS';
        ELECCION_SCOPE_WEBSERVICE = 'ZONE_ELECTIUM_COBROS_SRV_0001';
            
            PI = '';
            Map<String, List<ONE_Contracto_Line_Item__c>> ocliMap = new Map<String, List<ONE_Contracto_Line_Item__c>>();

            TiFraCabecera = new List<TFCabecera>{
                new TFCabecera(contracto, sapClientId)
            };

            TiFraPosicion = new List<TFPosicion>();

            for (ONE_Contracto_Line_Item__c ocli : [
                SELECT Id, ONE_Base_Imponible__c, ONE_Impuesto_SAP__c, ONE_Total_Impuestos_Electium__c, ONE_Anulada__c
                FROM ONE_Contracto_Line_Item__c
                WHERE (ONE_Contrato__c = :contracto.Id AND ONE_Anulada__c = FALSE)
            ]) {
                if (!ocliMap.keySet().contains(ocli.ONE_Impuesto_SAP__c)) {
                    ocliMap.put(ocli.ONE_Impuesto_SAP__c, new List<ONE_Contracto_Line_Item__c>());
                }
                ocliMap.get(ocli.ONE_Impuesto_SAP__c).add(ocli);
            }

            for (String key : ocliMap.keySet()) {
                TiFraPosicion.add(new TFPosicion(contracto, key, ocliMap.get(key)));
            }

            TiReturn = new List<String>();
            result = new Result();
        }
            
            
        }
    }
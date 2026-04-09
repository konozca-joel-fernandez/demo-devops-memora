/**
 * Created by mbujak003 on 02.02.2021.
 */
//Class for the Electium client creation integration
public with sharing class ONE_ElectClientCreateIntegrationService {
	//Static variable definition for the electium clien creation integration
    public static final String BUKRS_1140 = '1140';
    public static final String AKONT_4300000000 = '4300000000';
    public static final String ZUAWA_Z01 = 'Z01';
    public static final String FDGRV_ZD01 = 'ZD01';
    public static final String FDGRP_Z004 = 'Z004';
    public static final String ZTERM_Z000 = 'Z000';
    public static final String ZWELS_V = 'V';
    public static final String XZVER_X = 'X';
	
    public class ClientCreationCallout extends ONE_SAPCallout {
        public ClientCreationCallout(ClientCreationRequest orderRequest) {
            super(ONE_CommonConstants.CM_SAP_ELECTIUM_CLIENT_CREATE, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_ELECTIUM_CLIENTES);
            setBody(JSON.serialize(orderRequest).replaceAll('x_', ''));
        }
    }
	//Invocable class for calling the integration via flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        Map<Id, ClientCreationRequest> accId2PurchaseOrderRequest = prepareDTORequests(flowInputs[0].contractId);
        System.debug('accId2PurchaseOrderRequest-->' + accId2PurchaseOrderRequest);
		System.debug('accId2PurchaseOrderRequest.values()[0]-->' + accId2PurchaseOrderRequest.values()[0]);        
        ClientCreationCallout callout = new ClientCreationCallout(accId2PurchaseOrderRequest.values()[0]);
        System.debug('callout-->' + callout);    
        HttpResponse resp = callout.invokeCallout();
        FlowOutputs fo = new FlowOutputs();
		//Get response body
        String responseBody = resp.getBody();
		System.debug('RESPONSEBODY ES EL SIGUIENTE   '  + responseBody);
        Map<String, Object>  respObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        System.debug('RESPOBJECT ES EL SIGUIENTE   ' + respObject);
        Map<String, Object>  innerObject = (Map<String, Object>)respObject.get('d');
		//Parse body response and extract indicated values
        System.debug(JSON.serialize(innerObject));
        try {
            Map<String, Object>  ret = (Map<String, Object>)innerObject.get('Return');
            List<Object> results = (List<Object>)ret.get('results');

            String msgv1 = String.valueOf(((Map<String, Object>)results[0]).get('MessageV1'));
            String msg = String.valueOf(((Map<String, Object>)results[0]).get('Message'));
            String satus = String.valueOf(((Map<String, Object>)results[0]).get('Type'));
            fo.status = satus == 'S';
            fo.resultMessage = msg;
            fo.messageV1 = msgv1;
            System.debug('TODO OKKK EN CLIENTE ' + fo.status + '    ' + fo.resultMessage + '     ' + fo.messageV1);
            
        } catch (Exception ex) {
            fo.status = false;
            fo.resultMessage = resp.getBody();
            System.debug('fo.status' + fo.status + ' resultMessage ' + fo.resultMessage);
        }
        return new List<FlowOutputs> { fo };
    }
	//Flow input variable definition
    public class FlowInputs {
        @InvocableVariable
        public String contractId;
    }

    public class FlowOutputs {
        @InvocableVariable
        public Boolean status;
        @InvocableVariable
        public String resultMessage;
        @InvocableVariable
        public String messageV1;
    }
	//Query register and prepare the request
    public static Map<Id, ClientCreationRequest> prepareDTORequests(String contractId) {
        Map<Id, ClientCreationRequest> accId2PurchaseOrderRequest = new Map<Id, ClientCreationRequest>();
        ONE_Contrato__c contrato = [SELECT Id, ONE_Tipo_de_Pago__c,ONE_IBAN__c, ONE_Contratante__r.ONE_Tipo_de_documento__pc, ONE_Contratante__r.ONE_ID_Cliente_SAP__pc, ONE_Entidad_Bancaria__c FROM ONE_Contrato__c WHERE Id =: contractId];
        Account acc = ONE_AccountHelper.fetchAccountsByContractId(contractId);
        ClientCreationRequest request = new ClientCreationRequest(acc, contrato);
        accId2PurchaseOrderRequest.put(acc.Id, request);
        return accId2PurchaseOrderRequest;
    }
	//Data model for the integration
    public class ClientCreationRequest {
        public String Bukrs { get; private set; }
        public String TitleMedi { get; private set; }
        public String Name1 { get; private set; }
        public String Name2 { get; private set; }
        public String Name3 { get; private set; }
        public String Name4 { get; private set; }
        public String Street { get; private set; }
        public String HouseNum1 { get; private set; }
        public String HouseNum2 { get; private set; }
        public String Roomnumber { get; private set; }
        public String Floor { get; private set; }
        public String PostCode1 { get; private set; }
        public String City1 { get; private set; }
        public String Country { get; private set; }
        public String Region { get; private set; }
        public String Langu { get; private set; }
        public String TelNumber { get; private set; }
        public String FaxNumber { get; private set; }
        public String SmtpAddr { get; private set; }
        public String Stcd1 { get; private set; }
        public String Stcdt { get; private set; }
        public String Banks { get; private set; }
        public String Bankl { get; private set; }
        public String Bankn { get; private set; }
        public String Bkont { get; private set; }
        public Boolean Xezer { get; private set; }
        public String Iban { get; private set; }
        public String Banka { get; private set; }
        public String StrasBco { get; private set; }
        public String Ort01Bco { get; private set; }
        public String Brnch { get; private set; }
        public String Swift { get; private set; }
        public String Akont { get; private set; }
        public String Zuawa { get; private set; }
        public String Fdgrv { get; private set; }
        public String Frgrp { get; private set; }
        public String Altkn { get; private set; }
        public String Zterm { get; private set; }
        public String Guzte { get; private set; }
        public String Zwels { get; private set; }
        public Boolean Xzver { get; private set; }
        public String Streetabbr { get; private set; }
        public String Vbund { get; private set; }
        public String Kunnr { get; private set; }
        //public string zformPago {get; private set; }
        //public string ZtipoPago {get; private set; }
        //public string Zcuotas {get; private set; }
        //public string ZimpCuota {get; private set;}
        public List<String> x_Return { get; set; }
		//Prepare request based on the Account and Contrato input
        public ClientCreationRequest(Account acc, ONE_Contrato__c contrato) {
            //Populate all JSON variable with the corresponding information
            Bukrs = BUKRS_1140;
            TitleMedi = '';
            Name1 = acc.FirstName?.toUpperCase();
            Name2 = '';
            
            //Treat the last name to split in spaces and store in differents variables 
            List<String> filterLogicSplittedbySpace = acc.LastName?.toUpperCase().split(' ');
            Name3 = filterLogicSplittedbySpace.size()>0?filterLogicSplittedbySpace[0]:'';
           	Name4 = filterLogicSplittedbySpace.size()>1?filterLogicSplittedbySpace[1]:'';

            Street = acc.ONE_Direccion__pc?.toUpperCase();
            HouseNum1 = '';
            HouseNum2 = '';
            Roomnumber = '';
            Floor = '';
            //ZtipoPag = '01';
            PostCode1 = acc.ONE_Codigo_Postal__pc?.toUpperCase();
            City1 = acc.ONE_Municipio__pc?.toUpperCase();
            Country = acc.ONE_Pais__pc?.toUpperCase();
            Region = acc.ONE_Provincia__pc?.toUpperCase();
            Langu = acc.ONE_Idioma__pc?.toUpperCase();
            TelNumber = acc.Phone?.toUpperCase();
            FaxNumber = acc.Fax?.toUpperCase();
            SmtpAddr = acc.PersonEmail?.toUpperCase();
            Stcd1 = acc.ONE_N_Documento__pc?.toUpperCase();
            Stcdt = acc.ONE_Tipo_de_documento__pc.toUpperCase();
            Banks = '';
            Bankl = '';
            Bankn = '';
            Bkont = '';
            Xezer = false;
            Iban = contrato.ONE_IBAN__c != null? contrato.ONE_IBAN__c:'';
            Banka = contrato.ONE_Entidad_Bancaria__c!=null? contrato.ONE_Entidad_Bancaria__c:'';
            StrasBco = '';
            Ort01Bco = '';
            Brnch = '';
            Swift = '';
            Akont = AKONT_4300000000;
            Zuawa = ZUAWA_Z01;
            Fdgrv = FDGRV_ZD01;
            Frgrp = FDGRP_Z004;
            Altkn = acc.ONE_N_Documento__pc?.toUpperCase();
            Zterm = ZTERM_Z000;
            Guzte = '';
            Zwels = contrato?.ONE_Tipo_de_Pago__c == '1' ? contrato.ONE_Tipo_de_Pago__c : ZWELS_V;
            Xzver = false;
            Streetabbr = '';
            Vbund = '';
            Kunnr = contrato?.ONE_Contratante__r?.ONE_ID_Cliente_SAP__pc!= null ? contrato?.ONE_Contratante__r?.ONE_ID_Cliente_SAP__pc:'';
            x_Return = new List<String>();
        }
    }
}
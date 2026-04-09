/**
* Created by mbujak003 on 10.02.2021.
*/
//Class for the Client Creation SAP integration
public with sharing class ONE_ClientCreationIntegrationService {
    static final String EMPTY_VALUE = '';
    static final String DEFAULT_PARTICULAR_GROUP = 'Z014';// Hardcode parameter always the same
    static final String DEFAULT_PARTICULAR_GROUP_1 = 'Z001';// Hardcode parameter always the same
    static final String DEFAULT_OTHER_ACCOUNT_GROUP = 'Z006';// Hardcode parameter always the same
    public class ClientCreationCallout extends ONE_SAPCallout {
        public ClientCreationCallout(ClientCreationRequest orderRequest) {
            super(ONE_CommonConstants.CM_SAP_ZONECUSTOMER, ONE_Integration.RestMethod.POST, ONE_CommonConstants.SAPSCOPE_CUSTOMER); // Call SAP father class with integration call method
            setBody(JSON.serialize(orderRequest).replace('null', '""').replace('x_', ''));
        }
    }

    //Invocable method to call integration from a flow
    @InvocableMethod
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> flowInputs) {
        Map<Id, ClientCreationRequest> accId2PurchaseOrderRequest = prepareDTORequests(flowInputs[0].ordenDeVentaId);
        ClientCreationCallout callout = new ClientCreationCallout(accId2PurchaseOrderRequest.values()[0]);
        HttpResponse resp = callout.invokeCallout();
        
        //Parse flow output variables using responsre frin the integration
		FlowOutputs fo = new FlowOutputs();
		
        String customerId = '';
        String messageReturn = '';
        String result = '';
        fo.success = false;

        try {
            System.debug(resp.getBody());
            Map<String, Object> respObject = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            Map<String, Object> innerObject = (Map<String, Object>) respObject.get('d');

            customerId = String.valueOf(innerObject.get('customerId'));
            messageReturn = String.valueOf(innerObject.get('messageReturn'));

            Map<String, Object> resultObject = (Map<String, Object>) innerObject.get('result');
            result = String.valueOf(resultObject.get('Result'));

        } catch (Exception ex) {

        }

        fo.success = result == 'S' ? true : false;
        fo.customerId = customerId;
        fo.messageReturn = messageReturn;

        return new List<FlowOutputs>{
            fo
        };
    }
    //Input flow variable definition
    public class FlowInputs {
        @InvocableVariable
        public String ordenDeVentaId;
    }

    //output flow variable definition
    public class FlowOutputs {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String customerId;

        @InvocableVariable
        public String messageReturn;
    }
	//Query data for the request
    public static Map<Id, ClientCreationRequest> prepareDTORequests(String ordenDeVentaId) {
        Map<Id, ClientCreationRequest> ordenId2clientCreationRequest = new Map<Id, ClientCreationRequest>();
        ONE_Orden_De_Venta__c ordenDeVenta = [
            SELECT Id, ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_CIF__c,
            	ONE_Pagador_Particular__r.ONE_Contacto__r.Recordtype.Developername,
                ONE_Pagador_Particular__r.ONE_Contacto__r.Name,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Direccion__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Codigo_Postal__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Municipio_Direccion__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Pais__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Provincia__pc,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad__c,
                ONE_Forma_De_Pago__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c,
                ONE_Moneda__c, ONE_IBAN__c, ONE_Titular_De_La_Cuenta_Bancaria__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_ID_Cliente_SAP__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Tipo_de_documento__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_N_Documento__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.FirstName,
                ONE_Pagador_Particular__r.ONE_Contacto__r.LastName,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Municipio__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Provincia__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Direccion__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Codigo_Postal__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Municipio__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Pais__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.RecordTypeId,
                ONE_Orden_De_Venta__c.ONE_El_Pagador_Es_El_Difunto__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
        ];
        ClientCreationRequest request = new ClientCreationRequest(ordenDeVenta);
        ordenId2clientCreationRequest.put(ordenDeVenta.Id, request);
        return ordenId2clientCreationRequest;
    }
	
    public enum ContactType {
        OTRAS_CUENTAS,
        PA_PARTICULAR
    }

    public class ReqGeneralData {
        public String customerId { get; set; }
        public String region { get; set; }
        public String documentType { get; set; }
        public String grupoCuentas { get; set; }
        public String documentNumber { get; set; }
        public String name { get; set; }
        public String firstSurname { get; set; }
        public String secondSurname { get; set; }
        public String condicionPago { get; set; }
        public String stkzn { get; set; }
        
        public ReqGeneralData(ONE_Orden_De_Venta__c orden, ContactType cType) {
            customerId = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();

            region = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r.ONE_Provincia__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r.ONE_Provincia__pc?.toUpperCase();

            documentType = cType == ContactType.OTRAS_CUENTAS ? '97' : orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Tipo_de_documento__pc?.toUpperCase();

            grupoCuentas = getAccountGroupBasedOnContactTypeAndCustomerId(cType, customerId, orden);


            documentNumber = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_CIF__c?.toUpperCase() :
                orden.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_N_Documento__pc?.toUpperCase();
            name = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.FirstName?.toUpperCase();

            String fSurname = orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.LastName;
            String sSurname = '';

            if (orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.LastName != null && orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.LastName?.contains(' ')) {
                String lastName = orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.LastName;

                if (lastName.length() < 34) {
                    fSurname = lastName;
                } else {

                    fSurname = lastName?.substring(0, lastName.indexOf(' ', 34)).substring(0, lastName?.substring(0, lastName.indexOf(' ', 34)).lastIndexOf(' '));

                    if (lastName?.substring(lastName?.substring(0, lastName.indexOf(' ', 34)).lastIndexOf(' ')).length() < 34) {
                        sSurname = lastName?.substring(lastName?.substring(0, lastName.indexOf(' ', 34)).lastIndexOf(' ') + 1);
                    } else {
                        sSurname = lastName?.substring(lastName?.substring(0, lastName.indexOf(' ', 34)).lastIndexOf(' ') + 1).substring(0, 34);
                    }
                }
            }

            firstSurname = cType == ContactType.OTRAS_CUENTAS ? '' : fSurname?.toUpperCase();
            secondSurname = cType == ContactType.OTRAS_CUENTAS ? '' : sSurname?.toUpperCase();

            String tmpName = orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name;
            String tmpFirstSurname = '';

            if (cType == ContactType.OTRAS_CUENTAS) {
                if (orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name != null && orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name?.contains(' ')) {
                    if (tmpName.length() < 34) {
                        name = tmpName;
                    } else {
                        name = tmpName.substring(0, 34).substring(0, tmpName.substring(0, 34).lastIndexOf(' '));
                        tmpFirstSurname = tmpName.substring(name.length());
                        firstSurname = tmpFirstSurname.startsWith(' ') ? tmpFirstSurname.substring(1) : tmpFirstSurname;
                    }
                }
            }

            condicionPago = 'Z000';
            stkzn= orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Recordtype?.Developername=='ONE_Person_Accout_Particular'? 'X':'';
        }
        
        String getAccountGroupBasedOnContactTypeAndCustomerId(ContactType contactType, String customerId, ONE_Orden_De_Venta__c order) {
            if (contactType == ONE_ClientCreationIntegrationService.ContactType.OTRAS_CUENTAS) {
                return String.isBlank(customerId) ? DEFAULT_OTHER_ACCOUNT_GROUP : ONE_ClientCreationIntegrationService.EMPTY_VALUE;
            } else if (contactType == ONE_ClientCreationIntegrationService.ContactType.PA_PARTICULAR) {
                return order?.ONE_El_Pagador_Es_El_Difunto__c ? ONE_ClientCreationIntegrationService.DEFAULT_PARTICULAR_GROUP : ONE_ClientCreationIntegrationService.DEFAULT_PARTICULAR_GROUP_1;
            }
            return ONE_ClientCreationIntegrationService.EMPTY_VALUE;
        }
    }


	//Request addess data model definition and population
    public class ReqAddress {
        public String customerId { get; set; }
        public String street { get; set; }
        public String houseNumber { get; set; }
        public String floor { get; set; }
        public String door { get; set; }
        public String postalCode { get; set; }
        public String city { get; set; }
        public String country { get; set; }

        public ReqAddress(ONE_Orden_De_Venta__c orden, ContactType cType) {
            customerId = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();
            street = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Direccion__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Direccion__pc?.toUpperCase();
            houseNumber = '';
            floor = '';
            door = '';
            postalCode = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Codigo_Postal__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc?.toUpperCase();
            city = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Municipio_Direccion__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Municipio__pc?.toUpperCase();
            country = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Pais__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Pais__pc?.toUpperCase();
        }
    }

    //Request company data model definition and population
    public class ReqCompany {
        public String customerId { get; set; }
        public String societyId { get; set; }
        public String paymentMethod { get; set; }

        public ReqCompany(ONE_Orden_De_Venta__c orden, ContactType cType) {
            customerId = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();
            societyId = orden?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad__c?.toUpperCase();
            paymentMethod = orden?.ONE_Forma_De_Pago__c?.toUpperCase();
        }
    }
    //Request partner function data model definition and population
    public class ReqPartnerFunction {
        public String customerId { get; set; }
        public String partnerFunctionCode { get; set; }
        public String customer { get; set; }

        public ReqPartnerFunction(ONE_Orden_De_Venta__c orden, ContactType cType) {
            customerId = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();
            partnerFunctionCode = '';
            customer = '';
        }
    }
    //Request sales data model definition and population
    public class ReqSalesData {
        public String customerId { get; set; }
        public String operatingCenter { get; set; }
        public String customerGroup { get; set; }
        public String salesDistrict { get; set; }
        public String x_currency { get; set; }

        public ReqSalesData(ONE_Orden_De_Venta__c orden, ContactType cType) {
            customerId = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();
            operatingCenter = orden?.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Centro_Memora_Codigo_SAP__c?.toUpperCase();
            customerGroup = '';
            salesDistrict = '';
            x_currency = orden?.ONE_Moneda__c?.toUpperCase();
        }
    }
    //Request tax indicator data model definition and population
    public class ReqTaxIndicator {
        public String customerId { get; set; }
        public String taxClassification { get; set; }

        public ReqTaxIndicator(ONE_Orden_De_Venta__c orden, ContactType cType) {
            customerId = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();
            taxClassification = '0';
        }
    }
    //Request bank account data model definition and population
    public class ReqBankAccount {
        public String customerId { get; set; }
        public String bankAccountNumber { get; set; }
        public String accountHolder { get; set; }

        public ReqBankAccount(ONE_Orden_De_Venta__c orden, ContactType cType) {
            customerId = cType == ContactType.OTRAS_CUENTAS ?
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();
            bankAccountNumber = orden?.ONE_IBAN__c?.toUpperCase();
            accountHolder = orden?.ONE_Titular_De_La_Cuenta_Bancaria__c?.toUpperCase();
        }
    }
    //Response objetc data model definition and population
    public class ResultObject {
        public String Result { get; set; }

        public ResultObject() {
            Result = '';
        }
    }
    //Request global data model call
    public class ClientCreationRequest {
        public String customerId { get; set; }
        public ReqGeneralData GeneralData { get; set; }
        public ReqAddress Address { get; set; }
        public ReqCompany Company { get; set; }
        public ReqPartnerFunction PartnerFunction { get; set; }
        public ReqSalesData SalesData { get; set; }
        public ReqTaxIndicator TaxIndicator { get; set; }
        public ReqBankAccount BankAccount { get; set; }
        public ResultObject result { get; set; }
        public List<Object> messageReturn { get; set; }
        public ClientCreationRequest(ONE_Orden_De_Venta__c orden) {
            result = new ResultObject();
            messageReturn = new List<Object>{
                new Map<String, Object>()
            };
            if (orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r != null) {
                Id rtId = orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.RecordTypeId;
                String rtName = ONE_CommonUtils.getsObjectRecordTypeNameById(ONE_CommonConstants.ACCOUNT, rtId);
                System.debug(rtId);
                System.debug(rtName);
                ContactType ct = rtName.equalsIgnoreCase('Otras cuentas') ? ContactType.OTRAS_CUENTAS : ContactType.PA_PARTICULAR;

                customerId = ct == ContactType.OTRAS_CUENTAS ?
                    orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__c?.toUpperCase() :
                    orden?.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_ID_Cliente_SAP__pc?.toUpperCase();

                GeneralData = new ReqGeneralData(orden, ct);
                Address = new ReqAddress(orden, ct);
                Company = new ReqCompany(orden, ct);
                PartnerFunction = new ReqPartnerFunction(orden, ct);
                SalesData = new ReqSalesData(orden, ct);
                TaxIndicator = new ReqTaxIndicator(orden, ct);
                BankAccount = new ReqBankAccount(orden, ct);
            }
        }
    }
}
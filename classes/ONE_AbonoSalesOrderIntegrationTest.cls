/**
 * Created by bjaworski002 on 26.05.2022.
 */

@IsTest
private class ONE_AbonoSalesOrderIntegrationTest {

    @TestSetup
    public static void dataSetup() {
        User u = ONE_TestDataFactory.createUser('123456', true);

        Account acc = new Account(FirstName = 'John', LastName = 'Smith', Phone='434324522', ONE_Email__c = 'martaJ@example.com',
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                        ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
                ONE_Tipo_De_Impuesto__c = 'IVA');

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);

        Account accMemora = new Account(Name = 'MemoraTestName', Phone='54543322', ONE_Email__c = 'memoraa234@example.com',
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                        ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Tipo_De_Impuesto__c = 'IVA',
                ONE_Lugar__c = lugar.Id);

        insert new List<Account> {acc, accMemora};


        ONE_Expediente__c servicio = new ONE_Expediente__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Expediente__c.SObjectType.getDescribe().name,
                        'ONE_Servicio_Defuncion'),
                ONE_Difunto__c = acc.Id,
                ONE_Centro_Del_Expediente__c = accMemora.Id
        );
        insert servicio;

        ONE_Interlocutor__c interlocutor = ONE_TestDataFactory.createInterlocutor(
                new ONE_Interlocutor__c(
                        ONE_Expediente__c = servicio.Id,
                        ONE_Contacto__c = acc.Id
                ), true);

        ONE_Orden_De_Venta__c ordenDeVenta = ONE_TestDataFactory.createOrdenDeVenta(
                new ONE_Orden_De_Venta__c(
                        ONE_Pagador_Particular__c = interlocutor.Id,
                        ONE_Servicio__c = servicio.Id,
                        ONE_Fecha_De_Facturacion__c = Date.today(),
                        ONE_Numero_de_factura__c = 'FV25/02/21',
                        ONE_Forma_De_Pago__c = 'A',
                        ONE_Moneda__c = 'EUR',
                        ONE_IBAN__c = 'ES3621082850270010500972',
                        ONE_Titular_De_La_Cuenta_Bancaria__c = 'José Carreño Iborra',
                        ONE_El_Pagador_Es_El_Difunto__c = false
                ), true);

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name,
                        'ONE_Presupuesto_App'),
                ONE_Tipo_De_Contrato__c = 'Particular',
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c =23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = servicio.Id);
        insert presupuesto;

        ONE_Abono_Parcial__c abonoParcial = new ONE_Abono_Parcial__c(
                ONE_Orden_de_venta_AP__c = ordenDeVenta.Id,
                ONE_Fecha_De_Facturacion_Rectificativa__c = Date.today(),
                ONE_Presupuesto_AP__c = presupuesto.Id,
                ONE_Servicio_AP__c = servicio.Id);

        insert abonoParcial;

        ONE_Momento__c velacionMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT);
        ONE_Momento__c ceremonianMomento = new ONE_Momento__c(Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_MOMENT);
        insert new List<ONE_Momento__c> {velacionMomento, ceremonianMomento};

        ONE_Agrupacion__c composicioneAgrupacion = new ONE_Agrupacion__c(Name = ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0),
                ONE_Momento__c = velacionMomento.Id);
        ONE_Agrupacion__c ceremonialAgrupacion = new ONE_Agrupacion__c(Name = ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST.get(0),
                ONE_Momento__c = ceremonianMomento.Id);
        insert new List<ONE_Agrupacion__c>{composicioneAgrupacion, ceremonialAgrupacion};

        ONE_Categoria__c salasVelatoriolCategoria = new ONE_Categoria__c(ONE_Agrupacion__c= composicioneAgrupacion.Id,
                Name = (ONE_MomentoServiceConstants.VELACION_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0))
                ).get(0)
        );
        ONE_Categoria__c salasCeremonialCategoria = new ONE_Categoria__c(ONE_Agrupacion__c= ceremonialAgrupacion.Id,
                Name = (ONE_MomentoServiceConstants.CEREMONIA_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.CEREMONIA_SERVICO_AGRUPACION_LIST.get(0)).
                        get(0))
        );
        insert new List<ONE_Categoria__c>{salasCeremonialCategoria, salasVelatoriolCategoria};

        ONE_Producto__c velProducto = new ONE_Producto__c(Name = 'VelProd', ONE_Categoria__c = salasVelatoriolCategoria.Id);
        ONE_Producto__c ceremoniaProducto = new ONE_Producto__c(Name = 'CerProd', ONE_Categoria__c = salasCeremonialCategoria.Id,
                ONE_Codigo_Comercial__c = '1000005886');
        ONE_Producto__c velChildProducto = new ONE_Producto__c(Name = 'VelChildProd', ONE_Categoria__c = salasVelatoriolCategoria.Id,
                ONE_Codigo_Comercial__c = '1000005887');

        insert new List<ONE_Producto__c>{velProducto, ceremoniaProducto, velChildProducto};

        ONE_Expediente_Line_Item__c lineItem1 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
                ONE_Importe_Neto__c = 223 , ONE_Impuesto__c = 888, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false, ONE_Orden_De_Venta__c = ordenDeVenta.Id, ONE_Abono_parcial__c = abonoParcial.Id);
        ONE_Expediente_Line_Item__c lineItem2 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id, ONE_Orden_De_Venta__c = ordenDeVenta.Id,
                ONE_Importe_Neto__c = 444 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false, ONE_Abono_parcial__c = abonoParcial.Id);


        insert new List<ONE_Expediente_Line_Item__c>{lineItem1, lineItem2};

        ONE_Expediente_Line_Item__c lineItem3 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velChildProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
                ONE_Importe_Neto__c = 0 , ONE_Impuesto__c = 0, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = false,
                ONE_Linea_De_Servicio_Padre__c = lineItem1.Id, ONE_Abono_parcial__c = abonoParcial.Id);
        ONE_Expediente_Line_Item__c lineItem4 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
                ONE_Importe_Neto__c = 55 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = servicio.Id , ONE_Suplido__c = true,
                ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId(), ONE_Abono_parcial__c = abonoParcial.Id);

        insert new List<ONE_Expediente_Line_Item__c>{lineItem3, lineItem4};
    }

    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new AbonoSalesOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));

        ONE_AbonoSalesOrderIntegrationService.FlowInputs fi = new ONE_AbonoSalesOrderIntegrationService.FlowInputs();
        fi.abonoParcialId = [SELECT Id FROM ONE_Abono_Parcial__c LIMIT 1].Id;
        List<ONE_AbonoSalesOrderIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_AbonoSalesOrderIntegrationService.invokeIntegration(new List<ONE_AbonoSalesOrderIntegrationService.FlowInputs> { fi });
        Test.stopTest();

        System.assertEquals(fo[0].invoiceNumber, '2105028014');
    }

    @IsTest
    private static void invokeAlternativeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new AbonoSalesOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareAlternativeResponse()));

        ONE_AbonoSalesOrderIntegrationService.FlowInputs fi = new ONE_AbonoSalesOrderIntegrationService.FlowInputs();
        fi.abonoParcialId = [SELECT Id FROM ONE_Abono_Parcial__c LIMIT 1].Id;
        List<ONE_AbonoSalesOrderIntegrationService.FlowOutputs> fo;
        Test.startTest();
        fo = ONE_AbonoSalesOrderIntegrationService.invokeIntegration(new List<ONE_AbonoSalesOrderIntegrationService.FlowInputs> { fi });
        Test.stopTest();
    }

    @TestVisible
    private class AbonoSalesOrderMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public AbonoSalesOrderMock(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            res.setBody(this.body);
            return res;
        }
    }

        private static String prepareResponse() {
                //TODO: proper object creation and serialization
                return '{"d":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderSet(\'\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderSet(\'\')","type":"ZONE_SALESORDER_SRV.salesOrder"},"numPoliza":"","siniestro":"","contractNumber":"","invoiceNumber":"2105028014","businessData":null,"commentSet":null,"conditionsSet":null,"headerData":null,"itemDataSet":null,"partnerSet":null,"scheduleLineDataSet":null,"processSet":{"results":[{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","type":"ZONE_SALESORDER_SRV.process"},"contractNumber":"0038102329","code":"E8","message":"Contrato Particular 38102329 se ha grabado"},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/processSet(\'0038102329\')","type":"ZONE_SALESORDER_SRV.process"},"contractNumber":"0038102329","code":"E8","message":"Documento 2105028014 grabado."}]},"messageReturn":{"results":[{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'V1\',Number=\'311\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'V1\',Number=\'311\')","type":"ZONE_SALESORDER_SRV.messageReturn"},"Type":"S","Id":"V1","Number":"311","Message":"Contrato Particular 38102329 se ha grabado","LogNo":"","LogMsgNo":"000000","MessageV1":"Contrato Particular","MessageV2":"38102329","MessageV3":"","MessageV4":"","Parameter":"SALES_HEADER_IN","Row":0,"Field":"","System":"CERCLNT100"},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'VF\',Number=\'311\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/salesOrderMsgReturnSet(Id=\'VF\',Number=\'311\')","type":"ZONE_SALESORDER_SRV.messageReturn"},"Type":"S","Id":"VF","Number":"311","Message":"Documento 2105028014 grabado.","LogNo":"","LogMsgNo":"000000","MessageV1":"2105028014","MessageV2":"","MessageV3":"","MessageV4":"","Parameter":"","Row":0,"Field":"","System":""}]},"result":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/resultSet(\'E8\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_SALESORDER_SRV/resultSet(\'E8\')","type":"ZONE_SALESORDER_SRV.result"},"Result":"S","EResult":"E8"}}}';
        }

        //Response mockup definition
        private static String prepareAlternativeResponse() {
                //TODO: proper object creation and serialization
                return '{"error":{"code":"F5/287","message":{"lang":"es","value":"La cuenta 100120323 0500 está siendo tratada por el usuario CARTASP"},"innererror":{"application":{"component_id":"","service_namespace":"/SAP/","service_id":"ZONE_CANCELINVOICE_SRV","service_version":"0001"},"transactionid":"85E00D17F4660050E00628B62B2650A0","timestamp":"","Error_Resolution":{"SAP_Transaction":"","SAP_Note":"See SAP Note 1797736 for error analysis (https://service.sap.com/sap/support/notes/1797736)"},"errordetails":[{"code":"VF/050","message":"Documento 2207938365 grabado (documento contable no creado)","propertyref":"","severity":"warning","target":""},{"code":"VF/050","message":"Documento 2207938365 grabado (documento contable no creado)","propertyref":"","severity":"warning","target":""},{"code":"F5/287","message":"La cuenta 100120323 0500 está siendo tratada por el usuario CARTASP","propertyref":"","severity":"error","target":""},{"code":"/IWBEP/CX_SD_GEN_DPC_BUSINS","message":"An application exception has occurred.","propertyref":"","severity":"error","target":""}]}}}';
        }
}
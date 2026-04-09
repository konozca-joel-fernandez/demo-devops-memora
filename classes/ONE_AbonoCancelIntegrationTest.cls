/**
 * Created by bjaworski002 on 26.05.2022.
 */

@IsTest
private class ONE_AbonoCancelIntegrationTest {

    //Data structure definition
    @TestSetup
    private static void dataSetup() {

        User u = ONE_TestDataFactory.createUser('123456', true);

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account acc1 = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id),true);
        Account acc2 = ONE_TestDataFactory.createPersonAccount(new Account(
                ONE_ID_Cliente_SAP__pc = 'someId'
        ), true);
        ONE_Expediente__c expedient = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = acc1.Id,
                ONE_Inicio_Ceremonia__c = Date.today()
        ), true);

        ONE_Interlocutor__c interlocutor = ONE_TestDataFactory.createInterlocutor(
                new ONE_Interlocutor__c(
                        ONE_Contacto__c = acc2.Id
                ), true);

        ONE_Orden_De_Venta__c ordenDeVenta = ONE_TestDataFactory.createOrdenDeVenta(
                new ONE_Orden_De_Venta__c(
                        ONE_Pagador_Particular__c = interlocutor.Id,
                        ONE_Servicio__c = expedient.Id,
                        ONE_Fecha_De_Facturacion__c = Date.newInstance(2020, 12, 30),
                        ONE_Numero_de_factura__c = 'FV25/02/21',
                        ONE_Fecha_Hora_Del_Abono_Factura__c = Date.today()
                ), true);

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_Presupuesto__c.SObjectType.getDescribe().name,
                        'ONE_Presupuesto_App'),
                ONE_Tipo_De_Contrato__c = 'Particular',
                ONE_Tipo_De_Presupuesto__c = 'Presupuesto segunda venta',
                ONE_Importe_IVA_3__c = 23,
                ONE_Importe_IVA_21__c = 883,
                ONE_Importe_IVA_10__c = 33,
                ONE_Expediente__c = expedient.Id,
                OwnerId = u.Id);
        insert presupuesto;

        ONE_Abono_Parcial__c abonoParcial = new ONE_Abono_Parcial__c(
                ONE_Orden_de_venta_AP__c = ordenDeVenta.Id,
                ONE_Fecha_Abono_Factura_Rectificativa__c = Date.today(),
                ONE_Presupuesto_AP__c = presupuesto.Id,
                ONE_Servicio_AP__c = expedient.Id);

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
                ONE_Importe_Neto__c = 223 , ONE_Impuesto__c = 888, ONE_Cantidad__c = 2, ONE_Expediente__c = expedient.Id , ONE_Suplido__c = false, ONE_Orden_De_Venta__c = ordenDeVenta.Id, ONE_Abono_parcial__c = abonoParcial.Id);
        ONE_Expediente_Line_Item__c lineItem2 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id, ONE_Orden_De_Venta__c = ordenDeVenta.Id,
                ONE_Importe_Neto__c = 444 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = expedient.Id , ONE_Suplido__c = false, ONE_Abono_parcial__c = abonoParcial.Id);


        insert new List<ONE_Expediente_Line_Item__c>{lineItem1, lineItem2};

        ONE_Expediente_Line_Item__c lineItem3 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = velChildProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
                ONE_Importe_Neto__c = 0 , ONE_Impuesto__c = 0, ONE_Cantidad__c = 2, ONE_Expediente__c = expedient.Id , ONE_Suplido__c = false,
                ONE_Linea_De_Servicio_Padre__c = lineItem1.Id, ONE_Abono_parcial__c = abonoParcial.Id);
        ONE_Expediente_Line_Item__c lineItem4 = new ONE_Expediente_Line_Item__c(ONE_Producto__c = ceremoniaProducto.Id, ONE_Presupuesto__c = presupuesto.Id,
                ONE_Importe_Neto__c = 55 , ONE_Impuesto__c = 65, ONE_Cantidad__c = 2, ONE_Expediente__c = expedient.Id , ONE_Suplido__c = true,
                ONE_Asesor_Responsable_De_La_Venta__c = UserInfo.getUserId(), ONE_Abono_parcial__c = abonoParcial.Id);

        insert new List<ONE_Expediente_Line_Item__c>{lineItem3, lineItem4};


    }

    //Invoke integration test
    @IsTest
    private static void invokeIntegrationTest() {
        //Set mock response
        Test.setMock(HttpCalloutMock.class, new AbonoSalesOrderCancellationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));
        //flow input variable population
        ONE_AbonoCancelIntegrationService.FlowInputs fi = new ONE_AbonoCancelIntegrationService.FlowInputs();
        fi.abonoParcialId = [SELECT Id FROM ONE_Abono_Parcial__c LIMIT 1].Id;
        List<ONE_AbonoCancelIntegrationService.FlowOutputs> fo;
        Test.startTest();
        //Integration call
        fo = ONE_AbonoCancelIntegrationService.invokeIntegration(new List<ONE_AbonoCancelIntegrationService.FlowInputs> { fi });
        Test.stopTest();
        //Assert definition
        System.assertEquals(fo[0].EFkdatAnul, Date.newInstance(2020, 12, 30));
        System.assertEquals(fo[0].ESfakn, '2012938009');
        System.assertEquals(fo[0].EResult, 'S');
    }

    //Invoke integration test
    @IsTest
    private static void invokeAlternativeIntegrationTest() {
        //Set mock response
        Test.setMock(HttpCalloutMock.class, new AbonoSalesOrderCancellationMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareAlternativeResponse()));
        //flow input variable population
        ONE_AbonoCancelIntegrationService.FlowInputs fi = new ONE_AbonoCancelIntegrationService.FlowInputs();
        fi.abonoParcialId = [SELECT Id FROM ONE_Abono_Parcial__c LIMIT 1].Id;
        List<ONE_AbonoCancelIntegrationService.FlowOutputs> fo;
        Test.startTest();
        //Integration call
        fo = ONE_AbonoCancelIntegrationService.invokeIntegration(new List<ONE_AbonoCancelIntegrationService.FlowInputs> { fi });
        Test.stopTest();
    }

    //Mock up response data structure definition
    @TestVisible
    private class AbonoSalesOrderCancellationMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public AbonoSalesOrderCancellationMock(Integer code, String status, String body) {
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

        //Response mockup definition
        private static String prepareResponse() {
                //TODO: proper object creation and serialization
                return '{"d":{"__metadata":{"id":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELINVOICE_SRV/Z_ONE_CANCEL_INVOICESet(IFkdat=datetime\'2020-12-30T00-00-00\',IVbeln=\'1910059064\')","uri":"http://172.25.4.11:8000/sap/opu/odata/sap/ZONE_CANCELINVOICE_SRV/Z_ONE_CANCEL_INVOICESet(IFkdat=datetime\'2020-12-30T00-00-00\',IVbeln=\'1910059064\')","type":"ZONE_CANCELINVOICE_SRV.Z_ONE_CANCEL_INVOICE"},"IFkdat":"/Date(1609286400000)/","IVbeln":"1910059064","EFkdatAnul":"/Date(1609286400000)/","EResult":"S","ESfakn":"2012938009", "messageReturn": { "results": [] }}}';
        }

        //Response mockup definition
        private static String prepareAlternativeResponse() {
                //TODO: proper object creation and serialization
                return '{"error":{"code":"F5/287","message":{"lang":"es","value":"La cuenta 100120323 0500 está siendo tratada por el usuario CARTASP"},"innererror":{"application":{"component_id":"","service_namespace":"/SAP/","service_id":"ZONE_CANCELINVOICE_SRV","service_version":"0001"},"transactionid":"85E00D17F4660050E00628B62B2650A0","timestamp":"","Error_Resolution":{"SAP_Transaction":"","SAP_Note":"See SAP Note 1797736 for error analysis (https://service.sap.com/sap/support/notes/1797736)"},"errordetails":[{"code":"VF/050","message":"Documento 2207938365 grabado (documento contable no creado)","propertyref":"","severity":"warning","target":""},{"code":"VF/050","message":"Documento 2207938365 grabado (documento contable no creado)","propertyref":"","severity":"warning","target":""},{"code":"F5/287","message":"La cuenta 100120323 0500 está siendo tratada por el usuario CARTASP","propertyref":"","severity":"error","target":""},{"code":"/IWBEP/CX_SD_GEN_DPC_BUSINS","message":"An application exception has occurred.","propertyref":"","severity":"error","target":""}]}}}';
        }
}
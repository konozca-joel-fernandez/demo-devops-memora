/**
 * Created by mbujak003 on 24.02.2021.
 */

@IsTest
public with sharing class ONE_PurchaseOrderIntegrationTest {
    @TestSetup
    private static void dataSetup() {

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account acc1 = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id),true);
        ONE_Pedido_De_Proveedor__c pedido = ONE_TestDataFactory.createPedidoDeProveedor(
            new ONE_Pedido_De_Proveedor__c(ONE_Fecha__c = Date.today()), true
        );

        ONE_Expediente__c expedient = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(
            ONE_Centro_Del_Expediente__c = acc1.Id
        ), true);

        ONE_TestDataFactory.createTarea(new ONE_Tarea__c(
            ONE_Expediente__c = expedient.Id,
            ONE_Pedido_De_Proveedor__c = pedido.Id
        ), true);
        
        ONE_Caso__c cM1 = new ONE_Caso__c(
        	ONE_Expediente__c = expedient.Id
        );
        insert cM1;
        
        ONE_Expediente__c eM1 = new ONE_Expediente__c(
        	ONE_Caso__c = cM1.Id
        );
        insert eM1;
        
        Account accM1 = new Account(
        	Name = 'Proveedor',
            ONE_ID_Proveedor_SAP__c = 'test'
        );
        insert accM1;
        
        String recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Pedido_de_proveedor_M1' LIMIT 1].Id;
        
        ONE_Pedido_De_Proveedor__c pM1 = new ONE_Pedido_De_Proveedor__c(
            ONE_Fecha__c = Date.today(),
            RecordTypeId = recId,
            ONE_Proveedor__c = accM1.Id
        );
        insert pM1;
        
        ONE_Producto__c prodM1 = new ONE_Producto__c(
        	Name = 'Test M1',
            ONE_Codigo_SAP__c = 'test'
        );
        insert prodM1;
        
        ONE_Expediente_Line_Item__c SLI = new ONE_Expediente_Line_Item__c(
            ONE_Pedido_de_Proveedor_M1__c = pM1.Id,
            ONE_Importe_Neto__c = 100,
            ONE_Expediente__c = eM1.Id,
            ONE_Cantidad__c = 1,
            ONE_Producto__c = prodM1.Id
        );
        insert SLI;
    }

    @isTest
    private static void invokeIntegrationM1Test(){
        Test.setMock(HttpCalloutMock.class, new PurchaseOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));
		String recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Pedido_de_proveedor_M1' LIMIT 1].Id;      
        
        List<ONE_PurchaseOrderIntegrationService.FlowOutputs> fo;
        List<ONE_PurchaseOrderIntegrationService.FlowOutputs> foM1;
        
        Test.startTest();
        ONE_PurchaseOrderIntegrationService.FlowInputs fi = new ONE_PurchaseOrderIntegrationService.FlowInputs();
        fi.pedidoDeProvedoorId = [SELECT Id FROM ONE_Pedido_De_Proveedor__c WHERE RecordTypeId = :recId LIMIT 1].Id;
        fi.code = '30';
        fi.M1 = true;
        foM1 = ONE_PurchaseOrderIntegrationService.invokeIntegration(new List<ONE_PurchaseOrderIntegrationService.FlowInputs> { fi });
        Test.stopTest();
                
        System.assertEquals(true, foM1[0].message.startsWith('Pedido funerario'));
    }
    
    @IsTest
    private static void invokeIntegrationTest() {
        Test.setMock(HttpCalloutMock.class, new PurchaseOrderMock(ONE_CommonConstants.HTPP_SUCCESS_CODE, 'success', prepareResponse()));
		String recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Pedido_de_proveedor_M1' LIMIT 1].Id;      
        
        List<ONE_PurchaseOrderIntegrationService.FlowOutputs> fo;
        Test.startTest();
        ONE_PurchaseOrderIntegrationService.FlowInputs fi = new ONE_PurchaseOrderIntegrationService.FlowInputs();
        fi.pedidoDeProvedoorId = [SELECT Id FROM ONE_Pedido_De_Proveedor__c WHERE RecordTypeId != :recId LIMIT 1].Id;
        fi.code = '25';
        fi.M1 = false;
        fo = ONE_PurchaseOrderIntegrationService.invokeIntegration(new List<ONE_PurchaseOrderIntegrationService.FlowInputs> { fi });
        Test.stopTest();
        
        System.assertEquals(true, fo[0].message.startsWith('Pedido funerario'));
    }

    @TestVisible
    private class PurchaseOrderMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;

        public PurchaseOrderMock(Integer code, String status, String body) {
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
        return '{"d":{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/PurchaseOrderSet(\'\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/PurchaseOrderSet(\'\')","type":"ZONE_PURCHASEORDER_SRV_01.PurchaseOrder"},"orderId":"","POHeaderData":null,"POItemDataSet":null,"ProcessSet":{"results":[{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","type":"ZONE_PURCHASEORDER_SRV_01.Process"},"orderId":"4100028396","code":"E8","message":"Pedido funerario GF creado bajo el número 4100028396","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","type":"ZONE_PURCHASEORDER_SRV_01.Process"},"orderId":"4100028396","code":"E8","message":"No se ha creado ningún mensaje para la salida del documento de compras","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","type":"ZONE_PURCHASEORDER_SRV_01.Process"},"orderId":"4100028396","code":"E8","message":"La fecha de pedido se encuentra en el pasado","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","type":"ZONE_PURCHASEORDER_SRV_01.Process"},"orderId":"4100028396","code":"E8","message":"¿Se puede cumplir la fecha de entrega?","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')","type":"ZONE_PURCHASEORDER_SRV_01.Process"},"orderId":"4100028396","code":"E8","message":"No se ha podido ejecutar la modificación Centro Trabajo","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/ProcessSet(\'4100028396\')/PurchaseOrder"}}}]},"messageReturn":{"results":[{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'S\',Id=\'06\',Number=\'017\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'S\',Id=\'06\',Number=\'017\')","type":"ZONE_PURCHASEORDER_SRV_01.messageReturn"},"Type":"S","Id":"06","Number":"017","Message":"Pedido funerario GF creado bajo el número 4100028396","LogNo":"","LogMsgNo":"000000","MessageV1":"Pedido funerario GF","MessageV2":"4100028396","MessageV3":"","MessageV4":"","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'S\',Id=\'06\',Number=\'017\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'06\',Number=\'261\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'06\',Number=\'261\')","type":"ZONE_PURCHASEORDER_SRV_01.messageReturn"},"Type":"W","Id":"06","Number":"261","Message":"No se ha creado ningún mensaje para la salida del documento de compras","LogNo":"","LogMsgNo":"000000","MessageV1":"","MessageV2":"","MessageV3":"","MessageV4":"","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'06\',Number=\'261\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'06\',Number=\'028\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'06\',Number=\'028\')","type":"ZONE_PURCHASEORDER_SRV_01.messageReturn"},"Type":"W","Id":"06","Number":"028","Message":"La fecha de pedido se encuentra en el pasado","LogNo":"","LogMsgNo":"000000","MessageV1":"","MessageV2":"","MessageV3":"","MessageV4":"","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'06\',Number=\'028\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'ME\',Number=\'040\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'ME\',Number=\'040\')","type":"ZONE_PURCHASEORDER_SRV_01.messageReturn"},"Type":"W","Id":"ME","Number":"040","Message":"¿Se puede cumplir la fecha de entrega?","LogNo":"","LogMsgNo":"000000","MessageV1":"","MessageV2":"","MessageV3":"","MessageV4":"","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'W\',Id=\'ME\',Number=\'040\')/PurchaseOrder"}}},{"__metadata":{"id":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'I\',Id=\'ME\',Number=\'664\')","uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'I\',Id=\'ME\',Number=\'664\')","type":"ZONE_PURCHASEORDER_SRV_01.messageReturn"},"Type":"I","Id":"ME","Number":"664","Message":"No se ha podido ejecutar la modificación Centro Trabajo","LogNo":"","LogMsgNo":"000000","MessageV1":"Centro Trabajo","MessageV2":"","MessageV3":"","MessageV4":"","PurchaseOrder":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/POMsgReturnSet(Type=\'I\',Id=\'ME\',Number=\'664\')/PurchaseOrder"}}}]},"result":{"__deferred":{"uri":"http://195.235.115.142/sap/opu/odata/sap/ZONE_PURCHASEORDER_SRV_01/PurchaseOrderSet(\'\')/result"}}}}';
    }
}
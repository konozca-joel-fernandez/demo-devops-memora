/**
 * Created by mbujak003 on 25.05.2021.
 */

public with sharing class ONE_PostClientCreationQueueable {

    public class TareasQueueable implements Queueable {
        String expLineItemId;
        public TareasQueueable(String expedienteLineItemId) {
            expLineItemId = expedienteLineItemId;
        }

        public void execute(QueueableContext context) {
            ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
            fi.expedienteLineItemId = expLineItemId;
            ONE_EjacutarTareasAction.invoke(new List<ONE_EjacutarTareasAction.FlowInputs> { fi });
        }
    }

    public class SalesOrderActionQueueable implements Queueable, Database.AllowsCallouts {
        public String ordenId;
        public String tipodeCliente;
        public String numeroDeDocumento;
        public Boolean generacionFactura;
        public Boolean triggerSalesOrderAction;
        public String expedienteId;

        public SalesOrderActionQueueable(
            String newOrdenId,
            String newTipodeCliente,
            String newNumeroDeDocumento,
            Boolean genFactura,
            String newExpedienteId,
            Boolean newTriggerSalesOrderAction
        ) {
            ordenId = newOrdenId;
            tipodeCliente = newTipodeCliente;
            numeroDeDocumento = newNumeroDeDocumento;
            generacionFactura = genFactura;
            expedienteId = newExpedienteId;
            triggerSalesOrderAction = newTriggerSalesOrderAction;
        }

        public void execute(QueueableContext context) {
            ONE_SalesOrderIntegrationService.FlowInputs fi = new ONE_SalesOrderIntegrationService.FlowInputs();
            fi.ordenDeVentaId = ordenId;
           
			ONE_Orden_De_Venta__c odv= [SELECT Id,ONE_Tipo_De_Factura__c,ONE_Importe_Total__c FROM ONE_Orden_De_Venta__c WHERE Id =: ordenId];
            List<ONE_SalesOrderIntegrationService.FlowOutputs> fos = new List<ONE_SalesOrderIntegrationService.FlowOutputs> ();
            
            if((odv.ONE_Tipo_De_Factura__c=='02' && odv.ONE_Importe_Total__c<=400)|| odv.ONE_Tipo_De_Factura__c=='01'){
               fos =ONE_SalesOrderIntegrationService.invokeIntegration(new List<ONE_SalesOrderIntegrationService.FlowInputs> { fi });
            }else if(odv.ONE_Tipo_De_Factura__c=='02'&& odv.ONE_Importe_Total__c>400){
                //Error importe simplificada, no enviar a SAP
            }
            

            if(fos[0].Result == 'S') {
                List<ONE_Orden_De_Venta__c> ordens = [
                    SELECT Id FROM ONE_Orden_De_Venta__c WHERE Id =: ordenId
                ];

                if(!ordens.isEmpty()) {
                    ordens[0].ONE_Numero_de_factura__c = fos[0].invoiceNumber;
                    ordens[0].ONE_Resultado_SAP_Orden_De_Venta__c = fos[0].Result;
                    ordens[0].ONE_Estado_De_La_Orden_de_Venta__c = 'Facturado';
                    ordens[0].ONE_Identificador_TBAI_Factura__c = fos[0].idTBAI;
                    ordens[0].ONE_URL_Codigo_QR_TBAI_Factura__c = fos[0].qrTBAI;
                    update ordens;
                }
            } else {
                List<GroupMember> gms = [
                    SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'ONE_Emails_Facturacion_PagWeb'
                ];

                ONE_Expediente__c exp = [ SELECT Id, ONE_Contacto__r.ONE_Lugar__c, ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name, Name FROM ONE_Expediente__c WHERE Id =: expedienteId];

                List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                EmailTemplate et = [SELECT Id, subject, body FROM EmailTemplate WHERE DeveloperName = 'ONE_Email_Fallo_OV'];
                if(!gms.isEmpty()) {
                    for(GroupMember gm : gms) {
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.optOutPolicy = 'SEND';
                        message.plainTextBody = et.body
                            .replace('{!Account.ONE_Lugar__c}', exp.ONE_Centro_Del_Expediente__r?.ONE_Lugar__r?.ONE_Lugar_Superior__r?.Name)
                            .replace('{!ONE_Expediente__c.Name}', exp.Name);
                        message.subject = et.subject;
                        message.templateId = et.Id;
                        message.toAddresses = new List<String>();
                        message.targetObjectId = gm.UserOrGroupId;
                        message.saveAsActivity = false;
                        messages.add(message);
                    }
                    Messaging.sendEmail(messages);
                }
            }
            /*
            SE HA COMENTADO ESTA PARTE PORQUE EL USUARIO DE WEB QUE EJECUTA ESTE PROCESO NO TIENE PERMISOS PARA ACCEDER A LA VISUALFORCE PAGE PARA CREAR LA FACTURA COMERCIAL
            NI SE LE PUEDE DAR YA QUE SU TIPO DE LICENCIA ES SALESFORCE INTEGRATION Y ENTONCES NO LO PERMITE, YA SE GENERA EL PDF POR OTRO PROCESO
			if (!Test.isRunningTest()) {
            	System.enqueueJob(new DocGenQueueable(ordenId));
            }
            */
        }
    }

    public class SapClientCreationQueueable implements Queueable, Database.AllowsCallouts  {
        public String ordenId;
        public String tipodeCliente;
        public String numeroDeDocumento;
        public String expedienteId;

        public SapClientCreationQueueable(String newOrdenId, String newTipodeCliente, String newNumeroDeDocumento, String newExpedienteId) {
            ordenId = newOrdenId;
            tipodeCliente = newTipodeCliente;
            numeroDeDocumento = newNumeroDeDocumento;
            expedienteId = newExpedienteId;
        }

        public void execute(QueueableContext context) {
            Boolean triggerSOAction = false;
            ONE_ClientCreationIntegrationService.FlowInputs fi = new ONE_ClientCreationIntegrationService.FlowInputs();
            fi.ordenDeVentaId = ordenId;
            List<ONE_ClientCreationIntegrationService.FlowOutputs> fos =
                ONE_ClientCreationIntegrationService.invokeIntegration(new List<ONE_ClientCreationIntegrationService.FlowInputs> { fi });

            List<Account> accs = [
                SELECT Id, ONE_ID_Cliente_SAP__c, ONE_ID_Cliente_SAP__pc
                FROM Account
                WHERE ONE_N_Documento__pc =: numeroDeDocumento
                    OR ONE_CIF__c =: numeroDeDocumento
                LIMIT 1
            ];

            if(!accs.isEmpty()) {
                triggerSOAction = true;
                System.debug('tipodeCliente');
                System.debug(tipodeCliente);
                if(tipodeCliente == 'Particular') {
                    if(accs[0].ONE_ID_Cliente_SAP__pc == null || accs[0].ONE_ID_Cliente_SAP__pc == '') {
                        accs[0].ONE_ID_Cliente_SAP__pc = fos[0].customerId;
                    }
                } else {
                    if(accs[0].ONE_ID_Cliente_SAP__c == null || accs[0].ONE_ID_Cliente_SAP__c == '') {
                        accs[0].ONE_ID_Cliente_SAP__c = fos[0].customerId;
                        accs[0].ONE_Bypass_Facturacion_SAP__c = true;
                    }
                }
                update accs;
                Account auxAccount = new Account(
                    Id = accs[0].Id,
                    ONE_Bypass_Facturacion_SAP__c = false
                );
                update auxAccount;
            }
            
            if (!Test.isRunningTest()) {
            	System.enqueueJob(new SalesOrderActionQueueable(ordenId, tipodeCliente, numeroDeDocumento, true, expedienteId, triggerSOAction));
            }
        }
    }

    public class DocGenQueueable implements Queueable, Database.AllowsCallouts {
        public String ordenId;

        public DocGenQueueable(String newOrdenId) {
            ordenId = newOrdenId;
        }

        public void execute(QueueableContext context) {
            ONE_Orden_De_Venta__c updatedOrden = [
                SELECT Id, ONE_Numero_de_factura__c, ONE_Tipo_De_Factura__c
                FROM ONE_Orden_De_Venta__c
                WHERE Id =: ordenId
            ];

            if(updatedOrden?.ONE_Numero_de_factura__c != null && updatedOrden?.ONE_Numero_de_factura__c != '') {
                buildDocument(updatedOrden.Id, updatedOrden.ONE_Tipo_De_Factura__c, 'ES');
            }
        }

        @TestVisible
        private void buildDocument(String ordenDeVEntaId, String invoiceType, String lang) {
            if(invoiceType == '01') {
                ONE_FacturaComercialPdfService.FlowInput fi = new ONE_FacturaComercialPdfService.FlowInput();
                fi.ordenDeVentaId = ordenDeVentaId;
                fi.language = lang;
                ONE_FacturaComercialPdfService.createAndLinkPdf(new List<ONE_FacturaComercialPdfService.FlowInput> { fi });
            } else if (invoiceType == '02') {
                ONE_FacturaSimplComercialPdfService.FlowInput fi = new ONE_FacturaSimplComercialPdfService.FlowInput();
                fi.ordenDeVentaId = ordenDeVentaId;
                fi.language = lang;
                ONE_FacturaSimplComercialPdfService.createAndLinkPdf(new List<ONE_FacturaSimplComercialPdfService.FlowInput> { fi });
            }
        }
    }
}
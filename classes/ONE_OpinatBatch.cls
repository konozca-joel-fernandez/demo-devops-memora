/**
 * Created by mkuzak001 on 28.01.2021.
 */

global with sharing class ONE_OpinatBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
    //There need to be 2 callouts for each request (due to redirect)
    private static final Integer BATCH_SIZE = 1;
    //private static final Integer FROM_DATE_DAYS_NUMBER = 75;
    //private static final Integer TO_DATE_DAYS_NUMBER = 53;
    private static final Integer DAYS_BETWEEN_BATCHES = 1;
      
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Label
            FROM C_digo_de_campa_a__mdt
        ]);
    }
    
    global void execute(SchedulableContext param1) {
        Database.executeBatch(new ONE_OpinatBatch(), BATCH_SIZE);
    }
    
    global void execute(Database.BatchableContext bc, List<C_digo_de_campa_a__mdt> Campanyas) {
        Set<String> labels = new Set<String>();
        for(C_digo_de_campa_a__mdt c : Campanyas){
            labels.add(c.Label);
        }
        system.debug('labelsCampanya-->' + labels);
        List<ONE_Expediente__c> expedientesToUpdate = retrieveExpedientesValues(labels);
        update expedientesToUpdate;
    
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    
    private Map<Decimal, List<ONE_Expediente__c>> createCodigoCampanyaToExpedienteList(List<ONE_Expediente__c> records) {
        Map<Decimal, List<ONE_Expediente__c>> codigoCampanyaToExpedienteList = new Map<Decimal, List<ONE_Expediente__c>>();
        
        for (ONE_Expediente__c record : records) {
            List<ONE_Expediente__c> recordsWithSameCampaignId =
                codigoCampanyaToExpedienteList.containsKey(record.ONE_Campania__c)
                    ? codigoCampanyaToExpedienteList.get(record.ONE_Campania__c)
                    : new List<ONE_Expediente__c>();
            
            recordsWithSameCampaignId.add(record);
            codigoCampanyaToExpedienteList.put(record.ONE_Campania__c, recordsWithSameCampaignId);
        }
        
        return codigoCampanyaToExpedienteList;
    }
    
    private List<ONE_Expediente__c> retrieveExpedientesValues(Set<String> codigoCampanyaToExpedienteList) {
        List<ONE_Expediente__c> expedientesToUpdate = new List<ONE_Expediente__c>();
        
        for (String codigoCampanya : codigoCampanyaToExpedienteList) {
            system.debug('codigoCampanya-->' + codigoCampanya);
            /*ONE_OpinatIntegrationService.OpinatIntegrationCallout callout =
                new ONE_OpinatIntegrationService.OpinatIntegrationCallout(String.valueOf(codigoCampanya), Date.today().addDays(-FROM_DATE_DAYS_NUMBER), Date.today());*/
            ONE_OpinatIntegrationService.OpinatIntegrationCallout callout =
                new ONE_OpinatIntegrationService.OpinatIntegrationCallout(codigoCampanya, Date.today().addDays(-1), Date.today());
            HttpResponse res = callout.invokeCallout();
            String Link = callout.buildEndpoint().split('\\/ws')[0];
            system.debug('Opinat response-->' + res);
			system.debug('Opinat response BODY-->' + res.getBody());
            if (res.getStatusCode() == ONE_CommonConstants.HTPP_SUCCESS_CODE) {
                Map<String, ONE_OpinatIntegrationService.ResponseWrapper> codigoEncuestadoToWrapper = ONE_OpinatIntegrationService.parseResponse(res);

                List<ONE_Expediente__c> expedientesRelacionados = new List<ONE_Expediente__c>([SELECT Id, ONE_Campania__c, Name FROM ONE_Expediente__c WHERE Name IN :codigoEncuestadoToWrapper.keySet()]);
                
                if(expedientesRelacionados != null && !expedientesRelacionados.isEmpty()){
                    Map<Decimal, List<ONE_Expediente__c>> expedientesRespondidos = createCodigoCampanyaToExpedienteList(expedientesRelacionados);
                    system.debug('Decimal.valueOf-->' + Decimal.ValueOf(codigoCampanya));
                    system.debug('Expediente-->' + expedientesRespondidos.get(Decimal.ValueOf(codigoCampanya)));
                    if (expedientesRespondidos.get(Decimal.ValueOf(codigoCampanya)) != null){
                        for (ONE_Expediente__c expediente : expedientesRespondidos.get(Decimal.ValueOf(codigoCampanya))) {
                            ONE_OpinatIntegrationService.ResponseWrapper responseWrapper = codigoEncuestadoToWrapper.get(expediente.Name);
                            system.debug('Expediente to MAP-->' + expediente);
                            system.debug('responseWrapper-->' + responseWrapper);

                            if (expediente != null && responseWrapper != null) {
                                expediente.ONE_Comentario_De_La_Encuesta__c = responseWrapper.getComentario()!=null?responseWrapper.getComentario():'';
                                expediente.ONE_Motivos__c = responseWrapper.getMotivos()!=null?responseWrapper.getMotivos():'';
                                expediente.ONE_Link_A_La_Encuesta__c = responseWrapper.getLink()!=null? Link + responseWrapper.getLink():'';
                                expediente.ONE_Valoracion_NPS__c = responseWrapper.getValoracion() != null ? Decimal.valueOf(responseWrapper.getValoracion()) : null;
                                expediente.ONE_Fecha_respuesta__c = responseWrapper.getFechaRespuesta() != null ? DateTime.valueOf(responseWrapper.getFechaRespuesta()) : null;
                                expediente.ONE_Contacto_urgente__c = responseWrapper.getContactoUrgente() != null ? true : false;
                                
                                expedientesToUpdate.add(expediente);
                            }
                        }
                    }

                    // Se guardan las valoraciones sin importar las campañas.
                    
                    // for (ONE_Expediente__c expediente : expedientesRelacionados) {
                    //     ONE_OpinatIntegrationService.ResponseWrapper responseWrapper = codigoEncuestadoToWrapper.get(expediente.Name);
                    //     system.debug('Expediente to MAP-->' + expediente);
                    //     system.debug('responseWrapper-->' + responseWrapper);

                    //     if (expediente != null && responseWrapper != null) {
                    //         expediente.ONE_Comentario_De_La_Encuesta__c = responseWrapper.getComentario()!=null?responseWrapper.getComentario():'';
                    //         expediente.ONE_Motivos__c = responseWrapper.getMotivos()!=null?responseWrapper.getMotivos():'';
                    //         expediente.ONE_Link_A_La_Encuesta__c = responseWrapper.getLink()!=null?responseWrapper.getLink():'';
                    //         expediente.ONE_Valoracion_NPS__c = responseWrapper.getValoracion() != null ? Decimal.valueOf(responseWrapper.getValoracion()) : null;
                            
                    //         expedientesToUpdate.add(expediente);
                    //     }
                    // }
                    
                }
            }
        }
        
        return expedientesToUpdate;
    }
}
/**
* File Name: ONE_AltaSiniestroKBSBatch
* Description: 	Batch created to send orders to Kutxabank for budget generation
* Date: 10/10/2025
*
* Copyright: Konozca Consulting
* @author: Marc Pàmies
* Test: ONE_AltaSiniestroKBSTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		10/10/2025		Marc Pàmies  		Class creation
* 02        21/10/2025      Marc Pàmies         Modified filter to avoid processing cancelled cases
* ===================================================================================================================
*/

global class ONE_AltaSiniestroKBSBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    private List<ONE_Caso__c> casosSinPoliza = new List<ONE_Caso__c>();
    private List<String> casosConErrores = new List<String>();
    private List <String> casosFlagNames = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, ONE_Numero_De_Siniestro_Texto__c, ONE_Numero_De_Poliza__c, ONE_Numero_De_Poliza_texto__c, ONE_KBSErrorFlag__c
            FROM ONE_Caso__c
            WHERE ONE_Tipo__c = 'Kutxabank'
            AND ONE_Numero_De_Siniestro_Texto__c = null
            AND CreatedDate > 2025-10-21T00:00:00.000+0000
            AND ONE_Estado_Del_Caso__c != 'Anulado'
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Executing ONE_AltaSiniestroKBSBatch for ' + scope.size() + ' casos.');

        List<ONE_Caso__c> casosConPoliza = new List<ONE_Caso__c>();

        for (ONE_Caso__c caso : (List<ONE_Caso__c>) scope) {
            System.debug('CASO: ' + caso);
            if ((String.isNotBlank(caso.ONE_Numero_De_Poliza__c) || String.isNotBlank(caso.ONE_Numero_De_Poliza_texto__c)) && !caso.ONE_KBSErrorFlag__c) {
                casosConPoliza.add(caso);
            }
            else if(caso.ONE_KBSErrorFlag__c) {
                casosFlagNames.add('- ' + caso.Name + ' (' + caso.Id + ')\n');
            } 
            else {
                casosSinPoliza.add(caso);
            }
        }

        if (!casosConPoliza.isEmpty()) {
            Map<Id, ONE_OpenLifeClaimIntegrationService.FlowOutputs> resultados = new Map<Id, ONE_OpenLifeClaimIntegrationService.FlowOutputs>();
            Map<Id, String> caseIdToName = new Map<Id, String>();

            for (ONE_Caso__c caso : casosConPoliza) {
                ONE_OpenLifeClaimIntegrationService.FlowInputs inputs = new ONE_OpenLifeClaimIntegrationService.FlowInputs();
                inputs.casoId = caso.Id;
                inputs.service = 'kutxabank';
                inputs.batchKBS = true;
                ONE_OpenLifeClaimIntegrationService.FlowOutputs res = ONE_OpenLifeClaimIntegrationService.invokeIntegration(new List<ONE_OpenLifeClaimIntegrationService.FlowInputs>{inputs})[0];
                resultados.put(caso.Id, res);
                caseIdToName.put(caso.Id, caso.Name);
            }

            List<ONE_Caso__c> casosToUpdate = new List<ONE_Caso__c>();
            for (Id casoId : resultados.keySet()) {
                ONE_OpenLifeClaimIntegrationService.FlowOutputs res = resultados.get(casoId);
                if (res.success) {
                    casosToUpdate.add(new ONE_Caso__c(
                        Id = casoId,
                        ONE_Numero_De_Siniestro_Texto__c = res.returnValue
                    ));
                }
                else{
                    if (res.errorCode != 503) {
                        casosToUpdate.add(new ONE_Caso__c(
                            Id = casoId,
                            ONE_KBSErrorFlag__c = true
                        ));
                    }
                    casosConErrores.add('- ' + caseIdToName.get(casoId) + ' (' + casoId + '): ' + res.returnValue + '\n');
                }
            }

            if (!casosToUpdate.isEmpty()) {
                update casosToUpdate;
            }
        }
    }


    global void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Boolean sendMail = false;
        List<String> addresses = new List<String>();
        String body = '';
        if (!casosSinPoliza.isEmpty()) {
            sendMail = true;
            addresses.add('antonio.saiz@asistea.com');
            body = 'Se han encontrado los siguientes casos sin número de póliza:\n\n';
            for (ONE_Caso__c caso : casosSinPoliza) {
                body += '- ' + caso.Name + ' (' + caso.Id + ')\n';
            }
            body += '\n';
        }
        if (!casosConErrores.isEmpty()) {
            sendMail = true;
            if(addresses.isEmpty()){
                addresses.add('antonio.saiz@asistea.com');
            }
            addresses.add('marc.pamies@konozca.com');
            addresses.add('palcover@memora.es');
            body += 'Se han producido errores al enviar los siguientes casos:\n\n';
            for (String errorEntry : casosConErrores) {
                body += errorEntry;
            }
            body += '\n';
        }
        if (!casosFlagNames.isEmpty()) {
            sendMail = true;
            if(addresses.isEmpty()){
                addresses.add('antonio.saiz@asistea.com');
                addresses.add('marc.pamies@konozca.com');
                addresses.add('palcover@memora.es');
            }
            else if(!casosConErrores.isEmpty()){
            }
            else{
                addresses.add('marc.pamies@konozca.com');
                addresses.add('palcover@memora.es');
            }
            body += 'Los siguientes casos han tenido errores y siguen sin enviarse:\n\n';
            for (String casoEntry : casosFlagNames) {
                body += casoEntry;
            }
            body += '\n';
        }
        if(sendMail){
            email.setSubject('Resumen Diario - Apertura de siniestros automática KBS');
            email.setPlainTextBody(body);
            email.setToAddresses(addresses);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }
}
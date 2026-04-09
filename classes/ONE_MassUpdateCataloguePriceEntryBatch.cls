/**
 * Created by ljura001 on 3/2/2022.
 */

public with sharing class ONE_MassUpdateCataloguePriceEntryBatch implements Database.Batchable<sObject> {

    Set<Id> masterCatalogueIds = new Set<Id>();
    Map<String, Map<String, Decimal>> percentMap = new Map<String, Map<String, Decimal>>();
    Map<String, Date> dateMap = new Map<String, Date>();
    

    public ONE_MassUpdateCataloguePriceEntryBatch(List<ONE_MassUpdateCataloguePriceEntry.FlowInputs> inputsList) {
        for (ONE_MassUpdateCataloguePriceEntry.FlowInputs fi : inputsList) {
            masterCatalogueIds.add(fi.catalogueId);
            dateMap.put(fi.catalogueId, fi.vigenteHastaDate);

            percentMap.put(fi.catalogueId, new Map<String, Decimal>());
            percentMap.get(fi.catalogueId).put('A', fi.percentA + 1);
            percentMap.get(fi.catalogueId).put('B', fi.percentB + 1);
            percentMap.get(fi.catalogueId).put('C', fi.percentC + 1);
            percentMap.get(fi.catalogueId).put('N', fi.percentN + 1);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, ONE_Catalogo_De_Precios__c, ONE_Precio__c, ONE_Concepto_Comercial__c, ' +
            'ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c, ONE_Vigente_Desde__c, ONE_Vigente_Hasta__c, ' +
            '(SELECT Id, ONE_Catalogo_De_Precios__c, ONE_Catalogo_De_Precios__r.ONE_Indice_Para_Flores__c, ' +
            'ONE_Catalogo_De_Precios__r.ONE_Indice_Para_Otros_Productos__c, ONE_Concepto_Comercial__c, ' +
            'ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c, ONE_Concepto_Comercial__r.ONE_Flores__c, ' +
            'ONE_Entrada_De_Precio_Padre__c, ONE_Vigente_Desde__c, ONE_Vigente_Hasta__c ' +
            'FROM Entradas_de_precios__r ' +
            'WHERE ONE_Activo_Vigencia__c = TRUE AND ONE_Catalogo_De_Precios__r.ONE_Activo_Vigencia__c = TRUE) ' +
            'FROM ONE_Entrada_De_Precio__c ' +
            'WHERE ONE_Catalogo_De_Precios__c IN :masterCatalogueIds AND ONE_Activo_Vigencia__c = TRUE'
        );
    }

    public void execute(Database.BatchableContext bc, List<ONE_Entrada_De_Precio__c> priceEntryList){
        Map<Id, ONE_Entrada_De_Precio__c> master2CopyPricesMap = new Map<Id, ONE_Entrada_De_Precio__c>();
        List<ONE_Entrada_De_Precio__c> masterPricesToUpsert = new List<ONE_Entrada_De_Precio__c>();
        Map<ONE_Entrada_De_Precio__c, List<ONE_Entrada_De_Precio__c>> newMaster2ChildPricesMap =
                new Map<ONE_Entrada_De_Precio__c, List<ONE_Entrada_De_Precio__c>>();
        List<ONE_Entrada_De_Precio__c> childPricesToUpsert = new List<ONE_Entrada_De_Precio__c>();

        for (ONE_Entrada_De_Precio__c p : priceEntryList) {
            ONE_Entrada_De_Precio__c copiedPrice = p.clone(false, true, false, false);
            Decimal increaseFactor = percentMap.get(p.ONE_Catalogo_De_Precios__c).get(p.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c);
            copiedPrice.ONE_Precio__c = p.ONE_Precio__c;
            if (increaseFactor != null) {
                copiedPrice.ONE_Precio__c *= increaseFactor;
            }
            copiedPrice.ONE_Vigente_Desde__c = dateMap.get(p.ONE_Catalogo_De_Precios__c);

            p.ONE_Vigente_Hasta__c = dateMap.get(p.ONE_Catalogo_De_Precios__c).addDays(-1);
            masterPricesToUpsert.add(p);

            master2CopyPricesMap.put(p.Id, copiedPrice);
        }

        masterPricesToUpsert.addAll(master2CopyPricesMap.values());

        upsert masterPricesToUpsert;

        for (ONE_Entrada_De_Precio__c p : priceEntryList) {
            newMaster2ChildPricesMap.put(master2CopyPricesMap.get(p.Id), p.Entradas_de_precios__r);
        }

        for (ONE_Entrada_De_Precio__c masterCopy : newMaster2ChildPricesMap.keySet()) {
            for (ONE_Entrada_De_Precio__c child : newMaster2ChildPricesMap.get(masterCopy)) {
                ONE_Entrada_De_Precio__c copiedChild = child.clone(false, true, false, false);
                copiedChild.ONE_Entrada_De_Precio_Padre__c = masterCopy.Id;
                copiedChild.ONE_Vigente_Desde__c = masterCopy.ONE_Vigente_Desde__c;
                child.ONE_Vigente_Hasta__c = masterCopy.ONE_Vigente_Desde__c.addDays(-1);

                if (child.ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c == ONE_CommonConstants.PRODUCT_PRECIO_UNICO) {
                    copiedChild.ONE_Precio__c = masterCopy.ONE_Precio__c;
                } else if (child.ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c == ONE_CommonConstants.PRODUCT_PRECIO_INDEXADO
                        && child.ONE_Concepto_Comercial__r.ONE_Flores__c) {
                    copiedChild.ONE_Precio__c = masterCopy.ONE_Precio__c * child.ONE_Catalogo_De_Precios__r.ONE_Indice_Para_Flores__c;
                } else if (child.ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c == ONE_CommonConstants.PRODUCT_PRECIO_INDEXADO
                        && !child.ONE_Concepto_Comercial__r.ONE_Flores__c) {
                    copiedChild.ONE_Precio__c = masterCopy.ONE_Precio__c * child.ONE_Catalogo_De_Precios__r.ONE_Indice_Para_Otros_Productos__c;
                }
                childPricesToUpsert.add(child);
                childPricesToUpsert.add(copiedChild);
            }
        }

        upsert childPricesToUpsert;
    }

    public void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSenderDisplayName('Salesforce Support');
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setSaveAsActivity(false);

        EmailTemplate emailTemplate =[SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ONE_Finalizacion_Subida_De_Precios_Particular'];
        mail.setTemplateID(emailTemplate.Id); 
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        if (results[0].success)
         {
           System.debug('The email was sent successfully.');
         }
        else
         {
           System.debug('The email failed to send: ' + results[0].errors[0].message);
         }
    }
}
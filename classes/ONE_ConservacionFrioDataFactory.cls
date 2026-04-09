public with sharing class ONE_ConservacionFrioDataFactory {
    
    public static ONE_ConservacionFrioData buildConservacionFrioData(String accountId, String language){
        
        String headerLogoUrl = getLogoSociedadUrl(accountId);
        String signatureUrl = getFirmaUrl(accountId);
        List<ONE_ConservacionFrioData.ONE_ConservacionData> conservacionesList = getConservacionesList(accountId);
                
        ONE_ConservacionFrioData data = new ONE_ConservacionFrioData(
            headerLogoUrl,
            signatureUrl,
            conservacionesList,
            language,
            Datetime.now()
        );
        
        return data;
        
    }
    
    private static String getLogoSociedadUrl(String accountId){
        Account acc = [select ONE_URL_logo__c, ONE_Sociedad2__r.ONE_URL_logo__c from Account where Id = :accountId];
        
        return acc.ONE_URL_logo__c != null
            ? acc.ONE_URL_logo__c
            : acc.ONE_Sociedad2__r?.ONE_URL_logo__c;
    }
    
    private static String getFirmaUrl(String accountId){
        return [select ONE_Sociedad2__r.ONE_URL_Sello__c from Account where Id = :accountId].ONE_Sociedad2__r?.ONE_URL_Sello__c;
    }
    
    private static List<ONE_ConservacionFrioData.ONE_ConservacionData> getConservacionesList (String accountId){

        Account account = [SELECT ONE_Delegacion__c FROM Account WHERE Id = :accountId];

        List<ONE_Presupuesto__c> presupuestos = [   SELECT
                                                        ONE_Expediente__r.Name,
                                                        ONE_Expediente__r.ONE_Nombre_Apellidos_Del_Difunto__c,
                                                        ONE_Pagador_Compania__r.Name,
                                                        ONE_Expediente__r.ONE_Inicio_Deposito__c,
                                                        ONE_Expediente__r.ONE_Inicio_Incineracion__c
                                                    FROM ONE_Presupuesto__c
                                                    WHERE
                                                        ONE_Expediente__r.ONE_Inicio_Incineracion__c = TOMORROW
                                                        AND ONE_Tipo_De_Presupuesto__c = 'Presupuesto servicio completo'
                                                        AND ONE_Presupuesto_Cancelado__c = false
                                                        AND ONE_Expediente__r.ONE_Gerencia__c = :account.ONE_Delegacion__c
                                                    ORDER BY ONE_Expediente__r.ONE_Inicio_Incineracion__c ASC];
        List<ONE_ConservacionFrioData.ONE_ConservacionData> conservacionesList = new List<ONE_ConservacionFrioData.ONE_ConservacionData>();
        
        for(ONE_Presupuesto__c item : presupuestos){
            conservacionesList.add(
                new ONE_ConservacionFrioData.ONE_ConservacionData(
                    item.ONE_Expediente__r?.Name,
                    item.ONE_Expediente__r?.ONE_Nombre_Apellidos_Del_Difunto__c,
                    item.ONE_Pagador_Compania__r?.Name,
                    item.ONE_Expediente__r?.ONE_Inicio_Deposito__c,
                    item.ONE_Expediente__r?.ONE_Inicio_Incineracion__c
                )
            );
        }
        
        return conservacionesList;
    }

}
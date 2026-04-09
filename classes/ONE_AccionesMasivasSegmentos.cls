public with sharing class ONE_AccionesMasivasSegmentos {
    @InvocableMethod(label='Get Segmentos With Filters' description='Returns the list of segmentos  corresponding to the specified flow filters.')
    public static List<List<ONE_Segmentacion_De_Linea__c>> getSegmentos(List<List<String>> filters) {
        List<List<ONE_Segmentacion_De_Linea__c>> segmentos=new List<List<ONE_Segmentacion_De_Linea__c>>();
        String jerarquiaId;
        String zonaId;
        System.debug('Filters : '+ filters);
        System.debug('Filter1 : '+ filters[0][0]);
        System.debug('Filter2 : '+ filters[0][1]);
        System.debug('Filter3 : '+ filters[0][2]);
        System.debug('Filter4 : '+ filters[0][3]);
        List<String> segmentosSelected= filters[0][1].split(';');
        if (filters[0].size()==4) {
            segmentos.add([SELECT Name, ONE_Sergmento_Acuerdo_Name__c, ONE_Producto__c, ONE_Comportamiento__c,ONE_Segmentacion_Acuerdo__c,ONE_Segmentacion_Acuerdo__r.ONE_Segmentacion_Interna__c,Id,Segmentacion_Interna__c,ONE_Zona_Formula__c,ONE_Centro_Formula__c
                      FROM ONE_Segmentacion_De_Linea__c 
                      WHERE ONE_Producto__c =:filters[0][0] AND
                            ONE_Segmentacion_Acuerdo__r.ONE_Segmentacion_Interna__c !=null AND 
                            ONE_Segmentacion_Acuerdo__r.ONE_Segmentacion_Interna__c IN :segmentosSelected
                        AND (ONE_Segmentacion_Acuerdo__r.ONE_Lugar__c=:filters[0][2] 
                            OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][2]
                            OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][2]
                            OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][2]
                            OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__c=:filters[0][2]
                        	OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][2]
                        	OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][2]
                        	OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][2])
                        AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Desde__c <=:date.valueOf(filters[0][3]))
                        AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3])OR ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c =null)]);    
                            System.debug('segmentos'+ segmentos);
                            
        }else {
            return null;
        }
    return segmentos;
  }
}
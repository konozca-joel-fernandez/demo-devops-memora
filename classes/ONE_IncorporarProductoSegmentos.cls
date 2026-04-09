public with sharing class ONE_IncorporarProductoSegmentos {
    @InvocableMethod(label='Get Segmentos With Filters(Incorporar)' description='Returns the list of segmentos  corresponding to the specified flow filters.')
    public static List<List<ONE_Segmentacion_Acuerdo__c>> getSegmentos(List<List<String>> filters) {
        List<List<ONE_Segmentacion_Acuerdo__c>> segmentos=new List<List<ONE_Segmentacion_Acuerdo__c>>();
        String jerarquiaId;
        String zonaId;
        System.debug('Filters : '+ filters);
        System.debug('Filter1 : '+ filters[0][0]);
        System.debug('Filter2 : '+ filters[0][1]);
        System.debug('Filter3 : '+ filters[0][2]);
        System.debug('Filter4 : '+ filters[0][3]);
        List<String> segmentosSelected= filters[0][1].split(';');
        List<String> segmentosWithoutProduct=new List<String>();
        if (filters[0].size()==4) {
            AggregateResult[] segmentosWithProduct=[SELECT ONE_Segmentacion_Acuerdo__c
                                                FROM ONE_Segmentacion_De_Linea__c 
                                                WHERE  ONE_Producto__c =:filters[0][0] AND
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
                                                AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3]) OR ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c =null)
                                                GROUP BY ONE_Segmentacion_Acuerdo__c];
            AggregateResult[] segmentosTotal=[SELECT ONE_Segmentacion_Acuerdo__c
                                                FROM ONE_Segmentacion_De_Linea__c 
                                                WHERE 
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
                                                AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3]) OR ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c =null)
                                                GROUP BY ONE_Segmentacion_Acuerdo__c];
           
            for(AggregateResult ag:segmentosTotal){
                if(!segmentosWithProduct.contains(ag)){
                    System.debug('AG:'+ ag);
                    segmentosWithoutProduct.add(String.valueOf(ag.get('ONE_Segmentacion_Acuerdo__c')));
                }
            }
            System.debug('segmentosTotalsize '+ segmentosTotal.size());
            System.debug('segmentosWithProductsize '+ segmentosWithProduct.size());
            System.debug('segmentosWithoutProductsize '+ segmentosWithoutProduct.size());
            
            segmentos.add([SELECT Name, Id, ONE_Segmentacion_Interna__c, ONE_Lugar__c, ONE_Activo_Vigencia__c
            FROM ONE_Segmentacion_Acuerdo__c
            WHERE 
                 ONE_Segmentacion_Interna__c !=null AND 
                 ONE_Segmentacion_Interna__c IN :segmentosSelected
              AND (ONE_Lugar__c=:filters[0][2] 
                  OR ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][2] 
                  OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c=:filters[0][2]
                  OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c=:filters[0][2]
                  OR ONE_Centro__r.ONE_Lugar__c=:filters[0][2]
                  OR ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][2]
                  OR ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][2]
                  OR ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][2])
              AND (ONE_Vigencia_Desde__c <=:date.valueOf(filters[0][3]))
              AND (ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3]) OR ONE_Vigencia_Hasta__c =null)
              AND Id IN :segmentosWithoutProduct]);    
              
              System.debug('segmentos'+ segmentos);
            
        }else {
            return null;
        }
    return segmentos;
  }
}
public without sharing class ONE_IncorporarProductoAcuerdos {
    @InvocableMethod(label='Get Acuerdos With Filters(Incorporar)' description='Returns the list of acuerdos  corresponding to the specified flow filters.')
    public static List<List<ONE_Segmentacion_Acuerdo__c>> getAcuerdos(List<List<String>> filters) {
        List<List<ONE_Segmentacion_Acuerdo__c>> acuerdos=new List<List<ONE_Segmentacion_Acuerdo__c>>();
        String jerarquiaId;
        String zonaId;
        System.debug('Filters : '+ filters);
        System.debug('Filter1 : '+ filters[0][0]);
        System.debug('Filter2 : '+ filters[0][1]);
        System.debug('Filter3 : '+ filters[0][2]);
        System.debug('Filter4 : '+ filters[0][3]);
        List<String> acuerdosWithoutProduct=new List<String>();
        if (filters[0].size()==4) {
            AggregateResult[] acuerdosWithProduct=[SELECT ONE_Segmentacion_Acuerdo__c
                                                    FROM ONE_Segmentacion_De_Linea__c 
                                                    WHERE ONE_Producto__c =:filters[0][0] AND
                                                    ONE_Segmentacion_Acuerdo__r.ONE_Acuerdo_Con_Entidad__c!=false AND 
                                                    (ONE_Segmentacion_Acuerdo__r.ONE_Lugar__c=:filters[0][1] 
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                    	OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__c=:filters[0][1]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1])  
                                                    AND (ONE_Segmentacion_Acuerdo__r.ONE_Compania__c =:filters[0][2]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.ParentId =:filters[0][2]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.Parent.ParentId=:filters[0][2]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.Parent.Parent.ParentId=:filters[0][2]
                                                        OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.Parent.Parent.Parent.ParentId=:filters[0][2])
                                                    AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Desde__c <=:date.valueOf(filters[0][3]))
                                                    AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3]) OR ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c =null)
                                                    GROUP BY ONE_Segmentacion_Acuerdo__c];
            AggregateResult[] acuerdosTotal=[SELECT ONE_Segmentacion_Acuerdo__c
                                                FROM ONE_Segmentacion_De_Linea__c 
                                                WHERE 
                                                ONE_Segmentacion_Acuerdo__r.ONE_Acuerdo_Con_Entidad__c!=false AND 
                                                (ONE_Segmentacion_Acuerdo__r.ONE_Lugar__c=:filters[0][1] 
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                 	OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__c=:filters[0][1]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1])
                                                AND (ONE_Segmentacion_Acuerdo__r.ONE_Compania__c =:filters[0][2]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.ParentId =:filters[0][2]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.Parent.ParentId=:filters[0][2]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.Parent.Parent.ParentId=:filters[0][2]
                                                    OR ONE_Segmentacion_Acuerdo__r.ONE_Compania__r.Parent.Parent.Parent.ParentId=:filters[0][2])
                                                AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Desde__c <=:date.valueOf(filters[0][3]))
                                                AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3]) OR ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c =null)
                                                GROUP BY ONE_Segmentacion_Acuerdo__c];
           
            for(AggregateResult ag:acuerdosTotal){
                if(!acuerdosWithProduct.contains(ag)){
                    acuerdosWithoutProduct.add(String.valueOf(ag.get('ONE_Segmentacion_Acuerdo__c')));
                }
            }
            System.debug('acuerdosTotalsize '+ acuerdosTotal.size());
            System.debug('acuerdosWithProductsize '+ acuerdosWithProduct.size());
            System.debug('acuerdosWithoutProductsize '+ acuerdosWithoutProduct.size());
            acuerdos.add([SELECT Name,Id, ONE_Vigencia_Desde__c, ONE_Vigencia_Hasta__c, ONE_Activo_Vigencia__c,ONE_Lugar__c,ONE_Centro__c,ONE_Compania__c
            FROM ONE_Segmentacion_Acuerdo__c
            WHERE ONE_Acuerdo_Con_Entidad__c!=false AND 
              (ONE_Lugar__c=:filters[0][1] 
                  OR ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][1]
                  OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                  OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
               	  OR ONE_Centro__r.ONE_Lugar__c=:filters[0][1]
                  OR ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__c =:filters[0][1]
                  OR ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1]
                  OR ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =:filters[0][1])
              AND (ONE_Compania__c =:filters[0][2]
                  OR ONE_Compania__r.ParentId =:filters[0][2]
                  OR ONE_Compania__r.Parent.ParentId=:filters[0][2]
                  OR ONE_Compania__r.Parent.Parent.ParentId=:filters[0][2]
                  OR ONE_Compania__r.Parent.Parent.Parent.ParentId=:filters[0][2])
              AND ONE_Vigencia_Desde__c <=:date.valueOf(filters[0][3])  AND (ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3]) OR ONE_Vigencia_Hasta__c =null)
              AND Id IN :acuerdosWithoutProduct]);
              System.debug('acuerdos'+ acuerdos);
        }else {
            return null;
        }
    return acuerdos;
  }

}
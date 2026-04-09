public without sharing class ONE_AccionesMasivasAcuerdos {
    @InvocableMethod(label='Get Acuerdos With Filters' description='Returns the list of acuerdos  corresponding to the specified flow filters.')
    public static List<List<ONE_Segmentacion_De_Linea__c>> getAcuerdos(List<List<String>> filters) {
        List<List<ONE_Segmentacion_De_Linea__c>> acuerdos=new List<List<ONE_Segmentacion_De_Linea__c>>();
        String jerarquiaId;
        String zonaId;
        System.debug('Filters : '+ filters);
        System.debug('Filter1 : '+ filters[0][0]);
        System.debug('Filter2 : '+ filters[0][1]);
        System.debug('Filter3 : '+ filters[0][2]);
        System.debug('Filter4 : '+ filters[0][3]);
        if (filters[0].size()==4) {
            acuerdos.add([SELECT Name,ONE_Segmentacion_Acuerdo__r.Name, ONE_Producto__c, ONE_Comportamiento__c,Acuerdo_con_Entidad__c,ONE_Sergmento_Acuerdo_Name__c,ONE_Segmentacion_Acuerdo__r.Id, ONE_Zona_Formula__c, ONE_Centro_Formula__c
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
                        AND (ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c >=:date.valueOf(filters[0][3]) OR ONE_Segmentacion_Acuerdo__r.ONE_Vigencia_Hasta__c =null)]);
                            System.debug('acuerdos'+ acuerdos);
        }else {
            return null;
        }
    return acuerdos;
  }
}
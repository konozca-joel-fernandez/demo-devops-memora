public with sharing class ONE_MarcadorPuntosColocacionController {

    @AuraEnabled(cacheable=true)
    public static List<ONE_Punto_de_Colocacion__c> getPuntosDeColocacion(Id tareaId) {
        Id sliId = [SELECT ONE_Linea_De_Expediente__c FROM ONE_Tarea__c WHERE Id = :tareaId LIMIT 1].ONE_Linea_De_Expediente__c;
        return [SELECT Id, Name, ONE_Colocado__c, ONE_Direccion__c, ONE_Municipio__c, ONE_Provincia_picklist__c FROM ONE_Punto_de_Colocacion__c WHERE ONE_Linea_de_servicio__c = :sliId AND ONE_Invalido__c = false AND ONE_Seleccionado__c = true ORDER BY Name ASC];
    }

    @AuraEnabled(cacheable=true)
    public static List<ONE_Punto_de_Colocacion__c> getPuntosDeColocacionHistorial(Id tareaId) {
        Id sliId = [SELECT ONE_Linea_De_Expediente__c FROM ONE_Tarea__c WHERE Id = :tareaId LIMIT 1].ONE_Linea_De_Expediente__c;
        return [SELECT Id, Name, ONE_Colocado__c, ONE_Direccion__c, ONE_Municipio__c, ONE_Provincia_picklist__c FROM ONE_Punto_de_Colocacion__c WHERE ONE_Linea_de_servicio__c = :sliId AND ONE_Invalido__c = true AND ONE_Seleccionado__c = true ORDER BY Name ASC];
    }

    @AuraEnabled(cacheable=false)
    public static Boolean existenReseteados(Id tareaId) {
        Id sliId = [SELECT ONE_Linea_De_Expediente__c FROM ONE_Tarea__c WHERE Id = :tareaId LIMIT 1].ONE_Linea_De_Expediente__c;
        Integer countReseteados = [SELECT COUNT() FROM ONE_Punto_de_Colocacion__c WHERE ONE_Linea_de_servicio__c = :sliId AND ONE_Invalido__c = true];
        return countReseteados > 0;
    }

    @AuraEnabled(cacheable=false)
    public static void resetearPuntos(Id tareaId) {
        Id sliId = [SELECT ONE_Linea_De_Expediente__c FROM ONE_Tarea__c WHERE Id = :tareaId LIMIT 1].ONE_Linea_De_Expediente__c;
        List<ONE_Punto_de_Colocacion__c> puntos = [SELECT Id, ONE_Invalido__c, ONE_Colocado__c, ONE_Custom__c, ONE_Direccion__c, ONE_Indicaciones_Extra__c, ONE_Linea_de_servicio__c, ONE_Municipio__c,
                                                    ONE_Numero_SLI__c, ONE_Provincia_picklist__c, Name, ONE_RouteId__c, ONE_Seleccionado__c, ONE_StopId__c
                                                    FROM ONE_Punto_de_Colocacion__c WHERE ONE_Linea_de_servicio__c = :sliId AND ONE_Invalido__c = false AND ONE_Seleccionado__c = true];
        List<ONE_Punto_de_Colocacion__c> duplicatePoints = new List<ONE_Punto_de_Colocacion__c>();
        for(ONE_Punto_de_Colocacion__c punto : puntos) {
            ONE_Punto_de_Colocacion__c copiaPunto = punto.clone(false,false,false,false);
            copiapunto.ONE_Colocado__c = false;
            duplicatePoints.add(copiapunto);
            punto.ONE_Invalido__c = true;
        }
        insert duplicatePoints;
        update puntos; 
    }
}
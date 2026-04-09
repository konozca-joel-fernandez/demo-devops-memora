public with sharing class ONE_ExpedienteSelector {
    public static ONE_Expediente__c selectExpediente(Id expedienteId) {
        return [
                SELECT Id, ONE_Codigo_Difunto_CBSA__c, ONE_Causas_Defuncion__c, ONE_Hora_Destino_Final__c, ONE_Destino_Final__c,
                        ONE_Fecha_De_Defuncion__c, ONE_Estado_Del_Difunto__c, ONE_Tipo_De_Servicio_CB__c, ONE_Inicio_Incineracion__c,
                        ONE_Difunto__r.FirstName, ONE_Difunto__r.LastName, ONE_Difunto__r.ONE_Tipo_de_documento__pc,
                        ONE_Difunto__r.ONE_N_Documento__pc, ONE_Difunto__r.ONE_Sexo__c, ONE_Difunto__r.ONE_Pais__pc,
                        ONE_Difunto__r.ONE_Provincia__pc, ONE_Difunto__r.ONE_Municipio__pc, ONE_Difunto__r.ONE_Direccion__pc,
                        ONE_Difunto__r.ONE_Codigo_Postal__pc, ONE_Difunto__r.Phone, ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc,
                        ONE_Tipo_De_Lugar_De_Incineracion__c, ONE_Tipo_De_Lugar_Destino_Final__c, ONE_Lugar_Incineracion__c,
                        ONE_Incineracion__c, ONE_Cementerio__c
                FROM ONE_Expediente__c
                WHERE Id = :expedienteId
                LIMIT 1
        ];
    }
}
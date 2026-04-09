public with sharing class ONE_LeadsOlympiaWSHelper {
    
    public static String buildReqBody(Id oppId){

        ONE_Oportunidad__c opp = [SELECT 
                                ONE_Localizacion_puesto__c, 
                                ONE_Destinatario_s_de_la_informaci_n__c, 
                                ONE_Observaciones__c, 
                                ONE_Gerencia__r.Name, 
                                ONE_Contacto__r.Name,
                                ONE_Contacto__r.Phone,
                                ONE_Contacto__r.ONE_Email__c,
                                ONE_Prescriptor__r.Name,
                                ONE_Prescriptor__r.Title,
                                ONE_Prescriptor__r.Department,
                                ONE_Prescriptor__r.ONE_Codigo_Usuario_SAP__c 
                                FROM ONE_Oportunidad__c WHERE Id = :oppId LIMIT 1];


        Map<String, String> mapReqBody = new Map<String, String>();
        mapReqBody.put('fechaRegistro', DateTime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        system.debug('Fecha de registro: ' + mapReqBody.get('fechaRegistro'));
        mapReqBody.put('nombreUsuario', opp.ONE_Prescriptor__r.Name);
        system.debug('Nombre de usuario: ' + mapReqBody.get('nombreUsuario'));
        mapReqBody.put('categoriaProfesional', '');
        system.debug('Categoría profesional: ' + mapReqBody.get('categoriaProfesional'));
        mapReqBody.put('prescriptorCargo', opp.ONE_Prescriptor__r.Title);
        system.debug('Prescriptor cargo: ' + mapReqBody.get('prescriptorCargo'));
        mapReqBody.put('prescriptorDepartamento', '');
        system.debug('Prescriptor departamento: ' + mapReqBody.get('prescriptorDepartamento'));
        mapReqBody.put('prescriptorUsuarioSAP', opp.ONE_Prescriptor__r.ONE_Codigo_Usuario_SAP__c);
        system.debug('Prescriptor usuario SAP: ' + mapReqBody.get('prescriptorUsuarioSAP'));
        mapReqBody.put('localizacionPuesto', opp.ONE_Localizacion_puesto__c);
        system.debug('Localización puesto: ' + mapReqBody.get('localizacionPuesto'));
        mapReqBody.put('nombreLead', opp.ONE_Contacto__r.Name);
        system.debug('Nombre Lead: ' + mapReqBody.get('nombreLead'));
        mapReqBody.put('telefono', opp.ONE_Contacto__r.Phone); 
        system.debug('Teléfono: ' + mapReqBody.get('telefono'));
        mapReqBody.put('email', opp.ONE_Contacto__r.ONE_Email__c);
        system.debug('Email: ' + mapReqBody.get('email'));
        mapReqBody.put('gerencia', opp.ONE_Gerencia__r.Name);
        system.debug('Gerencia: ' + mapReqBody.get('gerencia'));
        mapReqBody.put('destinoInformacion', opp.ONE_Destinatario_s_de_la_informaci_n__c);
        system.debug('Destino información: ' + mapReqBody.get('destinoInformacion'));
        mapReqBody.put('observaciones', opp.ONE_Observaciones__c);
        system.debug('Observaciones: ' + mapReqBody.get('observaciones'));
        mapReqBody.put('URLReferencia', 'memora.com');
        system.debug('URL Ref: ' + mapReqBody.get('URLReferencia'));
        mapReqBody.put('consentimiento', 'S');
        system.debug('Consentimiento: ' + mapReqBody.get('consentimiento'));
        
        
        return JSON.serialize(mapReqBody);


    }


}
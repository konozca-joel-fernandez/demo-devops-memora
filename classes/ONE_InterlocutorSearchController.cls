public with sharing class ONE_InterlocutorSearchController {

@AuraEnabled
public static String fetchAccountsData(Object filtersObject) {

    Map<String, String> filtersMap = (Map<String, String>)JSON.deserialize(JSON.serialize(filtersObject), Map<String, String>.class);
    List<InterlocutorWrapper> intWrappers = new List<InterlocutorWrapper>();
    Set<String> fieldsToFetch = new Set<String> { 'Id', 'Name', 'ONE_Relacion_con_el_difunto__c', 'ONE_Rol__c', 'ONE_Cuenta_perteneciente__c' };

    String dynamicQuery = ONE_CommonUtils.buildDynamicQuery(ONE_CommonConstants.INTERLOCUTOR, fieldsToFetch);
    dynamicQuery += ' WHERE';

    if(filtersMap.containsKey('nombre') && filtersMap.get('nombre') != null && filtersMap.get('nombre') != '') {
        dynamicQuery += ' Name LIKE \'' + String.Format('%{0}%', new List<String> { filtersMap.get('nombre') })  + '\'';
    }

    if(filtersMap.containsKey('rol') && filtersMap.get('rol') != null  && filtersMap.get('rol') != '') {
        dynamicQuery += ' AND ONE_Rol__c LIKE \'' + String.Format('%{0}%', new List<String> { filtersMap.get('rol') })  + '\'';
    }

    if(filtersMap.containsKey('cuenta') && filtersMap.get('cuenta') != null && filtersMap.get('cuenta') != '') {
        dynamicQuery += ' AND ONE_Cuenta_perteneciente__c LIKE \'' + String.Format('%{0}%', new List<String> { filtersMap.get('cuenta') })  + '\'';
    }

    for(ONE_Interlocutor__c interlocutor : Database.query(dynamicQuery)) {
        intWrappers.add(
            new InterlocutorWrapper(
                interlocutor.Id,
                interlocutor.Name,
                interlocutor.ONE_Relacion_con_el_difunto__c,
                interlocutor.ONE_Rol__c,
                interlocutor.ONE_Cuenta_perteneciente__c
            )
        );
    }

    return JSON.serialize(intWrappers);
}

public class InterlocutorWrapper {
    public String interlocutorId { get; private set; }
    public String interlocutorName { get; private set; }
    public String relacionDifunto { get; private set; }
    public String interlocutorRol { get; private set; }
    public String cuentaPerteneciente { get; private set; }

    public InterlocutorWrapper(String interlocutorId, String interlocutorName, String relacionDifunto, String interlocutorRol, String cuentaPerteneciente) {
            this.interlocutorId = interlocutorId;
            this.interlocutorName = interlocutorName;
            this.relacionDifunto = relacionDifunto;
            this.interlocutorRol = interlocutorRol;
            this.cuentaPerteneciente = cuentaPerteneciente;
        }
    }
}
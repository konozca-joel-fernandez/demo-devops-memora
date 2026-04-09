/**
 * Created by mbujak003 on 24.11.2020.
 */
//Helper class for the sala's object
public with sharing class ONE_SalasHelper {
	//Time interval definition for the roon management component
    public enum TimeInterval {
        INTERVAL_24H,
        INTERVAL_48H,
        INTERVAL_3D,
        INTERVAL_7D
    }

	//Fetch all available reservation based on the selected time interval
    public static List<ONE_Reservas__c> fetchReservas(List<ONE_Recursos_Internos__c> recursos, Datetime startDate, TimeInterval interval) {

        if (startDate == null) {
            startDate = Datetime.newInstance(Date.today(), Time.newInstance(0,0,0,0));
        }
        Datetime endDate;
        //Set size of the component according to the interval
        if(interval == TimeInterval.INTERVAL_24H) {
            endDate = startDate.addDays(1);
        } else if (interval == TimeInterval.INTERVAL_48H) {
            endDate = startDate.addDays(2);
        } else if (interval == TimeInterval.INTERVAL_3D){
            endDate = startDate.addDays(3);
        } else {
            endDate = startDate.addDays(7);
        }

        //Query reservation based on time interval and recursos (center)
        return [
            SELECT Id, ONE_Fecha_Fin__c, Name, ONE_Fecha_Inicio__c,ONE_Tiempo_De_Mantenimiento_Manual__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c,
                ONE_Sala__c, ONE_Sala__r.Name, ONE_Nombre_De_Sala__c, ONE_Categoria_De_Sala__c, ONE_Tipo_De_Sala__c, ONE_Sala__r.ONE_Centro__c,
                ONE_Sala__r.ONE_Orden__c, ONE_Expediente_Formula__c, ONE_Expediente__r.ONE_Difunto__r.Name, ONE_Expediente__r.Name
            FROM ONE_Reservas__c
            WHERE ONE_Sala__c IN: recursos
                AND (
                    (ONE_Fecha_Inicio__c >=: startDate AND ONE_Fecha_Inicio__c <= :endDate)
                    OR (ONE_Fecha_Fin__c >= :startDate AND ONE_Fecha_Fin__c <=: endDate)
                    OR (ONE_Fecha_Inicio__c <= :startDate AND ONE_Fecha_Fin__c >=: endDate)
                )
                AND ONE_Cuenta_Sitio_De_La_Reserva__r.ONE_Centro_Memora_Codigo_SAP__c NOT IN :getCentersToHide()
            ORDER BY ONE_Sala__r.ONE_Orden__c ASC
        ];
    }
	
    public static List<ONE_Reservas__c> fetchReservas(Datetime startDate, TimeInterval interval) {

        if (startDate == null) {
            startDate = Datetime.newInstance(Date.today(), Time.newInstance(0,0,0,0));
        }
        Datetime endDate;
        //Set size of the component according to the interval
        if(interval == TimeInterval.INTERVAL_24H) {
            endDate = startDate.addDays(1);
        } else if (interval == TimeInterval.INTERVAL_48H) {
            endDate = startDate.addDays(2);
        } else if (interval == TimeInterval.INTERVAL_3D){
            endDate = startDate.addDays(4);
        } else {
            endDate = startDate.addDays(7);
        }

        //Query reservation based on time interval 
        return [
            SELECT Id, ONE_Fecha_Fin__c,Name, ONE_Fecha_Inicio__c,ONE_Tiempo_De_Mantenimiento_Manual__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c,
                ONE_Sala__c, ONE_Sala__r.Name, ONE_Nombre_De_Sala__c, ONE_Categoria_De_Sala__c, ONE_Tipo_De_Sala__c, ONE_Sala__r.ONE_Centro__c,
                ONE_Sala__r.ONE_Orden__c, ONE_Expediente_Formula__c, ONE_Expediente__r.ONE_Difunto__r.Name, ONE_Expediente__r.Name
            FROM ONE_Reservas__c
            WHERE ONE_Fecha_Inicio__c >=: startDate
                AND ONE_Fecha_Fin__c <=: endDate
                AND ONE_Cuenta_Sitio_De_La_Reserva__r.ONE_Centro_Memora_Codigo_SAP__c NOT IN :getCentersToHide()
            ORDER BY ONE_Sala__r.ONE_Orden__c ASC
        ];
    }

	//Utility method query all reservation in the selected recurso (sala)
    public static List<ONE_Reservas__c> fetchReservas(List<ONE_Recursos_Internos__c> recursos) {
        
        return [
            SELECT Id, ONE_Fecha_Fin__c,Name, ONE_Fecha_Inicio__c,ONE_Tiempo_De_Mantenimiento_Manual__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c,
                ONE_Sala__c, ONE_Sala__r.Name, ONE_Nombre_De_Sala__c, ONE_Categoria_De_Sala__c, ONE_Tipo_De_Sala__c, ONE_Sala__r.ONE_Centro__c,
                ONE_Sala__r.ONE_Orden__c, ONE_Expediente_Formula__c, ONE_Expediente__r.ONE_Difunto__r.Name, ONE_Expediente__r.Name
            FROM ONE_Reservas__c
            WHERE ONE_Sala__c IN: recursos
                AND ONE_Cuenta_Sitio_De_La_Reserva__r.ONE_Centro_Memora_Codigo_SAP__c NOT IN :getCentersToHide()
            ORDER BY ONE_Sala__r.ONE_Orden__c ASC
        ];
    }

	//Utility method query all reservation
    public static List<ONE_Reservas__c> fetchReservas() {

        return [
            SELECT Id, ONE_Fecha_Fin__c,Name, ONE_Fecha_Inicio__c,ONE_Tiempo_De_Mantenimiento_Manual__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__c,
                ONE_Sala__c, ONE_Sala__r.Name, ONE_Nombre_De_Sala__c, ONE_Categoria_De_Sala__c, ONE_Tipo_De_Sala__c, ONE_Sala__r.ONE_Centro__c,
                ONE_Sala__r.ONE_Orden__c, ONE_Expediente_Formula__c, ONE_Expediente__r.ONE_Difunto__r.Name, ONE_Expediente__r.Name
            FROM ONE_Reservas__c
            WHERE ONE_Cuenta_Sitio_De_La_Reserva__r.ONE_Centro_Memora_Codigo_SAP__c NOT IN :getCentersToHide()
            ORDER BY ONE_Sala__r.ONE_Orden__c ASC
        ];
    }

    public static List<String> getCentersToHide() {

        List<String> centersToHide = new List<String>();
        Map<Id, String> roleMap = new Map<Id, String>();
        for (UserRole role : [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN ('ONE_Serfutosa', 'ONE_Landarri', 'ONE_Zentolen')]) {
            roleMap.put(role.Id, role.DeveloperName);
        }
        Boolean hasLandarriZentolenPermission = FeatureManagement.checkPermission('Gestionar_reservas_en_Landarri_y_Zentolen');
		system.debug('roleMap == '+roleMap);
        system.debug('UserInfo.getUserRoleId() == '+UserInfo.getUserRoleId());
        String userRoleDeveloperName = roleMap.get(UserInfo.getUserRoleId());
        system.debug('userRoleDeveloperName == '+userRoleDeveloperName);
        if (userRoleDeveloperName != 'ONE_Serfutosa' && userRoleDeveloperName != 'ONE_Admin') {
            centersToHide.add('1257'); // Serfutosa center
        }
        if (userRoleDeveloperName != 'ONE_Landarri' && userRoleDeveloperName != 'ONE_Zentolen' && !hasLandarriZentolenPermission  && userRoleDeveloperName != 'ONE_Admin') {
            centersToHide.add('1694'); // Landarri center
            centersToHide.add('1695'); // Zentolen center
        }

        return centersToHide;
    }
}
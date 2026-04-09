/**
 * Created by mbujak003 on 04.12.2020.
 */

public with sharing class ONE_EjecutarTareasController {

    @AuraEnabled
    public static String ejacutarTareas(String recordId) {
        List<ONE_Tarea__c> tareasToInsert = new List<ONE_Tarea__c>();

        String expedientCentro;
        String expedientLugar;

        Map<String, String> productId2ProductType = new Map<String, String>();
        Map<String, String> lugarId2LugarSuperior = new Map<String, String>();
        Map<String, ONE_Producto__c> productId2Product = new Map<String, ONE_Producto__c>();
        Map<String, ONE_Expediente_Line_Item__c> productId2ExpedientLine = new Map<String, ONE_Expediente_Line_Item__c>();
        for(ONE_Lugar__c lugar : [
            SELECT Id, ONE_Lugar_Superior__c
            FROM ONE_Lugar__c
        ]) {
            lugarId2LugarSuperior.put(lugar.Id, lugar.ONE_Lugar_Superior__c);
        }

        for(ONE_Expediente_Line_Item__c eli : [
            SELECT Id, ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c, ONE_Expediente__r.ONE_Centro__c,
                ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__c, ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__c,
                ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c,
                (
                    SELECT Id FROM Tareas__r
                )
            FROM ONE_Expediente_Line_Item__c
            WHERE ONE_Expediente__c =: recordId
                AND ONE_Estado__c =: ONE_CommonConstants.ESTADO_CONFIRMADO
        ]) {
            if(eli.Tareas__r.isEmpty()) {
                expedientCentro = eli.ONE_Expediente__r.ONE_Centro__c;
                expedientLugar = eli.ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__c;
                productId2ProductType.put(eli.ONE_Producto__c, eli.ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c);
                productId2Product.put(eli.ONE_Producto__c, eli.ONE_Producto__r);
                productId2ExpedientLine.put(eli.ONE_Producto__c, eli);
            }
        }

        Set<String> lugarHierarchy = buildLugarHierarchy(expedientLugar);

        map<String, List<ONE_Proveedor_De_Producto__c>> productId2Provider = new Map<String, List<ONE_Proveedor_De_Producto__c>>();

        for(ONE_Proveedor_De_Producto__c provider : [
            SELECT Id, ONE_Producto__c, ONE_Compania__c, ONE_Proveedor__c
            FROM ONE_Proveedor_De_Producto__c
            WHERE ONE_Producto__c IN :productId2Product.keySet()
                AND (ONE_Centro__c =: expedientCentro
                    OR ONE_Lugar__c IN: lugarId2LugarSuperior.keySet())
                AND ONE_Activo__c = true
        ]) {
            if(!productId2Provider.containsKey(provider.ONE_Producto__c)) {
                    productId2Provider.put(provider.ONE_Producto__c, new List<ONE_Proveedor_De_Producto__c> { provider });
            } else {
                productId2Provider.get(provider.ONE_Producto__c).add(provider);
            }
        }

        for(ONE_Relacion_De_Productos__c rdp : [
            SELECT Id, ONE_Tipo_De_Relacion__c, ONE_Producto_Incluido__c, ONE_Producto_Comercial_Padre__c,
                ONE_Producto_Incluido__r.ONE_Tipologia_De_Producto_Lookup__c,
                ONE_Producto_Incluido__r.ONE_Tipo_De_Producto__c
            FROM ONE_Relacion_De_Productos__c
            WHERE ONE_Producto_Comercial_Padre__c IN: productId2ProductType.keySet()
                AND ONE_Producto_Comercial_Padre__r.ONE_Tipo_De_Producto__c =: ONE_CommonConstants.PRODUCTO_PACK
        ]) {
            productId2ProductType.put(rdp.ONE_Producto_Incluido__c, rdp.ONE_Producto_Incluido__r.ONE_Tipologia_De_Producto_Lookup__c);
            productId2Product.put(rdp.ONE_Producto_Incluido__c, rdp.ONE_Producto_Incluido__r);
            productId2ProductType.remove(rdp.ONE_Producto_Comercial_Padre__c);
            productId2Product.remove(rdp.ONE_Producto_Comercial_Padre__c);
            productId2ExpedientLine.put(rdp.ONE_Producto_Incluido__c, productId2ExpedientLine.get(rdp.ONE_Producto_Comercial_Padre__c));
        }

        Map<String, ONE_Configuracion_De_Tarea__c> productType2Config = new Map<String, ONE_Configuracion_De_Tarea__c>();
        Map<String, ONE_Configuracion_De_Tarea__c> productId2Config = new Map<String, ONE_Configuracion_De_Tarea__c>();

        for(ONE_Configuracion_De_Tarea__c config : [
            SELECT Id, ONE_Tipo_De_Recurso__c, ONE_Tipo_De_Tarea__c, OwnerId, ONE_Tipologia_De_Producto_Lookup__c,
                ONE_Requiere_Planificacion__c, ONE_Producto__c
            FROM ONE_Configuracion_De_Tarea__c
            WHERE ONE_Tipologia_De_Producto_Lookup__c IN: productId2ProductType.values()
            AND (
                    ONE_Centro__c =: expedientCentro
                    OR ONE_Lugar__c IN: lugarId2LugarSuperior.keySet()
                )
        ]) {
            productType2Config.put(config.ONE_Tipologia_De_Producto_Lookup__c, config);
            if(config.ONE_Producto__c != null) {
                productId2Config.put(config.ONE_Producto__c, config);
            }
        }

        Map<String, String> rtApiName2Label = new Map<String, String>();

        for(RecordType rt : [SELECT Id, DeveloperName, Name FROM RecordType WHERE SobjectType =: ONE_CommonConstants.TAREA]) {
            rtApiName2Label.put(rt.DeveloperName, rt.Name);
        }

        for(String pId : productId2ProductType.keySet()) {

            ONE_Configuracion_De_Tarea__c config;
            if(productId2Config.containsKey(pId)) {
                config = productId2Config.get(pId);
            } else if(productType2Config.containsKey(productId2Product.get(pId).ONE_Tipologia_De_Producto_Lookup__c)) {
                config = productType2Config.get(productId2Product.get(pId).ONE_Tipologia_De_Producto_Lookup__c);
            }

            if(config != null) {
                ONE_Tarea__c task = new ONE_Tarea__c(
                    ONE_Expediente__c = recordId,
                    ONE_Producto__c = pId,
                    ONE_Linea_De_Expediente__c = productId2ExpedientLine.get(pId).Id,
                    ONE_Configuracion_De_Tarea__c = config.Id,
                    Name = rtApiName2Label.get(config.ONE_Tipo_De_Tarea__c),
                    RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                        ONE_CommonConstants.TAREA,
                        config.ONE_Tipo_De_Tarea__c)
                );
                if(productId2Provider.containsKey(pId)) {
                    if(productId2Provider.get(pId) != null && productId2Provider.get(pId).size() > 1 ) {
                        for(ONE_Proveedor_De_Producto__c provider : productId2Provider.get(pId)) {
                            if(provider.ONE_Compania__c != null) {
                                task.ONE_Proveedor__c = provider.ONE_Compania__c;
                                break;
                            }
                        }
                    } else {
                        task.ONE_Proveedor__c = productId2Provider.get(pId)[0].ONE_Proveedor__c;
                    }
                }

                if(config.ONE_Tipo_De_Recurso__c == ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR) {
                    if(task.ONE_Proveedor__c == null) {
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ASIGNAR;
                    } else {
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ACCEPTAR;
                    }
                } else {
                    if(config.ONE_Requiere_Planificacion__c) {
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ASIGNAR;
                    } else {
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ACCEPTAR;
                    }
                }
                tareasToInsert.add(task);
            }
        }
        Database.insert(tareasToInsert, false);

        List<TareaWrapper> tareasToReturn = new List<TareaWrapper>();

        for(ONE_Tarea__c tarea : [
            SELECT Id, ONE_Expediente__c, ONE_Expediente__r.Name, ONE_Producto__c, ONE_Producto__r.Name,
                ONE_Linea_De_Expediente__c, ONE_Linea_De_Expediente__r.Name,
                ONE_Configuracion_De_Tarea__c, ONE_Configuracion_De_Tarea__r.Name, RecordType.Name
            FROM ONE_Tarea__c
            WHERE Id IN: tareasToInsert
        ]) {
            TareaWrapper tw = new TareaWrapper();
            tw.tareaId = tarea.Id;
            tw.expedienteName = tarea.ONE_Expediente__r.Name;
            tw.expedienteId = tarea.ONE_Expediente__c;
            tw.productName = tarea.ONE_Producto__r.Name;
            tw.productId = tarea.ONE_Producto__c;
            tw.expedientLineName = tarea.ONE_Linea_De_Expediente__r.Name;
            tw.expedientLineId = tarea.ONE_Linea_De_Expediente__c;
            tw.configuracionName = tarea.ONE_Configuracion_De_Tarea__r.Name;
            tw.configuracionId = tarea.ONE_Configuracion_De_Tarea__c;
            tw.recordTypeName = tarea.RecordType.Name;
            tareasToReturn.add(tw);
        }
        return JSON.serialize(tareasToReturn);
    }

    private static Set<String> buildLugarHierarchy(String rootLugar) {
        Map<String, String> lugarId2LugarSuperior = new Map<String, String>();
        Set<String> lugarHierarchy = new Set<String>();
        for(ONE_Lugar__c lugar : [
            SELECT Id, ONE_Lugar_Superior__c
            FROM ONE_Lugar__c
        ]) {
            lugarId2LugarSuperior.put(lugar.Id, lugar.ONE_Lugar_Superior__c);
        }

        String tempCurrentLugar = rootLugar;
        while(lugarId2LugarSuperior.get(tempCurrentLugar) != null) {
            lugarHierarchy.add(lugarId2LugarSuperior.get(tempCurrentLugar));
            tempCurrentLugar = lugarId2LugarSuperior.get(tempCurrentLugar);
        }
        return lugarHierarchy;
    }

    public class TareaWrapper {
        public String tareaId;
        public String expedienteName;
        public String expedienteId;
        public String productName;
        public String productId;
        public String expedientLineName;
        public String expedientLineId;
        public String configuracionName;
        public String configuracionId;
        public String recordTypeName;
        public TareaWrapper() {}
    }
}
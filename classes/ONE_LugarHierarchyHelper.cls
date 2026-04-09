/**
 * Created by mbujak003 on 19.04.2021.
 */

public with sharing class ONE_LugarHierarchyHelper {

    private static Map<String, LugarHierarchy> centroId2LugarHierarchy = new Map<String, LugarHierarchy>();

    public static LugarHierarchy getLugarHierarchy(Account centro) {
        System.debug(centro);
        System.debug(centro.Id);
        System.debug(centroId2LugarHierarchy);
        if (!centroId2LugarHierarchy.containsKey(centro.Id)) {
            centroId2LugarHierarchy.put(centro.Id, new LugarHierarchy(centro));
        }
        
        System.debug('centroId2LugarHierarchy~~'+centroId2LugarHierarchy);
        return centroId2LugarHierarchy.get(centro.Id);
    }

    public class LugarHierarchy {
        public Map<String, Hierarchical> recordId2Hierarchical { get; set; }

        public LugarHierarchy(Account centro) {
            buildHierarchy(centro);
            buildProviders();
            buildConfigs();
            System.debug('recordId2Hierarchical~~'+recordId2Hierarchical);
            System.debug('recordId2Hierarchical.keySet()~~'+recordId2Hierarchical.keySet());
            
        }

        private void buildHierarchy(Account centro) {
            recordId2Hierarchical = new Map<String, Hierarchical>{
                centro.Id => new Centro(centro)
            };
            for (ONE_Lugar__c lugar : [
                SELECT Id, Name, ONE_Lugar_Superior__c, ONE_Lugar_Superior__r.Name, ONE_Lugar_Superior__r.Id,
                    ONE_Lugar_Superior__r.ONE_Lugar_Superior__c
                FROM ONE_Lugar__c
                //añadida este where
                WHERE Id = :centro.Id OR Id = :centro.ONE_Lugar__c OR Id = :centro.ONE_Lugar__r.ONE_Lugar_Superior__c OR Id = :centro.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c OR Id = :centro.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c
                ORDER BY ONE_Lugar_Superior__c DESC
            ]) {
                recordId2Hierarchical.put(lugar.Id, new Lugar(lugar));
            }

            for (String recId : recordId2Hierarchical.keySet()) {
                if (recordId2Hierarchical.get(recId) instanceof Centro) {
                    Centro ct = (Centro) recordId2Hierarchical.get(recId);
                    Account sobj = ct.sObjectCentro;
                    recordId2Hierarchical.get(recId).lugarSuperior = (Lugar) recordId2Hierarchical.get(sobj.ONE_Lugar__c);
                } else if (recordId2Hierarchical.get(recId) instanceof Lugar) {
                    Lugar lg = (Lugar) recordId2Hierarchical.get(recId);
                    ONE_Lugar__c sobj = lg.sObjectLugar;
                    if (sobj.ONE_Lugar_Superior__c != null && recordId2Hierarchical.containsKey(sobj.ONE_Lugar_Superior__c)) {
                        recordId2Hierarchical.get(recId).lugarSuperior = (Lugar) recordId2Hierarchical.get(sobj.ONE_Lugar_Superior__c);
                        ((Lugar) recordId2Hierarchical.get(sobj.ONE_Lugar_Superior__c)).lugaresInferior.add((Lugar) recordId2Hierarchical.get(recId));
                    }
                }
            }
        }

        private void buildProviders() {
            for (ONE_Proveedor_De_Producto__c provider : [
                SELECT Id,Name, ONE_Producto__c, ONE_Compania__c, ONE_Proveedor__c, ONE_Activo__c, ONE_Lugar__c, ONE_Centro__c, ONE_Precio_De_Compra__c,
                    ONE_Proveedor__r.ONE_Metodo_De_Contacto_De_Proveedor__c
                FROM ONE_Proveedor_De_Producto__c
                WHERE (ONE_Lugar__c IN:recordId2Hierarchical.keySet()
                OR ONE_Centro__c IN:recordId2Hierarchical.keySet())
                AND ONE_Activo__c = true
                ORDER BY ONE_Centro__c DESC
            ]) {
                if (recordId2Hierarchical.containsKey(provider.ONE_Lugar__c)) {
                    if (!recordId2Hierarchical.get(provider.ONE_Lugar__c).productId2Provider.containsKey(provider.ONE_Producto__c)) {
                        recordId2Hierarchical.get(provider.ONE_Lugar__c).productId2Provider.put(provider.ONE_Producto__c, new List<ONE_Proveedor_De_Producto__c>{
                            provider
                        });
                    } else {
                        recordId2Hierarchical.get(provider.ONE_Lugar__c).productId2Provider.get(provider.ONE_Producto__c).add(provider);
                    }
                }
                if (recordId2Hierarchical.containsKey(provider.ONE_Centro__c)) {
                    if (!recordId2Hierarchical.get(provider.ONE_Centro__c).productId2Provider.containsKey(provider.ONE_Producto__c)) {
                        recordId2Hierarchical.get(provider.ONE_Centro__c).productId2Provider.put(provider.ONE_Producto__c, new List<ONE_Proveedor_De_Producto__c>{
                            provider
                        });
                    } else {
                        recordId2Hierarchical.get(provider.ONE_Centro__c).productId2Provider.get(provider.ONE_Producto__c).add(provider);
                        System.debug('Entro con el proveedor de producto:'+provider);
                    }
                }
            }
        }

        private void buildConfigs() {
            for (ONE_Configuracion_De_Tarea__c config : [
                SELECT Id, ONE_Tipo_De_Recurso__c, ONE_Tipo_De_Tarea__c, OwnerId, ONE_Tipologia_De_Producto_Lookup__c,ONE_Tipo_Gestoria__c,
                    ONE_Requiere_Planificacion__c, ONE_Producto__c, ONE_Lugar__c, ONE_Centro__c,ONE_Nombre_De_Tarea_Generica_Subtarea__c,
                    ONE_Autoasignar_tareas__c
                FROM ONE_Configuracion_De_Tarea__c
                WHERE (ONE_Lugar__c IN:recordId2Hierarchical.keySet()
                OR ONE_Centro__c IN:recordId2Hierarchical.keySet())
                ORDER BY ONE_Centro__c DESC
            ]) {

                if (recordId2Hierarchical.containsKey(config.ONE_Centro__c)) {

                    if (!recordId2Hierarchical.get(config.ONE_Centro__c).productType2Configs.containsKey(config.ONE_Tipologia_De_Producto_Lookup__c)) {
                        recordId2Hierarchical.get(config.ONE_Centro__c).productType2Configs.put(config.ONE_Tipologia_De_Producto_Lookup__c, new List<ONE_Configuracion_De_Tarea__c>{
                            config
                        });

                    } else {
                        recordId2Hierarchical.get(config.ONE_Centro__c).productType2Configs.get(config.ONE_Tipologia_De_Producto_Lookup__c).add(config);
                    }
                    if (config.ONE_Producto__c != null) {
                        if (!recordId2Hierarchical.get(config.ONE_Centro__c).productId2Configs.containsKey(config.ONE_Producto__c)) {
                            recordId2Hierarchical.get(config.ONE_Centro__c).productId2Configs.put(config.ONE_Producto__c, new List<ONE_Configuracion_De_Tarea__c>{
                                config
                            });

                        } else {
                            recordId2Hierarchical.get(config.ONE_Centro__c).productId2Configs.get(config.ONE_Producto__c).add(config);
                        }
                    }
                }

                if (recordId2Hierarchical.containsKey(config.ONE_Lugar__c)) {

                    if (!recordId2Hierarchical.get(config.ONE_Lugar__c).productType2Configs.containsKey(config.ONE_Tipologia_De_Producto_Lookup__c)) {
                        recordId2Hierarchical.get(config.ONE_Lugar__c).productType2Configs.put(config.ONE_Tipologia_De_Producto_Lookup__c, new List<ONE_Configuracion_De_Tarea__c>{
                            config
                        });
                    } else {
                        recordId2Hierarchical.get(config.ONE_Lugar__c).productType2Configs.get(config.ONE_Tipologia_De_Producto_Lookup__c).add(config);
                    }

                    if (config.ONE_Producto__c != null) {
                        if (!recordId2Hierarchical.get(config.ONE_Lugar__c).productId2Configs.containsKey(config.ONE_Producto__c)) {
                            recordId2Hierarchical.get(config.ONE_Lugar__c).productId2Configs.put(config.ONE_Producto__c, new List<ONE_Configuracion_De_Tarea__c>{
                                config
                            });
                        } else {
                            recordId2Hierarchical.get(config.ONE_Lugar__c).productId2Configs.get(config.ONE_Producto__c).add(config);
                        }
                    }
                }

                /*if (config.Id == 'a0K5r000001enBNEAY') {
                    System.debug(recordId2Hierarchical.get(config.ONE_Lugar__c).productType2Configs);
                }*/
            }
        }
    }

    public abstract class Hierarchical {
        public Map<String, List<ONE_Proveedor_De_Producto__c>> productId2Provider { get; set; }
        public Map<String, List<ONE_Configuracion_De_Tarea__c>> productType2Configs { get; set; }
        public Map<String, List<ONE_Configuracion_De_Tarea__c>> productId2Configs { get; set; }
        public Lugar lugarSuperior { get; set; }

        public Hierarchical() {
            productId2Provider = new Map<String, List<ONE_Proveedor_De_Producto__c>>();
            productType2Configs = new Map<String, List<ONE_Configuracion_De_Tarea__c>>();
            productId2Configs = new Map<String, List<ONE_Configuracion_De_Tarea__c>>();
        }
    }

    public class Centro extends Hierarchical {
        public Account sObjectCentro { get; set; }

        public Centro(Account centro) {
            super();
            sObjectCentro = centro;
        }
    }

    public class Lugar extends Hierarchical {
        public List<Lugar> lugaresInferior { get; set; }
        public ONE_Lugar__c sObjectLugar { get; set; }

        public Lugar(ONE_Lugar__c lugar) {
            super();
            sObjectLugar = lugar;
            lugaresInferior = new List<Lugar>();
        }
    }

    public class LugarHierarchyException extends Exception {
    }
}
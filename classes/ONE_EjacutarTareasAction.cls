/**
 * Created by mbujak003 on 12.04.2021.
 */

public with sharing class ONE_EjacutarTareasAction {

    private static List<FlowOutputs> s_flowOutputs = new List<FlowOutputs>();
    @InvocableMethod
    public static List<FlowOutputs> invoke(List<FlowInputs> flowInputs) {

        FlowOutputs fo = new FlowOutputs();

        ONE_Expediente_Line_Item__c eli = [
            SELECT Id, ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c, ONE_Producto__c, ONE_Expediente__r.ONE_Servicio__c,
                ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__c,
            	ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Compania__c, ONE_Expediente__r.ONE_Centro__c,
                ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c, ONE_Expediente__r.ONE_Centro__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c,
                ONE_Expediente__r.ONE_Compania__c, ONE_Presupuesto__c, ONE_Presupuesto__r.ONE_Tipo_De_Contrato__c, ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c, (
                SELECT Id
                FROM Tareas__r
            )
            FROM ONE_Expediente_Line_Item__c
            WHERE Id = :flowInputs[0].expedienteLineItemId
            LIMIT 1
        ];

        System.debug('eli ~~ ' + eli);
        Map<String, ONE_LugarHierarchyHelper.Hierarchical> lugarId2LugarWraper =
            ONE_LugarHierarchyHelper.getLugarHierarchy(eli.ONE_Expediente__r.ONE_Centro_Del_Expediente__r).recordId2Hierarchical;

        System.debug('lugarId2LugarWraper ~~ ' + lugarId2LugarWraper);

        Map<String, String> rtApiName2Label = new Map<String, String>();

        for (RecordType rt : [SELECT Id, DeveloperName, Name FROM RecordType WHERE SobjectType = :ONE_CommonConstants.TAREA]) {
            rtApiName2Label.put(rt.DeveloperName, rt.Name);
        }

        List<ONE_Tarea__c> tasksToInsert = new List<ONE_Tarea__c>();
        try {
            List<ONE_Configuracion_De_Tarea__c> prodConf;
            List<ONE_Configuracion_De_Tarea__c> typeConf;

            List<ONE_Configuracion_De_Tarea__c> cfgs;

            String hierarchicalId = eli.ONE_Expediente__r.ONE_Centro_Del_Expediente__c;
            System.debug('hierarchicalId ~~ ' + hierarchicalId);

            while (hierarchicalId != null) {
                ONE_LugarHierarchyHelper.Hierarchical hierarchical = lugarId2LugarWraper.get(hierarchicalId);
                System.debug('eli.ONE_Producto__c ~~ ' + eli.ONE_Producto__c);
                System.debug('productId2Configs ~~ ' + hierarchical.productId2Configs);
                System.debug('contains ~~ ' + hierarchical.productId2Configs.containsKey(eli.ONE_Producto__c));
                System.debug('prodConf ~~ ' + prodConf);

                if (prodConf == null && hierarchical.productId2Configs.containsKey(eli.ONE_Producto__c)) {
                    System.debug('prodConf ~~ ' + prodConf);
                    prodConf = hierarchical.productId2Configs.get(eli.ONE_Producto__c);
                }
                if (typeConf == null && hierarchical.productType2Configs.containsKey(eli.ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c)) {
                    System.debug('typeConf ~~ ' + typeConf);
                    typeConf = hierarchical.productType2Configs.get(eli.ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__c);
                }

                if (hierarchicalId != hierarchical?.lugarSuperior?.sObjectLugar?.Id) {
                    hierarchicalId = hierarchical?.lugarSuperior?.sObjectLugar?.Id;
                } else {
                    break;
                }
            }

            cfgs = prodConf == null ? typeConf : prodConf;

			String nameTarea;

            // Status code to indicate the path of the code
            String statusCode = '0';
            Integer count = 0;
            
            for (ONE_Configuracion_De_Tarea__c conf : cfgs) {
                if(conf.ONE_Tipo_De_Tarea__c=='ONE_Tarea_gestoria_Asistea'){
                    nameTarea=conf.ONE_Nombre_De_Tarea_Generica_Subtarea__c;
                }else{
                    nameTarea=rtApiName2Label.get(conf.ONE_Tipo_De_Tarea__c);
                }
                ONE_Tarea__c task = new ONE_Tarea__c(
                    ONE_Expediente__c = eli.ONE_Expediente__c,
                    ONE_Producto__c = eli.ONE_Producto__c,
                    ONE_Linea_De_Expediente__c = eli.Id,
                    ONE_Configuracion_De_Tarea__c = conf.Id,
                    Name = nameTarea,
                    RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                        ONE_CommonConstants.TAREA,
                        conf.ONE_Tipo_De_Tarea__c)
                );
                System.debug('task ~~ ' + task);

                if (conf.ONE_Tipo_De_Recurso__c == ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR) {
                    hierarchicalId = eli.ONE_Expediente__r.ONE_Centro_Del_Expediente__c;

                    while (hierarchicalId != null) {
                        
                        
                        ONE_LugarHierarchyHelper.Hierarchical hierarchical = lugarId2LugarWraper.get(hierarchicalId);
                        if (hierarchical.productId2Provider.containsKey(eli.ONE_Producto__c)) {
                            System.debug('1hierarchicalId ~~ ' + hierarchical.productId2Provider.get(eli.ONE_Producto__c));
                            ++count;
                            
                            if (hierarchical.productId2Provider.get(eli.ONE_Producto__c).size() == 1 ) {

                                statusCode = '1';
                                Boolean performParticular=false;
                                if(eli.ONE_Expediente__r.ONE_Compania__c !=null && eli.ONE_Presupuesto__r.ONE_Tipo_De_Contrato__c == ONE_CommonConstants.TIPO_DE_CONTRATO_SERVICIO){
                                    
                                    statusCode = '11';
                                    if(hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Compania__c==eli.ONE_Expediente__r.ONE_Compania__c){
                                        task.ONE_Proveedor__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c;
                                        task.ONE_Precio_De_Compra__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Precio_De_Compra__c;
                                        System.debug('1task misma compania~~ ' + hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c);
                                        //1 PROVEEDOR HOJA DE SERVICIO MISMA COMPAÑIA
                                        statusCode = '111';
                                		break;
                                    }else if(hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Compania__c==null){
                                        task.ONE_Proveedor__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c;
                                        task.ONE_Precio_De_Compra__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Precio_De_Compra__c;
                                        //1 PROVEEDOR HOJA DE SERVICIO COMPAÑIA DEL PROVEEDOR DE PRODUCTO VACIA
                                        statusCode = '112';
                                        System.debug('1task  compania vacia~~' + hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c);
                                        break;
                                    }else{
                                        //1 PROVEEDOR HOJA DE SERVICIO DISTINCA COMPAÑIA
                                        statusCode = '113';
                                       System.debug('1task distinta compania~~ no hacer nada ' + task); 
                                    }
                                        
                                }
                                if(eli.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c == ONE_CommonConstants.TIPO_DE_PRESUPUESTO_WEB){
                                    
                                    statusCode = '12';
                                    if (hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__r.ONE_Metodo_De_Contacto_De_Proveedor__c == 'Aplicacion') {
                                         	System.debug('1task  web~~' + hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c);
                                            task.ONE_Proveedor__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c;
                                            task.ONE_Precio_De_Compra__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Precio_De_Compra__c;
                                            
                                            statusCode = '121';
                                            break;
                                     }else{
                                         performParticular=true; 
                                     }
                                    
                                }
                                if(eli.ONE_Presupuesto__r.ONE_Tipo_De_Contrato__c == ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR || performParticular){
                                    
                                    statusCode = '13';
                                    if(hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Compania__c==null){
                                        System.debug('1task  particular~~' + hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c);
                                        task.ONE_Proveedor__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Proveedor__c;
                                        task.ONE_Precio_De_Compra__c = hierarchical.productId2Provider.get(eli.ONE_Producto__c)[0].ONE_Precio_De_Compra__c;
                                        
                                        statusCode = '131';
                                        break;
                                        
                                    }
                                    
                                    statusCode = '130';
                                }
                                
                                    
                                
                            } else if (hierarchical.productId2Provider.get(eli.ONE_Producto__c).size() == 0) {
                                continue;
                            } else if (hierarchical.productId2Provider.get(eli.ONE_Producto__c).size() > 1) {
                                
                                statusCode = '2';
                                System.debug('~~ ' + eli.ONE_Presupuesto__r.ONE_Tipo_De_Contrato__c );
                                Boolean performParticular = false;
                                if (eli.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c == ONE_CommonConstants.TIPO_DE_PRESUPUESTO_WEB) {
                                    
                                    statusCode = '22';
                                    for (ONE_Proveedor_De_Producto__c provider : hierarchical.productId2Provider.get(eli.ONE_Producto__c)) {
                                        if (provider.ONE_Proveedor__r.ONE_Metodo_De_Contacto_De_Proveedor__c == 'Aplicacion') {
                                            task.ONE_Proveedor__c = provider.ONE_Proveedor__c;
                                            task.ONE_Precio_De_Compra__c = provider.ONE_Precio_De_Compra__c;
                                            
                                            statusCode = '221';
                                            break;
                                        }else{
                                            performParticular=true;
                                        }
                                    }
                                }
                                if (eli.ONE_Presupuesto__r.ONE_Tipo_De_Contrato__c == ONE_CommonConstants.TIPO_DE_CONTRATO_PARTICULAR || performParticular) {
                                    
                                    statusCode = '23';
                                    ONE_Proveedor_De_Producto__c tmpProvider = null;
                                    for (ONE_Proveedor_De_Producto__c provider : hierarchical.productId2Provider.get(eli.ONE_Producto__c)) {
                                        if (provider.ONE_Compania__c == null) {
                                            if (tmpProvider == null) {
                                                tmpProvider = provider;
                                            } else {
                                                tmpProvider = null;
                                                
                                                statusCode = '230';
                                                break;
                                            }
                                        }
                                    }
                                    if (tmpProvider != null) {
                                        task.ONE_Proveedor__c = tmpProvider.ONE_Proveedor__c;
                                        task.ONE_Precio_De_Compra__c = tmpProvider.ONE_Precio_De_Compra__c;
                                        
                                        statusCode = '231';
                                        break;
                                    } else {
                                         if(eli.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c != ONE_CommonConstants.TIPO_DE_PRESUPUESTO_WEB){
                                            
                                            statusCode = '232';
                                            //break; 
                                        }
                                    }
                                } else if (eli.ONE_Presupuesto__r.ONE_Tipo_De_Contrato__c == ONE_CommonConstants.TIPO_DE_CONTRATO_SERVICIO) {
                                    
                                    statusCode = '21';
                                    System.debug('2task ~~ ' + task);
                                    ONE_Proveedor_De_Producto__c tmpProvider = null;
                                    Integer contador=0;
                                    for (ONE_Proveedor_De_Producto__c provider : hierarchical.productId2Provider.get(eli.ONE_Producto__c)) {
                                        System.debug('2task providers'+provider);
                                        if (provider.ONE_Compania__c != null && provider.ONE_Compania__c == eli.ONE_Expediente__r.ONE_Compania__c) {
                                            tmpProvider = provider;
                                            contador++;
                                        }
                                    }
                                    if(contador ==1){
                                         task.ONE_Proveedor__c = tmpProvider.ONE_Proveedor__c;
                                         task.ONE_Precio_De_Compra__c = tmpProvider.ONE_Precio_De_Compra__c;
                                         
                                         statusCode = '211';
                                         break;
                                    }else if(contador>1){
                                        
                                        statusCode = '212';
                                        break;
                                    }else{
                                        tmpProvider=null;
                                    }

                                    if (tmpProvider == null) {
                                        System.debug('1');
                                        ONE_Proveedor_De_Producto__c tmpProvider2 = null;
                                        for (ONE_Proveedor_De_Producto__c provider : hierarchical.productId2Provider.get(eli.ONE_Producto__c)) {
                                            if (provider!=null && provider.ONE_Compania__c == null) {
                                                System.debug('2');
                                                if (tmpProvider2 == null) {
                                                    tmpProvider2 = provider;
                                                } else {
                                                    System.debug('3');
                                                    tmpProvider2 = null;
                                                    
                                                    statusCode = '210';
                                                    break;
                                                }
                                            }
                                        }
                                        if (tmpProvider2 != null) {
                                            task.ONE_Proveedor__c = tmpProvider2.ONE_Proveedor__c;
                                            task.ONE_Precio_De_Compra__c = tmpProvider2.ONE_Precio_De_Compra__c;

                                            statusCode = '213';
                                            break;
                                        } else {
                                            System.debug('CONTINUE');
                                                                                     
                                        }
                                    } else {
                                        
                                        statusCode = '214';
                                        break;
                                    }
                                }
                                else {
                                    statusCode = '24';
                                    if(eli.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c != ONE_CommonConstants.TIPO_DE_PRESUPUESTO_WEB){
                                        statusCode = '241';
                                       break; 
                                    }
                                    
                                }
                            }
                        }
                        System.debug('hierarchical?.lugarSuperior?'+hierarchical?.lugarSuperior?.sObjectLugar?.Id);
                        if (hierarchicalId != hierarchical?.lugarSuperior?.sObjectLugar?.Id) {
                            hierarchicalId = hierarchical?.lugarSuperior?.sObjectLugar?.Id;
                        } else {
                            break;
                        }
                    }

                }
                if (conf.ONE_Tipo_De_Recurso__c == ONE_CommonConstants.TIPO_DE_RECURSO_PROVEDOOR) {
                    if (task.ONE_Proveedor__c == null) {
                        task.Status_Proveedor_Automatico__c = statusCode + ' - NA - ' + String.valueOf(count);
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ASIGNAR;
                    } else {
                        task.Status_Proveedor_Automatico__c = statusCode + ' - A - ' + String.valueOf(count);
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ACCEPTAR;
                    }
                } else {
                    if (conf.ONE_Requiere_Planificacion__c) {
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ASIGNAR;
                    }else if(conf.ONE_Tipo_De_Tarea__c=='ONE_Tarea_gestoria_Asistea'){
                        if(conf.ONE_Tipo_Gestoria__c=='Tarea de Gestoria 1'){
                            task.ONE_Tipo_Gestoria__c=conf.ONE_Tipo_Gestoria__c;
                            task.ONE_Estado_Gestoria__c ='Pendiente';
                        }else{
                            task.ONE_Tipo_Gestoria__c=conf.ONE_Tipo_Gestoria__c;
                            task.ONE_Estado_Gestoria__c ='Abierto';
                        }
                            
                        
                    } else {
                        task.ONE_Estado__c = ONE_CommonConstants.ESTADO_PENDIENTE_ACCEPTAR;
                    }
                }
                task.ONE_Numero_Pedido__c = flowInputs[0].numPedido;
				task.ONE_Correo_Confirmacion__c = flowInputs[0].correoConfirmacion;

                String execUserId = String.isBlank(flowInputs[0].executingUserId)
                    ? UserInfo.getUserId()
                    : flowInputs[0].executingUserId;

                if (conf.ONE_Autoasignar_tareas__c) {
                    task.OwnerId = execUserId;
                }

                 System.debug('Final task ~~ ' + task);
                
                tasksToInsert.add(task);
            }
			
            insert tasksToInsert;
        } catch (Exception ex) {
            fo.status = false;
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            System.debug(ex.getCause());
            System.debug(ex.getStackTraceString());
            return new List<FlowOutputs>{
                fo
            };
        }

        // Return ids
        List<String> taskIds = new List<String>();
        for (ONE_Tarea__c task : tasksToInsert) {
            taskIds.add(task.Id);
        }

        fo.status = true;
        fo.tareaIds = taskIds;
        s_flowOutputs.add(fo);
        return s_flowOutputs;
    }


    public class FlowInputs {
        @InvocableVariable
        public String expedienteLineItemId;
        
        @InvocableVariable
        public String executingUserId;

        public String numPedido;
        
        public String correoConfirmacion;
    }

    public class FlowOutputs {
        @InvocableVariable
        public Boolean status;
        @InvocableVariable
        public List<String> tareaIds;
    }
}
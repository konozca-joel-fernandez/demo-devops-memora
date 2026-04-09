public without sharing class ONE_CasoHelper {

    public static void createLineasPlanificacion(List<ONE_Caso__c> newRecords) {

        List<ONE_LineaPlanificacion__c> lineasPlanificacionToInsert = new List<ONE_LineaPlanificacion__c>();

        String avisoDefuncionRecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion');
        String avisoJudicialRecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Recogida_Judicial');

        for (ONE_Caso__c caso : newRecords) {
            if ( (caso.RecordTypeId == avisoDefuncionRecordTypeId || caso.RecordTypeId == avisoJudicialRecordTypeId) && caso.ONE_Expediente__c == null) {
                ONE_LineaPlanificacion__c lineaPlanificacion = new ONE_LineaPlanificacion__c(ONE_Caso__c = caso.Id);
                lineasPlanificacionToInsert.add(lineaPlanificacion);
            }
        }

        insert lineasPlanificacionToInsert;
    }

    public static void updateLineasPlanificacion(Map<Id, ONE_Caso__c> oldMap, Map<Id, ONE_Caso__c> newMap) {

        Boolean fieldsChanged = false;

        for (Id casoId : newMap.keySet()) {
            if (    newMap.get(casoId).OwnerId != oldMap.get(casoId).OwnerId ||
                    newMap.get(casoId).ONE_Expediente__c != oldMap.get(casoId).ONE_Expediente__c ||
                    newMap.get(casoId).ONE_Difunto__c != oldMap.get(casoId).ONE_Difunto__c ||
                    newMap.get(casoId).ONE_Tipo_De_Difunto__c != oldMap.get(casoId).ONE_Tipo_De_Difunto__c ||
                    newMap.get(casoId).ONE_Centro_Del_Servicio__c != oldMap.get(casoId).ONE_Centro_Del_Servicio__c ||
                    newMap.get(casoId).ONE_Lugar_De_Defuncion02__c != oldMap.get(casoId).ONE_Lugar_De_Defuncion02__c||
                	newMap.get(casoId).ONE_Zona_Operativa_Centro__c != oldMap.get(casoId).ONE_Zona_Operativa_Centro__c
            ) {
                fieldsChanged = true;
                break;
            }
        }

        if (fieldsChanged) {

            Map<Id, ONE_Caso__c> newMapWithRelatedFields = new Map<Id, ONE_Caso__c>();
            List<ONE_LineaPlanificacion__c> lineasPlanificacionToUpdate = new List<ONE_LineaPlanificacion__c>();
            Boolean updateLineaPlanificacionRequired;
            Map<Id, ONE_Expediente__c> casoServicioMap = new Map<Id, ONE_Expediente__c>();

            for (ONE_Expediente__c servicio : [ SELECT
                                                    OwnerId,
                                                    ONE_Caso__c,
                                                    ONE_Centro_Del_Expediente__c
                                                FROM ONE_Expediente__c
                                                WHERE
                                                    ONE_Caso__c IN :newMap.keySet() AND
                                                    (ONE_Caso__r.RecordType.DeveloperName = 'ONE_Avisos_De_Defuncion' OR
                                                    ONE_Caso__r.RecordType.DeveloperName = 'ONE_Recogida_Judicial')])
            {
                casoServicioMap.put(servicio.ONE_Caso__c, servicio);
            }

            for (ONE_Caso__c caso : [ SELECT
                                                    ONE_Difunto__r.Name,
                                                    toLabel(ONE_Tipo_De_Difunto__c) tipoDifuntoLabel
                                                FROM ONE_Caso__c
                                                WHERE Id IN :newMap.keySet()])
            {
                newMapWithRelatedFields.put(caso.Id, caso);
            }

            for (ONE_LineaPlanificacion__c lineaPlanificacion : [   SELECT
                                                                        OwnerId,
                                                                        ONE_Caso__c,
                                                                        ONE_Servicio__c,
                                                                        ONE_Difunto__c,
                                                                        ONE_TipoDifunto__c,
                                                                        ONE_NombreTipoDifunto__c,
                                                                        ONE_CentroTrabajo__c,
                                                                        ONE_LugarDefuncion__c,
                                                                 		ONE_Zona_Operativa_Centro__c
                                                                    FROM ONE_LineaPlanificacion__c
                                                                    WHERE
                                                                        ONE_Caso__c IN :newMap.keySet() AND
                                                                        (ONE_Caso__r.RecordType.DeveloperName = 'ONE_Avisos_De_Defuncion' OR
                                                                        ONE_Caso__r.RecordType.DeveloperName = 'ONE_Recogida_Judicial')])
            {
                updateLineaPlanificacionRequired = false;

                if (lineaPlanificacion.ONE_Servicio__c != newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Expediente__c) {
                    lineaPlanificacion.ONE_Servicio__c = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Expediente__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (lineaPlanificacion.ONE_Zona_Operativa_Centro__c != newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Zona_Operativa_Centro__c) {
                    lineaPlanificacion.ONE_Zona_Operativa_Centro__c = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Zona_Operativa_Centro__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_Servicio__c == null) {

                    if (casoServicioMap?.get(lineaPlanificacion.ONE_Caso__c)?.OwnerId != null) {
                        if (lineaPlanificacion.OwnerId != casoServicioMap?.get(lineaPlanificacion.ONE_Caso__c)?.OwnerId) {
                            lineaPlanificacion.OwnerId = casoServicioMap?.get(lineaPlanificacion.ONE_Caso__c)?.OwnerId;
                            updateLineaPlanificacionRequired = true;
                        }
                    }
                    else {
                        if (lineaPlanificacion.OwnerId != newMap.get(lineaPlanificacion.ONE_Caso__c).OwnerId) {
                            lineaPlanificacion.OwnerId = newMap.get(lineaPlanificacion.ONE_Caso__c).OwnerId;
                            updateLineaPlanificacionRequired = true;
                        }
                    }
    
                    if (lineaPlanificacion.ONE_Servicio__c != newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Expediente__c) {
                        lineaPlanificacion.ONE_Servicio__c = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Expediente__c;
                        updateLineaPlanificacionRequired = true;
                    }
    
                    if (lineaPlanificacion.ONE_Difunto__c != newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Difunto__c) {
                        lineaPlanificacion.ONE_Difunto__c = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Difunto__c;
                        String difuntoName = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Difunto__c != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Caso__c).ONE_Difunto__r.Name : '';
                        String tipoDifuntoLabel = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Caso__c)?.get('tipoDifuntoLabel') != null ? (String) newMapWithRelatedFields.get(lineaPlanificacion.ONE_Caso__c).get('tipoDifuntoLabel') : '';
                        lineaPlanificacion.ONE_NombreTipoDifuntoLibre__c = tipoDifuntoLabel == 'Cadáver adulto' ? difuntoName : tipoDifuntoLabel + ' - ' + difuntoName;
                        updateLineaPlanificacionRequired = true;
                    }
    /*
                    if (lineaPlanificacion.ONE_TipoDifunto__c != newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Tipo_De_Difunto__c) {
                        lineaPlanificacion.ONE_TipoDifunto__c = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Tipo_De_Difunto__c;
                        String difuntoName = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Difunto__c != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Caso__c).ONE_Difunto__r.Name : '';
                        String tipoDifuntoLabel = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Caso__c)?.get('tipoDifuntoLabel') != null ? (String) newMapWithRelatedFields.get(lineaPlanificacion.ONE_Caso__c).get('tipoDifuntoLabel') : '';
                        lineaPlanificacion.ONE_NombreTipoDifuntoLibre__c = tipoDifuntoLabel == 'Cadáver adulto' ? difuntoName : tipoDifuntoLabel + ' - ' + difuntoName;
                        updateLineaPlanificacionRequired = true;
                    }
    */
                    if (casoServicioMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Centro_Del_Expediente__c != null) {
                        if (lineaPlanificacion.ONE_CentroTrabajo__c != casoServicioMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Centro_Del_Expediente__c) {
                            lineaPlanificacion.ONE_CentroTrabajo__c = casoServicioMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Centro_Del_Expediente__c;
                            updateLineaPlanificacionRequired = true;
                        }
                    }
                    else {
                        if (lineaPlanificacion.ONE_CentroTrabajo__c != newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Centro_del_Servicio__c) {
                            lineaPlanificacion.ONE_CentroTrabajo__c = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Centro_del_Servicio__c;
                            updateLineaPlanificacionRequired = true;
                        }
                    }
    
                    if (lineaPlanificacion.ONE_LugarDefuncion__c != newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Lugar_De_Defuncion02__c) {
                        lineaPlanificacion.ONE_LugarDefuncion__c = newMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Lugar_De_Defuncion02__c;
                        updateLineaPlanificacionRequired = true;
                    }
                }

                if (updateLineaPlanificacionRequired) {
                    lineasPlanificacionToUpdate.add(lineaPlanificacion);
                }
            }

            update lineasPlanificacionToUpdate;
        }
    }
    
    public static void checkFieldsOcaso(List<ONE_Caso__c> newRecords){
        Boolean requiredFieldsFilledOut=true;
         for (ONE_Caso__c caso : newRecords) {
             if(caso.ONE_Sistema_externo_Origen__c=='Ocaso'){
                  if(caso.ONE_Emisor_Del_Aviso__c==null ||
                      caso.ONE_Record_Type__c==null ||
                      caso.ONE_Tipo__c==null ||
                      caso.ONE_Tipo_De_Difunto__c==null ||
                      caso.ONE_Causas_Defuncion__c==null ||
                      caso.ONE_Tipo_De_Servicio__c==null ||
                      caso.ONE_Certificado__c==null ||
                      caso.ONE_Tipo_de_Lugar__c==null ||
                      caso.ONE_Nombre_Difunto__c==null ||
                      caso.ONE_Apellidos_Difunto__c==null ||
                      caso.ONE_Tipo_Documento_Difunto__c==null ||
                      caso.ONE_N_Documento_Difunto__c==null ||
                      caso.ONE_Fecha_De_Defuncion__c==null ||
                      caso.ONE_Nombre_Avisador__c==null ||
                      caso.ONE_Apellidos_Avisador__c==null ||
                      caso.ONE_Telefono_Avisador__c==null ||
                      caso.ONE_Relacion_Con_El_Difunto__c==null ||
                      caso.ONE_Numero_De_Siniestro_Texto__c==null ||
                      caso.ONE_Numero_De_Poliza_texto__c==null ||
                      caso.ONE_Capital_Real__c==null ||
                      caso.ONE_Sistema_Externo_Origen__c==null){
                        requiredFieldsFilledOut=false;
                                         
                      }
                     if((caso.ONE_Tipo_de_Lugar__c=='Hospital' || caso.ONE_Tipo_de_Lugar__c=='Residencia') && caso.ONE_Lugar_De_Defuncion__c ==null){
                         requiredFieldsFilledOut=false;
                        
                         
                     }else if(caso.ONE_Tipo_de_Lugar__c !='Hospital' && caso.ONE_Tipo_de_Lugar__c!='Residencia' && (caso.ONE_Direccion_De_Defuncion__c  ==null ||
                              caso.ONE_Provincia_De_Defuncion__c  ==null ||caso.ONE_Municipio__c  ==null ||caso.ONE_Pais_De_Defuncion__c  ==null)){
                         requiredFieldsFilledOut=false;
                        
                     }
                     
                     if(!caso.ONE_Persona_De_Contacto_Avisador__c && (caso.ONE_Nombre_De_La_Persona_De_Contacto__c==null ||caso.ONE_Telefono_De_La_Persona_De_Contacto__c==null)){
                         requiredFieldsFilledOut=false;
                       
                     }
                     
                     if(!requiredFieldsFilledOut){
                        caso.addError('Error al insertar el caso: Faltan campos obligatorios por completar.');
                    }
             }     

         }  
    }
}
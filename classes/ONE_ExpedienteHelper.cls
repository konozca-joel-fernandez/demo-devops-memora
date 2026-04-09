public without sharing class ONE_ExpedienteHelper {

    public static void createLineasPlanificacion(List<ONE_Expediente__c> newRecords) {

        List<ONE_LineaPlanificacion__c> lineasPlanificacionToInsert = new List<ONE_LineaPlanificacion__c>();

        Set<Id> casoIdSet = new Set<Id>();
        for (ONE_Expediente__c servicio : newRecords) {
            if (servicio.ONE_Caso__c != null) {
                casoIdSet.add(servicio.ONE_Caso__c);
            }
        }

        Map<Id, ONE_Caso__c> casoMap = new Map<Id, ONE_Caso__c>();
        for (ONE_Caso__c caso : [   SELECT
                                        RecordType.DeveloperName
                                    FROM ONE_Caso__c WHERE Id IN :casoIdSet])
        {
            casoMap.put(caso.Id, caso);
        }

        for (ONE_Expediente__c servicio : newRecords) {

            ONE_LineaPlanificacion__c lineaPlanificacion;
            if (servicio.ONE_Caso__c == null || (servicio.ONE_Caso__c != null && (casoMap.get(servicio.ONE_Caso__c)?.RecordType.DeveloperName != 'ONE_Avisos_De_Defuncion' &&
                                                                                casoMap.get(servicio.ONE_Caso__c)?.RecordType.DeveloperName != 'ONE_Recogida_Judicial') ) ) {
                lineaPlanificacion = new ONE_LineaPlanificacion__c(
                    ONE_Servicio__c = servicio.Id,
                    ONE_Lugar_inhumaci_n__c = servicio.ONE_Destino_Final__c,
                    ONE_Municipio_Exhumaci_n__c = servicio.ONE_Municipio_Exhumaci_n__c,
                    ONE_Localizaci_n_Unidad_Exhumaci_n__c = servicio.ONE_Localizaci_n_Unidad_Exhumaci_n__c,
                    ONE_Observaciones_Exhumacion__c = servicio.ONE_Observaciones_Exhumacion__c,
                    ONE_Lugar_Exhumacion__c = servicio.ONE_Lugar_Exhumacion__c,
                    ONE_Unidad_de_Exhumacion__c = servicio.ONE_Unidad_de_Exhumacion__c,
                    Inicio_exhumaci_n__c = servicio.ONE_Inicio_Exhumaci_n__c,
                    ONE_Fin_Exhumaci_n__c = servicio.ONE_Fin_Exhumaci_n__c,
                    ONE_C_digo_postal_Exhumaci_n__c = servicio.ONE_C_digo_postal_Exhumaci_n__c,
                    ONE_Presente_en_Exhumaci_n__c = servicio.ONE_Presente_en_Exhumaci_n__c,
					ONE_Destrucci_n_de_la_L_pida__c = servicio.ONE_Destrucci_n_de_la_L_pida__c,
                    ONE_Restos_de__c = servicio.ONE_Restos_de__c,
					ONE_Finalidad_Exhumaci_n__c = servicio.ONE_Finalidad_Exhumaci_n__c,
                    ONE_Destino_Ornamentaci_n__c = servicio.ONE_Destino_Ornamentaci_n__c,
                    ONE_Tipo_de_ritual_libre__c = servicio.ONE_Tipo_De_Ritual_Ceremonia__c
                    
                );
          
                lineasPlanificacionToInsert.add(lineaPlanificacion);
            }
        }

        insert lineasPlanificacionToInsert;
    }

    public static void updateLineasPlanificacion(Map<Id, ONE_Expediente__c> oldMap, Map<Id, ONE_Expediente__c> newMap) {

        Boolean fieldsChanged = false;

        for (Id servicioId : newMap.keySet()) {
            if (    newMap.get(servicioId).OwnerId != oldMap.get(servicioId).OwnerId ||
                    newMap.get(servicioId).ONE_Centro_Del_Expediente__c != oldMap.get(servicioId).ONE_Centro_Del_Expediente__c ||
                    newMap.get(servicioId).ONE_Difunto__c != oldMap.get(servicioId).ONE_Difunto__c ||
                    newMap.get(servicioId).ONE_Tipo_de_Difunto__c != oldMap.get(servicioId).ONE_Tipo_de_Difunto__c ||
                    newMap.get(servicioId).ONE_Fin_Ceremonia__c != oldMap.get(servicioId).ONE_Fin_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Lugar_Ceremonia__c != oldMap.get(servicioId).ONE_Lugar_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Sala_Ceremonia__c != oldMap.get(servicioId).ONE_Sala_Ceremonia__c ||
                    newMap.get(servicioId).ONE_PersonalCeremonia__c != oldMap.get(servicioId).ONE_PersonalCeremonia__c ||
                    newMap.get(servicioId).ONE_Funeraria_Origen_Destino_Recepcion__c != oldMap.get(servicioId).ONE_Funeraria_Origen_Destino_Recepcion__c ||
                    newMap.get(servicioId).Numero_sala_Ceremonia_Ext__c != oldMap.get(servicioId).Numero_sala_Ceremonia_Ext__c ||
                    newMap.get(servicioId).ONE_Municipio_Ceremonia__c != oldMap.get(servicioId).ONE_Municipio_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Direccion_Ceremonia__c != oldMap.get(servicioId).ONE_Direccion_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Tipo_De_Lugar_De_Ceremonia__c != oldMap.get(servicioId).ONE_Tipo_De_Lugar_De_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Confirmada_Ceremonia_Externa__c != oldMap.get(servicioId).ONE_Confirmada_Ceremonia_Externa__c ||
                    newMap.get(servicioId).ONE_Ceremonia_Inhumacion_Confirmada__c != oldMap.get(servicioId).ONE_Ceremonia_Inhumacion_Confirmada__c ||
                    newMap.get(servicioId).ONE_Observaciones_Generales__c != oldMap.get(servicioId).ONE_Observaciones_Generales__c ||
                    newMap.get(servicioId).ONE_Velacion__c != oldMap.get(servicioId).ONE_Velacion__c ||
                    newMap.get(servicioId).ONE_Lugar_De_Velacion__c != oldMap.get(servicioId).ONE_Lugar_De_Velacion__c ||
                    newMap.get(servicioId).ONE_Inicio_Velacion__c != oldMap.get(servicioId).ONE_Inicio_Velacion__c ||
                    newMap.get(servicioId).ONE_Sala_De_Velacion__c != oldMap.get(servicioId).ONE_Sala_De_Velacion__c ||
                    newMap.get(servicioId).Numero_Sala_Velacion_Ext__c != oldMap.get(servicioId).Numero_Sala_Velacion_Ext__c ||
                    newMap.get(servicioId).ONE_Deposito__c != oldMap.get(servicioId).ONE_Deposito__c ||
                    newMap.get(servicioId).ONE_Lugar_De_Deposito__c != oldMap.get(servicioId).ONE_Lugar_De_Deposito__c ||
                    newMap.get(servicioId).ONE_Inicio_Deposito__c != oldMap.get(servicioId).ONE_Inicio_Deposito__c ||
                    newMap.get(servicioId).ONE_Fin_Deposito__c != oldMap.get(servicioId).ONE_Fin_Deposito__c ||
                    newMap.get(servicioId).ONE_Sala_Deposito__c != oldMap.get(servicioId).ONE_Sala_Deposito__c ||
                    newMap.get(servicioId).ONE_Licencia_Despachada__c != oldMap.get(servicioId).ONE_Licencia_Despachada__c ||
                    newMap.get(servicioId).ONE_Hora_Destino_Final__c != oldMap.get(servicioId).ONE_Hora_Destino_Final__c ||
                    newMap.get(servicioId).ONE_Inicio_Incineracion__c != oldMap.get(servicioId).ONE_Inicio_Incineracion__c ||
                    newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c != oldMap.get(servicioId).ONE_Fecha_Salida_Traslado__c ||
                    newMap.get(servicioId).ONE_Inicio_Ceremonia__c != oldMap.get(servicioId).ONE_Inicio_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Inicio_Despedida__c != oldMap.get(servicioId).ONE_Inicio_Despedida__c ||
                    newMap.get(servicioId).ONE_Lugar_Incineracion__c != oldMap.get(servicioId).ONE_Lugar_Incineracion__c ||
                    newMap.get(servicioId).ONE_Destino_Final__c != oldMap.get(servicioId).ONE_Destino_Final__c ||
                    newMap.get(servicioId).ONE_Destino_Traslado__c != oldMap.get(servicioId).ONE_Destino_Traslado__c ||
                    newMap.get(servicioId).ONE_Direccion_Velacion__c != oldMap.get(servicioId).ONE_Direccion_Velacion__c ||
                    newMap.get(servicioId).ONE_Tipo_De_Ritual_Ceremonia__c != oldMap.get(servicioId).ONE_Tipo_De_Ritual_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Codigo_Postal_Velacion__c != oldMap.get(servicioId).ONE_Codigo_Postal_Velacion__c ||
                    newMap.get(servicioId).ONE_Municipio_Velacion__c != oldMap.get(servicioId).ONE_Municipio_Velacion__c ||
                    newMap.get(servicioId).ONE_Modelo_De_Feretro__c != oldMap.get(servicioId).ONE_Modelo_De_Feretro__c ||
                    newMap.get(servicioId).ONE_Modelo_Urna__c != oldMap.get(servicioId).ONE_Modelo_Urna__c ||
                    newMap.get(servicioId).ONE_Destino_Final__c != oldMap.get(servicioId).ONE_Destino_Final__c ||
                 	newMap.get(servicioId).ONE_Lugar_Exhumacion__c != oldMap.get(servicioId).ONE_Lugar_Exhumacion__c ||
                    newMap.get(servicioId).ONE_Municipio_Exhumaci_n__c != oldMap.get(servicioId).ONE_Municipio_Exhumaci_n__c ||
                    newMap.get(servicioId).ONE_Localizaci_n_Unidad_Exhumaci_n__c != oldMap.get(servicioId).ONE_Localizaci_n_Unidad_Exhumaci_n__c ||
                    newMap.get(servicioId).ONE_Unidad_de_Exhumacion__c != oldMap.get(servicioId).ONE_Unidad_de_Exhumacion__c ||
                    newMap.get(servicioId).ONE_Inicio_Exhumaci_n__c != oldMap.get(servicioId).ONE_Inicio_Exhumaci_n__c ||
                	newMap.get(servicioId).ONE_Fin_Exhumaci_n__c != oldMap.get(servicioId).ONE_Fin_Exhumaci_n__c ||
                	newMap.get(servicioId).ONE_C_digo_postal_Exhumaci_n__c != oldMap.get(servicioId).ONE_C_digo_postal_Exhumaci_n__c ||
                	newMap.get(servicioId).ONE_Presente_en_Exhumaci_n__c != oldMap.get(servicioId).ONE_Presente_en_Exhumaci_n__c ||
                	newMap.get(servicioId).ONE_Destrucci_n_de_la_L_pida__c != oldMap.get(servicioId).ONE_Destrucci_n_de_la_L_pida__c ||
                	newMap.get(servicioId).ONE_Observaciones_Exhumacion__c != oldMap.get(servicioId).ONE_Observaciones_Exhumacion__c ||
                    newMap.get(servicioId).ONE_Restos_de__c != oldMap.get(servicioId).ONE_Restos_de__c ||
                    newMap.get(servicioId).ONE_Finalidad_Exhumaci_n__c != oldMap.get(servicioId).ONE_Finalidad_Exhumaci_n__c ||
                    newMap.get(servicioId).ONE_Destino_Ornamentaci_n__c != oldMap.get(servicioId).ONE_Destino_Ornamentaci_n__c 
                	
                	
                	
                	
                	
                	
            ) {
                fieldsChanged = true;
                break;
            }
        }

        if (fieldsChanged) {

            Map<Id, ONE_Expediente__c> newMapWithRelatedFields = new Map<Id, ONE_Expediente__c>();
            List<ONE_LineaPlanificacion__c> lineasPlanificacionToUpdate = new List<ONE_LineaPlanificacion__c>();
            List<ONE_LineaPlanificacion__c> lineasPlanificacionToUpdate2 = new List<ONE_LineaPlanificacion__c>();
            List<ONE_LineaPlanificacion__c> lineasPlanificacionToUpdate3 = new List<ONE_LineaPlanificacion__c>();
            List<ONE_LineaPlanificacion__c> lineasPlanificacionToUpdate4 = new List<ONE_LineaPlanificacion__c>();
            List<ONE_LineaPlanificacion__c> lineasPlanificacionToUpsert = new List<ONE_LineaPlanificacion__c>();
            Boolean updateLineaPlanificacionRequired, upsertLineaPlanificacionRequired;
            
            Map<Id, ONE_Expediente__c> serviciosMap =new Map<id, ONE_Expediente__c>([SELECT ONE_Difunto__r.Name,
                                                    toLabel(ONE_Tipo_De_Difunto__c) tipoDifuntoLabel,
                                                    ONE_Lugar_De_Velacion__r.Name,
                                                    ONE_Lugar_De_Deposito__r.Name,
                                                    ONE_Lugar_De_Deposito__r.ONE_Direccion__c,
                                                    ONE_Lugar_De_Deposito__r.ONE_Codigo_Postal__c,
                                                    ONE_Lugar_De_Deposito__r.ONE_Municipio_Direccion__c,
                                                    ONE_Sala_De_Velacion__r.ONE_Numero_De_Sala__c,
                                                    ONE_Sala_Deposito__r.Name,
                                                    ONE_Lugar_Ceremonia__r.Name,
                                                    ONE_Sala_Ceremonia__r.Name,
                                                    ONE_Lugar_Incineracion__r.Name,
                                                    ONE_Destino_Final__r.Name,
                                                    ONE_Destino_Traslado__r.Name,
                                                    ONE_Destino_Traslado__r.ONE_Municipio_Direccion__c,
                                                    toLabel(ONE_Destino_Traslado__r.ONE_Provincia__c),
                                                    ONE_Horno_Incineracion__r.Name,
                                                    ONE_Funeraria_Origen_Destino_Recepcion__r.Name,
                                                    ONE_Modelo_De_Feretro__r.Name,
                                                    ONE_Modelo_Urna__r.Name,
                                                    ONE_Destino_Final__c,
                                                    ONE_Lugar_Exhumacion__c,
                                                   	ONE_Municipio_Exhumaci_n__c, 
                                                    ONE_Localizaci_n_Unidad_Exhumaci_n__c, 
                                                    ONE_Unidad_de_Exhumacion__c, 
                                                    ONE_Observaciones_Exhumacion__c,
                                                    ONE_Inicio_Exhumaci_n__c, 
                                                    ONE_Fin_Exhumaci_n__c, 
                                                    ONE_C_digo_postal_Exhumaci_n__c, 
                                                    ONE_Presente_en_Exhumaci_n__c, 
                                                    ONE_Destrucci_n_de_la_L_pida__c,
                                                    ONE_Restos_de__c,
                                                    ONE_Finalidad_Exhumaci_n__c,
                                                    ONE_Destino_Ornamentaci_n__c,
                                                    ONE_Centro_Del_Expediente__r.ONE_Creacion_automatica_LPs_futuras__c,
                                                    ONE_Tipo_de_ritual_ceremonia__c
                                                     
                                                    
                                                FROM ONE_Expediente__c
                                                WHERE Id IN :newMap.keySet()]);

            for (ONE_Expediente__c servicio : serviciosMap.values())
            {
                newMapWithRelatedFields.put(servicio.Id, servicio);
            }

            Map<Id, ONE_LineaPlanificacion__c> primeraLineaPlanificacionMap = new Map<Id, ONE_LineaPlanificacion__c>();
            
            Map<Id, ONE_LineaPlanificacion__c> planificacionesMap =new Map<id, ONE_LineaPlanificacion__c>([   SELECT
                                                                        OwnerId,
                                                                        ONE_CentroTrabajo__c,
                                                                        ONE_Difunto__c,
                                                                        ONE_TipoDifunto__c,
                                                                        ONE_ActualizadoPorPlanificador__c,
                                                                        ONE_CreadoManualmente__c,
                                                                        ONE_IdExterno__c,
                                                                        ONE_Servicio__c,
                                                                        ONE_InicioCeremonia__c,
                                                                        ONE_FinCeremonia__c,
                                                                        ONE_LugarCeremonia__c,
                                                                        ONE_CeremoniaConfirmada__c,
                                                                        ONE_CeremoniaInhumacionConfirmada__c,
                                                                        ONE_ObservacionesGenerales__c,
                                                                        ONE_LugarTanatorio__c,
                                                                        ONE_InicioTanatorio__c,
                                                                        ONE_FinTanatorio__c,
                                                                        ONE_Lugar_Deposito__c,
                                                                        ONE_Inicio_Deposito__c,
                                                                        ONE_Fin_Deposito__c,
                                                                        ONE_LicenciaEnterramiento__c,
                                                                        ONE_FechaHoraDestinoFinal__c,
                                                                        ONE_FechaHoraInhumacion__c,
                                                                        ONE_FechaHoraIncineracion__c,
                                                                        ONE_LugarDestinoFinal__c,
                                                                        ONE_OrigenLibre__c,
                                                                        ONE_DestinoIntermedioLibre__c,
                                                                        ONE_DestinoFinalLibre__c,
                                                                        ONE_SalaTanatorio__c,
                                                                        ONE_SalaVelacionExterna__c,
                                                                        ONE_FeretroUrnaLibre__c,
                                                                        ONE_ModeloFeretro__c,
                                                                        ONE_TipoUrna__c,
                                                                        ONE_FeretroUrna__c,
                                                                        ONE_FechaProgramada__c,
                                                                        ONE_Lugar_inhumaci_n__c,
                                                                        ONE_Lugar_Exhumacion__c,
                                                                        ONE_Municipio_Exhumaci_n__c, 
                                                                        ONE_Localizaci_n_Unidad_Exhumaci_n__c, 
                                                                        ONE_Unidad_de_Exhumacion__c, 
                                                                        ONE_Observaciones_Exhumacion__c,
                                                                        Inicio_exhumaci_n__c, 
                                                                        ONE_Fin_Exhumaci_n__c, 
                                                                        ONE_C_digo_postal_Exhumaci_n__c, 
                                                                        ONE_Presente_en_Exhumaci_n__c, 
                                                                        ONE_Destrucci_n_de_la_L_pida__c,
                                                                        ONE_Restos_de__c,
                                                                        ONE_Finalidad_Exhumaci_n__c,
                                                                        ONE_Destino_Ornamentaci_n__c,
                                                                        ONE_Funeraria_Origen_Destino__c,
                                                                        ONE_Tipo_de_ritual_libre__c,
                                                                        ONE_TipoRitual__c 

                                                                                                           
                                                                    FROM ONE_LineaPlanificacion__c
                                                                    WHERE ONE_Servicio__c IN :newMap.keySet()]);

            for (ONE_LineaPlanificacion__c lineaPlanificacion : planificacionesMap.values())
            {
                updateLineaPlanificacionRequired = false;

                if (!lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                    primeraLineaPlanificacionMap.put(lineaPlanificacion.ONE_Servicio__c, lineaPlanificacion);
                }

                if (lineaPlanificacion.OwnerId != newMap.get(lineaPlanificacion.ONE_Servicio__c).OwnerId) {
                    lineaPlanificacion.OwnerId = newMap.get(lineaPlanificacion.ONE_Servicio__c).OwnerId;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_CentroTrabajo__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Centro_Del_Expediente__c) {
                    lineaPlanificacion.ONE_CentroTrabajo__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Centro_Del_Expediente__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_Difunto__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__c) {
                    lineaPlanificacion.ONE_Difunto__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__c;
                    String difuntoName = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__c != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__r.Name : '';
                    String tipoDifuntoLabel = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.get('tipoDifuntoLabel') != null ? (String) newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).get('tipoDifuntoLabel') : '';
                    lineaPlanificacion.ONE_NombreTipoDifuntoLibre__c = tipoDifuntoLabel == 'Cadáver adulto' ? difuntoName : tipoDifuntoLabel + ' - ' + difuntoName;
                    updateLineaPlanificacionRequired = true;
                }
/*
                if (lineaPlanificacion.ONE_TipoDifunto__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Difunto__c) {
                    lineaPlanificacion.ONE_TipoDifunto__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Difunto__c;
                    String difuntoName = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__c != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__r.Name : '';
                    String tipoDifuntoLabel = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.get('tipoDifuntoLabel') != null ? (String) newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).get('tipoDifuntoLabel') : '';
                    lineaPlanificacion.ONE_NombreTipoDifuntoLibre__c = tipoDifuntoLabel == 'Cadáver adulto' ? difuntoName : tipoDifuntoLabel + ' - ' + difuntoName;
                    updateLineaPlanificacionRequired = true;
                }
*/
                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Difunto__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Difunto__c) {
                    lineaPlanificacion.ONE_TipoDifunto__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Difunto__c;
                    String difuntoName = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__c != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__r.Name : '';
                    String tipoDifuntoLabel = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.get('tipoDifuntoLabel') != null ? (String) newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).get('tipoDifuntoLabel') : '';
                    lineaPlanificacion.ONE_NombreTipoDifuntoLibre__c = tipoDifuntoLabel == 'Cadáver adulto' ? difuntoName : tipoDifuntoLabel + ' - ' + difuntoName;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_InicioCeremonia__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c) {
                    lineaPlanificacion.ONE_InicioCeremonia__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_FinCeremonia__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Ceremonia__c) {
                    lineaPlanificacion.ONE_FinCeremonia__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Ceremonia__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_LugarCeremonia__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c) {
                    lineaPlanificacion.ONE_LugarCeremonia__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Funeraria_Origen_Destino_Recepcion__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Funeraria_Origen_Destino_Recepcion__c) {
                    lineaPlanificacion.ONE_Funeraria_Origen_Destino__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Funeraria_Origen_Destino_Recepcion__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_PersonalCeremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_PersonalCeremonia__c) {
                    lineaPlanificacion.ONE_PersonalCeremonia__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_PersonalCeremonia__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_PersonalCeremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_PersonalCeremonia__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Sala_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Sala_Ceremonia__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).Numero_sala_Ceremonia_Ext__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).Numero_sala_Ceremonia_Ext__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Municipio_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Municipio_Ceremonia__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Direccion_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Direccion_Ceremonia__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Lugar_De_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Lugar_De_Ceremonia__c)
                {
                    
                    if (!lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                        lineaPlanificacion.ONE_DestinoIntermedioLibre__c = getDestinoIntermedioLibre(newMap.get(lineaPlanificacion.ONE_Servicio__c), newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c));
                        updateLineaPlanificacionRequired = true;
                    }
                }
                
                if(lineaPlanificacion.ONE_Tipo_de_ritual_libre__c != newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Ritual_Ceremonia__c)
                {
                    lineaPlanificacion.ONE_Tipo_de_ritual_libre__c = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Tipo_De_Ritual_Ceremonia__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_CeremoniaConfirmada__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Confirmada_Ceremonia_Externa__c) {
                    lineaPlanificacion.ONE_CeremoniaConfirmada__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Confirmada_Ceremonia_Externa__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_CeremoniaInhumacionConfirmada__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Ceremonia_Inhumacion_Confirmada__c) {
                    lineaPlanificacion.ONE_CeremoniaInhumacionConfirmada__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Ceremonia_Inhumacion_Confirmada__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (lineaPlanificacion.ONE_ObservacionesGenerales__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Observaciones_Generales__c) {
                    lineaPlanificacion.ONE_ObservacionesGenerales__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Observaciones_Generales__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Velacion__c) {
                    if (lineaPlanificacion.ONE_LugarTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Velacion__c) {
                        lineaPlanificacion.ONE_LugarTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Velacion__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_InicioTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Velacion__c) {
                        lineaPlanificacion.ONE_InicioTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Velacion__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_FinTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Velacion__c) {
                        lineaPlanificacion.ONE_FinTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Velacion__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_SalaTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Sala_De_Velacion__c) {
                        lineaPlanificacion.ONE_SalaTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Sala_De_Velacion__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_SalaVelacionExterna__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).Numero_Sala_Velacion_Ext__c) {
                        lineaPlanificacion.ONE_SalaVelacionExterna__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).Numero_Sala_Velacion_Ext__c;
                        updateLineaPlanificacionRequired = true;
                    }
                }
                else if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Deposito__c) {
                    if (lineaPlanificacion.ONE_LugarTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Deposito__c) {
                        lineaPlanificacion.ONE_LugarTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Deposito__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_InicioTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Deposito__c) {
                        lineaPlanificacion.ONE_InicioTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Deposito__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_FinTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Deposito__c) {
                        lineaPlanificacion.ONE_FinTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Deposito__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_SalaTanatorio__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Sala_Deposito__c) {
                        lineaPlanificacion.ONE_SalaTanatorio__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Sala_Deposito__c;
                        updateLineaPlanificacionRequired = true;
                    }
                }

                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Deposito__c) {
                    if (lineaPlanificacion.ONE_Lugar_Deposito__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Deposito__c) {
                        lineaPlanificacion.ONE_Lugar_Deposito__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Deposito__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_Inicio_Deposito__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Deposito__c) {
                        lineaPlanificacion.ONE_Inicio_Deposito__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Deposito__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_Fin_Deposito__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Deposito__c) {
                        lineaPlanificacion.ONE_Fin_Deposito__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Deposito__c;
                        updateLineaPlanificacionRequired = true;
                    }
                }

                if (lineaPlanificacion.ONE_LicenciaEnterramiento__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Licencia_Despachada__c) {
                    lineaPlanificacion.ONE_LicenciaEnterramiento__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Licencia_Despachada__c;
                    updateLineaPlanificacionRequired = true;
                }

                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_De_Feretro__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_De_Feretro__c ||
                newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_Urna__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_Urna__c)
                {
                    String modeloFeretro = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Modelo_De_Feretro__r?.Name == null ? '' : newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_De_Feretro__r.Name;
                    String modeloUrna = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Modelo_Urna__r?.Name == null ? '' : newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_Urna__r.Name;
                    lineaPlanificacion.ONE_FeretroUrnaLibre__c = modeloFeretro + ' - ' + modeloUrna;
                    updateLineaPlanificacionRequired = true;
                }
                
                
                if (lineaPlanificacion.ONE_Lugar_Exhumacion__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Exhumacion__c) {
                    lineaPlanificacion.ONE_Lugar_Exhumacion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Exhumacion__c;
                    updateLineaPlanificacionRequired = true;
                }
                
                 if (lineaPlanificacion.ONE_Observaciones_Exhumacion__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Observaciones_Exhumacion__c) {
                    lineaPlanificacion.ONE_Observaciones_Exhumacion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Observaciones_Exhumacion__c;
                    updateLineaPlanificacionRequired = true;
                }
                
                if (lineaPlanificacion.ONE_Municipio_Exhumaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Municipio_Exhumaci_n__c) {
                    lineaPlanificacion.ONE_Municipio_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Municipio_Exhumaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                
                if (lineaPlanificacion.Inicio_Exhumaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Exhumaci_n__c) {
                    lineaPlanificacion.Inicio_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Exhumaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (lineaPlanificacion.ONE_Fin_Exhumaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Exhumaci_n__c) {
                    lineaPlanificacion.ONE_Fin_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fin_Exhumaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (lineaPlanificacion.ONE_C_digo_postal_Exhumaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_C_digo_postal_Exhumaci_n__c) {
                    lineaPlanificacion.ONE_C_digo_postal_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_C_digo_postal_Exhumaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (lineaPlanificacion.ONE_Presente_en_Exhumaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Presente_en_Exhumaci_n__c) {
                    lineaPlanificacion.ONE_Presente_en_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Presente_en_Exhumaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (lineaPlanificacion.ONE_Destrucci_n_de_la_L_pida__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destrucci_n_de_la_L_pida__c) {
                    lineaPlanificacion.ONE_Destrucci_n_de_la_L_pida__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destrucci_n_de_la_L_pida__c;
                    updateLineaPlanificacionRequired = true;
                }
                
                if (lineaPlanificacion.ONE_Localizaci_n_Unidad_Exhumaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Localizaci_n_Unidad_Exhumaci_n__c) {
                    lineaPlanificacion.ONE_Localizaci_n_Unidad_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Localizaci_n_Unidad_Exhumaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                                
                if (lineaPlanificacion.ONE_Unidad_de_Exhumacion__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Unidad_de_Exhumacion__c) {
                    lineaPlanificacion.ONE_Unidad_de_Exhumacion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Unidad_de_Exhumacion__c;
                    updateLineaPlanificacionRequired = true;
                }

                
                if (lineaPlanificacion.ONE_Restos_de__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Restos_de__c) {
                    lineaPlanificacion.ONE_Restos_de__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Restos_de__c;
                    updateLineaPlanificacionRequired = true;
                }
                
                if (lineaPlanificacion.ONE_Finalidad_Exhumaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Finalidad_Exhumaci_n__c) {
                    lineaPlanificacion.ONE_Finalidad_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Finalidad_Exhumaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                
                if (lineaPlanificacion.ONE_Destino_Ornamentaci_n__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Ornamentaci_n__c) {
                    lineaPlanificacion.ONE_Destino_Ornamentaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Ornamentaci_n__c;
                    updateLineaPlanificacionRequired = true;
                }
                                                                   
                
                if (newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Despedida__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Despedida__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Final__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Final__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Incineracion__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Incineracion__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Traslado__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Traslado__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Funeraria_Origen_Destino_Recepcion__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Funeraria_Origen_Destino_Recepcion__c ||
                    newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Horno_Incineracion__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Horno_Incineracion__c)
                {
                    Datetime minimumDate = getMinimumDate(new List<DateTime>{newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c, newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c, newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c});
                    if (newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c == minimumDate) {
                        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c;
                        lineaPlanificacion.ONE_LugarDestinoFinal__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__c;

                        if ((newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__c != null || newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Horno_Incineracion__c != null) && !lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                            String hornoIncineracion = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Horno_Incineracion__r?.Name != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Horno_Incineracion__r.Name : '';
                            if(hornoIncineracion != '') lineaPlanificacion.ONE_DestinoFinalLibre__c = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__r.Name + ' - ' + hornoIncineracion;
                            else lineaPlanificacion.ONE_DestinoFinalLibre__c = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__r.Name;
                            //lineaPlanificacion.ONE_DestinoFinalLibre__c = hornoIncineracion;
                        }
                        updateLineaPlanificacionRequired = true;
                    }
                    else if (newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c == minimumDate) {
                        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c;
                        lineaPlanificacion.ONE_LugarDestinoFinal__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Final__c;

                        
                        if ((newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Final__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Final__c || newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c) && !lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                            String destinoFinal = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Final__r?.Name != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Final__r.Name : '';
                            lineaPlanificacion.ONE_DestinoFinalLibre__c = destinoFinal;
                        }
                        updateLineaPlanificacionRequired = true;
                    }
                    else if (newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fecha_Salida_Traslado__c == minimumDate) {
                        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fecha_Salida_Traslado__c;
                        lineaPlanificacion.ONE_LugarDestinoFinal__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__c;
                        lineaPlanificacion.ONE_Lugar_Exhumacion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Exhumacion__c;
                        lineaPlanificacion.ONE_Observaciones_Exhumacion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Observaciones_Exhumacion__c;
                        lineaPlanificacion.ONE_Municipio_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Municipio_Exhumaci_n__c;
                        lineaPlanificacion.ONE_Localizaci_n_Unidad_Exhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Localizaci_n_Unidad_Exhumaci_n__c;
                        lineaPlanificacion.ONE_Unidad_de_Exhumacion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Unidad_de_Exhumacion__c;
                        if ((newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Traslado__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Traslado__c  || newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c) && !lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                            String destinoTraslado = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__r?.Name != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Traslado__r.Name : '';
                            String funerariaDestinoTraslado = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Funeraria_Origen_Destino_Recepcion__r?.Name != null ? newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c).ONE_Funeraria_Origen_Destino_Recepcion__r.Name : '';
                            //lineaPlanificacion.ONE_DestinoFinalLibre__c = newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__r.Name + ' - ' + newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__r.ONE_Municipio_Direccion__c + ' (' + newMapWithRelatedFields.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__r.ONE_Provincia__c + ')';
                            lineaPlanificacion.ONE_DestinoFinalLibre__c = destinoTraslado + ' - ' + funerariaDestinoTraslado;
                        }
                        updateLineaPlanificacionRequired = true;
                    }

                    if (lineaPlanificacion.ONE_FechaHoraIncineracion__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c) {
                        lineaPlanificacion.ONE_FechaHoraIncineracion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c;
                        updateLineaPlanificacionRequired = true;
                    }

                    
                    
                    if (lineaPlanificacion.ONE_FechaHoraInhumacion__c != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c) {
                        lineaPlanificacion.ONE_FechaHoraInhumacion__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c;
                        updateLineaPlanificacionRequired = true;
                    }

                    if ((newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c ||
                        newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c ||
                        newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c ||
                        newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c ||
                        newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Despedida__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Despedida__c) &&
                        !lineaPlanificacion.ONE_CreadoManualmente__c)
                    {
                        if (!System.isFuture() && !System.isBatch()) {
                            System.debug('CALL updateFechaProgramada');
                            updateFechaProgramada(lineaPlanificacion.Id);
                        }
                    }
                }
                
                if (newMap.get(lineaPlanificacion.ONE_servicio__c).ONE_Destino_Final__c != oldMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Final__c){
                    lineaPlanificacion.ONE_Lugar_inhumaci_n__c = newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Destino_Final__c;
                    updateLineaPlanificacionRequired = true;
                }
                
                if (updateLineaPlanificacionRequired) {
                    lineasPlanificacionToUpdate.add(lineaPlanificacion);
                }
            }

            update lineasPlanificacionToUpdate;


            for (Id servicioId : newMap.keySet()) {
                if (newMap.get(servicioId).ONE_Hora_Destino_Final__c != oldMap.get(servicioId).ONE_Hora_Destino_Final__c ||
                    newMap.get(servicioId).ONE_Inicio_Incineracion__c != oldMap.get(servicioId).ONE_Inicio_Incineracion__c ||
                    newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c != oldMap.get(servicioId).ONE_Fecha_Salida_Traslado__c ||
                    newMap.get(servicioId).ONE_Inicio_Ceremonia__c != oldMap.get(servicioId).ONE_Inicio_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Inicio_Despedida__c != oldMap.get(servicioId).ONE_Inicio_Despedida__c ||
                    newMap.get(servicioId).ONE_Direccion_Velacion__c != oldMap.get(servicioId).ONE_Direccion_Velacion__c ||
                    newMap.get(servicioId).ONE_Destino_Final__c != oldMap.get(servicioId).ONE_Destino_Final__c ||
                    newMap.get(servicioId).ONE_Lugar_Incineracion__c != oldMap.get(servicioId).ONE_Lugar_Incineracion__c ||
                    newMap.get(servicioId).ONE_Destino_Traslado__c != oldMap.get(servicioId).ONE_Destino_Traslado__c ||
                    newMap.get(servicioId).ONE_Lugar_Ceremonia__c != oldMap.get(servicioId).ONE_Lugar_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Lugar_Despedida__c != oldMap.get(servicioId).ONE_Lugar_Despedida__c ||
                    newMap.get(servicioId).ONE_Codigo_Postal_Velacion__c != oldMap.get(servicioId).ONE_Codigo_Postal_Velacion__c ||
                    newMap.get(servicioId).ONE_Municipio_Velacion__c != oldMap.get(servicioId).ONE_Municipio_Velacion__c ||
                    newMap.get(servicioId).ONE_Lugar_De_Deposito__c != oldMap.get(servicioId).ONE_Lugar_De_Deposito__c ||
                    newMap.get(servicioId).ONE_Lugar_De_Velacion__c != oldMap.get(servicioId).ONE_Lugar_De_Velacion__c ||
                    newMap.get(servicioId).ONE_Sala_Deposito__c != oldMap.get(servicioId).ONE_Sala_Deposito__c ||
                    newMap.get(servicioId).ONE_Sala_De_Velacion__c != oldMap.get(servicioId).ONE_Sala_De_Velacion__c ||
                    newMap.get(servicioId).Numero_Sala_Velacion_Ext__c != oldMap.get(servicioId).Numero_Sala_Velacion_Ext__c)
                {
                    List<Datetime> dateList = new List<DateTime>();
                    
                    Datetime inhumacionDatetime, incineracionDatetime, trasladoDatetime, ceremoniaDatetime, despedidaDatetime;
                    Date inhumacionDate, incineracionDate, trasladoDate, ceremoniaDate, despedidaDate;
                    if (newMap.get(servicioId).ONE_Hora_Destino_Final__c != null) {
                        inhumacionDatetime = newMap.get(servicioId).ONE_Hora_Destino_Final__c;
                        dateList.add(inhumacionDatetime);
                        inhumacionDate = inhumacionDatetime.date();
                    }
                    if (newMap.get(servicioId).ONE_Inicio_Incineracion__c != null) {
                        incineracionDatetime = newMap.get(servicioId).ONE_Inicio_Incineracion__c;
                        dateList.add(incineracionDatetime);
                        incineracionDate = incineracionDatetime.date();
                    }
                    if (newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c != null) {
                        trasladoDatetime = newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c;
                        dateList.add(trasladoDatetime);
                        trasladoDate = trasladoDatetime.date();
                    }
                    if (newMap.get(servicioId).ONE_Inicio_Ceremonia__c != null) {
                        ceremoniaDatetime = newMap.get(servicioId).ONE_Inicio_Ceremonia__c;
                        dateList.add(ceremoniaDatetime);
                        ceremoniaDate = ceremoniaDatetime.date();
                    }
                    if (newMap.get(servicioId).ONE_Inicio_Despedida__c != null) {
                        despedidaDatetime = newMap.get(servicioId).ONE_Inicio_Despedida__c;
                        dateList.add(despedidaDatetime);
                        despedidaDate = despedidaDatetime.date();
                    }

                    Boolean moreThanOneDay = false;
                    Date firstEventDate;
                    if (!dateList.isEmpty()) {
                        dateList.sort();
                        firstEventDate = dateList[0].date();

                        if ((inhumacionDate != null && inhumacionDate != firstEventDate) ||
                            (incineracionDate != null && incineracionDate != firstEventDate) ||
                            (trasladoDate != null && trasladoDate != firstEventDate) ||
                            (ceremoniaDate != null && ceremoniaDate != firstEventDate) ||
                            (despedidaDate != null && despedidaDate != firstEventDate))
                        {
                            moreThanOneDay = true;
                        }

                        if (moreThanOneDay) {
                            Map<Date, List<Datetime>> eventDateMap = new Map<Date, List<Datetime>>();
                            for (Datetime eventDatetime : dateList) {
                                List<Datetime> eventDatetimeList = eventDateMap.get(eventDatetime.date()) != null ? eventDateMap.get(eventDatetime.date()) : new List<Datetime>();
                                eventDatetimeList.add(eventDatetime);
                                eventDatetimeList.sort();
                                eventDateMap.put(eventDatetime.date(), eventDatetimeList);
                            }
                            List<Date> eventDates = new List<Date>(eventDateMap.keySet());
                            eventDates.sort();
                            system.debug('eventDates :: '+eventDates);
                            ONE_LineaPlanificacion__c lpToUpdate, lpToUpsert;
                            Id origenId = newMap.get(servicioId).ONE_Velacion__c ? newMap.get(servicioId).ONE_Lugar_De_Velacion__c : newMap.get(servicioId).ONE_Deposito__c ? newMap.get(servicioId).ONE_Lugar_De_Deposito__c : null;

                            // Check if upsertion is turned on for the Center
                            upsertLineaPlanificacionRequired = newMapWithRelatedFields.get(servicioId).ONE_Centro_Del_Expediente__r?.ONE_Creacion_automatica_LPs_futuras__c;

                            for (Integer i = 0; i < eventDates.size(); i++) {
                                lpToUpdate = null;
                                lpToUpsert = null;
                                system.debug('i :: '+i);
                                system.debug('eventDates[i] :: '+eventDates[i]);
                                if (i == 0) {
                                    if (primeraLineaPlanificacionMap.get(servicioId)?.Id != null) {
                                        system.debug('primeraLineaPlanificacion');
                                        lpToUpdate = new ONE_LineaPlanificacion__c(Id = primeraLineaPlanificacionMap.get(servicioId).Id);
                                        Datetime lastEventDatetime = eventDateMap.get(eventDates[i]).get(eventDateMap.get(eventDates[i]).size()-1);
                                        if (lastEventDatetime == newMap.get(servicioId).ONE_Hora_Destino_Final__c) {
                                            lpToUpdate.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Hora_Destino_Final__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpdate.ONE_Origen__c = origenId;
                                            lpToUpdate.ONE_Destino__c = newMap.get(servicioId).ONE_Destino_Final__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Inicio_Incineracion__c) {
                                            lpToUpdate.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Inicio_Incineracion__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpdate.ONE_Origen__c = origenId;
                                            lpToUpdate.ONE_Destino__c = newMap.get(servicioId).ONE_Lugar_Incineracion__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c) {
                                            lpToUpdate.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpdate.ONE_Origen__c = origenId;
                                            lpToUpdate.ONE_Destino__c = newMap.get(servicioId).ONE_Destino_Traslado__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Inicio_Ceremonia__c) {
                                            lpToUpdate.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Inicio_Ceremonia__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpdate.ONE_Origen__c = origenId;
                                            lpToUpdate.ONE_Destino__c = newMap.get(servicioId).ONE_Lugar_Ceremonia__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Inicio_Despedida__c) {
                                            lpToUpdate.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Inicio_Despedida__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpdate.ONE_Origen__c = origenId;
                                            lpToUpdate.ONE_Destino__c = newMap.get(servicioId).ONE_Lugar_Despedida__c;
                                        }

                                        if (newMap.get(servicioId).ONE_Velacion__c) {
                                            lpToUpdate.ONE_DireccionOrigen__c = newMap.get(servicioId).ONE_Direccion_Velacion__c + ', ' + newMap.get(servicioId).ONE_Codigo_Postal_Velacion__c + ' ' + newMap.get(servicioId).ONE_Municipio_Velacion__c;
                                        }
                                        else if (newMap.get(servicioId).ONE_Deposito__c) {
                                            lpToUpdate.ONE_DireccionOrigen__c = newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Direccion__c + ', ' + newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Codigo_Postal__c + ' ' + newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Municipio_Direccion__c;
                                        }
                
                                        if (String.isBlank(lpToUpdate.ONE_OrigenLibre__c)) {
                                            lpToUpdate.ONE_OrigenLibre__c = getOrigenLibre(newMap.get(servicioId), newMapWithRelatedFields.get(servicioId));
                                        }
                                    }
                                    
                                }
                                else {
                                    system.debug('Upsert required? ' + upsertLineaPlanificacionRequired);
                                    if(upsertLineaPlanificacionRequired == true) {
                                        lpToUpsert = new ONE_LineaPlanificacion__c(ONE_IdExterno__c = servicioId + '-' + eventDates[i]);
                                        lpToUpsert.ONE_Servicio__c = servicioId;
                                        Datetime lastEventDatetime = eventDateMap.get(eventDates[i]).get(eventDateMap.get(eventDates[i]).size()-1);
                                        if (lastEventDatetime == newMap.get(servicioId).ONE_Hora_Destino_Final__c) {
                                            lpToUpsert.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Hora_Destino_Final__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpsert.ONE_Origen__c = origenId;
                                            lpToUpsert.ONE_Destino__c = newMap.get(servicioId).ONE_Destino_Final__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Inicio_Incineracion__c) {
                                            lpToUpsert.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Inicio_Incineracion__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpsert.ONE_Origen__c = origenId;
                                            lpToUpsert.ONE_Destino__c = newMap.get(servicioId).ONE_Lugar_Incineracion__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c) {
                                            lpToUpsert.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpsert.ONE_Origen__c = origenId;
                                            lpToUpsert.ONE_Destino__c = newMap.get(servicioId).ONE_Destino_Traslado__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Inicio_Ceremonia__c) {
                                            lpToUpsert.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Inicio_Ceremonia__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpsert.ONE_Origen__c = origenId;
                                            lpToUpsert.ONE_Destino__c = newMap.get(servicioId).ONE_Lugar_Ceremonia__c;
                                        }
                                        else if (lastEventDatetime == newMap.get(servicioId).ONE_Inicio_Despedida__c) {
                                            lpToUpsert.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(newMap.get(servicioId).ONE_Inicio_Despedida__c.date(), Time.newInstance(0, 0, 0, 0));
                                            lpToUpsert.ONE_Origen__c = origenId;
                                            lpToUpsert.ONE_Destino__c = newMap.get(servicioId).ONE_Lugar_Despedida__c;
                                        }

                                        if (newMap.get(servicioId).ONE_Velacion__c) {
                                            lpToUpsert.ONE_DireccionOrigen__c = newMap.get(servicioId).ONE_Direccion_Velacion__c + ', ' + newMap.get(servicioId).ONE_Codigo_Postal_Velacion__c + ' ' + newMap.get(servicioId).ONE_Municipio_Velacion__c;
                                        }
                                        else if (newMap.get(servicioId).ONE_Deposito__c) {
                                            lpToUpsert.ONE_DireccionOrigen__c = newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Direccion__c + ', ' + newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Codigo_Postal__c + ' ' + newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Municipio_Direccion__c;
                                        }
                                        /*
                                        if (String.isBlank(lpToUpsert.ONE_OrigenLibre__c)) {
                                            lpToUpsert.ONE_OrigenLibre__c = getOrigenLibre(newMap.get(servicioId), newMapWithRelatedFields.get(servicioId));
                                        }*/
                                    }

                                }
                                if (lpToUpdate != null) {
                                    lineasPlanificacionToUpdate2.add(lpToUpdate);
                                }

                                if (lpToUpsert != null) {
                                    lineasPlanificacionToUpsert.add(lpToUpsert);
                                }
                            }
                        }
                        else {
                            if (primeraLineaPlanificacionMap.get(servicioId)?.Id != null) {
                                ONE_LineaPlanificacion__c lineaPlanificacion = new ONE_LineaPlanificacion__c (Id = primeraLineaPlanificacionMap.get(servicioId).Id);
                                lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c = DateTime.newInstance(firstEventDate, Time.newInstance(0, 0, 0, 0));

                                Id destinoId;
                                Datetime lastEventDatetime = dateList.get(dateList.size()-1);
                                
                                if (inhumacionDatetime == lastEventDatetime) {
                                    destinoId = newMap.get(servicioId).ONE_Destino_Final__c;
                                }
                                else if (incineracionDatetime == lastEventDatetime) {
                                    destinoId = newMap.get(servicioId).ONE_Lugar_Incineracion__c;
                                }
                                else if (trasladoDatetime == lastEventDatetime) {
                                    destinoId = newMap.get(servicioId).ONE_Destino_Traslado__c;
                                }
                                else if (ceremoniaDatetime == lastEventDatetime) {
                                    destinoId = newMap.get(servicioId).ONE_Lugar_Ceremonia__c;
                                }
                                
                                lineaPlanificacion.ONE_Origen__c = newMap.get(servicioId).ONE_Velacion__c ? newMap.get(servicioId).ONE_Lugar_De_Velacion__c : newMap.get(servicioId).ONE_Deposito__c ? newMap.get(servicioId).ONE_Lugar_De_Deposito__c : null;
                                
                                if (newMap.get(servicioId).ONE_Velacion__c) {
                                    lineaPlanificacion.ONE_DireccionOrigen__c = newMap.get(servicioId).ONE_Direccion_Velacion__c + ', ' + newMap.get(servicioId).ONE_Codigo_Postal_Velacion__c + ' ' + newMap.get(servicioId).ONE_Municipio_Velacion__c;
                                }
                                else if (newMap.get(servicioId).ONE_Deposito__c) {
                                    lineaPlanificacion.ONE_DireccionOrigen__c = newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Direccion__c + ', ' + newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Codigo_Postal__c + ' ' + newMapWithRelatedFields.get(servicioId).ONE_Lugar_De_Deposito__r.ONE_Municipio_Direccion__c;
                                }
                                
                                if (String.isBlank(lineaPlanificacion.ONE_OrigenLibre__c)) {
                                    lineaPlanificacion.ONE_OrigenLibre__c = getOrigenLibre(newMap.get(servicioId), newMapWithRelatedFields.get(servicioId));
                                }

                                lineaPlanificacion.ONE_Destino__c = destinoId;
                                
                                lineasPlanificacionToUpdate3.add(lineaPlanificacion);
                            }
                        }
                    }
                }
            }

            system.debug('lineasPlanificacionToUpdate2 :: '+lineasPlanificacionToUpdate2);
            update lineasPlanificacionToUpdate2;
            system.debug('lineasPlanificacionToUpdate3 :: '+lineasPlanificacionToUpdate3);
            update lineasPlanificacionToUpdate3;
            system.debug('lineasPlanificacionToUpsert :: '+lineasPlanificacionToUpsert);
            upsert lineasPlanificacionToUpsert ONE_IdExterno__c;

            Id previousDestinoId = null;
            Id previousServicioId = null;
            String previousDestinoName, previousDestinoAddress = '';
            Id servicioId;
            
             Map<Id, ONE_LineaPlanificacion__c> LineasplanificacionesMap =new Map<id, ONE_LineaPlanificacion__c>([SELECT
                                                                        ONE_FechaLineaPlanificacionDateTime__c,
                                                                        ONE_Servicio__c,
                                                                        ONE_Origen__c,
                                                                        ONE_DireccionOrigen__c,
                                                                        ONE_OrigenLibre__c,
                                                                        ONE_Destino__c,
                                                                        ONE_Destino__r.Name,
                                                                        ONE_Destino__r.ONE_Direccion__c,
                                                                        ONE_Destino__r.ONE_Codigo_Postal__c,
                                                                        ONE_Destino__r.ONE_Municipio_Direccion__c,
                                                                        ONE_LugarTanatorio__r.Name,
                                                                        ONE_LugarTanatorio__r.ONE_Direccion__c,
                                                                        ONE_LugarTanatorio__r.ONE_Codigo_Postal__c,
                                                                        ONE_LugarTanatorio__r.ONE_Municipio_Direccion__c,
                                                                        ONE_LugarTanatorio__c,
                                                                        ONE_Tipo_de_ritual_libre__c
                                                                    FROM ONE_LineaPlanificacion__c
                                                                    WHERE
                                                                        ONE_Servicio__c != null AND
                                                                        ONE_Servicio__c IN :newMap.keySet() AND
                                                                        ONE_FechaLineaPlanificacionDateTime__c != null
                                                                    ORDER BY ONE_Servicio__c ASC, ONE_FechaLineaPlanificacionDateTime__c ASC]);
            for (ONE_LineaPlanificacion__c lineaPlanificacion : LineasplanificacionesMap.values())
            {
                updateLineaPlanificacionRequired = false;
                servicioId = lineaPlanificacion.ONE_Servicio__c;
                if (newMap.get(servicioId).ONE_Hora_Destino_Final__c != oldMap.get(servicioId).ONE_Hora_Destino_Final__c ||
                    newMap.get(servicioId).ONE_Inicio_Incineracion__c != oldMap.get(servicioId).ONE_Inicio_Incineracion__c ||
                    newMap.get(servicioId).ONE_Fecha_Salida_Traslado__c != oldMap.get(servicioId).ONE_Fecha_Salida_Traslado__c ||
                    newMap.get(servicioId).ONE_Inicio_Ceremonia__c != oldMap.get(servicioId).ONE_Inicio_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Direccion_Velacion__c != oldMap.get(servicioId).ONE_Direccion_Velacion__c ||
                    newMap.get(servicioId).ONE_Destino_Final__c != oldMap.get(servicioId).ONE_Destino_Final__c ||
                    newMap.get(servicioId).ONE_Lugar_Incineracion__c != oldMap.get(servicioId).ONE_Lugar_Incineracion__c ||
                    newMap.get(servicioId).ONE_Destino_Traslado__c != oldMap.get(servicioId).ONE_Destino_Traslado__c ||
                    newMap.get(servicioId).ONE_Lugar_Ceremonia__c != oldMap.get(servicioId).ONE_Lugar_Ceremonia__c ||
                    newMap.get(servicioId).ONE_Codigo_Postal_Velacion__c != oldMap.get(servicioId).ONE_Codigo_Postal_Velacion__c ||
                    newMap.get(servicioId).ONE_Municipio_Velacion__c != oldMap.get(servicioId).ONE_Municipio_Velacion__c ||
                    newMap.get(servicioId).ONE_Lugar_De_Deposito__c != oldMap.get(servicioId).ONE_Lugar_De_Deposito__c ||
                    newMap.get(servicioId).ONE_Lugar_De_Velacion__c != oldMap.get(servicioId).ONE_Lugar_De_Velacion__c ||
                    newMap.get(servicioId).ONE_Sala_Deposito__c != oldMap.get(servicioId).ONE_Sala_Deposito__c ||
                    newMap.get(servicioId).ONE_Sala_De_Velacion__c != oldMap.get(servicioId).ONE_Sala_De_Velacion__c)
                {
                    if (servicioId == previousServicioId) {
                        lineaPlanificacion.ONE_Origen__c = previousDestinoId;
                        lineaPlanificacion.ONE_DireccionOrigen__c = previousDestinoAddress;
                        //lineaPlanificacion.ONE_OrigenLibre__c = previousDestinoName;
                        updateLineaPlanificacionRequired = true;
                    }
                    if (lineaPlanificacion.ONE_Destino__c != newMap.get(servicioId).ONE_Lugar_Incineracion__c &&
                        lineaPlanificacion.ONE_Destino__c != newMap.get(servicioId).ONE_Destino_Final__c &&
                        lineaPlanificacion.ONE_Destino__c != newMap.get(servicioId).ONE_Destino_Traslado__c)
                    {
                        lineaPlanificacion.ONE_Destino__c = lineaPlanificacion.ONE_LugarTanatorio__c;
                        previousDestinoName = lineaPlanificacion.ONE_LugarTanatorio__r.Name;
                        previousDestinoAddress = lineaPlanificacion.ONE_LugarTanatorio__r.ONE_Direccion__c + ', ' + lineaPlanificacion.ONE_LugarTanatorio__r.ONE_Codigo_Postal__c + ' ' + lineaPlanificacion.ONE_LugarTanatorio__r.ONE_Municipio_Direccion__c;
                        updateLineaPlanificacionRequired = true;
                    }
                    else {
                        previousDestinoName = lineaPlanificacion.ONE_Destino__r.Name;
                        previousDestinoAddress = lineaPlanificacion.ONE_Destino__r.ONE_Direccion__c + ', ' + lineaPlanificacion.ONE_Destino__r.ONE_Codigo_Postal__c + ' ' + lineaPlanificacion.ONE_Destino__r.ONE_Municipio_Direccion__c;
                    }
                }

                previousDestinoId = lineaPlanificacion.ONE_Destino__c;
                previousServicioId = servicioId;

                if (updateLineaPlanificacionRequired) {
                    lineasPlanificacionToUpdate4.add(lineaPlanificacion);
                }
            }

            update lineasPlanificacionToUpdate4;
        }
    }

    public static Datetime getMinimumDate(List<Datetime> dates) {

        Datetime minimumDate = null;
        List<Datetime> dateList = new List<DateTime>();

        for (Datetime dateItem : dates) {
            if (dateItem != null) {
                dateList.add(dateItem);
            }
        }

        if (!dateList.isEmpty()) {
            dateList.sort();
            minimumDate = dateList.get(0);
        }
        
        return minimumDate;
    }

    public static String getOrigenLibre(ONE_Expediente__c servicio, ONE_Expediente__c servicioWithRelatedFields) {

        String origenLibre = '';
        
        if (servicio.ONE_Velacion__c) {
            if (servicio.ONE_Lugar_De_Velacion__c != null) {
                String salaVelacion = String.isNotBlank(servicio.Numero_Sala_Velacion_Ext__c) ? servicio.Numero_Sala_Velacion_Ext__c : ( servicioWithRelatedFields.ONE_Sala_De_Velacion__r.ONE_Numero_De_Sala__c != null ? servicioWithRelatedFields.ONE_Sala_De_Velacion__r.ONE_Numero_De_Sala__c.format() : '' );
                origenLibre = servicioWithRelatedFields.ONE_Lugar_De_Velacion__r.Name + ' - ' + salaVelacion;
            }
            else if (servicio.ONE_Tipo_De_Lugar_De_Velacion__c == 'Domicilio' && String.isNotBlank(servicio.ONE_Direccion_Velacion__c)) {
                origenLibre = servicio.ONE_Direccion_Velacion__c + ', ' + servicio.ONE_Codigo_Postal_Velacion__c + ' ' + servicio.ONE_Municipio_Velacion__c;
            }
        }
        else if (servicio.ONE_Deposito__c) {
            if (servicio.ONE_Lugar_De_Deposito__c != null) {
                String salaDeposito = servicioWithRelatedFields.ONE_Sala_Deposito__r.Name != null ? servicioWithRelatedFields.ONE_Sala_Deposito__r.Name : '';
                origenLibre = servicioWithRelatedFields.ONE_Lugar_De_Deposito__r.Name + ' - ' + salaDeposito;
            }
        }

        return origenLibre;
    }

    public static String getDestinoIntermedioLibre(ONE_Expediente__c servicio, ONE_Expediente__c servicioWithRelatedFields) {

        String destinoIntermedioLibre = '';
        String nombreLugarCeremonia = servicioWithRelatedFields?.ONE_Lugar_Ceremonia__r?.Name != null ? servicioWithRelatedFields.ONE_Lugar_Ceremonia__r.Name : '';
        String salaCeremoniaInterna = servicioWithRelatedFields?.ONE_Sala_Ceremonia__r?.Name != null ? servicioWithRelatedFields.ONE_Sala_Ceremonia__r.Name : '';
        String salaCeremoniaExterna = servicio?.Numero_sala_Ceremonia_Ext__c != null ? servicio.Numero_sala_Ceremonia_Ext__c : '';
        String municipioCeremonia = servicio?.ONE_Municipio_Ceremonia__c != null ? servicio.ONE_Municipio_Ceremonia__c : '';
        String direccionCeremonia = servicio?.ONE_Direccion_Ceremonia__c != null ? servicio.ONE_Direccion_Ceremonia__c : '';

        if (servicio.ONE_Tipo_De_Lugar_De_Ceremonia__c == 'Interno') {
            destinoIntermedioLibre = salaCeremoniaInterna;
        }
        else if (servicio.ONE_Tipo_De_Lugar_De_Ceremonia__c == 'Tanatorio Externo') {
            destinoIntermedioLibre = nombreLugarCeremonia + ' - ' + salaCeremoniaExterna + ' - ' + municipioCeremonia;
        }
        else if (servicio.ONE_Tipo_De_Lugar_De_Ceremonia__c == 'Iglesia') {
            destinoIntermedioLibre = nombreLugarCeremonia + ' - ' + municipioCeremonia;
        }
        else if (servicio.ONE_Tipo_De_Lugar_De_Ceremonia__c == 'Domicilio') {
            destinoIntermedioLibre = direccionCeremonia + ' - ' + municipioCeremonia;
        }
        else if (servicio.ONE_Lugar_Ceremonia__c != null) {
            destinoIntermedioLibre = direccionCeremonia + ' - ' + municipioCeremonia;
        }
                
        return destinoIntermedioLibre;
    }
    
    public static void deleteReservasServicio(Map<Id, ONE_Expediente__c> oldMap, Map<Id, ONE_Expediente__c> newMap) {
        
        System.debug('oldMap is: ' + oldMap);
        System.debug('newMap is: ' + newMap);

        Map<Id, ONE_SlotSala__c> slotsToUpdate = new Map<Id, ONE_SlotSala__c>();
        Map<Id, ONE_SlotSala__c> slotsToDelete = new Map<Id, ONE_SlotSala__c>();
        Map<Id, ONE_Reservas__c> reservasToDelete = new Map<Id, ONE_Reservas__c>();

        try {
            
            List<ONE_Reservas__c> reservas = [SELECT Id, Name, ONE_Expediente__c, ONE_Momento_Al_Que_Aplica__c FROM ONE_Reservas__c
                                                                                    WHERE ONE_Expediente__c IN :newMap.keySet()];
            System.debug('reserva is: ' + reservas);
            for (ONE_Reservas__c reserva : reservas) {
                
                if ((reserva.ONE_Momento_Al_Que_Aplica__c == 'Velación' && oldMap.get(reserva.ONE_Expediente__c).ONE_Velacion__c && !newMap.get(reserva.ONE_Expediente__c).ONE_Velacion__c)
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Ceremonia' && oldMap.get(reserva.ONE_Expediente__c).ONE_Ceremonia__c && !newMap.get(reserva.ONE_Expediente__c).ONE_Ceremonia__c)
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Cremación' && oldMap.get(reserva.ONE_Expediente__c).ONE_Incineracion__c && !newMap.get(reserva.ONE_Expediente__c).ONE_Incineracion__c)
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Depósito' && oldMap.get(reserva.ONE_Expediente__c).ONE_Deposito__c && !newMap.get(reserva.ONE_Expediente__c).ONE_Deposito__c)
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Despedida' && oldMap.get(reserva.ONE_Expediente__c).ONE_Despedida__c && !newMap.get(reserva.ONE_Expediente__c).ONE_Despedida__c)) {
                        
                    List<ONE_SlotSala__c> slotToUpdate = [SELECT Id, ONE_Reserva__c, ONE_FinSlot__c, ONE_InicioSlot__c FROM ONE_SlotSala__c WHERE ONE_Reserva__c =:reserva.Id LIMIT 1];

                    if (slotToUpdate.size() > 0) {
                        if (slotToUpdate[0].ONE_InicioSlot__c != null && slotToUpdate[0].ONE_FinSlot__c != null) {
                            ONE_SlotSala__c slotToClear = new ONE_SlotSala__c (
                            Id = slotToUpdate[0].Id,
                            ONE_Servicio__c = null
                            );
                            slotsToUpdate.put(slotToClear.Id ,slotToClear);
                            //update slotToClear;
                        }
                        else {
                            ONE_SlotSala__c slotToClear = new ONE_SlotSala__c (
                            Id = slotToUpdate[0].Id
                            );
                            slotsToDelete.put(slotToClear.Id ,slotToClear);
                            //delete slotToClear;
                        }
                        
                    }
                    System.debug('Time to delete reserva');
                    reservasToDelete.put(reserva.Id, reserva);
                    //delete reserva;
                }

                /*
                else if (oldMap.get(reserva.ONE_Expediente__c).ONE_Cementerio__c && !newMap.get(reserva.ONE_Expediente__c).ONE_Cementerio__c) {
                    //expediente.ONE_Cementerio__c = false; 
                    expediente.ONE_Destino_final__c = null;
                    expediente.ONE_Hora_destino_final__c = null;
                }
                else if (oldMap.get(reserva.ONE_Expediente__c).ONE_Donacion__c && !newMap.get(reserva.ONE_Expediente__c).ONE_Donacion__c) {
                    //expediente.ONE_Donacion__c = false; 
                    expediente.ONE_Fecha_Donacion__c = null;
                    expediente.ONE_Municipio_Donacion__c = null;
                    expediente.ONE_Codigo_Postal_Donacion__c = null;
                    expediente.ONE_Datos_Donacion__c = null;
                    expediente.ONE_Direccion_Donacion__c = null;
                    expediente.ONE_Destino_Donacion__c = null;
                    expediente.ONE_Pais_Donacion__c = null;
                    expediente.ONE_Provincia_Donacion__c = null;
                }*/
                
                else continue;
            }

        update slotsToUpdate.values();
        delete slotsToDelete.values();
        delete reservasToDelete.values(); 
            
        } catch (Exception e) {
                System.debug('reserva is wrong in catch');
        }
        
    }

    @future
    public static void updateFechaProgramada(Id lineaPlanificacionId) {

        ONE_LineaPlanificacion__c lineaPlanificacion = [SELECT Id, ONE_FechaProgramada__c, Primer_evento_del_dia_v3__c FROM ONE_LineaPlanificacion__c WHERE Id = :lineaPlanificacionId];
        
        if (lineaPlanificacion.Primer_evento_del_dia_v3__c != null) {
            lineaPlanificacion.ONE_FechaProgramada__c = lineaPlanificacion.Primer_evento_del_dia_v3__c.date();
            
            System.debug('Updating fecha programada to: ' + lineaPlanificacion.ONE_FechaProgramada__c);
            try {
                update lineaPlanificacion;
            } catch (DmlException e) {
                System.debug('Error updating fecha programada: ' + e.getMessage());
            }
        }
    }

    public static void deleteObsoleteLineasPlanificacion(Map<Id, ONE_Expediente__c> oldMap, Map<Id, ONE_Expediente__c> newMap) {

        Set<Id> lineasPlanificacionToDeleteIds = new Set<Id>();

        Id primeraLineaPlanificacionID = null;
        Date primeraLineaPlanificacionDate = null;
        
        Map<Id, ONE_LineaPlanificacion__c> LineasplanificacionesMap =new Map<id, ONE_LineaPlanificacion__c>
        ([SELECT Id, ONE_Servicio__c, ONE_FechaLineaPlanificacionDateTime__c, ONE_CreadoManualmente__c, ONE_IdExterno__c
                FROM ONE_LineaPlanificacion__c
                WHERE
                    ONE_Servicio__c IN :newMap.keySet() AND 
                    ONE_CreadoManualmente__c = false AND
                    ONE_FechaLineaPlanificacionDateTime__c != null]);

        // Bucle 1 - get first LP and date
        for (ONE_LineaPlanificacion__c lineaPlanificacion : LineasplanificacionesMap.values())
        {
            if (lineaPlanificacion.ONE_IdExterno__c == null) {
                    primeraLineaPlanificacionID = lineaPlanificacion.Id;
                    primeraLineaPlanificacionDate = lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date();
                    break;
            }
        }

        System.debug('ID Primera LP: ' + primeraLineaPlanificacionID);
        System.debug('Date Primera LP: ' + primeraLineaPlanificacionDate);

        // Bucle 2 - search for deletes
        for (ONE_LineaPlanificacion__c lineaPlanificacion : LineasplanificacionesMap.values())
        {
            
            if (lineaPlanificacion.Id != primeraLineaPlanificacionID)
            {
                // Day repeated
                if (lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date() == primeraLineaPlanificacionDate) 
                {
                    lineasPlanificacionToDeleteIds.add(lineaPlanificacion.Id);
                    continue;
                }

                // LP not in event dates
                if (lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date() != null &&
                    lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date() != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c?.date() &&
                    lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date() != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Despedida__c?.date() &&
                    lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date() != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c?.date() &&
                    lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date() != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c?.date() &&
                    lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c?.date() != newMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c?.date())
                {
                    lineasPlanificacionToDeleteIds.add(lineaPlanificacion.Id);
                }

            }
        }
        System.debug('LPs TO DELETE: ' + lineasPlanificacionToDeleteIds);

        if (!lineasPlanificacionToDeleteIds.isEmpty() && !System.isFuture() && !System.isBatch()) {
            System.debug('CALL deleteObsoleteLineasPlanificacionFuture');
            deleteObsoleteLineasPlanificacionFuture(lineasPlanificacionToDeleteIds);
        }
        deleteReservasServicio(oldMap, newMap);
    }

    @future
    public static void deleteObsoleteLineasPlanificacionFuture(Set<Id> lineasPlanificacionToDeleteIds) {

        List<ONE_LineaPlanificacion__c> lineasPlanificacionToDelete = new List<ONE_LineaPlanificacion__c>();
        
        Map<Id, ONE_LineaPlanificacion__c> LineasplanificacionesMap =new Map<id, ONE_LineaPlanificacion__c>([SELECT Id, OwnerId, ONE_IdExterno__c FROM ONE_LineaPlanificacion__c WHERE Id IN :lineasPlanificacionToDeleteIds]);

        for (ONE_LineaPlanificacion__c lp : LineasplanificacionesMap.values()) {
            if (lp.ONE_IdExterno__c != null) {
                lp.OwnerId = UserInfo.getUserId();
                lineasPlanificacionToDelete.add(lp);
            }
        }
        
        if (!lineasPlanificacionToDelete.isEmpty()) {
            System.debug('Deleting LPs: ' + lineasPlanificacionToDelete);
            try {
                update lineasPlanificacionToDelete; // change owner to current user
                delete lineasPlanificacionToDelete;
            } catch (DmlException e) {
                System.debug('Error deleting LPs: ' + e.getMessage());
            }
        }
    }
}
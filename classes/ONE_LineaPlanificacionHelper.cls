public without sharing class ONE_LineaPlanificacionHelper {

    public static void autoCompleteFields(List<ONE_LineaPlanificacion__c> newRecords) {

        Set<Id> servicioIdSet = new Set<Id>();
        Set<Id> casoIdSet = new Set<Id>();
        for (ONE_LineaPlanificacion__c lineaPlanificacion : newRecords) {
            if (!lineaPlanificacion.ONE_Duplicado__c) {
                if (lineaPlanificacion.ONE_Servicio__c != null) {
                    servicioIdSet.add(lineaPlanificacion.ONE_Servicio__c);
                }
                else if (lineaPlanificacion.ONE_Caso__c != null) {
                    casoIdSet.add(lineaPlanificacion.ONE_Caso__c);
                }
            }
        }

        Map<Id, ONE_Expediente__c> servicioMap = new Map<Id, ONE_Expediente__c>();
        Map<Id, ONE_Caso__c> casoMap = new Map<Id, ONE_Caso__c>();

        for (ONE_Expediente__c servicio : [ SELECT
                                                OwnerId,
                                                ONE_Difunto__c,
                                                ONE_Difunto__r.Name,
                                                ONE_Tipo_De_Difunto__c,
                                                toLabel(ONE_Tipo_De_Difunto__c) tipoDifuntoLabel,
                                                ONE_Centro_Del_Expediente__c,
                                                ONE_Lugar_De_Defuncion__c,
                                                ONE_Velacion__c,
                                                ONE_Inicio_Velacion__c,
                                                ONE_Fin_Velacion__c,
                                                ONE_Lugar_De_Velacion__c,
                                                ONE_Sala_De_Velacion__c,
                                                Numero_Sala_Velacion_Ext__c,
                                                ONE_Deposito__c,
                                                ONE_Inicio_Deposito__c,
                                                ONE_Fin_Deposito__c,
                                                ONE_Lugar_De_Deposito__c,
                                                ONE_Sala_Deposito__c,
                                                ONE_Inicio_Ceremonia__c,
                                                ONE_Fin_Ceremonia__c,
                                                ONE_Lugar_Ceremonia__c,
                                                ONE_PersonalCeremonia__c,
                                                ONE_Funeraria_Origen_Destino_Recepcion__c,
                                                ONE_Inicio_Incineracion__c,
                                                ONE_Lugar_Incineracion__c,
                                                ONE_Hora_Destino_Final__c,
                                                ONE_Destino_Final__c,
                                                ONE_Fecha_Salida_Traslado__c,
                                                ONE_Destino_Traslado__c,
                                                ONE_Confirmada_Ceremonia_Externa__c,
                                                ONE_Ceremonia_Inhumacion_Confirmada__c,
                                                ONE_Observaciones_Generales__c,
                                                ONE_Licencia_Despachada__c,
                                                ONE_Lugar_Ceremonia__r.Name,
                                                ONE_Municipio_Ceremonia__c,
                                                ONE_Sala_Ceremonia__r.Name,
                                                Numero_sala_Ceremonia_Ext__c,
                                                ONE_Tipo_De_Lugar_De_Ceremonia__c,
                                                ONE_Direccion_Ceremonia__c,
                                                ONE_Lugar_Incineracion__r.Name,
                                                ONE_Horno_Incineracion__r.Name,
                                                ONE_Destino_Final__r.Name,
                                                ONE_Destino_Traslado__r.Name,
                                                ONE_Funeraria_Origen_Destino_Recepcion__r.Name,
                                                ONE_Modelo_De_Feretro__r.Name,
                                                ONE_Modelo_Urna__r.Name,
                                                ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name
                                           
                                            FROM ONE_Expediente__c WHERE Id IN :servicioIdSet])
        {
            servicioMap.put(servicio.Id, servicio);
        }

        for (ONE_Caso__c caso : [   SELECT
                                        OwnerId,
                                        ONE_Difunto__c,
                                        ONE_Difunto__r.Name,
                                        ONE_Tipo_De_Difunto__c,
                                        toLabel(ONE_Tipo_De_Difunto__c) tipoDifuntoLabel,
                                        ONE_Centro_Del_Servicio__c,
                                        ONE_Lugar_De_Defuncion02__c
                                    FROM ONE_Caso__c WHERE Id IN :casoIdSet])
        {
            casoMap.put(caso.Id, caso);
        }

        for (ONE_LineaPlanificacion__c lineaPlanificacion : newRecords) {

            if (!lineaPlanificacion.ONE_Duplicado__c) {

                if (lineaPlanificacion.Primer_evento_del_dia_v3__c != null) {
                    lineaPlanificacion.ONE_FechaProgramada__c = lineaPlanificacion.Primer_evento_del_dia_v3__c.date();
                }

                if (lineaPlanificacion.ONE_Servicio__c != null) {

                    lineaPlanificacion.OwnerId = servicioMap.get(lineaPlanificacion.ONE_Servicio__c).OwnerId;

                    String modeloFeretro = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Modelo_De_Feretro__r?.Name == null ? '' : servicioMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_De_Feretro__r.Name;
                    String modeloUrna = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Modelo_Urna__r?.Name == null ? '' : servicioMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Modelo_Urna__r.Name;
                    lineaPlanificacion.ONE_FeretroUrnaLibre__c = modeloFeretro + ' - ' + modeloUrna;
                    lineaPlanificacion.ONE_Zona_Operativa_Centro__c= servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Centro_Del_Expediente__r?.ONE_Lugar__r?.ONE_Lugar_Superior__r?.Name;
                    lineaPlanificacion.ONE_Difunto__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Difunto__c;
                    lineaPlanificacion.ONE_TipoDifunto__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Tipo_De_Difunto__c;
                    String difuntoName = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Difunto__c != null ? servicioMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Difunto__r.Name : '';
                    String tipoDifuntoLabel = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.get('tipoDifuntoLabel') != null ? (String) servicioMap.get(lineaPlanificacion.ONE_Servicio__c).get('tipoDifuntoLabel') : '';
                    lineaPlanificacion.ONE_NombreTipoDifuntoLibre__c = tipoDifuntoLabel == 'Cadáver adulto' ? difuntoName : tipoDifuntoLabel + ' - ' + difuntoName;
                    lineaPlanificacion.ONE_CentroTrabajo__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Centro_Del_Expediente__c;
                    lineaPlanificacion.ONE_LugarDefuncion__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_De_Defuncion__c;
                    lineaPlanificacion.ONE_Funeraria_Origen_Destino__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Funeraria_Origen_Destino_Recepcion__c;
                    if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Velacion__c) {
                        lineaPlanificacion.ONE_InicioTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Velacion__c;
                        lineaPlanificacion.ONE_LugarTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_De_Velacion__c;
                        lineaPlanificacion.ONE_FinTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fin_Velacion__c;
                        lineaPlanificacion.ONE_SalaTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Sala_De_Velacion__c;
                        lineaPlanificacion.ONE_SalaVelacionExterna__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.Numero_Sala_Velacion_Ext__c;
                    }
                    else if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Deposito__c) {
                        lineaPlanificacion.ONE_InicioTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Deposito__c;
                        lineaPlanificacion.ONE_LugarTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_De_Deposito__c;
                        lineaPlanificacion.ONE_FinTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fin_Deposito__c;
                        lineaPlanificacion.ONE_SalaTanatorio__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Sala_Deposito__c;
                    }

                    if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Deposito__c) {
                        lineaPlanificacion.ONE_Inicio_Deposito__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Deposito__c;
                        lineaPlanificacion.ONE_Fin_Deposito__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fin_Deposito__c;
                        lineaPlanificacion.ONE_Lugar_Deposito__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_De_Deposito__c;
                    }

                    lineaPlanificacion.ONE_InicioCeremonia__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Ceremonia__c;
                    lineaPlanificacion.ONE_FinCeremonia__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fin_Ceremonia__c;
                    lineaPlanificacion.ONE_LugarCeremonia__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Ceremonia__c;
                    lineaPlanificacion.ONE_PersonalCeremonia__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_PersonalCeremonia__c;

                    if (!lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                        lineaPlanificacion.ONE_DestinoIntermedioLibre__c = getDestinoIntermedioLibre(servicioMap.get(lineaPlanificacion.ONE_Servicio__c));
                    }

                    Datetime minimumDate = getMinimumDate(new List<DateTime>{servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c, servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c, servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fecha_Salida_Traslado__c});
                    if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c == minimumDate) {
                        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c;
                        lineaPlanificacion.ONE_LugarDestinoFinal__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__c;
                        if ((servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__c != null || servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Horno_Incineracion__c != null) && !lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                            String hornoIncineracion = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Horno_Incineracion__r?.Name != null ? servicioMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Horno_Incineracion__r.Name : '';
                            if(hornoIncineracion != '') lineaPlanificacion.ONE_DestinoFinalLibre__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__r.Name + ' - ' + hornoIncineracion;
                            else lineaPlanificacion.ONE_DestinoFinalLibre__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__r.Name;
                            //lineaPlanificacion.ONE_DestinoFinalLibre__c = hornoIncineracion;
                        }
                    }
                    else if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c == minimumDate) {
                        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c;
                        lineaPlanificacion.ONE_LugarDestinoFinal__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Final__c;
                        if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Final__c != null && !lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                            lineaPlanificacion.ONE_DestinoFinalLibre__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Final__r?.Name;
                        }
                    }
                    else if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fecha_Salida_Traslado__c == minimumDate) {
                        lineaPlanificacion.ONE_FechaHoraDestinoFinal__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Fecha_Salida_Traslado__c;
                        lineaPlanificacion.ONE_LugarDestinoFinal__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__c;
                        if (servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__c != null && !lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_IdExterno__c == null) {
                            String funerariaDestinoTraslado = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Funeraria_Origen_Destino_Recepcion__r?.Name != null ? servicioMap.get(lineaPlanificacion.ONE_Servicio__c).ONE_Funeraria_Origen_Destino_Recepcion__r.Name : '';
                            lineaPlanificacion.ONE_DestinoFinalLibre__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__r.Name + ' - ' + funerariaDestinoTraslado;
                        }
                    }
                    lineaPlanificacion.ONE_CeremoniaConfirmada__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Confirmada_Ceremonia_Externa__c;
                    lineaPlanificacion.ONE_CeremoniaInhumacionConfirmada__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Ceremonia_Inhumacion_Confirmada__c;
                    lineaPlanificacion.ONE_ObservacionesGenerales__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Observaciones_Generales__c;
                    lineaPlanificacion.ONE_LicenciaEnterramiento__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Licencia_Despachada__c;
                    lineaPlanificacion.ONE_FechaHoraIncineracion__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c;
                    lineaPlanificacion.ONE_FechaHoraInhumacion__c = servicioMap?.get(lineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c;
                }
                else if (lineaPlanificacion.ONE_Caso__c != null) {
                    lineaPlanificacion.OwnerId = casoMap.get(lineaPlanificacion.ONE_Caso__c).OwnerId;
                    lineaPlanificacion.ONE_Difunto__c = casoMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Difunto__c;
                    lineaPlanificacion.ONE_TipoDifunto__c = casoMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Tipo_De_Difunto__c;
                    String difuntoName = casoMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Difunto__c != null ? casoMap.get(lineaPlanificacion.ONE_Caso__c).ONE_Difunto__r.Name : '';
                    String tipoDifuntoLabel = casoMap?.get(lineaPlanificacion.ONE_Caso__c)?.get('tipoDifuntoLabel') != null ? (String) casoMap.get(lineaPlanificacion.ONE_Caso__c).get('tipoDifuntoLabel') : '';
                    lineaPlanificacion.ONE_NombreTipoDifuntoLibre__c = tipoDifuntoLabel == 'Cadáver adulto' ? difuntoName : tipoDifuntoLabel + ' - ' + difuntoName;
                    lineaPlanificacion.ONE_CentroTrabajo__c = casoMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Centro_Del_Servicio__c;
                    lineaPlanificacion.ONE_LugarDefuncion__c = casoMap?.get(lineaPlanificacion.ONE_Caso__c)?.ONE_Lugar_De_Defuncion02__c;
                }
            }
        }
    }

    public static void preventImportantFieldsEmptying(List<ONE_LineaPlanificacion__c> newRecords, Map<Id, ONE_LineaPlanificacion__c> oldMap, Map<Id, ONE_LineaPlanificacion__c> newMap) {

        for (ONE_LineaPlanificacion__c lineaPlanificacion : newRecords) {
            if (String.isNotBlank(oldMap.get(lineaPlanificacion.Id).ONE_Servicio__c) && String.isBlank(lineaPlanificacion.ONE_Servicio__c)) {
                lineaPlanificacion.ONE_Servicio__c = oldMap.get(lineaPlanificacion.Id).ONE_Servicio__c;
            }
        } 
    }

    public static void emptyDestinoIntermedioLibre(List<ONE_LineaPlanificacion__c> newRecords, Map<Id, ONE_LineaPlanificacion__c> oldMap, Map<Id, ONE_LineaPlanificacion__c> newMap) {

        for (ONE_LineaPlanificacion__c lineaPlanificacion : newRecords) {
            if ((!lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c != null && lineaPlanificacion.ONE_InicioCeremonia__c != null && lineaPlanificacion.ONE_FechaLineaPlanificacionDateTime__c > lineaPlanificacion.ONE_InicioCeremonia__c)
                || (lineaPlanificacion.ONE_CreadoManualmente__c && lineaPlanificacion.ONE_PrimerEventoDiaManual__c != null && lineaPlanificacion.ONE_InicioCeremonia__c != null && lineaPlanificacion.ONE_PrimerEventoDiaManual__c.date() > lineaPlanificacion.ONE_InicioCeremonia__c.date()))
            {
                lineaPlanificacion.ONE_DestinoIntermedioLibre__c = '';
            }
        } 
    }

    public static void saveFechaHoraProgramada(List<ONE_LineaPlanificacion__c> newRecords, Map<Id, ONE_LineaPlanificacion__c> oldMap, Map<Id, ONE_LineaPlanificacion__c> newMap) {

        for (ONE_LineaPlanificacion__c lineaPlanificacion : newRecords) {
            if ((oldMap.get(lineaPlanificacion.Id).ONE_FechaProgramada__c != newMap.get(lineaPlanificacion.Id).ONE_FechaProgramada__c ||
                oldMap.get(lineaPlanificacion.Id).ONE_HoraProgramada__c != newMap.get(lineaPlanificacion.Id).ONE_HoraProgramada__c) &&
                newMap.get(lineaPlanificacion.Id).ONE_FechaProgramada__c != null && newMap.get(lineaPlanificacion.Id).ONE_HoraProgramada__c != null)
            {
                Date fechaProgramadaDate = newMap.get(lineaPlanificacion.Id).ONE_FechaProgramada__c;
                String horaProgramadaString = newMap.get(lineaPlanificacion.Id).ONE_HoraProgramada__c;
                Datetime fechaHoraProgramadaDatetime = Datetime.parse(fechaProgramadaDate.format() + ', ' + horaProgramadaString);
                lineaPlanificacion.ONE_FechaHoraProgramada__c = fechaHoraProgramadaDatetime;
            }
        }
        
    }

    public static void markAsUpdatedByPlanificador(List<ONE_LineaPlanificacion__c> newRecords, Map<Id, ONE_LineaPlanificacion__c> oldMap, Map<Id, ONE_LineaPlanificacion__c> newMap) {

        for (ONE_LineaPlanificacion__c lineaPlanificacion : newRecords) {
            if (oldMap.get(lineaPlanificacion.Id).ONE_Origen__c != newMap.get(lineaPlanificacion.Id).ONE_Origen__c ||
                oldMap.get(lineaPlanificacion.Id).ONE_DireccionOrigen__c != newMap.get(lineaPlanificacion.Id).ONE_DireccionOrigen__c ||
                oldMap.get(lineaPlanificacion.Id).ONE_Destino__c != newMap.get(lineaPlanificacion.Id).ONE_Destino__c ||
                oldMap.get(lineaPlanificacion.Id).ONE_HoraProgramada__c != newMap.get(lineaPlanificacion.Id).ONE_HoraProgramada__c ||
                oldMap.get(lineaPlanificacion.Id).ONE_FechaProgramada__c != newMap.get(lineaPlanificacion.Id).ONE_FechaProgramada__c)
            {
                lineaPlanificacion.ONE_ActualizadoPorPlanificador__c = true;
            }
        }
    }

    public static void updateServicioAndRelatedLineasPlanificacion(Map<Id, ONE_LineaPlanificacion__c> oldMap, Map<Id, ONE_LineaPlanificacion__c> newMap) {

        Map<Id, ONE_Expediente__c> servicioMap = new Map<Id, ONE_Expediente__c>();
        Map<Id, List<ONE_LineaPlanificacion__c>> relatedLineasPlanificacionMap = new Map<Id, List<ONE_LineaPlanificacion__c>>();
        List<ONE_Expediente__c> serviciosToUpdate = new List<ONE_Expediente__c>();
        List<ONE_LineaPlanificacion__c> lineasPlanificacionToUpdate = new List<ONE_LineaPlanificacion__c>();
        Boolean servicioUpdateRequired = false;
        Boolean updateLineaPlanificacionRequired = false;

        for (Id lineaPlanificacionId : newMap.keySet()) {
            ONE_LineaPlanificacion__c lineaPlanificacion = newMap.get(lineaPlanificacionId);
            if (lineaPlanificacion.ONE_Servicio__c != null) {
                servicioMap.put(lineaPlanificacion.ONE_Servicio__c, null);
            }
        }

        for (ONE_Expediente__c servicio : [ SELECT
                                                ONE_Inicio_Ceremonia__c,
                                                ONE_Fin_Ceremonia__c,
                                                ONE_Lugar_Ceremonia__c,
                                                ONE_PersonalCeremonia__c,
                                                ONE_Confirmada_Ceremonia_Externa__c,
                                                ONE_Ceremonia_Inhumacion_Confirmada__c,
                                                ONE_Observaciones_Generales__c,
                                                ONE_Velacion__c,
                                                ONE_Lugar_De_Velacion__c,
                                                ONE_Inicio_Velacion__c,
                                                ONE_Fin_Velacion__c,
                                                ONE_Sala_De_Velacion__c,
                                                Numero_Sala_Velacion_Ext__c,
                                                ONE_Deposito__c,
                                                ONE_Lugar_De_Deposito__c,
                                                ONE_Inicio_Deposito__c,
                                                ONE_Fin_Deposito__c,
                                                ONE_Sala_Deposito__c,
                                                ONE_Licencia_Despachada__c,
                                                ONE_Inicio_Incineracion__c,
                                                ONE_Hora_Destino_Final__c,
                                                ONE_Fecha_Salida_Traslado__c,
                                                ONE_Lugar_Incineracion__c,
                                                ONE_Destino_Final__c,
                                                ONE_Destino_Traslado__c,
                                                ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name
                                            FROM ONE_Expediente__c WHERE Id IN :servicioMap.keySet()])
        {
            servicioMap.put(servicio.Id, servicio);
        }

        for (Id lineaPlanificacionId : newMap.keySet()) {

            servicioUpdateRequired = false;

            ONE_LineaPlanificacion__c lineaPlanificacion = newMap.get(lineaPlanificacionId);

            if (lineaPlanificacion.ONE_Servicio__c != null) {

                ONE_Expediente__c servicio = servicioMap.get(lineaPlanificacion.ONE_Servicio__c);

                if (newMap.get(lineaPlanificacionId).ONE_InicioCeremonia__c != null && newMap.get(lineaPlanificacionId).ONE_InicioCeremonia__c != null && servicio.ONE_Inicio_Ceremonia__c != newMap.get(lineaPlanificacionId).ONE_InicioCeremonia__c) {
                    servicio.ONE_Inicio_Ceremonia__c = newMap.get(lineaPlanificacionId).ONE_InicioCeremonia__c;
                    servicioUpdateRequired = true;
                }

                if (newMap.get(lineaPlanificacionId).ONE_FinCeremonia__c != null && servicio.ONE_Fin_Ceremonia__c != newMap.get(lineaPlanificacionId).ONE_FinCeremonia__c) {
                    servicio.ONE_Fin_Ceremonia__c = newMap.get(lineaPlanificacionId).ONE_FinCeremonia__c;
                    servicioUpdateRequired = true;
                }

                if (newMap.get(lineaPlanificacionId).ONE_LugarCeremonia__c != null && servicio.ONE_Lugar_Ceremonia__c != newMap.get(lineaPlanificacionId).ONE_LugarCeremonia__c) {
                    servicio.ONE_Lugar_Ceremonia__c = newMap.get(lineaPlanificacionId).ONE_LugarCeremonia__c;
                    servicioUpdateRequired = true;
                }

                if (servicio.ONE_PersonalCeremonia__c != newMap.get(lineaPlanificacionId).ONE_PersonalCeremonia__c) {
                    servicio.ONE_PersonalCeremonia__c = newMap.get(lineaPlanificacionId).ONE_PersonalCeremonia__c;
                    servicioUpdateRequired = true;
                }

                if (newMap.get(lineaPlanificacionId).ONE_CeremoniaConfirmada__c != null && servicio.ONE_Confirmada_Ceremonia_Externa__c != newMap.get(lineaPlanificacionId).ONE_CeremoniaConfirmada__c) {
                    servicio.ONE_Confirmada_Ceremonia_Externa__c = newMap.get(lineaPlanificacionId).ONE_CeremoniaConfirmada__c;
                    servicioUpdateRequired = true;
                }

                if (newMap.get(lineaPlanificacionId).ONE_CeremoniaInhumacionConfirmada__c != null && servicio.ONE_Ceremonia_Inhumacion_Confirmada__c != newMap.get(lineaPlanificacionId).ONE_CeremoniaInhumacionConfirmada__c) {
                    servicio.ONE_Ceremonia_Inhumacion_Confirmada__c = newMap.get(lineaPlanificacionId).ONE_CeremoniaInhumacionConfirmada__c;
                    servicioUpdateRequired = true;
                }

                if (newMap.get(lineaPlanificacionId).ONE_ObservacionesGenerales__c != null && servicio.ONE_Observaciones_Generales__c != newMap.get(lineaPlanificacionId).ONE_ObservacionesGenerales__c) {
                    servicio.ONE_Observaciones_Generales__c = newMap.get(lineaPlanificacionId).ONE_ObservacionesGenerales__c;
                    servicioUpdateRequired = true;
                }
                
                if (servicio.ONE_Velacion__c) {
                    if (newMap.get(lineaPlanificacionId).ONE_LugarTanatorio__c != null && servicio.ONE_Lugar_De_Velacion__c != newMap.get(lineaPlanificacionId).ONE_LugarTanatorio__c) {
                        servicio.ONE_Lugar_De_Velacion__c = newMap.get(lineaPlanificacionId).ONE_LugarTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                    if (newMap.get(lineaPlanificacionId).ONE_InicioTanatorio__c != null && servicio.ONE_Inicio_Velacion__c != newMap.get(lineaPlanificacionId).ONE_InicioTanatorio__c) {
                        servicio.ONE_Inicio_Velacion__c = newMap.get(lineaPlanificacionId).ONE_InicioTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                    if (newMap.get(lineaPlanificacionId).ONE_FinTanatorio__c != null && servicio.ONE_Fin_Velacion__c != newMap.get(lineaPlanificacionId).ONE_FinTanatorio__c) {
                        servicio.ONE_Fin_Velacion__c = newMap.get(lineaPlanificacionId).ONE_FinTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                    if (newMap.get(lineaPlanificacionId).ONE_SalaTanatorio__c != null && servicio.ONE_Sala_De_Velacion__c != newMap.get(lineaPlanificacionId).ONE_SalaTanatorio__c) {
                        servicio.ONE_Sala_De_Velacion__c = newMap.get(lineaPlanificacionId).ONE_SalaTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                    if (newMap.get(lineaPlanificacionId).ONE_SalaVelacionExterna__c != null && servicio.Numero_Sala_Velacion_Ext__c != newMap.get(lineaPlanificacionId).ONE_SalaVelacionExterna__c) {
                        servicio.Numero_Sala_Velacion_Ext__c = newMap.get(lineaPlanificacionId).ONE_SalaVelacionExterna__c;
                        servicioUpdateRequired = true;
                    }
                }
                else if (servicio.ONE_Deposito__c) {
                    if (newMap.get(lineaPlanificacionId).ONE_LugarTanatorio__c != null && servicio.ONE_Lugar_De_Deposito__c != newMap.get(lineaPlanificacionId).ONE_LugarTanatorio__c) {
                        servicio.ONE_Lugar_De_Deposito__c = newMap.get(lineaPlanificacionId).ONE_LugarTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                    if (newMap.get(lineaPlanificacionId).ONE_InicioTanatorio__c != null && servicio.ONE_Inicio_Deposito__c != newMap.get(lineaPlanificacionId).ONE_InicioTanatorio__c) {
                        servicio.ONE_Inicio_Deposito__c = newMap.get(lineaPlanificacionId).ONE_InicioTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                    if (newMap.get(lineaPlanificacionId).ONE_FinTanatorio__c != null && servicio.ONE_Fin_Deposito__c != newMap.get(lineaPlanificacionId).ONE_FinTanatorio__c) {
                        servicio.ONE_Fin_Deposito__c = newMap.get(lineaPlanificacionId).ONE_FinTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                    if (newMap.get(lineaPlanificacionId).ONE_SalaTanatorio__c != null && servicio.ONE_Sala_Deposito__c != newMap.get(lineaPlanificacionId).ONE_SalaTanatorio__c) {
                        servicio.ONE_Sala_Deposito__c = newMap.get(lineaPlanificacionId).ONE_SalaTanatorio__c;
                        servicioUpdateRequired = true;
                    }
                }

                if (newMap.get(lineaPlanificacionId).ONE_LicenciaEnterramiento__c != null && servicio.ONE_Licencia_Despachada__c != newMap.get(lineaPlanificacionId).ONE_LicenciaEnterramiento__c) {
                    servicio.ONE_Licencia_Despachada__c = newMap.get(lineaPlanificacionId).ONE_LicenciaEnterramiento__c;
                    servicioUpdateRequired = true;
                }

                if (oldMap.get(lineaPlanificacionId).ONE_LugarDestinoFinal__c != newMap.get(lineaPlanificacionId).ONE_LugarDestinoFinal__c) {
                    if (servicio.ONE_Inicio_Incineracion__c == null && servicio.ONE_Hora_Destino_Final__c == null && servicio.ONE_Fecha_Salida_Traslado__c == null) {
                        newMap.get(lineaPlanificacionId).addError('ONE_LugarDestinoFinal__c', 'Para poder modificar este campo el servicio debe incluir incineración, cementerio o traslado.');
                    }
                    else {
                        Datetime minimumDate = getMinimumDate(new List<DateTime>{servicio.ONE_Inicio_Incineracion__c, servicio.ONE_Hora_Destino_Final__c, servicio.ONE_Fecha_Salida_Traslado__c});
                        if (servicio.ONE_Inicio_Incineracion__c == minimumDate) {
                            servicio.ONE_Lugar_Incineracion__c = newMap.get(lineaPlanificacionId).ONE_LugarDestinoFinal__c;
                            servicioUpdateRequired = true;
                        }
                        else if (servicio.ONE_Hora_Destino_Final__c == minimumDate) {
                            servicio.ONE_Destino_Final__c = newMap.get(lineaPlanificacionId).ONE_LugarDestinoFinal__c;
                            servicioUpdateRequired = true;
                        }
                        else if (servicio.ONE_Fecha_Salida_Traslado__c == minimumDate) {
                            servicio.ONE_Destino_Traslado__c = newMap.get(lineaPlanificacionId).ONE_LugarDestinoFinal__c;
                            servicioUpdateRequired = true;
                        }
                    }
                }

                if (oldMap.get(lineaPlanificacionId).ONE_FechaHoraDestinoFinal__c != newMap.get(lineaPlanificacionId).ONE_FechaHoraDestinoFinal__c) {
                    if (servicio.ONE_Inicio_Incineracion__c == null && servicio.ONE_Hora_Destino_Final__c == null && servicio.ONE_Fecha_Salida_Traslado__c == null) {
                        newMap.get(lineaPlanificacionId).addError('ONE_FechaHoraDestinoFinal__c', 'Para poder modificar este campo el servicio debe incluir incineración, cementerio o traslado.');
                    }
                    else {
                        Datetime minimumDate = getMinimumDate(new List<DateTime>{servicio.ONE_Inicio_Incineracion__c, servicio.ONE_Hora_Destino_Final__c, servicio.ONE_Fecha_Salida_Traslado__c});
                        if (servicio.ONE_Inicio_Incineracion__c == minimumDate) {
                            servicio.ONE_Inicio_Incineracion__c = newMap.get(lineaPlanificacionId).ONE_FechaHoraDestinoFinal__c;
                            servicioUpdateRequired = true;
                        }
                        else if (servicio.ONE_Hora_Destino_Final__c == minimumDate) {
                            servicio.ONE_Hora_Destino_Final__c = newMap.get(lineaPlanificacionId).ONE_FechaHoraDestinoFinal__c;
                            servicioUpdateRequired = true;
                        }
                        else if (servicio.ONE_Fecha_Salida_Traslado__c == minimumDate) {
                            servicio.ONE_Fecha_Salida_Traslado__c = newMap.get(lineaPlanificacionId).ONE_FechaHoraDestinoFinal__c;
                            servicioUpdateRequired = true;
                        }
                    }
                }

                if (servicio.ONE_Inicio_Incineracion__c != newMap.get(lineaPlanificacionId).ONE_FechaHoraIncineracion__c && newMap.get(lineaPlanificacionId).ONE_FechaHoraIncineracion__c != null) {
                    servicio.ONE_Inicio_Incineracion__c = newMap.get(lineaPlanificacionId).ONE_FechaHoraIncineracion__c;
                    servicioUpdateRequired = true;
                }

                if (servicio.ONE_Hora_Destino_Final__c != newMap.get(lineaPlanificacionId).ONE_FechaHoraInhumacion__c && newMap.get(lineaPlanificacionId).ONE_FechaHoraInhumacion__c != null) {
                    servicio.ONE_Hora_Destino_Final__c = newMap.get(lineaPlanificacionId).ONE_FechaHoraInhumacion__c;
                    servicioUpdateRequired = true;
                }

                if (servicioUpdateRequired) {
                    serviciosToUpdate.add(servicio);
                }
            }
        }

        update serviciosToUpdate;

        Map<Id, ONE_Expediente__c> updatedServicioMap = new Map<Id, ONE_Expediente__c>(serviciosToUpdate);

        for (ONE_LineaPlanificacion__c relatedLineaPlanificacion : [    SELECT
                                                                            ONE_Servicio__c,
                                                                            ONE_InicioCeremonia__c,
                                                                            ONE_FinCeremonia__c,
                                                                            ONE_LugarCeremonia__c,
                                                                            ONE_PersonalCeremonia__c,
                                                                            ONE_CeremoniaConfirmada__c,
                                                                            ONE_CeremoniaInhumacionConfirmada__c,
                                                                            ONE_ObservacionesGenerales__c,
                                                                            ONE_LugarTanatorio__c,
                                                                            ONE_InicioTanatorio__c,
                                                                            ONE_FinTanatorio__c,
                                                                            ONE_LicenciaEnterramiento__c,
                                                                            ONE_FechaHoraDestinoFinal__c,
                                                                            ONE_FechaHoraInhumacion__c,
                                                                            ONE_FechaHoraIncineracion__c,
                                                                            ONE_LugarDestinoFinal__c, 
                                                                            ONE_Zona_Operativa_Centro__c,
                                                                   			ONE_Observaciones_Exhumacion__c,
                        													ONE_Municipio_Exhumaci_n__c, 
                                                                    		ONE_Localizaci_n_Unidad_Exhumaci_n__c , 
                                                                    		ONE_Unidad_de_Exhumacion__c,
                                                                    		Inicio_exhumaci_n__c,
                                                                    		ONE_Fin_Exhumaci_n__c,
                                                                    		ONE_C_digo_postal_Exhumaci_n__c,
                                                                    		ONE_Presente_en_Exhumaci_n__c,
                                                                    		ONE_Destrucci_n_de_la_L_pida__c,
                                                                    		ONE_Restos_de__c,
                                                                    		ONE_Finalidad_Exhumaci_n__c,
                                                                    		ONE_Destino_Ornamentaci_n__c
                                                                    		

                                                                        FROM ONE_LineaPlanificacion__c
                                                                        WHERE
                                                                            ONE_Servicio__c IN :updatedServicioMap.keySet() AND
                                                                            Id NOT IN :newMap.keySet()])
        {
            if (relatedLineaPlanificacion.ONE_Zona_Operativa_Centro__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Centro_Del_Expediente__r?.ONE_Lugar__r?.ONE_Lugar_Superior__r?.Name) {
                relatedLineaPlanificacion.ONE_Zona_Operativa_Centro__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Centro_Del_Expediente__r?.ONE_Lugar__r?.ONE_Lugar_Superior__r?.Name;
                updateLineaPlanificacionRequired = true;
            }
            
            if (relatedLineaPlanificacion.ONE_InicioCeremonia__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c) {
                relatedLineaPlanificacion.ONE_InicioCeremonia__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Ceremonia__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_FinCeremonia__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Fin_Ceremonia__c) {
                relatedLineaPlanificacion.ONE_FinCeremonia__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Fin_Ceremonia__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_LugarCeremonia__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c) {
                relatedLineaPlanificacion.ONE_LugarCeremonia__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Lugar_Ceremonia__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_PersonalCeremonia__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_PersonalCeremonia__c) {
                relatedLineaPlanificacion.ONE_PersonalCeremonia__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_PersonalCeremonia__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_CeremoniaConfirmada__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Confirmada_Ceremonia_Externa__c) {
                relatedLineaPlanificacion.ONE_CeremoniaConfirmada__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Confirmada_Ceremonia_Externa__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_CeremoniaInhumacionConfirmada__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Ceremonia_Inhumacion_Confirmada__c) {
                relatedLineaPlanificacion.ONE_CeremoniaInhumacionConfirmada__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Ceremonia_Inhumacion_Confirmada__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_ObservacionesGenerales__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Observaciones_Generales__c) {
                relatedLineaPlanificacion.ONE_ObservacionesGenerales__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Observaciones_Generales__c;
                updateLineaPlanificacionRequired = true;
            }

            if (updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Velacion__c) {
                if (relatedLineaPlanificacion.ONE_LugarTanatorio__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Velacion__c) {
                    relatedLineaPlanificacion.ONE_LugarTanatorio__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Velacion__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (relatedLineaPlanificacion.ONE_InicioTanatorio__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Velacion__c) {
                    relatedLineaPlanificacion.ONE_InicioTanatorio__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Velacion__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (relatedLineaPlanificacion.ONE_FinTanatorio__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Fin_Velacion__c) {
                    relatedLineaPlanificacion.ONE_FinTanatorio__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Fin_Velacion__c;
                    updateLineaPlanificacionRequired = true;
                }
            }
            else if (updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Deposito__c) {
                if (relatedLineaPlanificacion.ONE_LugarTanatorio__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Deposito__c) {
                    relatedLineaPlanificacion.ONE_LugarTanatorio__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Lugar_De_Deposito__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (relatedLineaPlanificacion.ONE_InicioTanatorio__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Deposito__c) {
                    relatedLineaPlanificacion.ONE_InicioTanatorio__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Deposito__c;
                    updateLineaPlanificacionRequired = true;
                }
                if (relatedLineaPlanificacion.ONE_FinTanatorio__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Fin_Deposito__c) {
                    relatedLineaPlanificacion.ONE_FinTanatorio__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Fin_Deposito__c;
                    updateLineaPlanificacionRequired = true;
                }
            }

            if (relatedLineaPlanificacion.ONE_LicenciaEnterramiento__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Licencia_Despachada__c) {
                relatedLineaPlanificacion.ONE_LicenciaEnterramiento__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Licencia_Despachada__c;
                updateLineaPlanificacionRequired = true;
            }

            Datetime minimumDate = getMinimumDate(new List<DateTime>{updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c, updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c, updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Fecha_Salida_Traslado__c});
            if (updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c == minimumDate) {
                relatedLineaPlanificacion.ONE_FechaHoraDestinoFinal__c = updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Inicio_Incineracion__c;
                relatedLineaPlanificacion.ONE_LugarDestinoFinal__c = updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Lugar_Incineracion__c;
                updateLineaPlanificacionRequired = true;
            }
            else if (updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c == minimumDate) {
                relatedLineaPlanificacion.ONE_FechaHoraDestinoFinal__c = updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Hora_Destino_Final__c;
                relatedLineaPlanificacion.ONE_LugarDestinoFinal__c = updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Final__c;
                updateLineaPlanificacionRequired = true;
            }
            else if (updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Fecha_Salida_Traslado__c == minimumDate) {
                relatedLineaPlanificacion.ONE_FechaHoraDestinoFinal__c = updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Fecha_Salida_Traslado__c;
                relatedLineaPlanificacion.ONE_LugarDestinoFinal__c = updatedServicioMap?.get(relatedLineaPlanificacion.ONE_Servicio__c)?.ONE_Destino_Traslado__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_FechaHoraIncineracion__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c) {
                relatedLineaPlanificacion.ONE_FechaHoraIncineracion__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Inicio_Incineracion__c;
                updateLineaPlanificacionRequired = true;
            }

            if (relatedLineaPlanificacion.ONE_FechaHoraInhumacion__c != updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c) {
                relatedLineaPlanificacion.ONE_FechaHoraInhumacion__c = updatedServicioMap.get(relatedLineaPlanificacion.ONE_Servicio__c).ONE_Hora_Destino_Final__c;
                updateLineaPlanificacionRequired = true;
            }

            if (updateLineaPlanificacionRequired) {
                lineasPlanificacionToUpdate.add(relatedLineaPlanificacion);
            }
        }

        ONE_LineaPlanificacionTriggerHandler.isUpdatingRelatedLineasPlanificacion = true;
        update lineasPlanificacionToUpdate;
        ONE_LineaPlanificacionTriggerHandler.isUpdatingRelatedLineasPlanificacion = false;
    }

    public static void cancelTasks(Map<id, ONE_LineaPlanificacion__c> oldMap) {

        List<ONE_Tarea__c> tasksToUpdate = new List<ONE_Tarea__c>();

        for (Id lineaPlanificacionId : oldMap.keySet()) {
            ONE_LineaPlanificacion__c deletedRecord = oldMap.get(lineaPlanificacionId);

            if (deletedRecord.ONE_TareaConduccion1__c != null) {
                ONE_Tarea__c task1 = new ONE_Tarea__c(Id = deletedRecord.ONE_TareaConduccion1__c);
                task1.ONE_Estado__c = 'Cancelado';
                tasksToUpdate.add(task1);
            }
            if (deletedRecord.ONE_TareaConduccion2__c != null) {
                ONE_Tarea__c task2 = new ONE_Tarea__c(Id = deletedRecord.ONE_TareaConduccion2__c);
                task2.ONE_Estado__c = 'Cancelado';
                tasksToUpdate.add(task2);
            }
            if (deletedRecord.ONE_TareaConduccion3__c != null) {
                ONE_Tarea__c task3 = new ONE_Tarea__c(Id = deletedRecord.ONE_TareaConduccion3__c);
                task3.ONE_Estado__c = 'Cancelado';
                tasksToUpdate.add(task3);
            }
        }

        update tasksToUpdate;
    }

    public static Datetime getMinimumDate(List<Datetime> dates) {

        Datetime minimumDate = null;
        List<Datetime> dateList = new List<DateTime>();

        for (Datetime dateItem : dates) {
            if (dateItem != null) {
                dateList.add(dateItem);
            }
        }

        if(!dateList.isEmpty()) {
            dateList.sort();
            minimumDate = dateList.get(0);
        }
        
        return minimumDate;
    }

    public static String getDestinoIntermedioLibre(ONE_Expediente__c servicio) {

        String destinoIntermedioLibre = '';
        String nombreLugarCeremonia = servicio?.ONE_Lugar_Ceremonia__r?.Name != null ? servicio.ONE_Lugar_Ceremonia__r.Name : '';
        String salaCeremoniaInterna = servicio?.ONE_Sala_Ceremonia__r?.Name != null ? servicio.ONE_Sala_Ceremonia__r.Name : '';
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
            destinoIntermedioLibre = nombreLugarCeremonia + ' - ' + municipioCeremonia;
        }
                
        return destinoIntermedioLibre;
    }

    
}
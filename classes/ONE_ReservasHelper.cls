/**
 * Created by mbujak003 on 01.12.2020.
 * Modified by Pau Martin on 08.09.2023
 */

public with sharing class ONE_ReservasHelper {

    private static Boolean wasWarned = false;
    private static Boolean isSFB = false;
    private static Boolean isCentroMemora = false;
    private static Set<String> profilesToSkip = new Set<String>{
            ONE_CommonConstants.PROFILE_SYSADMIN,
            ONE_CommonConstants.PROFILE_SYSADMIN_ES,
            ONE_CommonConstants.PROFILE_POLIVALENTE,
            ONE_CommonConstants.PROFILE_PLANIFICADOR
    };
    
    private static Set<String> asesorProfilesToSkip = new Set<String>{
            ONE_CommonConstants.PROFILE_ASESOR,
            ONE_CommonConstants.PROFILE_ASESOR_FACTURA
    };    

    /**
     * Checks whether the Room for new reservation is available (Horarios)
     *
     * @param newRecords Reservations list.
     */
    
    public static void validateHorario(List<ONE_Reservas__c> newRecords) {
        Boolean error = false;
        for(ONE_Reservas__c reserva : newRecords) {
            if (reserva.ONE_Cuenta_Sitio_De_La_Reserva__c != null) {
                Account acc = [SELECT Id, Name, RecordTypeId,  RecordType.DeveloperName from Account where Id = :reserva.ONE_Cuenta_Sitio_De_La_Reserva__c];

                if (acc.RecordType.DeveloperName == 'ONE_Centro_Memora') isCentroMemora = true;
                else isCentroMemora = false;

                if (reserva.ONE_Sala__c == null && isCentroMemora) {
                    error = true;
                    reserva.addError ('NO ES POSIBLE REALIZAR ESTA RESERVA SI NO SE INSERTA UNA SALA DONDE SE VAYA A REALIZAR EL MOMENTO', false);
                    break;
                }
            }
            else {
                List<ONE_Recursos_Internos__c> sala = [SELECT Id, Name, ONE_Centro__c, ONE_Centro__r.RecordType.DeveloperName, ONE_Centro__r.ONE_Cementiris_De_Barcelona__c from ONE_Recursos_Internos__c WHERE Id=:reserva.ONE_Sala__c LIMIT 1];
                if (sala.size() > 0) {
                    if (sala[0].ONE_Centro__r.RecordType.DeveloperName == 'ONE_Centro_Memora') isCentroMemora = true;
                    else isCentroMemora = false;
                }
                else {
                    error = true;
                    reserva.addError ('NO SE PUEDE REALIZAR UNA RESERVA SI NO RELLENAMOS EL LUGAR O LA SALA');
                }
            }
        }

        if (isCentroMemora && !error) {
            ONE_Recursos_Internos__c sala = [SELECT Id, Name, ONE_Centro__c, ONE_Centro__r.ONE_Cementiris_De_Barcelona__c from ONE_Recursos_Internos__c 
                WHERE Id=:newRecords[0].ONE_Sala__c];
    
            for(ONE_Reservas__c reserva : newRecords) {
                if (sala.ONE_Centro__r.ONE_Cementiris_De_Barcelona__c == true) {
                    isSFB = true;
                }
                else {
                    isSFB = false;
                }
                if ((reserva.ONE_Momento_Al_Que_Aplica__c == 'Velación' && (reserva.ONE_Fecha_Fin__c == null || reserva.ONE_Fecha_Inicio__c == null)) 
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Depósito' && (reserva.ONE_Fecha_Fin__c == null || reserva.ONE_Fecha_Inicio__c == null))
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Despedida' && (reserva.ONE_Fecha_Fin__c == null || reserva.ONE_Fecha_Inicio__c == null))
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Ceremonia' && (reserva.ONE_Fecha_Inicio__c == null))
                || (reserva.ONE_Momento_Al_Que_Aplica__c == 'Cremación' && (reserva.ONE_Fecha_Inicio__c == null)))
                {
                    error = true;
                    reserva.addError ('NO ES POSIBLE REALIZAR ESTA RESERVA SI NO SE INSERTA UNA FECHA DE INICIO O DE FIN DEL MOMENTO', false);
                }
                
            }
        }
        /*
        if (isSFB) {
            Map<Id, ONE_Reservas__c> salaId2NewReserva = new Map<Id, ONE_Reservas__c>();
            Map<Id, List<ONE_Horario__c>> salaId2Horarios = new Map<Id, List<ONE_Horario__c>>();
            Boolean wasUserWarned = false;
            for(ONE_Reservas__c reserva : newRecords) {
                salaId2NewReserva.put(reserva.ONE_Sala__c, reserva);
                wasUserWarned = wasUserWarned(reserva);
            }
            system.debug('salaId2NewReserva: ' + salaId2NewReserva);
            Map<String, Set<Date>> salaId2SpecialDate = new Map<String, Set<Date>>();
    
            salaId2Horarios = buildSalaId2Horarios(salaId2NewReserva.keySet());
            system.debug('salaId2Horarios: ' + salaId2Horarios);
            for(Id salaId : salaId2Horarios.keySet()) {
                for(ONE_Horario__c horario : salaId2Horarios.get(salaId)) {
                    if(horario.ONE_Fecha_Excepcional__c != null) {
                        if(salaId2SpecialDate.containsKey(salaId)) {
                            salaId2SpecialDate.get(salaId).add(horario.ONE_Fecha_Excepcional__c);
                        } else {
                            salaId2SpecialDate.put(salaId, new Set<Date>{ horario.ONE_Fecha_Excepcional__c });
                        }
                    }
                }
    
                ONE_Reservas__c tempReservas = salaId2NewReserva.get(salaId);
                Boolean isInSchedule = salaId2Horarios.get(salaId).isEmpty() ? true : false;
                Boolean specialDay = false;
                for(ONE_Horario__c horario : salaId2Horarios.get(salaId)) {
                    Integer dayNumber = ONE_CommonUtils.dayNumber(tempReservas.ONE_Fecha_Inicio__c.date());
                    specialDay = salaId2SpecialDate.containsKey(salaId) && salaId2SpecialDate.get(salaId).contains(tempReservas.ONE_Fecha_Inicio__c.date());
                    System.debug('special day: ' + specialDay + 'dayNumber: '+ dayNumber);
                    if(specialDay && horario.ONE_Fecha_Excepcional__c != null ||
                            !specialDay && horario.ONE_Lunes__c && dayNumber == 1 ||
                            !specialDay && horario.ONE_Martes__c && dayNumber == 2 ||
                            !specialDay && horario.ONE_Miercoles__c && dayNumber == 3 ||
                            !specialDay && horario.ONE_Jueves__c && dayNumber == 4 ||
                            !specialDay && horario.ONE_Viernes__c && dayNumber == 5 ||
                            !specialDay && horario.ONE_Sabado__c && dayNumber == 6 ||
                            !specialDay && horario.ONE_Domingo__c && dayNumber == 0
                            ) {
                        Datetime startDate = Datetime.newInstance(tempReservas.ONE_Fecha_Inicio__c.date(), horario.ONE_Hora_De_Inicio__c);
                        Datetime endDate = Datetime.newInstance(tempReservas.ONE_Fecha_Fin__c.date(), horario.ONE_Hora_De_Fin__c);
    
                        isInSchedule = tempReservas.ONE_Fecha_Inicio__c >= startDate && tempReservas.ONE_Fecha_Fin__c == endDate;
    
                        if(isInSchedule) {
                            break;
                        }
                    } else {
                        isInSchedule = false;
                    }
                }
    
                if(!isInSchedule && (!skipValidation(wasUserWarned))) {
                    if(userPrivilaged()) {
                        //tempReservas.addError('NO ES POSIBLE MODIFICAR LA FECHA DE INICIO O FIN PARA SALAS SFB QUE DISPONEN DE HORARIO PREDEFINIDO', false);
                    } else {
                        //tempReservas.addError('NO ES POSIBLE MODIFICAR LA FECHA DE INICIO O FIN PARA SALAS SFB QUE DISPONEN DE HORARIO PREDEFINIDO', false);
                    }
                }
            }
        }*/
        
    }
	
    public static void validateDisponibilidad(List<ONE_Reservas__c> newRecords) {
        Set<Id> salaIds = new Set<Id>();
        Boolean wasUserWarned = false;
        
        try {
            for(ONE_Reservas__c reserva : newRecords) {
                salaIds.add(reserva.ONE_Sala__c);
                wasUserWarned = wasUserWarned(reserva);
                
                //comprueba que no hay más de una reserva de un momento concreto
                AggregateResult[] countReservas = [
                    SELECT COUNT(Id)
                    FROM ONE_Reservas__c
                    WHERE ONE_Momento_Al_Que_Aplica__c = :reserva.ONE_Momento_Al_Que_Aplica__c
                    AND ONE_Expediente__c = :reserva.ONE_Expediente__c
                    AND ONE_Momento_Al_Que_Aplica__c != null
                ];

                Integer counter = Integer.valueOf(countReservas[0].get('expr0'));
                if ((reserva.Id != null && counter != 1 && reserva.ONE_Expediente__c != null && reserva.ONE_Tipo_De_Reserva__c == 'Reserva')
                || (reserva.Id == null && counter != 0 && reserva.ONE_Expediente__c != null && reserva.ONE_Tipo_De_Reserva__c == 'Reserva')){
                    reserva.addError('NO ES POSIBLE REALIZAR ESTA OPERACIÓN. YA EXISTE UNA RESERVA PARA EL MOMENTO ' + reserva.ONE_Momento_Al_Que_Aplica__c + ' EN ESTE SERVICIO. POR FAVOR, MODIFIQUE LA RESERVA EXISTENTE');
                }
            }
    
            Datetime last3days = DateTime.now().addDays(-3);
    
            List<ONE_Reservas__c> allReservas = [
                    SELECT Id, ONE_Sala__c, ONE_Fecha_Inicio__c, ONE_Fecha_Fin__c, ONE_Expediente__c
                    FROM ONE_Reservas__c
                    WHERE ONE_Sala__c IN: salaIds
                    AND ONE_Fecha_Inicio__c > :last3days
                    AND Id NOT IN: newRecords
            ];
    
           
    
    
            for (ONE_Reservas__c newReserva : newRecords) {
                for (ONE_Reservas__c otherReservation : allReservas) {
                    if (isNewReservationInBetweenExistingOne(newReserva, otherReservation) && !skipValidation(wasWarned)) {

                        newReserva.ONE_ManualRecordChangeIndicator__c = '#%$#';
                        wasUserWarned = true;
                        newReserva.addError(userPrivilaged() ? 'NO ES POSIBLE REALIZAR ESTA OPERACIÓN PORQUE YA EXISTE UNA RESERVA EN EL SLOT INDICADO. PRUEBE CON OTRA FECHA Y HORA. EN CASO DE REQUERIR UN SOLAPAMIENTO DE RESERVAS, VAYA AL BOTÓN DE GESTIÓN DE SALAS Y FINALIZE SU RESERVA. SI YA SE ENCUENTRA EN ESTE, PULSE DE NUEVO GUARDAR.' : 'NO ES POSIBLE REALIZAR ESTA OPERACIÓN PORQUE YA EXISTE UNA RESERVA EN EL SLOT INDICADO. PRUEBE CON OTRA FECHA Y HORA', false);
                        break;
                    }
                    else {
                        newReserva.ONE_ManualRecordChangeIndicator__c = '';
                    }
                }
                
            }
        }catch (Exception e) {
            //newRecords[0].addError('NO ES POSIBLE REALIZAR ESTA OPERACIÓN. YA EXISTE UNA RESERVA PARA EL MOMENTO ' + newRecords[0].ONE_Momento_Al_Que_Aplica__c + ' EN ESTE SERVICIO. POR FAVOR, MODIFIQUE LA RESERVA EXISTENTE');
        }

        
    }
    
    static Boolean isNewReservationInBetweenExistingOne(ONE_Reservas__c newReservation, ONE_Reservas__c existingReservation) {
        return newReservation.ONE_Fecha_Inicio__c > existingReservation.ONE_Fecha_Inicio__c &&
                newReservation.ONE_Fecha_Inicio__c < existingReservation.ONE_Fecha_Fin__c &&
                newReservation.ONE_Expediente__c != existingReservation.ONE_Expediente__c &&
                !isReservaCeremoniaSFB(newReservation) &&
                newReservation.ONE_Momento_Al_Que_Aplica__c != 'Depósito';
    }

    static Boolean isReservaCeremoniaSFB (ONE_Reservas__c newReserva) {
        return newReserva.ONE_Momento_Al_Que_Aplica__c == 'Ceremonia' && isSFB;
    }

    /**
     * Checks whether the Room for new reservation is available (Overlapping existing reservations)
     *
     * @param newRecords Reservations list.
     */
    public static void validateOverlappingReservas(List<ONE_Reservas__c> newRecords, Map<Id, ONE_Reservas__c> oldMap) {
        try {
            Set<Id> salaIds = new Set<Id>();
            Map<Id, ONE_Reservas__c> reservasMap =new Map<id, ONE_Reservas__c>();
            Boolean wasUserWarned = false;

            for(ONE_Reservas__c reserva : newRecords) {
                salaIds.add(reserva.ONE_Sala__c);
                System.debug('userWarned: ' + wasWarned);
                wasUserWarned = wasUserWarned(reserva);
            }

            Map<Id, ONE_Reservas__c> someMap = new Map<Id, ONE_Reservas__c>();
            if(oldMap != null) {
                someMap.putAll(oldMap);
                reservasMap =new Map<id, ONE_Reservas__c>([SELECT Id, ONE_Sala__c, ONE_Fecha_Inicio__c, ONE_Fecha_Fin__c
                    FROM ONE_Reservas__c
                    WHERE ONE_Sala__c IN: salaIds
                    AND ONE_Fecha_Fin__c >= TODAY
                    AND Id NOT IN: someMap.keySet()]);
            }
            else {
                reservasMap = new Map<id, ONE_Reservas__c>([SELECT Id, ONE_Sala__c, ONE_Fecha_Inicio__c, ONE_Fecha_Fin__c
                FROM ONE_Reservas__c
                WHERE ONE_Sala__c IN: salaIds
                AND ONE_Fecha_Fin__c >= TODAY
                AND Id NOT IN: newRecords]);
        
            }
        
            //mira todas las reservas existentes posteriores o iguales a TODAY
            for(ONE_Reservas__c oldReserva : reservasMap.values()) {
                for(ONE_Reservas__c newReserva : newRecords) {
                    if(newReserva.ONE_Sala__c == oldReserva.ONE_Sala__c) {
                        if((newReserva.ONE_Fecha_Inicio__c < oldReserva.ONE_Fecha_Inicio__c && newReserva.ONE_Fecha_Fin__c > oldReserva.ONE_Fecha_Inicio__c)
                        || (newReserva.ONE_Fecha_Inicio__c < oldReserva.ONE_Fecha_Inicio__c && newReserva.ONE_Fecha_Fin__c > oldReserva.ONE_Fecha_Fin__c)
                        || (newReserva.ONE_Fecha_Inicio__c > oldReserva.ONE_Fecha_Inicio__c && newReserva.ONE_Fecha_Fin__c < oldReserva.ONE_Fecha_Fin__c)
                        || (newReserva.ONE_Fecha_Inicio__c < oldReserva.ONE_Fecha_Inicio__c && newReserva.ONE_Fecha_Fin__c > oldReserva.ONE_Fecha_Inicio__c)
                        || (newReserva.ONE_Fecha_Inicio__c > oldReserva.ONE_Fecha_Inicio__c && newReserva.ONE_Fecha_Inicio__c < oldReserva.ONE_Fecha_Fin__c)
                        || (newReserva.ONE_Fecha_Inicio__c >= oldReserva.ONE_Fecha_Inicio__c && newReserva.ONE_Fecha_Inicio__c < oldReserva.ONE_Fecha_Fin__c)) {

                            if(!skipValidation(wasUserWarned) && (newReserva.ONE_Tipo_De_Reserva__c == 'Reserva' || !isSFB) && isCentroMemora && newReserva.ONE_Momento_Al_Que_Aplica__c != 'Depósito') {
                                System.debug('no esquiva validation');
                                if(userPrivilaged()) {
                                    System.debug('165');
                                    wasUserWarned = true;
                                    newReserva.addError('YA EXISTE UNA RESERVA EN EL SLOT INDICADO, PRUEBE CON OTRA FECHA Y HORA. EN CASO DE REQUERIR UN SOLAPAMIENTO DE RESERVAS, VAYA AL BOTÓN DE GESTIÓN DE SALAS Y FINALIZE SU RESERVA. SI YA SE ENCUENTRA EN ESTE, PULSE DE NUEVO GUARDAR.', false);
                                } else {
                                    newReserva.addError('YA EXISTE UNA RESERVA EN EL SLOT INDICADO, PRUEBE CON OTRA FECHA Y HORA. INTÉNTELO DE NUEVO CON OTRA FECHA Y HORA',false);
                                }
                            }
                            else {
                                System.debug('Skipvalidation true');  
                                newReserva.ONE_ManualRecordChangeIndicator__c = '';
                            }
                        }
                    }
                }
            }
        }
        catch (Exception e) {
            //newRecords[0].addError('YA EXISTE UNA RESERVA EN EL SLOT INDICADO, PRUEBE CON OTRA FECHA Y HORA. EN CASO DE REQUERIR UN SOLAPAMIENTO DE RESERVAS, VAYA AL BOTÓN DE GESTIÓN DE SALAS Y FINALIZE SU RESERVA. SI YA SE ENCUENTRA EN ESTE, PULSE DE NUEVO GUARDAR.', false);
        }        
        
    }

    /**
     * Maps reservation fields to expedient fields upon reservation creation
     *
     * @param newMap new reservations map.
     
  	*/
    public static void mapFieldsToExpedient(Map<id, ONE_Reservas__c> newMap) {
        List<ONE_Expediente__c> expedientsToUpdate = new List<ONE_Expediente__c>();

        for(Id recId : newMap.keySet()) {
            ONE_Reservas__c newRecord = newMap.get(recId);

            if (isSFB) {
                List<ONE_SlotSala__c> slotSFB = [SELECT Id, ONE_InicioSlot__c, ONE_FinSlot__c, ONE_Sala__c FROM ONE_SlotSala__c WHERE ONE_InicioSlot__c =:newRecord.ONE_Fecha_Inicio__c AND ONE_FinSlot__c = :newRecord.ONE_Fecha_Fin__c AND ONE_Sala__c = :newRecord.ONE_Sala__c LIMIT 1];
                if (slotSFB.size() > 0) {
                    ONE_SlotSala__c slot = new ONE_SlotSala__c(
                        Id = slotSFB[0].Id,
                        ONE_Reserva__c = newRecord.Id,
                        ONE_Observaciones__c = newRecord.ONE_Motivos_Del_Bloqueo__c
                    );
                    update slot;
                }
            }

            if(newRecord.ONE_Expediente__c != null) {
                ONE_Expediente__c expediente = new ONE_Expediente__c(Id = newRecord.ONE_Expediente__c);
                if(newRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_VELACION) {
                    expediente.ONE_Lugar_De_Velacion__c = newRecord.ONE_Cuenta_Sitio_De_La_Reserva__c;
                    expediente.ONE_Sala_De_Velacion__c = newRecord.ONE_Sala__c;
                    expediente.ONE_Inicio_Velacion__c = newRecord.ONE_Fecha_Inicio__c;
                    expediente.ONE_Fin_Velacion__c = newRecord.ONE_Fecha_Fin__c;
                    expediente.ONE_Velacion__c = true;
                } else if(newRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_CEREMONIA) {
                    expediente.ONE_Lugar_ceremonia__c = newRecord.ONE_Cuenta_Sitio_De_La_Reserva__c;
                    expediente.ONE_Sala_ceremonia__c = newRecord.ONE_Sala__c;
                    expediente.ONE_Inicio_ceremonia__c = newRecord.ONE_Fecha_Inicio__c;
                    expediente.ONE_Fin_ceremonia__c = newRecord.ONE_Fecha_Fin__c;
                    expediente.ONE_Ceremonia__c = true;
                } else if(newRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_CREMACION) {
                    expediente.ONE_Lugar_incineracion__c = newRecord.ONE_Cuenta_Sitio_De_La_Reserva__c;
                    expediente.ONE_Horno_incineracion__c = newRecord.ONE_Sala__c;
                    expediente.ONE_Inicio_incineracion__c = newRecord.ONE_Fecha_Inicio__c;
                    expediente.ONE_Fin_incineracion__c = newRecord.ONE_Fecha_Fin__c;
                    expediente.ONE_Incineracion__c = true;
                }/*else if(newRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_CEMENTERIO) {
                    expediente.ONE_Destino_final__c = newRecord.ONE_Cuenta_Sitio_De_La_Reserva__c;
                    expediente.ONE_Hora_destino_final__c = newRecord.ONE_Fecha_Inicio__c;
                    expediente.ONE_Cementerio__c = true;
                } */else if(newRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_DEPOSITO) {
                    expediente.ONE_Lugar_De_Deposito__c = newRecord.ONE_Cuenta_Sitio_De_La_Reserva__c;
                    expediente.ONE_Sala_Deposito__c = newRecord.ONE_Sala__c;
                    expediente.ONE_Inicio_Deposito__c = newRecord.ONE_Fecha_Inicio__c;
                    expediente.ONE_Fin_Deposito__c = newRecord.ONE_Fecha_Fin__c;
                    expediente.ONE_Deposito__c = true;
                } else if(newRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_DESPEDIDA) {
                    expediente.ONE_Lugar_Despedida__c = newRecord.ONE_Cuenta_Sitio_De_La_Reserva__c;
                    expediente.ONE_Sala_Despedida__c = newRecord.ONE_Sala__c;
                    expediente.ONE_Inicio_Despedida__c = newRecord.ONE_Fecha_Inicio__c;
                    expediente.ONE_Fin_Despedida__c = newRecord.ONE_Fecha_Fin__c;
                    expediente.ONE_Despedida__c = true;
                } else {
                    break;
                }
                update expediente;
                //expedientsToUpdate.add(expediente);
                System.debug('Expedients to Update: ' + expedientsToUpdate);
                //update expedientsToUpdate;
                //expedientsToUpdate.remove(0);
            }
        }
        //update expedientsToUpdate;
    }

    /**
     * Maps reservation fields to expedient fields upon reservation creation
     *
     * @param newMap new reservations map.
     */
    
    public static void clearFieldsFromExpedient(Map<id, ONE_Reservas__c> oldMap) {
        List<ONE_Expediente__c> expedientsToUpdate = new List<ONE_Expediente__c>();

        for(Id recId : oldMap.keySet()) {
            ONE_Reservas__c deletedRecord = oldMap.get(recId);
           
            if(deletedRecord.ONE_Expediente__c != null) {
                ONE_Expediente__c expediente = new ONE_Expediente__c(Id = deletedRecord.ONE_Expediente__c);
                if(deletedRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_VELACION) {
                    expediente.ONE_Velacion__c = false;
                    expediente.ONE_Lugar_De_Velacion__c = null;
                    expediente.ONE_Sala_De_Velacion__c = null;
                    expediente.ONE_Inicio_Velacion__c = null;
                    expediente.ONE_Fin_Velacion__c = null;
                } else if(deletedRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_CEREMONIA) {
                    expediente.ONE_Ceremonia__c = false;
                    expediente.ONE_Lugar_ceremonia__c = null;
                    expediente.ONE_Sala_ceremonia__c = null;
                    expediente.ONE_Inicio_ceremonia__c = null;
                    expediente.ONE_Fin_ceremonia__c = null;
                } else if(deletedRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_CREMACION) {
                    expediente.ONE_Incineracion__c = false;
                    expediente.ONE_Lugar_incineracion__c = null;
                    expediente.ONE_Horno_incineracion__c = null;
                    expediente.ONE_Inicio_incineracion__c = null;
                    expediente.ONE_Fin_incineracion__c = null;
                }/*else if(deletedRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_CEMENTERIO) {
                    expediente.ONE_Cementerio__c = false; 
                    expediente.ONE_Destino_final__c = null;
                    expediente.ONE_Hora_destino_final__c = null;
                } */else if(deletedRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_DEPOSITO) {
                    expediente.ONE_Deposito__c = false;
                    expediente.ONE_Lugar_De_Deposito__c = null;
                    expediente.ONE_Sala_Deposito__c = null;
                    expediente.ONE_Inicio_Deposito__c = null;
                    expediente.ONE_Fin_Deposito__c = null;
                } else if(deletedRecord.ONE_Momento_Al_Que_Aplica__c == ONE_CommonConstants.MOMENTO_DESPEDIDA) {
                    expediente.ONE_Despedida__c = false;
                    expediente.ONE_Lugar_Despedida__c = null;
                    expediente.ONE_Sala_Despedida__c = null;
                    expediente.ONE_Inicio_Despedida__c = null;
                    expediente.ONE_Fin_Despedida__c = null;
                } else {
                    break;
                }
                //expedientsToUpdate.add(expediente);
                update expediente;
                //delete deletedRecord;
            }
        }
        System.debug('Records to delete ' + expedientsToUpdate);
        //update expedientsToUpdate;
        
    }
/*
    private static Map<Id, List<ONE_Horario__c>> buildSalaId2Horarios(Set<Id> salasIds) {
        Map<Id, List<ONE_Horario__c>> salaId2Horarios = new Map<Id, List<ONE_Horario__c>>();
        System.debug('salasIds: ' + salasIds);
        for(ONE_Horario__c horario : ONE_HorarioHelper.fetchHorariosForSalas(salasIds)) {
            System.debug('Imprime salasIds: ' + ONE_HorarioHelper.fetchHorariosForSalas(salasIds));
            for(Id salaId : salasIds) {
                if(!salaId2Horarios.containsKey(salaId)) {
                    salaId2Horarios.put(salaId, new List<ONE_Horario__c> { horario });
                } else {
                    salaId2Horarios.get(salaId).add(horario);
                }
            }
        }
        return salaId2Horarios;
    }
*/
    private static Boolean wasUserWarned(ONE_Reservas__c reservas) {
        if(wasWarned) {
            return wasWarned;
        }
        if(reservas.ONE_ManualRecordChangeIndicator__c == null) {
            return false;
        }
        if(reservas.ONE_ManualRecordChangeIndicator__c.endsWith('#%$#')) {
            wasWarned = true;
            return true;
        } else if(reservas.ONE_ManualRecordChangeIndicator__c.endsWith('#$%#')) {
            return false;
        } else {
            return false;
        }
    }

    public static Boolean userPrivilaged() {
        return profilesToSkip.contains(ONE_CommonUtils.getProfileNameById(UserInfo.getProfileId()));
    }
    
    public static Boolean asesorPrivilege() {
        return asesorProfilesToSkip.contains(ONE_CommonUtils.getProfileNameById(UserInfo.getProfileId()));
    }

    public static Boolean skipValidation(Boolean wasUserWarned) {
        return wasUserWarned && userPrivilaged();
    }

    public static void fixWasWarnedField(List<ONE_Reservas__c> reservas) {
        for(ONE_Reservas__c reserva : reservas) {
            if(reserva.ONE_ManualRecordChangeIndicator__c == null) {
                return;
            }
            if(reserva.ONE_ManualRecordChangeIndicator__c.endsWith('#%$#')) {
                reserva.ONE_ManualRecordChangeIndicator__c = reserva.ONE_ManualRecordChangeIndicator__c.replace('#%$#', '');
            } else if(reserva.ONE_ManualRecordChangeIndicator__c.endsWith('#$%#')) {
                reserva.ONE_ManualRecordChangeIndicator__c = reserva.ONE_ManualRecordChangeIndicator__c.replace('#$%#', '');
            }
        }
    }
}
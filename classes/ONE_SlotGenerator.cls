public with sharing class ONE_SlotGenerator {

    // A partir de un número N, genera los slots para los siguientes N días
    public static List<ONE_SlotSala__c> generateSlotsForNextDays(Integer numberOfDays) {

        List<ONE_SlotSala__c> generatedSlots = new List<ONE_SlotSala__c>();
        Set<Date> dateSet = new Set<Date>();
        Set<Date> datesWithSlots = getDatesWithSlots(Date.today());
        Date dateValue = Date.today();

        for (Integer i = 0; i <= numberOfDays; i++) {
            if (!datesWithSlots.contains(dateValue)) {
                dateSet.add(dateValue);
            }
            dateValue = dateValue.addDays(1);
        }
		FlowInputs input = new FlowInputs();
        generatedSlots = generateSlots(dateSet, input);

        return generatedSlots;
    }

    // A partir de una fecha, genera los slots para esa fecha si todavía no existen
    public static List<ONE_SlotSala__c> generateSlotsByDate(Date startDate) {

        List<ONE_SlotSala__c> generatedSlots = new List<ONE_SlotSala__c>();
        Set<Date> dateSet = new Set<Date>{startDate};
        Set<Date> datesWithSlots = getDatesWithSlots(startDate);
        
        System.debug ('dateSet: ' + dateSet);
        System.debug ('datesWithSlots: ' + datesWithSlots);
        FlowInputs input = new FlowInputs();
        generatedSlots = generateSlots(dateSet, input);

        System.debug('generatedSlots: ' + generatedSlots);

        return generatedSlots;
    }

    // Reprocesa los slots existentes tras crear/modificar un horario, eliminando todos los slots futuros sin reserva y volviendo a generarlos con los horarios vigentes
    @InvocableMethod(label='Reprocesar slots' description='Elimina todos los slots futuros y vuelve a generarlos con los horarios vigentes')
    public static void reprocessSlots(List<FlowInputs> flowInputs) {

        Set<Date> dateSet = getDatesWithSlots(Date.today());
        List<ONE_SlotSala__c> undeletedSlots = deleteSlots();
        System.debug ('flowInputs: ' + flowInputs);

        //AFTER DELETE Festivo
        if (flowInputs[0].action == 'Eliminar') generateSlots(dateSet, flowInputs[0]);
        else { //ESTO SE EJECUTA EN CASO DE QUE HAYAMOS CREADO, MODIFICADO O ELIMINADO Horarios. O cuando SE CREA O SE MODIFICA Festivos.
            FlowInputs input = new FlowInputs();
            generateSlots(dateSet, input);
        }
    }

    // A partir de una fecha de inicio, obtiene todas las fechas para las cuales existen slots posteriores a la fecha de inicio
    private static Set<Date> getDatesWithSlots(Date startDate) {

        Set<Date> datesWithSlots = new Set<Date>();

        for (ONE_SlotSala__c slot : [SELECT Id, ONE_InicioSlot__c, Fecha_fin_slot__c FROM ONE_SlotSala__c WHERE Fecha_fin_slot__c >= :startDate]) {
            datesWithSlots.add(slot.Fecha_fin_slot__c);
        }

        return datesWithSlots;
    }

    // Elimina todos los slots futuros que no tienen reserva
    private static List<ONE_SlotSala__c> deleteSlots() {

        List<ONE_SlotSala__c> undeletedSlots = new List<ONE_SlotSala__c>();
        List<ONE_SlotSala__c> slotsToDelete = new List<ONE_SlotSala__c>();

        for (ONE_SlotSala__c slot : [
            SELECT ONE_Reserva__c
            FROM ONE_SlotSala__c
            WHERE
                Fecha_fin_slot__c >= :Date.today()])
        {
            if (String.isNotBlank(slot.ONE_Reserva__c)) {
                undeletedSlots.add(slot);
            }
            else {
                slotsToDelete.add(slot);
            }
        }
        
        delete slotsToDelete;
        
        return undeletedSlots;
    }

    // A partir de un conjunto de fechas, genera todos los slots para esas fechas
    private static List<ONE_SlotSala__c> generateSlots(Set<Date> dateSet, FlowInputs input) {
        List<ONE_SlotSala__c> slots = new List<ONE_SlotSala__c>();
        Map<Id, List<ONE_Horario__c>> roomSchedulesMap = getRoomSchedules();
        Map<Id, List<ONE_Festivo__c>> roomFreeDaysMap = getRoomFreeDays(input);
        System.debug('dateSet: ' + dateSet);
        System.debug('roomScheduleMap: ' + roomSchedulesMap);
        System.debug('roomFreeDaysMap: ' + roomFreeDaysMap);
        for (Date dateItem : dateSet) {
            Date finDate = dateItem;
            Integer weekdayNumber = getWeekdayNumberFromDate(finDate);
            for (Id salaId : roomSchedulesMap.keySet()) {
                Boolean isFestivo = false;
                List<ONE_Festivo__c> festivos = new List<ONE_Festivo__c>();
                festivos = roomFreeDaysMap.get(salaId);
                List<ONE_Horario__c> roomSchedules = new List<ONE_Horario__c>();
                roomSchedules = roomSchedulesMap.get(salaId);
                System.debug('Room schedules: '+  roomSchedules);
                System.debug('Room Festivosxx: '+  festivos);
                if (festivos != null) {
                    for (ONE_Festivo__c festivo : festivos) {
                        if (festivo.ONE_Fecha_Cierre__c == finDate) { 
                            isFestivo = true;
                            break;
                            System.debug ('slot would not appear in the list');
                        }
                    }
                }
                if (!isFestivo) {
                    for (ONE_Horario__c schedule : roomSchedules) {
                        System.debug('schedule: ' + schedule);
                        Time hourTempIni = schedule.ONE_Hora_De_Inicio__c;
                        Time hourTempFin = schedule.ONE_Hora_De_Fin__c;
                        if (schedule.ONE_Fecha_Excepcional__c == finDate) {
                            ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                ONE_Horario__c = schedule.Id,
                                ONE_Sala__c = schedule.ONE_Sala__c,
                                Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                Hora_inicio_slot__c = hourTempIni,
                                Fecha_fin_slot__c = finDate,
                                Hora_fin_Slot__c = hourTempFin,
                                ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                            );
                            if (hourTempIni != null || hourTempFin != null) {
                                slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                            }
                            slots.add(slot);
                            //break; // siguiente sala
                        }
                        else if (schedule.ONE_Activo__c && schedule.ONE_Hora_De_Inicio__c != null && schedule.ONE_Hora_De_Fin__c != null) {
                            switch on weekdayNumber {
                                when 1 {
                                    if (schedule.ONE_Lunes__c) {
                                        ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                            ONE_Horario__c = schedule.Id,
                                            ONE_Sala__c = schedule.ONE_Sala__c,
                                            Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                            Hora_inicio_slot__c = hourTempIni,
                                            Fecha_fin_slot__c = finDate,
                                            Hora_fin_Slot__c = hourTempFin,
                                            ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                            ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                                        );
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        slots.add(slot);
                                        //break;
                                    }
                                }
                                when 2 {
                                    if (schedule.ONE_Martes__c) {
                                        ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                            ONE_Horario__c = schedule.Id,
                                            ONE_Sala__c = schedule.ONE_Sala__c,
                                            Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                            Hora_inicio_slot__c = hourTempIni,
                                            Fecha_fin_slot__c = finDate,
                                            Hora_fin_Slot__c = hourTempFin,
                                            ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                            ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                                        );
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        slots.add(slot);
                                        //break;
                                    }
                                }
                                when 3 {
                                    if (schedule.ONE_Miercoles__c) {
                                        ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                            ONE_Horario__c = schedule.Id,
                                            ONE_Sala__c = schedule.ONE_Sala__c,
                                            Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                            Hora_inicio_slot__c = hourTempIni,
                                            Fecha_fin_slot__c = finDate,
                                            Hora_fin_Slot__c = hourTempFin,
                                            ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                            ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                                        );
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        slots.add(slot);
                                        //break;
                                    }
                                }
                                when 4 {
                                    if (schedule.ONE_Jueves__c) {
                                        ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                            ONE_Horario__c = schedule.Id,
                                            ONE_Sala__c = schedule.ONE_Sala__c,
                                            Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                            Hora_inicio_slot__c = hourTempIni,
                                            Fecha_fin_slot__c = finDate,
                                            Hora_fin_Slot__c = hourTempFin,
                                            ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                            ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                                        );
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        slots.add(slot);
                                        //break;
                                    }
                                }
                                when 5 {
                                    if (schedule.ONE_Viernes__c) {
                                        ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                            ONE_Horario__c = schedule.Id,
                                            ONE_Sala__c = schedule.ONE_Sala__c,
                                            Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                            Hora_inicio_slot__c = hourTempIni,
                                            Fecha_fin_slot__c = finDate,
                                            Hora_fin_Slot__c = hourTempFin,
                                            ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                            ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                                        );
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        slots.add(slot);
                                        //break;
                                    }
                                }
                                when 6 {
                                    if (schedule.ONE_Sabado__c) {
                                        ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                            ONE_Horario__c = schedule.Id,
                                            ONE_Sala__c = schedule.ONE_Sala__c,
                                            Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                            Hora_inicio_slot__c = hourTempIni,
                                            Fecha_fin_slot__c = finDate,
                                            Hora_fin_Slot__c = hourTempFin,
                                            ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                            ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                                        );
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        slots.add(slot);
                                        //break;
                                    }
                                }
                                when 7 {
                                    if (schedule.ONE_Domingo__c) {
                                        ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                            ONE_Horario__c = schedule.Id,
                                            ONE_Sala__c = schedule.ONE_Sala__c,
                                            Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                            Hora_inicio_slot__c = hourTempIni,
                                            Fecha_fin_slot__c = finDate,
                                            Hora_fin_Slot__c = hourTempFin,
                                            ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                            ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                                        );
                                        if (hourTempIni != null || hourTempFin != null) {
                                            slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                            slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                                        }
                                        slots.add(slot);
                                        //break;
                                    }
                                }
                            }
                            
                        }
                        else if (schedule.ONE_Activo__c && schedule.ONE_Hora_De_Inicio__c == null && schedule.ONE_Hora_De_Fin__c == null) {
                            ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                    ONE_Horario__c = schedule.Id,
                                    ONE_Sala__c = schedule.ONE_Sala__c,
                                    Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                    Hora_inicio_slot__c = hourTempIni,
                                    Fecha_fin_slot__c = finDate,
                                    Hora_fin_Slot__c = hourTempFin
                                    //ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                    //ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                            );
                            if (hourTempIni != null || hourTempFin != null) {
                                slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                            }
                            slots.add(slot);
                            System.debug('creo slot' + slot);
                            //break; // siguiente sala
                        }
                    }
                }
                else {
                    for (ONE_Horario__c schedule : roomSchedules) {
                        System.debug('schedule Festivo: ' + schedule);
                        Time hourTempIni = schedule.ONE_Hora_De_Inicio__c;
                        Time hourTempFin = schedule.ONE_Hora_De_Fin__c;
                        if (schedule.ONE_Fecha_Excepcional__c == finDate) {
                            ONE_SlotSala__c slot = new ONE_SlotSala__c(
                                ONE_Horario__c = schedule.Id,
                                ONE_Sala__c = schedule.ONE_Sala__c,
                                Fecha_inicio_Slot__c = getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c),
                                Hora_inicio_slot__c = hourTempIni,
                                Fecha_fin_slot__c = finDate,
                                Hora_fin_Slot__c = hourTempFin,
                                ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni),
                                ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c)
                            );
                            if (hourTempIni != null || hourTempFin != null) {
                                slot.ONE_InicioSlot__c = Datetime.newInstance(getFechaIniSlotByRoomType(finDate,schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c, schedule.ONE_Mismo_dia__c), hourTempIni);
                                slot.ONE_FinSlot__c = getFinSlotByRoomType(finDate, hourTempFin, schedule.ONE_Sala__r.ONE_Tipo_De_Sala__c);
                            }
                            slots.add(slot);
                            //break; // siguiente sala
                        }
                    }
                }
            }  
        }
        List<ONE_SlotSala__c> slotsMismoHorario = [SELECT Id, ONE_Sala__c, ONE_Reserva__c, Fecha_inicio_Slot__c, Fecha_fin_slot__c, Hora_inicio_slot__c, Hora_fin_Slot__c from ONE_SlotSala__c WHERE Fecha_fin_slot__c >= :Date.today()];
        insert slots;
        System.debug('slots in the generator class: ' + slots);
        
        //revisar slots duplicados
        
        System.debug ('SLOTS CON EL MISMO HORARIO: ' + slotsMismoHorario);
        if (slotsMismoHorario.size() > 0) {
            List<ONE_SlotSala__c> listToRemove = new List<ONE_SlotSala__c>();
            for (ONE_SlotSala__c slot : slots) {
                for (ONE_SlotSala__c slotMismoHorario : slotsMismoHorario) {
                    if (slot.ONE_Sala__c == slotMismoHorario.ONE_Sala__c && slot.Fecha_inicio_Slot__c == slotMismoHorario.Fecha_inicio_Slot__c && slot.Fecha_fin_slot__c == slotMismoHorario.Fecha_fin_slot__c && slot.Hora_inicio_slot__c == slotMismoHorario.Hora_inicio_slot__c && slot.Hora_fin_Slot__c == slotMismoHorario.Hora_fin_Slot__c) {
                        System.debug ('slot will be removed: ' + slot);
                        listToRemove.add(slot);
                    }
                }
            }
            delete listToRemove;
        }
        //return
        return slots;
    }

    // Obtiene todos los horarios existentes por cada sala
    private static Map<Id, List<ONE_Horario__c>> getRoomSchedules() {
        Map<Id, List<ONE_Horario__c>> roomSchedulesMap = new Map<Id, List<ONE_Horario__c>>();
        for (ONE_Horario__c schedule : [ SELECT
                                            Name,
                                            ONE_Sala__c,
                                            ONE_Sala__r.ONE_Tipo_De_Sala__c,
                                            ONE_Mismo_dia__c,
                                            ONE_Fecha_Excepcional__c,
                                            ONE_Hora_De_Inicio__c,
                                            ONE_Hora_De_Fin__c,
                                            ONE_Lunes__c,
                                            ONE_Martes__c,
                                            ONE_Miercoles__c,
                                            ONE_Jueves__c,
                                            ONE_Viernes__c,
                                            ONE_Sabado__c,
                                            ONE_Domingo__c,
                                            ONE_Inicio_De_Vigencia__c,
                                            ONE_Fin_De_Vigencia__c,
                                            ONE_Activo__c
                                        FROM ONE_Horario__c
                                        WHERE
                                            ONE_Sala__c != null
                                        ORDER BY ONE_Fecha_Excepcional__c NULLS LAST
                                        ])
        {
            List<ONE_Horario__c> roomSchedules = roomSchedulesMap.get(schedule.ONE_Sala__c);
            if (roomSchedules == null) {
                roomSchedules = new List<ONE_Horario__c>();
            }
            roomSchedules.add(schedule);
            roomSchedulesMap.put(schedule.ONE_Sala__c, roomSchedules);
        }

        return roomSchedulesMap;
    }

    private static Map<Id, List<ONE_Festivo__c>> getRoomFreeDays(FlowInputs input) {
        Map<Id, List<ONE_Festivo__c>> roomFreeDaysMap = new Map<Id, List<ONE_Festivo__c>>();
        List<ONE_Festivo__c> roomFreeDays = new List<ONE_Festivo__c>();
        if (input.record != null) {
            System.debug ('the all input is: ' + input);
            System.debug ('the 1all input is: ' + input.record);
            System.debug ('the 2all input is: ' + input.record.id);
            Id recordFreeDay = input.record.id;
            for (ONE_Festivo__c festivo : [SELECT Id, Name, ONE_Fecha_Cierre__c, ONE_Sala__c, ONE_Sala__r.Name, ONE_Activo__c, isDeleted from ONE_Festivo__c 
                                        WHERE ONE_Sala__c != null AND Id != :recordFreeDay
                                        ORDER BY ONE_Fecha_Cierre__c NULLS LAST
                                        ])
        	{
                roomFreeDays = roomFreeDaysMap.get(festivo.ONE_Sala__c);
                if (roomFreeDays == null) {
                    roomFreeDays = new List<ONE_Festivo__c>();
                }
                roomFreeDays.add(festivo);
                roomFreeDaysMap.put(festivo.ONE_Sala__c, roomFreeDays);
            }
        }
        else {
            for (ONE_Festivo__c festivo : [SELECT Id, Name, ONE_Fecha_Cierre__c, ONE_Sala__c, ONE_Sala__r.Name, ONE_Activo__c, isDeleted from ONE_Festivo__c 
                                        WHERE ONE_Sala__c != null
                                        ORDER BY ONE_Fecha_Cierre__c NULLS LAST
                                        ])
        	{
                roomFreeDays = roomFreeDaysMap.get(festivo.ONE_Sala__c);
                if (roomFreeDays == null) {
                    roomFreeDays = new List<ONE_Festivo__c>();
                }
                roomFreeDays.add(festivo);
                roomFreeDaysMap.put(festivo.ONE_Sala__c, roomFreeDays);
            }
        }
        return roomFreeDaysMap;
    }

    // A partir de una fecha, obtiene su día de la semana en forma de número
    private static Integer getWeekdayNumberFromDate(Date fromDate) {

        return Integer.valueOf(((Datetime) fromDate).format('u'));
    }
    
    // A partir de una fecha, una hora y un tipo de sala, obtiene la fecha/hora correspondiente al fin de slot
    private static Datetime getFinSlotByRoomType(Date finDate, Time timeValue, String roomType) {
        /*
        switch on roomType {
            when 'Sala Velatorio' {
                return Datetime.newInstance(finDate, timeValue);
            }
            when 'Sala Despedida' {
                return Datetime.newInstance(finDate, timeValue);
            }
        }*/

        return Datetime.newInstance(finDate, timeValue);
    }

    private static Date getFechaIniSlotByRoomType(Date finDate, String roomType, Boolean sameDay) {
        Date startDate = finDate;
        System.debug('startDate -> ' + finDate + ' room Type -> ' + roomType);
        switch on roomType {
            when 'Sala Velatorio' {
                if(!sameDay) return startDate.addDays(-1);
                else return startDate;
            }
            when 'Sala Despedida' {
                return startDate;
            }
            when 'Sala Ceremonia'{
                return startDate;
            }
            when 'Depósito' {
                return startDate;
            }
            when 'Crematorio' {
                return startDate;
            }
        }

        return null;
    }

    public class FlowInputs {
        @InvocableVariable
        public ONE_Festivo__c record;
        @InvocableVariable
        public String action;
    }
}
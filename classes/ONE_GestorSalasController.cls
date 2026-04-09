public with sharing class ONE_GestorSalasController {

    private final static Integer MAX_RESULTS = 2000;
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

    // A partir de un servicio, obtiene el resulta de búsqueda correspondiente al centro del servicio
    @AuraEnabled
    public static List<LookupSearchResult> getCurrentCentro(Id servicioId) {

        ONE_Expediente__c servicio = [SELECT ONE_Centro_Del_Expediente__c, ONE_Centro_Del_Expediente__r.Name, ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Name FROM ONE_Expediente__c WHERE Id = :servicioId];
        //List<Account> centrosSFB = [SELECT Id, Name, ONE_Lugar__r.Name, ONE_Tipo__c FROM Account where ONE_Cementiris_De_Barcelona__c = true AND ONE_Tipo__c = 'Tanatorio' AND ONE_Lugar__r.Name != 'MANRESA' LIMIT 5];
        List<LookupSearchResult> currentCentro = new List<LookupSearchResult>();
        /*
        for (Account centroSFB : centrosSFB) {
            currentCentro.add(new LookupSearchResult(centroSFB.Id, 'Account', 'standard:account', centroSFB.Name, centroSFB.ONE_Lugar__r.Name));
        }*/
        currentCentro.add(new LookupSearchResult(servicio.ONE_Centro_Del_Expediente__c, 'Account', 'standard:account', servicio.ONE_Centro_Del_Expediente__r.Name, servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Name));
        return currentCentro;
    }

    // A partir de un texto, obtiene todos los centros cuyos nombres coincidan con el texto
    @AuraEnabled
    public static List<LookupSearchResult> searchCentros(String searchTerm, List<String> selectedIds) {

        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Account(Id, Name, ONE_Lugar__r.Name WHERE id NOT IN :selectedIds AND RecordType.DeveloperName = 'ONE_Centro_Memora')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitle = account.ONE_Lugar__r.Name == null ? '' : account.ONE_Lugar__r.Name;
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    // A partir de unos filtros (fecha fin, centros y estado slot), obtiene una lista con todos los slots existentes
    @AuraEnabled
    public static List<ONE_SlotSala__c> getSlotList(String finMomentoDate, List<String> centerIdList, String estadoSlot, String tipoHorario) {

        Date finMomentoDateAux = Date.valueOf(finMomentoDate);
        List<ONE_SlotSala__c> slotList = new List<ONE_SlotSala__c>();

        if (String.isBlank(estadoSlot)) {
            if (String.isBlank(tipoHorario)) {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
            else if (tipoHorario == 'Libre') {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_FinSlot__c = null AND 
                            ONE_InicioSlot__c = null 
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
            else if (tipoHorario == 'Predefinido') {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_FinSlot__c != null AND 
                            ONE_InicioSlot__c != null
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
        }
        else if (estadoSlot == 'Disponible') {
            if (String.isBlank(tipoHorario)) {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_Ocupado__c = false
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
            else if (tipoHorario == 'Libre') {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_FinSlot__c = null AND 
                            ONE_InicioSlot__c = null AND 
                            ONE_Ocupado__c = false
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
            else if (tipoHorario == 'Predefinido') {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_FinSlot__c != null AND 
                            ONE_InicioSlot__c != null AND 
                            ONE_Ocupado__c = false
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
        }
        else if (estadoSlot == 'Ocupado') {
            if (String.isBlank(tipoHorario)) {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_Ocupado__c = true
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
            else if (tipoHorario == 'Libre') {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_FinSlot__c = null AND 
                            ONE_InicioSlot__c = null AND 
                            ONE_Ocupado__c = true
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
            else if (tipoHorario == 'Predefinido') {
                slotList = [SELECT
                            Id,
                            ONE_RutaSubruta__c,
                            ONE_Ocupado__c,
                            Fecha_inicio_Slot__c,
                            Hora_inicio_slot__c,
                            ONE_InicioSlot__c,
                            Fecha_fin_slot__c,
                            Hora_fin_Slot__c,
                            ONE_FinSlot__c,
                            ONE_SalaName__c,
                            ONE_TipoServicio__c,
                            ONE_Segmento__c,
                            ONE_TipoSala__c,
                            ONE_Tanatorio__c,
                            ONE_Incineracion__c,
                            ONE_Difunto__c,
                            ONE_FechaDefuncion__c,
                            ONE_DestinoFinal__c,
                            ONE_Fecha_Inicio_Reserva__c,
                            ONE_Fecha_fin_de_reserva__c,
                            ONE_Sala_ceremonia_relacionada__c,
                            ONE_Duraci_n_Ceremonia__c,
                            ONE_Reserva__c,
                            Slot_con_ceremonia__c,
                            ONE_TipoReserva__c,
                            ONE_Servicio__c,
                            ONE_Observaciones__c,
                            ONE_Estado_Slot__c
                        FROM ONE_SlotSala__c
                        WHERE
                            ONE_Sala__r.ONE_Centro__c IN :centerIdList AND
                            Fecha_fin_slot__c = :finMomentoDateAux AND 
                            ONE_FinSlot__c != null AND 
                            ONE_InicioSlot__c != null AND 
                            ONE_Ocupado__c = true 
                            ORDER BY ONE_FinSlot__c NULLS LAST];
            }
        }
        return slotList;
    }

    // A partir de una fecha fin, genera todos los slots correspondientes a esa fecha
    @AuraEnabled
    public static void createSlots(String endDateString) {

        Date endDate = Date.valueOf(endDateString);
        Date startDate = endDate;
        ONE_SlotGenerator.generateSlotsByDate(startDate);
    }

    // A partir de un servicio y un slot, obtiene los campos por defecto de una reserva para ese servicio y ese slot
    @AuraEnabled
    public static ONE_Reservas__c getReservaDefaultValues(Id servicioId, Id slotId) {

        ONE_Reservas__c reservaDefaultValues = new ONE_Reservas__c();

        ONE_SlotSala__c slot = [
            SELECT  Id,
                    ONE_TipoSala__c,
                    Fecha_inicio_Slot__c,
                    Fecha_fin_slot__c,
                    ONE_Reserva__c,
                    ONE_Sala__c,
                    ONE_Sala__r.ONE_Centro__c,
                    ONE_Tanatorio__c,
                    ONE_InicioSlot__c,
                    ONE_FinSlot__c,
                    ONE_Fecha_Inicio_Reserva__c,
                    ONE_Fecha_fin_de_reserva__c,
                    ONE_Servicio__c
            FROM    ONE_SlotSala__c
            WHERE   Id = :slotId
        ];

        if (String.isBlank(slot.ONE_Reserva__c)) {
            reservaDefaultValues.ONE_Expediente__c = servicioId != null ? servicioId : '';
            reservaDefaultValues.ONE_Sala__c = slot.ONE_Sala__c;
            reservaDefaultValues.ONE_Cuenta_Sitio_De_La_Reserva__c = slot.ONE_Sala__r.ONE_Centro__c;
            if (slot.ONE_TipoSala__c.contains('Sala Velatorio')) reservaDefaultValues.ONE_Momento_Al_Que_Aplica__c = 'Velación';
            else if (slot.ONE_TipoSala__c.contains('Sala Ceremonia')) reservaDefaultValues.ONE_Momento_Al_Que_Aplica__c = 'Ceremonia';
            else if (slot.ONE_TipoSala__c.contains('Depósito')) reservaDefaultValues.ONE_Momento_Al_Que_Aplica__c = 'Depósito';
            else if (slot.ONE_TipoSala__c.contains('Sala Despedida')) reservaDefaultValues.ONE_Momento_Al_Que_Aplica__c = 'Despedida';
            else if (slot.ONE_TipoSala__c.contains('Crematorio')) reservaDefaultValues.ONE_Momento_Al_Que_Aplica__c = 'Cremación';
           
            reservaDefaultValues.ONE_Fecha_Inicio__c = slot.ONE_InicioSlot__c;
            reservaDefaultValues.ONE_Fecha_Fin__c = slot.ONE_FinSlot__c;
            reservaDefaultValues.ONE_Reserva_con_Ceremonia__c = true;
        }
        else {
            reservaDefaultValues = [
                SELECT  Id,
                        ONE_Expediente__c,
                        ONE_Sala__c,
                        ONE_Cuenta_Sitio_De_La_Reserva__c,
                        ONE_Momento_Al_Que_Aplica__c,
                        ONE_Fecha_Inicio__c,
                        ONE_Fecha_Fin__c,
                        ONE_Tipo_De_Reserva__c,
                        ONE_Motivos_Del_Bloqueo__c,
                        ONE_Reserva_con_Ceremonia__c
                FROM    ONE_Reservas__c
                WHERE   Id = :slot.ONE_Reserva__c
            ];
        }

        return reservaDefaultValues;
    }

    // A partir de un slot y una reserva, actualiza el slot para incorporar la reserva
    @AuraEnabled
    public static String updateSlotWithReserva(Id slotId, Id reservaId) {
        
        /* reserva creada antes de entrar en esta acción */
        ONE_Reservas__c reserva = [SELECT ONE_Expediente__c, ONE_Momento_Al_Que_Aplica__c, ONE_Fecha_Inicio__c, ONE_Fecha_Fin__c , ONE_Cuenta_Sitio_De_La_Reserva__c, ONE_Sala__c, ONE_Reserva_con_Ceremonia__c, ONE_Motivos_Del_Bloqueo__c from ONE_Reservas__c WHERE Id = :reservaId ORDER BY ONE_Fecha_Inicio__c LIMIT 1];

        ONE_SlotSala__c slotSala = [SELECT Id, ONE_InicioSlot__c, ONE_FinSlot__c, ONE_Servicio__c, Fecha_inicio_Slot__c, Fecha_fin_slot__c, ONE_Fecha_Inicio_Reserva__c,ONE_Fecha_fin_de_reserva__c, ONE_Sala_ceremonia_relacionada__c, ONE_Duraci_n_Ceremonia__c, ONE_Horario__c from ONE_SlotSala__c WHERE Id = :slotId ORDER BY Fecha_inicio_Slot__c LIMIT 1];

        /* si el fin de la reserva es el mismo dia que la fecha seleccionada previamente para visualizar los slots */
        
        ONE_SlotSala__c slot = new ONE_SlotSala__c(
        Id = slotId,
        ONE_Reserva__c = reserva.Id,
        ONE_Servicio__c = reserva.ONE_Expediente__c,
        ONE_Observaciones__c = reserva.ONE_Motivos_Del_Bloqueo__c
        );

        update slot;

        /* Si la reserva es de velacion y check de crear reserva de ceremonia esta marcado */
        if ((reserva.ONE_Momento_Al_Que_Aplica__c == 'Velación' || reserva.ONE_Momento_Al_Que_Aplica__c == 'Despedida') && slotSala.ONE_Sala_ceremonia_relacionada__c != null && slotSala.ONE_InicioSlot__c != null && slotSala.ONE_FinSlot__c != null && reserva.ONE_Reserva_con_Ceremonia__c) {
            ONE_Recursos_Internos__c salaCeremonia = [SELECT Id, Name, ONE_Centro__c, ONE_Tipo_De_Sala__c from ONE_Recursos_Internos__c where Name = :slotSala.ONE_Sala_ceremonia_relacionada__c AND ONE_Tipo_De_Sala__c = 'Sala Ceremonia' LIMIT 1];
            List<ONE_Reservas__c> reservaAsociada = [SELECT Id, ONE_Expediente__c, ONE_Momento_Al_Que_Aplica__c from ONE_Reservas__c where ONE_Expediente__c = :reserva.ONE_Expediente__c AND ONE_Momento_Al_Que_Aplica__c = 'Ceremonia' LIMIT 1];
            
            ONE_Reservas__c reservaCeremonia;
            
            if (reservaAsociada.size() > 0) {
                reservaCeremonia = new ONE_Reservas__c (
                Id = reservaAsociada[0].Id,
                ONE_Cuenta_Sitio_De_La_Reserva__c = salaCeremonia.ONE_Centro__c,
                ONE_Expediente__c = reserva.ONE_Expediente__c,
                ONE_Fecha_Inicio__c = reserva.ONE_Fecha_Fin__c,
                ONE_Fecha_Fin__c = reserva.ONE_Fecha_Fin__c.addMinutes(Integer.valueOf(slotSala.ONE_Duraci_n_Ceremonia__c)),
                ONE_Momento_Al_Que_Aplica__c = 'Ceremonia',
                ONE_Sala__c = salaCeremonia.Id,
                ONE_Tipo_De_Reserva__c = 'Reserva'
                );
                update reservaCeremonia;
            } 
            else {
                reservaCeremonia = new ONE_Reservas__c (
                    ONE_Cuenta_Sitio_De_La_Reserva__c = salaCeremonia.ONE_Centro__c,
                    ONE_Expediente__c = reserva.ONE_Expediente__c,
                    ONE_Fecha_Inicio__c = reserva.ONE_Fecha_Fin__c,
                    ONE_Fecha_Fin__c = reserva.ONE_Fecha_Fin__c.addMinutes(Integer.valueOf(slotSala.ONE_Duraci_n_Ceremonia__c)),
                    ONE_Momento_Al_Que_Aplica__c = 'Ceremonia',
                    ONE_Sala__c = salaCeremonia.Id,
                    ONE_Tipo_De_Reserva__c = 'Reserva'
                );
                insert reservaCeremonia;
                List<ONE_SlotSala__c> slotSalaCeremonia = [SELECT Id, Fecha_inicio_Slot__c from ONE_SlotSala__c 
                WHERE Fecha_inicio_Slot__c = :reservaCeremonia.ONE_Fecha_Inicio__c.date() 
                AND Fecha_fin_slot__c = :reservaCeremonia.ONE_Fecha_Fin__c.date() 
                AND Hora_inicio_slot__c = :reservaCeremonia.ONE_Fecha_Inicio__c.time()
                AND Hora_fin_Slot__c = : reservaCeremonia.ONE_Fecha_Fin__c.time() ORDER BY Fecha_inicio_Slot__c LIMIT 1];

                if (slotSalaCeremonia.size() > 0) {
                    ONE_SlotSala__c slotCeremonia = new ONE_SlotSala__c(
                    Id = slotSalaCeremonia[0].Id,
                    ONE_Reserva__c = reservaCeremonia.Id,
                    ONE_Servicio__c = reservaCeremonia.ONE_Expediente__c
                    );
                    update slotCeremonia;
                }
            }             
        }

        /* Si se esta creando una reserva de ceremonia, crear slot nuevo para crear más reservas de ceremonia en esa sala */
        else if (slotSala.ONE_InicioSlot__c == null && slotSala.ONE_FinSlot__c == null && slotSala.ONE_Servicio__c == null) {
            ONE_SlotSala__c newSlot = new ONE_SlotSala__c(
                ONE_Horario__c = slotSala.ONE_Horario__c,
                ONE_Sala__c = reserva.ONE_Sala__c,
                Fecha_fin_slot__c = slotSala.Fecha_fin_slot__c
            );
            insert newSlot;
        }
        return 'SUCCESS'; 
    }


    @AuraEnabled
    public static Boolean userPrivilaged(){
        try {
            List<GroupMember> groupSupervisores = [SELECT Id, Group.Name, UserOrGroupId from GroupMember WHERE Group.Name = 'Supervisores SFB'];
            List<String> usersId = new List<String>();
            for (GroupMember user : groupSupervisores) {
                usersId.add(user.UserOrGroupId);
            }
            System.debug ('users: ' + usersId);
            System.debug('profilesToskip ::' + profilesToSkip);
            System.debug('UserInfo: ' + UserInfo.getProfileId());
            System.debug('contains: ' + profilesToSkip.contains(ONE_CommonUtils.getProfileNameById(UserInfo.getProfileId())));
            //System.debug('Name of the current user contains: ' + (namesToSkip.contains(UserInfo.getName())));
            System.debug('user in the user group: ' + usersId.contains(UserInfo.getUserId()));
            return (profilesToSkip.contains(ONE_CommonUtils.getProfileNameById(UserInfo.getProfileId()))) || (usersId.contains(UserInfo.getUserId()));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Boolean asesorPrivilege() {
        return asesorProfilesToSkip.contains(ONE_CommonUtils.getProfileNameById(UserInfo.getProfileId()));
    }

    // A partir de un slot y una reserva, elimina la reserva asociada al slot
    @AuraEnabled
    public static void deleteReserva(Id slotId, Id serviceId, Id reservaId) {

        ONE_SlotSala__c slotSala = [SELECT Id, ONE_InicioSlot__c, ONE_FinSlot__c from ONE_SlotSala__c WHERE Id = :slotId LIMIT 1];

        if (slotSala.ONE_InicioSlot__c == null && slotSala.ONE_FinSlot__c == null) {
            ONE_SlotSala__c slot = new ONE_SlotSala__c(
	        Id = slotSala.Id
            );
            delete slot;
        }
        else {
            ONE_SlotSala__c slot = new ONE_SlotSala__c(
	        Id = slotId,
            ONE_Reserva__c = null,
            ONE_Servicio__c = null,
            ONE_Observaciones__c = ''
            );
            update slot;
        }
        

        ONE_Reservas__c reserva = new ONE_Reservas__c(
	        Id = reservaId
        );
        ONE_Reservas__c reservaInfo = [SELECT ONE_Expediente__c, ONE_Momento_Al_Que_Aplica__c, 
            ONE_Fecha_Inicio__c, ONE_Fecha_Fin__c , ONE_Cuenta_Sitio_De_La_Reserva__c, ONE_Sala__c, ONE_Reserva_con_Ceremonia__c
            from ONE_Reservas__c WHERE Id = :reservaId 
            ORDER BY ONE_Fecha_Inicio__c LIMIT 1];

        
        if ((reservaInfo.ONE_Momento_Al_Que_Aplica__c == 'Velación' || reservaInfo.ONE_Momento_Al_Que_Aplica__c == 'Despedida') && reservaInfo.ONE_Expediente__c == serviceId && reservaInfo.ONE_Reserva_con_Ceremonia__c) {
            List<ONE_Reservas__c> reservasCeremonia = [SELECT Id, ONE_Expediente__c, ONE_Momento_Al_Que_Aplica__c, ONE_Fecha_Inicio__c, ONE_Fecha_Fin__c  from ONE_Reservas__c where ONE_Expediente__c = :serviceId AND ONE_Momento_Al_Que_Aplica__c = 'Ceremonia' LIMIT 1];
            if (reservasCeremonia.size() > 0) {
                List<ONE_SlotSala__c> slotSalaCeremonia = [SELECT Id, Fecha_inicio_Slot__c from ONE_SlotSala__c 
                    WHERE Fecha_inicio_Slot__c = :reservasCeremonia[0].ONE_Fecha_Inicio__c.date() 
                    AND Fecha_fin_slot__c = :reservasCeremonia[0].ONE_Fecha_Fin__c.date() 
                    AND Hora_inicio_slot__c = :reservasCeremonia[0].ONE_Fecha_Inicio__c.time()
                    AND Hora_fin_Slot__c = : reservasCeremonia[0].ONE_Fecha_Fin__c.time() ORDER BY Fecha_inicio_Slot__c LIMIT 1];
                if (slotSalaCeremonia.size() > 0) {
                    ONE_SlotSala__c slotCeremonia = new ONE_SlotSala__c(
                        Id = slotSalaCeremonia[0].Id,
                        ONE_Reserva__c = null,
                        ONE_Servicio__c = null
                    );
                    update slotCeremonia;
                }
                delete reservasCeremonia;
            }
        }

        if (reservaInfo.ONE_Expediente__c == serviceId || reservaInfo.ONE_Expediente__c == null) delete reserva;
        //else reserva.addError('No es posible borrar una reserva que pertenece a otro servicio. Si estas seguro de esta acción, pulse de nuevo a eliminar.');
        
    }
}
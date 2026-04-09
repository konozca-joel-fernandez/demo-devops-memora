public without sharing class ONE_ConsultaResevaSalasController {

    public String Interval { get; set; }
    public String objeto { get; set; }
    public String idLugar { get; set; }
    public String idCentro { get; set; }
    public String fechaInicio { get; set; }
    public String tipoSala { get; set; }
    public String allRoomsJson { get; set; }
    public String vForceUrl { get; set; }

    public static Boolean wasUserWarned = false;
    private static final String OBJETO_CENTRO = 'centro';
    private static final String OBJETO_LUGAR = 'lugar';

    private static final String PARAM_OBJETO = 'objeto';
    private static final String PARAM_INTERVALO = 'intervalo';
    private static final String PARAM_CENTRO_ID = 'idCentro';
    private static final String PARAM_LUGAR_ID = 'idLugar';
    private static final String PARAM_FECHA_INICIO = 'fechaInicio';
    private static final String PARAM_TIPO_SALA = 'tipoSala';

    private transient ONE_SalasHelper.TimeInterval timeInterval { get; set; } // Time interval selected from the picklist in the component

    public ONE_ConsultaResevaSalasController() {
        vForceUrl = ONE_CommonUtils.getVFBaseURL()[2];
        objeto = ApexPages.CurrentPage().getparameters().get(PARAM_OBJETO);
        Interval = ApexPages.CurrentPage().getparameters().get(PARAM_INTERVALO);
        fechaInicio = ApexPages.CurrentPage().getparameters().get(PARAM_FECHA_INICIO);
        tipoSala = ApexPages.CurrentPage().getparameters().get(PARAM_TIPO_SALA);

        Integer daysToGenerate = 0;
        // Translation for the picklist values
        switch on Interval {
            when '1' {
                timeInterval = ONE_SalasHelper.TimeInterval.INTERVAL_24H;
                daysToGenerate = 1;
            }
            when '2' {
                timeInterval = ONE_SalasHelper.TimeInterval.INTERVAL_48H;
                daysToGenerate = 2;
            }
            when '3' {
                timeInterval = ONE_SalasHelper.TimeInterval.INTERVAL_3D;
                daysToGenerate = 3;
            }
            when else {
                timeInterval = ONE_SalasHelper.TimeInterval.INTERVAL_7D;
                daysToGenerate = 7;
            }
        }

        Map<Room, List<Timespan>> room2Reservations = new Map<Room, List<Timespan>>();

        String centroString = ApexPages.CurrentPage().getparameters().get(PARAM_CENTRO_ID);
        Set<Id> centroIdsSet;
        if(centroString != '' && centroString != null) {
            centroIdsSet = (Set<Id>)JSON.Deserialize(centroString, Set<Id>.class);
        }

        id lugarId = ApexPages.CurrentPage().getparameters().get(PARAM_LUGAR_ID);
        Set<Id> lugarIdsSet = new Set<Id>();
        if(lugarId != null) {
            lugarIdsSet.add(lugarId);
        }

        Map<String, Set<Date>> salaId2SpecialDate = new Map<String, Set<Date>>();

        List<ONE_Recursos_Internos__c> recursos = fetchRecursosInternos(centroIdsSet, lugarIdsSet, tipoSala);
        System.debug('recursos');
        System.debug(recursos);
        for (ONE_Recursos_Internos__c sala : recursos) {
            System.debug(sala.Horarios__r.size());
            for (ONE_Horario__c horario : sala.Horarios__r) {
                if (horario.ONE_Fecha_Excepcional__c != null) {
                    if (salaId2SpecialDate.containsKey(sala.Id)) {
                        salaId2SpecialDate.get(sala.Id).add(horario.ONE_Fecha_Excepcional__c);
                    } else {
                        salaId2SpecialDate.put(sala.Id, new Set<Date>{
                            horario.ONE_Fecha_Excepcional__c
                        });
                    }
                }
            }
        }

        for (ONE_Recursos_Internos__c sala : recursos) {
            List<Timespan> day2Timespan = new List<Timespan>();
            for (ONE_Horario__c horario : sala.Horarios__r) {
                Boolean specialDay;
                DateTime today = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
                if (fechaInicio != '' && fechaInicio != null) {
                    Date dateValue = Date.valueOf(fechaInicio);
                    today = Datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
                }
                for (Integer i = 0; i < daysToGenerate; i++) {
                    DateTime startDate;
                    DateTime endDate;
                    specialDay = salaId2SpecialDate.containsKey(sala.Id) && salaId2SpecialDate.get(sala.Id).contains(today.date());
                    if ( !specialDay && horario.ONE_Lunes__c && ONE_CommonUtils.dayNumber(today.date()) == 1 ||
                        !specialDay && horario.ONE_Martes__c && ONE_CommonUtils.dayNumber(today.date()) == 2 ||
                        !specialDay && horario.ONE_Miercoles__c && ONE_CommonUtils.dayNumber(today.date()) == 3 ||
                        !specialDay && horario.ONE_Jueves__c && ONE_CommonUtils.dayNumber(today.date()) == 4 ||
                        !specialDay && horario.ONE_Viernes__c && ONE_CommonUtils.dayNumber(today.date()) == 5 ||
                        !specialDay && horario.ONE_Sabado__c && ONE_CommonUtils.dayNumber(today.date()) == 6 ||
                        !specialDay && horario.ONE_Domingo__c && ONE_CommonUtils.dayNumber(today.date()) == 0 ||
                        specialDay && horario.ONE_Fecha_Excepcional__c != null && horario.ONE_Fecha_Excepcional__c.daysBetween(today.date()) == 0) {
						
                        if (horario.ONE_Hora_De_Inicio__c != null && horario.ONE_Hora_De_Fin__c != null) {
                            startDate = DateTime.newInstance(today.date(), horario.ONE_Hora_De_Inicio__c);
                            endDate = DateTime.newInstance(today.date(), horario.ONE_Hora_De_Fin__c);
    
                            if(horario.ONE_Hora_De_Fin__c <= horario.ONE_Hora_De_Inicio__c) {
                                Date endDateAux = Date.newinstance(endDate.year(), endDate.month(), endDate.day());
                                endDateAux = endDateAux.addDays(1);
                                endDate = DateTime.newInstance(endDateAux, horario.ONE_Hora_De_Fin__c);
                                //endDate = endDate.addDays(1);
                            }
    
                            day2Timespan.add(new Timespan('', startDate, endDate, ''));
                        }
                    }
                    Date todayAux = Date.newinstance(today.year(), today.month(), today.day());
                    todayAux = todayAux.addDays(1);
                    today = Datetime.newInstance(todayAux.year(), todayAux.month(), todayAux.day());
                    //today = today.addDays(1);
                }
            }
            Room room = new Room(buildName(sala), sala.Id, sala.ONE_Orden__c, day2Timespan);
            room2Reservations.put(room, new List<Timespan>());

        }

        for (ONE_Reservas__c reserva : prepareReservas()) {
            Room newRoom = new Room(buildName(reserva), reserva.Id, reserva.ONE_Sala__r.ONE_Orden__c);

            if (room2Reservations.containsKey(newRoom)) {
                room2Reservations.get(newRoom).add(
                    new Timespan(
                        reserva.ONE_Expediente_Formula__c,
                        reserva.ONE_Fecha_Inicio__c,
                        reserva.ONE_Fecha_Fin__c,
                        String.format(
                            '{0} {1}',
                            new List<String>{
                                reserva?.ONE_Expediente__r?.ONE_Difunto__r.Name == null ? '' : reserva.ONE_Expediente__r.ONE_Difunto__r.Name,
                                reserva?.ONE_Expediente__r?.Name == null ? '' : reserva.ONE_Expediente__r.Name
                            }
                        )
                    )
                );
            } else {
                room2Reservations.put(newRoom, new List<Timespan>{
                    new Timespan(
                        reserva.ONE_Expediente_Formula__c,
                        reserva.ONE_Fecha_Inicio__c,
                        reserva.ONE_Fecha_Fin__c,
                        String.format(
                            '{0} {1}',
                            new List<String>{
                                reserva?.ONE_Expediente__r?.ONE_Difunto__r.Name == null ? '' : reserva.ONE_Expediente__r.ONE_Difunto__r.Name,
                                reserva?.ONE_Expediente__r?.Name == null ? '' : reserva.ONE_Expediente__r.Name
                            }
                        )
                    )
                });
            }
        }

        for (Room key : room2Reservations.keySet()) {
            key.reservations = room2Reservations.get(key);
        }

        List<Room> allRooms = new List<Room>(room2Reservations.keySet());
        allRooms.sort();
        for(Room r : allRooms) {
            r.Name = r.Name.split('%%')[1];
        }

        allRoomsJson = JSON.serialize(allRooms);

        System.debug(allRoomsJson);
    }

    private List<ONE_Recursos_Internos__c> fetchRecursosInternos(Set<Id> centroIds, Set<Id> lugarIds, String tipoSala) {
        if(centroIds != null && !centroIds.isEmpty()) {
            if (String.isBlank(tipoSala)) {
                return [
                    SELECT Name, ONE_Categoria_De_Sala__c,ONE_Centro__c, ONE_Tipo_De_Sala__c, ONE_Orden__c,
                    (
                        SELECT Id, ONE_Hora_De_Inicio__c, ONE_Hora_De_Fin__c, ONE_Domingo__c, ONE_Jueves__c, ONE_Lunes__c,
                        ONE_Martes__c, ONE_Miercoles__c, ONE_Sabado__c, ONE_Viernes__c, ONE_Fecha_Excepcional__c
                        FROM Horarios__r WHERE ONE_Activo__c = true OR ONE_Fecha_Excepcional__c != null
                    )
                    FROM ONE_Recursos_Internos__c
                    WHERE RecordType.DeveloperName =: ONE_CommonConstants.REC_RT_SALAS
                        AND ONE_Centro__c IN: centroIds
                ];
            }
            else {
                return [
                    SELECT Name, ONE_Categoria_De_Sala__c,ONE_Centro__c, ONE_Tipo_De_Sala__c, ONE_Orden__c,
                    (
                        SELECT Id, ONE_Hora_De_Inicio__c, ONE_Hora_De_Fin__c, ONE_Domingo__c, ONE_Jueves__c, ONE_Lunes__c,
                        ONE_Martes__c, ONE_Miercoles__c, ONE_Sabado__c, ONE_Viernes__c, ONE_Fecha_Excepcional__c
                        FROM Horarios__r WHERE ONE_Activo__c = true OR ONE_Fecha_Excepcional__c != null
                    )
                    FROM ONE_Recursos_Internos__c
                    WHERE RecordType.DeveloperName =: ONE_CommonConstants.REC_RT_SALAS
                        AND ONE_Tipo_De_Sala__c = :tipoSala
                        AND ONE_Centro__c IN: centroIds
                ];
            }

        } else if(lugarIds != null && !lugarIds.isEmpty()) {
            List<Account> centros = [
                SELECT Id
                FROM Account
                WHERE ONE_Delegacion__c IN :lugarIds
                    OR ONE_Lugar__c IN :lugarIds
                    OR ONE_Lugar__r.ONE_Lugar_Superior__c IN: lugarIds
                    OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c IN: lugarIds
                    OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c IN: lugarIds
            ];
            if (String.isBlank(tipoSala)) {
                return [
                    SELECT Name, ONE_Categoria_De_Sala__c,ONE_Centro__c, ONE_Tipo_De_Sala__c, ONE_Orden__c, (
                        SELECT Id, ONE_Hora_De_Inicio__c, ONE_Hora_De_Fin__c, ONE_Domingo__c, ONE_Jueves__c, ONE_Lunes__c,
                            ONE_Martes__c, ONE_Miercoles__c, ONE_Sabado__c, ONE_Viernes__c, ONE_Fecha_Excepcional__c
                        FROM Horarios__r WHERE ONE_Activo__c = true OR ONE_Fecha_Excepcional__c != null
                    )
                    FROM ONE_Recursos_Internos__c
                    WHERE RecordType.DeveloperName =: ONE_CommonConstants.REC_RT_SALAS
                        AND ONE_Centro__c IN: centros
                ];
            }
            else {
                return [
                    SELECT Name, ONE_Categoria_De_Sala__c,ONE_Centro__c, ONE_Tipo_De_Sala__c, ONE_Orden__c, (
                        SELECT Id, ONE_Hora_De_Inicio__c, ONE_Hora_De_Fin__c, ONE_Domingo__c, ONE_Jueves__c, ONE_Lunes__c,
                            ONE_Martes__c, ONE_Miercoles__c, ONE_Sabado__c, ONE_Viernes__c, ONE_Fecha_Excepcional__c
                        FROM Horarios__r WHERE ONE_Activo__c = true OR ONE_Fecha_Excepcional__c != null
                    )
                    FROM ONE_Recursos_Internos__c
                    WHERE RecordType.DeveloperName =: ONE_CommonConstants.REC_RT_SALAS
                        AND ONE_Tipo_De_Sala__c = :tipoSala
                        AND ONE_Centro__c IN: centros
                ];
            }
        } else {
            if (String.isBlank(tipoSala)) {
                return [
                    SELECT Name, ONE_Categoria_De_Sala__c,ONE_Centro__c, ONE_Tipo_De_Sala__c, ONE_Orden__c, (
                        SELECT Id, ONE_Hora_De_Inicio__c, ONE_Hora_De_Fin__c, ONE_Domingo__c, ONE_Jueves__c, ONE_Lunes__c,
                        ONE_Martes__c, ONE_Miercoles__c, ONE_Sabado__c, ONE_Viernes__c, ONE_Fecha_Excepcional__c
                        FROM Horarios__r WHERE ONE_Activo__c = true OR ONE_Fecha_Excepcional__c != null
                        )
                    FROM ONE_Recursos_Internos__c
                    WHERE RecordType.DeveloperName =: ONE_CommonConstants.REC_RT_SALAS
                ];
            }
            else {
                return [
                    SELECT Name, ONE_Categoria_De_Sala__c,ONE_Centro__c, ONE_Tipo_De_Sala__c, ONE_Orden__c, (
                        SELECT Id, ONE_Hora_De_Inicio__c, ONE_Hora_De_Fin__c, ONE_Domingo__c, ONE_Jueves__c, ONE_Lunes__c,
                        ONE_Martes__c, ONE_Miercoles__c, ONE_Sabado__c, ONE_Viernes__c, ONE_Fecha_Excepcional__c
                        FROM Horarios__r WHERE ONE_Activo__c = true OR ONE_Fecha_Excepcional__c != null
                        )
                    FROM ONE_Recursos_Internos__c
                    WHERE RecordType.DeveloperName =: ONE_CommonConstants.REC_RT_SALAS
                        AND ONE_Tipo_De_Sala__c = :tipoSala
                ];
            }
        }
    }

    private List<ONE_Reservas__c> prepareReservas() {
        List<ONE_Reservas__c> reservas = new List<ONE_Reservas__c>();
        Datetime startDate;

        if (fechaInicio != null && fechaInicio != '') {
            Date fechaDate = Date.valueOf(fechaInicio);
            startDate = Datetime.newInstance(fechaDate, Time.newInstance(0,0,0,0));
        }
        if (objeto != null) {
            if (objeto == OBJETO_CENTRO) {
                String centroString = ApexPages.CurrentPage().getparameters().get(PARAM_CENTRO_ID);
                Set<Id> testId = (Set<Id>)JSON.Deserialize(centroString, Set<Id>.class);

                List<ONE_Recursos_Internos__c> recursos = [
                    SELECT Id
                    FROM ONE_Recursos_Internos__c
                    WHERE ONE_Centro__c IN :testId
                ];

                reservas = ONE_SalasHelper.fetchReservas(recursos, startDate, timeInterval);
                System.debug('reservas');
                System.debug(reservas);

            } else if (objeto == OBJETO_LUGAR) {

                id testId = ApexPages.CurrentPage().getparameters().get(PARAM_LUGAR_ID);
                List<Account> centros = [
                    SELECT Id
                    FROM Account
                    WHERE ONE_Delegacion__c = :testId
                    OR ONE_Lugar__c =: testId
                    OR ONE_Lugar__r.ONE_Lugar_Superior__c =: testId
                    OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =: testId
                    OR ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =: testId
                ];
                List<ONE_Recursos_Internos__c> recursos = [
                    SELECT id
                    FROM ONE_Recursos_Internos__c
                    WHERE ONE_Centro__c IN :centros
                ];
                reservas = ONE_SalasHelper.fetchReservas(recursos, startDate, timeInterval);
            }
        } else {
            reservas = ONE_SalasHelper.fetchReservas(startDate, timeInterval);
        }

        return reservas;
    }

    private String buildName(Object obj) {
        if (obj instanceof ONE_Reservas__c) {
            ONE_Reservas__c reserva = (ONE_Reservas__c) obj;
            return String.format(
                '{0}%%{1} {2} {3}',
                new List<String>{
                    reserva.ONE_Sala__r.ONE_Centro__c == null ? '' : reserva.ONE_Sala__r.ONE_Centro__c,
                    reserva.ONE_Nombre_De_Sala__c == null ? '' : reserva.ONE_Nombre_De_Sala__c,
                    reserva.ONE_Categoria_De_Sala__c == null ? '' : reserva.ONE_Categoria_De_Sala__c,
                    reserva.ONE_Tipo_De_Sala__c == null ? '' : reserva.ONE_Tipo_De_Sala__c
                }
            );
        } else if (obj instanceof ONE_Recursos_Internos__c) {
            ONE_Recursos_Internos__c sala = (ONE_Recursos_Internos__c) obj;
            return String.format(
                '{0}%%{1} {2} {3}',
                new List<String>{
                    sala.ONE_Centro__c == null ? '' : sala.ONE_Centro__c,
                    sala.Name == null ? '' : sala.Name,
                    sala.ONE_Categoria_De_Sala__c == null ? '' : sala.ONE_Categoria_De_Sala__c,
                    sala.ONE_Tipo_De_Sala__c == null ? '' : sala.ONE_Tipo_De_Sala__c
                }
            );
        }
        return null;
    }

    public Class Timespan {
        public String name { get; private set; }
        public String startDate { get; private set; }
        public String endDate { get; private set; }
        public String reservationName { get; set; }

        public Timespan(String name, String startDate, String endDate, String reservationName) {
            this.name = name;
            this.startDate = startDate;
            this.endDate = endDate;
            this.reservationName = reservationName;
        }

        public Timespan(String name, DateTime startDate, DateTime endDate, String reservationName) {
            this.name = name;
            this.startDate = startDate.format('yyyy-MM-dd HH:mm');
            this.endDate = endDate.format('yyyy-MM-dd HH:mm');
            this.reservationName = reservationName;
        }
    }

    public abstract class OrderedRoom implements Comparable {
        public Decimal order { get; set; }
        public virtual Integer compareTo(Object compareTo) {
            OrderedRoom compareToEmp = (OrderedRoom) compareTo;

            if (this.order == null) return 1;
            if (compareToEmp == null) return -1;
            if (this.order == compareToEmp.order) {
                return 0;
            } else if (this.order > compareToEmp.order) {
                return 1;
            } else {
                return -1;
            }
        }
    }

    public class Room extends OrderedRoom  {
        public String name { get; private set; }
        public String id { get; private set; }
        public List<Timespan> reservations { get; private set; }
        public List<Timespan> workingHours { get; private set; }

        public Room(String name, Id id, Decimal orden) {
            this.name = name;
            this.order = orden;
            this.id = id;
            this.reservations = new List<Timespan>();
            this.workingHours = new List<Timespan>();
        }

        public Room(String name, Id id, Decimal orden, List<Timespan> workingHours) {
            this.name = name;
            this.id = id;
            this.order = orden;
            this.reservations = new List<Timespan>();
            this.workingHours = workingHours;
        }

        public Room(String name, Id id, Decimal orden, List<Timespan> reservations, List<Timespan> workingHours) {
            this.name = name;
            this.id = id;
            this.order = orden;
            this.reservations = reservations;
            this.workingHours = workingHours;
        }

        public Boolean equals(Object obj) {
            if (obj instanceof Room) {
                Room s = (Room) obj;
                return (s.name.equals(this.name));
            } else {
                return false;
            }
        }

        public Integer hashCode() {
            return name.length() + Integer.valueOf(order == null ? 0 : order);
        }

        public override Integer compareTo(Object compareTo) {
            Room compareToEmp = (Room) compareTo;
            Integer roomOrder = super.compareTo(compareToEmp);
            System.debug('roomOrder');
            System.debug(roomOrder);
            System.debug(this.name);
            System.debug(compareToEmp.name);
            System.debug(this.name.split('%%')[0].compareTo(compareToEmp.name.split('%%')[0]));
            if(this.name.split('%%')[0].compareTo(compareToEmp.name.split('%%')[0]) == 0) {
                return roomOrder;
            } else {
                return this.name.split('%%')[0].compareTo(compareToEmp.name.split('%%')[0]);
            }
        }
    }

    @AuraEnabled
    public static Boolean isExpediente(String recId) {
        String sObjectType = ((Id)recId).getSobjectType().getDescribe().getName();
        return sObjectType.equalsIgnoreCase(ONE_CommonConstants.EXPEDIENTE);
    }

    @AuraEnabled
    public static String getVisualforcePage() {
        return ONE_CommonUtils.getVFBaseURL()[0];
    }

    @AuraEnabled
    public static List<ONE_LookupSearchResult> initLookup(String recId) {
        String sObjectType = ((Id)recId).getSobjectType().getDescribe().getName();

        System.debug('sObjectType');
        System.debug(sObjectType);

        if(sObjectType.equalsIgnoreCase(ONE_CommonConstants.ACCOUNT)) {
            List<Account> acc = [
                SELECT Id, Name
                FROM Account
                WHERE Id =: recId
            ];
            return new List<ONE_LookupSearchResult> {
                new ONE_LookupSearchResult(
                    acc[0].Id,
                    ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ICO_ACCOUNT,
                    acc[0].Name,
                    ''
                )
            };
        } else if(sObjectType.equalsIgnoreCase(ONE_CommonConstants.EXPEDIENTE)) {
            List<ONE_Expediente__c> expediente = [
                SELECT Id, ONE_Centro__c, ONE_Centro__r.Name, ONE_Centro_Del_Expediente__c, ONE_Centro_Del_Expediente__r.Name
                FROM ONE_Expediente__c
                WHERE Id =: recId
            ];
            return new List<ONE_LookupSearchResult> {
                new ONE_LookupSearchResult(
                    expediente[0].ONE_Centro_Del_Expediente__c,
                    ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ICO_ACCOUNT,
                    expediente[0].ONE_Centro_Del_Expediente__r.Name,
                    ''
                )
            };
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<ONE_LookupSearchResult> searchCentro(String searchTerm, List<String> selectedIds) {
        List<ONE_LookupSearchResult> retList = new List<ONE_LookupSearchResult>();
        for (Account centro : [
            SELECT Id, Name
            FROM Account
            WHERE Name LIKE: '%'+searchTerm+'%'
                AND Id NOT IN: selectedIds
                AND RecordType.DeveloperName =: ONE_CommonConstants.ACC_RT_CENTRO_MEMORA
            ORDER BY createdDate DESC
            LIMIT 5
        ]) {
            retList.add(
                new ONE_LookupSearchResult(
                    centro.Id,
                    ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ICO_ACCOUNT,
                    centro.Name,
                    '')
            );
        }
        return retList;
    }

    @AuraEnabled(cacheable=true)
    public static List<ONE_LookupSearchResult> searchLugar(String searchTerm, List<String> selectedIds) {
        List<ONE_LookupSearchResult> retList = new List<ONE_LookupSearchResult>();
        for (ONE_Lugar__c lugar : [
            SELECT Id, Name
            FROM ONE_Lugar__c
            WHERE Name LIKE: '%'+searchTerm+'%'
                AND Id NOT IN: selectedIds
            ORDER BY createdDate DESC
            LIMIT 5
        ]) {
            retList.add(
                new ONE_LookupSearchResult(
                    lugar.Id,
                    ONE_CommonConstants.LUGAR,
                    ONE_CommonConstants.ICO_ACCOUNT,
                    lugar.Name,
                    '')
            );
        }
        return retList;
    }

    @AuraEnabled
    public static String deleteRecord(Object obj) {
        System.debug('AAAAA '  + obj);
        Map<String, String> parsedObjKey2Value = (Map<String, String>)JSON.deserialize(JSON.serialize(obj), Map<String, String>.class);
        System.debug(parsedObjKey2Value);
        try {
            
            List<ONE_Reservas__c> selectRecords = [
                SELECT Id, ONE_Expediente__c, ONE_Cuenta_Sitio_De_La_Reserva__c
                FROM ONE_Reservas__c
                WHERE ONE_Fecha_Inicio__c =: (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('start')+'"', DateTime.class)
                    AND ONE_Fecha_Fin__c =:  (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('end')+'"', DateTime.class)
                    AND (ONE_Sala__c =: (String)parsedObjKey2Value.get('id') OR Id =: (String)parsedObjKey2Value.get('id'))
                LIMIT 1
            ];

            List<ONE_SlotSala__c> slotSala = [SELECT Id, ONE_InicioSlot__c, ONE_FinSlot__c from ONE_SlotSala__c WHERE ONE_Reserva__c = :selectRecords[0].Id LIMIT 1];

            if (slotSala.size() > 0) {
                if (slotSala[0].ONE_InicioSlot__c == null && slotSala[0].ONE_FinSlot__c == null) {
                    delete slotSala[0];
                }
                else {
                    ONE_SlotSala__c slot = new ONE_SlotSala__c(
                        Id = slotSala[0].Id,
                        ONE_Observaciones__c = ''
                    );
                    update slot;
                }
                
            }

            String recordId = (String)parsedObjKey2Value.get('recordId');
            String expedienteId = (String)parsedObjKey2Value.get('expedient');
            Boolean isAcc = recordId.startsWith('001');

            if (recordId == selectRecords[0].ONE_Expediente__c || isAcc || selectRecords[0].ONE_Expediente__c == null) delete selectRecords;
            else {
                throw new AuraHandledException('');
            }

            
            return 'SUCCESS';
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            String msg = 'No es posible borrar una reserva que pertenece a otro servicio.';
            //String msg = 'Se ha producido un error';
            return msg;
        }
    }

    @AuraEnabled
    public static String updateCuenta(String sala) {
        return [
            SELECT ONE_Centro__c FROM ONE_Recursos_Internos__c WHERE Id =: sala
        ].ONE_Centro__c;
    }

    @AuraEnabled
    public static String updateRecord(Object obj) {
        System.debug(obj);
        Map<String, String> parsedObjKey2Value = (Map<String, String>)JSON.deserialize(JSON.serialize(obj), Map<String, String>.class);

        System.debug(parsedObjKey2Value.get('isError'));
        try {

            List<ONE_Reservas__c> reservas = [
                SELECT Id, ONE_Observaciones__c, ONE_ManualRecordChangeIndicator__c, ONE_Sala__c, ONE_Fecha_Inicio__c, ONE_Fecha_Fin__c, ONE_Cuenta_Sitio_De_La_Reserva__c, ONE_Expediente__c
                FROM ONE_Reservas__c
                WHERE ONE_Fecha_Inicio__c =: (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('start')+'"', DateTime.class)
                    AND ONE_Fecha_Fin__c =:  (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('end')+'"', DateTime.class)
                    AND (ONE_Sala__c =: (String)parsedObjKey2Value.get('id') OR Id =: (String)parsedObjKey2Value.get('id'))
                LIMIT 1
            ];

            String recordId = (String)parsedObjKey2Value.get('recordId');
            String expedienteId = (String)parsedObjKey2Value.get('expedient');
            Boolean isAcc = recordId.startsWith('001');

            System.debug('id actual: ' + recordId + ' && isAcc: ' + isAcc);
            System.debug('el id de exp: ' + expedienteId);
            System.debug((DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('start')+'"', DateTime.class));
            System.debug((DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('end')+'"', DateTime.class));
            System.debug((String)parsedObjKey2Value.get('id'));
            System.debug(reservas.size());
            System.debug(reservas);
            
            if (recordId == reservas[0].ONE_Expediente__c || isAcc || reservas[0].ONE_Expediente__c == null) {
                reservas[0].ONE_ManualRecordChangeIndicator__c = (parsedObjKey2Value.get('isError') == 'true') ?
            	reservas[0].ONE_ManualRecordChangeIndicator__c + '#%$#' : reservas[0].ONE_ManualRecordChangeIndicator__c + '#$%#';

            	reservas[0].ONE_Sala__c = (String)parsedObjKey2Value.get('newSala');
            	reservas[0].ONE_Fecha_Inicio__c = (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('newStart')+'"', DateTime.class);
            	reservas[0].ONE_Fecha_Fin__c = (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('newEnd')+'"', DateTime.class);
            	reservas[0].ONE_Cuenta_Sitio_De_La_Reserva__c = (String)parsedObjKey2Value.get('cuenta');

            	update reservas;
            }
            
            else {
            	throw new AuraHandledException('');
            }

            

            return 'SUCCESS';
        } catch(Exception e) {
            System.debug('Exception ' + e);
            Boolean auraException = e.getMessage().contains('Script-thrown exception');
            if (auraException) {
                String msg = 'No es posible modificar una reserva que pertenece a otro servicio.';
                //String msg = 'Se ha producido un error';
                return msg;
            }
            
            return e.getMessage();
            
            //return ex.getMessage();
        }
    }

    //get informacion de la sala: Centro y momento
    @AuraEnabled
    public static String getAccountSala(Object obj){
        Map<String, String> parsedObjKey2Value = (Map<String, String>)JSON.deserialize(JSON.serialize(obj), Map<String, String>.class);
        String sala = (String)parsedObjKey2Value.get('id');
        if (sala != null) {
            List<ONE_Recursos_Internos__c> recursos = [SELECT ONE_Centro__c, ONE_Tipo_De_Sala__c FROM ONE_Recursos_Internos__c where Id=:sala LIMIT 1];

            return JSON.serialize(recursos);
        }
        return '';
    }

    @AuraEnabled
    public static String initSecondaryLookups(Object obj) {
        System.debug('initSecondaryLookups');
        System.debug(obj);
        Map<String, String> parsedObjKey2Value = (Map<String, String>)JSON.deserialize(JSON.serialize(obj), Map<String, String>.class);
        System.debug(parsedObjKey2Value);

        DateTime dt1 = (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('start')+'"', DateTime.class);
        DateTime dt2 = (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('end')+'"', DateTime.class);

        List<ONE_Reservas__c> reservas = [
            SELECT Id, ONE_Observaciones__c, ONE_Motivos_Del_Bloqueo__c, ONE_Tipo_De_Reserva__c, ONE_Momento_Al_Que_Aplica__c, ONE_Sala__c, ONE_Expediente__c, ONE_Cuenta_Sitio_De_La_Reserva__c
            FROM ONE_Reservas__c
            WHERE ONE_Fecha_Inicio__c =: (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('start')+'"', DateTime.class)
                AND ONE_Fecha_Fin__c =:  (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('end')+'"', DateTime.class)
                AND (ONE_Sala__c =: (String)parsedObjKey2Value.get('id') OR Id =: (String)parsedObjKey2Value.get('id'))
            LIMIT 1
        ];
        system.debug(reservas);
        return JSON.serialize(reservas);
    }

    @AuraEnabled
    public static Boolean canEdit(Object obj) {
        System.debug('canEdit');
        if(ONE_ReservasHelper.userPrivilaged() || ONE_ReservasHelper.asesorPrivilege()) {
            return true;
        }
        System.debug(obj);
        Map<String, String> parsedObjKey2Value = (Map<String, String>)JSON.deserialize(JSON.serialize(obj), Map<String, String>.class);
        System.debug(parsedObjKey2Value);
        List<ONE_Reservas__c> reservas = [
            SELECT Id, ONE_Observaciones__c
            FROM ONE_Reservas__c
            WHERE ONE_Expediente__r.OwnerId =: UserInfo.getUserId()
                AND ONE_Fecha_Inicio__c =: (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('start')+'"', DateTime.class)
                AND ONE_Fecha_Fin__c =:  (DateTime)JSON.deserialize('"'+parsedObjKey2Value.get('end')+'"', DateTime.class)
                AND (ONE_Sala__c =: (String)parsedObjKey2Value.get('id') OR Id =: (String)parsedObjKey2Value.get('id'))
            LIMIT 1
        ];

        return (!reservas.isEmpty());
    }
}
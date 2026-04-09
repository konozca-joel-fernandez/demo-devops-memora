/**
 * Created by mbujak003 on 02.12.2020.
 */

public with sharing class ONE_HorarioHelper {
    public static List<ONE_Horario__c> fetchHorariosForSalas(Set<Id> salasIds) {
        return [
            SELECT Id, ONE_Hora_De_Inicio__c, ONE_Hora_De_Fin__c, ONE_Domingo__c, ONE_Jueves__c, ONE_Lunes__c,
                ONE_Martes__c, ONE_Miercoles__c, ONE_Sabado__c, ONE_Viernes__c, ONE_Fecha_Excepcional__c, ONE_Sala__c
            FROM ONE_Horario__c
            WHERE ONE_Sala__c IN: salasIds AND (ONE_Activo__c = true OR ONE_Fecha_Excepcional__c != null)
        ];
    }

    public class RoomScheduleDay {
        public Boolean isSpecial;
        public Integer dayNumber;
        public DateTime startDate;
        public DateTime endDate;

        public RoomScheduleDay(DateTime startDate, DateTime endDate, Integer dayNumber, Boolean isSpecial) {
            this.startDate = startDate;
            this.endDate = endDate;
            this.dayNumber = dayNumber;
            this.isSpecial = isSpecial;
        }
    }

    public class RoomSchedule {

        public List<RoomScheduleDay> scheduleDays;
        public List<ONE_Horario__c> horarios;
        public Date startDate;
        public Date endDate;

        public RoomSchedule(Date startDate, Date endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
            scheduleDays = new List<RoomScheduleDay>();
            horarios = new List<ONE_Horario__c>();
        }

        public RoomSchedule(List<ONE_Horario__c> horarios, Date startDate, Date endDate) {
            this(startDate, endDate);
            this.horarios = horarios;
        }

        public void buildSchedule() {
            for(Date day = startDate; day <= endDate; day.addDays(1)) {
                for(ONE_Horario__c horario : horarios) {
                    if(horario.ONE_Lunes__c && ONE_CommonUtils.dayNumber(day) == 1 ||
                        horario.ONE_Martes__c && ONE_CommonUtils.dayNumber(day) == 2 ||
                        horario.ONE_Miercoles__c && ONE_CommonUtils.dayNumber(day) == 3 ||
                        horario.ONE_Jueves__c && ONE_CommonUtils.dayNumber(day) == 4 ||
                        horario.ONE_Viernes__c && ONE_CommonUtils.dayNumber(day) == 5 ||
                        horario.ONE_Sabado__c && ONE_CommonUtils.dayNumber(day) == 6 ||
                        horario.ONE_Domingo__c && ONE_CommonUtils.dayNumber(day) == 7 ||
                        horario.ONE_Fecha_Excepcional__c != null && day.daysBetween(horario.ONE_Fecha_Excepcional__c) == 0) {
                        RoomScheduleDay rsd = new RoomScheduleDay(
                            Datetime.newInstance(day, horario.ONE_Hora_De_Inicio__c),
                            Datetime.newInstance(day, horario.ONE_Hora_De_Fin__c),
                            ONE_CommonUtils.dayNumber(day),
                            horario.ONE_Fecha_Excepcional__c != null
                        );
                        scheduleDays.add(rsd);
                    }
                }
            }
        }

        public void addHorario(ONE_Horario__c horario) {
            this.horarios.add(horario);
        }

        public Boolean dateInSchedule(DateTime startDate, DateTime endDate) {
            if(scheduleDays != null) {
                for(RoomScheduleDay rsd : scheduleDays) {
                    if(startDate.day() == rsd.startDate.day()) {
                        return (startDate >= rsd.startDate && endDate <= rsd.endDate);
                    }
                }
            }
            return false;
    }
}
}
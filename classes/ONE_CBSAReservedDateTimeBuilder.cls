public with sharing class ONE_CBSAReservedDateTimeBuilder {
    private static final String TIME_SEPARATOR = ':';
    private static final String DATE_SEPARATOR = '-';

    @InvocableMethod(label='Parse Reservation Date CBSA' description='Parses the reservation date and time')
    public static List<FlowOutputs> parseReservationDateCBSA(List<FlowInputs> flowInputs) {

        FlowOutputs flowOutputs = new FlowOutputs();
        flowOutputs.reservedDateTime = buildReservedDateTime(flowInputs[0].reservedDate, flowInputs[0].reservedTime);
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            Id = flowInputs[0].serviceId
        );
        if (flowInputs[0].reservationType == 'I' || flowInputs[0].reservationType == 'Incineración') {	
            expediente.ONE_Inicio_Incineracion__c = flowOutputs.reservedDateTime;
        } else {
            expediente.ONE_Hora_destino_final__c = flowOutputs.reservedDateTime;
        }
        update expediente;
        return new List<FlowOutputs>{flowOutputs};
    }

    private static Datetime buildReservedDateTime(String reservedDate, String reservedTime) {
        return Datetime.newInstance(buildReservedDate(reservedDate), buildReservedTime(reservedTime));
    }

    private static Time buildReservedTime(String reservedTime) {
        String[] splittedReservationTime = reservedTime.split(TIME_SEPARATOR);
        return Time.newInstance(
                Integer.valueOf(splittedReservationTime[0]),
                Integer.valueOf(splittedReservationTime[1]),
                0,
                0
        );
    }

    private static Date buildReservedDate(String reservedDate) {
        String[] splittedReservationDate = reservedDate.split(DATE_SEPARATOR);
        return Date.newInstance(
                Integer.valueOf(splittedReservationDate[0]),
                Integer.valueOf(splittedReservationDate[1]),
                Integer.valueOf(splittedReservationDate[2])
        );
    }

    public class FlowInputs {
        @InvocableVariable
        public String reservedDate;
        @InvocableVariable
        public String reservedTime;
        @InvocableVariable
        public String serviceId;
        @InvocableVariable
        public String reservationType;
    }

    public class FlowOutputs {
        @InvocableVariable
        public Datetime reservedDateTime;
    }
}
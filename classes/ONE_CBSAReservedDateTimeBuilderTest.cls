@isTest
private class ONE_CBSAReservedDateTimeBuilderTest {
    @testSetup
    static void setup() {
        ONE_Expediente__c expediente = new ONE_Expediente__c();
        insert expediente;
    }

    @isTest
    static void testParseReservationDateCBSA_Incineration() {
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        ONE_CBSAReservedDateTimeBuilder.FlowInputs input = new ONE_CBSAReservedDateTimeBuilder.FlowInputs();
        input.reservedDate = '2025-03-26';
        input.reservedTime = '14:30';
        input.serviceId = expediente.Id;
        input.reservationType = 'Incineración';
        
        List<ONE_CBSAReservedDateTimeBuilder.FlowOutputs> outputs = ONE_CBSAReservedDateTimeBuilder.parseReservationDateCBSA(new List<ONE_CBSAReservedDateTimeBuilder.FlowInputs>{ input });
        
        Datetime expectedDatetime = Datetime.newInstance(2025, 3, 26, 14, 30, 0);
        System.assertEquals(expectedDatetime, outputs[0].reservedDateTime);
        
        expediente = [SELECT ONE_Inicio_Incineracion__c FROM ONE_Expediente__c WHERE Id = :expediente.Id];
        System.assertEquals(expectedDatetime, expediente.ONE_Inicio_Incineracion__c);
    }

    @isTest
    static void testParseReservationDateCBSA_NonIncineration() {
        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c LIMIT 1];

        ONE_CBSAReservedDateTimeBuilder.FlowInputs input = new ONE_CBSAReservedDateTimeBuilder.FlowInputs();
        input.reservedDate = '2025-03-26';
        input.reservedTime = '16:00';
        input.serviceId = expediente.Id;
        input.reservationType = 'Otro';
        
        List<ONE_CBSAReservedDateTimeBuilder.FlowOutputs> outputs = ONE_CBSAReservedDateTimeBuilder.parseReservationDateCBSA(new List<ONE_CBSAReservedDateTimeBuilder.FlowInputs>{ input });
        
        Datetime expectedDatetime = Datetime.newInstance(2025, 3, 26, 16, 0, 0);
        System.assertEquals(expectedDatetime, outputs[0].reservedDateTime);
        
        expediente = [SELECT ONE_Hora_destino_final__c FROM ONE_Expediente__c WHERE Id = :expediente.Id];
        System.assertEquals(expectedDatetime, expediente.ONE_Hora_destino_final__c);
    }
}
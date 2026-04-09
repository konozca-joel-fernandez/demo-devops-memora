public class ONE_sendMailPendienteZona {

    public class Input {
        @InvocableVariable(required=true)
        public Id templateId;

        @InvocableVariable(required=true)
        public Id queueId;

        @InvocableVariable(required=true)
        public Id recordId;
        
        @InvocableVariable(required=true)
        public String orgWideAddress;
    }

    @InvocableMethod(label='Enviar correo Caso Pendiente de Zona' description='Envía correos usando plantilla a todos los miembros de una cola')
    public static void enqueueEmailJob(List<Input> inputs) {
        for (Input input : inputs) {
            System.enqueueJob(new ONE_sendMailPendienteZonaQueueable(
                input.templateId,
                input.queueId,
                input.recordId,
                input.orgWideAddress
            ));
        }
    }
}
public with sharing class ONE_CBSA_ReservationController {
    
    public static final String ENDPOINT_NAME = 'CBSA_Reservations';

    @InvocableMethod(label='CBSA New Integration' description='Método para realizar reserva en CBSA')
    public static List<FlowOutputs> getReservation(List<FlowInputs> request) {
        return sendPostRequest(request[0]);
    }
    
    public static List<FlowOutputs> sendPostRequest(FlowInputs inputs) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(ONE_IntegrationEndpointSelector.selectIntegrationEndpoint(ENDPOINT_NAME).ONE_Resource__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(ONE_CBSA_ReservationHelper.buildRequest(parseFlowInputs(inputs)));
        try {
            HttpResponse response = http.send(request);
            ONE_CommonUtils.createInboundIntegrationLog('ONE_CBSA_ReservationController', request.getBody(), response.getBody(), request.getMethod(), ENDPOINT_NAME);
            ONE_CBSA_ReservationHelper.CBSAResponse helperResponse = ONE_CBSA_ReservationHelper.parseResponseAndUpdate(response.getBody(), inputs.serviceId);
            return parseFlowOutputs(helperResponse);
        } catch (Exception e) {
            ONE_CommonUtils.createInboundIntegrationLog('ONE_CBSA_ReservationController', request.getBody(), e.getMessage(), request.getMethod(), ENDPOINT_NAME);
            System.debug('Error en la solicitud HTTP: ' + e.getMessage());
            throw new CalloutException('Error en la solicitud HTTP: ' + e.getMessage());
        }
    }
    
    private static ONE_CBSA_ReservationHelper.CBSARequest parseFlowInputs(FlowInputs inputs){
        ONE_CBSA_ReservationHelper.CBSARequest cbsaRequest = new ONE_CBSA_ReservationHelper.CBSARequest();
        cbsaRequest.serviceId = inputs.serviceId;
        cbsaRequest.reservationType = inputs.reservationType;
        cbsaRequest.cementerioInh = inputs.cementerioInh;
        cbsaRequest.cementerioInc = inputs.cementerioInc;
        cbsaRequest.llegadaDifunto = inputs.llegadaDifunto;
        cbsaRequest.asistFam = inputs.asistFam;
        cbsaRequest.inhumationDate = inputs.inhumationDate;
        return cbsaRequest;
    }

    private static List<FlowOutputs> parseFlowOutputs(ONE_CBSA_ReservationHelper.CBSAResponse helperResponse){
        FlowOutputs cbsaResponse = new FlowOutputs();
        cbsaResponse.responseCode = helperResponse.responseCode;
        cbsaResponse.responseMessage = helperResponse.responseMessage;
        cbsaResponse.availableHours = helperResponse.availableHours;
        cbsaResponse.selectedHour = helperResponse.selectedHour;
        cbsaResponse.selectedDate = helperResponse.selectedDate;
        return new List<FlowOutputs>{ cbsaResponse };
    }

    public class FlowInputs{
        @InvocableVariable(label='Id del servicio' required=true)
        public Id serviceId;

        @InvocableVariable(label='Tipo de reserva' description='I - Incineración, E - Inhumación' required=true)
        public String reservationType;

        @InvocableVariable(label='Cementerio Inhumación' description='Código cementerio para Inhumación. Solo obligatorio en inhumación')
        public String cementerioInh;

        @InvocableVariable(label='Cementerio Incineración' description='Código cementerio para Incineración. Solo obligatorio en incineración')
        public String cementerioInc;

        @InvocableVariable(label='Fecha de llegada del difunto' description='Fecha de llegada del difunto a las instalaciones de CBSA')
        public DateTime llegadaDifunto;

        @InvocableVariable(label='Asistencia familiar' description='Tipo de asistencia de la familia')
        public String asistFam;

        @InvocableVariable(label='Fecha de inhumación' description='Fecha de inhumación de consulta o seleccionada. Solo obligatorio en inhumación')
        public DateTime inhumationDate;
    }

    public class FlowOutputs{
        @InvocableVariable(label='Código de solicitud' description='C: Correcto, E: Error, W: Advertencia')
        public String responseCode;

        @InvocableVariable(label='Mensaje de respuesta')
        public String responseMessage;

        @InvocableVariable(label='Horarios Disponibles')
        public List<String> availableHours;

        @InvocableVariable(label='Hora seleccionada')
        public String selectedHour;

        @InvocableVariable(label='Fecha seleccionada')
        public Date selectedDate;
    }

}
public with sharing class ONE_LeadsOlympiaWS {

    @InvocableMethod(label='Generar Lead Olympia')
    public static List<ResponseOutput> enviarPost(List<RequestInput> inputs) {
        List<ResponseOutput> outputResult = new List<ResponseOutput>();
        for (RequestInput input : inputs) {
            ResponseOutput output = new ResponseOutput();
            try {
                
                String body = ONE_LeadsOlympiaWSHelper.buildReqBody(input.opportunityId);

                
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:LeadsOlympiaWSTest'); 
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(body);

                Http http = new Http();
                HttpResponse res = http.send(req);

                if(res.getStatusCode() != 200) {
                    output.success = false;
                    System.debug('Estado petición: ' + res.getStatusCode());
                    System.debug('Cuerpo de la respuesta: ' + res.getBody());
                }else{
                    output.success = true;
                    System.debug('Petición enviada correctamente.');
                    System.debug('Status: ' + res.getStatus());
                    System.debug('Response: ' + res.getBody());
                }
                

               

            } catch (Exception e) {
                System.debug('Error al enviar POST: ' + e.getMessage());
                output.success = false;
            }

            outputResult.add(output);
        }
        return outputResult;
    }

    public class RequestInput {
        @InvocableVariable(label='Oportunidad Id' required=true)
        public Id opportunityId;
    }
    public class ResponseOutput {
        @InvocableVariable(label='Estado de la petición')
        public Boolean success;
    }


}
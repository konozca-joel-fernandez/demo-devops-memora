/**
 * Created by bjaworski002 on 24.01.2022.
 */

public with sharing class ONE_GeneraliPdfBase64 {

    public Id casoId;

    public ONE_GeneraliPdfBase64(List<FlowInput> flowInputs) {
        this.casoId = flowInputs.get(0).casoId;
    }

    @InvocableMethod
    public static List<FlowOutput> encodeAndSendPdf(List<FlowInput> flowInputs) {
        ONE_GeneraliPdfBase64 service = new ONE_GeneraliPdfBase64(flowInputs);
        return service.encodeAndSendPdf();
    }

    private List<FlowOutput> encodeAndSendPdf() {
        FlowOutput output;
        try {
            ONE_Caso__c caso = ONE_CasoSelector.fetchCasosbyIds(new List<Id>{casoId}).get(0);
            String body = buildRequestBody(caso);
            System.debug('Body: ' + body);
            ONE_InsuranceIntegrationCallout.InsuranceService service = caso.ONE_Tipo__c == ONE_CommonConstants.CASO_TIPO_CAJAMAR ? ONE_InsuranceIntegrationCallout.InsuranceService.CAJAMAR : ONE_InsuranceIntegrationCallout.InsuranceService.GENERALI;
            ONE_InsuranceIntegrationCallout.Base64Callout callout = new ONE_InsuranceIntegrationCallout.Base64Callout(body, service);
            HttpResponse response = callout.invokeCallout(false);
            System.debug(response);
            if (response.getStatusCode() == ONE_CommonConstants.HTPP_SUCCESS_CODE) {
                Base64Response responseBody = (Base64Response)JSON.deserialize(response.getBody(), Base64Response.class);
                System.debug('Base64Response: ' + responseBody);
                output = new FlowOutput(true, responseBody);
            } else {
                output = new FlowOutput(false, null, new List<String>{response.getStatusCode() + ' ' + response.getStatus()});
            }
        } catch (Exception e) {
            System.debug(e);
            output = new FlowOutput(false, null, new List<String>{e.getMessage() + '|' + e.getStackTraceString()});
        }
        return new List<FlowOutput>{output};
    }

    private String buildRequestBody(ONE_Caso__c caso) {
        ContentDocumentLink content = ONE_ContentDocumentLinkSelector.fetchContentForGeneralliByCasoId(caso.Id);

        return JSON.serializePretty(new RequestEntryWrapper(caso, content));
    }

    public class RequestEntryWrapper {
        private String claimNumber;
        private List<Document> documents;

        public RequestEntryWrapper(ONE_Caso__c caso, ContentDocumentLink content) {
            this.claimNumber = caso.ONE_Numero_De_Siniestro_Texto__c;
            this.documents = new List<Document>{new Document(content)};
        }
    }

    public class Document {
        private String content;
        private String filename;
        private String type;

        public Document(ContentDocumentLink content) {
            this.content = EncodingUtil.base64Encode(content.ContentDocument.LatestPublishedVersion.VersionData);
            this.filename = content.ContentDocument.LatestPublishedVersion.Title;
            this.type = ONE_CommonConstants.DOCUMENT_TYPE_OTR;
        }
    }

    public virtual class FlowInput {
        @InvocableVariable
        public Id casoId;
    }

    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String codeError;
        @InvocableVariable
        public String errorMessages;

        public FlowOutput(Boolean success, String codeError, List<String> errorMessages) {
            this.success = success;
            this.codeError = codeError;
            this.errorMessages = errorMessages.get(0);
        }

        public FlowOutput(Boolean success, Base64Response response) {
            this.success = success;
            this.codeError = response.codeError;
            this.errorMessages = response.errorMessages?.get(0);
        }
    }

    public class Base64Response {
        String codeError;
        List<String> errorMessages;
    }
}
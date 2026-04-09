/**
 * Created by  on  .
 */

public with sharing class ONE_CDBGraveStatusResponseParser {
    public static final String GRAVE_STATUS_RESPONSE_STATUS = 'status', GRAVE_STATUS_RESPONSE_MESSAGE = 'mensaje',
            GRAVE_STATUS_RESPONSE_PENDING_AMOUNT = 'pendent', GRAVE_STATUS_RESPONSE_CODE = 'codi';

    public static ONE_CDBGraveStatusResponse extractGraveStatusResponse(Dom.Document serviceResponse) {
        return getGraveStatusResponse(ONE_CDBSoapResponseParser.getResponseDocument(serviceResponse));
    }

    static ONE_CDBGraveStatusResponse getGraveStatusResponse(List<Dom.XmlNode> responseDocument) {
        ONE_CDBGraveStatusResponse graveStatusResponse = new ONE_CDBGraveStatusResponse();
        for (Dom.XmlNode documentNode : responseDocument) {
            if (documentNode.getName() == GRAVE_STATUS_RESPONSE_STATUS) {
                graveStatusResponse.status = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, graveStatusResponse.status, GRAVE_STATUS_RESPONSE_STATUS);
            } else if (documentNode.getName() == GRAVE_STATUS_RESPONSE_MESSAGE) {
                graveStatusResponse.mensaje = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, graveStatusResponse.mensaje, GRAVE_STATUS_RESPONSE_MESSAGE);
            } else if (documentNode.getName() == GRAVE_STATUS_RESPONSE_PENDING_AMOUNT) {
                graveStatusResponse.pendent = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, graveStatusResponse.pendent, GRAVE_STATUS_RESPONSE_PENDING_AMOUNT);
            }  else if (documentNode.getName() == GRAVE_STATUS_RESPONSE_CODE) {
                graveStatusResponse.codi = ONE_CDBSoapResponseParser.assignNewValueIfOldIsBlank(documentNode, graveStatusResponse.codi, GRAVE_STATUS_RESPONSE_CODE);
            }
        }
        return graveStatusResponse;
    }
    
}
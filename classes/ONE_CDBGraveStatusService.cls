/**
 * Created by mchruscick001 on 08.10.2021 10:41.
 */

public with sharing class ONE_CDBGraveStatusService {

    @InvocableMethod(Label='Grave Status Service')
    public static List<GraveStatusResponse> getGraveStatus(List<Id> presupuestoId) {
        return new List<GraveStatusResponse>{new GraveStatusResponse(processGraveStatusResponse(doRequest(presupuestoId[0])))};
    }

    static Dom.Document doRequest(Id presupuestoId) {
        return ONE_CDBService.callCDBGraveStatusService(ONE_CDBGraveStatusRequestBuilder.buildRequest(ONE_PresupuestoSelector.selectPresupuesto(presupuestoId)));
    }

    static ONE_CDBGraveStatusResponse processGraveStatusResponse(Dom.Document response) {
        return ONE_CDBGraveStatusResponseParser.extractGraveStatusResponse(response);
    }

    public class GraveStatusResponse {
        @InvocableVariable
        public ONE_CDBGraveStatusResponse graveStatusResponse;

        public GraveStatusResponse(ONE_CDBGraveStatusResponse graveStatusResponse) {
            this.graveStatusResponse = graveStatusResponse;
        }
    }
}
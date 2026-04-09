/**
 * Created by mchruscick001 on 11.10.2021 09:04.
 */

public with sharing class ONE_CDBResponseMockService {
    
    public static String getConstructedGraveStatusResponse() {
        return new ONE_CDBResponseMockBuilder().buildGraveStatusResponse();
    }
    
    public static String getConstructedCancelResponse() {
        return new ONE_CDBResponseMockBuilder().buildCancelResponse();
    }    
    
    public static String getConstructedReservationResponse() {
        return new ONE_CDBResponseMockBuilder().buildMakeAnReservationResponse();
    } 
    
    public static String getConstructedAvailableTimesResponse() {
        return new ONE_CDBResponseMockBuilder().buildGetAvailableTimesResponse();
    }

    public static String getConstructedContractWithErrorsResponse() {
        return new ONE_CDBResponseMockBuilder().buildContractWithErrorsResponse();
    }
    
    public static String getConstructedContractWithoutErrorsResponse() {
        return new ONE_CDBResponseMockBuilder().buildContractWithoutErrorsResponse();
    }

    public static String getConstructedContractWithProductsAndInvoicesWithoutErrorsResponse() {
        return new ONE_CDBResponseMockBuilder().buildContractWithProductsAndInvoicesWithoutErrorsResponse();
    }

    public class CDBServiceResponseMock implements HttpCalloutMock {
        protected Integer code;
        protected String body;
        public CDBServiceResponseMock(String body) {
            this.code = ONE_CommonConstants.HTPP_SUCCESS_CODE;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(this.body);
            res.setStatusCode(this.code);
            return res;
        }
    }
}
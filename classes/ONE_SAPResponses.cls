/**
 * Created by mbujak003 on 22.02.2021.
 */

public with sharing class ONE_SAPResponses {
    public class Metadata {
        public String id  { get; set; }
        public String uri  { get; set; }
        public String type  { get; set; }
    }

    public abstract class BaseResponse {
        public Metadata metadata { get; set; }

        public override String toString() {
            return this.toString().replaceAll('metadata', '__metadata'); 
        }
    }

    public class StockReservationResponse extends BaseResponse {
        public String IMatnr { get; set; }
        public String IMeins { get; set; }
        public Decimal IMenge { get; set; }
        public String IWerks { get; set; }
        public String IZzaufnr { get; set; }
        public String ELgort { get; set; }
        public String ELifnr { get; set; }
        public String EMblnr { get; set; }
        public String EMjahr { get; set; }
        public String EResult { get; set; }
        public String EWerks { get; set; }
        public String IXfuerzawerks { get; set; }
    }

    public class StockConsumptionResponse extends BaseResponse {
        public String Expediente { get; set; }
        public String IMblnr { get; set; }
        public String IMjahr { get; set; }
        public String EMblnrAnulres { get; set; }
        public String EMblnrConsigna { get; set; }
        public String EMblnrConsumo { get; set; }
        public String EMjahrAnulres { get; set; }
        public String EMjahrConsigna { get; set; }
        public String EMjahrConsumo { get; set; }
        public String Result { get; set; }
    }

    public class StockAvailabilityResponse extends BaseResponse {
        public String Material {get; set;}
        public String Centro {get; set;}
        public String Almacen {get; set;}
        public String Proveedor {get; set;}
        public String Unidades {get;set;}
    }

    public class StockConsumptionResponseWrapper {
        public StockConsumptionResponse d { get; set; }
        public StockConsumptionResponseWrapper(StockConsumptionResponse resp) {
            d = resp;
        }
    }

    public class StockReservationResponseWrapper {
        public StockReservationResponse d { get; set; }
        public StockReservationResponseWrapper(StockReservationResponse resp) {
            d = resp;
        }
    }

    public class StockAvailabilityResponseWrapper {
        Map<String, List<StockAvailabilityResponse>> d {get; set;}
        public StockAvailabilityResponseWrapper(Map<String, List<StockAvailabilityResponse>> respMap) {
            d = respMap;
           // Map<String, List<StockAvailabilityResponse>> d = new Map<String, List<StockAvailabilityResponse>>{
            //    'd' => results
           // };
        }
    }
}
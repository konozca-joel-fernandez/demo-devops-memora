@RestResource(UrlMapping='/routes')
global with sharing class ONE_RouteWebService {

    @HttpPost
    global static void upsertStops() {
        try {
            String requestBody = RestContext.request.requestBody.toString();
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            String serviceId = (String) requestMap.get('serviceId');
            List<Object> stopsRaw = (List<Object>) requestMap.get('stops');

            if (String.isBlank(serviceId) || stopsRaw == null) {
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('{"error":"Missing serviceId or stops list"}');
                return;
            }

            List<ONE_Punto_de_Colocacion__c> stopsToUpsert = new List<ONE_Punto_de_Colocacion__c>();
            List<ONE_Punto_de_Colocacion__c> stopsToDelete = new List<ONE_Punto_de_Colocacion__c>();
            Map<Integer, Stop> listPositionToStop = new Map<Integer, Stop>();

            List<Decimal> sliNumbers = new List<Decimal>();
            for (Object rawStop : stopsRaw) {
                Map<String, Object> stopMap = (Map<String, Object>) rawStop;
                if (stopMap.get('SLINumber') != null) {
                    sliNumbers.add(Decimal.valueOf((Integer) stopMap.get('SLINumber')));
                }
            }

            Map<Decimal, Id> sliToLineItemIdMap = new Map<Decimal, Id>();
            if (!sliNumbers.isEmpty()) {
                for (ONE_Expediente_Line_Item__c sli : [
                    SELECT Id, ONE_Numero_SLI__c 
                    FROM ONE_Expediente_Line_Item__c 
                    WHERE ONE_Expediente__c = :serviceId 
                    AND ONE_Numero_SLI__c IN :sliNumbers
                ]) {
                    sliToLineItemIdMap.put(sli.ONE_Numero_SLI__c, sli.Id);
                }
            }

            Integer count = 0;
            Boolean first = true;

            for (Object rawStop : stopsRaw) {
                if (first) {
                    first = false;
                } else {
                    count++;
                }

                Map<String, Object> stopMap = (Map<String, Object>) rawStop;
                Boolean isDeleted = (Boolean) stopMap.get('Deleted');

                if (isDeleted == true) {
                    String idToDelete = (String) stopMap.get('Id');
                    if (!String.isBlank(idToDelete) && !idToDelete.startsWith('selected')) {
                        stopsToDelete.add(new ONE_Punto_de_Colocacion__c(Id = idToDelete));
                    }
                    continue;
                }

                ONE_Punto_de_Colocacion__c stop = new ONE_Punto_de_Colocacion__c();

                String tempId = (String) stopMap.get('Id');
                if (!String.isBlank(tempId) && tempId.startsWith('selected')) {
                    stop.Id = null;
                    listPositionToStop.put(count, (Stop) JSON.deserialize(JSON.serialize(stopMap), Stop.class));
                } else {
                    stop.Id = tempId;
                }

                stop.Name = (String) stopMap.get('Name');
                stop.ONE_Direccion__c = (String) stopMap.get('Address');
                stop.ONE_Municipio__c = (String) stopMap.get('City');
                stop.ONE_Provincia_picklist__c = (String) stopMap.get('Province');
                stop.ONE_Indicaciones_Extra__c = (String) stopMap.get('ExtraInfo');
                stop.ONE_Linea_de_servicio__c = sliToLineItemIdMap.get(Decimal.valueOf((Integer) stopMap.get('SLINumber')));
                stop.ONE_Numero_SLI__c = Decimal.valueOf((Integer) stopMap.get('SLINumber'));
                stop.ONE_Custom__c = (Boolean) stopMap.get('Custom');
                stop.ONE_Seleccionado__c = (Boolean) stopMap.get('Selected');
                stop.ONE_RouteId__c = (String) stopMap.get('RouteId');
                stop.ONE_StopId__c = (String) stopMap.get('StopId');

                stopsToUpsert.add(stop);
            }

            if (!stopsToUpsert.isEmpty()) {
                upsert stopsToUpsert;
            }
            if (!stopsToDelete.isEmpty()) {
                delete stopsToDelete;
            }

            List<Stop> resultList = new List<Stop>();
            for (Integer i = 0; i < stopsToUpsert.size(); i++) {
                if (listPositionToStop.containsKey(i)) {
                    Stop originalStop = listPositionToStop.get(i);
                    String newId = stopsToUpsert[i].Id;
                    originalStop.Id = newId;
                    originalStop.Deleted = false;
                    resultList.add(originalStop);
                }
            }
            
            System.debug('NUEVOS PUNTOS: ' + resultList);
            
        	RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(resultList));

        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(
                '{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}'
            );
        }
    }

    @HttpGet
    global static void getRoutes() {
        String serviceId = RestContext.request.params.get('serviceId');
        String quoteId = RestContext.request.params.get('quoteId');

        if (serviceId == null) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{"error":"Missing required parameter: serviceId"}');
            return;
        }

        Id zonaOperativa = [SELECT ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__c FROM ONE_Expediente__c WHERE Id = :serviceId LIMIT 1].ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__c;

        List<ONE_Ruta__c> rutas = [SELECT Id, Name FROM ONE_Ruta__c WHERE ONE_Lugar__c = :zonaOperativa];

        List<ONE_Punto_de_Interes__c> puntosDeInteres = [SELECT Id, Name, ONE_Direccion__c, ONE_Ruta__c, ONE_Municipio__c,
                                                            ONE_Provincia_picklist__c, ONE_Indicaciones_Extra__c
                                                            FROM ONE_Punto_de_Interes__c WHERE ONE_Ruta__c IN :rutas];

        List<ONE_Expediente_Line_Item__c> lineItems = [SELECT Id FROM ONE_Expediente_Line_Item__c WHERE ONE_Producto__r.ONE_Tipologia_De_Producto_Lookup__r.ONE_Excepcion__c = '09' AND ONE_Expediente__c = :serviceId AND ONE_Presupuesto__c = :quoteId];
        List<Id> lineItemIds = new List<Id>();
        for(ONE_Expediente_Line_Item__c item : lineItems){
            lineItemIds.add(item.Id);
        }

        List<ONE_Punto_de_Colocacion__c> puntosDeColocacion = [SELECT Id, Name, ONE_Direccion__c, ONE_Municipio__c,
                                                                ONE_Provincia_picklist__c, ONE_Indicaciones_Extra__c, ONE_Linea_de_servicio__c,
                                                                ONE_Seleccionado__c, ONE_Custom__c, ONE_RouteId__c, ONE_StopId__c, ONE_Numero_SLI__c
                                                                FROM ONE_Punto_de_Colocacion__c WHERE ONE_Linea_de_servicio__c IN :lineItemIds AND ONE_Invalido__c = false];

        List<Route> routes = new List<Route>();

        for (ONE_Ruta__c ruta : rutas) {
            Route route = new Route();
            route.Id = ruta.Id;
            route.Name = ruta.Name;
            route.Stops = new List<Stop>();

            for (ONE_Punto_de_Interes__c punto : puntosDeInteres) {
                if (punto.ONE_Ruta__c == ruta.Id) {
                    Stop stop = new Stop();
                    stop.Id = punto.Id;
                    stop.Name = punto.Name;
                    stop.Address = punto.ONE_Direccion__c;
                    stop.City = punto.ONE_Municipio__c;
                    stop.Province = punto.ONE_Provincia_picklist__c;
                    stop.ExtraInfo = punto.ONE_Indicaciones_Extra__c;
                    stop.RouteId = punto.ONE_Ruta__c;
                    route.Stops.add(stop);
                }
            }

            routes.add(route);
        }

        List<Stop> stops = new List<Stop>();

        for(ONE_Punto_de_Colocacion__c stop : puntosDeColocacion){
            Stop s = new Stop();
            s.Id = stop.Id;
            s.Name = stop.Name;
            s.Address = stop.ONE_Direccion__c;
            s.City = stop.ONE_Municipio__c;
            s.Province = stop.ONE_Provincia_picklist__c;
            s.ExtraInfo = stop.ONE_Indicaciones_Extra__c;
            s.Selected = stop.ONE_Seleccionado__c;
            s.Custom = stop.ONE_Custom__c;
            s.RouteId = stop.ONE_RouteId__c;
            s.SLINumber = stop.ONE_Numero_SLI__c != null ? stop.ONE_Numero_SLI__c : 0 ;
            s.StopId = stop.ONE_StopId__c;
            stops.add(s);
        }

        Schema.DescribeFieldResult fieldResult = ONE_Punto_de_Colocacion__c.ONE_Provincia_picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<Provincia> provincias = new List<Provincia>();
        for(Schema.PicklistEntry picklistValue : picklistValues){
            Provincia provincia = new Provincia();
            provincia.Value = picklistValue.getValue();
            provincia.Label = picklistValue.getLabel();
            provincias.add(provincia);
        }
		        
        ResponseWrapper response = new ResponseWrapper();
        response.routes = routes;
        response.stops = stops;
        response.provinces = provincias;

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));

    }

    public class ResponseWrapper {
        public List<Route> routes;
        public List<Stop> stops;
        public List<Provincia> provinces;
    }

    public class Route{
        public String Id;
        public String Name;
        public List<Stop> Stops;
    }

    public class Stop{
        public String Id;
        public String Name;
        public String Address;
        public String City;
        public String Province;
        public String ExtraInfo;
        public Boolean Selected;
        public Boolean Custom;
        public String RouteId;
        public Decimal SLINumber;
        public String StopId;
        public Boolean Deleted;
    }

    public class Provincia{
        public String Value;
        public String Label;
    }
}
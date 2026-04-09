@IsTest
public class ONE_ObispadoCanarias_Test {
    private static String samplePDF = 'JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCBSDQovUGFnZXMgMyAwIFINCj4+DQplbmRvYmoNCg0KMiAwIG9iag0KPDwNCi9UeXBlIC9PdXRsaW5lcw0KL0NvdW50IDANCj4+DQplbmRvYmoNCg0KMyAwIG9iag0KPDwNCi9UeXBlIC9QYWdlcw0KL0NvdW50IDINCi9LaWRzIFsgNCAwIFIgNiAwIFIgXSANCj4+DQplbmRvYmoNCg0KNCAwIG9iag0KPDwNCi9UeXBlIC9QYWdlDQovUGFyZW50IDMgMCBSDQovUmVzb3VyY2VzIDw8DQovRm9udCA8PA0KL0YxIDkgMCBSIA0KPj4NCi9Qcm9jU2V0IDggMCBSDQo+Pg0KL01lZGlhQm94IFswIDAgNjEyLjAwMDAgNzkyLjAwMDBdDQovQ29udGVudHMgNSAwIFINCj4+DQplbmRvYmoNCg0KNSAwIG9iag0KPDwgL0xlbmd0aCAxMDc0ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBBIFNpbXBsZSBQREYgRmlsZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIFRoaXMgaXMgYSBzbWFsbCBkZW1vbnN0cmF0aW9uIC5wZGYgZmlsZSAtICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjY0LjcwNDAgVGQNCigganVzdCBmb3IgdXNlIGluIHRoZSBWaXJ0dWFsIE1lY2hhbmljcyB0dXRvcmlhbHMuIE1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NTIuNzUyMCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDYyOC44NDgwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjE2Ljg5NjAgVGQNCiggdGV4dC4gQW5kIG1vcmUgdGV4dC4gQm9yaW5nLCB6enp6ei4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjA0Ljk0NDAgVGQNCiggbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDU5Mi45OTIwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNTY5LjA4ODAgVGQNCiggQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA1NTcuMTM2MCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBFdmVuIG1vcmUuIENvbnRpbnVlZCBvbiBwYWdlIDIgLi4uKSBUag0KRVQNCmVuZHN0cmVhbQ0KZW5kb2JqDQoNCjYgMCBvYmoNCjw8DQovVHlwZSAvUGFnZQ0KL1BhcmVudCAzIDAgUg0KL1Jlc291cmNlcyA8PA0KL0ZvbnQgPDwNCi9GMSA5IDAgUiANCj4+DQovUHJvY1NldCA4IDAgUg0KPj4NCi9NZWRpYUJveCBbMCAwIDYxMi4wMDAwIDc5Mi4wMDAwXQ0KL0NvbnRlbnRzIDcgMCBSDQo+Pg0KZW5kb2JqDQoNCjcgMCBvYmoNCjw8IC9MZW5ndGggNjc2ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBTaW1wbGUgUERGIEZpbGUgMiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIC4uLmNvbnRpbnVlZCBmcm9tIHBhZ2UgMS4gWWV0IG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NzYuNjU2MCBUZA0KKCBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY2NC43MDQwIFRkDQooIHRleHQuIE9oLCBob3cgYm9yaW5nIHR5cGluZyB0aGlzIHN0dWZmLiBCdXQgbm90IGFzIGJvcmluZyBhcyB3YXRjaGluZyApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY1Mi43NTIwIFRkDQooIHBhaW50IGRyeS4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NDAuODAwMCBUZA0KKCBCb3JpbmcuICBNb3JlLCBhIGxpdHRsZSBtb3JlIHRleHQuIFRoZSBlbmQsIGFuZCBqdXN0IGFzIHdlbGwuICkgVGoNCkVUDQplbmRzdHJlYW0NCmVuZG9iag0KDQo4IDAgb2JqDQpbL1BERiAvVGV4dF0NCmVuZG9iag0KDQo5IDAgb2JqDQo8PA0KL1R5cGUgL0ZvbnQNCi9TdWJ0eXBlIC9UeXBlMQ0KL05hbWUgL0YxDQovQmFzZUZvbnQgL0hlbHZldGljYQ0KL0VuY29kaW5nIC9XaW5BbnNpRW5jb2RpbmcNCj4+DQplbmRvYmoNCg0KMTAgMCBvYmoNCjw8DQovQ3JlYXRvciAoUmF2ZSBcKGh0dHA6Ly93d3cubmV2cm9uYS5jb20vcmF2ZVwpKQ0KL1Byb2R1Y2VyIChOZXZyb25hIERlc2lnbnMpDQovQ3JlYXRpb25EYXRlIChEOjIwMDYwMzAxMDcyODI2KQ0KPj4NCmVuZG9iag0KDQp4cmVmDQowIDExDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMTkgMDAwMDAgbg0KMDAwMDAwMDA5MyAwMDAwMCBuDQowMDAwMDAwMTQ3IDAwMDAwIG4NCjAwMDAwMDAyMjIgMDAwMDAgbg0KMDAwMDAwMDM5MCAwMDAwMCBuDQowMDAwMDAxNTIyIDAwMDAwIG4NCjAwMDAwMDE2OTAgMDAwMDAgbg0KMDAwMDAwMjQyMyAwMDAwMCBuDQowMDAwMDAyNDU2IDAwMDAwIG4NCjAwMDAwMDI1NzQgMDAwMDAgbg0KDQp0cmFpbGVyDQo8PA0KL1NpemUgMTENCi9Sb290IDEgMCBSDQovSW5mbyAxMCAwIFINCj4+DQoNCnN0YXJ0eHJlZg0KMjcxNA0KJSVFT0YNCg==';
    
    @TestSetup
    public static void dataSetup(){
        ONE_Lugar__c lugarDelegacion = ONE_TestDataFactory.createLugar(null, true); 
        ONE_Lugar__c lugarZona = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarDelegacion.Id), true);
        ONE_Lugar__c lugarArea = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarZona.Id), true);
        
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        Account tanatorio = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 1', ONE_Tipo__c = 'Cementerio', ONE_Lugar__c = lugarArea.Id), true);
        ONE_Expediente__c servicio = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = tanatorio.Id), true);
        
        Account parroquia = new Account(
            Name = 'TestParroquia',
        	ONE_Provincia__c = '38',
            ONE_Sociedad__c = '0500',
            ONE_Centro_Memora_Codigo_SAP__c = '0',
            ONE_CIF__c = '1234567H',
        	ONE_Lugar__c = lugarArea.Id
        );
        insert parroquia;
        
        ONE_Tarea__c ceremonia = new ONE_Tarea__c(
            ONE_External_Id__c = '1',
            ONE_Expediente__c = servicio.Id,
            ONE_Lugar__c = parroquia.Id
        );
        insert ceremonia;
    }
    
    @IsTest
    public static void call3() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/exequia/paymentConfirmation/';
        req.httpMethod = 'POST';
        req.params.put('ID_Exequia', '1');
        req.requestBody =  Blob.valueOf(samplePDF);
        RestContext.request = req;
        RestContext.response = res;
        ONE_ObispadoCanariasWebService.confirmacionDePago();
        Test.stopTest();
    }
    
    @IsTest
    public static void call3Fail() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/exequia/paymentConfirmation/';
        req.httpMethod = 'POST';
        req.params.put('ID_Exequia', '2');
        req.requestBody =  Blob.valueOf(samplePDF);
        RestContext.request = req;
        RestContext.response = res;
        ONE_ObispadoCanariasWebService.confirmacionDePago();
        Test.stopTest();
    }
    
    @IsTest
    public static void call3Fail2() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/exequia/paymentConfirmation/';
        req.httpMethod = 'POST';
        req.params.put('ID_Exequia', '1');
        RestContext.request = req;
        RestContext.response = res;
        ONE_ObispadoCanariasWebService.confirmacionDePago();
        Test.stopTest();
    }
    
    @IsTest
    public static void call3Fail3() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/exequia/paymentConfirmation/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        ONE_ObispadoCanariasWebService.confirmacionDePago();
        Test.stopTest();
    }
    
    @IsTest
    public static void call1(){
        //Test.setMock(HttpCalloutMock.class, new ObispadoCanariasTokenMock('OK', null, 'MjAyMzEyMTE0NDFCMioxMiVBbDYzMjNyakE3cw..'));
        Test.setMock(HttpCalloutMock.class, new ObispadoCanariasMock());
        
        Test.startTest();
        
        ONE_ObispadoCanariasWebService.CrearActualizarExequia([SELECT Id FROM ONE_Tarea__c LIMIT 1].Id);
        
        Test.stopTest();
    }
    
    @IsTest
    public static void call2(){
        //Test.setMock(HttpCalloutMock.class, new ObispadoCanariasTokenMock('OK', null, 'MjAyMzEyMTE0NDFCMioxMiVBbDYzMjNyakE3cw..'));
        Test.setMock(HttpCalloutMock.class, new ObispadoCanariasMock());
        
        ONE_Lugar__c lugarDelegacion = ONE_TestDataFactory.createLugar(null, true); 
        ONE_Lugar__c lugarZona = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarDelegacion.Id), true);
        ONE_Lugar__c lugarArea = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugarZona.Id), true);
        
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);
        Account tanatorio = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 1', ONE_Tipo__c = 'Cementerio', ONE_Lugar__c = lugarArea.Id), true);
        ONE_Expediente__c servicio = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = tanatorio.Id), true);
        
        ONE_Tarea__c newTarea = new ONE_Tarea__c(
            Name = 'Test Tarea',
            ONE_Fecha_Y_Hora__c = DateTime.newInstance(2023, 12, 11, 14, 41, 0), // Hardcoded date and time
            ONE_Expediente__c = servicio.Id
        );
        
       	insert newTarea;


        List<String> ceremonias = new List<String>();
        ceremonias.add(newTarea.Id);
        
        
        ContentVersion cv = new ContentVersion(Title = 'pdfTest', VersionData = Blob.valueOf(samplePDF), PathOnClient = 'pdfTest');
        insert cv;
        
        Test.startTest();
        
        ONE_Tarea__c ceremonia = [SELECT Id, Name, ONE_Fecha_Y_Hora__c  FROM ONE_Tarea__c 	LIMIT 1];
        ceremonia.ONE_Fecha_Y_Hora__c = DateTime.now();
        
        
        ONE_ObispadoCanariasWebService.ValidarPagoExequias(ceremonias, cv.Id);
        
        Test.stopTest();
    }
    
    @TestVisible
    private class ObispadoCanariasMock implements HttpCalloutMock {
        
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            
            String endpoint = req.getEndpoint();
            
            if(endpoint.contains('gettoken')) {
                response.setBody('{' +
					'"status": "OK",' + 
					'"message": null,' +
					'"data": "MjAyMzEyMTE0NDFCMioxMiVBbDYzMjNyakE3cw.."' +
					'}'
                );
            } else {
                if(endpoint.contains('tipo=crearactualizarexequia')){
                    response.setBody('{' +
                        '"status": "OK",' +
                        '"message": null,' +
                        '"data": {' +
                        	'"coste":"70",' +
                            '"IBAN":"ES1213456789",' +
                            '"idexequia":"3",' +
                            '"numregistro":"REG1"' +
                        '}' +
                    '}'
                	);
                } 
                if(endpoint.contains('tipo=validacionpago')){
                    response.setBody('{' +
                        '"status": "OK",' +
                        '"message": null,' +
                        '"data": "OK"' +
                        '}'
                	);
                }    
            }
            return response;
        }
    }
    @TestVisible
    private class ObispadoCanariasCrearActualizarMock implements HttpCalloutMock {
        protected String status;
        protected String message;
        protected DataCreateExequias data;

        public ObispadoCanariasCrearActualizarMock(String status, String message, DataCreateExequias data) {
            this.status = status;
            this.message = message;
            this.data = data;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(JSON.serialize(this));
            return res;
        }
    }
    @TestVisible
    private class ObispadoCanariasValidarPago implements HttpCalloutMock {
        protected String status;
        protected String message;
        protected String data;

        public ObispadoCanariasValidarPago(String status, String message, String data) {
            this.status = status;
            this.message = message;
            this.data = data;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(JSON.serialize(this));
            return res;
        }
    }
    
    public class DataCreateExequias {
        public String coste;
        public String IBAN;
        public Integer idexequia;
        public String numregistro;
        
        public DataCreateExequias(String coste, String IBAN, Integer idexequia, String numregistro){
            this.coste = coste;
            this.IBAN = IBAN;
            this.idexequia = idexequia;
            this.numregistro = numregistro;
        }
    }
    
}
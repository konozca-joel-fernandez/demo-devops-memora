/**
 * Created by Miguel Serrat on 09.11.2023
 * Last Modified by Alex Climent on 08.07.2024 (ORI - 6158 La diócesis en la respuesta de la 1er llamada nos devolverá un PDF. El documento devuelto deberá guardarse en el servicio y NO deberá verse en el billing companyes. Los pasos a seguir que propuso javier es hacer una primera llamada en preprod para ver si se devuelve correctamente el pdf y luego realizar los cambios pertinentes en SF. )
 * 
 * LOGs:
 * -------------------------------------------
 * DATE       USER            CHANGE
 * -------------------------------------------
 */

@RestResource(UrlMapping='/exequia/paymentConfirmation')
global with sharing class ONE_ObispadoCanariasWebService {


    @HttpPost
    global static void confirmacionDePago(){
        String exequiaID = RestContext.request?.params?.get('ID_Exequia');
     
        //ERR 400 no ID_Exequia
		if(exequiaID == null ) {
            Map<String, Object> errKey2ErrVal = new Map<String, Object> {
                'message' => 'missing \'ID_Exequia\' parameter',
                'code' => 400
            };

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errKey2ErrVal));
            RestContext.response.statusCode = Integer.valueOf(errKey2ErrVal.get('code'));
            return;
        }
        
        ONE_Tarea__c ceremonia;
        ONE_Expediente__c servicio;
        
        try {
            ceremonia = [SELECT Id, ONE_Expediente__c FROM ONE_Tarea__c WHERE ONE_External_Id__c = :exequiaID];
        	servicio = [SELECT Id, Name, ONE_Difunto__r.Name, ONE_Difunto__r.ONE_Apellidos__c, ONE_Centro_Del_Expediente__r.Name 
                        FROM ONE_Expediente__c 
                        WHERE Id = :ceremonia.ONE_Expediente__c];
        } catch(Exception e) {
            //ERR 404 service not found
            Map<String, Object> errKey2ErrVal = new Map<String, Object> {
                'message' => 'Not found!' + e,
                'code' => 404
            };

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errKey2ErrVal));
            RestContext.response.statusCode = Integer.valueOf(errKey2ErrVal.get('code'));
            return;
        }
        
        String reqBody = RestContext.request?.requestBody?.toString();
        
        //ERR 400 no pdf
        if(reqBody == null || reqBody == '') {
            Map<String, Object> errKey2ErrVal = new Map<String, Object> {
                'message' => 'missing \'PDF_Payment_Confirmation\' in body',
                'code' => 400
            };
                        
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errKey2ErrVal));
            RestContext.response.statusCode = Integer.valueOf(errKey2ErrVal.get('code'));
            return;
        }
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Suplidos - ' + servicio.ONE_Centro_Del_Expediente__r.Name + ' ' + servicio.Name + ' EXEQUIA ' + servicio.ONE_Difunto__r.Name + ' ' + servicio.ONE_Difunto__r.ONE_Apellidos__c + '.pdf';
        cv.PathOnClient = 'Suplidos - ' + servicio.ONE_Centro_Del_Expediente__r.Name + ' ' + servicio.Name + ' EXEQUIA ' + servicio.ONE_Difunto__r.Name + ' ' + servicio.ONE_Difunto__r.ONE_Apellidos__c + '.pdf';
        cv.VersionData = EncodingUtil.base64Decode(reqBody);
        cv.TagCsv = 'Suplidos';
        cv.IsMajorVersion = true;
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = servicio.Id;
        //V - Viewer permission. C - Collaborator permission. I - Inferred permission
        cdl.ShareType = 'V';
        Insert cdl;
        
        ceremonia.ONE_Estado_Exequias__c = 'Aprobado';
        update ceremonia;
        
        //OK 200
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(exequiaID));
        RestContext.response.statusCode = Integer.valueOf(200);
    }
    
    @InvocableMethod(label='IntegracionExequias' description='OP 1 : crearActualizarExequia. OP 2 : confirmacion de pago')
    public static void IntegracionExequias(List<FlowInput> inputs){
        try {
            FlowInput input = inputs[0];
            if (input.option == '1'){
                CrearActualizarExequia(input.tareasId[0]);
            }
            
            if (input.option == '2'){
                ValidarPagoExequias(input.tareasId, input.pdfIds[0]);
            }
        } catch (Exception err) {
            throw err;
        }
       
	}
    
    @Future(callout=true)
    public static void CrearActualizarExequia(String tareaId){
        if(tareaId == null){
            throw createApplicationException('No Tarea ID');
        }
        ONE_Tarea__c ceremonia = [SELECT Id, 
                                  ONE_Nombre_Y_Apellidos_Del_Difunto__c, 
                                  ONE_Fecha_Y_Hora__c,
                                  ONE_Expediente__r.Id,
                                  ONE_External_Id__c,
                                  ONE_Precio_De_Compra__c,
                                  ONE_Comentarios__c,
                                  ONE_Parroco_Exequias__c,
                                  ONE_Tipo_de_servicio_Exequias__c,
                                  ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Pagador_Compania__r.Name,
                                  ONE_Lugar__r.ONE_CIF__c
                                  FROM ONE_Tarea__c 
                                  WHERE Id = :tareaId
                                  LIMIT 1];
        String response = '';

		ONE_Expediente__c servicio;
        
        try {
            
            servicio = [SELECT Id, Name, ONE_Difunto__r.Name, ONE_Difunto__r.ONE_Apellidos__c, ONE_Centro_Del_Expediente__r.Name 
                        FROM ONE_Expediente__c 
                        WHERE Id = :ceremonia.ONE_Expediente__c];
        } catch(Exception e) {
            //ERR 404 service not found
            Map<String, Object> errKey2ErrVal = new Map<String, Object> {
                'message' => 'Not found!' + e,
                    'code' => 404
                    };    
                        
                        }
                        
                        
        if(ceremonia.ONE_Lugar__r.ONE_CIF__c == null){
            throw createApplicationException('PARROQUIA SIN CIF');
        }
          
        
        system.debug('ssss');
        Map<String, Object> params = new Map<String, Object>{
            'tipo' => 'crearactualizarexequia',
            'difunto' => ceremonia.ONE_Nombre_Y_Apellidos_Del_Difunto__c != null ? EncodingUtil.urlEncode(ceremonia.ONE_Nombre_Y_Apellidos_Del_Difunto__c,'UTF-8') : '',
            'idexequiaSF' => ceremonia.Id != null ? ceremonia.Id : '',
            'fecha' => ceremonia.ONE_Fecha_Y_Hora__c != null ? EncodingUtil.urlEncode(ceremonia.ONE_Fecha_Y_Hora__c.format('dd-MM-yyyy'),'UTF-8') : '',
            'hora' => ceremonia.ONE_Fecha_Y_Hora__c != null ? EncodingUtil.urlEncode(ceremonia.ONE_Fecha_Y_Hora__c.format('HH:mm'),'UTF-8') : '',
            'cifparroquia' => ceremonia.ONE_Lugar__r.ONE_CIF__c != null ? EncodingUtil.urlEncode(ceremonia.ONE_Lugar__r.ONE_CIF__c,'UTF-8') : '',
            'parroco' => ceremonia.ONE_Parroco_Exequias__c != null ? EncodingUtil.urlEncode(ceremonia.ONE_Parroco_Exequias__c,'UTF-8') : '',
            'observaciones' => ceremonia.ONE_Comentarios__c != null ? EncodingUtil.urlEncode(ceremonia.ONE_Comentarios__c,'UTF-8') : '',
            'ciffuneraria' => 'B85012441',
            'aseguradora' => ceremonia.ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Pagador_Compania__r.Name != null 
                ? ceremonia.ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Pagador_Compania__r.Name.contains('GENERALI')
                	? EncodingUtil.urlEncode(ceremonia.ONE_Nombre_Y_Apellidos_Del_Difunto__c,'UTF-8')
                	: ceremonia.ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Pagador_Compania__r.Name.contains('Pompas Fúnebres Tenerife')
            			? EncodingUtil.urlEncode('SANTA LUCIA SA', 'UTF-8')
                        : EncodingUtil.urlEncode(ceremonia.ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Pagador_Compania__r.Name,'UTF-8') 
              	: ceremonia.ONE_Nombre_Y_Apellidos_Del_Difunto__c != null 
                    ? EncodingUtil.urlEncode(ceremonia.ONE_Nombre_Y_Apellidos_Del_Difunto__c,'UTF-8') 
                    : '',
            'tiposervicio' => ceremonia.ONE_Tipo_de_servicio_Exequias__c == 'Exequia' ? 0 : 1
        };
        
        system.debug('tttt');
                                                
        response = new ONE_ObispadoCanariasIntegrationCallout.CrearActualizarExequiaCallout(params).invokeCallout(true).getBody();
        
        ResponseCreateExequias rCE = (ResponseCreateExequias)JSON.deserialize(response, ResponseCreateExequias.class);
        
        if (rCE == null || rCE.data == null) {
            
            throw new applicationException('Invalid API response: ' + response);
            
        }
        if(rCE.status != 'OK'){
            throw createApplicationException('ERROR API: ' + rCE.status);
        }
        
        system.debug('a1 ' + ceremonia.ONE_Precio_De_Compra__c );
        ceremonia.ONE_Precio_De_Compra__c = Decimal.valueOf(rCE.data.coste);
        system.debug('a2 ' + ceremonia.ONE_Precio_De_Compra__c);
        ceremonia.ONE_External_Id__c = String.valueOf(rCE.data.idexequia);
        system.debug('a3 ' + String.valueOf(rCE.data.idexequia));
        ceremonia.ONE_Reg_Exequias__c = rCE.data.numregistro;
        system.debug('a4 ' + rCE.data.numregistro + 'a5 ' + ceremonia.ONE_Reg_Exequias__c);
        ceremonia.ONE_IBAN__c = rCE.data.IBAN;
        ceremonia.ONE_Estado_Exequias__c = 'Solicitada';
        
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Suplidos-.pdf';
        cv.PathOnClient = 'Suplidos-.pdf';
        if(rCE.data.justificante != null){
            cv.VersionData = EncodingUtil.base64Decode(String.valueOf(rCE.data.justificante));
        }
        else cv.VersionData = Blob.valueOf('ddhdhdh');
        cv.TagCsv = 'Suplidos';
        cv.IsMajorVersion = true;
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = servicio.Id;
        //V - Viewer permission. C - Collaborator permission. I - Inferred permission
        cdl.ShareType = 'V';
        Insert cdl;
        
        
        update ceremonia;
        
    }
    
    @Future(callout=true)
    public static void ValidarPagoExequias(List<String> tareas, String pdfId){
        String response = '';
        
        Map<String, Object> params = new Map<String, Object>{
            'tipo' => 'validacionpago'
        };
        
        ContentVersion cv = [SELECT  Title, VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :pdfID];
        String pdf = EncodingUtil.base64Encode(cv.VersionData);
        
        Integer i = 0;
       
        List<ONE_Tarea__c> ceremonias = [SELECT 
                                         	Id, 
                                         	ONE_Expediente__c,
                                        	ONE_External_Id__c, 
                                         	ONE_Fecha_Y_Hora__c,
                                         	ONE_Expediente__r.ONE_Difunto__r.ONE_N_Documento__pc 
                                         FROM ONE_Tarea__c 
                                         WHERE Id IN :tareas];
        
        
        String exequias = '[';
        List<ContentDocumentLink> linkedPDFs = new List<ContentDocumentLink>();
        for (ONE_Tarea__c ceremonia : ceremonias){
            exequias += '{"idexequiaweb":"' + ceremonia.ONE_External_Id__c;
            System.debug('aux ' + ceremonia.ONE_Fecha_Y_Hora__c);
            if (ceremonia.ONE_Fecha_Y_Hora__c != null){
                exequias += '","fecha":"' + ceremonia.ONE_Fecha_Y_Hora__c.format('dd-MM-yyyy');
                exequias += '","hora":"' + ceremonia.ONE_Fecha_Y_Hora__c.format('HH:mm');
            }
            exequias += '"},';        
            
        if (ceremonia.ONE_Expediente__c != null) {
            ContentDocumentLink linkedPDF = new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = ceremonia.ONE_Expediente__c,
                ShareType = 'V');
            linkedPDFs.add(linkedPDF);
            ceremonia.ONE_Estado_Exequias__c = 'Comprobante Enviado';
    
        } 
            
            else {
        system.debug('Missing LinkedEntityId for ceremonia: ' + ceremonia.Id);
        throw new applicationException('Required field LinkedEntityId is missing for ceremonia: ' + ceremonia.Id);
            }

        }
        exequias = exequias.removeEnd(',');
        exequias += ']';
        
        System.debug('exequias: ' + exequias);
        
        String body = 'exequias=' + EncodingUtil.urlEncode(exequias,'UTF-8') +
            		  '&pdfjustificante=' +  EncodingUtil.urlEncode(pdf,'UTF-8');
            
        response = new ONE_ObispadoCanariasIntegrationCallout.ValidacionPagoBase64Callout(params, body).invokeCallout(true).getBody();
        
        ResponseValidarExequias rVE = (ResponseValidarExequias)JSON.deserialize(response, ResponseValidarExequias.class);
        if(rVE.status == 'OK'){
            update ceremonias;
            Insert linkedPDFs;
        } else {
            throw new applicationException('Error: ' + rVE.message);
        }
    }
    
    public class FlowInput {
    	@InvocableVariable(label='Option')
   		public String Option;

	    @InvocableVariable(label='tareaId')
    	public List<String> tareasId;
        
        @InvocableVariable(label='pdf')
        public List<String> pdfIds;
	}
    
    public class ResponseCreateExequias {
        public String status;
        public String message;
        public DataCreateExequias data; 
    }      
    
    public class DataCreateExequias {
        public String coste;
        public String IBAN;
        public Integer idexequia;
        public String numregistro;
        public String justificante;
    }
    
    public class ResponseValidarExequias {
        public String status;
        public String message;
        public String data;
    }   
    
    public class applicationException extends Exception {}
    static applicationException createApplicationException(String message) {
        applicationException ex = new applicationException(message);
        ex.setMessage(message);
        return ex;
    }
}
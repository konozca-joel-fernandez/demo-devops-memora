public class ONE_FacturacionOCASOWS {

    @AuraEnabled
    public static Map<String, String> createRequest (Id odventaId, String ficheroData,String ficheroName){
        Map<String, String> resultsIntegration=new Map<String,String>();
        ONE_Orden_De_Venta__c odventa=getOrdenDeVenta(odventaId);
        RegistrarFacturaRequest requestWrapper =prepareRequestWrapper(odventa, ficheroData, ficheroName);
        System.debug('requestWrapper'+requestWrapper);
        System.debug('JSON'+ JSON.serialize(requestWrapper));
        Ocaso_Integration__mdt ocasoDataLogin=[SELECT ONE_Endpoint__c,ONE_grant_type__c,ONE_client_id__c,ONE_client_secret__c,ONE_username__c,ONE_password__c,ONE_scope__c FROM Ocaso_Integration__mdt WHERE Developername ='LOGIN' LIMIT 1];
        Ocaso_Integration__mdt ocasoDataFactura=[SELECT ONE_Endpoint__c,ONE_grant_type__c,ONE_client_id__c,ONE_client_secret__c,ONE_username__c,ONE_password__c,ONE_scope__c FROM Ocaso_Integration__mdt WHERE Developername='FACTURA' LIMIT 1];
        
        /*Login request*/
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ocasoDataLogin.ONE_Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type='+ocasoDataLogin.ONE_grant_type__c+
                    '&client_id='+ocasoDataLogin.ONE_client_id__c+
                    '&client_secret='+ocasoDataLogin.ONE_client_secret__c+
                    '&username='+ocasoDataLogin.ONE_username__c+
                    '&password='+ocasoDataLogin.ONE_password__c+
                    '&scope='+ocasoDataLogin.ONE_scope__c);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('Status code; '+res.getStatusCode() + ' ' + res.getStatus());
        if(res.getStatusCode() != 200 ) {
            System.debug('Response Login: ' + res.getStatusCode() + ' ' + res.getStatus());
        }else{
            System.debug('Response Login: ' + res.getStatusCode() + ' - ' + res.getStatus());

            /*Facturacion request*/ 
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String token = (String)results.get('access_token');
            System.debug('token'+token);    
            HttpRequest req2 = new HttpRequest();
            req2.setEndpoint(ocasoDataFactura.ONE_Endpoint__c);
            req2.setMethod('PUT');
            req2.setHeader('Authorization', 'Bearer ' + token);
            req2.setHeader('Content-Type', 'application/json');
            req2.setBody(JSON.serialize(requestWrapper));
            HTTPResponse res2 = http.send(req2);
            System.debug(res2.getBody());
            Map<String, Object> results2 = (Map<String, Object>)JSON.deserializeUntyped(res2.getBody());

            resultsIntegration.put('statusCode',String.valueOf(res2.getStatusCode()));
            resultsIntegration.put('codigoError',String.valueOf(results2.get('codigoError')));
            resultsIntegration.put('messageError',String.valueOf(results2.get('descripcionError')));
            //Map<String, Object> documentosAnexados=(Map<String, Object>)results2.get('documentosAnexados');
            List<Object> documentosAnexados = (List<Object>)(results2.get('documentosAnexados'));
            for(Object documento : documentosAnexados){
                Map<String, Object> results3=(Map<String, Object>)documento;
                resultsIntegration.put('idDocumentum',String.valueOf(results3.get('idDocumentum')));
            }
            ONE_IntegrationLog integrationLog = new ONE_IntegrationLog(
                'ONE_FacturacionOCASOWS',
                req2.getBody(),
                res2.getBody(),
                req2.getMethod(),
                req2.getEndpoint(),
                ONE_IntegrationLog.Direction.OUTBOUND
            );
            ONE_IntegrationLog.commitLog(integrationLog, true, true);
        
        }
        
        return resultsIntegration;
    }
    
    private static RegistrarFacturaRequest prepareRequestWrapper(ONE_Orden_De_Venta__c odventa,String ficheroData,String ficheroName) {
        RegistrarFacturaRequest requestWrapper = new RegistrarFacturaRequest();
        requestWrapper.factura=prepareFactura(odventa);
        requestWrapper.anexos=prepareAnexos(odventa, ficheroData, ficheroName);
        return requestWrapper;
    }
    
    private static factura prepareFactura(ONE_Orden_De_Venta__c odventa){
        factura factura =new factura(); 
        factura.cabecera=prepareCabecera(odventa);
        factura.impuestos=prepareImpuestos(odventa);
        factura.retenciones=null;
        factura.elementos=prepareElementos(odventa);
        return factura;
    }

    private static cabecera prepareCabecera(ONE_Orden_De_Venta__c odventa){
        cabecera cabecera=new cabecera();
        cabecera.datosProveedor=prepareDatosProveedor(odventa);
        cabecera.companiaOcaso='01';
        cabecera.idDocumentoFactura=odventa.ONE_Numero_de_factura__c;
        cabecera.numeroFactura=odventa.ONE_Numero_de_factura__c;
        cabecera.importeLiquido=odventa.ONE_Importe_Total__c;
        cabecera.fechaFactura=String.valueOf(odventa.ONE_Fecha_De_Facturacion__c);
        cabecera.idSiniestro=odventa.ONE_Servicio__r.ONE_Numero_de_Siniestro__c;
        cabecera.numPoliza=odventa.ONE_Servicio__r.ONE_Numero_de_Poliza__c;
        cabecera.observaciones= odventa.ONE_Observaciones__c;
        //cabecera.facturaRectificada=prepareFacturaRectificada(odventa); no se mandarán abonos
        cabecera.facturaRectificada=null;
        cabecera.suplidos=odventa.ONE_Importe_Neto_Suplido__c!=null && odventa.ONE_Importe_Neto_Suplido__c >0;
        cabecera.importeTotalSuplidos=odventa.ONE_Importe_Neto_Suplido__c;
        cabecera.detalleSuplidos=null;
        cabecera.emailComunicaciones='cuentasacobrar@memora.es';
        return cabecera;
    }

    private static datosProveedor prepareDatosProveedor(ONE_Orden_De_Venta__c odventa){
        datosProveedor datosProveedor=new datosProveedor();
        datosProveedor.nifProveedor=odventa.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_CIF__c;
        datosProveedor.nombreProveedor=odventa.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name;
        return datosProveedor;
    }

    private static facturaRectificada prepareFacturaRectificada(ONE_Orden_De_Venta__c odventa){
        facturaRectificada facturaRectificada=new facturaRectificada(); 
        facturaRectificada.numFacturaRectificada=odventa.ONE_Numero_Abono_Factura__c;
        facturaRectificada.fechaFacturaRectificada=String.valueOf(Date.valueOf(odventa.ONE_Fecha_Hora_Del_Abono_Factura__c));
        facturaRectificada.tipoRectificativa='N';
        return facturaRectificada;
    }

    private static detalleSuplidos prepareDetalleSuplidos(ONE_Orden_De_Venta__c odventa){
        detalleSuplidos detalleSuplidos= null;
        /*detalleSuplidos.suplidoProveedor=odventa.ONE_Importe_Neto_Suplido__c!=null && odventa.ONE_Importe_Neto_Suplido__c >0;
        detalleSuplidos.importeTotalSuplidoProveedor=odventa.ONE_Importe_Neto_Suplido__c;
        detalleSuplidos.suplidoPerceptor=false;
        detalleSuplidos.importeSuplidoPerceptor=null;
        detalleSuplidos.suplidosProveedor=prepareSuplidosProveedor(odventa);
        detalleSuplidos.suplidosProveedor=null;
        detalleSuplidos.suplidosPerceptor=null;*/
        return detalleSuplidos;
    }
    /*
    private static List<suplidosProveedor> prepareSuplidosProveedor (ONE_Orden_De_Venta__c odventa){
        List<suplidosProveedor> suplidosProveedor=new List<suplidosProveedor>();
        List<ONE_Expediente_Line_Item__c> slis=getSLISuplidos(odventa.Id);
        for(ONE_Expediente_Line_Item__c sli :slis){
            suplidosProveedor suplidoProveedor=new suplidosProveedor();
            suplidoProveedor.cabecera=prepareCabeceraSuplidos(sli,odventa);
            suplidoProveedor.impuestos=prepareImpuestosSuplido(sli);
            suplidoProveedor.retenciones=null;
            suplidoProveedor.elementos=prepareElementosSuplido(sli);
            suplidosProveedor.add(suplidoProveedor);
        }
       
        return suplidosProveedor;
    }
   
    private static cabecera prepareCabeceraSuplidos (ONE_Expediente_Line_Item__c sli,ONE_Orden_De_Venta__c odventa){
        cabecera cabeceraSuplidos=new cabecera();
        cabeceraSuplidos.datosProveedor=prepareDatosProveedorSuplido(sli);
        cabeceraSuplidos.companiaOcaso='01';
        cabeceraSuplidos.idDocumentoFactura= odventa.ONE_Numero_de_factura__c;
        cabeceraSuplidos.numeroFactura='DUDA'; //DUDA
        cabeceraSuplidos.importeLiquido= sli.ONE_Importe_Neto__c;
        cabeceraSuplidos.fechaFactura= String.valueof(Date.today()); //DUDA
        cabeceraSuplidos.idSiniestro=odventa.ONE_Servicio__r.ONE_Numero_de_Siniestro__c;
        cabeceraSuplidos.numPoliza= odventa.ONE_Servicio__r.ONE_Numero_de_Poliza__c;
        cabeceraSuplidos.observaciones= 'factura suplida';
        return cabeceraSuplidos;
    }
    private static datosProveedor prepareDatosProveedorSuplido(ONE_Expediente_Line_Item__c sli){
        datosProveedor datosProveedorSuplido=new datosProveedor();
        datosProveedorSuplido.nifProveedor=sli.ONE_Proveedor_Suplido__r.ONE_N_Documento__pc!=null ?sli.ONE_Proveedor_Suplido__r.ONE_N_Documento__pc:'PRUEBANIF' ; //DUDA
        datosProveedorSuplido.nombreProveedor=sli.ONE_Proveedor_Suplido__r.Name; //DUDA
      return datosProveedorSuplido;
    }
    private static List<impuestos> prepareImpuestosSuplido (ONE_Expediente_Line_Item__c sli){
        List<impuestos> impuestosList=new List<impuestos>();
        impuestos impuesto=new impuestos();
        impuesto.baseImponible=sli.ONE_Importe_Base__c;
        impuesto.porcentajeIva=sli.ONE_Impuesto__c;
        impuesto.tipoImpuesto='IVA';
        impuesto.importeIVA=sli.ONE_Importe_Impuesto__c;
        impuestosList.add(impuesto);
        return impuestosList;
    }
    private static List<elementos> prepareElementosSuplido (ONE_Expediente_Line_Item__c sli){
        List<elementos> elementosList=new List<elementos>();
        elementos elemento =new elementos();
        elemento.cantidad=sli.ONE_Cantidad__c;
        elemento.descripcion=sli.ONE_Producto__r.Name;
        elemento.importe=sli.ONE_Importe_Neto__c;
        elemento.importeIVA=sli.ONE_Importe_Impuesto__c;
        elemento.porcentajeIVA=sli.ONE_Impuesto__c;
        elemento.tipoImpuesto='IVA';
        elementosList.add(elemento);
        return elementosList;
    }*/
    private static List<impuestos> prepareImpuestos (ONE_Orden_De_Venta__c odventa){
        List<impuestos> impuestosList= new  List<impuestos>();
        if(odventa.ONE_Importe_Neto_0__c!=null && odventa.ONE_Importe_Neto_0__c !=0){
            impuestos impuesto0=new impuestos();
            impuesto0.baseImponible=odventa.ONE_Importe_Base_0__c;
            impuesto0.porcentajeIva=0;
            impuesto0.tipoImpuesto='IVA';
            impuesto0.importeIVA=odventa.ONE_Importe_Impuesto_0__c;
            impuestosList.add(impuesto0);

        }
        if(odventa.ONE_Importe_Neto_3__c!=null && odventa.ONE_Importe_Neto_3__c!=0){
            impuestos impuesto3=new impuestos();
            impuesto3.baseImponible=odventa.ONE_Importe_Base_3__c;
            impuesto3.porcentajeIva=3;
            impuesto3.tipoImpuesto='IGI';
            impuesto3.importeIVA=odventa.ONE_Importe_Impuesto_3__c;
            impuestosList.add(impuesto3);
        }
        if(odventa.ONE_Importe_Neto_4__c!=null && odventa.ONE_Importe_Neto_4__c!=0){
            impuestos impuesto4=new impuestos();
            impuesto4.baseImponible=odventa.ONE_Importe_Base_4__c;
            impuesto4.porcentajeIva=4;
            impuesto4.tipoImpuesto='IVA';
            impuesto4.importeIVA=odventa.ONE_Importe_Impuesto_4__c;
            impuestosList.add(impuesto4);
        }
        if(odventa.ONE_Importe_Neto_10__c!=null && odventa.ONE_Importe_Neto_10__c!=0){
            impuestos impuesto10=new impuestos();
            impuesto10.baseImponible=odventa.ONE_Importe_Base_10__c;
            impuesto10.porcentajeIva=10;
            impuesto10.tipoImpuesto='IVA';
            impuesto10.importeIVA=odventa.ONE_Importe_Impuesto_10__c;
            impuestosList.add(impuesto10);
        }
        if(odventa.ONE_Importe_Neto_21__c!=null && odventa.ONE_Importe_Neto_21__c!=0){
            impuestos impuesto21=new impuestos();
            impuesto21.baseImponible=odventa.ONE_Importe_Base_21__c;
            impuesto21.porcentajeIva=21;
            impuesto21.tipoImpuesto='IVA';
            impuesto21.importeIVA=odventa.ONE_Importe_Impuesto_21__c;
            impuestosList.add(impuesto21);
        }
        return impuestosList;
    }
    private static  List<elementos> prepareElementos (ONE_Orden_De_Venta__c odventa){
        List<elementos> elementosList= new  List<elementos>();
        List<ONE_Expediente_Line_Item__c> slis=getSLISAsociadas(odventa.Id);
        for (ONE_Expediente_Line_Item__c sli : slis) {
            elementos elemento =new elementos();
            elemento.cantidad=sli.ONE_Cantidad__c;
            elemento.descripcion=sli.ONE_Producto__r.Name;
            elemento.importe=sli.ONE_Importe_Neto__c;
            elemento.importeIVA=sli.ONE_Importe_Impuesto__c;
            elemento.porcentajeIVA=sli.ONE_Impuesto__c;
            elemento.tipoImpuesto=sli.ONE_Impuesto__c == 3?'IGI':'IVA';
            elementosList.add(elemento);
        }
        
        return elementosList;
    }

    private static List<anexos> prepareAnexos(ONE_Orden_De_Venta__c odventa,String ficheroData, String ficheroName){
        List<anexos> anexosList = new  List<anexos>();
        anexos anexo =new anexos();
        anexo.idDocumentoFactura=odventa.ONE_Numero_de_factura__c;
        anexo.tipoFactura='P';
        anexo.nombreFichero=ficheroName;
        anexo.fichero=String.valueOf(ficheroData);
        anexosList.add(anexo);
        return anexosList;
    }

    private static ONE_Orden_De_Venta__c getOrdenDeVenta(Id odventaId){
        return [SELECT Id,ONE_Fecha_De_Facturacion__c,ONE_Numero_de_factura__c,ONE_Importe_Total__c,ONE_Servicio__r.ONE_Numero_de_Siniestro__c,
        ONE_Servicio__r.ONE_Numero_de_Poliza__c,ONE_Observaciones__c,ONE_Importe_Neto_Suplido__c,ONE_Numero_Abono_Factura__c,
        ONE_Fecha_Hora_Del_Abono_Factura__c,ONE_Importe_Neto_0__c,ONE_Importe_Neto_3__c,ONE_Importe_Neto_4__c,ONE_Importe_Neto_10__c,
        ONE_Importe_Neto_21__c,ONE_Importe_Base_0__c,ONE_Importe_Base_3__c,ONE_Importe_Base_4__c,ONE_Importe_Base_10__c,ONE_Importe_Base_21__c,
        ONE_Importe_Impuesto_0__c,ONE_Importe_Impuesto_3__c,ONE_Importe_Impuesto_4__c,ONE_Importe_Impuesto_10__c,ONE_Importe_Impuesto_21__c,
        ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_CIF__c
        FROM ONE_Orden_De_Venta__c 
        WHERE Id =:odventaId];
    }

    private static List<ONE_Expediente_Line_Item__c> getSLISAsociadas(Id odventaId){
        return [SELECT Id, ONE_Producto__r.Name, ONE_Cantidad__c,ONE_Importe_Neto__c,ONE_Importe_Impuesto__c,ONE_Impuesto__c,ONE_Importe_Base__c
                FROM ONE_Expediente_Line_Item__c
                WHERE ONE_Orden_De_Venta__c =:odventaId
                AND ONE_Estado__c='Facturado'];
    }

    private static List<ONE_Expediente_Line_Item__c> getSLISuplidos(Id odventaId){
        return [SELECT Id, ONE_Producto__r.Name,ONE_Importe_Base__c, ONE_Cantidad__c,ONE_Importe_Neto__c,ONE_Importe_Impuesto__c,ONE_Impuesto__c, ONE_Proveedor_Suplido__r.name, ONE_Proveedor_Suplido__r.ONE_N_Documento__pc
                FROM ONE_Expediente_Line_Item__c
                WHERE ONE_Orden_De_Venta__c =:odventaId
                AND ONE_Estado__c='Facturado'
                AND ONE_Suplido__c=true];
    }

    public class RegistrarFacturaRequest {
	public factura factura;
	public anexos[] anexos;
    
    }
	public class factura {
		public cabecera cabecera;
		public impuestos[] impuestos;
		public retenciones[] retenciones;
		public elementos[] elementos;
	}
	public class cabecera {
		public datosProveedor datosProveedor;
		public String companiaOcaso;	
		public String idDocumentoFactura;	
		public String numeroFactura;	
		public Decimal importeLiquido;
		public String fechaFactura;	
		public String idSiniestro;	
		public String numPoliza;	
		public String observaciones;
		public facturaRectificada facturaRectificada;
		public boolean suplidos;
		public Decimal importeTotalSuplidos;	
		public detalleSuplidos detalleSuplidos;
		public String emailComunicaciones;	
	}
	public class datosProveedor {
		public String nifProveedor;
		public String nombreProveedor;
		public Integer idDelegacionGiso;
		public String ciaDelegacionGiso;
		public String oficinaReferencia;
	}
	public class facturaRectificada {
		public String numFacturaRectificada;
		public String fechaFacturaRectificada;
		public String tipoRectificativa;
	}
	public class detalleSuplidos {
		public boolean suplidoProveedor;
		public Decimal importeTotalSuplidoProveedor;
		public boolean suplidoPerceptor;
		public Decimal importeSuplidoPerceptor;
		public suplidosPerceptor[] suplidosPerceptor;
		public suplidosProveedor[] suplidosProveedor;
	}
	public class suplidosPerceptor {
		public datosPersonales datosPersonales;
		public direccion direccion;
		public Decimal importe;
	}
	public class datosPersonales {
		public String nombre;
		public String apellido1;
		public String apellido2;
		public String nif;
	}
	public class direccion {
		public tipoVia tipoVia;
		public String nombreVia;
		public String numero;
		public String codigoPostal;
		public provincia provincia;
		public municipio municipio;
		public submunicipio submunicipio;
		public String localidad;
	}
	public class tipoVia {
		public String codigo;
		public String literal;
	}
	public class provincia {
		public String codigo;
		public String literal;
	}
	public class municipio {
		public String codigo;
		public String literal;
	}
	public class submunicipio {
		public String codigo;
		public String literal;
	}
	public class suplidosProveedor {
		public cabecera cabecera;
		public impuestos[] impuestos;
		public retenciones[] retenciones;
        public elementos[] elementos;
	}
	public class impuestos {
		public Decimal baseImponible;
		public Decimal porcentajeIva;
		public String tipoImpuesto;
		public Decimal importeIVA;
	}
	public class retenciones {
		public Integer porcentajeRetencion;
		public Integer importeRetencion;
	}
	public class elementos {
		public String descripcion;
		public Decimal importe;
		public Decimal cantidad;
		public Decimal importeIVA;
		public Decimal porcentajeIVA;
		public String tipoImpuesto;
	}
	public class anexos {
		public String idDocumentoFactura;
		public String tipoFactura;
		public String nombreFichero;
		public String fichero;
        
	}
    public class ResponseWrapper {
        public String codeError;
        public String[] errorMessages;
    }
	public static ONE_FacturacionOCASOWS parse(String json){
		return (ONE_FacturacionOCASOWS) System.JSON.deserialize(json, ONE_FacturacionOCASOWS.class);
	}

}
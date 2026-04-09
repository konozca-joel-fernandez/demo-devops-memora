/**
 * Created by mbujak003 on 22.02.2021.
 */

 @RestResource(UrlMapping='/client/create')
 global with sharing class ONE_ClientCreationWebService {
     private static final String CLASS_NAME = 'ONE_ClientCreationWebService';
     private static final String ENDPOINT_NAME = 'CLIENT_CREATE';
     private static Map<String, Object> sObject2recordId;
 
     @HttpPost
     global static void createCient() {
         HttpError err = null;
         String jsonStr = null;
 
         sObject2recordId = new Map<String, Object>();
 
         if (null == RestContext.request.requestBody) {
             RestContext.response.addHeader('Content-Type', 'application/json');
             RestContext.response.responseBody = Blob.valueOf('Body is missing!');
             RestContext.response.statusCode = 400;
             return;
         }
         jsonStr = RestContext.request.requestBody.toString();
         ClientDTO dto = null;
 
         try {
 
             dto = (ClientDTO) JSON.deserialize(jsonStr, ClientDTO.class);
 
             processDTO(dto);
 
 
         } catch (Exception ex) {
             System.debug('Hello3');
             RestContext.response.addHeader('Content-Type', 'application/json');
             RestContext.response.responseBody = Blob.valueOf(ex.getMessage());
             RestContext.response.statusCode = 400;
         } finally {
             ONE_CommonUtils.createInboundIntegrationLog(
                 CLASS_NAME,
                 jsonStr,
                 RestContext.response.responseBody.toString(),
                 RestContext.request.httpMethod,
                 ENDPOINT_NAME
             );
         }
 
     }
 
     private static void processDTO(ClientDTO dto) {
         Account acc = null;
 
         if (dto.pedido.TipoCliente == 'Empresa') {
             acc = prepareAccount(dto.pedido);
         } else {
             acc = preparePersonAccount(dto.pedido);
         }
         sObject2recordId.put('AccountId', acc.Id);
         ONE_Interlocutor__c interlocutor = new ONE_Interlocutor__c(
             ONE_Contacto__c = acc.Id,
             ONE_Expediente__c = dto.pedido.idServicioConsulta,
             ONE_Clasificacion__c = 'Participante',
             Name = acc.FirstName + ' ' + acc.LastName + ' - Interlocutor',
             ONE_Pagador__c = true,
             ONE_Relacion_con_el_difunto__c='Otro',
             ONE_Consentimiento_Familiar__c = dto.pedido.consentimientoFamiliar,
             ONE_Tratamiento_Datos_Gestion_Electium__c = dto.pedido.consentimientoElectium,
             ONE_Acepta_condiciones_venta_distancia__c = dto.pedido.consentimientoVentaADistancia,
             ONE_Tratamiento_Datos_Compra_Flores__c = dto.pedido.consentimientoDatosVentaFlores,
             ONE_Aviso_Legal_y_Privacidad__c = dto.pedido.consentimientoAvisoLegal,
             ONE_Tratamiento_Datos_Presupuesto__c = dto.pedido.consentimientoDatosPresupuesto,
             ONE_Acepta_publicidad__c = dto.pedido.consentimientoPublicidad,
             ONE_Tratamiento_Datos_Gestion_Solicitud__c = dto.pedido.consentimientoGestionDatos
         );
         insert interlocutor;
         sObject2recordId.put('interlocutorId', interlocutor.Id);
 
         ONE_Presupuesto__c budget = new ONE_Presupuesto__c(
             RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Presupuesto__c', 'ONE_Presupuesto_WEB'),
             ONE_ID_Comprador_Memora__c = dto.pedido.IDSAPempleado,
             ONE_Interlocutor__c = interlocutor.Id,
             ONE_Estado__c = 'Contratado',
             ONE_Expediente__c = dto.pedido.idServicioConsulta,
             ONE_Presupuesto_preconfigurado__c = false,
             ONE_Tipo_De_Contrato__c = dto.pedido.TipoCliente,
             ONE_Tipo_De_Presupuesto__c = 'Presupuesto web',
             ONE_Total_Importe_Presupuesto__c = dto.pedido.importeTotal != null ? Decimal.valueOf(dto.pedido.importeTotal) : null,
             ONE_Tareas_Lanzadas__c = true, 
             ONE_UTM_Campaign__c=dto.pedido.UTMCampaign,
             ONE_UTM_Content__c=dto.pedido.UTMContent,
             ONE_UTM_Medium__c=dto.pedido.UTMMedium,
             ONE_UTM_Source__c=dto.pedido.UTMSource,
             ONE_UTM_Term__c=dto.pedido.UTMTerm,
             ONE_UTM_gclid__c=dto.pedido.UTMGclid,
             ONE_UTM_Url_Referral__c=dto.pedido.UTMUrlReferral
         );
 
         insert budget;
         sObject2recordId.put('presupuestoId', budget.Id);
 
         ONE_Orden_De_Venta__c orden = new ONE_Orden_De_Venta__c(
             ONE_Generacion_Factura__c = dto.pedido.generacionFactura == 'True',
             ONE_Pagador_Particular__c = interlocutor.Id,
             ONE_Servicio__c = dto.pedido.idServicioConsulta,
             ONE_Fecha_De_Facturacion__c = dto.pedido.fechaDeFacturacion != null ? Date.valueOf(dto.pedido.fechaDeFacturacion) : null,
             ONE_Presupuesto__c = budget.Id,
             ONE_Forma_De_Pago__c = 'H',
             ONE_Importe_Total__c = dto.pedido.importeTotal != null ? Decimal.valueOf(dto.pedido.importeTotal) : null
         );
 		
         insert orden;
         sObject2recordId.put('ordenDeVentaId', orden.Id);
 
         List<String> codigos = new List<String>();
 
         for (LineaPedido linea : dto.lineasPedido) {
             codigos.add(linea.codigoDeProducto);
         }
 
         Map<String, String> codigo2ProductId = new Map<String, String>();
         for (ONE_Producto__c product : [
             SELECT Id, ONE_Codigo_Comercial__c
             FROM ONE_Producto__c
             WHERE Id IN:codigos
         ]) {
             codigo2ProductId.put(product.ONE_Codigo_Comercial__c, product.Id);
         }
 
         List<ONE_Expediente_Line_Item__c> expLineItems = new List<ONE_Expediente_Line_Item__c>();
         for (LineaPedido linea : dto.lineasPedido) {
             expLineItems.add(
                 new ONE_Expediente_Line_Item__c(
                     ONE_Orden_De_Venta__c = orden.Id,
                     ONE_Producto__c = linea.codigoDeProducto, //codigo2ProductId.get(linea.codigoDeProducto),
                     ONE_Cantidad__c = linea.cantidad != null ? Decimal.valueOf(linea.cantidad) : null,
                     ONE_Texto_Banda_O_Lazo__c = (linea.textoBandaOLazo != null ? linea.textoBandaOLazo : '') + (linea.fraseTarjeta != null ? linea.fraseTarjeta : ''),
                     ONE_Tarjeta_O_Lazo__c = linea.lazoOTarjeta,
                     ONE_Estado__c = 'Facturado',
                     ONE_Expediente__c = dto.pedido.idServicioConsulta,
                     ONE_Presupuesto__c = budget.Id,
                     ONE_Categorizacion_De_Linea__c = 'Producto Web',
                     ONE_Nombre_del_Remitente__c = linea.remitente,
                     ONE_Importe_Base__c = linea.importeBase != null ? Decimal.valueOf(linea.importeBase) : null,
                     ONE_Impuesto__c = linea.porcentajeImpuesto != null ? Decimal.valueOf(linea.porcentajeImpuesto) : null,
                     ONE_Importe_Impuesto__c = linea.importeImpuestos != null ? Decimal.valueOf(linea.importeImpuestos) : null,
                     ONE_Precio__c=linea.precioUnitario != null ? Decimal.valueOf(linea.precioUnitario) : null
                 )
             );
         }
         insert expLineItems;
         List<Id> exLineItemsIds = new List<Id>();
         for (ONE_Expediente_Line_Item__c item : expLineItems) {
             exLineItemsIds.add(item.Id);
         }
         sObject2recordId.put('expLineItemsIds', exLineItemsIds);
 
         for (String eliId : exLineItemsIds) {
             invokeTareasAction(eliId, dto.pedido.numPedido, dto.pedido.email);
         }
 
         if (dto.pedido.generacionFactura.equalsIgnoreCase('true')) {
             if (!Test.isRunningTest()) {
                System.debug('GENERACION FACTURA');
                 System.enqueueJob(new ONE_PostClientCreationQueueable.SapClientCreationQueueable(
                     orden.Id,
                     dto.pedido.TipoCliente,
                     dto.pedido.numeroDeDocumento,
                     dto.pedido.idServicioConsulta
                 ));
             }
         } else {
             if (!Test.isRunningTest()) {
                 System.debug('ELSE GENERACION FACTURA');
                 System.enqueueJob(new ONE_PostClientCreationQueueable.SalesOrderActionQueueable(
                     orden.Id,
                     dto.pedido.TipoCliente,
                     dto.pedido.numeroDeDocumento,
                     false,
                     dto.pedido.idServicioConsulta,
                     true
                 ));
             }
         }
 
         RestContext.response.addHeader('Content-Type', 'application/json');
 
         RestContext.response.responseBody = Blob.valueOf(
             JSON.serialize(new Map<String, Object>{
                 'createdRecords' => sObject2recordId
             }, false)
         );
     }
 
     private static Account prepareAccount(Pedido pedido) {
         Account acc = null;
         if (pedido.numeroDeDocumento != null) {
             List<Account> tempAcc = [
                 SELECT Id, FirstName, LastName
                 FROM Account
                 WHERE ONE_CIF__c = :pedido.numeroDeDocumento
             ];
             if (!tempAcc.isEmpty()) {
                 acc = tempAcc[0];
             }
         }
         if (acc == null) {
             acc = new Account(
                 RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
                 Name = pedido.nombreEmpresa,
                 ONE_CIF__c = pedido.numeroDeDocumento,
                 ONE_Pais__c = pedido.pais,
                 ONE_Provincia__c = pedido.provincia,
                 ONE_Municipio_Direccion__c = pedido.municipio,
                 ONE_Direccion__c = pedido.tipoDeCalle + ' ' + pedido.direccion + ', ' + pedido.numeroDeCalle + ' ' + pedido.piso,
                 ONE_Origen_Contacto__c = 'Web',
                 ONE_Codigo_Postal__c = pedido.codigoPostal,
                 Phone = pedido.movil,
                 ONE_Email__c = pedido.email,
                 ONE_Tipo__c = 'Otras entidades',
                 ONE_Estado__c = 'Aceptado por venta',
                 ONE_Indicativo_Tel_fono__c = pedido.indicativotelefono,
                 ONE_Indicativo_M_vil__c = pedido.indicativomovil
             );
             insert acc;
         }
         return acc;
     }
 
     @TestVisible
     private static Account preparePersonAccount(Pedido pedido) {
         Account acc = null;
         if (pedido.numeroDeDocumento != null) {
             List<Account> tempAcc = [
                 SELECT Id, FirstName, LastName
                 FROM Account
                 WHERE ONE_N_Documento__pc = :pedido.numeroDeDocumento
             ];
             if (!tempAcc.isEmpty()) {
                 acc = tempAcc[0];
             }
         }
         if (acc == null) {
             acc = new Account(
                 RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
                 FirstName = pedido.nombreCliente,
                 LastName = pedido.apellido1 + ' ' + pedido.apellido2,
                 ONE_Tipo_de_documento__pc = pedido.tipoDeDocumento,
                 ONE_N_Documento__pc = pedido.numeroDeDocumento,
                 ONE_Pais__pc = pedido.pais,
                 ONE_Provincia__pc = pedido.provincia,
                 ONE_Municipio__pc = pedido.municipio,
                 ONE_Direccion__pc = pedido.tipoDeCalle + ' ' + pedido.direccion + ', ' + pedido.numeroDeCalle + ' ' + pedido.piso,
                 ONE_Origen_Contacto__pc = 'Web',
                 ONE_Codigo_Postal__pc = pedido.codigoPostal,
                 Phone = pedido.movil,
                 ONE_Email__c = pedido.email,
                 ONE_Indicativo_Tel_fono__c = pedido.indicativotelefono,
                 ONE_Indicativo_M_vil__c = pedido.indicativomovil
             );
             insert acc;
         }
         return acc;
     }
 
     @Future
     private static void invokeTareasAction(String expedienteLineItemId, String numPedido, String correoConfirmacion) {
         ONE_EjacutarTareasAction.FlowInputs fi = new ONE_EjacutarTareasAction.FlowInputs();
         fi.expedienteLineItemId = expedienteLineItemId;
         fi.numPedido = numPedido;
         fi.correoConfirmacion = correoConfirmacion;
         ONE_EjacutarTareasAction.invoke(new List<ONE_EjacutarTareasAction.FlowInputs>{
             fi
         });
     }
 
     public class returnObject {
         Integer status { get; set; }
         String message { get; set; }
     }
 
     public class Pedido {
         public String idServicioConsulta { get; set; }
         public String IDSAPempleado { get; set; }
         public String TipoCliente { get; set; }
         public String nombreEmpresa { get; set; }
         public String nombreCliente { get; set; }
         public String apellido1 { get; set; }
         public String apellido2 { get; set; }
         public String tipoDeDocumento { get; set; }
         public String numeroDeDocumento { get; set; }
         public String pais { get; set; }
         public String provincia { get; set; }
         public String municipio { get; set; }
         public String tipoDeCalle { get; set; }
         public String direccion { get; set; }
         public String numeroDeCalle { get; set; }
         public String piso { get; set; }
         public String codigoPostal { get; set; }
         public String movil { get; set; }
         public String email { get; set; }
         public String generacionFactura { get; set; }
         public String fechaDeFacturacion { get; set; }
         public String importeTotal { get; set; }
         public String UTMCampaign { get; set; }
         public String UTMContent { get; set; }
         public String UTMMedium { get; set; }
         public String UTMSource { get; set; }
         public String UTMTerm { get; set; }
         public String UTMGclid { get; set; }
         public String UTMUrlReferral { get; set; }
         public String numPedido { get; set; }
         public Boolean consentimientoFamiliar { get; set; }
         public Boolean consentimientoElectium { get; set; }
         public Boolean consentimientoVentaADistancia { get; set; }
         public Boolean consentimientoDatosVentaFlores { get; set; }
         public Boolean consentimientoPublicidad { get; set; }
         public Boolean consentimientoDatosPresupuesto { get; set; }
         public Boolean consentimientoAvisoLegal { get; set; }
         public Boolean consentimientoGestionDatos{ get; set; }
         public String indicativotelefono{ get; set; }
         public String indicativomovil{ get; set; }

     }
 
     public class LineaPedido {
         public String codigoDeProducto { get; set; }
         public String cantidad { get; set; }
         public String lazoOTarjeta { get; set; }
         public String textoBandaOLazo { get; set; }
         public String fraseTarjeta { get; set; }
         public String remitente { get; set; }
         public String importeImpuestos { get; set; }
         public String porcentajeImpuesto { get; set; }
         public String precioBase { get; set; }
         public String importeBase { get; set; }
         public String precioUnitario { get; set; }
     }
 
     public class ClientDTO {
         @TestVisible
         Pedido pedido { get; set; }
         @TestVisible
         List<LineaPedido> lineasPedido { get; set; }
     }
 
     public class HttpError {
         public String errorMsg { get; set; }
         public Integer errorCode { get; set; }
     }
 }
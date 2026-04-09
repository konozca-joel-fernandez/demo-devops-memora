//Data structure for the comunication with the front end in the generation of the PDF process
public class ONE_PedidoMarmolistaData {
    
    public String logoUrl {public get; private set;} 
    public String documentCode {public get; private set;}
    public String ONE_Doc_Centro {public get; private set;}
    public String ONE_Doc_Telefono {public get; private set;}
    public String ONE_Doc_N_Pedido {public get; private set;}
    public String ONE_Doc_Fecha_Hora_Pedido {public get; private set;}
    public String ONE_Doc_Proveedor {public get; private set;}
    public String ONE_Doc_N_Servicio {public get; private set;}
    public String ONE_Doc_Difunto {public get; private set;}
    public String ONE_Doc_Material_Contratado {public get; private set;} 
    public integer ONE_Doc_Cantidad {public get; private set;}
    public String ONE_Doc_Observaciones_del_material {public get; private set;}
    public String ONE_Doc_Marmolista_Nombre_Apellido {public get; private set;}
    public String ONE_Doc_Marmolista_Cementerio {public get; private set;}
    public String ONE_Doc_Marmolista_Datos_Ubicacion {public get; private set;}
    public String ONE_Doc_Marmolista_Fecha_Lugar_Nacimiento {public get; private set;}
    public String ONE_Doc_Marmolista_Fecha_Hora_Defuncion {public get; private set;}
    public String ONE_Doc_Marmolista_Nombre_Apellidos {public get; private set;}
    public String ONE_Doc_Marmolista_Domicilio {public get; private set;}
    public String ONE_Doc_Marmolista_Telefono {public get; private set;}
    public String ONE_Doc_Marmolista_Email {public get; private set;}
    public String ONE_Doc_Sociedad_Nombre {public get; private set;} 
    public String ONE_Doc_Asesor {public get; private set;} 
    public String ONE_Doc_Marmolista_Tipo_Concesion {public get; private set;} 
    public String ONE_Doc_Marmolista_Observaciones {public get; private set;} 
    public String language {public get; private set;}
    public String ONE_Reproduccion {public get; private set;}
    public String ONE_Inscripcion {public get; private set;}
    public String ONE_Tipografia {public get; private set;}
    public String ONE_Color_Del_Marmol {public get; private set;}
    public String ONE_Tamano {public get; private set;}
        
    
    public ONE_PedidoMarmolistaData(String docCode, ONE_Tarea__c tarea, ONE_Pedido_De_Proveedor__c pedidoProveedor, String language) {
        
        logoUrl = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null
            ? pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c;
        documentCode = docCode;
        ONE_Doc_Centro = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name;
        ONE_Doc_Telefono = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Phone;
        ONE_Doc_N_Pedido = pedidoProveedor.Name;
        ONE_Doc_Fecha_Hora_Pedido = pedidoProveedor.ONE_Fecha__c != null? pedidoProveedor.ONE_Fecha__c.format() :'';
        ONE_Doc_Proveedor = pedidoProveedor.ONE_Proveedor__r.Name;
        ONE_Doc_N_Servicio = pedidoProveedor.ONE_Expediente__r.Name;
        ONE_Doc_Difunto = ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.FirstName) + ' ' +ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.LastName);
        ONE_Doc_Material_Contratado = 
            language == 'CA'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Catalan__c):
        	language == 'EU'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Euskera__c):
        	language == 'EN_US'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Ingles__c):
        	ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c);
        ONE_Doc_Cantidad = tarea.ONE_Cantidad__c != null? tarea.ONE_Cantidad__c.intValue(): null;
        ONE_Doc_Observaciones_del_material =
            language == 'CA'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descriptivo_Producto_CAT__c):
        	language == 'EU'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descriptivo_Producto_EUS__c):
        	language == 'EN_US'? ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descriptivo_Producto_ENG__c):
        	ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Producto__r?.ONE_Descriptivo_Producto_ESP__c);
        String direccionCementerio = pedidoProveedor.ONE_Expediente__r.ONE_Destino_Final__r.ONE_Direccion__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Destino_Final__r.ONE_Direccion__c :'' + ', ' +
            pedidoProveedor.ONE_Expediente__r.ONE_Destino_Final__r.ONE_Municipio_Direccion__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Destino_Final__r.ONE_Municipio_Direccion__c :'';
        ONE_Doc_Marmolista_Cementerio = pedidoProveedor.ONE_Expediente__r.ONE_Destino_Final__r.Name + ' - ' + direccionCementerio;
        ONE_Doc_Marmolista_Datos_Ubicacion = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_LocalizacionUnidadEnterramiento__c);
        ONE_Doc_Marmolista_Fecha_Lugar_Nacimiento = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc != null? pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc.format() :'' + '- ' +
           ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_Nacimiento__pc);
        ONE_Doc_Marmolista_Fecha_Hora_Defuncion = pedidoProveedor.ONE_Expediente__r.ONE_Fecha_De_Defuncion__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Fecha_De_Defuncion__c.format() :'';
        ONE_Doc_Marmolista_Nombre_Apellidos = ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.FirstName) + ' ' +
            								  ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.LastName);
        ONE_Doc_Marmolista_Domicilio = 
            ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.ONE_Direccion__pc) + ' ' + 
            ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.ONE_Municipio__pc) + ' ' + 
            ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.ONE_Provincia__pc) + ' ' +
            ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.ONE_Codigo_Postal__pc) + ' ' +
            ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.ONE_Pais__pc);
        ONE_Doc_Marmolista_Telefono = pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.PersonHomePhone;
        ONE_Doc_Marmolista_Email = pedidoProveedor.ONE_Expediente__r.ONE_Declarante__r.ONE_Email__c;
        ONE_Doc_Sociedad_Nombre = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name;
        ONE_Doc_Asesor = pedidoProveedor.ONE_Expediente__r.Owner.FirstName +' '+ pedidoProveedor.ONE_Expediente__r.Owner.LastName;
        ONE_Doc_Marmolista_Observaciones = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Comentarios__c);
        ONE_Doc_Marmolista_Tipo_Concesion = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Concesion__c);
        this.language = language;
        ONE_Reproduccion = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Reproduccion__c);
        ONE_Inscripcion = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Inscripcion__c);
        ONE_Tipografia = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Tipografia__c);
        ONE_Color_Del_Marmol = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Color_Del_Marmol__c);
        ONE_Tamano = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Tamano__c);

        
        
        
    }
    
}
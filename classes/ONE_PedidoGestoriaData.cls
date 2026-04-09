public class ONE_PedidoGestoriaData {
    
    public String logoUrl {public get; private set;}
    public String documentCode {public get; private set;}
    public String ONE_Doc_Centro {public get; private set;} 
    public String ONE_Doc_Asesor {public get; private set;} 
    public String ONE_Doc_N_Pedido {public get; private set;} 
    public String ONE_Doc_Fecha_Hora_Pedido {public get; private set;}
    public String ONE_Doc_Proveedor {public get; private set;} 
    public String ONE_Doc_N_Servicio {public get; private set;} 
    public String ONE_Doc_Difunto {public get; private set;} 
    public String ONE_Doc_Material_Contratado {public get; private set;} 
    public integer ONE_Doc_Cantidad {public get; private set;} 
    public String ONE_Doc_Observaciones_del_material {public get; private set;} 
    public String ONE_Doc_Gestoria_Tipo_Documento {public get; private set;} 
    public String ONE_Doc_Gestoria_N {public get; private set;} 
    public String ONE_Doc_Gestoria_Fecha_Lugar_Nacimiento {public get; private set;} 
    public String ONE_Doc_Gestoria_Sexo {public get; private set;} 
    public integer ONE_Doc_Gestoria_Edad {public get; private set;} 
    public String ONE_Doc_Gestoria_Nombre_Padre {public get; private set;} 
    public String ONE_Doc_Gestoria_Nombre_Madre {public get; private set;} 
    public String ONE_Doc_Gestoria_Domicilio {public get; private set;} 
    public String ONE_Doc_Gestoria_Estado_Civil {public get; private set;} 
    public String ONE_Doc_Gestoria_Fecha_Hora_Defuncion {public get; private set;} 
    public String ONE_Doc_Gestoria_Lugar_Defuncion {public get; private set;} 
    public String ONE_Doc_Gestoria_Poblacion_Defuncion {public get; private set;} 
    public String ONE_Doc_Gestoria_Nombre {public get; private set;} 
    public String ONE_Doc_Gestoria_Parentesco_Difunto {public get; private set;} 
    public String ONE_Doc_Gestoria_Direccion_Poblacion {public get; private set;} 
    public String ONE_Doc_Gestoria_Telefono {public get; private set;} 
    public String ONE_Doc_Gestoria_Email {public get; private set;} 
    public String ONE_Doc_Observaciones {public get; private set;} 
    public String ONE_Doc_Sociedad_Nombre {public get; private set;}
    public String language {public get; private set;}
        
    public ONE_PedidoGestoriaData(String docCode, ONE_Tarea__c tarea, ONE_Pedido_De_Proveedor__c pedidoProveedor, ONE_Interlocutor__c interlocutor, String language) {
               
        logoUrl = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null
            ? pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c;
        ONE_Doc_Centro = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name;
        ONE_Doc_Asesor = pedidoProveedor.ONE_Expediente__r.Owner.FirstName + ' ' +pedidoProveedor.ONE_Expediente__r.Owner.LastName;
        ONE_Doc_N_Pedido = pedidoProveedor.Name;
        ONE_Doc_Fecha_Hora_Pedido = pedidoProveedor.ONE_Fecha__c != null? pedidoProveedor.ONE_Fecha__c.format() :'';
        ONE_Doc_Proveedor = pedidoProveedor.ONE_Proveedor__r.Name;
        ONE_Doc_N_Servicio = pedidoProveedor.ONE_Expediente__r.Name;
        ONE_Doc_Difunto = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.FirstName +' '+ pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.LastName;
        ONE_Doc_Material_Contratado  = 
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
        ONE_Doc_Gestoria_Tipo_Documento = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_N_Documento__pc;
        ONE_Doc_Gestoria_N = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_N_Documento__pc;
        System.debug('Fecha Nacimiento -->'+pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc); 
        System.debug('Lugar Nacimiento -->'+pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_nacimiento__pc); 

        ONE_Doc_Gestoria_Fecha_Lugar_Nacimiento =   (pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc != null? pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc.format() :'')
            										+ ' - '+
            										(pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_nacimiento__pc != null? pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_nacimiento__pc: '');
        ONE_Doc_Gestoria_Sexo = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Sexo__c;
        ONE_Doc_Gestoria_Edad = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c.intValue():null;
        ONE_Doc_Gestoria_Nombre_Padre = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Padres__c;
        ONE_Doc_Gestoria_Nombre_Madre = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_De_La_Madre__c;
        ONE_Doc_Gestoria_Domicilio = ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Direccion__pc) + ', ' +
                                     ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Municipio__pc) + ', ' +
                                     ONE_CommonUtils.changeNullToBlank(pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Pais__pc);
        ONE_Doc_Gestoria_Estado_Civil = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Estado_Civil__c;
        ONE_Doc_Gestoria_Fecha_Hora_Defuncion = pedidoProveedor.ONE_Expediente__r?.ONE_Fecha_De_Defuncion__c?.format();
        ONE_Doc_Gestoria_Lugar_Defuncion = pedidoProveedor.ONE_Expediente__r.ONE_Direccion_De_Defuncion__c;
        ONE_Doc_Gestoria_Poblacion_Defuncion = pedidoProveedor.ONE_Expediente__r.ONE_Municipio_De_Defuncion__c;
        ONE_Doc_Gestoria_Nombre = ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r?.FirstName) +' '+ ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r?.LastName);
        ONE_Doc_Gestoria_Parentesco_Difunto = interlocutor.ONE_Relacion_con_el_difunto__c;
        ONE_Doc_Gestoria_Direccion_Poblacion = ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r?.ONE_Direccion__pc) + 
                                               ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r?.ONE_Municipio__pc) + 
                                               ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r?.ONE_Provincia__pc);
        ONE_Doc_Gestoria_Telefono = interlocutor.ONE_Contacto__r.Phone;
        ONE_Doc_Gestoria_Email = interlocutor.ONE_Contacto__r.ONE_Email__c;
        ONE_Doc_Observaciones = tarea.ONE_Comentarios__c;
        ONE_Doc_Sociedad_Nombre = pedidoProveedor.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r.Name; 
		this.language = language;

    }
    
}
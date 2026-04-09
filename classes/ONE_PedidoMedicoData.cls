public class ONE_PedidoMedicoData {
    
    public String logoUrl {public get; private set;}
    public String documentCode {public get; private set;} 
    public String ONE_Doc_Centro  {public get; private set;} 
    public String ONE_Doc_Asesor  {public get; private set;} 
    public String ONE_Doc_N_Servicio  {public get; private set;} 
    public String ONE_Doc_N_Pedido  {public get; private set;} 
    public String ONE_Doc_Fecha_Hora_Pedido  {public get; private set;} 
    public String ONE_Doc_proveedor_medico  {public get; private set;} 
    public String ONE_Doc_Difunto  {public get; private set;} 
    public String ONE_Doc_Medico_Producto  {public get; private set;} 
    public String ONE_Doc_Medico_Fecha_hora  {public get; private set;} 
    public String ONE_Doc_Medico_Lugar  {public get; private set;} 
    public String ONE_Doc_Comentarios  {public get; private set;} 
    public String ONE_Doc_Nombre_difunto  {public get; private set;} 
    public String ONE_Doc_NIF_difunto  {public get; private set;} 
    public Integer ONE_Doc_Gestoria_Edad  {public get; private set;} 
    public String ONE_Doc_Gestoria_Sexo  {public get; private set;} 
    public String ONE_Doc_medico_Contacto_difunto  {public get; private set;} 
    public String ONE_Doc_telefono_declarante_medico  {public get; private set;} 
    public String ONE_Doc_DatosParroquialesFecha_defuncion  {public get; private set;} 
    public String ONE_Doc_DatosParroquialesLugar_defuncion  {public get; private set;} 
    public String ONE_Doc_causas_defuncion  {public get; private set;} 
    public String ONE_Doc_Tanatoestetica  {public get; private set;} 
    public String ONE_Doc_Tanatopraxia  {public get; private set;} 
    public String ONE_Doc_Velacion_lugar  {public get; private set;} 
    public String ONE_Doc_fecha_hora_inicio_velacion  {public get; private set;} 
    public String ONE_Doc_tipo_destino_final  {public get; private set;} 
    public String ONE_Doc_fecha_hora_servicio  {public get; private set;}
    public String ONE_Doc_Sociedad_Nombre {public get; private set;}
    public String ONE_Doc_Gestoria_Fecha_Hora_Defuncion {public get; private set;}
    public String language {public get; private set;}
    
    
    public ONE_PedidoMedicoData(String docCode, ONE_Tarea__c tarea, ONE_Pedido_De_Proveedor__c pedidoProveedor, ONE_Interlocutor__c interlocutor, String language) {
        
        ONE_Doc_Sociedad_Nombre = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name; 
        logoUrl = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null
            ? pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c;
        documentCode = docCode;
        ONE_Doc_Centro = pedidoProveedor.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name;
        ONE_Doc_Asesor = pedidoProveedor.ONE_Expediente__r.Owner.FirstName +' '+ pedidoProveedor.ONE_Expediente__r.Owner.LastName;
        ONE_Doc_N_Servicio = pedidoProveedor.ONE_Expediente__r.Name;
        ONE_Doc_N_Pedido = pedidoProveedor.Name;
        ONE_Doc_Fecha_Hora_Pedido = pedidoProveedor.ONE_Fecha__c != null? pedidoProveedor.ONE_Fecha__c.format() :'';
        ONE_Doc_proveedor_medico = pedidoProveedor.ONE_Proveedor__r.Name;
        ONE_Doc_Difunto = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.FirstName +' '+ pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.LastName;
     
        ONE_Doc_Medico_Producto = language == 'EU'? tarea.ONE_Producto__r.ONE_Descripcion_En_Euskera__c:
                                  language == 'CA'? tarea.ONE_Producto__r.ONE_Descripcion_En_Catalan__c:
        						  language == 'EN_US' ? tarea.ONE_Producto__r.ONE_Descripcion_En_Ingles__c:
                                  tarea.ONE_Producto__r.ONE_Descripcion_En_Castellano__c;
        
        ONE_Doc_Medico_Fecha_hora = tarea.ONE_Fecha_Y_Hora__c != null? tarea.ONE_Fecha_Y_Hora__c.format() :'';
        ONE_Doc_Medico_Lugar = tarea.ONE_Lugar__r.Name;
        ONE_Doc_Comentarios = tarea.ONE_Comentarios__c;
        ONE_Doc_Nombre_difunto = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.FirstName  +' '+  pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.LastName;
        ONE_Doc_NIF_difunto = pedidoProveedor.ONE_Expediente__r.ONE_Numero_de_Documento__c;
        ONE_Doc_Gestoria_Edad = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c.intValue(): null;
        ONE_Doc_Gestoria_Sexo = pedidoProveedor.ONE_Expediente__r.ONE_Difunto__r.ONE_Sexo__c;
        ONE_Doc_medico_Contacto_difunto = interlocutor.ONE_Contacto__r.FirstName +' '+ interlocutor.ONE_Contacto__r.LastName;
        ONE_Doc_telefono_declarante_medico = interlocutor.ONE_Contacto__r.Phone;
        ONE_Doc_DatosParroquialesFecha_defuncion = pedidoProveedor.ONE_Expediente__r.ONE_Fecha_De_Defuncion__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Fecha_De_Defuncion__c.format() :'';
        ONE_Doc_DatosParroquialesLugar_defuncion = pedidoProveedor.ONE_Expediente__r.ONE_Direccion_De_Defuncion__c;
        ONE_Doc_causas_defuncion = pedidoProveedor.ONE_Expediente__r.ONE_Causas_Defuncion__c;
        ONE_Doc_Tanatoestetica = tarea.ONE_Tanatoestetica__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
        ONE_Doc_Tanatopraxia = tarea.ONE_Tanatopraxia__c ?'/img/checkbox_checked.gif': '/img/checkbox_unchecked.gif';
        ONE_Doc_Velacion_lugar = pedidoProveedor.ONE_Expediente__r.ONE_Direccion_Velacion__c +', '+
                                 pedidoProveedor.ONE_Expediente__r.ONE_Municipio_Velacion__c +', '+
                                 pedidoProveedor.ONE_Expediente__r.ONE_Provincia_Velacion__c +', '+
                                 pedidoProveedor.ONE_Expediente__r.ONE_Codigo_Postal_Velacion__c;
        ONE_Doc_fecha_hora_inicio_velacion = pedidoProveedor.ONE_Expediente__r.ONE_Inicio_Velacion__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Inicio_Velacion__c.format() :'';
        ONE_Doc_tipo_destino_final = pedidoProveedor.ONE_Expediente__r.ONE_Tipo_De_Lugar_Destino_Final__c;
        ONE_Doc_fecha_hora_servicio = pedidoProveedor.ONE_Expediente__r.ONE_Hora_Destino_Final__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Hora_Destino_Final__c.format() :'';
        ONE_Doc_Gestoria_Fecha_Hora_Defuncion = pedidoProveedor.ONE_Expediente__r.ONE_Fecha_De_Defuncion__c != null? pedidoProveedor.ONE_Expediente__r.ONE_Fecha_De_Defuncion__c.format() :'';
		this.language = language;
    }
    
    
}
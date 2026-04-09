public class ONE_MailEntregaFloresBuilder {
	
    private ONE_Tarea__c tarea;
    
    private EmailTemplate et;
    
    public ONE_MailEntregaFloresBuilder(id tareaId){
    	this.et =[SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'ONE_Plantilla_Tarea_Flores'];
		this.tarea = [SELECT Id, ONE_Linea_De_Expediente__r.ONE_Importe_Base__c, ONE_Linea_De_Expediente__r.ONE_Importe_Neto__c, ONE_Linea_De_Expediente__r.ONE_Producto__r.Name, 
                        ONE_Linea_De_Expediente__r.ONE_Impuesto__c,	ONE_Linea_De_Expediente__r.ONE_Lugar_Y_Hora_Del_Servicio__c, ONE_Fecha_Y_Hora__c, ONE_Lugar__r.Name, 
                        ONE_Expediente__r.ONE_Difunto__r.FirstName, ONE_Expediente__r.ONE_Difunto__r.LastName, ONE_Tarjeta_O_Lazo__c, ONE_Texto_Banda_O_Lazo__c, 
                        ONE_Cantidad__c, ONE_Linea_De_Expediente__r.ONE_Precio__c, ONE_Linea_De_Expediente__r.ONE_Importe_Impuesto__c, ONE_Correo_Confirmacion__c,
                        ONE_Numero_Pedido__c, ONE_Correo_Confirmacion_Enviado__c
                      	FROM ONE_Tarea__c
                      	WHERE Id = :tareaId];
    }
    
    public Id getOrgAddress(){
        return [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'webmaster@memora.es' LIMIT 1].Id;
    }
    
    public void confirmarEnvio(){
        this.tarea.ONE_Correo_Confirmacion_Enviado__c = true;
        update this.tarea;
    }
    
    public String getTarget(){
        return this.tarea.ONE_Correo_Confirmacion__c;
    }
    
    public Id getEmailTemplate(){
        return this.et.Id;
    }
    
    public String getSubject(){
        return this.et.Subject;
    }
    
    public String buildHTML(){
        String html = this.et.HtmlValue;
        html = html.replace('{numPedido}', this.tarea.ONE_Numero_Pedido__c != null ? this.tarea.ONE_Numero_Pedido__c : '');
        html = html.replace('{difunto.Name}', (this.tarea.ONE_Expediente__r.ONE_Difunto__r.FirstName != null && this.tarea.ONE_Expediente__r.ONE_Difunto__r.LastName != null) ? this.tarea.ONE_Expediente__r.ONE_Difunto__r.FirstName + ' ' + this.tarea.ONE_Expediente__r.ONE_Difunto__r.LastName : this.tarea.ONE_Expediente__r.ONE_Difunto__r.LastName != null ? this.tarea.ONE_Expediente__r.ONE_Difunto__r.LastName : this.tarea.ONE_Expediente__r.ONE_Difunto__r.FirstName != null ? this.tarea.ONE_Expediente__r.ONE_Difunto__r.FirstName : '');
        html = html.replace('{centroDeEntrega}', this.tarea.ONE_Lugar__r.Name != null ? this.tarea.ONE_Lugar__r.Name : '');
        html = html.replace('{momentoEntrega}', this.tarea.ONE_Linea_De_Expediente__r.ONE_Lugar_Y_Hora_Del_Servicio__c != null ?
                            						this.tarea.ONE_Linea_De_Expediente__r.ONE_Lugar_Y_Hora_Del_Servicio__c == 'Depósito' ?
                            							'del ' + this.tarea.ONE_Linea_De_Expediente__r.ONE_Lugar_Y_Hora_Del_Servicio__c :
                            							'de la ' + this.tarea.ONE_Linea_De_Expediente__r.ONE_Lugar_Y_Hora_Del_Servicio__c
                            							: '');
        
        Datetime fechaHora = this.tarea.ONE_Fecha_Y_Hora__c;
        String fechaComoString = fechaHora != null ? fechaHora.format('yyyy/MM/dd') : '';
        String horaComoString = fechaHora != null ? fechaHora.format('HH:mm:ss') : '';
        html = html.replace('{fechaEntrega}', fechaComoString);
        html = html.replace('{horaEntrega}', horaComoString);
        html = html.replace('{tarea.Dedicatoria}', this.tarea.ONE_Tarjeta_O_Lazo__c != null ? this.tarea.ONE_Tarjeta_O_Lazo__c : '');
        html = html.replace('{tarea.textoDedicatoria}', this.tarea.ONE_Texto_Banda_O_Lazo__c != null ? this.tarea.ONE_Texto_Banda_O_Lazo__c : '');
        html = html.replace('{producto.Name}', this.tarea.ONE_Linea_De_Expediente__r.ONE_Producto__r.Name != null ? this.tarea.ONE_Linea_De_Expediente__r.ONE_Producto__r.Name : '');
        html = html.replace('{producto.Cantidad}', this.tarea.ONE_Cantidad__c != null ? 
                                                        this.tarea.ONE_Cantidad__c != 1 ? 
                                                            this.tarea.ONE_Cantidad__c.toString().substring(0, 1) + ' unidad' :
                                                            this.tarea.ONE_Cantidad__c.toString().substring(0, 1) + ' unidades' :
                                                        '');	
        html = html.replace('{producto.Precio}', this.tarea.ONE_Linea_De_Expediente__r.ONE_Precio__c != null ? this.tarea.ONE_Linea_De_Expediente__r.ONE_Precio__c.toString().replace('.', ',') : '');
        html = html.replace('{tipoImpositivo}', this.tarea.ONE_Linea_De_Expediente__r.ONE_Impuesto__c != null ? this.tarea.ONE_Linea_De_Expediente__r.ONE_Impuesto__c.toString().substring(0, 2) + '%': '');
        html = html.replace('{productoImporteBase}', this.tarea.ONE_Linea_De_Expediente__r.ONE_Importe_Base__c != null ?
                            this.tarea.ONE_Linea_De_Expediente__r.ONE_Importe_Base__c.toString().replace('.', ',') : '');
        html = html.replace('{producto.ONE_Importe_Impuesto__c}', this.tarea.ONE_Linea_De_Expediente__r.ONE_Importe_Impuesto__c != null ?
                            this.tarea.ONE_Linea_De_Expediente__r.ONE_Importe_Impuesto__c.toString().replace('.', ',') : '');
        html = html.replace('{producto.ImporteNeto}', this.tarea.ONE_Linea_De_Expediente__r.ONE_Importe_Neto__c != null ?
                            this.tarea.ONE_Linea_De_Expediente__r.ONE_Importe_Neto__c.toString().replace('.', ',') : '');
        
        return html;
    }
    
}
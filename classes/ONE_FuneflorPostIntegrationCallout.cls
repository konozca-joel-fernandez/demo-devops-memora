/**
 * Created by mkuzak001 on 02.02.2021.
 * Modified by Marc Cervilla on 27.01.2025 - Modify JSON to add momentos
 */
//Class that implement all the method for the funeflor order modification
public with sharing class ONE_FuneflorPostIntegrationCallout extends ONE_FuneflorIntegrationCallout {
    //Static variable definition
    @TestVisible
    private static final String FU_SUFFIX = '-FU';
    //Integration request callout
    public ONE_FuneflorPostIntegrationCallout(String endpointMetadataName, ONE_Integration.RestMethod restMethod, ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        super(endpointMetadataName, restMethod);
        pedido = ONE_FuneflorIntegrationHelper.selectPedidoDeProveedor(pedido.Id);
        tarea = ONE_FuneflorIntegrationHelper.selectTarea(tarea.Id);
        validateRequest(pedido, tarea);
        setBody(buildRequestBody(pedido, tarea));
    }
    //Request validation class
    public void validateRequest(ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        if (pedido.Name == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Pedido_De_Proveedor__c.Name'}));
        }
        if (pedido.ONE_Fecha__c == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Pedido_De_Proveedor__c.ONE_Fecha__c'}));
        }
        if (pedido.ONE_Expediente__c == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Pedido_De_Proveedor__c.ONE_Expediente__c'}));
        }
        if (tarea.ONE_Posicion_Pedido__c == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Tarea__c.ONE_Posicion_Pedido__c'}));
        }
        if (tarea.ONE_Cantidad__c == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Tarea__c.ONE_Cantidad__c'}));
        }
        if (tarea.ONE_Expediente__c == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List<String>{'ONE_Tarea__c.ONE_Expediente__c'}));
        }
    }
    //Request header builder
    public override ONE_FuneflorIntegrationCallout.Cabecera buildRequestCabecera(ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        ONE_FuneflorPostIntegrationCallout.Cabecera cabecera = new ONE_FuneflorPostIntegrationCallout.Cabecera();
        cabecera.id_cli = pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Numero_Cliente_Funeflor__c;
        cabecera.fecha = pedido.ONE_Fecha__c;
        cabecera.refcli = pedido.Name;
        cabecera.segmento = pedido.ONE_Expediente__r?.ONE_Segmento_Seleccionado__r?.ONE_Segmentacion_Interna__c;
        //cabecera.compania = pedido.ONE_Expediente__r?.ONE_Compania__r?.Name;
        cabecera.aseguradora = pedido.ONE_Expediente__r?.ONE_Compania__r?.Name;
        if (tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__r?.ONE_Tipo_De_Presupuesto__c == 'Presupuesto web') {
            cabecera.asesor = tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__r?.ONE_Interlocutor__r?.ONE_Contacto__r?.Name;
            cabecera.telcontacto = tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__r?.ONE_Interlocutor__r?.ONE_Contacto__r?.Phone;
            cabecera.emailcontacto = tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__r?.ONE_Interlocutor__r?.ONE_Contacto__r?.PersonEmail;
            cabecera.origen = 3; // Memora Web
        }
        else if (tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__c != null) {
            cabecera.asesor = tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__r.Owner?.Name;
            cabecera.telcontacto = tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__r.Owner?.Phone;
            cabecera.emailcontacto = tarea.ONE_Linea_De_Expediente__r?.ONE_Presupuesto__r.Owner?.Email;
            cabecera.origen = 2; // One
        }
        else {
            cabecera.asesor = pedido.ONE_Expediente__r?.ONE_Nombre_Del_Asesor__c;
            cabecera.telcontacto = pedido.ONE_Expediente__r?.Owner?.Phone;
            cabecera.emailcontacto = pedido.ONE_Expediente__r?.Owner?.Email;
            cabecera.origen = 2; // One
        }
        if (pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r?.ONE_Codigo_De_Centro__c != null) {
            //add suffix -FU or -TA
            if (pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sufijo_pedido_flores__c == null) {
                cabecera.id_centrointerext = pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c + FU_SUFFIX;
            }
            else {
                cabecera.id_centrointerext = pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c + 
                    pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sufijo_pedido_flores__c;
            }
        }
        cabecera.difext = pedido.ONE_Expediente__r.Name;
        cabecera.difunto = pedido.ONE_Expediente__r.ONE_Difunto__r.FirstName + ' ' + pedido.ONE_Expediente__r.ONE_Difunto__r.LastName;
        if (pedido.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.ONE_Codigo_De_Centro__c != null) {
            cabecera.tanatorio_ext = pedido.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.ONE_Codigo_De_Centro__c;
        }

        Datetime fechaHora = tarea.ONE_Fecha_Y_Hora__c;
        if(fechaHora != null) {
            cabecera.fecentsol = ONE_CommonUtils.formatDateValue(fechaHora);
            cabecera.horentsol = ONE_CommonUtils.formatTimeValue(fechaHora);
        }

        cabecera.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento(tarea.ONE_Momento_Entrega__c);

        // **Old fields send before sending moments**

        /*cabecera.lugarcere = (pedido.ONE_Expediente__r.ONE_Sala_ceremonia__c != null)
            ? pedido.ONE_Expediente__r.ONE_Sala_ceremonia__r.Name
            : pedido.ONE_Expediente__r.ONE_Lugar_ceremonia__r.Name;
        
        if (tarea.ONE_Lugar__c != null) {
            cabecera.direnv = tarea.ONE_Lugar__r.ONE_Direccion__c;
        } else if (tarea.ONE_Expediente__r.ONE_Lugar_De_Velacion__c != null) {
            cabecera.direnv = tarea.ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Direccion__c;
        } else {
            cabecera.direnv = tarea.ONE_Expediente__r.ONE_Direccion_Velacion__c;
        }
        
        if (tarea.ONE_Lugar__c != null) {
            cabecera.id_posenv = tarea.ONE_Lugar__r.ONE_Codigo_Postal__c;
        } else if (tarea.ONE_Expediente__r.ONE_Lugar_De_Velacion__c != null) {
            cabecera.id_posenv = tarea.ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Codigo_Postal__c;
        } else {
            cabecera.id_posenv = tarea.ONE_Expediente__r.ONE_Codigo_Postal_Velacion__c;
        }
        
        if (tarea.ONE_Lugar__c != null) {
            cabecera.pobenv = tarea.ONE_Lugar__r.ONE_Municipio_Direccion__c;
        } else if (tarea.ONE_Expediente__r.ONE_Lugar_De_Velacion__c != null) {
            cabecera.pobenv = tarea.ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Municipio_Direccion__c;
        } else {
            cabecera.pobenv = tarea.ONE_Expediente__r.ONE_Municipio_Velacion__c;
        }
        
        if (tarea.ONE_Lugar__c != null) {
            cabecera.nomenv =tarea.ONE_Lugar__r?.Name;
        } else if (tarea.ONE_Expediente__r.ONE_Lugar_De_Velacion__c != null) {
            cabecera.nomenv =tarea.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.Name;
        } else {
            //cabecera.nomenv =''; NULL
        }*/
        
        return cabecera;
    }
    //Request body with order line builder
    public override ONE_FuneflorIntegrationCallout.Linea buildRequestLinea(ONE_Tarea__c tarea) {
        ONE_FuneflorPostIntegrationCallout.Linea linea = new ONE_FuneflorPostIntegrationCallout.Linea();
        
        linea.id_lin = (tarea.ONE_Posicion_Pedido__c != null) ? Integer.valueOf(tarea.ONE_Posicion_Pedido__c) : null;
        linea.refcli = String.isNotBlank(tarea.ONE_Modelo__c) ? tarea.ONE_Modelo__r?.ONE_Codigo_Comercial__c : tarea.ONE_Producto__r?.ONE_Codigo_Comercial__c;
        linea.pedven = String.valueOf(tarea.ONE_Cantidad__c);
        linea.desaux1 = String.isNotBlank(tarea.ONE_Modelo__c) ? tarea.ONE_Modelo__r?.Name : tarea.ONE_Producto__r?.ONE_Descripcion_En_Castellano__c;
        //linea.fecent = (tarea.ONE_Fecha_Y_Hora__c != null) ? String.valueOf(Date.valueOf(tarea.ONE_Fecha_Y_Hora__c)) : null;
        //linea.txtlinea = tarea.ONE_Texto_Banda_O_Lazo__c;
        linea.txtlinea = null;
        linea.txtlazo = tarea.ONE_Texto_Banda_O_Lazo__c ;
        linea.idilazo = tarea.ONE_Idioma__c;
        linea.sopdedi = tarea.ONE_Tarjeta_O_Lazo__c;
        linea.obsase = tarea.ONE_Comentarios__c;
        linea.precio = tarea.ONE_Precio_De_Compra__c;
        
        return linea;
    }

    
    // Request body with momentos info
    public override List<ONE_FuneflorIntegrationCallout.Momento> buildRequestMomentos(ONE_Tarea__c tarea) {
        return ONE_FuneflorIntegrationHelper.getMomentosTarea(tarea);
    }

    //Data structure for the header
    public class Cabecera extends ONE_FuneflorIntegrationCallout.Cabecera {
        public String id_cli;
        public Date fecha;
        public String refcli;
        public String segmento;
        //public String compania;
        public String aseguradora;
        public String asesor;
        public String telcontacto;
        public String emailcontacto;
        public String id_centrointerext;
        public String difunto;
        public String tanatorio_ext;
        //public String lugarcere;
        //public String direnv;
        //public String nomenv;
        //public String id_posenv;
        //public String pobenv;
        public String difext;
        public Integer origen;
        public String fecentsol;
        public String horentsol;
        public String id_mom;

    }

    //Data structure for the order line
    public class Linea extends ONE_FuneflorIntegrationCallout.Linea {
        public Integer id_lin;
        public String refcli;
        public String pedven;
        public String desaux1;
        //public String fecent;
        public String txtlinea;
        public String txtlazo;
        public String idilazo;
        public String sopdedi;
        public String obsase;
        public Double precio;
    }
}
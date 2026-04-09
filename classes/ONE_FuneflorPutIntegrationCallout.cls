/**
 * Created by mkuzak001 on 02.02.2021.
 * Modified by Marc Cervilla on 27.01.2025 - Modify JSON to add momentos
 */
//Class for the funeflor order creation integration
public with sharing class ONE_FuneflorPutIntegrationCallout extends ONE_FuneflorIntegrationCallout {
    //Call create order integration
    public ONE_FuneflorPutIntegrationCallout(String endpointMetadataName, ONE_Integration.RestMethod restMethod, ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        super(endpointMetadataName, restMethod);
        pedido = ONE_FuneflorIntegrationHelper.selectPedidoDeProveedor(pedido.Id);
        tarea = ONE_FuneflorIntegrationHelper.selectTarea(tarea.Id);
        validateRequest(pedido, tarea);
        setBody(buildRequestBody(pedido, tarea));
    }
    //Validate request method
    public void validateRequest(ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        if (pedido.Name == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List < String > {
                'ONE_Pedido_De_Proveedor__c.Name'
            }));
        }
        if (tarea.ONE_Posicion_Pedido__c == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List < String > {
                'ONE_Tarea__c.ONE_Posicion_Pedido__c'
            }));
        }
        if (tarea.ONE_Comentarios__c == null) {
            throw new ONE_FuneflorIntegrationCalloutException(String.format(Label.FieldIsMandatory, new List < String > {
                'ONE_Tarea__c.ONE_Comentarios__c'
            }));
        }
    }
    //Build request header for the order creation
    protected override ONE_FuneflorIntegrationCallout.Cabecera buildRequestCabecera(ONE_Pedido_De_Proveedor__c pedido, ONE_Tarea__c tarea) {
        ONE_FuneflorPutIntegrationCallout.Cabecera cabecera = new ONE_FuneflorPutIntegrationCallout.Cabecera();

        cabecera.refcli = pedido.Name;

        Datetime fechaHora = tarea.ONE_Fecha_Y_Hora__c;
        if (fechaHora != null) {
            cabecera.fecentsol = ONE_CommonUtils.formatDateValue(fechaHora);
            cabecera.horentsol = ONE_CommonUtils.formatTimeValue(fechaHora);
        }

        cabecera.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento(tarea.ONE_Momento_Entrega__c);

        return cabecera;
    }
    //Build request body for the order creation
    protected override ONE_FuneflorIntegrationCallout.Linea buildRequestLinea(ONE_Tarea__c tarea) {
        ONE_FuneflorPutIntegrationCallout.Linea linea = new ONE_FuneflorPutIntegrationCallout.Linea();
        linea.id_lin = Integer.valueOf(tarea.ONE_Posicion_Pedido__c);
        linea.obsase = tarea.ONE_Comentarios__c;
        linea.txtlazo = tarea.ONE_Texto_Banda_O_Lazo__c;
        linea.sopdedi = tarea.ONE_Tarjeta_O_Lazo__c;
        return linea;
    }

    // Request body with momentos info
    protected override List < ONE_FuneflorIntegrationCallout.Momento > buildRequestMomentos(ONE_Tarea__c tarea) {
        return ONE_FuneflorIntegrationHelper.getMomentosTarea(tarea);
    }



    //Header data structure integration definition
    public class Cabecera extends ONE_FuneflorIntegrationCallout.Cabecera {
        public String refcli;
        public String fecentsol;
        public String horentsol;
        public String id_mom;
    }
    //Body data structure integration definition
    public class Linea extends ONE_FuneflorIntegrationCallout.Linea {
        public Integer id_lin;
        public String obsase;
        public String txtlazo;
        public String sopdedi;
    }

}
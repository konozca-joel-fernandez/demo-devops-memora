/**
 * Created by mkuzak001 on 04.02.2021.
 * Modified by Marc Cervilla on 27.01.2025 - Add momento info
 */
//Funeflor integration helper class to query all the needed information for the request
public with sharing class ONE_FuneflorIntegrationHelper {
    //Select ONE_Pedido_De_Proveedor__c using pedido ID
    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedor(Id pedidoId) {
        return [
            SELECT Name, ONE_Expediente__r.ONE_Segmento_Seleccionado__r.ONE_Segmentacion_Interna__c, ONE_Fecha__c,
                ONE_Expediente__r.ONE_Compania__r.Name, ONE_Expediente__r.ONE_Nombre_Del_Asesor__c, ONE_Expediente__r.Owner.Phone,
                ONE_Expediente__r.Owner.Email, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_De_Centro__c, ONE_Expediente__r.Name,
                ONE_Expediente__r.ONE_Difunto__r.FirstName, ONE_Expediente__r.ONE_Difunto__r.LastName,
                ONE_Expediente__r.ONE_Sala_De_Velacion__r.ONE_Numero_De_Sala__c, ONE_Expediente__r.ONE_Sala_ceremonia__c,
                ONE_Expediente__r.ONE_Sala_ceremonia__r.Name, ONE_Expediente__r.ONE_Lugar_ceremonia__r.Name,
                ONE_Expediente__r.ONE_Inicio_Velacion__c, ONE_Expediente__r.ONE_Fin_Velacion__c,ONE_Expediente__r.ONE_Inicio_ceremonia__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Numero_Cliente_Funeflor__c,
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Codigo_De_Centro__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sufijo_pedido_flores__c
            FROM ONE_Pedido_De_Proveedor__c
            WHERE Id = :pedidoId
        ];
    }
    //Select ONE_Tarea__c using tarea ID
    public static ONE_Tarea__c selectTarea(Id tareaId) {
        return [
            SELECT ONE_Lugar__c, ONE_Lugar__r.BillingStreet, ONE_Expediente__r.ONE_Lugar_De_Velacion__c,
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.BillingStreet,
                ONE_Lugar__r.BillingPostalCode, ONE_Lugar__r.BillingCity, ONE_Posicion_Pedido__c,
                ONE_Producto__r.ONE_Codigo_Comercial__c, ONE_Cantidad__c,ONE_Fecha_Y_Hora__c, ONE_Texto_Banda_O_Lazo__c,
                ONE_Idioma__c, ONE_Comentarios__c, ONE_Producto__r.ONE_Descripcion_En_Castellano__c, 
            	ONE_Lugar__r.ONE_Direccion__c,ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Direccion__c,
            	ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Codigo_Postal__c,ONE_Lugar__r.ONE_Codigo_Postal__c,
            	ONE_Lugar__r.ONE_Municipio_Direccion__c, ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Municipio_Direccion__c,
            	ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Codigo_De_Centro__c, 
            	ONE_Lugar__r.Name,
                ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c,
                ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Interlocutor__r.ONE_Contacto__r.Name,
                ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Interlocutor__r.ONE_Contacto__r.Phone,
                ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.ONE_Interlocutor__r.ONE_Contacto__r.PersonEmail,
                ONE_Modelo__c, ONE_Modelo__r.Name, ONE_Modelo__r.ONE_Codigo_Comercial__c, 
            	ONE_Precio_De_Compra__c, toLabel(ONE_Tarjeta_O_Lazo__c),
                ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.Owner.Name, ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.Owner.Phone,
                ONE_Linea_De_Expediente__r.ONE_Presupuesto__r.Owner.Email,
                //fields for momentos
                ONE_Momento_Entrega__c,
                ONE_Expediente__r.Name,
                ONE_Expediente__r.ONE_Velacion__c,
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name,
                ONE_Expediente__r.ONE_Direccion_Velacion__c,
                ONE_Expediente__r.ONE_Codigo_Postal_Velacion__c,
                ONE_Expediente__r.ONE_Municipio_Velacion__c,
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Phone,
                ONE_Expediente__r.ONE_Sala_De_Velacion__r.ONE_Numero_De_Sala__c,
                ONE_Expediente__r.ONE_Inicio_Velacion__c,
                ONE_Expediente__r.ONE_Fin_Velacion__c,
                ONE_Expediente__r.ONE_Ceremonia__c,
                ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
                ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c,
                ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Phone,
                ONE_Expediente__r.ONE_Sala_Ceremonia__r.ONE_Numero_De_Sala__c,
                ONE_Expediente__r.ONE_Inicio_Ceremonia__c,
                ONE_Expediente__r.ONE_Fin_Ceremonia__c,
                ONE_Expediente__r.ONE_Cementerio__c,
                ONE_Expediente__r.ONE_Destino_Final__r.Name,
                ONE_Expediente__r.ONE_Destino_Final__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Codigo_Postal_Destino_Final__c,
                ONE_Expediente__r.ONE_Municipio_Destino_Final__c,
                ONE_Expediente__r.ONE_Destino_Final__r.Phone,
                ONE_Expediente__r.ONE_Hora_Destino_Final__c,
                ONE_Expediente__r.ONE_Incineracion__c,
                ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name,
                ONE_Expediente__r.ONE_Lugar_Incineracion__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Codigo_Postal_Incineracion__c,
                ONE_Expediente__r.ONE_Municipio_Incineracion__c,
                ONE_Expediente__r.ONE_Lugar_Incineracion__r.Phone,
                ONE_Expediente__r.ONE_Inicio_Incineracion__c,
                ONE_Expediente__r.ONE_Fin_Incineracion__c,
                ONE_Expediente__r.ONE_Deposito__c,
                ONE_Expediente__r.ONE_Lugar_De_Deposito__r.Name,
                ONE_Expediente__r.ONE_Lugar_De_Deposito__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Lugar_De_Deposito__r.ONE_Codigo_Postal__c,
                ONE_Expediente__r.ONE_Lugar_De_Deposito__r.ONE_Municipio_Direccion__c,
                ONE_Expediente__r.ONE_Lugar_De_Deposito__r.Phone,
                ONE_Expediente__r.ONE_Sala_Deposito__r.ONE_Numero_De_Sala__c,
                ONE_Expediente__r.ONE_Inicio_Deposito__c,
                ONE_Expediente__r.ONE_Fin_Deposito__c,
                ONE_Expediente__r.ONE_Despedida__c,
                ONE_Expediente__r.ONE_Lugar_Despedida__r.Name,
                ONE_Expediente__r.ONE_Lugar_Despedida__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Lugar_Despedida__r.ONE_Codigo_Postal__c,
                ONE_Expediente__r.ONE_Lugar_Despedida__r.ONE_Municipio_Direccion__c,
                ONE_Expediente__r.ONE_Lugar_Despedida__r.Phone,
                ONE_Expediente__r.ONE_Sala_Despedida__r.ONE_Numero_De_Sala__c,
                ONE_Expediente__r.ONE_Inicio_Despedida__c,
                ONE_Expediente__r.ONE_Fin_Despedida__c
            FROM ONE_Tarea__c
            WHERE Id = :tareaId
        ];
    }

    // Mapping moments with id
    private static final Map<String, String> MOMENTOS_MAP = new Map<String, String>{
        'Velacion' => 'VL',
        'Ceremonia' => 'CR',
        'Inhumacion' => 'CM',
        'Incineracion' => 'IN',
        'Deposito' => 'DP',
        'Despedida' => 'DS'
    };

    // Get ID momento
    public static String getIDMomento(String momValue) {
        return MOMENTOS_MAP.containsKey(momValue) ? MOMENTOS_MAP.get(momValue) : 'VL';
    }

    // Get body with momentos info, used in POST and PUT
    public static List<ONE_FuneflorIntegrationCallout.Momento> getMomentosTarea(ONE_Tarea__c tarea) {

        List<ONE_FuneflorIntegrationCallout.Momento> momentos = new List<ONE_FuneflorIntegrationCallout.Momento>();

        // Get Expediente
        ONE_Expediente__c expediente = tarea.ONE_Expediente__r;

        if (expediente == null) {
            return momentos;
        }

        ONE_FuneflorIntegrationCallout.Momento momento;

        // If lugar don't exist we send default text
        final String dirParticular = 'DIRECCIÓN PARTICULAR';
        final String noInformado = 'NO INFORMADO';
        final String postalDefault = '00000';

        // If no fecha is informed we send today
        final String fechaDefault = ONE_CommonUtils.formatDateValue( Date.today() );
        final String horaIniDefault = ONE_CommonUtils.formatTimeValue( Datetime.now() );
        final String horaFinDefault = '23:59';

        DateTime inicio = null;
        DateTime fin = null;

        // VELACION
        if (expediente.ONE_Velacion__c) {
        
            momento = new ONE_FuneflorIntegrationCallout.Momento();

            momento.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento('Velacion');
            //momento.difex = expediente.Name;
            momento.nomenv = (expediente.ONE_Lugar_De_Velacion__r?.Name != null) ? expediente.ONE_Lugar_De_Velacion__r?.Name : 
                (expediente.ONE_Direccion_Velacion__c != null) ? dirParticular : noInformado;
            momento.direnv = expediente.ONE_Direccion_Velacion__c != null ? expediente.ONE_Direccion_Velacion__c : noInformado;
            momento.id_posenv = expediente.ONE_Codigo_Postal_Velacion__c != null ? expediente.ONE_Codigo_Postal_Velacion__c : postalDefault;
            momento.pobenv = expediente.ONE_Municipio_Velacion__c != null ? expediente.ONE_Municipio_Velacion__c : noInformado;
            momento.telcontacto = expediente.ONE_Lugar_De_Velacion__r?.Phone;
            momento.movcontacto = null;
            momento.sala = Integer.valueOf(expediente.ONE_Sala_De_Velacion__r?.ONE_Numero_De_Sala__c);

            //INFORMAR SIEMPRE FECHAS

            inicio = expediente.ONE_Inicio_Velacion__c;
            fin = expediente.ONE_Fin_Velacion__c;

            if (inicio != null && fin != null) {
                // Ambos informados
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(fin);
                momento.horfin = ONE_CommonUtils.formatTimeValue(fin);

            } else if (inicio != null) {
                // Solo inicio informado
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(inicio);
                momento.horfin = horaFinDefault;

            } else {
                // Inicio no informado -> hoy
                momento.fecini = fechaDefault;
                momento.horini = horaIniDefault;
                momento.fecfin = fechaDefault;
                momento.horfin = horaFinDefault;
            }
            
            momentos.add(momento);
        }

        // CEREMONIA
        if (expediente.ONE_Ceremonia__c) {
        
            momento = new ONE_FuneflorIntegrationCallout.Momento();

            momento.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento('Ceremonia');
            //momento.difex = expediente.Name;
            momento.nomenv = (expediente.ONE_Lugar_Ceremonia__r?.Name != null) ? expediente.ONE_Lugar_Ceremonia__r?.Name : 
            (expediente.ONE_Direccion_Ceremonia__c != null) ? dirParticular : noInformado;
            momento.direnv = expediente.ONE_Direccion_Ceremonia__c != null ? expediente.ONE_Direccion_Ceremonia__c : noInformado;
            momento.id_posenv = expediente.ONE_Codigo_Postal_Ceremonia__c != null ? expediente.ONE_Codigo_Postal_Ceremonia__c : postalDefault;
            momento.pobenv = expediente.ONE_Municipio_Ceremonia__c != null ? expediente.ONE_Municipio_Ceremonia__c : noInformado;
            momento.telcontacto = expediente.ONE_Lugar_Ceremonia__r?.Phone;
            momento.movcontacto = null;
            momento.sala = Integer.valueOf(expediente.ONE_Sala_Ceremonia__r?.ONE_Numero_De_Sala__c);

            inicio = expediente.ONE_Inicio_Ceremonia__c;
            fin = expediente.ONE_Fin_Ceremonia__c;

            if (inicio != null && fin != null) {
                // Ambos informados
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(fin);
                momento.horfin = ONE_CommonUtils.formatTimeValue(fin);

            } else if (inicio != null) {
                // Solo inicio informado
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(inicio);
                momento.horfin = horaFinDefault;

            } else {
                // Inicio no informado -> hoy
                momento.fecini = fechaDefault;
                momento.horini = horaIniDefault;
                momento.fecfin = fechaDefault;
                momento.horfin = horaFinDefault;
            }

            momentos.add(momento);
        }

        // INHUMACION
        if (expediente.ONE_Cementerio__c) {
        
            momento = new ONE_FuneflorIntegrationCallout.Momento();

            momento.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento('Inhumacion');
            //momento.difex = expediente.Name;
            momento.nomenv = expediente.ONE_Destino_Final__r?.Name != null ? expediente.ONE_Destino_Final__r?.Name : noInformado;
            momento.direnv = expediente.ONE_Destino_Final__r?.ONE_Direccion__c != null ? expediente.ONE_Destino_Final__r?.ONE_Direccion__c : noInformado;
            momento.id_posenv = expediente.ONE_Codigo_Postal_Destino_Final__c != null ? expediente.ONE_Codigo_Postal_Destino_Final__c : postalDefault;
            momento.pobenv = expediente.ONE_Municipio_Destino_Final__c != null ? expediente.ONE_Municipio_Destino_Final__c : noInformado;
            momento.telcontacto = expediente.ONE_Destino_Final__r?.Phone;
            momento.movcontacto = null;
            momento.sala = null;

            if (expediente.ONE_Hora_Destino_Final__c != null) {
                momento.fecini = ONE_CommonUtils.formatDateValue(expediente.ONE_Hora_Destino_Final__c);
                momento.horini = ONE_CommonUtils.formatTimeValue(expediente.ONE_Hora_Destino_Final__c);

                //inhumacion fin = ini
                momento.fecfin = ONE_CommonUtils.formatDateValue(expediente.ONE_Hora_Destino_Final__c);
                momento.horfin = ONE_CommonUtils.formatTimeValue(expediente.ONE_Hora_Destino_Final__c);
            }
            else {
                momento.fecini = fechaDefault;
                momento.horini = horaIniDefault;
                momento.fecfin = fechaDefault;
                momento.horfin = horaFinDefault;
            }            

            momentos.add(momento);
        }

        // INCINERACION
        if (expediente.ONE_Incineracion__c) {
        
            momento = new ONE_FuneflorIntegrationCallout.Momento();

            momento.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento('Incineracion');
            //momento.difex = expediente.Name;
            momento.nomenv = expediente.ONE_Lugar_Incineracion__r?.Name != null ? expediente.ONE_Lugar_Incineracion__r?.Name : noInformado;
            momento.direnv = expediente.ONE_Lugar_Incineracion__r?.ONE_Direccion__c != null ? expediente.ONE_Lugar_Incineracion__r?.ONE_Direccion__c : noInformado;
            momento.id_posenv = expediente.ONE_Codigo_Postal_Incineracion__c != null ? expediente.ONE_Codigo_Postal_Incineracion__c : postalDefault;
            momento.pobenv = expediente.ONE_Municipio_Incineracion__c != null ? expediente.ONE_Municipio_Incineracion__c : noInformado;
            momento.telcontacto = expediente.ONE_Lugar_Incineracion__r?.Phone;
            momento.movcontacto = null;
            momento.sala = null;

            inicio = expediente.ONE_Inicio_Incineracion__c;
            fin = expediente.ONE_Fin_Incineracion__c;

            if (inicio != null && fin != null) {
                // Ambos informados
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(fin);
                momento.horfin = ONE_CommonUtils.formatTimeValue(fin);

            } else if (inicio != null) {
                // Solo inicio informado
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(inicio);
                momento.horfin = horaFinDefault;

            } else {
                // Inicio no informado -> hoy
                momento.fecini = fechaDefault;
                momento.horini = horaIniDefault;
                momento.fecfin = fechaDefault;
                momento.horfin = horaFinDefault;
            }

            momentos.add(momento);
        }

        // DEPOSITO
        if (expediente.ONE_Deposito__c) {
        
            momento = new ONE_FuneflorIntegrationCallout.Momento();

            momento.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento('Deposito');
            //momento.difex = expediente.Name;
            momento.nomenv = expediente.ONE_Lugar_De_Deposito__r?.Name != null ? expediente.ONE_Lugar_De_Deposito__r?.Name : noInformado;
            momento.direnv = expediente.ONE_Lugar_De_Deposito__r?.ONE_Direccion__c != null ? expediente.ONE_Lugar_De_Deposito__r?.ONE_Direccion__c : noInformado;
            momento.id_posenv = expediente.ONE_Lugar_De_Deposito__r?.ONE_Codigo_Postal__c != null ? expediente.ONE_Lugar_De_Deposito__r?.ONE_Codigo_Postal__c : postalDefault;
            momento.pobenv = expediente.ONE_Lugar_De_Deposito__r?.ONE_Municipio_Direccion__c != null ? expediente.ONE_Lugar_De_Deposito__r?.ONE_Municipio_Direccion__c : noInformado;
            momento.telcontacto = expediente.ONE_Lugar_De_Deposito__r?.Phone;
            momento.movcontacto = null;
            momento.sala = Integer.valueOf(expediente.ONE_Sala_Deposito__r?.ONE_Numero_De_Sala__c);

            inicio = expediente.ONE_Inicio_Deposito__c;
            fin = expediente.ONE_Fin_Deposito__c;

            if (inicio != null && fin != null) {
                // Ambos informados
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(fin);
                momento.horfin = ONE_CommonUtils.formatTimeValue(fin);

            } else if (inicio != null) {
                // Solo inicio informado
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(inicio);
                momento.horfin = horaFinDefault;

            } else {
                // Inicio no informado -> hoy
                momento.fecini = fechaDefault;
                momento.horini = horaIniDefault;
                momento.fecfin = fechaDefault;
                momento.horfin = horaFinDefault;
            }
            
            momentos.add(momento);
        }

        // DESPEDIDA
        if (expediente.ONE_Despedida__c) {
        
            momento = new ONE_FuneflorIntegrationCallout.Momento();

            momento.id_mom = ONE_FuneflorIntegrationHelper.getIDMomento('Despedida');
            //momento.difex = expediente.Name;
            momento.nomenv = expediente.ONE_Lugar_Despedida__r?.Name != null ? expediente.ONE_Lugar_Despedida__r?.Name : noInformado;
            momento.direnv = expediente.ONE_Lugar_Despedida__r?.ONE_Direccion__c != null ? expediente.ONE_Lugar_Despedida__r?.ONE_Direccion__c : noInformado;
            momento.id_posenv = expediente.ONE_Lugar_Despedida__r?.ONE_Codigo_Postal__c != null ? expediente.ONE_Lugar_Despedida__r?.ONE_Codigo_Postal__c : postalDefault;
            momento.pobenv = expediente.ONE_Lugar_Despedida__r?.ONE_Municipio_Direccion__c != null ? expediente.ONE_Lugar_Despedida__r?.ONE_Municipio_Direccion__c : noInformado;
            momento.telcontacto = expediente.ONE_Lugar_Despedida__r?.Phone;
            momento.movcontacto = null;
            momento.sala = Integer.valueOf(expediente.ONE_Sala_Despedida__r?.ONE_Numero_De_Sala__c);

            inicio = expediente.ONE_Inicio_Despedida__c;
            fin = expediente.ONE_Fin_Despedida__c;

            if (inicio != null && fin != null) {
                // Ambos informados
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(fin);
                momento.horfin = ONE_CommonUtils.formatTimeValue(fin);

            } else if (inicio != null) {
                // Solo inicio informado
                momento.fecini = ONE_CommonUtils.formatDateValue(inicio);
                momento.horini = ONE_CommonUtils.formatTimeValue(inicio);
                momento.fecfin = ONE_CommonUtils.formatDateValue(inicio);
                momento.horfin = horaFinDefault;

            } else {
                // Inicio no informado -> hoy
                momento.fecini = fechaDefault;
                momento.horini = horaIniDefault;
                momento.fecfin = fechaDefault;
                momento.horfin = horaFinDefault;
            }
            
            momentos.add(momento);
        }

        return momentos;
        

    }

}
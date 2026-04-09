public with sharing class ONE_PedidoDatosParroquialesDataFactory {

    public static ONE_PedidoDatosParroquialesPdfService.DatosParroquialesData buildData(Id pedidoId, String language) {

        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);
        ONE_Tarea__c tarea = selectTarea(pedidoId);
        
        string logo = pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        
        ONE_PdfServiceBase.HeaderData headerData = new ONE_PdfServiceBase.HeaderData(
                pedido?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Name,
                pedido?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Phone,
                pedido?.ONE_Expediente__r?.Owner.FirstName + ' ' + pedido?.ONE_Expediente__r?.Owner.LastName,
                pedido?.Name,
                String.valueOf(pedido?.ONE_Fecha__c), 
                pedido?.ONE_Proveedor__r?.Name,
                pedido?.ONE_Expediente__r?.Name,
                pedido.ONE_Expediente__r?.ONE_Difunto__r?.FirstName + ' ' + pedido?.ONE_Expediente__r?.ONE_Difunto__r?.LastName,
                logo,
                pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name);

        headerData.parroquia = pedido?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name;

        ONE_PedidoDatosParroquialesPdfService.DatosParroquialesData datosParroquiales
                = new ONE_PedidoDatosParroquialesPdfService.DatosParroquialesData(language, headerData);

        datosParroquiales.documentCode = getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PEDIDO_DATOS_PARROQUIALES);

        datosParroquiales.difunto = new ONE_PedidoDatosParroquialesPdfService.DatosDelDifunto();
        datosParroquiales.difunto.nombre = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.FirstName)
                + ' ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.LastName);
        datosParroquiales.difunto.nombreColoquial = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nombre_Coloquial__c);
        datosParroquiales.difunto.fechaNacimiento = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_de_nacimiento__pc?.format());
        datosParroquiales.difunto.edad = pedido.ONE_Expediente__r.ONE_Edad_Del_Difunto__c;
        datosParroquiales.difunto.nacionalidad = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nacionalidad__c);
        datosParroquiales.difunto.lugarNacimiento = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Lugar_de_Nacimiento__pc);
        datosParroquiales.difunto.nombrePadres = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Padres__c)
                + ' y ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nombre_De_La_Madre__c);
        datosParroquiales.difunto.domicilio = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Direccion__pc)
            	+ ' ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Municipio__pc )
                + ' ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Codigo_Postal__pc)
                + ' ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Pais__pc);
        datosParroquiales.difunto.estadoCivil = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Estado_Civil__c);
        datosParroquiales.difunto.conyuge = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Conyuge__c);
        datosParroquiales.difunto.hijos = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Hijos__c);

        datosParroquiales.defuncion = new ONE_PedidoDatosParroquialesPdfService.DatosDeLaDefuncion();
        datosParroquiales.defuncion.fecha = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Fecha_De_Defuncion__c?.format());
        datosParroquiales.defuncion.lugar = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__r?.Name)
                + ': ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_De_Defuncion__c);
        datosParroquiales.defuncion.poblacion = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_De_Defuncion__c)
                + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_De_Defuncion__c);
        datosParroquiales.ceremoniaDestino = new ONE_PedidoDatosParroquialesPdfService.DatosDeLaCeremoniaDestino();
        datosParroquiales.ceremoniaDestino.domicilioMortuorio = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Nombre_Domicilio_Mortuorio__c);
        datosParroquiales.ceremoniaDestino.pob = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Provincia_Domicilio_Mortuorio__c);
		datosParroquiales.ceremoniaDestino.ceremoniaEn =
            ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name) + ' - '
            + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Ceremonia__c);
        datosParroquiales.ceremoniaDestino.pob2 = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c) 
            + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Ceremonia__c);
        datosParroquiales.ceremoniaDestino.fecha = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c?.format());
        datosParroquiales.ceremoniaDestino.tipoCeremonia = ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Tipo_De_Ritual_Ceremonia__c);
        datosParroquiales.ceremoniaDestino.idioma = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Idioma__c);       
        if(pedido?.ONE_Expediente__r?.ONE_Incineracion__c == true && pedido?.ONE_Expediente__r?.ONE_Cementerio__c == true ){
            datosParroquiales.ceremoniaDestino.cementerioCrematorio =
                ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Incineracion__r.Name)
                + ' - ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Incineracion__c)
                + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Incineracion__c)
                + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Incineracion__c);          
        }else if(pedido?.ONE_Expediente__r?.ONE_Incineracion__c == true){
            datosParroquiales.ceremoniaDestino.cementerioCrematorio =
                ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Lugar_Incineracion__r.Name)
                + ' - ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Incineracion__c)
                + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Incineracion__c)
                + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Incineracion__c);          
        }else if(pedido?.ONE_Expediente__r?.ONE_Cementerio__c == true){
            datosParroquiales.ceremoniaDestino.cementerioCrematorio =
                ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Tipo_De_Lugar_Destino_Final__c)
                + ' - ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_Destino_Final__c)
                + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Municipio_Destino_Final__c)
                + ', ' + ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Codigo_Postal_Destino_Final__c);                
        }else{
            datosParroquiales.ceremoniaDestino.cementerioCrematorio = '';   
        }                        
        datosParroquiales.ceremoniaDestino.fecha2 = String.valueOf(pedido?.ONE_Expediente__r?.ONE_Hora_Destino_Final__c);
        datosParroquiales.reciboCeremonia = new ONE_PedidoDatosParroquialesPdfService.ReciboCeremonia();
        datosParroquiales.reciboCeremonia.nServicio = '';
        datosParroquiales.reciboCeremonia.laCantidadDe = '';
        datosParroquiales.reciboCeremonia.enConcepto = '';
        datosParroquiales.reciboCeremonia.enFecha = '';
        datosParroquiales.reciboCeremonia.realizadaEn = '';
        datosParroquiales.comentarios = ONE_CommonUtils.changeNullToBlank(tarea?.ONE_Comentarios__c);       
        if (pedido.ONE_Expediente__r.ONE_Declarante__c != null) {
            ONE_Interlocutor__c interlocutor = selectInterlocutor(pedido.ONE_Expediente__c);
            datosParroquiales.difunto.declarante = ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r.FirstName)
                    + ' ' + ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r.LastName);
            datosParroquiales.difunto.parentesco = ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Relacion_con_el_difunto__c);
            datosParroquiales.difunto.telDeclarante = ONE_CommonUtils.changeNullToBlank(interlocutor.ONE_Contacto__r.Phone);

            datosParroquiales.reciboCeremonia.reciboDe = ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.FirstName)
                    + ' ' + ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.LastName)
                    + ' Con número de documento: ' + ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.ONE_N_Documento__pc);
        }

        return datosParroquiales;
    }

    private static String getDocumentCode(String mtName) {
        return [
                SELECT Label
                FROM ONE_Codigo_de_documento__mdt
                WHERE DeveloperName = :mtName
        ].Label;
    }

    public static ONE_Interlocutor__c selectInterlocutor(Id expedienteId) {
        return [
                SELECT ONE_Contacto__r.FirstName,
                       ONE_Contacto__r.LastName,
                       ONE_Relacion_con_el_difunto__c,
                       ONE_Contacto__r.Phone,
                       ONE_Contacto__r.ONE_N_Documento__pc
                FROM  ONE_Interlocutor__c
                WHERE ONE_Expediente__c = :expedienteId
                LIMIT 1
        ];
    }
        
    public static ONE_Tarea__c selectTarea(Id pedidoProveedorId) {
        
        return [
            SELECT
            ONE_Idioma__c, 
            ONE_Comentarios__c
            FROM 
            ONE_Tarea__c
            WHERE
            ONE_Pedido_De_Proveedor__c =: pedidoProveedorId Limit 1];
    }

    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedor(Id pedidoId) {
        return [
                SELECT Id,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Phone,
                       ONE_Expediente__r.ONE_Difunto__r.FirstName,
                       ONE_Expediente__r.ONE_Difunto__r.LastName,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_de_nacimiento__pc,
                       ONE_Expediente__r.ONE_Edad_Del_Difunto__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Nacionalidad__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_Nacimiento__pc,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Padres__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_De_La_Madre__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Direccion__pc,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Provincia__pc,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Pais__pc,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Estado_Civil__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Conyuge__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Hijos__c,
                       ONE_Expediente__r.ONE_Fecha_De_Defuncion__c,
                       ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.Name,
                       ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
                       ONE_Expediente__r.ONE_Provincia_De_Defuncion__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_De_Defuncion__c,
                       ONE_Expediente__r.ONE_Nombre_Domicilio_Mortuorio__c,
                       ONE_Expediente__r.ONE_Provincia_Domicilio_Mortuorio__c,
                       ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
                       ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c,
                       ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                       ONE_Expediente__r.ONE_Inicio_Ceremonia__c,
                       ONE_Expediente__r.ONE_Tipo_De_Lugar_De_Ceremonia__c,
                       ONE_Expediente__r.ONE_Idioma__c,
                       ONE_Expediente__r.ONE_Tipo_De_Lugar_Destino_Final__c,
                       ONE_Expediente__r.ONE_Direccion_Destino_Final__c,
                       ONE_Expediente__r.ONE_Municipio_Destino_Final__c,
                       ONE_Expediente__r.ONE_Provincia_Destino_Final__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_Destino_Final__c,
                       ONE_Expediente__r.ONE_Hora_Destino_Final__c,
                       ONE_Expediente__r.Owner.FirstName,
                       ONE_Expediente__r.Owner.LastName,
                       ONE_Expediente__r.ONE_Declarante__c,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Municipio__pc,
                       ONE_Expediente__r.ONE_Difunto__r.ONE_Codigo_Postal__pc,
            		   ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                       Name,
                       ONE_Fecha__c,
                       ONE_Proveedor__r.Name,
                       ONE_Expediente__r.Name,
                       ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                       ONE_Expediente__r.ONE_Tipo_De_Ritual_Ceremonia__c,
                       ONE_Expediente__r.ONE_Incineracion__c,
                       ONE_Expediente__r.ONE_Cementerio__c,
            		   ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,
            		   ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name,
            		   ONE_Expediente__r.ONE_Direccion_Incineracion__c,
                       ONE_Expediente__r.ONE_Municipio_Incineracion__c,
                       ONE_Expediente__r.ONE_Codigo_Postal_Incineracion__c
                FROM ONE_Pedido_De_Proveedor__c
                WHERE Id = :pedidoId
        ];
    }

}
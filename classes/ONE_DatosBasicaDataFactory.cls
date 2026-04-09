//Class to define all the queries that will get all the apropiate data to generate the PDF
public with sharing class ONE_DatosBasicaDataFactory {  

    //Get all the data and store in the Data object created    
    public static ONE_DatosBasicaData buildDatosBasicaData(String pedidoId, String language) {
        ONE_Pedido_De_Proveedor__c pedido = ONE_PedidoDeProveedorSelector.selectPedidoDeProveedorForPdfGeneration(pedidoId);
        ONE_Interlocutor__c interlocutor = selectInterlocutor(pedido.ONE_Expediente__c);
        ONE_DatosBasicaData.DatosDeDfuncion datosDeDfuncion = buildDatosDeDfuncion(pedido);
        ONE_DatosBasicaData.DatosDelContacto datosDelContacto = buildDatosDelContacto(interlocutor);
        ONE_DatosBasicaData.Velatorio velatorio = buildVelatorio(interlocutor);
        ONE_DatosBasicaData.Despedida despedida = buildDespedida(interlocutor);
        ONE_DatosBasicaData.Ceremonia ceremonia = buildCeremonia(interlocutor);
        ONE_DatosBasicaData.Finilizacion finilizacion = buildFinilizacion(interlocutor);
        
        ONE_DatosBasicaData.DatosDelDifunto datosDelDifunto = buildDatosDelDifunto(pedido);
        System.debug('datosDelDifunto: ' + datosDelDifunto);
        System.debug('Logo 1: ' + pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c);
        System.debug('Logo 2: ' + pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name);

        String logo = pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null ? pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c : pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        
        
        
        ONE_DatosBasicaData data = new ONE_DatosBasicaData(
            pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c,
            language,
            getDocumentCode(ONE_CommonConstants.CM_CODIGO_DE_DOCUMENTO_DATOS_BASICOS),
            pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
            ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.ONE_Compania__r.Name),
            pedido.ONE_Expediente__r.ONE_Numero_de_Poliza__c,
            pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
            pedido.ONE_Expediente__r.Name,
            ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.Owner.FirstName) + ' ' + ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.Owner.LastName),
            ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.ONE_Difunto__r.FirstName) + ' ' + ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.ONE_Difunto__r.LastName),
            pedido.Name,
            pedido.ONE_Fecha__c,
            pedido.ONE_Proveedor__r?.Name,
            datosDeDfuncion,
            datosDelDifunto,
            datosDelContacto,
            velatorio,
            despedida,
            ceremonia,
            finilizacion,
            pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c
        ); 
        
        return data;
    }
    //Build datos del difunto data
    private static ONE_DatosBasicaData.DatosDelDifunto buildDatosDelDifunto(ONE_Pedido_De_Proveedor__c pedido) {
        return new ONE_DatosBasicaData.DatosDelDifunto(
            ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r?.ONE_Difunto__r?.FirstName) + ' ' + ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.ONE_Difunto__r.LastName),
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nombre_Coloquial__c,
            pedido.ONE_Expediente__r?.ONE_Numero_de_Documento__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nacionalidad__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Lugar_de_nacimiento__pc,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Edad__c != null ? String.valueOf(pedido.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c) : '',
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Altura_Cm__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Peso_Kg__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Padres__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nombre_De_La_Madre__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Estado_Civil__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Numero_de_los_hijos__c,
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Conyuge__c,
            ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Direccion__pc) + ', ' + ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.ONE_Difunto__r.ONE_Municipio__pc),
            ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Provincia__pc) + ', ' + ONE_CommonUtils.changeNullToBlank(pedido.ONE_Expediente__r.ONE_Difunto__r.ONE_Codigo_Postal__pc),
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_de_nacimiento__pc != null ? pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_de_nacimiento__pc.format() : '',
            pedido.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Provincia_nacimiento__c
        );
    }
    //Build datos del contacto data    
    private static ONE_DatosBasicaData.DatosDelContacto buildDatosDelContacto(ONE_Interlocutor__c interlocutor) {
        return new ONE_DatosBasicaData.DatosDelContacto(
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.FirstName) + ' ' + ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.LastName),
            interlocutor?.ONE_Relacion_con_el_difunto__c,
            interlocutor?.ONE_Contacto__r?.ONE_N_Documento__pc,
            interlocutor?.ONE_Contacto__r?.Phone,
            interlocutor?.ONE_Contacto__r?.ONE_Email__c,
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.ONE_Tipo_De_Calle_Picklist__c)+ ' '+ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.ONE_Direccion__pc)+ ' '+ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.ONE_Municipio__pc)+ ' '+ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.ONE_Provincia__pc)+ ' '+ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Contacto__r?.ONE_Codigo_Postal__pc)
        );
    }

    //Build datos de defuncion data      
    private static ONE_DatosBasicaData.DatosDeDfuncion buildDatosDeDfuncion(ONE_Pedido_De_Proveedor__c pedido) {
        return new ONE_DatosBasicaData.DatosDeDfuncion(pedido?.ONE_Expediente__r?.ONE_Tipo_De_Lugar_De_Defuncion__c,pedido?.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__r?.Name,
            ONE_CommonUtils.changeNullToBlank(pedido?.ONE_Expediente__r?.ONE_Direccion_De_Defuncion__c),
            pedido?.ONE_Expediente__r?.ONE_Fecha_De_Defuncion__c != null ? String.valueOf(pedido?.ONE_Expediente__r?.ONE_Fecha_De_Defuncion__c?.format()) : '',
            pedido?.ONE_Expediente__r?.ONE_Causas_Defuncion__c,
            pedido?.ONE_Expediente__r?.ONE_Municipio_De_Defuncion__c
        );
    }

    //Build datos velatorio data        
    private static ONE_DatosBasicaData.Velatorio buildVelatorio(ONE_Interlocutor__c interlocutor) {
        System.debug('DATOS VELACION + ' + String.valueOf(interlocutor?.ONE_Expediente__r?.ONE_Inicio_Velacion__c?.format()) + ' + ' + String.valueOf(interlocutor?.ONE_Expediente__r?.ONE_Fin_Velacion__c?.format()) + ' + ' + interlocutor?.ONE_Expediente__r?.ONE_Sala_De_Velacion__r?.Name + ' + ' + String.valueOf(interlocutor?.ONE_Expediente__r?.ONE_Observaciones_Velacion__c));
        return new ONE_DatosBasicaData.Velatorio(
            getVelatorioLugar(interlocutor),
            interlocutor?.ONE_Expediente__r?.ONE_Inicio_Velacion__c == null ? '' : String.valueOf(interlocutor?.ONE_Expediente__r?.ONE_Inicio_Velacion__c?.format()),
            interlocutor?.ONE_Expediente__r?.ONE_Fin_Velacion__c == null ? '' : String.valueOf(interlocutor?.ONE_Expediente__r?.ONE_Fin_Velacion__c?.format()),
            interlocutor?.ONE_Expediente__r?.ONE_Tipo_De_Lugar_De_Velacion__c != null && interlocutor?.ONE_Expediente__r?.ONE_Tipo_De_Lugar_De_Velacion__c == 'Externo' ? 'Sala ' + (interlocutor?.ONE_Expediente__r?.Numero_Sala_Velacion_Ext__c != null ? interlocutor?.ONE_Expediente__r?.Numero_Sala_Velacion_Ext__c : '') : interlocutor?.ONE_Expediente__r?.ONE_Sala_De_Velacion__r?.Name,
        	interlocutor?.ONE_Expediente__r?.ONE_Observaciones_Velacion__c
        );
        
        
    }
    
    private static ONE_DatosBasicaData.Despedida buildDespedida(ONE_Interlocutor__c interlocutor) {
        return new ONE_DatosBasicaData.Despedida(
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Lugar_Despedida__r?.Name),
            interlocutor?.ONE_Expediente__r?.ONE_Inicio_Despedida__c == null ? '' : String.valueOf(interlocutor?.ONE_Expediente__r?.ONE_Inicio_Despedida__c?.format()),
            interlocutor?.ONE_Expediente__r?.ONE_Tipo_De_Ritual_Ceremonia__c,            
            interlocutor?.ONE_Expediente__r?.ONE_Sala_Despedida__c,
            interlocutor?.ONE_Expediente__r?.ONE_Observaciones_Despedida__c
        );
        
    }

    //Build datos lugar velatorio data            
    private static String getVelatorioLugar(ONE_Interlocutor__c interlocutor) {
        if (interlocutor?.ONE_Expediente__c == null) {
            return '';
        }
        return ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r.Name) + 
            + ' ' + ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r.ONE_Municipio_Velacion__c);
    }

    //Build datos ceremonia data               
    private static ONE_DatosBasicaData.Ceremonia buildCeremonia(ONE_Interlocutor__c interlocutor) {
        return new ONE_DatosBasicaData.Ceremonia(
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name) + ' ' + 
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c),
            interlocutor?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c  == null ? '' : String.valueOf(interlocutor?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c ?.format()),
            interlocutor?.ONE_Expediente__r?.ONE_Tipo_De_Ritual_Ceremonia__c,
            interlocutor?.ONE_Expediente__r?.ONE_Sala_Ceremonia__r?.Name,
            interlocutor?.ONE_Expediente__r?.ONE_Observaciones_Ceremonia__c
        );
    }
    
    //Build datos incineración data      
    private static ONE_DatosBasicaData.Finilizacion buildFinilizacion(ONE_Interlocutor__c interlocutor) {
        return new ONE_DatosBasicaData.Finilizacion(
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Lugar_Incineracion__r?.Name) + ' ' +
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Municipio_Incineracion__c),
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Destino_Final__r?.Name) + ' ' + 
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Municipio_Destino_Final__c),
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Destino_Traslado__r?.Name) + ' '+
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Destino_Traslado__r?.ONE_Municipio_Direccion__c) + ' '+
            ONE_CommonUtils.changeNullToBlank(interlocutor?.ONE_Expediente__r?.ONE_Destino_Traslado__r?.ONE_Provincia__c),
            '',
            interlocutor?.ONE_Expediente__r?.ONE_Cementerio__c,
            interlocutor?.ONE_Expediente__r?.ONE_Incineracion__c,
            interlocutor?.ONE_Expediente__r?.ONE_Destino_Traslado__c==null? false:true,
            interlocutor?.ONE_Expediente__r?.ONE_Inicio_Incineracion__c!=null?interlocutor?.ONE_Expediente__r?.ONE_Inicio_Incineracion__c.format('dd/MM/yyyy') +'  '+interlocutor?.ONE_Expediente__r?.ONE_Inicio_Incineracion__c.format('HH:mm'):'' ,
            interlocutor?.ONE_Expediente__r?.ONE_Hora_Destino_Final__c!=null?interlocutor?.ONE_Expediente__r?.ONE_Hora_Destino_Final__c.format('dd/MM/yyyy') +'  '+interlocutor?.ONE_Expediente__r?.ONE_Hora_Destino_Final__c.format('HH:mm'):'',
            interlocutor?.ONE_Expediente__r?.ONE_LocalizacionUnidadEnterramiento__c,
            interlocutor?.ONE_Expediente__r?.ONE_Familia_En_Destino_Final__c,
            interlocutor?.ONE_Expediente__r?.ONE_Fecha_Salida_Traslado__c!=null?interlocutor?.ONE_Expediente__r?.ONE_Fecha_Salida_Traslado__c.format('dd/MM/yyyy') + '  '+interlocutor?.ONE_Expediente__r?.ONE_Fecha_Salida_Traslado__c.format('HH:mm'):'',
            interlocutor?.ONE_Expediente__r?.ONE_Ambito_Traslado__c,
            interlocutor?.ONE_Expediente__r?.ONE_Funeraria_Origen_Destino_Recepcion__r.Name,
            interlocutor?.ONE_Expediente__r?.ONE_Observaciones_Traslado__c, //Añadido Rocio
            interlocutor?.ONE_Expediente__r?.ONE_PaisTraslado__c,
            interlocutor?.ONE_Expediente__r?.ONE_DestinoFinalTraslado__c,
            interlocutor?.ONE_Expediente__r?.ONE_Fecha_Hora_Compromiso__c != null ? interlocutor?.ONE_Expediente__r?.ONE_Fecha_Hora_Compromiso__c.format() : ''
        );
    }
    //Query ONE_Pedido_De_Proveedor__c data
    private static ONE_Pedido_De_Proveedor__c selectPedido(Id pedidoId) {
        return [
            SELECT ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name, ONE_Expediente__r.Owner.FirstName,
                ONE_Expediente__r.Owner.LastName, ONE_Expediente__r.Name, ONE_Expediente__r.ONE_Difunto__r.FirstName,
                ONE_Expediente__r.ONE_Difunto__r.LastName, ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                ONE_Expediente__r.ONE_Numero_de_Documento__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Nacionalidad__c,
            	ONE_Expediente__r.ONE_Difunto__r.ONE_Lugar_de_nacimiento__pc,ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Altura_Cm__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Peso_Kg__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Padres__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Nombre_De_La_Madre__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Estado_Civil__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Conyuge__c, ONE_Expediente__r.ONE_Difunto__r.ONE_Direccion__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Municipio__pc, ONE_Expediente__r.ONE_Difunto__r.ONE_Provincia__pc,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Pais__pc, ONE_Expediente__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c, ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
                ONE_Expediente__r.ONE_Provincia_De_Defuncion__c, ONE_Expediente__r.ONE_Fecha_De_Defuncion__c,
                ONE_Expediente__r.ONE_Causas_Defuncion__c, ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name, ONE_Expediente__r.ONE_Declarante__c,
            	ONE_Expediente__r.ONE_Difunto__r.ONE_Codigo_Postal__pc, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Logo_Pie_de_Pagina__c,
            	ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,ONE_Expediente__r.ONE_Compania__r.Name, ONE_Expediente__r.ONE_Numero_de_Poliza__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Provincia_nacimiento__c
            FROM ONE_Pedido_De_Proveedor__c
            WHERE Id = :pedidoId
        ];
    }
    //Query ONE_Interlocutor__c data
    private static ONE_Interlocutor__c selectInterlocutor(Id expedienteId) {
        List<ONE_Interlocutor__c> interlocutors = [
            SELECT ONE_Contacto__r.FirstName, ONE_Contacto__r.LastName, ONE_Relacion_con_el_difunto__c,
                ONE_Contacto__r.ONE_N_Documento__pc, ONE_Contacto__r.Phone,ONE_Contacto__r.ONE_Email__c,
            	ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,ONE_Expediente__r.ONE_Provincia_De_Defuncion__c, ONE_Expediente__r.ONE_Fecha_De_Defuncion__c,
                ONE_Expediente__r.ONE_Causas_Defuncion__c, ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name,
                ONE_Expediente__r.ONE_Direccion_Velacion__c, ONE_Expediente__r.ONE_Municipio_Velacion__c,
                ONE_Expediente__r.ONE_Provincia_Velacion__c, ONE_Expediente__r.ONE_Codigo_Postal_Velacion__c,
                ONE_Expediente__r.ONE_Inicio_Velacion__c, ONE_Expediente__r.ONE_Fin_Velacion__c,
                ONE_Expediente__r.ONE_Sala_De_Velacion__r.Name, ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
                ONE_Expediente__r.ONE_Direccion_Ceremonia__c, ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                ONE_Expediente__r.ONE_Provincia_Ceremonia__c, ONE_Expediente__r.ONE_Codigo_Postal_Ceremonia__c,
                ONE_Expediente__r.ONE_Fin_Ceremonia__c, ONE_Expediente__r.ONE_Inicio_Ceremonia__c,
                ONE_Expediente__r.ONE_Sala_Ceremonia__r.Name, ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name,
                ONE_Expediente__r.ONE_Destino_Final__r.Name, ONE_Expediente__r.ONE_Destino_Traslado__r.Name,
                ONE_Expediente__r.ONE_Destino_Traslado__r.ONE_Municipio_Direccion__c,toLabel(ONE_Expediente__r.ONE_Destino_Traslado__r.ONE_Provincia__c),
            	ONE_Expediente__r.ONE_Direccion_Incineracion__c,
            	ONE_Expediente__r.ONE_Municipio_Incineracion__c,
            	ONE_Expediente__r.ONE_Direccion_Destino_Final__c,
            	ONE_Expediente__r.ONE_Lugar_Despedida__r.Name,
            	ONE_Expediente__r.ONE_Inicio_Despedida__c,
            	ONE_Expediente__r.ONE_Tipo_De_Ritual_Ceremonia__c, 
            	ONE_Expediente__r.ONE_Observaciones_Despedida__c,
            	ONE_Expediente__r.ONE_Municipio_Destino_Final__c,
            	ONE_Expediente__r.ONE_Tipo_De_Lugar_De_Velacion__c,
            	ONE_Expediente__r.ONE_Sala_Despedida__c,
            	ONE_Expediente__r.Numero_Sala_Velacion_Ext__c,
                ONE_Contacto__r.ONE_Tipo_De_Calle_Picklist__c,ONE_Contacto__r.ONE_Direccion__pc, 
                ONE_Contacto__r.ONE_Codigo_Postal__pc, ONE_Contacto__r.ONE_Municipio__pc, toLabel(ONE_Contacto__r.ONE_Provincia__pc),
                toLabel(ONE_Contacto__r.ONE_Pais__pc), ONE_Expediente__r.ONE_Cementerio__c, ONE_Expediente__r.ONE_Incineracion__c,
                ONE_Expediente__r.ONE_Destino_Traslado__c,  ONE_Expediente__r.ONE_Inicio_Incineracion__c, ONE_Expediente__r.ONE_Fecha_Salida_Traslado__c,
                toLabel(ONE_Expediente__r.ONE_Ambito_Traslado__c), ONE_Expediente__r.ONE_Funeraria_Origen_Destino_Recepcion__r.Name,ONE_Expediente__r.ONE_Hora_Destino_Final__c,
                ONE_Expediente__r.ONE_Observaciones_Destino_Final__c, ONE_Expediente__r.ONE_Observaciones_Traslado__c, ONE_Expediente__r.ONE_LocalizacionUnidadEnterramiento__c, ONE_Expediente__r.ONE_Familia_En_Destino_Final__c, ONE_Expediente__r.ONE_Observaciones_Ceremonia__c, ONE_Expediente__r.ONE_Observaciones_Velacion__c,
                toLabel(ONE_Expediente__r.ONE_PaisTraslado__c), ONE_Expediente__r.ONE_DestinoFinalTraslado__c, ONE_Expediente__r.ONE_Fecha_Hora_Compromiso__c 
            FROM ONE_Interlocutor__c
            WHERE ONE_Expediente__r.Id = :expedienteId
            AND ONE_Declarante__c = TRUE
        ];
        
        return (interlocutors.size() != 1) ? null : interlocutors.get(0);
    }

    //Query document code from a custom metada type to display it in the PDF header        
    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }

}
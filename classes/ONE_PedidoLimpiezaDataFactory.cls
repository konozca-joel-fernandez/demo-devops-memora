public with sharing class ONE_PedidoLimpiezaDataFactory { 

    public static ONE_PedidoLimpiezaPdfService.LimpiezaData buildData(Id pedidoId, String language) {

        ONE_Pedido_De_Proveedor__c pedido = selectPedidoDeProveedor(pedidoId);

        String logo = pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? pedido.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : pedido.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;

        ONE_PedidoLimpiezaPdfService.LimpiezaData limpiezaData = new ONE_PedidoLimpiezaPdfService.LimpiezaData(language);
        limpiezaData.logoUrl = logo;
        limpiezaData.documentCode = getDocumentCode(ONE_CommonConstants.DOCUMENT_CODE_PEDIDO_LIMPIEZA);

        // Obtener la única tarea
        ONE_Tarea__c tarea = selectTarea(pedidoId).isEmpty() ? null : selectTarea(pedidoId)[0];
        if(tarea != null){
            limpiezaData.suscriptor = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.Name;
            limpiezaData.domicilioSuscriptor = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Direccion__pc;
            limpiezaData.poblacionSuscriptor = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Municipio__pc;
            limpiezaData.provinciaSuscriptor = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Provincia__c;
            limpiezaData.tipoDocumento = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Tipo_de_documento__pc;
            limpiezaData.numeroDocumento = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_N_documento__pc;
            limpiezaData.correoElectronico = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Email__c;
            limpiezaData.fecha = Date.today().format();
            limpiezaData.codigoPostal = tarea?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Codigo_Postal__pc;
            limpiezaData.concesion = tarea?.ONE_Expediente__r?.ONE_Concesion__c;
            limpiezaData.tipoDeEnterramiento = tarea?.ONE_Tipo_de_enterramiento__c;
            //limpiezaData.patio = tarea?.ONE_Patio__c;
            //limpiezaData.cuartel = tarea?.ONE_Cuartel__c;
            //limpiezaData.manzana = tarea?.ONE_Manzana__c;
            //limpiezaData.galeria = tarea?.ONE_GalerIa__c;
            //limpiezaData.fila = tarea?.ONE_Fila__c;
            //limpiezaData.numeroNicho = tarea?.ONE_Numero_Localizacion_Unidad__c;
            limpiezaData.localizacionUnidad = tarea?.ONE_LocalizacionUnidadEnterramiento__c;
            limpiezaData.dondeSeEncuentra = tarea?.ONE_Expediente__r?.ONE_Municipio_Destino_Final__c;
            limpiezaData.fechaDefuncion = tarea?.ONE_Expediente__r?.ONE_Fecha_de_defuncion__c != null ? tarea?.ONE_Expediente__r?.ONE_Fecha_de_defuncion__c.format() : '';
            limpiezaData.observaciones = tarea?.ONE_Comentarios__c;
            limpiezaData.numeroServicio = tarea?.ONE_Expediente__r?.Name;
            limpiezaData.tramitadoPor = tarea?.ONE_Expediente__r?.ONE_Nombre_Del_Asesor__c;
        }

        return limpiezaData;
    }

    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }

    public static List<ONE_Tarea__c> selectTarea(Id pedidoId) {
        return [
            SELECT ONE_Expediente__c,
                   //ONE_Tramitado_Por__c,
                   //ONE_Tramitado_Por__r.Name,
                   ONE_Comentarios__c,
                   //ONE_Cuartel__c,
                   //ONE_Fila__c,
                   //ONE_GalerIa__c,
                   //ONE_Manzana__c,
                   //ONE_Numero_Localizacion_Unidad__c,
                   //ONE_Patio__c,
                   ONE_Tipo_de_enterramiento__c,
                   ONE_Expediente__r.Name,
                   ONE_Expediente__r.ONE_Fecha_de_defuncion__c,
                   ONE_Expediente__r.ONE_Declarante__r.Name,
                   ONE_Expediente__r.ONE_Declarante__r.ONE_Tipo_de_documento__pc,
                   ONE_Expediente__r.ONE_Declarante__r.ONE_N_documento__pc,
                   ONE_Expediente__r.ONE_Declarante__r.ONE_Codigo_Postal__pc,
                   ONE_Expediente__r.ONE_Declarante__r.ONE_Municipio__pc,
                   ONE_Expediente__r.ONE_Declarante__r.ONE_Provincia__c,
                   ONE_Expediente__r.ONE_Declarante__r.ONE_Direccion__pc,
                   ONE_Expediente__r.ONE_Concesion__c,
                   ONE_Expediente__r.ONE_Municipio_Destino_Final__c,
                   ONE_Expediente__r.ONE_Destino_Final__r.Name,
                   ONE_Expediente__r.ONE_Declarante__r.ONE_Email__c,
                   ONE_Expediente__r.ONE_Nombre_Del_Asesor__c,
                   ONE_LocalizacionUnidadEnterramiento__c
            FROM ONE_Tarea__c
            WHERE ONE_Pedido_De_Proveedor__c = :pedidoId
            LIMIT 1
        ];
    }

    public static ONE_Pedido_De_Proveedor__c selectPedidoDeProveedor(Id pedidoId) {
        return [
            SELECT Id,
                   ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                   ONE_Expediente__r.Owner.FirstName,
                   ONE_Expediente__r.Owner.LastName,
                   Name,
                   ONE_Fecha__c,
                   ONE_Proveedor__r.Name,
                   ONE_Expediente__r.Name,
                   ONE_Email_Proveedor__c,
                   ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                   ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c
            FROM ONE_Pedido_De_Proveedor__c
            WHERE Id = :pedidoId
        ];
    }
}
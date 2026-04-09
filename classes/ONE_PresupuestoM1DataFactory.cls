/**
* Created by Miguel Angel Serrat on 17.05.2024.
*/

public class ONE_PresupuestoM1DataFactory {

    private static final String SERFUNLE_ZONE_EXTERNAL_ID = '10038';

    public static ONE_PresupuestoComercialData buildPresupuestoM1Data(String ordenDeVentaId, String language) {
        Boolean isFacturaMejora = false;
        //ONE_Presupuesto__c presupuestoRecord = selectPresupuestoForPdfGeneration(ordenDeVentaId);
        ONE_Orden_De_Venta__c ov = selectOrdenDeVentaForPDFGeneration(ordenDeVentaId);
        System.debug('Document query: ' + ordenDeVentaId);

        ONE_PresupuestoComercialData.HeaderData headerData = createHeaderData(ov);
        ONE_PresupuestoComercialData.DifuntoData difuntoData = createDifuntoData(ov);
        ONE_PresupuestoComercialData.ServicioData servicioData = createServicioData(ov);
        ONE_PresupuestoComercialData.MomentoListData momentoListData = ONE_MomentoService.getFacturaMomentoLists(ordenDeVentaId, language);
        Map<List<ONE_MomentoData>, Boolean> descuentosData = ONE_MomentoService.getFacturaDescuentosLists(ordenDeVentaId, language);
        Map<List<ONE_MomentoData>, Boolean> suplidosData = ONE_MomentoService.getFacturaSuplidosLists(ordenDeVentaId, language);
        List<ONE_PresupuestoComercialData.ImpuestosData> impuestosList = getImpuestosList(ov);
        List<ONE_Expediente_Line_Item__c> lineasExpediente = [SELECT ONE_Mejora_De_Compania__c, ONE_Importe_Descuento_Posicion__c 
                                                              FROM ONE_Expediente_Line_Item__c 
                                                              WHERE ONE_Orden_De_Venta__c = :ordenDeVentaId AND ONE_Estado__c != 'Eliminado'];

        for (ONE_Expediente_Line_Item__c linea : lineasExpediente) {
            if (linea.ONE_Mejora_De_Compania__c == true) {
                isFacturaMejora = true;
                break;
            }
        }
        
        string logo = ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null 
            ? ov.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        
        ONE_PresupuestoComercialData data = new ONE_PresupuestoComercialData(
            logo,
            language,
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Logo_Pie_de_Pagina__c,
            getTaxLabel(ov),
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Pie_de_pagina__c,
            ov.ONE_Importe_Total__c,
            headerData,
            difuntoData,
            servicioData,
            momentoListData,
            descuentosData,
            suplidosData,
            impuestosList,
            '',
            '',
            isFacturaMejora,
            false,
            false,
            '',
            generateSerfunle(ov),
            ov.recordtype.developername,
            '',
            ''
        );
		
        System.debug('DATA: ' + data);
        return data;
    }

    private static ONE_PresupuestoComercialData.HeaderData createHeaderData(ONE_Orden_De_Venta__c ov) {
        Boolean isPresupuestoSegundaVenta = false;
        if(ov.ONE_Tipo_De_Presupuesto__c == 'Presupuesto segunda venta') isPresupuestoSegundaVenta = true; 

        return new ONE_PresupuestoComercialData.HeaderData(
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name,
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Direccion__c + ', ' + ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Municipio_Direccion__c,
            getProvinciaString(ov),
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.Phone,
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.Fax,
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_Web__c,
            ov.Name, '', '', false, null, null, null,null,null,null,'',
            '',
            '', isPresupuestoSegundaVenta,
            false
        );
    }

    private static ONE_PresupuestoComercialData.DifuntoData createDifuntoData(ONE_Orden_De_Venta__c ov) {

       

        

        return new ONE_PresupuestoComercialData.DifuntoData(
            getDiuntoNombre(ov),
            ov.ONE_Servicio__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
            getDiuntoLugar(ov),
            ov.ONE_Servicio__r?.Name,
            ov.ONE_Servicio__r?.ONE_Numero_de_Poliza__c,
            ov.ONE_Servicio__r?.ONE_Numero_de_Siniestro__c,
            ONE_CommonUtils.changeNullToBlank(ONE_PdfGeneratorHelper.getNameOrNombreFiscalDeLaCuenta(ov)),
            ONE_CommonUtils.changeNullToBlank(ov.ONE_Pagador_Compania__r?.ONE_Direccion__c),
            ov.ONE_Pagador_Compania__r.ONE_CIF__c,
            true, //Interlocutor Empresa
            ONE_CommonUtils.changeNullToBlank(ov.ONE_Pagador_Compania__r?.ONE_Municipio_Direccion__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(ov.ONE_Pagador_Compania__r?.ONE_Provincia__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(ov.ONE_Pagador_Compania__r?.ONE_Codigo_Postal__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(ov.ONE_Pagador_Compania__r?.ONE_Pais__c),
                        ov.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                        //ov.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c == null ? null : ov.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c.date()
                //String.valueOf(ov.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
        );
    }

    private static ONE_PresupuestoComercialData.ServicioData createServicioData(ONE_Orden_De_Venta__c ov) {
        return new ONE_PresupuestoComercialData.ServicioData(
            ov.ONE_Servicio__r?.ONE_Inicio_Velacion__c,
            ov.ONE_Servicio__r?.ONE_Lugar_De_Velacion__r?.Name,
            ov.ONE_Servicio__r?.ONE_Direccion_Velacion__c,
            ov.ONE_Servicio__r?.ONE_Municipio_Velacion__c,
            ov.ONE_Servicio__r?.ONE_Inicio_Ceremonia__c,
            ov.ONE_Servicio__r?.ONE_Lugar_Ceremonia__r?.Name,
            ov.ONE_Servicio__r?.ONE_Direccion_Ceremonia__c,
            ov.ONE_Servicio__r?.ONE_Municipio_Ceremonia__c,
            ov.ONE_Servicio__r?.ONE_Inicio_Incineracion__c,
            ov.ONE_Servicio__r?.ONE_Lugar_Incineracion__r?.Name,
            ov.ONE_Servicio__r?.ONE_Direccion_Incineracion__c,
            ov.ONE_Servicio__r?.ONE_Municipio_Incineracion__c,
            ov.ONE_Servicio__r?.ONE_Hora_Destino_Final__c,
            ov.ONE_Servicio__r?.ONE_Destino_Final__r?.Name,
            ov.ONE_Servicio__r?.ONE_Direccion_Destino_Final__c,
            ov.ONE_Servicio__r?.ONE_Municipio_Destino_Final__c,
            ov.ONE_Servicio__r?.Recordtype?.Developername,
            '',
            '',
            ''
        );
    }
    
    private static String getProvinciaString(ONE_Orden_De_Venta__c ov) {
        return ONE_CommonUtils.changeNullToBlank(ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Provincia__c) + ' ' +
            ONE_CommonUtils.changeNullToBlank(ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_Postal__c);
    }

    private static String getDiuntoNombre(ONE_Orden_De_Venta__c ov) {
        return ONE_CommonUtils.changeNullToBlank(ov.ONE_Servicio__r?.ONE_Difunto__r?.FirstName) + ' ' +
            ONE_CommonUtils.changeNullToBlank(ov.ONE_Servicio__r?.ONE_Difunto__r?.LastName);
    }

    private static String getDiuntoLugar(ONE_Orden_De_Venta__c ov) {
        return ONE_CommonUtils.changeNullToBlank(ov.ONE_Servicio__r?.ONE_Direccion_De_Defuncion__c) + ' ' +
            ONE_CommonUtils.changeNullToBlank(ov.ONE_Servicio__r?.ONE_Municipio_De_Defuncion__c) + ' ' +
            ONE_CommonUtils.changeNullToBlank(ov.ONE_Servicio__r?.ONE_Codigo_Postal_De_Defuncion__c);
    }

    private static String getTaxLabel(ONE_Orden_De_Venta__c ov) {
        if (ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c != null &&
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c == 'IVA') {
            return Label.ONE_Doc_IVA;
        } else if (ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c != null &&
            ov.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c == 'IGIC') {
            return Label.ONE_Doc_IGIC;
        } else {
            return 'IVA/IGIC';
        }
    }

    private static Boolean checkTotalDescuento(List<ONE_Expediente_Line_Item__c> listOfOneExpedienteLineItem) {
        for (ONE_Expediente_Line_Item__c item : listOfOneExpedienteLineItem) {
            if (item.ONE_Importe_Descuento_Posicion__c != null && item.ONE_Importe_Descuento_Posicion__c != 0) {
                return true;
            }
        }
        return false;
    }

    private static String getContratoSignatureImgUrl(Id presupuestoId) {
        List<ContentDocumentLink> attachments = new List<ContentDocumentLink>([
            SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate,
                ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :presupuestoId AND (ContentDocument.Title LIKE :'Contrato%'  OR ContentDocument.Title LIKE :'Condiciones Generales de Contratación%')
            ORDER BY ContentDocument.CreatedDate DESC
        ]);

        if (attachments.isEmpty()) {
            return '';
        } else {
            String fileURL = '/sfc/servlet.shepherd/version/download/';
            fileURL += attachments.get(0).ContentDocument.LatestPublishedVersionId;
            System.debug('Signature url: ' + fileURL);
            return fileURL;
        }
    }

    private static List<ONE_PresupuestoComercialData.ImpuestosData> getImpuestosList(ONE_Orden_De_Venta__c ov) {
        List<ONE_PresupuestoComercialData.ImpuestosData> impuestosList = new List<ONE_PresupuestoComercialData.ImpuestosData>();
        List<String> taxStringList = new List<String>{
            '0', '3', '4', '10', '21', 'Suplido'
        };
        List<String> labelTable = new List<String>{
            Label.ONE_Doc_Servicio_0, Label.ONE_Doc_Servicio_3, Label.ONE_Doc_Servicio_4,
            Label.ONE_Doc_Servicio_10, Label.ONE_Doc_Servicio_21, Label.ONE_Doc_Suplidos
        };

        for (Integer i = 0; i < taxStringList.size(); i++) {
            ONE_PresupuestoComercialData.ImpuestosData impuestosRecord = new ONE_PresupuestoComercialData.ImpuestosData(
                labelTable.get(i),
                (Decimal) ov.get('ONE_Importe_Base_' + taxStringList.get(i) + '__c'),
                (Decimal) ov.get('ONE_Importe_Impuesto_' + taxStringList.get(i) + '__c'),
                (Decimal) ov.get('ONE_Importe_Neto_' + taxStringList.get(i) + '__c')
            );
            if (impuestosRecord.importeNeto != '0') {
                impuestosList.add(impuestosRecord);
            }
        }
        return impuestosList;
    }

    private static String generateSerfunle(ONE_Orden_De_Venta__c ov) {
        String result;
        try {
            result = ov.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
        } catch(Exception e) {
            result = null;
        }
        return result;
    }

    private static ONE_Orden_De_Venta__c selectOrdenDeVentaForPDFGeneration(Id ordenDeVentaId) {
        return [
            SELECT Id,
            	Name,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Logo_Pie_de_Pagina__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Direccion__c,
                toLabel(ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Provincia__c),
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Codigo_Postal__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Phone,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Fax,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c,
                CreatedDate, 
            	ONE_Servicio__c,
                ONE_Servicio__r.ONE_Difunto__r.FirstName,
                ONE_Servicio__r.ONE_Difunto__r.LastName,
                ONE_Servicio__r.ONE_Difunto__r.ONE_N_Documento__pc,
                ONE_Servicio__r.ONE_Direccion_De_Defuncion__c,
                ONE_Servicio__r.ONE_Municipio_De_Defuncion__c,
                ONE_Servicio__r.ONE_Codigo_Postal_De_Defuncion__c,
            	ONE_Servicio__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c,
                ONE_Servicio__r.Name,
                ONE_Importe_Total__c,
                ONE_Servicio__r.ONE_Numero_de_Poliza__c,
                ONE_Servicio__r.ONE_Numero_de_Siniestro__c,
                ONE_Servicio__r.ONE_Inicio_Velacion__c,
                ONE_Servicio__r.ONE_Lugar_De_Velacion__r.Name,
                ONE_Servicio__r.ONE_Direccion_Velacion__c,
                ONE_Servicio__r.ONE_Municipio_Velacion__c,
                ONE_Servicio__r.ONE_Inicio_Ceremonia__c,
                ONE_Servicio__r.ONE_Lugar_Ceremonia__r.Name,
                ONE_Servicio__r.ONE_Direccion_Ceremonia__c,
                ONE_Servicio__r.ONE_Municipio_Ceremonia__c,
                ONE_Servicio__r.ONE_Inicio_Incineracion__c,
                ONE_Servicio__r.ONE_Lugar_Incineracion__r.Name,
                ONE_Servicio__r.ONE_Direccion_Incineracion__c,
                ONE_Servicio__r.ONE_Municipio_Incineracion__c,
                ONE_Servicio__r.ONE_Hora_Destino_Final__c,
                ONE_Servicio__r.ONE_Destino_Final__r.Name,
                ONE_Servicio__r.ONE_Direccion_Destino_Final__c,
                ONE_Servicio__r.ONE_Municipio_Destino_Final__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                ONE_Importe_Base_0__c, ONE_Importe_Impuesto_0__c, ONE_Importe_Neto_0__c,
                ONE_Importe_Base_3__c, ONE_Importe_Impuesto_3__c, ONE_Importe_Neto_3__c,
                ONE_Importe_Base_4__c, ONE_Importe_Impuesto_4__c, ONE_Importe_Neto_4__c,
                ONE_Importe_Base_10__c, ONE_Importe_Impuesto_10__c, ONE_Importe_Neto_10__c,
                ONE_Importe_Base_21__c, ONE_Importe_Impuesto_21__c, ONE_Importe_Neto_21__c,
                ONE_Importe_Base_Suplido__c, ONE_Importe_Impuesto_Suplido__c, ONE_Importe_Neto_Suplido__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio_Direccion__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.Phone,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.Fax,
                toLabel(ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c),
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_Postal__c,
                //ONE_Interlocutor__r.ONE_Contacto__r.FirstName,
                //ONE_Interlocutor__r.ONE_Contacto__r.LastName,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_Direccion__pc,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_Municipio__pc,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_Codigo_Postal__pc,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_N_Documento__pc,
                ONE_Pagador_Compania__r.Name,
                ONE_Pagador_Compania__r.ONE_Direccion__c,
                ONE_Pagador_Compania__r.ONE_Municipio_Direccion__c,
                ONE_Pagador_Compania__r.ONE_Nombre_Anexo__c,
                ONE_Pagador_Compania__r.ONE_Codigo_Postal__c,
                toLabel(ONE_Pagador_Compania__r.ONE_Provincia__c),
                toLabel(ONE_Pagador_Compania__r.ONE_Pais__c),
                ONE_Pagador_Compania__r.ONE_CIF__c,
                ONE_Pagador_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c,
                ONE_Pagador_Compania__r.RecordType.DeveloperName,
                //ONE_tipo_Documento__c,
                //ONE_Tipo_De_Contrato__c,
            	//ONE_Tipo_De_Presupuesto__c,
                //Name,
                //ONE_Interlocutor__r.ONE_Contacto__r.Name,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_Direccion__c,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_Municipio_Direccion__c,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_Codigo_Postal__c,
                //ONE_Interlocutor__r.ONE_Contacto__r.ONE_CIF__c,
                //ONE_Interlutor_Empresa__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_External_ID__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name,
                //toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Provincia__pc),
                //toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Provincia__c),
                //toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Pais__pc),
                //toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Pais__c),
            	ONE_Servicio__r.Recordtype.Developername,
            	Recordtype.Developername,
            	ONE_Tipo_De_Presupuesto__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
        ];
    }
}
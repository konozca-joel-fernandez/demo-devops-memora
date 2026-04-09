public with sharing class ONE_AbonoParcialDataFactory {
    public static ONE_PresupuestoComercialData buildAbonoParcialData(String abonoParcialId, String documentType, String language) {
        Boolean isFacturaMejora = false;
        ONE_Abono_Parcial__c abonoParcialRecord = [SELECT
                                                   	ONE_Estado_Abono_Parcial__c,
													ONE_Orden_de_venta_AP__c,
                                                   	ONE_Numero_de_factura_rectificativa__c,
                                                   	ONE_Numero_Abono_Factura_Rectificativa__c,
                                                   	ONE_Orden_de_venta_AP__r.ONE_Numero_de_factura__c,
                                                   	ONE_Presupuesto_AP__r.Name,
                                                   	ONE_Fecha_De_Facturacion_Rectificativa__c,
    	                                           	ONE_Fecha_Abono_Factura_Rectificativa__c,
													ONE_Importe_Base_0_AP__c,
                                                   	ONE_Importe_Impuesto_0_AP__c,
                                                   	ONE_Importe_Neto_0_AP__c,
                                                   	ONE_Importe_Base_3_AP__c,
                                                   	ONE_Importe_Impuesto_3_AP__c,
                                                   	ONE_Importe_Neto_3_AP__c,
                                                   	ONE_Importe_Base_4_AP__c,
                                                   	ONE_Importe_Impuesto_4_AP__c,
                                                   	ONE_Importe_Neto_4_AP__c,
                                                   	ONE_Importe_Base_10_AP__c,
                                                   	ONE_Importe_Impuesto_10_AP__c,
                                                   	ONE_Importe_Neto_10_AP__c,
                                                   	ONE_Importe_Base_21_AP__c,
                                                   	ONE_Importe_Impuesto_21_AP__c,
                                                   	ONE_Importe_Neto_21_AP__c,
                                                   	ONE_Importe_Base_Suplido_AP__c,
                                                   	ONE_Importe_Impuesto_Suplido_AP__c,
                                                   	ONE_Importe_Neto_Suplido_AP__c,
                                                    ONE_Total_Importe_AP__c,
                                                    ONE_Identificador_TBAI_AP__c,
                                                    ONE_Identificador_TBAI_Cancelacion_AP__c,
                                                    ONE_Codigo_QR_TBAI_AP__c,
                                                    ONE_Orden_de_venta_AP__r.Recordtype.Developername,
                                                    ONE_Codigo_QR_TBAI_Cancelacion_AP__c
                                                   FROM ONE_Abono_Parcial__c WHERE Id = :abonoParcialId];
        ONE_Orden_De_Venta__c ordenDeVentaRecord = selectOrdenDeVentaForPdfGeneration(abonoParcialRecord.ONE_Orden_de_venta_AP__c);

        System.debug('Document query: ' + ordenDeVentaRecord);

        ONE_PresupuestoComercialData.HeaderData headerData = createHeaderData(ordenDeVentaRecord, abonoParcialRecord, documentType);
        ONE_PresupuestoComercialData.DifuntoData difuntoData = createDifuntoData(ordenDeVentaRecord);
        ONE_PresupuestoComercialData.ServicioData servicioData = createServicioData(ordenDeVentaRecord);
        ONE_PresupuestoComercialData.MomentoListData momentoListData = ONE_MomentoService.getAbonoParcialMomentoLists(abonoParcialId, documentType, language);
        Map<List<ONE_MomentoData>, Boolean> descuentosData = ONE_MomentoService.getAbonoParcialDescuentosLists(abonoParcialId, documentType, language);
        Map<List<ONE_MomentoData>, Boolean> suplidosData = ONE_MomentoService.getAbonoParcialSuplidosLists(abonoParcialId, documentType, language);
        List<ONE_PresupuestoComercialData.ImpuestosData> impuestosList = getAbonoParcialImpuestosList(abonoParcialRecord);
        List<ONE_Expediente_Line_Item__c> lineasExpediente = [SELECT ONE_Mejora_De_Compania__c, ONE_Importe_Descuento_Posicion__c FROM ONE_Expediente_Line_Item__c WHERE ONE_Abono_parcial__c = :abonoParcialId];

        for (ONE_Expediente_Line_Item__c linea : lineasExpediente) {
            if (linea.ONE_Mejora_De_Compania__c == true) {
                isFacturaMejora = true;
                break;
            }
        }
		String sociedadLogo;
        String sociedadPiePagina;
        String sociedadLogoPie;
        
        
        if(ordenDeVentaRecord.RecordType.DeveloperName=='ONE_OrdendeVenta_Gestoria'){
            Account sociedadAsistea=[SELECT ONE_URL_logo__c,ONE_Logo_Pie_de_Pagina__c,ONE_Pie_de_pagina__c
                                    FROM Account 
                                    WHERE ONE_External_ID_Sociedad__c=:System.Label.SociedadAsisteaCodigo AND Recordtype.Developername='ONE_Sociedades'];
            
            sociedadLogo=sociedadAsistea.ONE_URL_logo__c;
        	sociedadPiePagina=sociedadAsistea.ONE_Pie_de_pagina__c;
        	sociedadLogoPie=sociedadAsistea.ONE_Logo_Pie_de_Pagina__c;
            
        }else{
            sociedadLogo=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null
            ? ordenDeVentaRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        	sociedadPiePagina=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Logo_Pie_de_Pagina__c;
        	sociedadLogoPie=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Pie_de_pagina__c;
            
        }
     
        
        ONE_PresupuestoComercialData data = new ONE_PresupuestoComercialData(
            sociedadLogo,
            language,
            sociedadLogoPie,
            getTaxLabel(ordenDeVentaRecord),
            sociedadPiePagina,
            abonoParcialRecord.ONE_Total_Importe_AP__c,
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
            (ordenDeVentaRecord.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c == 'Presupuesto servicio completo') ? true : false,
            (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Particular' && ordenDeVentaRecord.ONE_Forma_De_Pago__c == 'A') ? true : false,
            ordenDeVentaRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Numero_De_Cuenta_Bancaria__c,
            generateSerfunle(ordenDeVentaRecord),
            ordenDeVentaRecord.recordtype.developername,
            '',
            ''
        );

        return data;
    }
    
    private static String generateSerfunle(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
        String result;
        try{
            result= ordenDeVentaRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
        }catch(Exception e){
            result= null;
        }
        return result;
    }

    private static ONE_PresupuestoComercialData.HeaderData createHeaderData(ONE_Orden_De_Venta__c ordenDeVentaRecord, ONE_Abono_Parcial__c abonoParcialRecord, String documentType) {
        Date fechaDocumento;
        String abonoNumber, facturaNumber, idTBAI, qrTBAI;
        String sociedadName;
        String sociedadWeb;
        String direccionCentro;
        String municipioCentro;
        String telefonoCentro;
        String faxCentro;
        Boolean isPresupuestoSegundaVenta = false;
        
         if(ordenDeVentaRecord.RecordType.DeveloperName=='ONE_OrdendeVenta_Gestoria'){
            Account centroAsistea=[SELECT ONE_Sociedad2__r.Name,ONE_Sociedad2__r.ONE_URL_Web__c,ONE_Direccion__c,ONE_Municipio_Direccion__c,Phone,Fax
                                    FROM Account 
                                    WHERE ONE_Centro_Memora_Codigo_SAP__c=:System.Label.CentroAsisteaCodigo AND Recordtype.Developername='ONE_Centro_Memora' LIMIT 1];
            
            sociedadName=centroAsistea.ONE_Sociedad2__r.Name;
            sociedadWeb=centroAsistea.ONE_Sociedad2__r.ONE_URL_Web__c;
            direccionCentro=centroAsistea.ONE_Direccion__c;
            municipioCentro=centroAsistea.ONE_Municipio_Direccion__c;
			telefonoCentro=centroAsistea.Phone;
            faxCentro=centroAsistea.Fax;
            if(ordenDeVentaRecord.ONE_Tipo_De_Presupuesto__c == 'Presupuesto segunda venta') isPresupuestoSegundaVenta = true; 

        }else{
        	sociedadName=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name;
            sociedadWeb=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_Web__c;
            direccionCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Direccion__c ;
            municipioCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Municipio_Direccion__c;
			telefonoCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.Phone;
            faxCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.Fax;
            if(ordenDeVentaRecord.ONE_Tipo_De_Presupuesto__c == 'Presupuesto segunda venta') isPresupuestoSegundaVenta = true; 

        }
        if (documentType == 'factura_rectificativa') {
            abonoNumber = abonoParcialRecord.ONE_Numero_de_factura_rectificativa__c;
            facturaNumber = abonoParcialRecord.ONE_Orden_de_venta_AP__r.ONE_Numero_de_factura__c;
            fechaDocumento = abonoParcialRecord.ONE_Fecha_De_Facturacion_Rectificativa__c;
            idTBAI = abonoParcialRecord.ONE_Identificador_TBAI_AP__c;
            qrTBAI = abonoParcialRecord.ONE_Codigo_QR_TBAI_AP__c;
        }
        else if (documentType == 'cancelacion_abono_parcial') {
            abonoNumber = abonoParcialRecord.ONE_Numero_Abono_Factura_Rectificativa__c;
            facturaNumber = abonoParcialRecord.ONE_Numero_de_factura_rectificativa__c;
            fechaDocumento = Date.newInstance(abonoParcialRecord.ONE_Fecha_Abono_Factura_Rectificativa__c.year(), abonoParcialRecord.ONE_Fecha_Abono_Factura_Rectificativa__c.month(), abonoParcialRecord.ONE_Fecha_Abono_Factura_Rectificativa__c.day());
            idTBAI = abonoParcialRecord.ONE_Identificador_TBAI_Cancelacion_AP__c;
            qrTBAI = abonoParcialRecord.ONE_Codigo_QR_TBAI_Cancelacion_AP__c;
        }
        System.debug('documentType-->' + documentType);
        System.debug('fechaDocumento-->' + fechaDocumento);

        return new ONE_PresupuestoComercialData.HeaderData(
            sociedadName,
            direccionCentro+ ', ' + municipioCentro,
            getProvinciaString(ordenDeVentaRecord),
            telefonoCentro,
            faxCentro,
            sociedadWeb,
            ordenDeVentaRecord.ONE_Presupuesto__r?.Name,
            abonoNumber,
            facturaNumber,
            (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Compañía' && ordenDeVentaRecord.ONE_Pagador_Compania__r.RecordType.DeveloperName == 'ONE_Centro_Memora') ? true : false,
            ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Nombre_Fiscal_De_La_Cuenta__c,
            ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Direccion__c,
            buildAddressCentro(ordenDeVentaRecord),
            fechaDocumento,
            ordenDeVentaRecord.ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_CIF__c,
            ordenDeVentaRecord.ONE_Tipo_De_Factura__c,
            'factura',
            idTBAI,
            qrTBAI,
            isPresupuestoSegundaVenta,
            ordenDeVentaRecord.ONE_Factura_Concesiones__c
        );
    }

    private static ONE_PresupuestoComercialData.DifuntoData createDifuntoData(ONE_Orden_De_Venta__c ordenDeVentaRecord) {

        ONE_PresupuestoComercialData.DifuntoData difuntoData;
       

        

        if (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Particular' && ordenDeVentaRecord.ONE_Pagador_Empresa__c == false) {

            difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                getDiuntoNombre(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                getDiuntoLugar(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.Name,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Poliza__c,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Siniestro__c,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.FirstName) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.LastName),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Direccion__pc),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r ?.ONE_N_Documento__pc),
                ordenDeVentaRecord.ONE_Pagador_Empresa__c,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Municipio__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Provincia__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Pais__pc),
                    ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                    //ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c == null ? null : ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c
                //String.valueOf(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
            );
        } else if (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Particular' && ordenDeVentaRecord.ONE_Pagador_Empresa__c == true) {

            difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                getDiuntoNombre(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                getDiuntoLugar(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.Name,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Poliza__c,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Siniestro__c,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Direccion__c),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_CIF__c),
                ordenDeVentaRecord.ONE_Pagador_Empresa__c,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Municipio_Direccion__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Provincia__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Codigo_Postal__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Pais__c),
                    ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                    //ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c == null ? null : ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c
                //String.valueOf(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)

            );
        } else if (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Compañía') {
            Id otrasCuentasId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS).getRecordTypeId();

            difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                getDiuntoNombre(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                getDiuntoLugar(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.Name,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Poliza__c,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Siniestro__c,
                //ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.Name),
                ONE_CommonUtils.changeNullToBlank(ONE_PdfGeneratorHelper.getNameOrNombreFiscalDeLaCuenta(ordenDeVentaRecord)),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Direccion__c),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_CIF__c),
                ordenDeVentaRecord.ONE_Pagador_Particular__c == null,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Municipio_Direccion__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Provincia__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Codigo_Postal__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Pais__c), /* + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_CIF__c)*/
                    ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                    //String.valueOf(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                //ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c == null ? null : ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c.date()
            );
        }

        return difuntoData;

    }

    private static ONE_PresupuestoComercialData.ServicioData createServicioData(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
        return new ONE_PresupuestoComercialData.ServicioData(
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Inicio_Velacion__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Lugar_De_Velacion__r?.Name,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Direccion_Velacion__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Municipio_Velacion__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Inicio_Ceremonia__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Lugar_Ceremonia__r?.Name,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Direccion_Ceremonia__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Municipio_Ceremonia__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Inicio_Incineracion__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Lugar_Incineracion__r?.Name,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Direccion_Incineracion__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Municipio_Incineracion__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Hora_Destino_Final__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Destino_Final__r?.Name,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Direccion_Destino_Final__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Municipio_Destino_Final__c,
            null,
            null,
            null,
            null
        );
    }

    private static String getProvinciaString(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
        if(ordenDeVentaRecord.RecordType.DeveloperName=='ONE_OrdendeVenta_Gestoria'){
            Account centroAsistea=[SELECT ONE_Provincia__c,ONE_Codigo_Postal__c FROM Account 
                                   WHERE ONE_Centro_Memora_Codigo_SAP__c=:System.Label.CentroAsisteaCodigo AND Recordtype.Developername='ONE_Centro_Memora'];
            return ONE_CommonUtils.changeNullToBlank(centroAsistea.ONE_Provincia__c) + ' ' +ONE_CommonUtils.changeNullToBlank(centroAsistea.ONE_Codigo_Postal__c);
        }
        return ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Provincia__c) + ' ' +
            ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_Postal__c);
    }
	@TestVisible
    private static String getDiuntoNombre(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
        return ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.FirstName) + ' ' +
            ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.LastName);
    }

    private static String getDiuntoLugar(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
        Schema.DescribeFieldResult F = ONE_Expediente__c.ONE_Provincia_De_Defuncion__c.getDescribe();
		List<Schema.PicklistEntry> P = F.getPicklistValues();
        String provincia;
        for(Schema.PicklistEntry e : P){
            if (e.getValue() == ordenDeVentaRecord.ONE_Servicio__r?.ONE_Provincia_De_Defuncion__c){
                provincia = e.getLabel();
            }
        }
        return /*ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Direccion_De_Defuncion__c) + ' ' +*/
            ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Municipio_De_Defuncion__c) + ', ' +
            /*ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Codigo_Postal_De_Defuncion__c) +*/ 
            provincia;
    }

    private static String getTaxLabel(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
        if (ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c != null &&
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c == 'IVA') {
            return Label.ONE_Doc_IVA;

        } else if (ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c != null &&
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c == 'IGIC') {
            return Label.ONE_Doc_IGIC;
        } else {
            return 'IVA/IGIC';
        }
    }
    
    @TestVisible
    private static Boolean checkTotalDescuento(List<ONE_Expediente_Line_Item__c> listOfOneExpedienteLineItem) {
        for (ONE_Expediente_Line_Item__c item : listOfOneExpedienteLineItem) {
            if (item.ONE_Importe_Descuento_Posicion__c != null && item.ONE_Importe_Descuento_Posicion__c != 0) {
                return true;
            }
        }
        return false;
    }

    private static String getContratoSignatureImgUrl(Id ordenDeVentaId, String fileName) {
        List<ContentDocumentLink> attachments = new List<ContentDocumentLink>([
            SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate,
                ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :ordenDeVentaId AND ContentDocument.Title LIKE :fileName + '%'
            ORDER BY ContentDocument.CreatedDate
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

    private static List<ONE_PresupuestoComercialData.ImpuestosData> getAbonoParcialImpuestosList(ONE_Abono_Parcial__c abonoParcialRecord) {
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
                (Decimal) abonoParcialRecord.get('ONE_Importe_Base_' + taxStringList.get(i) + '_AP__c'),
                (Decimal) abonoParcialRecord.get('ONE_Importe_Impuesto_' + taxStringList.get(i) + '_AP__c'),
                (Decimal) abonoParcialRecord.get('ONE_Importe_Neto_' + taxStringList.get(i) + '_AP__c')
            );
            if (impuestosRecord.importeBase != '0' || (taxStringList.get(i) == 'Suplido' && impuestosRecord.importeNeto != '0')) {
                impuestosList.add(impuestosRecord);
            }
        }
        return impuestosList;
    }

    private static String buildAddressCentro(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
        String address = ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Codigo_Postal__c != null ? ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Codigo_Postal__c : '';
        address += ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Municipio_Direccion__c != null ? ', ' + ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Municipio_Direccion__c : '';
        address += ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Provincia__c != null ? ', ' + ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Provincia__c : '';
        address += ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Pais__c != null ? ', ' + ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Sociedad2__r?.ONE_Pais__c : '';

        return address;
    }

    private static ONE_Orden_De_Venta__c selectOrdenDeVentaForPdfGeneration(Id ordenDeVentaId) {
        return [
            SELECT Id, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Logo_Pie_de_Pagina__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Direccion__c,
                toLabel(ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Provincia__c),
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Codigo_Postal__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Phone,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Fax,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c,
                ONE_Numero_de_factura__c, ONE_Presupuesto__r.Name, ONE_Fecha_De_Facturacion__c,
                ONE_Servicio__r.ONE_Difunto__r.FirstName,
                ONE_Servicio__r.ONE_Difunto__r.LastName,
                ONE_Servicio__r.ONE_Difunto__r.ONE_N_Documento__pc,
            	ONE_Servicio__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c,
                ONE_Servicio__r.ONE_Direccion_De_Defuncion__c,
                ONE_Servicio__r.ONE_Municipio_De_Defuncion__c,
                ONE_Servicio__r.ONE_Codigo_Postal_De_Defuncion__c,
            	ONE_Servicio__r.ONE_Provincia_De_Defuncion__c,
                ONE_Servicio__r.Name,
                ONE_Importe_Total__c,
                ONE_Servicio__r.ONE_Numero_de_Poliza__c,
                ONE_Servicio__r.ONE_Numero_de_Siniestro__c,
                ONE_Pagador_Particular__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.FirstName,
                ONE_Pagador_Particular__r.ONE_Contacto__r.LastName,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Direccion__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Municipio__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Codigo_Postal__pc,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_N_Documento__pc,
                toLabel(ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Provincia__pc),
                toLabel(ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Pais__pc),
                ONE_Pagador_Compania__c,
                ONE_Pagador_Compania__r.Name,
                ONE_Pagador_Compania__r.ONE_Nombre_Anexo__c,
                ONE_Pagador_Compania__r.ONE_Direccion__c,
                ONE_Pagador_Compania__r.ONE_Municipio_Direccion__c,
                ONE_Pagador_Compania__r.ONE_Codigo_Postal__c,
                toLabel(ONE_Pagador_Compania__r.ONE_Pais__c),
                toLabel(ONE_Pagador_Compania__r.ONE_Provincia__c),
                ONE_Pagador_Compania__r.ONE_CIF__c,
                ONE_Pagador_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c,
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
                ONE_Numero_Abono_Factura__c, ONE_Fecha_Hora_Del_Abono_Factura__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c,
                toLabel(ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c),
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_Postal__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.Phone,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.Fax,
                ONE_Tipo_De_Pagador__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.Name,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Direccion__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Municipio_Direccion__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Codigo_Postal__c,
                toLabel(ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Pais__c),
                toLabel(ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Provincia__c),
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_CIF__c,
                ONE_Pagador_Empresa__c,
                ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Numero_De_Cuenta_Bancaria__c,
                ONE_Forma_De_Pago__c,
                ONE_Pagador_Compania__r.RecordType.DeveloperName,
                ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_Nombre_Fiscal_De_La_Cuenta__c,
                ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_Direccion__c,
                ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_Codigo_Postal__c,
                ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_Municipio_Direccion__c,
                toLabel(ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_Provincia__c),
                toLabel(ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_Pais__c),
                ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_CIF__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Municipio_Direccion__c,
            	ONE_Estado_De_La_Orden_de_Venta__c, ONE_Tipo_De_Factura__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name,
                ONE_Identificador_TBAI_Factura__c,
                ONE_Codigo_QR_TBAI_Factura__c,
            	Recordtype.Developername,
            	ONE_Tipo_De_Presupuesto__c,
                ONE_Factura_Concesiones__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
        ];
    }
}
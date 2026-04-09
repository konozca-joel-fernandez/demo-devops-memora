/**
 * Created by msulek003 on 21.04.2021.
 */

public with sharing class ONE_FacturaComercialDataFactory {
    public static ONE_PresupuestoComercialData buildFacturaComercialData(String ordenDeVentaId, String language, String isAbono) {
        Boolean isFacturaMejora = false;
        ONE_Orden_De_Venta__c ordenDeVentaRecord = selectOrdenDeVentaForPdfGeneration(ordenDeVentaId);

        System.debug('Document query: ' + ordenDeVentaRecord);

        ONE_PresupuestoComercialData.HeaderData headerData = createHeaderData(ordenDeVentaRecord, isAbono);
        ONE_PresupuestoComercialData.DifuntoData difuntoData = createDifuntoData(ordenDeVentaRecord);
        ONE_PresupuestoComercialData.ServicioData servicioData = createServicioData(ordenDeVentaRecord);
        ONE_PresupuestoComercialData.MomentoListData momentoListData = ONE_MomentoService.getFacturaMomentoLists(ordenDeVentaId, language);
        Map<List<ONE_MomentoData>, Boolean> descuentosData = ONE_MomentoService.getFacturaDescuentosLists(ordenDeVentaId, language);
        Map<List<ONE_MomentoData>, Boolean> suplidosData = ONE_MomentoService.getFacturaSuplidosLists(ordenDeVentaId, language);
        List<ONE_PresupuestoComercialData.ImpuestosData> impuestosList = getImpuestosList(ordenDeVentaRecord);
        List<ONE_Expediente_Line_Item__c> lineasExpediente = [SELECT ONE_Mejora_De_Compania__c, ONE_Importe_Descuento_Posicion__c FROM ONE_Expediente_Line_Item__c WHERE ONE_Orden_De_Venta__c = :ordenDeVentaRecord.Id];

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
            sociedadPiePagina=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Pie_de_pagina__c;
            sociedadLogoPie=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Logo_Pie_de_Pagina__c;
            
        }
     
        
        
        String CBNC; //
        

        if (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Compañía') {

            System.debug('Entro Compañía');
            String cliente = ordenDeVentaRecord.ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c; //idsap ordendeventa
            String sociedad = ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_External_ID_Sociedad__c; //idsociedad ordenventa
            String numIBAN = '';
            boolean printable = false;

            List<Cuentas_Cliente_CIA__c> cuentasBanco = [
                SELECT ONE_Numero_De_Cuenta__c 
                FROM Cuentas_Cliente_CIA__c 
                WHERE ONE_Cliente__c = :cliente AND ONE_Sociedad__c = :sociedad 
                LIMIT 1
            ];
            
            if (!cuentasBanco.isEmpty()) {
                numIBAN = cuentasBanco[0].ONE_Numero_De_Cuenta__c;
                printable = true;
            } else {
                System.debug('No se encontró ninguna cuenta bancaria para el cliente y sociedad dados.');
            }

            ONE_PresupuestoComercialData data = new ONE_PresupuestoComercialData(
                sociedadLogo,
                language,
                sociedadLogoPie,
                getTaxLabel(ordenDeVentaRecord), sociedadPiePagina,
                ordenDeVentaRecord.ONE_Importe_Total__c, headerData, difuntoData, servicioData, momentoListData, descuentosData,
                suplidosData, impuestosList, getContratoSignatureImgUrl(ordenDeVentaId, 'Contrato'),
                getContratoSignatureImgUrl(ordenDeVentaId, 'Condiciones Generales de Contratación'), isFacturaMejora,
                (ordenDeVentaRecord.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c == 'Presupuesto servicio completo') ? true : false,
                printable,
                numIBAN, generateSerfunle(ordenDeVentaRecord),
                ordenDeVentaRecord.recordtype.developername,
                '',
                ''
            );    
            
            return data;
        } 
        else{
            ONE_PresupuestoComercialData data = new ONE_PresupuestoComercialData(
                sociedadLogo,
                language,
                sociedadLogoPie,
                getTaxLabel(ordenDeVentaRecord), sociedadPiePagina,
                ordenDeVentaRecord.ONE_Importe_Total__c, headerData, difuntoData, servicioData, momentoListData, descuentosData,
                suplidosData, impuestosList, getContratoSignatureImgUrl(ordenDeVentaId, 'Contrato'),
                getContratoSignatureImgUrl(ordenDeVentaId, 'Condiciones Generales de Contratación'), isFacturaMejora,
                (ordenDeVentaRecord.ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c == 'Presupuesto servicio completo') ? true : false,
                (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Particular' && ordenDeVentaRecord.ONE_Forma_De_Pago__c == 'A')||(ordenDeVentaRecord.ONE_Servicio__r.RecordType.DeveloperName=='ONE_Servicio_M1') ? true : false,
                ordenDeVentaRecord.ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Numero_De_Cuenta_Bancaria__c, generateSerfunle(ordenDeVentaRecord),
                ordenDeVentaRecord.recordtype.developername,
                '',
                ''
            );
            return data;
        }
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

    private static ONE_PresupuestoComercialData.HeaderData createHeaderData(ONE_Orden_De_Venta__c ordenDeVentaRecord, String isAbono) {
        Date fechaDocumento;
        String idTBAI, qrTBAI;
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
            isPresupuestoSegundaVenta = false;
        }else{
            sociedadName=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name;
            sociedadWeb=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_Web__c;
            direccionCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Direccion__c ;
            municipioCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.ONE_Municipio_Direccion__c;
            telefonoCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.Phone;
            faxCentro=ordenDeVentaRecord.ONE_Servicio__r?.ONE_Centro_Del_Expediente__r?.Fax;
            if(ordenDeVentaRecord.ONE_Tipo_De_Presupuesto__c == 'Presupuesto segunda venta') isPresupuestoSegundaVenta = true; 
        }
        if(isAbono == 'false'){
            fechaDocumento = ordenDeVentaRecord.ONE_Fecha_De_Facturacion__c;
            idTBAI = ordenDeVentaRecord.ONE_Identificador_TBAI_Factura__c;
            qrTBAI = ordenDeVentaRecord.ONE_Codigo_QR_TBAI_Factura__c;
            
        }else if(isAbono == 'true'){
            fechaDocumento = Date.newInstance(ordenDeVentaRecord.ONE_Fecha_Hora_Del_Abono_Factura__c.year(), ordenDeVentaRecord.ONE_Fecha_Hora_Del_Abono_Factura__c.month(), ordenDeVentaRecord.ONE_Fecha_Hora_Del_Abono_Factura__c.day());
            idTBAI = ordenDeVentaRecord.ONE_Identificador_TBAI_Abono__c;
            qrTBAI = ordenDeVentaRecord.ONE_Codigo_QR_TBAI_Abono__c;
        }

        return new ONE_PresupuestoComercialData.HeaderData(
            sociedadName,
            direccionCentro+ ', ' + municipioCentro,
            getProvinciaString(ordenDeVentaRecord),
            telefonoCentro,
            faxCentro,
            sociedadWeb,
            ordenDeVentaRecord.ONE_Presupuesto__r?.Name,
            ordenDeVentaRecord.ONE_Numero_Abono_Factura__c,
            ordenDeVentaRecord.ONE_Numero_de_factura__c,
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
        String nombreCuentaPagador = '';
        

        

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
                //ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Nombre_Anexo__c),    
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Direccion__pc),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r ?.ONE_N_Documento__pc),
                ordenDeVentaRecord.ONE_Pagador_Empresa__c,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Municipio__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Provincia__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Pais__pc),
                	ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                    //String.valueOf(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                   //ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c == null ? null : ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c.date()       
            );
        } else if (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Particular' && ordenDeVentaRecord.ONE_Pagador_Empresa__c == true) {

            if(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Nombre_Anexo__c == null){
                nombreCuentaPagador = ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name;
            }else{
                nombreCuentaPagador = ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name + ' - ' + ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Nombre_Anexo__c;
            }

            difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                getDiuntoNombre(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                getDiuntoLugar(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.Name,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Poliza__c,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Siniestro__c,
                nombreCuentaPagador,
                //ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.Name),
                //ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Nombre_Anexo__c),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Direccion__c),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_CIF__c),
                ordenDeVentaRecord.ONE_Pagador_Empresa__c,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Municipio_Direccion__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Provincia__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Codigo_Postal__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Particular__r?.ONE_Contacto__r?.ONE_Pais__c),
                    ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                    //String.valueOf(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                //ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c == null ? null : ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c.date()
            );
        } else if (ordenDeVentaRecord.ONE_Tipo_De_Pagador__c == 'Compañía') {
            Id otrasCuentasId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS).getRecordTypeId();
            System.debug(' esta es la fecha de defuncion ' +  String.valueOf(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c));

            difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                getDiuntoNombre(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                getDiuntoLugar(ordenDeVentaRecord),
                ordenDeVentaRecord.ONE_Servicio__r?.Name,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Poliza__c,
                ordenDeVentaRecord.ONE_Servicio__r?.ONE_Numero_de_Siniestro__c,
                //ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.Name),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r.RecordType.DeveloperName == 'ONE_Centro_Memora' ? ordenDeVentaRecord.ONE_Pagador_Compania__r.ONE_Sociedad2__r.ONE_Nombre_Fiscal_De_La_Cuenta__c : ONE_PdfGeneratorHelper.getNameOrNombreFiscalDeLaCuenta(ordenDeVentaRecord)),
                //ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Nombre_Anexo__c),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Direccion__c),
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_CIF__c),
                ordenDeVentaRecord.ONE_Pagador_Particular__c == null,
                ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Municipio_Direccion__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Provincia__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Codigo_Postal__c) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_Pais__c), /* + ' ' +
                    ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Pagador_Compania__r?.ONE_CIF__c)*/
               //ONE_CommonUtils.changeNullToBlank(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c.date().format())
            		//String.valueOf(ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                    ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                    //ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c == null ? null : ordenDeVentaRecord.ONE_Servicio__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c.date()
                );
            

            
        }
        System.debug('difuntoData-->' + difuntoData);
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
            ordenDeVentaRecord.ONE_Servicio__r?.RecordType.DeveloperName,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Nombre_Mascota__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_N_Microchip__c,
            ordenDeVentaRecord.ONE_Servicio__r?.ONE_Tipo_de_Mascota__c
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

    private static List<ONE_PresupuestoComercialData.ImpuestosData> getImpuestosList(ONE_Orden_De_Venta__c ordenDeVentaRecord) {
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
                (Decimal) ordenDeVentaRecord.get('ONE_Importe_Base_' + taxStringList.get(i) + '__c'),
                (Decimal) ordenDeVentaRecord.get('ONE_Importe_Impuesto_' + taxStringList.get(i) + '__c'),
                (Decimal) ordenDeVentaRecord.get('ONE_Importe_Neto_' + taxStringList.get(i) + '__c')
            );
            if ((impuestosRecord.importeBase != '0' || (ordenDeVentaRecord.ONE_Servicio__r.RecordType.developerName == 'ONE_Servicio_M1' && impuestosRecord.importeNeto != '0')) 
                || (impuestosRecord.importeNeto != '0' && taxStringList.get(i) == 'Suplido')) {
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
            SELECT Id, ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
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
                ONE_Servicio__r.ONE_Direccion_De_Defuncion__c,
                ONE_Servicio__r.ONE_Municipio_De_Defuncion__c,
                ONE_Servicio__r.ONE_Codigo_Postal_De_Defuncion__c,
                ONE_Servicio__r.ONE_Provincia_De_Defuncion__c,
                ONE_Servicio__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c,
                ONE_Servicio__r.Name,
                ONE_Importe_Total__c,
                ONE_Servicio__r.ONE_Numero_de_Poliza__c,
                ONE_Servicio__r.ONE_Numero_de_Siniestro__c,
                ONE_Pagador_Particular__c,
                ONE_Pagador_Particular__r.ONE_Contacto__r.FirstName,
                ONE_Pagador_Particular__r.ONE_Contacto__r.LastName,
                ONE_Pagador_Particular__r.ONE_Contacto__r.ONE_Nombre_Anexo__c,
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
                ONE_Servicio__r.ONE_Nombre_Mascota__c,
                ONE_Servicio__r.ONE_N_Microchip__c,
                ONE_Servicio__r.ONE_Tipo_de_Mascota__c,
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
                ONE_Servicio__r.Recordtype.DeveloperName,
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
                ONE_Identificador_TBAI_Abono__c,
                ONE_Codigo_QR_TBAI_Abono__c, 
            	ONE_Pagador_Compania__r.ONE_ID_Cliente_SAP__c,
            	ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_External_ID_Sociedad__c,
                Recordtype.Developername,
            	ONE_Tipo_De_Presupuesto__c,
                ONE_Factura_Concesiones__c
            FROM ONE_Orden_De_Venta__c
            WHERE Id = :ordenDeVentaId
        ];
    }
}
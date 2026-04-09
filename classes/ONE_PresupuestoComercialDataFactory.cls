/**
* Created by msulek003 on 12.04.2021.
*/

public with sharing class ONE_PresupuestoComercialDataFactory {

    private static final String SERFUNLE_ZONE_EXTERNAL_ID = '10038';

    public static ONE_PresupuestoComercialData buildPresupuestoComercialData(String presupuestoId, String language) {
        Boolean isFacturaMejora = false;
        ONE_Presupuesto__c presupuestoRecord = selectPresupuestoForPdfGeneration(presupuestoId);
        System.debug('Document query: ' + presupuestoRecord);

        ONE_PresupuestoComercialData.HeaderData headerData = createHeaderData(presupuestoRecord);
        ONE_PresupuestoComercialData.DifuntoData difuntoData = createDifuntoData(presupuestoRecord);
        ONE_PresupuestoComercialData.ServicioData servicioData = createServicioData(presupuestoRecord);
        ONE_PresupuestoComercialData.MomentoListData momentoListData = ONE_MomentoService.getMomentoLists(presupuestoId, language);
        Map<List<ONE_MomentoData>, Boolean> descuentosData = ONE_MomentoService.getDescuentosLists(presupuestoId, language);
        Map<List<ONE_MomentoData>, Boolean> suplidosData = ONE_MomentoService.getSuplidosLists(presupuestoId, language);
        List<ONE_PresupuestoComercialData.ImpuestosData> impuestosList = getImpuestosList(presupuestoRecord);
        List<ONE_Expediente_Line_Item__c> lineasExpediente = [SELECT ONE_Mejora_De_Compania__c, ONE_Importe_Descuento_Posicion__c FROM ONE_Expediente_Line_Item__c WHERE ONE_Presupuesto__c = :presupuestoId];

        for (ONE_Expediente_Line_Item__c linea : lineasExpediente) {
            if (linea.ONE_Mejora_De_Compania__c == true) {
                isFacturaMejora = true;
                break;
            }
        }
        string logo = presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_URL_logo__c != null 
            ? presupuestoRecord.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c
            : presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_logo__c;
        
        ONE_PresupuestoComercialData data = new ONE_PresupuestoComercialData(
            logo,
            language,
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Logo_Pie_de_Pagina__c,
            getTaxLabel(presupuestoRecord),
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_Pie_de_pagina__c,
            presupuestoRecord.ONE_Total_Importe_Presupuesto__c,
            headerData,
            difuntoData,
            servicioData,
            momentoListData,
            descuentosData,
            suplidosData,
            impuestosList,
            getContratoSignatureImgUrl(presupuestoId),
            getContratoSignatureImgUrl(presupuestoId),
            isFacturaMejora,
            (presupuestoRecord.ONE_Tipo_De_Presupuesto__c).contains('completo'),
            false,
            '',
            generateSerfunle(presupuestoRecord),
            presupuestoRecord.recordtype.developername,
            presupuestoRecord.ONE_Tipo_De_Contrato__c,
            presupuestoRecord.ONE_Metodo_De_Pago__c
        );
		
        System.debug('DATA: ' + data);
        System.debug('presupuestoRecord.ONE_Tipo_De_Contrato__c: ' + presupuestoRecord.ONE_Tipo_De_Contrato__c);
        System.debug('presupuestoRecord.ONE_Metodo_De_Pago__c: ' + presupuestoRecord.ONE_Metodo_De_Pago__c);
        System.debug('presupuestoRecord.ONE_tipo_Documento__c: '+presupuestoRecord.ONE_tipo_Documento__c);

        return data;
    }

    private static ONE_PresupuestoComercialData.HeaderData createHeaderData(ONE_Presupuesto__c presupuestoRecord) {
                
        Boolean isPresupuestoSegundaVenta = false;
 		if(presupuestoRecord.ONE_Tipo_De_Presupuesto__c == 'Presupuesto segunda venta') isPresupuestoSegundaVenta = true;
        return new ONE_PresupuestoComercialData.HeaderData(
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.Name,
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Direccion__c + ', ' + presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Municipio_Direccion__c,
            getProvinciaString(presupuestoRecord),
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Phone,
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.Fax,
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Sociedad2__r?.ONE_URL_Web__c,
            presupuestoRecord.Name, '', '', false, null, null, null,null,null,null,presupuestoRecord.ONE_tipo_Documento__c,
            '',
            '', isPresupuestoSegundaVenta,
            false
        );
    }

    private static ONE_PresupuestoComercialData.DifuntoData createDifuntoData(ONE_Presupuesto__c presupuestoRecord) {
        ONE_PresupuestoComercialData.DifuntoData difuntoData;
        System.debug('Tipo de documento-->' + presupuestoRecord.ONE_tipo_Documento__c);

        
        

        if (presupuestoRecord.ONE_tipo_Documento__c == 'contrato') {
            if (presupuestoRecord.ONE_Tipo_De_Contrato__c == 'Particular' && presupuestoRecord.ONE_Interlutor_Empresa__c == false) {
                difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                    getDiuntoNombre(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                    getDiuntoLugar(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.Name,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Poliza__c,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.FirstName) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.LastName),
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__pc),
                    presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_N_Documento__pc,
                    presupuestoRecord.ONE_Interlutor_Empresa__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio__pc) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__pc) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__pc),
                        presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                        //String.valueOf(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                );
            } else if (presupuestoRecord.ONE_Tipo_De_Contrato__c == 'Particular' && presupuestoRecord.ONE_Interlutor_Empresa__c == true) {
                difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                    getDiuntoNombre(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                    getDiuntoLugar(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.Name,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Poliza__c,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.Name),
                    ONE_CommonUtils.changeNullToBlank(
                        presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__c != null 
                        	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__c
                        	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__pc 
                    ),
                    presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_CIF__c,
                    presupuestoRecord.ONE_Interlutor_Empresa__c,
                    ONE_CommonUtils.changeNullToBlank(
                        presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio_Direccion__c != null
                        	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio_Direccion__c
                        	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio__pc
                    ) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(
                            presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__c != null
                            	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__c 
                            	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__pc
                        ) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(
                            presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__c != null
                            	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__c
                            	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc
                        ) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(
                            presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__c != null
                            	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__c
                            	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__pc
                        ),
                        presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                       // String.valueOf(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
            	);
            } else if (presupuestoRecord.ONE_Tipo_De_Contrato__c == 'Hoja de servicio') {
                difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                    getDiuntoNombre(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                    getDiuntoLugar(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.Name,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Poliza__c,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c,
                    ONE_CommonUtils.changeNullToBlank(ONE_PdfGeneratorHelper.getNameOrNombreFiscalDeLaCuenta(presupuestoRecord)),
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Direccion__c),
                    presupuestoRecord.ONE_Pagador_Compania__r.ONE_CIF__c,
                    presupuestoRecord.ONE_Interlutor_Empresa__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Municipio_Direccion__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Provincia__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Codigo_Postal__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Pais__c),
                        presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                        //String.valueOf(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                );
            }
        } else if (presupuestoRecord.ONE_tipo_Documento__c == 'presupuesto' || presupuestoRecord.ONE_tipo_Documento__c == 'ConsultaPrecios' ) {
            if ((presupuestoRecord.ONE_Tipo_De_Contrato__c == 'Particular' && presupuestoRecord.ONE_Interlutor_Empresa__c == false) ||
               presupuestoRecord.ONE_Expediente__r.RecordType.DeveloperName == 'ONE_Servicio_Consulta_De_Presupuesto') {
                difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                    getDiuntoNombre(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                    getDiuntoLugar(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.Name,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Poliza__c,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.FirstName) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.LastName),
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__pc),
                    presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_N_Documento__pc,
                    presupuestoRecord.ONE_Interlutor_Empresa__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio__pc) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__pc) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__pc),
                        presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                        //String.valueOf(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                );
            } else if (presupuestoRecord.ONE_Tipo_De_Contrato__c == 'Particular' && presupuestoRecord.ONE_Interlutor_Empresa__c == true) {
                difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                    getDiuntoNombre(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                    getDiuntoLugar(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.Name,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Poliza__c,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.Name),
                    ONE_CommonUtils.changeNullToBlank(
                        presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__c != null 
                        	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__c
                        	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__pc 
                    ),
                    presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_CIF__c,
                    presupuestoRecord.ONE_Interlutor_Empresa__c,
                    ONE_CommonUtils.changeNullToBlank(
                        presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio_Direccion__c != null
                        	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio_Direccion__c
                        	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio__pc
                    ) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(
                            presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__c != null
                            	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__c 
                            	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__pc
                        ) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(
                            presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__c != null
                            	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__c
                            	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc
                        ) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(
                            presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__c != null
                            	? presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__c
                            	: presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__pc
                        ),
                        presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                        //String.valueOf(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                );
            } else if (presupuestoRecord.ONE_Tipo_De_Contrato__c == 'Hoja de servicio') {
                difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                    getDiuntoNombre(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                    getDiuntoLugar(presupuestoRecord),
                    presupuestoRecord.ONE_Expediente__r?.Name,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Poliza__c,
                    presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c,
                    ONE_CommonUtils.changeNullToBlank(ONE_PdfGeneratorHelper.getNameOrNombreFiscalDeLaCuenta(presupuestoRecord)),
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Direccion__c),
                    presupuestoRecord.ONE_Pagador_Compania__r.ONE_CIF__c,
                    presupuestoRecord.ONE_Interlutor_Empresa__c,
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Municipio_Direccion__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Provincia__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Codigo_Postal__c) + ' ' +
                        ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Pagador_Compania__r?.ONE_Pais__c),
                        presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                        //String.valueOf(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
                );
            }

        } else if (presupuestoRecord.ONE_tipo_Documento__c == 'hoja_servicio') {
            difuntoData = new ONE_PresupuestoComercialData.DifuntoData(
                getDiuntoNombre(presupuestoRecord),
                presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc,
                getDiuntoLugar(presupuestoRecord),
                presupuestoRecord.ONE_Expediente__r?.Name,
                presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Poliza__c,
                presupuestoRecord.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c,
                ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.FirstName) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.LastName),
                ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Direccion__pc),
                presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_N_Documento__pc,
                presupuestoRecord.ONE_Interlutor_Empresa__c,
                ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Municipio__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Provincia__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Codigo_Postal__pc) + ' ' +
                    ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Interlocutor__r?.ONE_Contacto__r?.ONE_Pais__pc),
                    presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c?.format('dd/MM/yyyy')
                    //String.valueOf(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c)
            );
        }

        return difuntoData;
    }

    private static ONE_PresupuestoComercialData.ServicioData createServicioData(ONE_Presupuesto__c presupuestoRecord) {
        return new ONE_PresupuestoComercialData.ServicioData(
            presupuestoRecord.ONE_Expediente__r?.ONE_Inicio_Velacion__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.Name,
            presupuestoRecord.ONE_Expediente__r?.ONE_Direccion_Velacion__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Municipio_Velacion__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name,
            presupuestoRecord.ONE_Expediente__r?.ONE_Direccion_Ceremonia__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Inicio_Incineracion__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Lugar_Incineracion__r?.Name,
            presupuestoRecord.ONE_Expediente__r?.ONE_Direccion_Incineracion__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Municipio_Incineracion__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Hora_Destino_Final__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Destino_Final__r?.Name,
            presupuestoRecord.ONE_Expediente__r?.ONE_Direccion_Destino_Final__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Municipio_Destino_Final__c,
            presupuestoRecord.ONE_Expediente__r?.Recordtype?.Developername,
            presupuestoRecord.ONE_Expediente__r?.ONE_Nombre_Mascota__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_N_Microchip__c,
            presupuestoRecord.ONE_Expediente__r?.ONE_Tipo_de_Mascota__c
        );
    }
    
    private static String getProvinciaString(ONE_Presupuesto__c presupuestoRecord) {
        return ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Provincia__c) + ' ' +
            ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Codigo_Postal__c);
    }

    private static String getDiuntoNombre(ONE_Presupuesto__c presupuestoRecord) {
        return ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.FirstName) + ' ' +
            ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Expediente__r?.ONE_Difunto__r?.LastName);
    }

    private static String getDiuntoLugar(ONE_Presupuesto__c presupuestoRecord) {
        return ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Expediente__r?.ONE_Direccion_De_Defuncion__c) + ' ' +
            ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Expediente__r?.ONE_Municipio_De_Defuncion__c) + ' ' +
            ONE_CommonUtils.changeNullToBlank(presupuestoRecord.ONE_Expediente__r?.ONE_Codigo_Postal_De_Defuncion__c);
    }

    private static String getTaxLabel(ONE_Presupuesto__c presupuestoRecord) {
        if (presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c != null &&
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c == 'IVA') {
            return Label.ONE_Doc_IVA;

        } else if (presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c != null &&
            presupuestoRecord.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Tipo_De_Impuesto__c == 'IGIC') {
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

    private static List<ONE_PresupuestoComercialData.ImpuestosData> getImpuestosList(ONE_Presupuesto__c presupuestoRecord) {
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
                (Decimal) presupuestoRecord.get('ONE_Importe_Base_' + taxStringList.get(i) + '__c'),
                (Decimal) presupuestoRecord.get('ONE_Importe_Impuesto_' + taxStringList.get(i) + '__c'),
                (Decimal) presupuestoRecord.get('ONE_Importe_Neto_' + taxStringList.get(i) + '__c')
            );
            if (impuestosRecord.importeBase != '0' || (taxStringList.get(i) == 'Suplido' && impuestosRecord.importeNeto != '0')) {
                impuestosList.add(impuestosRecord);
            }
        }
        return impuestosList;
    }

    private static String generateSerfunle(ONE_Presupuesto__c presupuestoRecord) {
        String result;
        try {
            result = presupuestoRecord.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;
        } catch(Exception e) {
            result = null;
        }
        return result;
    }

    private static ONE_Presupuesto__c selectPresupuestoForPdfGeneration(Id presupuestoId) {
        return [
            SELECT Id,ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c, ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Logo_Pie_de_Pagina__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Name,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Pie_de_pagina__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Direccion__c,
                toLabel(ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Provincia__c),
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_Codigo_Postal__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Phone,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.Fax,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c,
                ONE_Creation_Date__c, ONE_Expediente__c,
                ONE_Expediente__r.ONE_Difunto__r.FirstName,
                ONE_Expediente__r.ONE_Difunto__r.LastName,
                ONE_Expediente__r.ONE_Difunto__r.ONE_N_Documento__pc,
                ONE_Expediente__r.ONE_Direccion_De_Defuncion__c,
                ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,
                ONE_Expediente__r.ONE_Codigo_Postal_De_Defuncion__c,
            	ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c,
                ONE_Expediente__r.Name,
                ONE_Total_Importe_Presupuesto__c,
                ONE_Expediente__r.ONE_Numero_de_Poliza__c,
                ONE_Expediente__r.ONE_Numero_de_Siniestro__c,
                ONE_Expediente__r.ONE_Inicio_Velacion__c,
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name,
                ONE_Expediente__r.ONE_Direccion_Velacion__c,
                ONE_Expediente__r.ONE_Municipio_Velacion__c,
                ONE_Expediente__r.ONE_Inicio_Ceremonia__c,
                ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name,
                ONE_Expediente__r.ONE_Direccion_Ceremonia__c,
                ONE_Expediente__r.ONE_Municipio_Ceremonia__c,
                ONE_Expediente__r.ONE_Inicio_Incineracion__c,
                ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name,
                ONE_Expediente__r.ONE_Direccion_Incineracion__c,
                ONE_Expediente__r.ONE_Municipio_Incineracion__c,
                ONE_Expediente__r.ONE_Hora_Destino_Final__c,
                ONE_Expediente__r.ONE_Destino_Final__r.Name,
                ONE_Expediente__r.ONE_Direccion_Destino_Final__c,
                ONE_Expediente__r.ONE_Municipio_Destino_Final__c,
            	ONE_Expediente__r.ONE_Nombre_Mascota__c,
            	ONE_Expediente__r.ONE_Tipo_de_Mascota__c,
            	ONE_Expediente__r.ONE_N_Microchip__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Tipo_De_Impuesto__c,
                ONE_Importe_Base_0__c, ONE_Importe_Impuesto_0__c, ONE_Importe_Neto_0__c,
                ONE_Importe_Base_3__c, ONE_Importe_Impuesto_3__c, ONE_Importe_Neto_3__c,
                ONE_Importe_Base_4__c, ONE_Importe_Impuesto_4__c, ONE_Importe_Neto_4__c,
                ONE_Importe_Base_10__c, ONE_Importe_Impuesto_10__c, ONE_Importe_Neto_10__c,
                ONE_Importe_Base_21__c, ONE_Importe_Impuesto_21__c, ONE_Importe_Neto_21__c,
                ONE_Importe_Base_Suplido__c, ONE_Importe_Impuesto_Suplido__c, ONE_Importe_Neto_Suplido__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Municipio_Direccion__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Phone,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Fax,
                toLabel(ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c),
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Codigo_Postal__c,
                ONE_Interlocutor__r.ONE_Contacto__r.FirstName,
                ONE_Interlocutor__r.ONE_Contacto__r.LastName,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_Direccion__pc,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_Municipio__pc,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_Codigo_Postal__pc,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_N_Documento__pc,
                ONE_Pagador_Compania__r.Name,
                ONE_Pagador_Compania__r.ONE_Direccion__c,
                ONE_Pagador_Compania__r.ONE_Municipio_Direccion__c,
                ONE_Pagador_Compania__r.ONE_Codigo_Postal__c,
                toLabel(ONE_Pagador_Compania__r.ONE_Provincia__c),
                toLabel(ONE_Pagador_Compania__r.ONE_Pais__c),
                ONE_Pagador_Compania__r.ONE_CIF__c,
                ONE_Pagador_Compania__r.ONE_Nombre_Fiscal_De_La_Cuenta__c,
                ONE_Pagador_Compania__r.RecordType.DeveloperName,
                ONE_tipo_Documento__c,
                ONE_Tipo_De_Contrato__c,
            	ONE_Tipo_De_Presupuesto__c,
            	toLabel(ONE_Metodo_De_Pago__c),
                Name,
                ONE_Interlocutor__r.ONE_Contacto__r.Name,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_Direccion__c,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_Municipio_Direccion__c,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_Codigo_Postal__c,
                ONE_Interlocutor__r.ONE_Contacto__r.ONE_CIF__c,
                ONE_Interlutor_Empresa__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_External_ID__c,
            	ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name,
                toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Provincia__pc),
                toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Provincia__c),
                toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Pais__pc),
                toLabel(ONE_Interlocutor__r.ONE_Contacto__r.ONE_Pais__c),
            	ONE_Expediente__r.Recordtype.Developername,
            	Recordtype.Developername
            
            FROM ONE_Presupuesto__c
            WHERE Id = :presupuestoId
        ];
    }
}
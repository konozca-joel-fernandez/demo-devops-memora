/**
* File Name: ONE_UdianasCreateQueueable.cls
* Description: 	Queueable class to create Udianas records for Servicios
* Date: 02/10/2025
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Test: ONE_UdianasCreateQueueableTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		02/10/2025		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
global with sharing class ONE_UdianasCreateQueueable
    implements Queueable, Database.AllowsCallouts {

    private List<Id> servicioIds;
    private Integer offset;
    private static final Integer CHUNK_SIZE = 1;


    public ONE_UdianasCreateQueueable(List<Id> ids) {
        this(ids, 0);
    }
    private ONE_UdianasCreateQueueable(List<Id> ids, Integer offset) {
        this.servicioIds = (ids == null) ? new List<Id>() : ids;
        this.offset = (offset == null) ? 0 : offset;
    }


    public void execute(QueueableContext qc) {
        Integer endIdx = Math.min(offset + CHUNK_SIZE, servicioIds.size());
        for (Integer i = offset; i < endIdx; i++) {
            Id servicioId = servicioIds[i];
            try {
                // Consulta Servicio
                ONE_Expediente__c servicio = [
                    SELECT Id, Name, Udiana_Status__c,
                        ONE_Fecha_De_Defuncion__c, ONE_In_Arboriam__c, ONE_Servicio__c,
                        ONE_Declarante__c,
                        ONE_Declarante__r.Name,
                        ONE_Declarante__r.ONE_Email__c,
                        ONE_Declarante__r.ONE_Idioma__pc,
                        ONE_Declarante__r.ONE_Remision_de_info_y_accion_comercial__pc,
                        ONE_Difunto__c,
                        ONE_Difunto__r.FirstName,
                        ONE_Difunto__r.LastName,
                        ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                        ONE_Difunto__r.Name,
                        ONE_Difunto__r.ONE_Sexo__c,
                        ONE_Compania__c,
                        ONE_Compania__r.Id,
                        ONE_Compania__r.Name,
                        ONE_Compania__r.ONE_InsuranceHashId__c,
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Name,
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id,
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name,
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_EnterpriseHashId__c,
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.Name,
                        CreatedDate
                    FROM ONE_Expediente__c
                    WHERE Id = :servicioId
                    LIMIT 1
                ];

                
                // Resolver API Key según Área
                String apiKey =
                    resolveApiKey(
                        servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.Name
                    );

                
                // ENTERPRISE (Zona)
                String enterpriseHashId =
                    servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_EnterpriseHashId__c;

                if (enterpriseHashId == null) {
                    String enterpriseName =
                        servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Name;

                    enterpriseHashId =
                        ONE_UdianasEnterpriseService.createEnterprise(enterpriseName);
                }

                
                // INSURANCE
                String insuranceHashId;
                Boolean sendUdiana = true;
                Account insuranceAccount = null;
                Account insuranceAccountToUpdate = null;

                if (servicio.ONE_Servicio__c == 'Particular') {
                    insuranceHashId =
                        ONE_UdianasInsuranceService.lookupParticularHash();
                }
                else if (servicio.ONE_Servicio__c == 'Asegurado/Acuerdo') {

                    List<ONE_Orden_De_Venta__c> odvs = [
                        SELECT Id,
                            ONE_Pagador_Compania__c,
                            ONE_Pagador_Compania__r.Id,
                            ONE_Pagador_Compania__r.Name,
                            ONE_Pagador_Compania__r.ONE_Nivel_Jerarquia_Cuentas__c,
                            ONE_Pagador_Compania__r.ONE_InsuranceHashId__c,
                            ONE_Pagador_Compania__r.Parent.Id,
                            ONE_Pagador_Compania__r.Parent.Name,
                            ONE_Pagador_Compania__r.Parent.ONE_Nivel_Jerarquia_Cuentas__c,
                            ONE_Pagador_Compania__r.Parent.ONE_InsuranceHashId__c,
                            ONE_Pagador_Compania__r.Parent.Parent.Id,
                            ONE_Pagador_Compania__r.Parent.Parent.Name,
                            ONE_Pagador_Compania__r.Parent.Parent.ONE_Nivel_Jerarquia_Cuentas__c,
                            ONE_Pagador_Compania__r.Parent.Parent.ONE_InsuranceHashId__c
                        FROM ONE_Orden_De_Venta__c
                        WHERE ONE_Presupuesto__r.ONE_Expediente__c = :servicioId
                        AND ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c = 'Presupuesto servicio completo'
                        AND ONE_Presupuesto__r.ONE_Estado_Facturacion_Presupuesto__c = 'Facturado (Orden de Venta creada)'
                        AND ONE_Estado_De_La_Orden_de_Venta__c != 'Abonado'
                        AND ONE_Orden_de_Venta_Cancelada__c = false
                        AND ONE_Pagador_Compania__c != null
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ];

                    DateTime expiresAt = servicio.CreatedDate.addDays(14);

                    DateTime todayLastRun = DateTime.newInstance(
                        Date.today(),
                        Time.newInstance(23, 0, 0, 0)
                    );

                    Boolean isLastAttempt = (todayLastRun >= expiresAt);


                    if (!odvs.isEmpty()) {

                        ONE_Orden_De_Venta__c odv = odvs[0];

                        // Buscamos la cuenta aseguradora adecuada
                        Account pagador = odv.ONE_Pagador_Compania__r;

                        if (pagador != null
                            && pagador.Parent != null
                            && pagador.Parent.Parent != null
                            && pagador.Parent.Parent.ONE_Nivel_Jerarquia_Cuentas__c == 'Agrupación Salesforce') {

                            insuranceAccount = pagador.Parent.Parent;

                        } else if (pagador != null
                                && pagador.Parent != null
                                && pagador.Parent.ONE_Nivel_Jerarquia_Cuentas__c == 'Agrupación Salesforce') {

                            insuranceAccount = pagador.Parent;

                        } else if (pagador != null
                                && pagador.ONE_Nivel_Jerarquia_Cuentas__c == 'Agrupación Salesforce') {

                            insuranceAccount = pagador;

                        } else {
                            insuranceAccount = pagador;
                        }
                    } else {
                        if (isLastAttempt && servicio.ONE_In_Arboriam__c == 'Si') {
                            insuranceAccount = servicio.ONE_Compania__r; 
                        } else {
                            sendUdiana = false; // NO enviar
                        }
                    }

                    insuranceHashId = (insuranceAccount == null) ? null : insuranceAccount.ONE_InsuranceHashId__c;

                    if (insuranceHashId == null && insuranceAccount != null) {
                        insuranceHashId = ONE_UdianasInsuranceService.createInsurance(insuranceAccount.Name);
                    }

                    insuranceAccountToUpdate = insuranceAccount;
                }
                else {
                    insuranceHashId = null;
                }

                // Si no se debe enviar Udiana, actualizar estado y salir
                if (sendUdiana == false) {
                    applyNoSendPreUpdates(servicioId, servicio, enterpriseHashId);
                    continue;
                }

                // Construir request Udianas
                String requestJson =
                    ONE_UdianasRequestBuilder.buildRequestJson(
                        servicio,
                        enterpriseHashId,
                        insuranceHashId,
                        apiKey
                    );

                
                // Callout Udianas
                HttpResponse res =
                    ONE_UdianasIntegrationService.createUdiana(
                        requestJson,
                        apiKey
                    );

                Integer sc = (res != null) ? res.getStatusCode() : 0;

                String udianaHashId;
                if (sc == 200 || sc == 201) {
                    try {
                        Map<String,Object> body =
                            (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

                        Object idVal =
                            body != null && body.containsKey('udianaHashId')
                                ? body.get('udianaHashId')
                                : body != null ? body.get('id') : null;

                        udianaHashId =
                            (idVal == null) ? null : String.valueOf(idVal);
                    }
                    catch (Exception ignore) {
                        udianaHashId = null;
                    }
                }

                
                try {
                    update new ONE_Expediente__c(
                        Id                = servicioId,
                        Udiana_Status__c  = (sc == 200 || sc == 201) ? 'Sent' : 'Error',
                        Udiana_Hash_Id__c = udianaHashId,
                        ONE_Udiana_Sent_At__c = (sc == 200 || sc == 201) ? System.now() : null
                    );
                }
                catch (Exception ignore) {
                    throw ignore;
                }

                List<Account> accUpdates = new List<Account>();
                List<ONE_Lugar__c> lugarUpdates = new List<ONE_Lugar__c>();

                // Insurance hash en Account
                if (insuranceAccountToUpdate != null &&
                    insuranceAccountToUpdate.Id != null &&
                    insuranceHashId != null &&
                    insuranceAccountToUpdate.ONE_InsuranceHashId__c == null) {

                    accUpdates.add(new Account(
                        Id = insuranceAccountToUpdate.Id,
                        ONE_InsuranceHashId__c = insuranceHashId
                    ));
                }

                // Enterprise hash en Zona
                if (enterpriseHashId != null &&
                    servicio.ONE_Centro_Del_Expediente__r != null &&
                    servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r != null &&
                    servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r != null &&
                    servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id != null &&
                    servicio.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_EnterpriseHashId__c == null) {

                    lugarUpdates.add(new ONE_Lugar__c(
                        Id = servicio.ONE_Centro_Del_Expediente__r
                                    .ONE_Lugar__r
                                    .ONE_Lugar_Superior__r
                                    .Id,
                        ONE_EnterpriseHashId__c = enterpriseHashId
                    ));
                }

                // Account
                try {
                    if (!accUpdates.isEmpty()) update accUpdates;
                } catch (Exception eAcc) {
                    System.debug(LoggingLevel.ERROR, 'FAIL Account: ' + eAcc.getMessage());
                }

                // Lugar
                try {
                    if (!lugarUpdates.isEmpty()) update lugarUpdates;
                } catch (Exception eLugar) {
                    System.debug(LoggingLevel.ERROR, 'FAIL Lugar: ' + eLugar.getMessage());
                }


            }
            catch (Exception e) {
                try {
                    update new ONE_Expediente__c(
                        Id = servicioId,
                        Udiana_Status__c = 'Error'
                    );
                } catch (Exception ignore) {}
            }
        }
        if (endIdx < servicioIds.size()) {
            System.enqueueJob(new ONE_UdianasCreateQueueable(servicioIds, endIdx));
        }
    }

    // API Key resolution
    @TestVisible
    private String resolveApiKey(String areaOperativaName) {
        if (areaOperativaName == null) {
            return getDefaultApiKey();
        }
        else if (areaOperativaName == 'SERFUNLE') {
            return getSerfunleApiKey();
        }
        return getDefaultApiKey();
    }

    @TestVisible
    private String getDefaultApiKey() {
        return [
            SELECT ONE_ApiKey__c
            FROM ONE_UdianasApiKey__mdt
            WHERE ONE_Area_Operativa__c = 'Default'
            LIMIT 1
        ].ONE_ApiKey__c;
    }

    @TestVisible
    private String getSerfunleApiKey() {
        return [
            SELECT ONE_ApiKey__c
            FROM ONE_UdianasApiKey__mdt
            WHERE ONE_Area_Operativa__c = 'SERFUNLE'
            LIMIT 1
        ].ONE_ApiKey__c;
    }

    @TestVisible
    private static void applyNoSendPreUpdates(
        Id servicioId,
        ONE_Expediente__c servicio,
        String enterpriseHashId
    ) {
        List<SObject> preUpdates = new List<SObject>();

        if (enterpriseHashId != null &&
            servicio.ONE_Centro_Del_Expediente__r
                    .ONE_Lugar__r
                    .ONE_Lugar_Superior__r
                    .ONE_EnterpriseHashId__c == null) {

            preUpdates.add(new ONE_Lugar__c(
                Id = servicio.ONE_Centro_Del_Expediente__r
                            .ONE_Lugar__r
                            .ONE_Lugar_Superior__r
                            .Id,
                ONE_EnterpriseHashId__c = enterpriseHashId
            ));
        }

        preUpdates.add(new ONE_Expediente__c(
            Id = servicioId,
            Udiana_Status__c = 'Pending'
        ));

        if (!preUpdates.isEmpty()) update preUpdates;
    }

    private static DateTime nextDailyRun(DateTime now, Integer hour24, Integer minute) {
        Date today = Date.today();
        Time runTime = Time.newInstance(hour24, minute, 0, 0);
        DateTime todayRun = DateTime.newInstance(today, runTime);
        return (now >= todayRun)
            ? DateTime.newInstance(today.addDays(1), runTime)
            : todayRun;
    }

}
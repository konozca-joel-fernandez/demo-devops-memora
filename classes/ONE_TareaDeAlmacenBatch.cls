//This class call the stock reservation for the tarea's ed almacen
global class ONE_TareaDeAlmacenBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String tareaDeAlmacenRecordTypeId =
            ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_ALMACEN);
		//Query tareas to call SAP Stock reservation integration
        String query = 'SELECT Id, ONE_Expediente__r.Name, ONE_Producto__r.ONE_SKU__c, ONE_Cantidad__c, ' +
                'ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c, ' +
                'ONE_Modelo__r.ONE_SKU__c, ONE_Modelo__c, ONE_Producto__c, ' +
                'ONE_Almacen__c, ONE_Centro_De_Reserva__c, ONE_Ejercicio_Cancelacion_Consumo__c, ' +
                'ONE_Ejercicio_Cancelacion_De_Reserva__c, ONE_Ejercicio_Consumo_De_Material__c, ' +
                'ONE_Ejercicio_Reserva_De_Material__c, ONE_Numero_Cancelacion_Consumo__c, ' +
                'ONE_Numero_De_Cancelacion_De_Reserva__c, ONE_Numero_De_Consumo_De_Material__c,' +
                'ONE_Numero_De_Reserva_De_Material__c, ONE_Proveedor_Consigna__c ' +
            'FROM ONE_Tarea__c ' +
            'WHERE ONE_Configuracion_De_Tarea__c  != null ' +
                'AND ONE_Expediente__c  != null ' +
                'AND (' +
                '(ONE_Producto__c != null AND ONE_Producto__r.ONE_Tipo_De_Producto__c = \'Producto comercial\' AND ONE_Modelo__c = null) ' +
                'OR ONE_Modelo__c != null) ' +
                'AND (ONE_Numero_De_Cancelacion_De_Reserva__c != null OR ONE_Numero_De_Reserva_De_Material__c = null) ' +
                'AND RecordTypeId = :tareaDeAlmacenRecordTypeId ' +
                'AND ONE_Processed_By_Batch__c = false';

        return Database.getQueryLocator(query);

    }
	//Batch execute method
    global void execute(Database.BatchableContext BC, List<ONE_Tarea__c> scope) {

        Set<Id> taskIds = (new Map<Id,ONE_Tarea__c>(scope)).keySet();
        String tareaDeAlmacenRecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.TAREA, ONE_CommonConstants.TAREA_RT_TAREA_DE_ALMACEN);
        List<ONE_Tarea__c> tareasToUpdate = new List<ONE_Tarea__c>();
        List<Task> tasksToInsert = new List<Task>();
        List<ONE_StockReservationIntegrationService.FlowInputs> inputList = new List<ONE_StockReservationIntegrationService.FlowInputs>();
        List<ONE_StockReservationIntegrationService.Flowoutputs> results = new List<ONE_StockReservationIntegrationService.FlowOutputs>();

        List<ONE_Tarea__c> tasks = [SELECT
                                        Id, 
                                        ONE_Expediente__r.Name, 
                                        ONE_Producto__r.ONE_SKU__c, 
                                        ONE_Cantidad__c,
                                        ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c,
                                        ONE_Modelo__r.ONE_SKU__c, 
                                        ONE_Modelo__c, 
                                        ONE_Producto__c,
                                        ONE_Almacen__c, 
                                        ONE_Centro_De_Reserva__c, 
                                        ONE_Ejercicio_Cancelacion_Consumo__c,
                                        ONE_Ejercicio_Cancelacion_De_Reserva__c, 
                                        ONE_Ejercicio_Consumo_De_Material__c,
                                        ONE_Ejercicio_Reserva_De_Material__c, 
                                        ONE_Numero_Cancelacion_Consumo__c,
                                        ONE_Numero_De_Cancelacion_De_Reserva__c, 
                                        ONE_Numero_De_Consumo_De_Material__c,
                                        ONE_Numero_De_Reserva_De_Material__c, 
                                        ONE_Proveedor_Consigna__c
                                    FROM
                                        ONE_Tarea__c
                                    WHERE
                                        Id IN :taskIds
                                        AND ONE_Configuracion_De_Tarea__c  != null
                                        AND ONE_Expediente__c  != null
                                        AND (
                                                (
                                                    ONE_Producto__c != null
                                                    AND ONE_Producto__r.ONE_Tipo_De_Producto__c = 'Producto comercial'
                                                    AND ONE_Modelo__c = null
                                                )
                                            OR
                                                ONE_Modelo__c != null
                                        )
                                        AND (
                                            ONE_Numero_De_Cancelacion_De_Reserva__c != null
                                            OR ONE_Numero_De_Reserva_De_Material__c = null
                                        )
                                        AND RecordTypeId = :tareaDeAlmacenRecordTypeId
                                        AND ONE_Processed_By_Batch__c = false
                                    FOR UPDATE
                                    ];

		//Call stock reservation for each task 
        for (ONE_Tarea__c t : tasks) {
            ONE_StockReservationIntegrationService.FlowInputs tareaParameters = new ONE_StockReservationIntegrationService.FlowInputs();
            tareaParameters.IMatnr = '';
            tareaParameters.IMeins = 'UN';
            tareaParameters.IMenge = t.ONE_Cantidad__c;
            tareaParameters.IWerks = t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Centro_Memora_Codigo_SAP__c;
            tareaParameters.IZzaufnr = t.ONE_Expediente__r.Name;
			//Apply modelo in case we need to use it
            if (t.ONE_Modelo__c != null) {
                tareaParameters.IMatnr = t.ONE_Modelo__r.ONE_SKU__c;
            } else if (t.ONE_Producto__c != null) {
                tareaParameters.IMatnr = t.ONE_Producto__r.ONE_SKU__c;
            }

            inputList.add(tareaParameters); // create list

            results = ONE_StockReservationIntegrationService.invokeIntegration((inputList)); // Invoke stock reservation integration
			//Parse stock reservation response
            for (ONE_StockReservationIntegrationService.Flowoutputs result : results) {
                if (result.EResult == 'S') {//In case the call is OK update tarea's register
                    t.ONE_Almacen__c = result.ELgort;
                    t.ONE_Centro_De_Reserva__c = result.EWerks;
                    t.ONE_Ejercicio_Cancelacion_Consumo__c = '';
                    t.ONE_Ejercicio_Cancelacion_De_Reserva__c = '';
                    t.ONE_Ejercicio_Consumo_De_Material__c = '';
                    t.ONE_Ejercicio_Reserva_De_Material__c = result.EMjahr;
                    t.ONE_Numero_Cancelacion_Consumo__c = '';
                    t.ONE_Numero_De_Cancelacion_De_Reserva__c = '';
                    t.ONE_Numero_De_Consumo_De_Material__c = '';
                    t.ONE_Numero_De_Reserva_De_Material__c = result.EMblnr;
                    t.ONE_Proveedor_Consigna__c = result.ELifnr;
                    t.ONE_Processed_By_Batch__c = true;
                    tareasToUpdate.add(t);
                } else {//In case of KO communication return error
                    Task errorTask = new Task(
                        Description = Label.ONE_StockReservationErrorMes + ' ' + result.errorMessage,
                        Status = 'Open',
                        Priority = 'High',
                        Subject = Label.ONE_StockReservationError,
                        Type = 'Other',
                        WhatId = t.Id,
                        ActivityDate = Date.today()
                    );
                    t.ONE_Processed_By_Batch__c = true;
                    t.ONE_Fallo_en_reserva_de_stock__c = true;
                    tareasToUpdate.add(t);
                    tasksToInsert.add(errorTask);
                }
            }
        }
		//Update or insert all tareas edited
        if (!tareasToUpdate.isEmpty()) {
            update tareasToUpdate;
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
	//Batch finish method
    global void finish(Database.BatchableContext BC) {
        String tareaDeAlmacenRecordTypeId =
                Schema.getGlobalDescribe().get('ONE_Tarea__c').getDescribe().getRecordTypeInfosByDeveloperName().get(ONE_CommonConstants.TAREA_RT_TAREA_DE_ALMACEN).getRecordTypeId();
        System.debug(tareaDeAlmacenRecordTypeId);
    }
}
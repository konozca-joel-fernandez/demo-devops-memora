@IsTest
private class ONE_PricesRecalculationBatchTest {

    @testSetup
    private static void testSetup() {

        Account account = new Account(
            Name = 'Company',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
            ONE_Nivel_Jerarquia_Cuentas__c='Jerarquía 2'
        );
        insert account;

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar'
        );
        insert lugar;

        ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1)
        );
        insert catalogo;

        ONE_Segmentacion_Acuerdo__c acuerdo = new ONE_Segmentacion_Acuerdo__c(
            ONE_Vigencia_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = account.Id,
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Lugar__c = lugar.Id,
            ONE_Necesita_Recalculo__c = true,
            ONE_Tipo_De_Recalculo__c = 'Recálculo de importe',
            ONE_Importe_Conjunto__c = 0,
            ONE_Ajuste_Necesario__c = 0
        );
        insert acuerdo;

        ONE_Momento__c momento = new ONE_Momento__c(
            Name = ONE_MomentoServiceConstants.VELACION_SERVICO_MOMENT
        );
        insert momento;

        ONE_Agrupacion__c agrupacion = new ONE_Agrupacion__c(
            Name = ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = momento.Id
        );
        insert agrupacion;

        ONE_Categoria__c categoria = new ONE_Categoria__c(
            ONE_Agrupacion__c= agrupacion.Id,
            Name = (ONE_MomentoServiceConstants.VELACION_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.VELACION_SERVICO_AGRUPACION_LIST.get(0))).get(0)
        );
        insert categoria;

        ONE_Producto__c producto1 = new ONE_Producto__c(
            Name = 'Producto',
            ONE_Categoria__c = categoria.Id
        );
        insert producto1;

        ONE_Producto__c producto2 = new ONE_Producto__c(
            Name = 'Producto',
            ONE_Categoria__c = categoria.Id
        );
        insert producto2;

        ONE_Entrada_De_Precio__c entradaPrecio1 = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Concepto_Comercial__c = producto1.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio1;

        ONE_Entrada_De_Precio__c entradaPrecio2 = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Concepto_Comercial__c = producto2.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio2;

        ONE_Segmentacion_De_Linea__c segmentacionLinea1 = new ONE_Segmentacion_De_Linea__c(
            ONE_Segmentacion_Acuerdo__c = acuerdo.Id,
            ONE_Producto__c = producto1.Id,
            ONE_Unidades__c = 1,
            ONE_Comportamiento__c = '01'
        );
        insert segmentacionLinea1;

        ONE_Segmentacion_De_Linea__c segmentacionLinea2 = new ONE_Segmentacion_De_Linea__c(
            ONE_Segmentacion_Acuerdo__c = acuerdo.Id,
            ONE_Producto__c = producto2.Id,
            ONE_Unidades__c = 1,
            ONE_Comportamiento__c = '01'
        );
        insert segmentacionLinea2;
    }

    @IsTest
    static void recalculoAjuste() {

        Test.startTest();
        Id batchId = Database.executeBatch(new ONE_PricesRecalculationBatch(), 1);
        Test.stopTest();
    }

    @IsTest
    static void recalculoImporte() {

        ONE_Segmentacion_Acuerdo__c acuerdo = [SELECT ONE_Tipo_De_Recalculo__c FROM ONE_Segmentacion_Acuerdo__c LIMIT 1];
        acuerdo.ONE_Tipo_De_Recalculo__c = 'Recálculo de importe';
        update acuerdo;
        Test.startTest();
        Id batchId = Database.executeBatch(new ONE_PricesRecalculationBatch(), 1);
        Test.stopTest();
    }
}
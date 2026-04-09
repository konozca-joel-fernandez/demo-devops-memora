/**
 * Created by Marc Pàmies on 23/10/2024.
 */

@isTest
public class ONE_Subida_Tarifas_LocalesTest {
    @isTest
    static void testSubidaLocales() {
        ONE_Subida_Tarifas_Locales.FlowInput input = new ONE_Subida_Tarifas_Locales.FlowInput();
        input.catalogos = new List<String>{[SELECT Id FROM ONE_Catalogo_De_Precios__c LIMIT 1].Id};
        input.subidas = new List<Double>{10.0, 15.0, 20.0, 25.0}; // A: 10%, B: 15%, C: 20%, N: 25%
        input.fechaInicio = Date.today().addDays(1);

        List<ONE_Subida_Tarifas_Locales.FlowInput> inputs = new List<ONE_Subida_Tarifas_Locales.FlowInput>{input};

        Test.startTest();
        List<ONE_Subida_Tarifas_Locales.FlowOutput> outputs = ONE_Subida_Tarifas_Locales.subidaLocales(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size());
        System.assertEquals(true, outputs[0].success, 'El método debería haber terminado correctamente.');

        List<ONE_Entrada_De_Precio__c> oldEntries = [SELECT ONE_Vigente_Hasta__c FROM ONE_Entrada_De_Precio__c WHERE ONE_Vigente_Hasta__c = :input.fechaInicio.addDays(-1)];
        System.assertEquals(4, oldEntries.size(), 'Deberían haberse actualizado 4 entradas antiguas.');

        List<ONE_Entrada_De_Precio__c> newEntries = [SELECT ONE_Precio__c, ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c FROM ONE_Entrada_De_Precio__c WHERE ONE_Vigente_Desde__c = :input.fechaInicio];
        System.assertEquals(4, newEntries.size(), 'Deberían haberse creado 4 entradas nuevas.');
        
        List<ONE_Entrada_De_Precio__c> updatedPrices = [SELECT Id, ONE_Precio__c, ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c,
                                                        ONE_Concepto_Comercial__c, ONE_Concepto_Comercial__r.Name
                                                        FROM ONE_Entrada_De_Precio__c WHERE ONE_Vigente_Desde__c = :input.fechaInicio];
        
        for (ONE_Entrada_De_Precio__c price : updatedPrices) {
            Decimal expectedPrice;
            if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'A') {
                expectedPrice = 100 * (1 + 0.10);
            } else if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'B') {
                expectedPrice = 100 * (1 + 0.15);
            } else if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'C') {
                expectedPrice = 100 * (1 + 0.20);
            } else if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'N') {
                expectedPrice = 100 * (1 + 0.25);
            }
            System.assertEquals(expectedPrice, price.ONE_Precio__c, 'El precio actualizado no es correcto para el producto ' + price.ONE_Concepto_Comercial__r.Name);
        }

    }
    
	@testSetup
    static void setupTestData() {
        
        List<ONE_Producto__c> productList= new List<ONE_Producto__c>();
        
        ONE_Producto__c tipoA = new ONE_Producto__c(
        	Name = 'TipoA',
            ONE_Descripcion_En_Castellano__c = 'TipoA',
            ONE_Clasificacion_ABC__c = 'A',
            ONE_Tipo_De_Precio__c = 'Precio local',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(tipoA);
        
        ONE_Producto__c tipoB = new ONE_Producto__c(
        	Name = 'TipoB',
            ONE_Descripcion_En_Castellano__c = 'TipoB',
            ONE_Clasificacion_ABC__c = 'B',
            ONE_Tipo_De_Precio__c = 'Precio local',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(tipoB);
        
        ONE_Producto__c tipoC = new ONE_Producto__c(
        	Name = 'TipoC',
            ONE_Descripcion_En_Castellano__c = 'TipoC',
            ONE_Clasificacion_ABC__c = 'C',
            ONE_Tipo_De_Precio__c = 'Precio local',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(tipoC);
        
        ONE_Producto__c tipoN = new ONE_Producto__c(
        	Name = 'TipoN',
            ONE_Descripcion_En_Castellano__c = 'TipoN',
            ONE_Clasificacion_ABC__c = 'N',
            ONE_Tipo_De_Precio__c = 'Precio local',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(tipoN);
        
        ONE_Producto__c noLocal = new ONE_Producto__c(
        	Name = 'noLocal',
            ONE_Descripcion_En_Castellano__c = 'noLocal',
            ONE_Clasificacion_ABC__c = 'N',
            ONE_Tipo_De_Precio__c = 'Precio único',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(noLocal);
        
		insert productList;
        
        ONE_Catalogo_de_Precios__c cat = new ONE_Catalogo_de_Precios__c(
        	Name = 'Catálogo Test',
            ONE_Tipo_De_Tarifa__c = 'Local',
            ONE_Validez_Desde__c = Date.today().addDays(-1)
        );
        insert cat;
        
        List<ONE_Entrada_De_Precio__c> priceEntryList = new List<ONE_Entrada_De_Precio__c>();
        
        ONE_Entrada_De_Precio__c priceEntryA = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = tipoA.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10)
        );
        priceEntryList.add(priceEntryA);
        
        ONE_Entrada_De_Precio__c priceEntryB = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = tipoB.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10)
        );
        priceEntryList.add(priceEntryB);
        
        ONE_Entrada_De_Precio__c priceEntryC = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = tipoC.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10)
        );
        priceEntryList.add(priceEntryC);
        
        ONE_Entrada_De_Precio__c priceEntryN = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = tipoN.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10)
        );
        priceEntryList.add(priceEntryN);
        
        ONE_Entrada_De_Precio__c priceEntryNoLocal = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = noLocal.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10)
        );
        priceEntryList.add(priceEntryNoLocal);
                
        insert priceEntryList;
    }
}
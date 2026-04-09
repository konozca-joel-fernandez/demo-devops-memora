/**
 * Created by Marc Pàmies on 23/10/2024.
 */

@isTest
public class ONE_MassUpdateCataloguePriceEntryTest {
    @isTest
    static void testUpdateCataloguePriceEntry() {
        List<ONE_MassUpdateCataloguePriceEntry.FlowInputs> inputsList = new List<ONE_MassUpdateCataloguePriceEntry.FlowInputs>();
        
        ONE_MassUpdateCataloguePriceEntry.FlowInputs input = new ONE_MassUpdateCataloguePriceEntry.FlowInputs();
        input.catalogueId = [SELECT Id FROM ONE_Catalogo_De_Precios__c LIMIT 1].Id; 
        input.percentA = 0.10;
        input.percentB = 0.15;
        input.percentC = 0.20;
        input.percentN = 0.25;
        input.vigenteHastaDate = Date.today().addDays(30);
        inputsList.add(input);

        Test.startTest();
        List<ONE_MassUpdateCataloguePriceEntry.FlowOutputs> outputs = ONE_MassUpdateCataloguePriceEntry.updateCataloguePriceEntry(inputsList);
        Test.stopTest();

        System.assertNotEquals(null, outputs);
        System.assertEquals(1, outputs.size());
        System.assertEquals('', outputs[0].message, 'El mensaje de error no debería estar presente.');
            
        List<ONE_Entrada_De_Precio__c> updatedPrices = [SELECT Id, ONE_Precio__c, ONE_Vigente_Hasta__c, ONE_Entrada_De_Precio_Padre__c, ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c,
                                                        ONE_Concepto_Comercial__c, ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c, ONE_Concepto_Comercial__r.ONE_Flores__c, ONE_Concepto_Comercial__r.Name
                                                        FROM ONE_Entrada_De_Precio__c WHERE ONE_Vigente_Desde__c = :input.vigenteHastaDate];
        
        for (ONE_Entrada_De_Precio__c price : updatedPrices) {
            Decimal expectedPrice;
            if (price.ONE_Entrada_De_Precio_Padre__c == null){
                if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'A') {
                    expectedPrice = 100 * (1 + 0.10);  // 10% incremento
                } else if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'B') {
                    expectedPrice = 100 * (1 + 0.15);  // 15% incremento
                } else if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'C') {
                    expectedPrice = 100 * (1 + 0.20);  // 20% incremento
                } else if (price.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c == 'N') {
                    expectedPrice = 100 * (1 + 0.25);  // 25% incremento
                }
            }
            else{
                if (price.ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c == 'Precio Local'){
                    expectedPrice = 100;
                }
                else if (price.ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c == 'Precio Único'){
                    expectedPrice = 100 * (1 + 0.10);
                }
                else if (price.ONE_Concepto_Comercial__r.ONE_Flores__c){
                    expectedPrice = 100 * (1 + 0.10) * 0.25;
                }
                else{
                    expectedPrice = 100 * (1 + 0.10) * 0.5;
                }
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
            ONE_Tipo_De_Precio__c = 'Precio único',
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
            ONE_Tipo_De_Precio__c = 'Precio indexado',
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
            ONE_Tipo_De_Precio__c = 'Precio único',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(tipoN);
        
        ONE_Producto__c flores = new ONE_Producto__c(
        	Name = 'Flores',
            ONE_Descripcion_En_Castellano__c = 'Flores',
            ONE_Clasificacion_ABC__c = 'A',
            ONE_Tipo_De_Precio__c = 'Precio indexado',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = True            
        );
        productList.add(flores);
        
        ONE_Producto__c precioUnico = new ONE_Producto__c(
        	Name = 'Precio único',
            ONE_Descripcion_En_Castellano__c = 'Precio único',
            ONE_Clasificacion_ABC__c = 'A',
            ONE_Tipo_De_Precio__c = 'Precio único',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(precioUnico);
        
        ONE_Producto__c precioIndexado = new ONE_Producto__c(
        	Name = 'Precio indexado',
            ONE_Descripcion_En_Castellano__c = 'Precio indexado',
            ONE_Clasificacion_ABC__c = 'A',
            ONE_Tipo_De_Precio__c = 'Precio indexado',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(precioIndexado);
        
        ONE_Producto__c precioLocal = new ONE_Producto__c(
        	Name = 'Precio local',
            ONE_Descripcion_En_Castellano__c = 'Precio local',
            ONE_Clasificacion_ABC__c = 'A',
            ONE_Tipo_De_Precio__c = 'Precio local',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = False            
        );
        productList.add(precioLocal);
        
		insert productList;
        
        ONE_Catalogo_de_Precios__c cat = new ONE_Catalogo_de_Precios__c(
        	Name = 'Catálogo Test',
            ONE_Tipo_De_Tarifa__c = 'Base',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Indice_Para_Flores__c = 0.25,
            ONE_Indice_Para_Otros_Productos__c  = 0.5
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
        
        ONE_Entrada_De_Precio__c priceEntryIndexado = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = precioIndexado.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10),
            ONE_Entrada_De_Precio_Padre__c = priceEntryA.Id
        );
        priceEntryList.add(priceEntryIndexado);
        
        ONE_Entrada_De_Precio__c priceEntryLocal = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = precioLocal.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10),
            ONE_Entrada_De_Precio_Padre__c = priceEntryA.Id
        );
        priceEntryList.add(priceEntryLocal);
        
        ONE_Entrada_De_Precio__c priceEntryflores = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = flores.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10),
            ONE_Entrada_De_Precio_Padre__c = priceEntryA.Id
        );
        priceEntryList.add(priceEntryflores);
        
        ONE_Entrada_De_Precio__c priceEntryUnico = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = cat.Id,
            ONE_Precio__c = 100,
            ONE_Concepto_Comercial__c = precioUnico.Id,
            ONE_Vigente_Desde__c = Date.today().addDays(-10),
            ONE_Vigente_Hasta__c = Date.today().addDays(10),
            ONE_Entrada_De_Precio_Padre__c = priceEntryA.Id
        );
        priceEntryList.add(priceEntryUnico);
        
        insert priceEntryList;
    }
}
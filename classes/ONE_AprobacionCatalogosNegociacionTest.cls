@IsTest
public class ONE_AprobacionCatalogosNegociacionTest {
@TestSetup static void setup() {
        
        Account entidad = new Account(Name='MAPFRE TEST',ONE_Estado__c='Aceptado',ONE_Nivel_Jerarquia_Cuentas__c='Agrupación Salesforce');
        insert entidad;
        ONE_Producto__c producto=new ONE_Producto__c(Name='Product Test',ONE_Codigo_Comercial__c='12345',ONE_Codigo_SAP__c='12345');
        insert producto;
        ONE_Lugar__c lugar=new ONE_Lugar__c(Name='LUGAR TEST', ONE_Nivel_Jerarquico__c='delegacion');
        insert lugar;
      	ONE_Catalogo_De_Precios__c catalogo1 = new ONE_Catalogo_De_Precios__c(name='No selected',ONE_Validez_Desde__c = Date.today().addDays(-1),ONE_Compania__c = entidad.Id, ONE_Lugar__c = lugar.Id);
        insert catalogo1;       
    	String catalogoReferencia=[Select ONE_Identificador_Catalogo__c from ONE_Catalogo_De_Precios__c where Id=:catalogo1.Id].ONE_Identificador_Catalogo__c;
    	System.debug('catalogoReferencia'+catalogoReferencia);
     	ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c( ONE_Estado__c='En negociación',name='CATALOGO SELECTED',ONE_Validez_Desde__c = Date.today().addDays(-1),ONE_Compania__c = entidad.Id, ONE_Lugar__c = lugar.Id,ONE_Catalogo_de_Referencia__c=catalogoReferencia);
        insert catalogo;
    	System.debug('catalogo'+catalogo);
        ONE_Segmentacion_Acuerdo__c segmentacion= new ONE_Segmentacion_Acuerdo__c(ONE_Catalogo_de_precios__c=catalogo.Id,ONE_Lugar__c=lugar.Id,Name='SEGMENTACION TEST',ONE_Segmentacion_Interna__c='nobilis',ONE_Vigencia_Desde__c=Date.today(),ONE_Vigencia_Hasta__c=Date.today()+300);
        insert segmentacion;
     
		ONE_Segmentacion_Acuerdo__c acuerdo=new ONE_Segmentacion_Acuerdo__c(ONE_Estado__c='En negociación',ONE_Acuerdo_de_Referencia__c=segmentacion.ONE_Identificador_Acuerdo__c, ONE_Catalogo_de_precios__c=catalogo.Id,ONE_Lugar__c=lugar.Id,Name='ACUERDO TEST', ONE_Compania__c=entidad.Id,ONE_Vigencia_Desde__c=Date.today(),ONE_Vigencia_Hasta__c=Date.today()+300);
        insert acuerdo;
        
        ONE_Segmentacion_De_Linea__c s1= new ONE_Segmentacion_De_Linea__c(ONE_Segmentacion_Acuerdo__c=segmentacion.Id,ONE_Producto__c=producto.Id);
        insert s1;
     	
      	ONE_Entrada_De_Precio__c entradaPrecio = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Concepto_Comercial__c = producto.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio;
        ONE_Entrada_De_Precio__c entradaPrecio2 = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo1.Id,
            ONE_Concepto_Comercial__c = producto.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio2;
 
        
    }
    static testMethod void ONE_AprobacionCatalogosNegociacion() {
        Test.startTest();
         ONE_AprobacionCatalogosNegociacion.FlowInput input = new ONE_AprobacionCatalogosNegociacion.FlowInput();
         List<String> catalogosSelected=new List<String>();
        List<String> catalogosReferencia=new List<String>();
        for(ONE_Catalogo_de_Precios__c catalogo:[SELECT Id, ONE_Catalogo_de_Referencia__c, ONE_Identificador_catalogo__c from ONE_Catalogo_de_Precios__c where ONE_Estado__c='En negociación']){
            catalogosSelected.add(catalogo.Id);
            catalogosReferencia.add(catalogo.ONE_Catalogo_de_Referencia__c);
        }
         
         input.finVigencia=Date.today()-1;
         input.inicioVigencia=Date.today();
         input.catalogosSeleccionadosIds=catalogosSelected;
         input.catalogosReferenciaExternalId=catalogosReferencia;
        
        
        List<ONE_AprobacionCatalogosNegociacion.FlowInput> inputs = new List<ONE_AprobacionCatalogosNegociacion.FlowInput>{input};
        List<ONE_AprobacionCatalogosNegociacion.FlowOutput> outputs = ONE_AprobacionCatalogosNegociacion.AprobacionCatalogosNegociacionMethod(inputs);
        ONE_AprobacionCatalogosNegociacion aprobar=new ONE_AprobacionCatalogosNegociacion(inputs);
        Test.stopTest();
    }
}
@isTest
public class ONE_SimuladorCompaniasTest {
 @TestSetup static void setup() {
        
        Account entidad = new Account(Name='MAPFRE TEST',ONE_Estado__c='Aceptado',ONE_Nivel_Jerarquia_Cuentas__c='Agrupación Salesforce');
        insert entidad;
        ONE_Producto__c producto=new ONE_Producto__c(Name='Product Test',ONE_Codigo_Comercial__c='12345',ONE_Codigo_SAP__c='12345');
        insert producto;
        ONE_Lugar__c lugar=new ONE_Lugar__c(Name='LUGAR TEST', ONE_Nivel_Jerarquico__c='delegacion');
        insert lugar;
      	ONE_Catalogo_De_Precios__c catalogo1 = new ONE_Catalogo_De_Precios__c(ONE_Validez_Desde__c = Date.today().addDays(-1),ONE_Compania__c = entidad.Id, ONE_Lugar__c = lugar.Id);
        insert catalogo1;
     	ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(name='CATALOGO SELECTED',ONE_Validez_Desde__c = Date.today().addDays(-1),ONE_Compania__c = entidad.Id, ONE_Lugar__c = lugar.Id,ONE_Catalogo_de_Referencia__c=catalogo1.ONE_Identificador_Catalogo__c);
        insert catalogo;
        ONE_Segmentacion_Acuerdo__c segmentacion= new ONE_Segmentacion_Acuerdo__c(ONE_Catalogo_de_precios__c=catalogo.Id,ONE_Lugar__c=lugar.Id,Name='SEGMENTACION TEST',ONE_Segmentacion_Interna__c='nobilis',ONE_Vigencia_Desde__c=Date.today(),ONE_Vigencia_Hasta__c=Date.today()+300);
        insert segmentacion;
     
		ONE_Segmentacion_Acuerdo__c acuerdo=new ONE_Segmentacion_Acuerdo__c(ONE_Catalogo_de_precios__c=catalogo.Id,ONE_Lugar__c=lugar.Id,Name='ACUERDO TEST', ONE_Compania__c=entidad.Id,ONE_Vigencia_Desde__c=Date.today(),ONE_Vigencia_Hasta__c=Date.today()+300);
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
    static testMethod void simuladorAccount() {
        Test.startTest();
         ONE_SimuladorCompanias.FlowInput input = new ONE_SimuladorCompanias.FlowInput();
         List<Id> catalogosSelected=new List<Id>();
        for(ONE_Catalogo_de_Precios__c catalogo:[SELECT Id from ONE_Catalogo_de_Precios__c where Name='CATALOGO SELECTED']){
            catalogosSelected.add(catalogo.Id);
        }
         input.catalogosPrecioRelacionados=catalogosSelected;
         input.finVigencia=Date.today()-1;
         input.inicioVigencia=Date.today();
         input.PorcentajeA=0.5;
         input.PorcentajeB=0.2;
         input.PorcentajeC=0.2;
         input.PorcentajeN=0.1;
        
        List<ONE_SimuladorCompanias.FlowInput> inputs = new List<ONE_SimuladorCompanias.FlowInput>{input};
        List<ONE_SimuladorCompanias.FlowOutput> outputs = ONE_SimuladorCompanias.SimuladorSubidaTarifasPorCuenta(inputs);
        ONE_SimuladorCompanias simulador= new ONE_SimuladorCompanias(inputs);
        Test.stopTest();
    }
}
@isTest
public class ONE_AccionesMasivasTest {

    @TestSetup static void setup() {
        
        Account entidad = new Account(Name='MAPFRE TEST',ONE_Estado__c='Aceptado',ONE_Nivel_Jerarquia_Cuentas__c='Agrupación Salesforce');
        insert entidad;
        ONE_Producto__c producto=new ONE_Producto__c(Name='Product Test',ONE_Codigo_Comercial__c='12345',ONE_Codigo_SAP__c='12345');
        insert producto;
        ONE_Lugar__c lugar=new ONE_Lugar__c(Name='LUGAR TEST', ONE_Nivel_Jerarquico__c='delegacion');
        insert lugar;
        ONE_Segmentacion_Acuerdo__c segmentacion= new ONE_Segmentacion_Acuerdo__c(ONE_Lugar__c=lugar.Id,Name='SEGMENTACION TEST',ONE_Segmentacion_Interna__c='nobilis',ONE_Vigencia_Desde__c=Date.today(),ONE_Vigencia_Hasta__c=Date.today()+300);
        insert segmentacion;
		ONE_Segmentacion_Acuerdo__c acuerdo=new ONE_Segmentacion_Acuerdo__c(ONE_Lugar__c=lugar.Id,Name='ACUERDO TEST', ONE_Compania__c=entidad.Id,ONE_Vigencia_Desde__c=Date.today(),ONE_Vigencia_Hasta__c=Date.today()+300);
        insert acuerdo;
        
        ONE_Segmentacion_De_Linea__c s1= new ONE_Segmentacion_De_Linea__c(ONE_Segmentacion_Acuerdo__c=segmentacion.Id,ONE_Producto__c=producto.Id);
        insert s1;
        
        
    }
    static testMethod void getLineasAcuerdos() {
        Test.startTest();
        List<String> filters =new List<String>();
        filters.add([SELECT Id FROM ONE_Producto__c].Id);
        filters.add([SELECT Id FROM ONE_Lugar__c].Id);
        filters.add([SELECT Id FROM Account].Id);
        filters.add(String.valueOf(Date.today()));
        List<List<String>> lfilters=new List<List<String>>();
        lfilters.add(filters);
        List<List<ONE_Segmentacion_De_Linea__c>> result=ONE_AccionesMasivasAcuerdos.getAcuerdos(lfilters);
        Test.stopTest();
    }
     static testMethod void getLineasSegmentos() {
        Test.startTest();
         List<String> filters =new List<String>();
        filters.add([SELECT Id FROM ONE_Producto__c].Id);
        filters.add('nobilis');
        filters.add([SELECT Id FROM ONE_Lugar__c].Id);
        filters.add(String.valueOf(Date.today()));
        List<List<String>> lfilters=new List<List<String>>();
        lfilters.add(filters);
        List<List<ONE_Segmentacion_De_Linea__c>> result=ONE_AccionesMasivasSegmentos.getSegmentos(lfilters);
        Test.stopTest();
    }
    
      static testMethod void addProductSegmentos() {
        Test.startTest();
         List<String> filters =new List<String>();
        filters.add([SELECT Id FROM ONE_Producto__c].Id);
        filters.add('nobilis');
        filters.add([SELECT Id FROM ONE_Lugar__c].Id);
        filters.add(String.valueOf(Date.today()));
        List<List<String>> lfilters=new List<List<String>>();
        lfilters.add(filters);
        List<List<ONE_Segmentacion_Acuerdo__c>> result=ONE_IncorporarProductoSegmentos.getSegmentos(lfilters);
        Test.stopTest();
    }

     static testMethod void addProductAcuerdos() {
        Test.startTest();
         List<String> filters =new List<String>();
        filters.add([SELECT Id FROM ONE_Producto__c].Id);
        filters.add('nobilis');
        filters.add([SELECT Id FROM ONE_Lugar__c].Id);
        filters.add(String.valueOf(Date.today()));
        List<List<String>> lfilters=new List<List<String>>();
        lfilters.add(filters);
        List<List<ONE_Segmentacion_Acuerdo__c>> result=ONE_IncorporarProductoAcuerdos.getAcuerdos(lfilters);
        Test.stopTest();
    }

        
        
    
}
@isTest
public class ONE_AgrupacionCuentasControllerTest {
  @testSetup
    private static void testSetup() {

        Account account = new Account(
            Name = 'Company',
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name, ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS),
            ONE_Nivel_Jerarquia_Cuentas__c='Agrupación Salesforce',
            ONE_Tipo__c='Jerarquías'
        );
        insert account;

        ONE_Lugar__c lugar = new ONE_Lugar__c(
            Name = 'Lugar'
        );
        insert lugar;

        ONE_Catalogo_De_Precios__c catalogo = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c = account.Id,
            ONE_Lugar__c = lugar.Id
        );
        insert catalogo;
        ONE_Catalogo_De_Precios__c catalogo2 = new ONE_Catalogo_De_Precios__c(
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Lugar__c = lugar.Id,
            ONE_Compania__c = account.Id
        );
        insert catalogo2;

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

        ONE_Producto__c producto = new ONE_Producto__c(
            Name = 'Producto',
            ONE_Categoria__c = categoria.Id
        );
        insert producto;

        ONE_Entrada_De_Precio__c entradaPrecio = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo.Id,
            ONE_Concepto_Comercial__c = producto.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio;
        ONE_Entrada_De_Precio__c entradaPrecio2 = new ONE_Entrada_De_Precio__c(
            ONE_Catalogo_De_Precios__c = catalogo2.Id,
            ONE_Concepto_Comercial__c = producto.Id,
            ONE_Precio__c = 0,
            ONE_Vigente_Hasta__c = Date.today().addDays(1),
            ONE_Vigente_Desde__c = Date.today().addDays(-1)
        );
        insert entradaPrecio2;
    
        ONE_Segmentacion_Acuerdo__c acuerdo =new ONE_Segmentacion_Acuerdo__c(
            ONE_Catalogo_De_Precios__c=catalogo2.Id,
            ONE_Vigencia_Hasta__c = Date.today().addDays(1),
            ONE_Vigencia_Desde__c = Date.today().addDays(-1),
            ONE_Compania__c=account.Id
        );
        insert acuerdo;
        ONE_Segmentacion_De_Linea__c linea= new ONE_Segmentacion_De_Linea__c(
        ONE_Segmentacion_Acuerdo__c=acuerdo.Id,
        ONE_Comportamiento__c='01'
        );
        insert linea;
        }
    @isTest
    private static void ONE_AgrupacionCuentasController() {
        List<Id> catalogosIds= new List<Id>();
        List <ONE_AgrupacionCuentasController.FlowInput> flowInputs=new List <ONE_AgrupacionCuentasController.FlowInput>();
        List <ONE_ClonarAcuerdosController.FlowInput> flowInputs2=new List <ONE_ClonarAcuerdosController.FlowInput>();
        ONE_AgrupacionCuentasController.FlowInput fi=new ONE_AgrupacionCuentasController.FlowInput();
        ONE_ClonarAcuerdosController.FlowInput fi2= new ONE_ClonarAcuerdosController.FlowInput();
        for(ONE_Catalogo_De_Precios__c catalogo:[SELECT Id FROM ONE_Catalogo_De_Precios__c]){
            catalogosIds.add(catalogo.Id);
        }
        fi.catalogosPrecioRelacionados=catalogosIds;
        fi.finVigencia=Date.today().addDays(30);
        fi.inicioVigencia=fi.finVigencia.addDays(1);
        fi.PorcentajeA=20;
        fi.PorcentajeA=15;
        fi.PorcentajeA=10;
        flowInputs.add(fi);
        
        fi2.catalogosPrecioRelacionados=catalogosIds;
        fi2.finVigencia=Date.today().addDays(30);
        fi2.inicioVigencia=fi.finVigencia.addDays(1);
        fi2.tipoRecalculo='Recálculo de ajuste';
        fi2.aplicarRecalculo='Si';
        fi2.tipoA=5;
        flowInputs2.add(fi2);
        ONE_AgrupacionCuentasController ag= new ONE_AgrupacionCuentasController(flowInputs);
        List <ONE_AgrupacionCuentasController.FlowOutput> flowOutputs=new List <ONE_AgrupacionCuentasController.FlowOutput>();
        flowOutputs=ONE_AgrupacionCuentasController.subidaTarifasPorCuenta(flowInputs);
        ONE_ClonarAcuerdosController clone= new ONE_ClonarAcuerdosController(flowInputs2);
        List <ONE_ClonarAcuerdosController.FlowOutput> flowOutputs2=new List <ONE_ClonarAcuerdosController.FlowOutput>();
        flowOutputs2=ONE_ClonarAcuerdosController.cloneAcuerdosSeleccionados(flowInputs2);
    }
}
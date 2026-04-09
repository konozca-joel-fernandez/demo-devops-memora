public class ONE_AgrupacionCuentasController {
    private Decimal PorcentajeA;
    private Decimal PorcentajeB;
    private Decimal PorcentajeC;
    private Decimal PorcentajeN;
    private Date inicioVigencia;
    private Date finVigencia; 
    private List<Id> catalogosPrecioRelacionados;


    public ONE_AgrupacionCuentasController(List < FlowInput > flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.PorcentajeA = flowInput.PorcentajeA;
        this.PorcentajeB = flowInput.PorcentajeB;
        this.PorcentajeC = flowInput.PorcentajeC;
        this.PorcentajeN = flowInput.PorcentajeN;
        this.inicioVigencia = flowInput.inicioVigencia;
        this.finVigencia = flowInput.finVigencia;
        this.catalogosPrecioRelacionados = flowInput.catalogosPrecioRelacionados;
    
    }
    @InvocableMethod(label = 'subidaTarifasPorCuenta')
    public static List<FlowOutput> subidaTarifasPorCuenta(List < FlowInput > flowInputs) {
        FlowInput flowInput = flowInputs.get(0);
        System.debug('flowInput: '+flowInput);
        Boolean success;
        Decimal newPrice;
        List<ONE_Entrada_de_Precio__c> entradasPrecioToUpdate= new List<ONE_Entrada_de_Precio__c>();
        List<ONE_Entrada_de_Precio__c> entradasPrecioToCreate= new List<ONE_Entrada_de_Precio__c>();
            
        try{
            List<ONE_Entrada_de_Precio__c> entradasPrecio=[SELECT Id,ONE_Precio__c,ONE_Vigente_Desde__c,ONE_Vigente_Hasta__c,ONE_Catalogo_De_Precios__c,ONE_Concepto_Comercial__c,ONE_Tipologia_De_Producto__c,ONE_Tipo_De_Precio__c, ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c
                                                          FROM ONE_Entrada_de_Precio__c 
                                                          WHERE ONE_Catalogo_De_Precios__c IN: flowInput.catalogosPrecioRelacionados 
                                                          AND ONE_Entrada_De_Precio_Padre__c=null
                                                          AND ONE_Activo_Vigencia__c=true];
            System.debug('entradasPrecio size: '+entradasPrecio.size());
            for(ONE_Entrada_de_Precio__c ep:entradasPrecio){
                
                ONE_Entrada_de_Precio__c epClonada=ep.clone(false,true,false,false);
                
                switch on (ep.ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c){
                    when 'A'{newPrice=ep.ONE_Precio__c + (ep.ONE_Precio__c *flowInput.PorcentajeA/100);}
                    when 'B'{newPrice=ep.ONE_Precio__c + (ep.ONE_Precio__c *flowInput.PorcentajeB/100);}
                    when 'C'{newPrice=ep.ONE_Precio__c + (ep.ONE_Precio__c *flowInput.PorcentajeC/100);}
                    when 'N'{newPrice=ep.ONE_Precio__c + (ep.ONE_Precio__c *flowInput.PorcentajeN/100);}
                    when else{newPrice=ep.ONE_Precio__c;}
                }
                epClonada.ONE_Precio__c=newPrice.setScale(2);
                epClonada.ONE_Vigente_Desde__c=flowInput.inicioVigencia;
                epClonada.ONE_Vigente_Hasta__c=null;
                entradasPrecioToCreate.add(epClonada);
                System.debug('epClonada : '+ epClonada);
                
                ep.ONE_Vigente_Hasta__c=flowInput.finVigencia;
                entradasPrecioToUpdate.add(ep);
                
                System.debug('entradasPrecioToCreate : '+ entradasPrecioToCreate);
                System.debug('entradasPrecioToUpdate : '+ entradasPrecioToUpdate);
            }
            update entradasPrecioToUpdate;
            insert entradasPrecioToCreate;
             success=true;
        }catch(Exception e){
             success=false;
        }
        return new List<FlowOutput>{new FlowOutput(success)};
    }
    public virtual class FlowInput {
        @InvocableVariable
        public Decimal PorcentajeA;
        @InvocableVariable
        public Decimal PorcentajeB;
        @InvocableVariable
        public Decimal PorcentajeC;
        @InvocableVariable
        public Decimal PorcentajeN;
        @InvocableVariable
        public Date inicioVigencia;
        @InvocableVariable
        public Date finVigencia;
        @InvocableVariable
        public List<Id> catalogosPrecioRelacionados;
    }

    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
        
        public FlowOutput(Boolean success) {
            this.success = success;
            
        }
    }
}
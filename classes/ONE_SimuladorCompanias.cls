public class ONE_SimuladorCompanias {
    private Decimal PorcentajeA;
    private Decimal PorcentajeB;
    private Decimal PorcentajeC;
    private Decimal PorcentajeN;
    private Date inicioVigencia;
    private Date finVigencia; 
    private List<Id> catalogosPrecioRelacionados;
       
    public ONE_SimuladorCompanias(List < FlowInput > flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.PorcentajeA = flowInput.PorcentajeA;
        this.PorcentajeB = flowInput.PorcentajeB;
        this.PorcentajeC = flowInput.PorcentajeC;
        this.PorcentajeN = flowInput.PorcentajeN;
        this.inicioVigencia = flowInput.inicioVigencia;
        this.finVigencia = flowInput.finVigencia;
        this.catalogosPrecioRelacionados = flowInput.catalogosPrecioRelacionados;
    
    }
        @InvocableMethod(label = 'SimuladorSubidaTarifasPorCuenta')
    public static List<FlowOutput> SimuladorSubidaTarifasPorCuenta(List < FlowInput > flowInputs) {
        FlowInput flowInput = flowInputs.get(0);
        System.debug('flowInput: '+flowInput);
        Boolean success;
        Decimal newPrice;
        List<ONE_Catalogo_De_Precios__c> catalogosToCreate=new List<ONE_Catalogo_De_Precios__c>();
        List<ONE_Entrada_de_Precio__c> entradasPrecioToCreate= new List<ONE_Entrada_de_Precio__c>();
        List<ONE_Segmentacion_Acuerdo__c> acuerdosToCreate= new List<ONE_Segmentacion_Acuerdo__c>();
        List<ONE_Segmentacion_De_Linea__c> lineasAcuerdosToCreate= new List<ONE_Segmentacion_De_Linea__c>();
            
        try{
            List<ONE_Catalogo_De_Precios__c> catalogos=[SELECT Id,Name,ONE_Catalogo_de_Referencia__c,ONE_Centro__c,ONE_Compania__c,ONE_Estado__c,ONE_Identificador_Catalogo__c,ONE_Lugar__c,ONE_Validez_Desde__c,ONE_Validez_Hasta__c
                                                         FROM ONE_Catalogo_De_Precios__c
                                                         WHERE Id IN: flowInput.catalogosPrecioRelacionados];
            for(ONE_Catalogo_De_Precios__c catalogo:catalogos){
                ONE_Catalogo_De_Precios__c catalogoClonado=catalogo.clone(false,true,false,false);
                catalogoClonado.ONE_Catalogo_de_Referencia__c=catalogo.ONE_Identificador_Catalogo__c;
                catalogoClonado.ONE_Estado__c='En negociación';
                catalogoClonado.Name=catalogo.Name + ' subida '+flowInput.PorcentajeA+'%';
                catalogoClonado.ONE_Validez_Desde__c=flowInput.inicioVigencia;
                catalogoClonado.ONE_Validez_Hasta__c=null;
                catalogoClonado.ONE_Tipo_De_Tarifa__c='Compañía';
                catalogoClonado.ONE_External_ID__c=catalogo.Name + ' subida '+flowInput.PorcentajeA+'%';
                catalogosToCreate.add(catalogoClonado);
                
            }
            insert catalogosToCreate;
            List<ONE_Entrada_de_Precio__c> entradasPrecio=[SELECT Id,ONE_Precio__c,ONE_Vigente_Desde__c,ONE_Vigente_Hasta__c,ONE_Catalogo_De_Precios__c,ONE_Catalogo_De_Precios__r.ONE_Identificador_Catalogo__c,ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c,ONE_Concepto_Comercial__c,ONE_Tipologia_De_Producto__c,ONE_Tipo_De_Precio__c, ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c
                                                          FROM ONE_Entrada_de_Precio__c 
                                                          WHERE ONE_Catalogo_De_Precios__c IN: flowInput.catalogosPrecioRelacionados 
                                                          AND ONE_Entrada_De_Precio_Padre__c=null
                                                          AND ONE_Activo_Vigencia__c=true];
            System.debug('entradasPrecio size: '+entradasPrecio.size());
           for(ONE_Catalogo_De_Precios__c catalogo:catalogosToCreate){
            for(ONE_Entrada_de_Precio__c ep:entradasPrecio){
                if(ep.ONE_Catalogo_De_Precios__r.ONE_Identificador_Catalogo__c==catalogo.ONE_Catalogo_de_Referencia__c){
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
                epClonada.ONE_Catalogo_De_Precios__c=catalogo.Id;
                entradasPrecioToCreate.add(epClonada);
                System.debug('epClonada : '+ epClonada);
                }
               
                System.debug('entradasPrecioToCreate : '+ entradasPrecioToCreate);
            }
           }
           
            insert entradasPrecioToCreate;
            
            List<ONE_Segmentacion_Acuerdo__c> acuerdos=[SELECT Id,Name,ONE_Compania__c,ONE_Importe_Conjunto__c,ONE_Necesita_Recalculo__c,ONE_Tipo_De_Recalculo__c,ONE_Lugar__c,ONE_Centro__c,ONE_Ajuste_Necesario__c,ONE_Vigencia_Hasta__c,ONE_Vigencia_Desde__c,ONE_Acuerdo_de_Referencia__c,ONE_Identificador_Acuerdo__c,ONE_Catalogo_De_Precios__c,ONE_Catalogo_De_Precios__r.ONE_Identificador_Catalogo__c,ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c,ONE_Estado__c
                                                          FROM ONE_Segmentacion_Acuerdo__c 
                                                          WHERE ONE_Catalogo_De_Precios__c IN: flowInput.catalogosPrecioRelacionados
                                                          AND ONE_Activo_Vigencia__c=true];
            for(ONE_Catalogo_De_Precios__c catalogo:catalogosToCreate){
                for(ONE_Segmentacion_Acuerdo__c acuerdo:acuerdos){
                    if(acuerdo.ONE_Catalogo_De_Precios__r.ONE_Identificador_Catalogo__c==catalogo.ONE_Catalogo_de_Referencia__c){
                		ONE_Segmentacion_Acuerdo__c acuerdoClonado=acuerdo.clone(false,true,false,false);
                        acuerdoClonado.ONE_Estado__c='En negociación';
                        acuerdoClonado.ONE_Vigencia_Desde__c=flowInput.inicioVigencia;
                        acuerdoClonado.ONE_Vigencia_Hasta__c=null;
                        acuerdoClonado.ONE_Acuerdo_de_Referencia__c=acuerdo.ONE_Identificador_Acuerdo__c;
                        acuerdoClonado.ONE_Catalogo_De_Precios__c=catalogo.Id;
                        acuerdoClonado.ONE_Necesita_Recalculo__c=true;
                        acuerdosToCreate.add(acuerdoClonado);
                    }
                    
                }
            }
            insert acuerdosToCreate;
            
            List<ONE_Segmentacion_De_Linea__c> lineasAcuerdo=[SELECT Id, ONE_Producto__c,ONE_Suplido__c,ONE_Unidades__c, ONE_Comportamiento__c,ONE_Segmentacion_Acuerdo__r.ONE_Identificador_Acuerdo__c,ONE_Segmentacion_Acuerdo__r.ONE_Acuerdo_de_Referencia__c,ONE_Segmentacion_Acuerdo__c,ONE_Segmentacion_Acuerdo__r.ONE_Catalogo_De_Precios__c,ONE_Segmentacion_Acuerdo__r.ONE_Catalogo_De_Precios__r.ONE_Identificador_Catalogo__c,ONE_Segmentacion_Acuerdo__r.ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c
                                                              FROM ONE_Segmentacion_De_Linea__c 
                                                              WHERE ONE_Segmentacion_Acuerdo__r.ONE_Catalogo_De_Precios__c IN: flowInput.catalogosPrecioRelacionados];
            for(ONE_Segmentacion_Acuerdo__c acuerdo:acuerdosToCreate){
                for(ONE_Segmentacion_De_Linea__c linea:lineasAcuerdo){
                    if(linea.ONE_Segmentacion_Acuerdo__r.ONE_Identificador_Acuerdo__c==acuerdo.ONE_Acuerdo_de_Referencia__c){
                        ONE_Segmentacion_De_Linea__c lineaClonada=linea.clone(false,true,false,false);
                        lineaClonada.ONE_Entrada_De_Precio_Relacionada__c=null;
                        lineaClonada.ONE_Segmentacion_Acuerdo__c=acuerdo.Id;
                        lineasAcuerdosToCreate.add(lineaClonada);
                    }
                }
            }
            insert lineasAcuerdosToCreate;
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
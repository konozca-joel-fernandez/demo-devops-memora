public class ONE_AprobacionCatalogosNegociacion {
    private Date inicioVigencia;
    private Date finVigencia; 
    private List<String> catalogosSeleccionadosIds;
    private List<String> catalogosReferenciaExternalId;
    
     public ONE_AprobacionCatalogosNegociacion(List <FlowInput> flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.inicioVigencia = flowInput.inicioVigencia;
        this.finVigencia = flowInput.finVigencia;
        this.catalogosSeleccionadosIds = flowInput.catalogosSeleccionadosIds;
        this.catalogosReferenciaExternalId=flowInput.catalogosReferenciaExternalId;
         
        
    }
        @InvocableMethod(label = 'AprobacionCatalogosNegociacion')
    public static List<FlowOutput> AprobacionCatalogosNegociacionMethod(List < FlowInput > flowInputs) { 
        FlowInput flowInput = flowInputs.get(0);
        Boolean success;
        try{
            Map<String, ONE_Catalogo_De_Precios__c> mapingCatalogos=new Map<String, ONE_Catalogo_De_Precios__c>();
            List<ONE_Entrada_de_Precio__c> entradasPrecioSelected= [SELECT Id,ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c FROM ONE_Entrada_de_Precio__c WHERE ONE_Catalogo_De_Precios__c IN:flowInput.catalogosSeleccionadosIds];
            List<ONE_Segmentacion_Acuerdo__c> acuerdosSelected= [SELECT Id,ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c FROM ONE_Segmentacion_Acuerdo__c WHERE ONE_Catalogo_De_Precios__c IN:flowInput.catalogosSeleccionadosIds];
            List<ONE_Entrada_de_Precio__c> entradasPrecioOld= [SELECT Id FROM ONE_Entrada_de_Precio__c WHERE ONE_Activo_Vigencia__c=true AND ONE_Catalogo_De_Precios__r.ONE_Identificador_Catalogo__c IN:flowInput.catalogosReferenciaExternalId];
            List<ONE_Segmentacion_Acuerdo__c> acuerdosOld= [SELECT Id FROM ONE_Segmentacion_Acuerdo__c WHERE ONE_Activo_Vigencia__c=true AND ONE_Catalogo_De_Precios__r.ONE_Identificador_Catalogo__c IN:flowInput.catalogosReferenciaExternalId ];
            System.debug('flowInput.catalogosReferenciaExternalId'+flowInput.catalogosReferenciaExternalId);
            System.debug('select'+[SELECT Id, ONE_Identificador_Catalogo__c, ONE_Catalogo_de_Referencia__c,Name from ONE_Catalogo_De_Precios__c where id =:flowInput.catalogosSeleccionadosIds]);
            System.debug('flowInput.catalogosSeleccionadosIds'+flowInput.catalogosSeleccionadosIds);
            System.debug('entradasPrecioSelected'+entradasPrecioSelected);
            System.debug('acuerdosSelected'+acuerdosSelected);
            System.debug('entradasPrecioOld'+entradasPrecioOld);
            System.debug('acuerdosOld'+acuerdosOld);
            for(ONE_Catalogo_De_Precios__c catalogo :[SELECT Id, ONE_Identificador_Catalogo__c  FROM ONE_Catalogo_De_Precios__c WHERE ONE_Identificador_Catalogo__c IN:flowInput.catalogosReferenciaExternalId]){
                 mapingCatalogos.put(catalogo.ONE_Identificador_Catalogo__c,catalogo); 
             }
             System.debug('mapingCatalogos'+mapingCatalogos);
             for(ONE_Entrada_de_Precio__c ep:entradasPrecioOld){
                 ep.ONE_Vigente_Hasta__c=flowInput.finVigencia;
             }
             update entradasPrecioOld;
             
             for(ONE_Segmentacion_Acuerdo__c acuerdo:acuerdosOld){
                 acuerdo.ONE_Vigencia_Hasta__c=flowInput.finVigencia;
             }
             update acuerdosOld;
             
             for(ONE_Entrada_de_Precio__c ep:entradasPrecioSelected){
                 if(mapingCatalogos.containsKey(ep.ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c)){
                     ep.ONE_Catalogo_De_Precios__c=(mapingCatalogos.get(ep.ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c)).Id;
                     ep.ONE_Vigente_Desde__c=flowInput.inicioVigencia;
                     ep.ONE_Vigente_Hasta__c=null;
                 }
             }
             update entradasPrecioSelected;
             
             for(ONE_Segmentacion_Acuerdo__c acuerdo:acuerdosSelected){
                 if(mapingCatalogos.containsKey(acuerdo.ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c)){
                     acuerdo.ONE_Catalogo_De_Precios__c=(mapingCatalogos.get(acuerdo.ONE_Catalogo_De_Precios__r.ONE_Catalogo_de_Referencia__c)).Id;
                     acuerdo.ONE_Vigencia_Desde__c=flowInput.inicioVigencia;
                     acuerdo.ONE_Vigencia_Hasta__c=null;
                     acuerdo.ONE_Estado__c=null;
                 }
             }
             update acuerdosSelected;
             success=true;
    	}catch(Exception e){
             success=false;
        }
     return new List<FlowOutput>{new FlowOutput(success)};
    }
     public virtual class FlowInput {
        @InvocableVariable
        public Date inicioVigencia;
        @InvocableVariable
        public Date finVigencia;
        @InvocableVariable
        public List<String> catalogosSeleccionadosIds;
        @InvocableVariable
        public List<String> catalogosReferenciaExternalId;
    }

    public virtual class FlowOutput {
        @InvocableVariable
        public Boolean success;
        
        public FlowOutput(Boolean success) {
            this.success = success;
            
        }
    }
}
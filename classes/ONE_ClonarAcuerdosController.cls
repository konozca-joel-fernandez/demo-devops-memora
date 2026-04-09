public class ONE_ClonarAcuerdosController {
    private Date inicioVigencia;
    private Date finVigencia;
    private String tipoRecalculo;
    private List<Id> catalogosPrecioRelacionados;
    private String aplicarRecalculo;
    private Decimal tipoA;
     
    public ONE_ClonarAcuerdosController(List < FlowInput > flowInputs) {

        FlowInput flowInput = flowInputs.get(0);
        this.inicioVigencia = flowInput.inicioVigencia;
        this.finVigencia = flowInput.finVigencia;
        this.tipoRecalculo=flowInput.tipoRecalculo;
        this.catalogosPrecioRelacionados = flowInput.catalogosPrecioRelacionados;
        this.aplicarRecalculo = flowInput.aplicarRecalculo;
        this.tipoA = flowInput.tipoA;
        
    
    }
     @InvocableMethod(label = 'cloneAcuerdosSeleccionados')
    public static List<FlowOutput> cloneAcuerdosSeleccionados(List < FlowInput > flowInputs) {
        
        FlowInput flowInput = flowInputs.get(0);
        ONE_Segmentacion_Acuerdo__c acuerdoClonado =new ONE_Segmentacion_Acuerdo__c();
        List<ONE_Segmentacion_Acuerdo__c> acuerdostoUpdate= new List<ONE_Segmentacion_Acuerdo__c>();
        ONE_Segmentacion_De_Linea__c lineaClonada= new ONE_Segmentacion_De_Linea__c();
        List<ONE_Segmentacion_De_Linea__c> lineasToCreate= new List<ONE_Segmentacion_De_Linea__c>();
        List<Id> acuerdosListIds= new List<Id>();
        Map<Id, ONE_Segmentacion_Acuerdo__c> acuerdosMap= new Map<Id, ONE_Segmentacion_Acuerdo__c>();
        Map <Id,Id> acuerdosOldNewIdMap =new Map <Id,Id>();
        
        System.debug('flowInput: '+flowInput);
        Boolean success;
        try{
            List<ONE_Segmentacion_Acuerdo__c> acuerdosRelacionados=[SELECT Id,ONE_Identificador_Acuerdo__c, Name,ONE_Ajuste_Necesario__c,ONE_Catalogo_De_Precios__c,ONE_Centro__c, ONE_Compania__c,ONE_Importe_Conjunto__c,ONE_Lugar__c,ONE_Necesita_Recalculo__c,ONE_Tipo_De_Recalculo__c,ONE_Vigencia_Desde__c,ONE_Vigencia_Hasta__c 
                                  FROM ONE_Segmentacion_Acuerdo__c 
                                  WHERE ONE_Catalogo_De_Precios__c IN: FlowInput.catalogosPrecioRelacionados 
                                  AND ONE_Activo_Vigencia__c=true];
            
            if(acuerdosRelacionados.size()!=0){
                for(ONE_Segmentacion_Acuerdo__c acuerdo : acuerdosRelacionados){
                    acuerdoClonado=acuerdo.clone(false,true,false,false);
                    acuerdoClonado.ONE_Vigencia_Desde__c=flowInput.inicioVigencia;
                    acuerdoClonado.ONE_Vigencia_Hasta__c=null;
                    acuerdoClonado.ONE_Tipo_De_Recalculo__c=flowInput.tipoRecalculo;
                    acuerdoClonado.ONE_Necesita_Recalculo__c=true;
                    acuerdoClonado.ONE_Acuerdo_de_Referencia__c=acuerdo.ONE_Identificador_Acuerdo__c;
                    acuerdoClonado.OwnerId=UserInfo.getUserId();
                    
                    
                    if(flowInput.aplicarRecalculo.toLowerCase()== 'si' && flowInput.aplicarRecalculo != null){
                        if(acuerdoClonado.ONE_Ajuste_Necesario__c != null && flowInput.tipoA != null){                            
                            acuerdoClonado.ONE_Ajuste_Necesario__c = acuerdoClonado.ONE_Ajuste_Necesario__c + acuerdoClonado.ONE_Ajuste_Necesario__c * (flowInput.tipoA/100);
                        }        
                    }
                    
                    
                    acuerdosMap.put(acuerdo.Id, acuerdoClonado);
                    acuerdo.ONE_Vigencia_Hasta__c=flowInput.finVigencia;
                    acuerdosToUpdate.add(acuerdo);
                    
                        
                    
                }
                update acuerdosToUpdate;
                insert acuerdosMap.values();
                
                for(Id acuerdoOldId :acuerdosMap.keySet()){
                    acuerdosOldNewIdMap.put(acuerdoOldId,acuerdosMap.get(acuerdoOldId).Id);
                    System.debug('acuerdosOldNewIdMap: '+acuerdosOldNewIdMap);
                }
                
                List <ONE_Segmentacion_De_Linea__c> lineasSegmentacion=[SELECT Id,ONE_Producto__c,ONE_Comportamiento__c,ONE_Suplido__c,ONE_Entrada_De_Precio_Relacionada__c, ONE_Unidades__c,ONE_Segmentacion_Acuerdo__c,ONE_External_Id__c
                                                                        FROM ONE_Segmentacion_De_Linea__c 
                                                                        WHERE ONE_Segmentacion_Acuerdo__c IN:acuerdosOldNewIdMap.keySet()];
            
                if(lineasSegmentacion.size()!=0){
                    for(ONE_Segmentacion_De_Linea__c linea: lineasSegmentacion){
                        lineaClonada=linea.clone(false,true,false,false);
                        lineaClonada.ONE_External_Id__c=null;
                        lineaClonada.ONE_Entrada_De_Precio_Relacionada__c=null;
                        lineaClonada.ONE_Segmentacion_Acuerdo__c=acuerdosOldNewIdMap.get(linea.ONE_Segmentacion_Acuerdo__c);
                        lineasToCreate.add(lineaClonada);
                    }
                    insert lineasToCreate;
                }
            }
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
        public String tipoRecalculo;
        @InvocableVariable
        public List<Id> catalogosPrecioRelacionados;
        @InvocableVariable
        public String aplicarRecalculo;
        @InvocableVariable
        public Decimal tipoA;
    }

    public virtual class FlowOutput {
       
        @InvocableVariable
        public Boolean success;
        
        public FlowOutput(Boolean success) {
            this.success = success;
            
        }
    }
}
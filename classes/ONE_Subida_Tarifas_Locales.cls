public class ONE_Subida_Tarifas_Locales {
	@InvocableMethod(label='SubidasTarifasParticular')
    public static List<FlowOutput> subidaLocales(List<FlowInput> inputs){
        List<FlowOutput> fo = new List<FlowOutput>();
        List<ONE_Entrada_De_Precio__c> allOldEntradas = new List<ONE_Entrada_De_Precio__c>();
        List<ONE_Entrada_De_Precio__c> allNewEntradas = new List<ONE_Entrada_De_Precio__c>();
        
        try{
            Map<String, Map<String, ONE_Entrada_De_Precio__c>> catalogo2entradas = new Map<String, Map<String, ONE_Entrada_De_Precio__c>>();
            for(ONE_Entrada_De_Precio__c ent : [SELECT Id, ONE_Catalogo_De_Precios__c, ONE_Precio__c, ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c 
                                                FROM ONE_Entrada_De_Precio__c 
                                                WHERE ONE_Catalogo_De_Precios__c IN :inputs[0].catalogos 
                                                AND ONE_Activo_Vigencia__c = TRUE AND ONE_Concepto_Comercial__r.ONE_Tipo_De_Precio__c = 'Precio Local']){
                if (catalogo2entradas.containsKey(ent.ONE_Catalogo_De_Precios__c)){
                    if(catalogo2entradas.get(ent.ONE_Catalogo_De_Precios__c).containsKey(ent.Id)){
                        //should not enter here
                    } else {
                        catalogo2entradas.get(ent.ONE_Catalogo_De_Precios__c).put(ent.Id, ent);
                    }
                } else {
                    catalogo2entradas.put(ent.ONE_Catalogo_De_Precios__c, new Map<String, ONE_Entrada_De_Precio__c>{ent.Id => ent});
                }
            }
            
            for(String cat : catalogo2entradas.keySet()) {
                List<ONE_Entrada_De_Precio__c> entradas = catalogo2entradas.get(cat).values();
                List<ONE_Entrada_De_Precio__c> entradasClonadas = entradas.deepClone();                
                for(integer i = 0; i < entradasClonadas.size(); i++){
                    entradas[i].ONE_Vigente_Hasta__c = inputs[0].fechaInicio.addDays(-1); 
                    
                    entradasClonadas[i].ONE_Vigente_Desde__c = inputs[0].fechaInicio;
                    
                    if (entradasClonadas[i].ONE_Precio__c != null){
                        switch on entradasClonadas[i].ONE_Concepto_Comercial__r.ONE_Clasificacion_ABC__c {
                            when 'A' {
                                entradasClonadas[i].ONE_Precio__c = entradasClonadas[i].ONE_Precio__c * (1 + (inputs[0].subidas[0] / 100.0));
                            }
                            when 'B' {
                                entradasClonadas[i].ONE_Precio__c = entradasClonadas[i].ONE_Precio__c * (1 + (inputs[0].subidas[1] / 100.0));
                            }
                            when 'C' {
                                entradasClonadas[i].ONE_Precio__c = entradasClonadas[i].ONE_Precio__c * (1 + (inputs[0].subidas[2] / 100.0));
                            }
                            when 'N' {
                                entradasClonadas[i].ONE_Precio__c = entradasClonadas[i].ONE_Precio__c * (1 + (inputs[0].subidas[3] / 100.0));
                            }
                        }
                    }
                }
                
                allOldEntradas.addAll(entradas);
                allNewEntradas.addAll(entradasClonadas);
            }
            
            update allOldEntradas;
            insert allNewEntradas;
            fo.add(new FlowOutput(true));
            
        } catch (Exception error) {
            fo.add(new FlowOutput(false));
            System.debug('Error: ' + error);
        }
		
        return fo;
	}
    
    public class FlowInput {
    	@InvocableVariable(label='catalogos')
    	public List<String> catalogos;
        
        @InvocableVariable(label='subidas A, B, C, N')
        public List<Double> subidas;
        
        @InvocableVariable(label='fechaInicio')
   		public Date fechaInicio;
	}
    
    public class FlowOutput {
        @InvocableVariable(label='success')
        public Boolean success;
        
        FlowOutput(Boolean s){
            this.success = s;
        }
    }
    
}
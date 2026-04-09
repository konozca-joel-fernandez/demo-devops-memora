public with sharing class ONE_InterlocutorHandler {
    

    public static void updateDeclarantes(Set<Id> serviciosId){

        if(serviciosId == null || serviciosId.isEmpty()){
            return;
        }

        
        List<ONE_Interlocutor__c> declarantes = [
                SELECT Name, ONE_Expediente__c 
                FROM ONE_Interlocutor__c 
                WHERE ONE_Expediente__c IN :serviciosId
                AND ONE_Declarante__c = true
        ];

        List<ONE_LineaPlanificacion__c> lineas = [
                SELECT Id, ONE_Servicio__c 
                FROM ONE_LineaPlanificacion__c 
                WHERE ONE_Servicio__c IN :serviciosId
        ];

        List<ONE_LineaPlanificacion__c> lineasAActualizar = new List<ONE_LineaPlanificacion__c>();

        for (ONE_LineaPlanificacion__c linea : lineas) {
                // Obtener los nombres de los declarantes correspondientes a esta línea
                List<String> nombres = new List<String>();
                for (ONE_Interlocutor__c declarante : declarantes) {
                    if (declarante.ONE_Expediente__c == linea.ONE_Servicio__c) {
                        nombres.add(declarante.Name);
                    }
                }
    
                // Asignar los nombres concatenados al campo de la línea
                linea.ONE_Declarantes__c = nombres.isEmpty() ? null : String.join(nombres, ', ');
                lineasAActualizar.add(linea);
        }
    
        if (!lineasAActualizar.isEmpty()) {
                update lineasAActualizar;
        }


 
     }

}
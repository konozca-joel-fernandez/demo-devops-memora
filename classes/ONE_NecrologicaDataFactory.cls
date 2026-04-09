//Class to define all the queries that will get all the apropiate data to generate the PDF
public class ONE_NecrologicaDataFactory {
    //Get all the data and store in the Data object created    
    public static ONE_NecrologicaData buildNecrologicaData( ID accountOrLugarID, String language, String level, Date startDate, Date endDate) {
        List <ONE_Expediente__c> expedientsRecord = selectDocumentosForPdfGeneration(accountOrLugarID, level, startDate, endDate);
        
        System.debug('Expedient query: ' + expedientsRecord);
        
        ONE_NecrologicaData data = new ONE_NecrologicaData(
            getDocumentCode('ONE_Solicitud_Incineracion'),
            getNombreSociedad(level,accountOrLugarID),
            expedientsRecord,
            language
        );
        
        System.debug('DATA: ' + data);
        return data;
    }   
	//Query for Expediente data based on level parameter    
    public static  List <ONE_Expediente__c> selectDocumentosForPdfGeneration( ID accountOrLugarID, String level, Date startDate, Date endDate) {
        System.debug('Expedient query parameters: ' + accountOrLugarID + level + startDate + endDate);

        List <ONE_Expediente__c> expedientData;
        
        if( level == 'centro'){ //Query for level centro
                expedientData = [        
                    SELECT 
                        ONE_Fecha_De_Defuncion__c,
                        ONE_Inicio_Ceremonia__c,
                    	ONE_Fin_Ceremonia__c,
                        ONE_Tipo_De_Lugar_De_Ceremonia__c ,
                        ONE_Direccion_Ceremonia__c ,
                        ONE_Provincia_Ceremonia__c ,
                        ONE_Municipio_Ceremonia__c,
                        ONE_Difunto__r.ONE_Edad__c,
                        ONE_Difunto__r.ONE_Estado_Civil__c,
                        ONE_Difunto__r.ONE_Conyuge__c,
                        ONE_Difunto__r.ONE_Numero_de_los_hijos__c,
                        ONE_Difunto__r.ONE_Municipio__pc,
                        ONE_Difunto__r.FirstName,
                        ONE_Difunto__r.LastName,
                        ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                    	ONE_Lugar_Ceremonia__r.Name
                    FROM 
                        ONE_Expediente__c
                    WHERE
                        ONE_Centro_Del_Expediente__c =: accountOrLugarID 
                    AND
                        ONE_Estado__c != 'Cancelado' 
                    AND
                        ONE_Publicar_en_Prensa__c = 'Si'
                    AND
                        (
                            (DAY_ONLY(ONE_Inicio_Ceremonia__c) >=: startDate AND DAY_ONLY(ONE_Fin_Ceremonia__c) <=: endDate)
                        OR
                            (DAY_ONLY(ONE_Inicio_Incineracion__c) >=: startDate AND DAY_ONLY(ONE_Fin_Incineracion__c) <=: endDate AND ONE_Inicio_Ceremonia__c = null)
                        OR
                            (DAY_ONLY(ONE_Hora_Destino_Final__c)  >=:  startDate AND DAY_ONLY(ONE_Hora_Destino_Final__c) <=:  endDate AND ONE_Inicio_Ceremonia__c = null AND ONE_Inicio_Incineracion__c = null)
                        )
                ];    
        }  if( level == 'area_operativa'){ //Quero for area_operativa level
                expedientData = [        
                    SELECT 
                        ONE_Fecha_De_Defuncion__c,
                        ONE_Inicio_Ceremonia__c,
                    	ONE_Fin_Ceremonia__c,
                        ONE_Tipo_De_Lugar_De_Ceremonia__c ,
                        ONE_Direccion_Ceremonia__c ,
                        ONE_Provincia_Ceremonia__c ,
                        ONE_Municipio_Ceremonia__c,
                        ONE_Difunto__r.ONE_Edad__c,
                        ONE_Difunto__r.ONE_Estado_Civil__c, 
                        ONE_Difunto__r.ONE_Conyuge__c,
                        ONE_Difunto__r.ONE_Numero_de_los_hijos__c,
                        ONE_Difunto__r.ONE_Municipio__pc,
                        ONE_Difunto__r.FirstName,
                        ONE_Difunto__r.LastName,
                    	ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                    	ONE_Lugar_Ceremonia__r.Name
                    FROM 
                        ONE_Expediente__c
                    WHERE
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__c =: accountOrLugarID 
                    AND
                        ONE_Estado__c != 'Cancelado' 
                    AND
                        ONE_Publicar_en_Prensa__c = 'Si'
                    AND
                        (
                            (DAY_ONLY(ONE_Inicio_Ceremonia__c) >=: startDate AND DAY_ONLY(ONE_Fin_Ceremonia__c) <=: endDate)
                        OR
                            (DAY_ONLY(ONE_Inicio_Incineracion__c) >=: startDate AND DAY_ONLY(ONE_Fin_Incineracion__c) <=: endDate AND ONE_Inicio_Ceremonia__c = null)
                        OR
                            (DAY_ONLY(ONE_Hora_Destino_Final__c)  >=:  startDate AND DAY_ONLY(ONE_Hora_Destino_Final__c) <=:  endDate AND ONE_Inicio_Ceremonia__c = null AND ONE_Inicio_Incineracion__c = null)
                        )
                ];    
        }  if( level == 'zona_operativa'){ // Query for zona_operativa level 
                expedientData = [        
                    SELECT 
                        ONE_Fecha_De_Defuncion__c,
                        ONE_Inicio_Ceremonia__c,
                    	ONE_Fin_Ceremonia__c,
                        ONE_Tipo_De_Lugar_De_Ceremonia__c ,
                        ONE_Direccion_Ceremonia__c ,
                        ONE_Provincia_Ceremonia__c ,
                        ONE_Municipio_Ceremonia__c,
                        ONE_Difunto__r.ONE_Edad__c,
                        ONE_Difunto__r.ONE_Estado_Civil__c, 
                        ONE_Difunto__r.ONE_Conyuge__c,
                        ONE_Difunto__r.ONE_Numero_de_los_hijos__c,
                        ONE_Difunto__r.ONE_Municipio__pc,
                        ONE_Difunto__r.FirstName,
                        ONE_Difunto__r.LastName,
                    	ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                    	ONE_Lugar_Ceremonia__r.Name
                    FROM 
                        ONE_Expediente__c
                    WHERE
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__c =: accountOrLugarID 
                    AND
                        ONE_Estado__c != 'Cancelado' 
					AND
                        ONE_Publicar_en_Prensa__c = 'Si'
					AND
                        (
                            (DAY_ONLY(ONE_Inicio_Ceremonia__c) >=: startDate AND DAY_ONLY(ONE_Fin_Ceremonia__c) <=: endDate)
                        OR
                            (DAY_ONLY(ONE_Inicio_Incineracion__c) >=: startDate AND DAY_ONLY(ONE_Fin_Incineracion__c) <=: endDate AND ONE_Inicio_Ceremonia__c = null)
                        OR
                            (DAY_ONLY(ONE_Hora_Destino_Final__c)  >=:  startDate AND DAY_ONLY(ONE_Hora_Destino_Final__c) <=:  endDate AND ONE_Inicio_Ceremonia__c = null AND ONE_Inicio_Incineracion__c = null)
                        )
                ];    
        }  if( level == 'delegacion'){ // Query for delegacion level
                expedientData = [        
                    SELECT 
                        ONE_Fecha_De_Defuncion__c,
                        ONE_Inicio_Ceremonia__c,
                    	ONE_Fin_Ceremonia__c,                    
                        ONE_Tipo_De_Lugar_De_Ceremonia__c ,
                        ONE_Direccion_Ceremonia__c ,
                        ONE_Provincia_Ceremonia__c ,
                        ONE_Municipio_Ceremonia__c,
                        ONE_Difunto__r.ONE_Edad__c,
                        ONE_Difunto__r.ONE_Estado_Civil__c, 
                        ONE_Difunto__r.ONE_Conyuge__c,
                        ONE_Difunto__r.ONE_Numero_de_los_hijos__c,
                        ONE_Difunto__r.ONE_Municipio__pc,
                        ONE_Difunto__r.FirstName,
                        ONE_Difunto__r.LastName,
                    	ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                    	ONE_Lugar_Ceremonia__r.Name
                    FROM 
                        ONE_Expediente__c
                    WHERE
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =: accountOrLugarID 
                    AND
                        ONE_Estado__c != 'Cancelado' 
                    AND
                        ONE_Publicar_en_Prensa__c = 'Si'
                    AND
                        (
                            (DAY_ONLY(ONE_Inicio_Ceremonia__c) >=: startDate AND DAY_ONLY(ONE_Fin_Ceremonia__c) <=: endDate)
                        OR
                            (DAY_ONLY(ONE_Inicio_Incineracion__c) >=: startDate AND DAY_ONLY(ONE_Fin_Incineracion__c) <=: endDate AND ONE_Inicio_Ceremonia__c = null)
                        OR
                            (DAY_ONLY(ONE_Hora_Destino_Final__c)  >=:  startDate AND DAY_ONLY(ONE_Hora_Destino_Final__c) <=:  endDate AND ONE_Inicio_Ceremonia__c = null AND ONE_Inicio_Incineracion__c = null)
                        )
                ];    
        }  if( level == 'ambito'){ // Query for ambito level
               expedientData = [        
                    SELECT 
                        ONE_Fecha_De_Defuncion__c,
                        ONE_Inicio_Ceremonia__c,
                    	ONE_Fin_Ceremonia__c,                   
                        ONE_Tipo_De_Lugar_De_Ceremonia__c ,
                        ONE_Direccion_Ceremonia__c ,
                        ONE_Provincia_Ceremonia__c ,
                        ONE_Municipio_Ceremonia__c,
                        ONE_Difunto__r.ONE_Edad__c,
                        ONE_Difunto__r.ONE_Estado_Civil__c, 
                        ONE_Difunto__r.ONE_Conyuge__c,
                        ONE_Difunto__r.ONE_Numero_de_los_hijos__c,
                        ONE_Difunto__r.ONE_Municipio__pc,
                        ONE_Difunto__r.FirstName,
                        ONE_Difunto__r.LastName,
                   		ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                   		ONE_Lugar_Ceremonia__r.Name

                    FROM 
                        ONE_Expediente__c
                    WHERE
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__r.ONE_Lugar_Superior__c =: accountOrLugarID 
                    AND
                        ONE_Estado__c != 'Cancelado' 
                    AND
                        ONE_Publicar_en_Prensa__c = 'Si'
                    AND
                        (
                            (DAY_ONLY(ONE_Inicio_Ceremonia__c) >=: startDate AND DAY_ONLY(ONE_Fin_Ceremonia__c) <=: endDate)
                        OR
                            (DAY_ONLY(ONE_Inicio_Incineracion__c) >=: startDate AND DAY_ONLY(ONE_Fin_Incineracion__c) <=: endDate AND ONE_Inicio_Ceremonia__c = null)
                        OR
                            (DAY_ONLY(ONE_Hora_Destino_Final__c)  >=:  startDate AND DAY_ONLY(ONE_Hora_Destino_Final__c) <=:  endDate AND ONE_Inicio_Ceremonia__c = null AND ONE_Inicio_Incineracion__c = null)
                        )
                ];    
        }

        
        return expedientData ;
    }
        
    //Query document code from a custom metada type to display it in the PDF header    
    private static String getDocumentCode(String mtName) {
        return [
            SELECT Label
            FROM ONE_Codigo_de_documento__mdt
            WHERE DeveloperName = :mtName
        ].Label;
    }
    
    //Query for name to display acording to the level
    private static String getNombreSociedad(String level, ID accountOrLugarID) {
        
		ONE_Lugar__c lugar;
        Account centro;  
        System.debug('level-->' + level);
        System.debug('accountOrLugarID-->' + accountOrLugarID);
        
        if(level == 'centro'){
            centro = [SELECT name from Account where id =: accountOrLugarID Limit 1];
        	return centro.name;            
        }

        else{
            lugar = [SELECT  name, toLabel(ONE_Nivel_Jerarquico__c) from ONE_Lugar__c where id =: accountOrLugarID Limit 1];
            return lugar.ONE_Nivel_Jerarquico__c + ' - ' + lugar.name;            
        }

    }

}
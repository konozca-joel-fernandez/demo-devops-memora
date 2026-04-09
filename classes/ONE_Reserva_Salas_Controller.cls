public class ONE_Reserva_Salas_Controller {
    //Lookup
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5    
        String sQuery;
        //if(recordType != null)
        //     sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey and RecordTypeId = '+'"0125r00000006URAAY"'+' order by createdDate DESC limit 5';
        //else
        if(ObjectName == 'centro') //RecordType.Name
        	sQuery =  'select id, Name from ' +'Account' + ' where Name LIKE: searchKey and RecordType.Name = \'Centro Mémora\'' +' order by createdDate DESC limit 5';
        else if(ObjectName == 'lugar')
            sQuery =  'select id, Name from ' +'ONE_Lugar__c' + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
            
        system.debug('sQuery-->' + sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        system.debug('lstOfRecords-->' + lstOfRecords);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static void updateComponent(String centerName, ID centerID) {
        system.debug('centerNAme-->' + centerNAme + ' centerID-->' + centerID);
        
        //ONE_Consulta_Reseva_Salas reserva = new ONE_Consulta_Reseva_Salas(centerID);

    }
}
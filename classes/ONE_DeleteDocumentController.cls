public without sharing class ONE_DeleteDocumentController {
    @AuraEnabled
    public static String deleteDocument (String recordId){
        try{
            ContentDocument doc =[SELECT Id, OwnerId FROM ContentDocument Where Id=:recordId];
            delete doc; 
        }catch(Exception e){
            System.debug('ERROR'+e);
            return 'NOK';
        }
       return 'OK';
    }
}
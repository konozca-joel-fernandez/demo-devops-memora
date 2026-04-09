public with sharing class ONE_CreateInterlocutorFormController {

    @AuraEnabled
    public static String fetchRecordTypes() {
        List<RecordTypeWrapper> rtWrappers = new List<RecordTypeWrapper>();
        for(RecordType rt : [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType =: ONE_CommonConstants.INTERLOCUTOR
        ]) {
            rtWrappers.add(new RecordTypeWrapper(rt.Id, rt.Name));
        }
        return JSON.serialize(rtwrappers);
    }

    public class RecordTypeWrapper {
        String id;
        String label;
        Boolean selected;
        public RecordTypeWrapper(String id, String label) {
            this.id = id;
            this.label = label;
            this.selected = false;
        }
    }

}
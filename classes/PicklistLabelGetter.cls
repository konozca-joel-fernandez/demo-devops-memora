public with sharing class PicklistLabelGetter {

    public virtual class FlowInput {
        @InvocableVariable
        public String objectName;
        @InvocableVariable
        public String fieldName;
        @InvocableVariable
        public String picklistValue;
    }

    @InvocableMethod
    public static List<String> getPicklistLabel(List<FlowInput> parameters) {

        String objectName = parameters[0].objectName;
        String fieldName = parameters[0].fieldName;
        String picklistValue = parameters[0].picklistValue;
        String picklistLabel = '';
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry ple : ples) {
            if (ple.getValue() == picklistValue) {
                picklistLabel = ple.getLabel();
            }
        }
        return new List<String> { picklistLabel };
    }
}
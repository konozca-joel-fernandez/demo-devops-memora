public without sharing class ONE_DateValueGetter {

    public virtual class FlowInput {
        @InvocableVariable
        public Datetime datetimeValue;
    }
    
    public class FlowOutput {
        @InvocableVariable
        public String day;
        @InvocableVariable
        public String month;
        @InvocableVariable
        public String year;
    }

    @InvocableMethod
    public static List<FlowOutput> getDateValue(List<FlowInput> parameters) {

        Datetime datetimeValue = parameters[0].datetimeValue;

        FlowOutput outputParameters = new FlowOutput();
        outputParameters.day = String.valueOf(datetimeValue.day());
        outputParameters.month = String.valueOf(datetimeValue.month());
        outputParameters.year = String.valueOf(datetimeValue.year());
        
        return new List<FlowOutput> { outputParameters };
    }
}
public without sharing class MinimumDateGetter {

    public virtual class FlowInput {
        @InvocableVariable
        public String dates;
    }
    
    public class FlowOutput {
        @InvocableVariable
        public String minimumDate;
    }

    @InvocableMethod
    public static List<FlowOutput> getMinimumDate(List<FlowInput> parameters) {

        String dates = parameters[0].dates;
        String minimumDate = '';

        List<String> dateStringList = dates.split(';');
        List<DateTime> dateList = new List<DateTime>();
        for (String dateString : dateStringList) {
            if (String.isNotBlank(dateString)) {
                DateTime dateValue = DateTime.valueOfGmt(dateString);
                dateList.add(dateValue);
            }
        }
        if(!dateList.isEmpty()) {
            dateList.sort();
            minimumDate = dateList.get(0).format();
        }
        
        FlowOutput outputParameters = new FlowOutput();
        outputParameters.minimumDate = minimumDate;
        
        return new List<FlowOutput> { outputParameters };
    }
}
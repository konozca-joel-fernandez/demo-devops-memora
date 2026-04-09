public without sharing class LastNameSeparator {

    public virtual class FlowInput {
        @InvocableVariable
        public String lastName;
    }
    
    public class FlowOutput {
        @InvocableVariable
        public String lastName1;
        @InvocableVariable
        public String lastName2;
    }

    @InvocableMethod
    public static List<FlowOutput> getLastNames(List<FlowInput> parameters) {

        String lastName = parameters[0].lastName;
        String lastName1 = '';
        String lastName2 = '';

        if (lastName.length() > 35) {
            lastName1 = lastName.substring(0, lastName.lastIndexOf(' ', 35));
            lastName2 = lastName.substring(lastName.lastIndexOf(' ', 35) + 1);
        }
        else {
            lastName1 = lastName;
        }
        
        FlowOutput outputParameters = new FlowOutput();
        outputParameters.lastName1 = lastName1;
        outputParameters.lastName2 = lastName2;
        
        return new List<FlowOutput> { outputParameters };
    }
}
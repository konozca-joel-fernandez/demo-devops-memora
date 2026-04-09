public with sharing class ONE_SplitString {

    public class StringInput {
        @InvocableVariable
        public String inputString;
    }

    public class StringOutput {
        @InvocableVariable
        public List<String> outputStrings;

        public StringOutput(List<String> outputStrings) {
            this.outputStrings = outputStrings;
        }
    }

    @InvocableMethod
    public static List<StringOutput> splitString(List<StringInput> inputs) {
        List<StringOutput> outputs = new List<StringOutput>();

        for (StringInput input : inputs) {
            if (input.inputString != null) {
                
                String cleanedInput = input.inputString.replace('[', '').replace(']', '').trim();
                
                
                List<String> splitStrings = cleanedInput.split(';');

                outputs.add(new StringOutput(splitStrings));
            } else {
                outputs.add(new StringOutput(new List<String>()));
            }
        }

        return outputs;
    }
}
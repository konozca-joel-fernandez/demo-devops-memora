public class ONE_MassUpdateCataloguePriceEntry {

    @InvocableMethod
    public static List<FlowOutputs> updateCataloguePriceEntry(List<FlowInputs> inputsList) {
        FlowOutputs fo = new FlowOutputs();
        fo.message = '';

        try {
            Database.executeBatch(new ONE_MassUpdateCataloguePriceEntryBatch(inputsList), 100);
        } catch (Exception ex) {
            fo.message = String.valueOf(ex);
        }

        List<FlowOutputs> outputs = new List<FlowOutputs>{fo};
        return outputs;
    }
	//Flow input variable definition
    public class FlowInputs {
        @InvocableVariable
        public String catalogueId;
        @InvocableVariable
        public Decimal percentA;
        @InvocableVariable
        public Decimal percentB;
        @InvocableVariable
        public Decimal percentC;
        @InvocableVariable
        public Decimal percentN;
        @InvocableVariable
        public Date vigenteHastaDate;
    }
	//Flow oup variable definition
    public class FlowOutputs {
        @InvocableVariable
        public String message;
    }

}
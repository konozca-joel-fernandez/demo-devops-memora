@isTest
public class PicklistLabelGetterTest {

    @isTest
    private static void getPicklistLabelProvincia() {
        
        Test.startTest();
        PicklistLabelGetter.FlowInput input = new PicklistLabelGetter.FlowInput();
        input.objectName = 'Account';
        input.fieldName = 'ONE_Provincia__pc';
        input.picklistValue = '28';
        List<PicklistLabelGetter.FlowInput> inputs = new List<PicklistLabelGetter.FlowInput>{input};
        List<String> outputs = PicklistLabelGetter.getPicklistLabel(inputs); 
        Test.stopTest();

        System.assertEquals('Madrid', outputs[0]);
    }
}
@isTest
public class MinimumDateGetterTest {

    @isTest
    private static void getMinimumDate() {
        
        Test.startTest();
        MinimumDateGetter.FlowInput input = new MinimumDateGetter.FlowInput();
        input.dates = '2021-11-08 14:00:00;2021-11-06 14:00:00;2021-11-08 13:00:00';
        List<MinimumDateGetter.FlowInput> inputs = new List<MinimumDateGetter.FlowInput>{input};
        List<MinimumDateGetter.FlowOutput> outputs = MinimumDateGetter.getMinimumDate(inputs); 
        Test.stopTest();

        System.assertEquals(DateTime.valueOfGmt('2021-11-06 14:00:00').format(), outputs[0].minimumDate);
    }
}
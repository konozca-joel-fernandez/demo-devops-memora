@isTest
public class ONE_DateValueGetterTest {

    @isTest
    private static void getDateValue() {
        
        Test.startTest();
        ONE_DateValueGetter.FlowInput input = new ONE_DateValueGetter.FlowInput();
        input.datetimeValue = Datetime.now();
        List<ONE_DateValueGetter.FlowInput> inputs = new List<ONE_DateValueGetter.FlowInput>{input};
        List<ONE_DateValueGetter.FlowOutput> outputs = ONE_DateValueGetter.getDateValue(inputs); 
        Test.stopTest();
    }
}
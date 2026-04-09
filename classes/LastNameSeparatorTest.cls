@isTest
public class LastNameSeparatorTest {

    @isTest
    private static void getLastNames() {
        
        Test.startTest();
        LastNameSeparator.FlowInput input = new LastNameSeparator.FlowInput();
        input.lastName = 'Vidal-Abarca Espinosa de los Monteros';
        List<LastNameSeparator.FlowInput> inputs = new List<LastNameSeparator.FlowInput>{input};
        List<LastNameSeparator.FlowOutput> outputs = LastNameSeparator.getLastNames(inputs); 
        Test.stopTest();

        System.assertEquals('Vidal-Abarca Espinosa de los', outputs[0].lastName1);
        System.assertEquals('Monteros', outputs[0].lastName2);
    }
}
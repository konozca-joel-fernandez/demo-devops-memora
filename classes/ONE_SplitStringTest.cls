@isTest
private class ONE_SplitStringTest {

    @isTest
    static void testSplitStringWithValidInput() {
        // Arrange
        ONE_SplitString.StringInput input = new ONE_SplitString.StringInput();
        input.inputString = '[value1;value2;value3]';

        List<ONE_SplitString.StringInput> inputs = new List<ONE_SplitString.StringInput>{ input };

        // Act
        List<ONE_SplitString.StringOutput> results = ONE_SplitString.splitString(inputs);

        // Assert
        System.assertEquals(1, results.size(), 'Debe haber un solo resultado');
        System.assertEquals(3, results[0].outputStrings.size(), 'Debe dividirse en tres elementos');
        System.assertEquals('value1', results[0].outputStrings[0]);
        System.assertEquals('value2', results[0].outputStrings[1]);
        System.assertEquals('value3', results[0].outputStrings[2]);
    }

    @isTest
    static void testSplitStringWithEmptyInput() {
        // Arrange
        ONE_SplitString.StringInput input = new ONE_SplitString.StringInput();
        input.inputString = '[]';

        List<ONE_SplitString.StringInput> inputs = new List<ONE_SplitString.StringInput>{ input };

        // Act
        List<ONE_SplitString.StringOutput> results = ONE_SplitString.splitString(inputs);

        // Assert
        System.assertEquals(1, results.size(), 'Debe haber un solo resultado');
        System.assertEquals(1, results[0].outputStrings.size(), 'Debe haber un elemento vacío');
        System.assertEquals('', results[0].outputStrings[0]);
    }

    @isTest
    static void testSplitStringWithNullInput() {
        // Arrange
        ONE_SplitString.StringInput input = new ONE_SplitString.StringInput();
        input.inputString = null;

        List<ONE_SplitString.StringInput> inputs = new List<ONE_SplitString.StringInput>{ input };

        // Act
        List<ONE_SplitString.StringOutput> results = ONE_SplitString.splitString(inputs);

        // Assert
        System.assertEquals(1, results.size(), 'Debe haber un solo resultado');
        System.assertEquals(0, results[0].outputStrings.size(), 'Debe estar vacío');
    }
}
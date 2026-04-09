@isTest
public class RemoveHTMLMarkupTest {

    @isTest
    static void testStripHtml() {
        // Test case 1: Test with valid rich text content
        List<String> richTexts = new List<String>{
            '<p>This is <b>bold</b> and <i>italic</i></p>',
            '<div>Another <a href="https://example.com">link</a></div>',
            'No HTML here'
        };

        // Calling the Invocable methods
        List<String> result = RemoveHTMLMarkup.stripHtml(richTexts);

        // Assert that the HTML tags are removed
        System.assertEquals('This is bold and italic', result[0], 'First text should have no HTML tags');
        System.assertEquals('Another link', result[1], 'Second text should have no HTML tags');
        System.assertEquals('No HTML here', result[2], 'Third text should remain unchanged');

        // Test case 2: Test with null value
        richTexts = new List<String>{null};
        result = RemoveHTMLMarkup.stripHtml(richTexts);

        // Assert that the result is an empty string for null input
        System.assertEquals('', result[0], 'Null input should return an empty string');
    }

}
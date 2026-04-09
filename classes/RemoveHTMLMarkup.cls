public class RemoveHTMLMarkup {

    @InvocableMethod(label='Remove HTML from Rich Text' description='Removes HTML tags from a given Rich Text field')
    public static List<String> stripHtml(List<String> richTexts) {
        List<String> textContent = new List<String>();
        for (String richText : richTexts) {
            if (richText == null) {
                textContent.add('');
            } else {
                textContent.add(richText.stripHtmlTags()); // Remove all HTML tags
            }
        }
        return textContent;
    }

}
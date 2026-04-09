public with sharing class TextGalleryController  {

    public class Text {

        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String num { get; set; }
        @AuraEnabled
        public String body { get; set; }

        public Text(String id, String num, String body) {
            this.id = id;
            this.num = num;
            this.body = body;
        }
    }

    @AuraEnabled
    public static List<Text> getTexts(String language, String fieldName) {

        List<Text> textList = new List<Text>();

        for (TextoRecordatorio__mdt texto : [SELECT DeveloperName, Numero__c, Texto__c FROM TextoRecordatorio__mdt WHERE FieldName__c = :fieldName AND Language__c = :language ORDER BY Numero__c ASC]) {
            textList.add(new Text(texto.DeveloperName, String.valueOf(texto.Numero__c.intValue()), texto.Texto__c));
        }

        return textList;
    }
    
}
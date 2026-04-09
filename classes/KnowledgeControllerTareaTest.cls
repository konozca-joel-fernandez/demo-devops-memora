@IsTest(seeAllData=true)

public class KnowledgeControllerTareaTest {

    @IsTest

    static void testFindArticlesForTarea() {

        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c LIMIT 1]; 



        Test.startTest();

        List<KnowledgeLWCController.ArticleDTO> results = KnowledgeLWCController.findArticles(

            tarea.Id, 'ONE_Tarea__c', null, 5, 'Hospital'

        );

        Test.stopTest();



        //System.assertNotEquals(0, results.size(), 'Debe devolver artículos relacionados con Tarea');

    }

}
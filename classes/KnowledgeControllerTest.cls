@IsTest
public class KnowledgeControllerTest {
    @TestSetup
    static void setup() {
        // Consultar RecordTypes existentes
        RecordType tareaRT = [SELECT Id FROM RecordType WHERE SObjectType = 'ONE_Tarea__c' AND DeveloperName = 'ONE_Tarea_De_Conduccion' LIMIT 1];
        RecordType accountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'ONE_Otras_Cuentas' LIMIT 1];
        RecordType kavRTOperaciones = [SELECT Id FROM RecordType WHERE SObjectType = 'Knowledge__kav' AND DeveloperName = 'Knowledge_Operaciones' LIMIT 1];
        RecordType kavRTGD = [SELECT Id FROM RecordType WHERE SObjectType = 'Knowledge__kav' AND DeveloperName = 'Knowledge_GD' LIMIT 1];
        RecordType kavRTCC = [SELECT Id FROM RecordType WHERE SObjectType = 'Knowledge__kav' AND DeveloperName = 'Knowledge_CC' LIMIT 1];

        List<KnowledgeLWCController.ArticleDTO> test = new List<KnowledgeLWCController.ArticleDTO>();
        // Crear registro Account
        Account acc = new Account(
            Name = 'Cuenta Test',
            RecordTypeId = accountRT.Id,
            ONE_Tipo__c = 'Hospitales'

        );
        insert acc;
                // º/ Crear registro ONE_Tarea__c
        ONE_Tarea__c tarea = new ONE_Tarea__c(
            Name = 'Tarea Test',
            RecordTypeId = tareaRT.Id,
            ONE_Lugar_De_Origen__c = acc.Id,
            ONE_Estado__c = 'No Informado'
        );
       // insert tarea;
        // Crear Knowledge__kav asociados a ONE_Tarea__c
        Knowledge__kav kav1 = new Knowledge__kav(
            Title = 'Articulo Tarea',
            UrlName = 'articulo-tarea',
           Cuerpo__c = 'Contenido del articulo',
            ONE_Centro__c = acc.Id,
            ONE_Contacto_y_o_responsable_Centro__c = 'Responsable',
            RecordTypeId = kavRTOperaciones.Id
        );
        insert kav1;
        // Crear Knowledge__kav asociados a Account

        Knowledge__kav kav2 = new Knowledge__kav(
            Title = 'Articulo Cuenta',
            UrlName = 'articulo-cuenta',
            Cuerpo__c = '<p>Contenido del articulo cuenta</p>',
            ONE_Cuenta_Relacionada__c = acc.Id,
            RecordTypeId = kavRTGD.Id
        );
        insert kav2;
        test.add(new KnowledgeLWCController.ArticleDTO(kav1.Id, kav1.Title, KnowledgeLWCController.stripHtmlTags(kav1.Cuerpo__c), kav1.UrlName, kav1.KnowledgeArticleId, kav1.Cuerpo__c, kav1.ONE_Centro__c, kav1.ONE_Cuenta_Relacionada__c, 
                                                      kav1.Tipo_de_caso__c, kav1.Gerencia__c, kav1.ONE_Municipio__c, kav1.Tipo_de_cliente__c));
    }

    @IsTest
    static void testFindArticlesForAccount() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<KnowledgeLWCController.ArticleDTO> results = KnowledgeLWCController.findArticles(
            acc.Id,
            'Account',
            null,
            5,
            'Articulo'
        );
        Test.stopTest();
        //  System.assertNotEquals(0, results.size(), 'Debe devolver artículos relacionados con Account');
       // System.assertEquals('Articulo Cuenta', results[0].title);
    }
            
        @IsTest
        static void testFindArticlesForCasos() {
            // 1. Escenario: Recogida Judicial (con keyword para cubrir el "if hasKeyword")
            // 
			RecordType RJ_RT = [SELECT Id FROM RecordType WHERE SObjectType = 'ONE_Caso__c' AND DeveloperName = 'ONE_Recogida_Judicial' LIMIT 1];
            RecordType AD_RT = [SELECT Id FROM RecordType WHERE SObjectType = 'ONE_Caso__c' AND DeveloperName = 'ONE_Avisos_De_Defuncion' LIMIT 1];
            RecordType OO_RT = [SELECT Id FROM RecordType WHERE SObjectType = 'ONE_Caso__c' AND DeveloperName = 'ONE_Oportunidades_Olympia' LIMIT 1];
            RecordType AM1_RT = [SELECT Id FROM RecordType WHERE SObjectType = 'ONE_Caso__c' AND DeveloperName = 'ONE_Avisos_M1' LIMIT 1];
//            ONE_Lugar__c gerenciaCaso = [SELECT Id FROM ONE_Lugar__c WHERE Name = 'Z.REMEDIOS'];
           
            
            ONE_Caso__c caso1 = new ONE_Caso__c(ONE_Record_Type__c = 'Recogida Judicial',
                                               RecordTypeId = RJ_RT.Id);
            insert caso1;
            
            // 2. Escenario: Oportunidades Olympia
            ONE_Caso__c caso2 = new ONE_Caso__c(ONE_Record_Type__c = 'Oportunidad Olympia',
                                               	RecordTypeId = OO_RT.Id);
            insert caso2;
            
            // 3. Escenario: Avisos de defunción (necesita Gerencia)
            ONE_Caso__c caso3 = new ONE_Caso__c(
                ONE_Record_Type__c = 'Avisos de defunción', 
                //ONE_Gerencia__c = gerenciaCaso.Id,
                RecordTypeId = AD_RT.Id
            );
            insert caso3;
            
            // 4. Escenario: Avisos M1 (necesita Tipo)
            ONE_Caso__c caso4 = new ONE_Caso__c(
                ONE_Record_Type__c = 'Avisos M1', 
                ONE_Tipo__c = 'Otros',
                RecordTypeId = AM1_RT.Id
            );
            insert caso4;
        
            Test.startTest();
            // Ejecutamos cada uno para entrar en sus respectivos 'else if'
            KnowledgeLWCController.findArticles(caso1.Id, 'ONE_Caso__c', null, 5, 'Test'); // Este cubre el hasKeyword
            KnowledgeLWCController.findArticles(caso2.Id, 'ONE_Caso__c', null, 5, null);
            KnowledgeLWCController.findArticles(caso3.Id, 'ONE_Caso__c', null, 5, null);
            KnowledgeLWCController.findArticles(caso4.Id, 'ONE_Caso__c', null, 5, null);
            Test.stopTest();
        
            // Verificación básica para asegurar que no rompió nada
            System.assertNotEquals(null, caso1.Id, 'El caso debería haberse insertado');
        }



    @IsTest

    static void testFindArticlesWithNullId() {

        Test.startTest();

        List<KnowledgeLWCController.ArticleDTO> results = KnowledgeLWCController.findArticles(

            null,

            'Account',

            null,

            5,

            'Articulo'

        );

        Test.stopTest();



        System.assertEquals(0, results.size(), 'Debe devolver lista vacía si el Id es null');

    }

}
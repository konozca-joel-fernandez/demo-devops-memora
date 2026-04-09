public with sharing class KnowledgeLWCController {
    public class ArticleDTO {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String title;
        @AuraEnabled public String summary;
        @AuraEnabled public String urlName;
        @AuraEnabled public String knowledgeArticleId;
        @AuraEnabled public String cuerpo;
        @AuraEnabled public String ONE_Centro;
        @AuraEnabled public String ONE_Cuenta_Relacionada;
        @AuraEnabled public String ONE_TipoCaso;
        @AuraEnabled public String ONE_Gerencia;
        @AuraEnabled public String ONE_Municipio;
        @AuraEnabled public String ONE_TipoCliente;

        public ArticleDTO(Id recordId, String title, String summary, String urlName, String knowledgeArticleId, String cuerpo, String ONE_Centro, String ONE_Cuenta_Relacionada,
                         String ONE_TipoCaso, String ONE_Gerencia, String ONE_Municipio, String ONE_TipoCliente) {
            this.recordId = recordId;
            this.title = title;
            this.summary = summary;
            this.urlName = urlName;
            this.knowledgeArticleId = knowledgeArticleId;
            this.cuerpo = cuerpo;
            this.ONE_Centro = ONE_Centro;
            this.ONE_Cuenta_Relacionada = ONE_Cuenta_Relacionada;
            this.ONE_TipoCaso = ONE_TipoCaso;
            this.ONE_Gerencia = ONE_Gerencia;
            this.ONE_Municipio = ONE_Municipio;
            this.ONE_TipoCliente = ONE_TipoCliente;
        }
    }
   
    public static String stripHtmlTags(String html) {
            return html != null ? html.replaceAll('<[^>]+>', '') : '';
    }


    @AuraEnabled(cacheable=true)
    public static List<ArticleDTO> findArticles(Id recordId, String objectApiName, String filterField, Integer maxResults, String keyword) {
        if (recordId == null) return new List<ArticleDTO>();
        if (maxResults == null) maxResults = 5;

        Boolean hasKeyword = keyword != null && keyword.trim().length() > 0;
        String keywordFilter = hasKeyword ? '%' + keyword + '%' : null;


        List<Knowledge__kav> kav = new List<Knowledge__kav>();
        if(objectApiName == 'ONE_Tarea__c'){

            ONE_Tarea__c tareaRecord = [SELECT RecordType.DeveloperName, 
                                                ONE_Lugar_De_Origen__c 
                                                FROM ONE_Tarea__c WHERE Id =: recordId LIMIT 1];
            if(tareaRecord.recordtype.DeveloperName == 'ONE_Tarea_De_Conduccion'){
        
                Id lugarDeRecogida = tareaRecord.ONE_Lugar_De_Origen__c;
        
                String baseQuery = 
                    'SELECT Id, KnowledgeArticleId, Title, UrlName, Cuerpo__c, ONE_Centro__c, ONE_Contacto_y_o_responsable_Centro__c, ONE_Cuenta_Relacionada__c, ' +
                    'Tipo_de_caso__c, Gerencia__c, ONE_Municipio__c, Tipo_de_cliente__c ' +
                    'FROM Knowledge__kav ' +
                    'WHERE PublishStatus = \'Online\' ' +
                    'AND ONE_Centro__c = :lugarDeRecogida ' +
                    'AND RecordType.DeveloperName = \'Knowledge_Operaciones\' ';
        
        
                if (hasKeyword) {
                    baseQuery += 
                        'AND (Title LIKE :keywordFilter OR ONE_Contacto_y_o_responsable_Centro__c LIKE :keywordFilter ' +
                        'OR ONE_Tipo_de_proceso__c LIKE :keywordFilter) ';
                }
        
                baseQuery += 'ORDER BY LastPublishedDate DESC';
        
                kav = Database.query(baseQuery);
            }
        }else if(objectApiName == 'Account'){
            Account accRecord = [SELECT Id, Name, RecordType.DeveloperName  FROM Account WHERE Id =: recordId LIMIT 1];
           

            if(accRecord.recordtype.DeveloperName == 'ONE_Otras_Cuentas'){
                String cuentaVinculada = accRecord.Id;
                
                
                String baseQuery = 
                        'SELECT Id, KnowledgeArticleId, Title, UrlName, Cuerpo__c, ONE_Cuenta_Relacionada__c, ONE_Gestor_de_desarrollo__c, ONE_Centro__c, ' +
                    	'Tipo_de_caso__c, Gerencia__c, ONE_Municipio__c, Tipo_de_cliente__c ' +
                        'FROM Knowledge__kav ' +
                        'WHERE PublishStatus = \'Online\' ' +
                        'AND (ONE_Cuenta_Relacionada__c = :cuentaVinculada OR ONE_Centro__c =: cuentaVinculada) ' +
                        'AND (recordType.DeveloperName = \'Knowledge_GD\' OR recordType.DeveloperName = \'Knowledge_Operaciones\' ) ';
                    
                    if (hasKeyword) {
                        baseQuery += 'AND (Title LIKE :keywordFilter OR ONE_Gestor_de_desarrollo__c LIKE :keywordFilter) ';
                    }
                    
                    baseQuery += 'ORDER BY LastPublishedDate DESC';
                    
                    kav = Database.query(baseQuery);

            }
        }else if(objectApiName == 'ONE_Caso__c'){
            ONE_Caso__c caso = [SELECT Id, ONE_Record_Type__c, ONE_Gerencia__c, ONE_Municipio__c, ONE_Tipo__c, RecordType.DeveloperName FROM ONE_Caso__c WHERE Id=:recordId];
            
            if(caso.ONE_Record_Type__c == 'Recogida Judicial'){
                
                String baseQuery = 
                    'SELECT Id, KnowledgeArticleId, Title, UrlName, Cuerpo__c, ONE_Cuenta_Relacionada__c, ONE_Gestor_de_desarrollo__c, ONE_Centro__c, ' + 
                    'Tipo_de_caso__c, Gerencia__c, ONE_Municipio__c, Tipo_de_cliente__c ' +
                    'FROM Knowledge__kav ' +
                    'WHERE PublishStatus = \'Online\' ' +
                    'AND (Tipo_de_caso__c = \'Recogida Judicial\') ' +
                    'AND (recordType.DeveloperName = \'Knowledge_CC\') ';
                
                if (hasKeyword) {
                    baseQuery += 'AND (Title LIKE :keywordFilter OR Tipo_de_caso__c LIKE :keywordFilter) ';
                }
                
                baseQuery += 'ORDER BY LastPublishedDate DESC';
                
                kav = Database.query(baseQuery);
                
                
            }else if(caso.ONE_Record_Type__c == 'Oportunidades Olympia'){
                 
                
                 String baseQuery = 
                    'SELECT Id, KnowledgeArticleId, Title, UrlName, Cuerpo__c, ONE_Cuenta_Relacionada__c, ONE_Gestor_de_desarrollo__c, ONE_Centro__c, ' +
                    'Tipo_de_caso__c, Gerencia__c, ONE_Municipio__c, Tipo_de_cliente__c ' +
                    'FROM Knowledge__kav ' +
                    'WHERE PublishStatus = \'Online\' ' +
                    'AND (Tipo_de_caso__c = \'Oportunidad Olympia\') ' +
                    'AND (recordType.DeveloperName = \'Knowledge_CC\') ';
                
                if (hasKeyword) {
                    baseQuery += 'AND (Title LIKE :keywordFilter OR Tipo_de_caso__c LIKE :keywordFilter) ';
                }
                
                baseQuery += 'ORDER BY LastPublishedDate DESC';
                
                kav = Database.query(baseQuery);
                
            }else if(caso.ONE_Record_Type__c == 'Avisos de defunción'){
                String gerenciaCaso = caso.ONE_Gerencia__c;
                
                String baseQuery = 
                    'SELECT Id, KnowledgeArticleId, Title, UrlName, Cuerpo__c, ONE_Cuenta_Relacionada__c, ONE_Gestor_de_desarrollo__c, ONE_Centro__c, ' +
                    'Tipo_de_caso__c, Gerencia__c, ONE_Municipio__c, Tipo_de_cliente__c ' +
                    'FROM Knowledge__kav ' +
                    'WHERE PublishStatus = \'Online\' ' +
                    'AND (Tipo_de_caso__c = \'Aviso de defunción\') ' +
                    'AND (Gerencia__c=:gerenciaCaso OR Gerencia__c = NULL) ' +
                    'AND (recordType.DeveloperName = \'Knowledge_CC\') ';
                
                if (hasKeyword) {
                    baseQuery += 'AND (Title LIKE :keywordFilter OR Tipo_de_caso__c LIKE :keywordFilter) ';
                }
                
                baseQuery += 'ORDER BY LastPublishedDate DESC';
                
                kav = Database.query(baseQuery);
                
                
                
            }else if(caso.ONE_Record_Type__c == 'Avisos M1'){
                String tipoCliente = caso.ONE_Tipo__c;
                
                String baseQuery = 
                    'SELECT Id, KnowledgeArticleId, Title, UrlName, Cuerpo__c, ONE_Cuenta_Relacionada__c, ONE_Gestor_de_desarrollo__c, ONE_Centro__c, ' +
                    'Tipo_de_caso__c, Gerencia__c, ONE_Municipio__c, Tipo_de_cliente__c ' +
                    'FROM Knowledge__kav ' +
                    'WHERE PublishStatus = \'Online\' ' +
                    'AND (Tipo_de_caso__c = \'Aviso M1\') ' +
                    'AND Tipo_de_cliente__c=:tipoCliente ' +
                    'AND (recordType.DeveloperName = \'Knowledge_CC\') ';
                
                if (hasKeyword) {
                    baseQuery += 'AND (Title LIKE :keywordFilter OR Tipo_de_caso__c LIKE :keywordFilter) ';
                }
                
                baseQuery += 'ORDER BY LastPublishedDate DESC';
                
                kav = Database.query(baseQuery);
                
            }
            
            
        }
        
        List<ArticleDTO> out = new List<ArticleDTO>();
        for (Knowledge__kav k : kav) {
            out.add(new ArticleDTO(k.Id, k.Title,  stripHtmlTags(k.Cuerpo__c), k.UrlName, k.KnowledgeArticleId, k.Cuerpo__c, k.ONE_Centro__c, k.ONE_Cuenta_Relacionada__c,
                                  k.Tipo_de_caso__c, k.Gerencia__c, k.ONE_Municipio__c, k.Tipo_de_cliente__c));
        }
        return out;
    }
}
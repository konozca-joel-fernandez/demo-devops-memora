public without sharing class PdfDocumentController {

    public Id documentoId {public get; private set;}
    public String language {public get; private set;}
    public String documentoRecordTypeName {public get; private set;}
    public String html {public get; private set;}
    public static List<MomentoDoc010> momentosDoc010 {public get; public set;}
    
    public class MomentoDoc010 {
		public String name {public get; public set;}
        public List<ProductDoc010> products {public get; public set;}
        
        public MomentoDoc010(String name, List<ProductDoc010> products) {
            this.name = name;
            this.products = products;
        }
    }

    public class ProductDoc010 {
		public Integer quantity {public get; public set;}
        public String name {public get; public set;}
        public String observations {public get; public set;}
        
        public ProductDoc010(Integer quantity, String name, String observations) {
            this.quantity = quantity;
            this.name = name;
            this.observations = observations;
        }
    }
    
    public PdfDocumentController() {
        documentoId = ApexPages.currentPage().getParameters().get('documentoId').escapeHtml4();
        language = ApexPages.currentPage().getParameters().get('language').escapeHtml4();
        documentoRecordTypeName = ApexPages.currentPage().getParameters().get('documentoRecordTypeName').escapeHtml4();
        
        String emailTemplateName = documentoRecordTypeName + '_' + language;
		
        EmailTemplate plantilla = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
        
        html = plantilla.HtmlValue;
        //system.debug ('ID ' + documentoId + 'HTML ' + html);
        system.debug('El documento es: ' + documentoRecordTypeName);
        switch on documentoRecordTypeName {
            when 'DOC001_Acta_de_entrega' {
                html = Doc001Builder.fillTemplate(documentoId, html);
            }
            when 'DOC002_Acta_de_reconocimiento' {
                html = Doc002Builder.fillTemplate(documentoId, html);
            }
            when 'DOC003_Acta_medica_practica_tanatologica_y_extraccion' {
                html = Doc003Builder.fillTemplate(documentoId, html);
            }
            when 'DOC004_Certificado_de_empresa' {
                html = Doc004Builder.fillTemplate(documentoId, html);
            }
            when 'DOC005_Certificado_de_incineracion' {
                html = Doc005Builder.fillTemplate(documentoId, html);
            }
            when 'DOC006_Certificado_deposito_cinerario_comunitario' {
                html = Doc006Builder.fillTemplate(documentoId, html);
            }
            when 'DOC007_Certificado_precintado_feretro_urna' {
                html = Doc007Builder.fillTemplate(documentoId, html);
            }
            when 'DOC008_Codigo_de_duelo' {
                html = Doc008Builder.fillTemplate(documentoId, html);
            }
            when 'DOC009_Codigo_Streaming' {
                html = Doc009Builder.fillTemplate(documentoId, html);
            }
            when 'DOC010_Control_Visita_Sala' {
                html = Doc010Builder.fillTemplate(documentoId, html);
            }
            when 'DOC011_Impresion_sobre_documentacion' {
                html = Doc011Builder.fillTemplate(documentoId, html);
            }
            when 'DOC012_Libro_de_firmas' {
                html = Doc012Builder.fillTemplate(documentoId, html);
            }
            when 'DOC013_Hoja_Declaracion_Defuncion_1_2' {
                html = Doc013Builder.fillTemplate(documentoId, html);
            }
            when 'DOC014_Licencia_RG_impreso' {
                html = Doc014Builder.fillTemplate(documentoId, html);
            }
            when 'DOC015_Nota_de_Condolencias' {
                /*ONE_Documentos__c doc = [
                    SELECT
                        ONE_Servicio__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                        nombre_difunto_modificable__c,
                        Sala_Velatorio__c,
                        Mensaje__c,
                        Remitente__c,
                        ONE_Municipio__c,
                        ONE_Fecha_Now__c,
                        Nombre_coloquial__c
                FROM ONE_Documentos__c
                WHERE Id = :documentoId];
                
                doc.Nombre_coloquial__c = 'a';
                doc.nombre_difunto_modificable__c = 'b';
                doc.Sala_Velatorio__c = 'c';
                doc.Mensaje__c = 'd';
                doc.Remitente__c = 'e';
                doc.ONE_Municipio__c = 'f';*/
				//update doc;
                html = Doc015Builder.fillTemplate(documentoId, html);
            }
            when 'DOC016_Orden_Preparacion_Arca_y_Complementos' {
                html = Doc016Builder.fillTemplate(documentoId, html);
            }
            when 'DOC017_Recogida_entrega_de_cenizas' {
                html = Doc017Builder.fillTemplate(documentoId, html);
            }
            when 'DOC018_Recordatorio' {
                html = Doc018Builder.fillTemplate(documentoId, html);
            }
            when 'DOC019_Registro_judiciales_y_manipulacion_COVID' {
                html = Doc019Builder.fillTemplate(documentoId, html);
            }
            when 'DOC020_Relacion_efectos_recibidos_entregados' {
                html = Doc020Builder.fillTemplate(documentoId, html);
            }
            when 'DOC021_Solicitud_certificado_literales_al_juzgado' {
                html = Doc021Builder.fillTemplate(documentoId, html);
            }
            when 'DOC022_Solicitud_traslado_y_practica_tanatologica' {
                html = Doc022Builder.fillTemplate(documentoId, html);
            }
            when 'DOC023_Hoja_recogida_difunto_para_reg_civil' {
                html = Doc023Builder.fillTemplate(documentoId, html);
            }
            when 'DOC024_Hoja_Declaracion_Defuncion_Bilingue_1_2' {
                html = Doc024Builder.fillTemplate(documentoId, html);
            }
            when 'DOC025_Sepa' {
                html = Doc025Builder.fillTemplate(documentoId, html);
            }
            when 'DOC027_Inscripcion_judiciales' {
                html = Doc027Builder.fillTemplate(documentoId, html);
            }
            when 'DOC028_Formulario_Inscripcion_Defuncion_RC' {
                html = Doc028Builder.fillTemplate(documentoId, html);
            }
            when 'DOC029_Acta_constancia_declaracion_defuncion' {
                html = Doc029Builder.fillTemplate(documentoId, html);
            }
            when 'DOC030_Datos_Ceremonia_Parroquial' {
                html = Doc030Builder.fillTemplate(documentoId, html);
            }
            when 'DOC032_Orden_Recogida_Preparacion_Deposito' {
                html = Doc032Builder.fillTemplate(documentoId, html);
            }
            when 'DOC033_Esquela_Prensa' {
                html = Doc033Builder.fillTemplate(documentoId, html);
            }
            when 'DOC034_CE_Pedido_Tarea_Inhumacion' {
                html = Doc034Builder.fillTemplate(documentoId, html);
            }
            when 'DOC035_CE_Orden_Trabajo_Cementerio' {
                html = Doc035Builder.fillTemplate(documentoId, html);
            }
            when 'DOC036_TA_Cartel_Informativo_Tumulo' {
                html = Doc036Builder.fillTemplate(documentoId, html);
            }
            when 'DOC037_Orden_de_servicio' {
                html = Doc037Builder.fillTemplate(documentoId, html);
            }
            when 'DOC038_Autorizacion_retirada' {
                html = Doc038Builder.fillTemplate(documentoId, html);
            }
            when 'DOC039_Etiqueta_pulsera' {
                html = Doc039Builder.fillTemplate(documentoId, html);
            }
            when 'DOC040_Solicitud_oficios_tramitaci_n_judicial' {
                html = Doc040Builder.fillTemplate(documentoId, html);
            }
            when 'DOC041_Solicitud_de_Incineracion_Grupo_Albia' {
                html = Doc041Builder.fillTemplate(documentoId, html);
            }
            when 'DOC042_Solicitud_Tanatorio_Grupo_Albia' {
                html = Doc042Builder.fillTemplate(documentoId, html);
            }
        }
    }
}
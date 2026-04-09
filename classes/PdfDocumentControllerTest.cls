@isTest
public class PdfDocumentControllerTest {
    
    @testSetup
    private static void testSetup() {

        List<ONE_Documentos__c> documents = new List<ONE_Documentos__c>();

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        
        Account centro = ONE_TestDataFactory.createAccount(
            new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT,
                    ONE_CommonConstants.ACC_RT_CENTRO_MEMORA),
                ONE_Lugar__c = lugar.Id,
                ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN'
            ), true
        );
        
        Account acc = new Account(FirstName = 'TEST', LastName = 'TEST', Phone='532944', ONE_Email__c = 'martaJtest@example.com', ONE_N_Documento__pc = '44445555X',
                                  RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(Account.SObjectType.getDescribe().name,
                                                                                              ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR));
        insert acc;
        
        ONE_Expediente__c expediente = new ONE_Expediente__c(
            ONE_Difunto__c = acc.id,
            ONE_Inicio_Incineracion__c = Datetime.now(),
            ONE_Centro_Del_Expediente__c = centro.Id
        );
        insert expediente;

        ONE_Tarea__c tarea = new ONE_Tarea__c(
            RecordTypeId = Schema.SObjectType.ONE_Tarea__c.getRecordTypeInfosByDeveloperName().get('ONE_Tarea_De_Cremacion').getRecordTypeId(),
            ONE_Expediente__c = expediente.Id
        );
        insert tarea;
        
        // Documento 001

        ONE_Documentos__c documentoTarea1 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC001_Acta_de_entrega').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id,
            Residencia__c = true
        );
        documents.add(documentoTarea1);
        
        // Documento 002
       
        ONE_Documentos__c documentoTarea2 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC002_Acta_de_reconocimiento').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id
        );
        documents.add(documentoTarea2);
                
        // Documento 003
        
        ONE_Documentos__c documentoTarea3 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC003_Acta_medica_practica_tanatologica_y_extraccion').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id,
            Tanatopraxia__c = true,
            Extraccion_de_marcapasos__c = true,
            Otros_productos__c = 'Producto 1',
            Otras_tecnicas__c = 'Tecnica 1',
            Ataud_bolsa_sanitaria__c = true
        );
        documents.add(documentoTarea3);
                
        // Documento 004
        
        ONE_Documentos__c documentoTarea4 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC004_Certificado_de_empresa').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id
        );
        documents.add(documentoTarea4);
        
        // Documento 005
        
        ONE_Documentos__c documentoTarea5 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC005_Certificado_de_incineracion').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id,
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoTarea5);
          
        // Documento 006
        
        ONE_Documentos__c documentoTarea6 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC006_Certificado_deposito_cinerario_comunitario').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id,
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoTarea6);
        
        // Documento 007
        
        ONE_Documentos__c documentoTarea7 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC007_Certificado_precintado_feretro_urna').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id,
            ONE_Servicio__c = expediente.Id,
            Precintado_feretro__c = true
        );
        documents.add(documentoTarea7);
        
        // Documento 008
        
        ONE_Documentos__c documentoServicio8 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC008_Codigo_de_duelo').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio8);
        
        // Documento 009
        
        ONE_Documentos__c documentoServicio9 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC009_Codigo_Streaming').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio9);

        // Documento 011
        
        ONE_Documentos__c documentoServicio11 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC011_Impresion_sobre_documentacion').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id,
            Otros_documentos__c = 'Otros documentos'
        );
        documents.add(documentoServicio11);
        
        // Documento 012
        
        ONE_Documentos__c documentoServicio12 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC012_Libro_de_firmas').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio12);

        // Documento 013
        
        ONE_Documentos__c documentoServicio13 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC013_Hoja_Declaracion_Defuncion_1_2').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id,
            Observaciones2__c = 'xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx',
            Otros_datos__c = 'xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx',
            Los_anteriores_datos_se_conocen__c = 'xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx  xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx'
        );
        documents.add(documentoServicio13);

        // Documento 014
        
        ONE_Documentos__c documentoServicio14 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC014_Licencia_RG_impreso').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio14);

        // Documento 015
        
        ONE_Documentos__c documentoServicio15 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC015_Nota_de_Condolencias').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio15);

        // Documento 016
        
        ONE_Documentos__c documentoServicio16 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC016_Orden_Preparacion_Arca_y_Complementos').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio16);
        
        // Documento 017
        
        ONE_Documentos__c documentoTarea17 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC017_Recogida_entrega_de_cenizas').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id
        );
        documents.add(documentoTarea17);
              
        // Documento 018
        
        ONE_Documentos__c documentoServicio18 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC018_Recordatorio').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio18);
        
        // Documento 019
        
        ONE_Documentos__c documentoServicio19 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC019_Registro_judiciales_y_manipulacion_COVID').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio19);
        
        // Documento 020
        
        ONE_Documentos__c documentoTarea20 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC020_Relacion_efectos_recibidos_entregados').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id,
            Documentacion__c = true,
            Otros_documentos__c = 'Otro documento'
        );
        documents.add(documentoTarea20);
                
        // Documento 021
        
        ONE_Documentos__c documentoServicio21 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC021_Solicitud_certificado_literales_al_juzgado').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio21);
        
        // Documento 022
        
        ONE_Documentos__c documentoTarea22 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC022_Solicitud_traslado_y_practica_tanatologica').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id,
            Fecha_modificable__c = Datetime.now()
        );
        documents.add(documentoTarea22);
        

        // Documento 023
        
        ONE_Documentos__c documentoServicio23 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC023_Hoja_recogida_difunto_para_reg_civil').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio23);

        // Documento 024
        
        ONE_Documentos__c documentoServicio24 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC024_Hoja_Declaracion_Defuncion_Bilingue_1_2').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id,
            Observaciones2__c = 'xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx',
            Otros_datos__c = 'xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx',
            Los_anteriores_datos_se_conocen__c = 'xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx  xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx'
        );
        documents.add(documentoServicio24);
        
        // Documento 025

        ONE_Documentos__c documentoServicio25 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC025_Sepa').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio25);

        // Documento 027
        
        ONE_Documentos__c documentoServicio27 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC027_Inscripcion_judiciales').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio27);

        // Documento 028
        
        ONE_Documentos__c documentoServicio28 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC028_Formulario_Inscripcion_Defuncion_RC').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio28);
        
        // Documento 029
        
        ONE_Documentos__c documentoServicio29 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC029_Acta_constancia_declaracion_defuncion').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio29);

        // Documento 030
        
        ONE_Documentos__c documentoServicio30 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC030_Datos_Ceremonia_Parroquial').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio30);

        // Documento 032
        
        ONE_Documentos__c documentoServicio32 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC032_Orden_Recogida_Preparacion_Deposito').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio32);

        // Documento 033
        
        ONE_Documentos__c documentoServicio33 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC033_Esquela_Prensa').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documentoServicio33);

        // Documento 034
        
        ONE_Documentos__c documentoTarea34 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC034_CE_Pedido_Tarea_Inhumacion').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id
        );
        documents.add(documentoTarea34);

        // Documento 038
        
        ONE_Documentos__c documento38 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC038_Autorizacion_retirada').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documento38);

        // Documento 039
        
        ONE_Documentos__c documento39 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC039_Etiqueta_pulsera').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documento39);

        ONE_Documentos__c documento40 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC040_Solicitud_oficios_tramitaci_n_judicial').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documento40);
        
        // Documento 041
        
        ONE_Documentos__c documento41 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC041_Solicitud_de_Incineracion_Grupo_Albia').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documento41);
        
        // Documento 042
        
        ONE_Documentos__c documento42 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC042_Solicitud_Tanatorio_Grupo_Albia').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        documents.add(documento42);
        

        insert documents;
        

        ONE_Documentos__c documento = [SELECT Id FROM ONE_Documentos__c WHERE RecordType.DeveloperName = 'DOC002_Acta_de_reconocimiento' LIMIT 1];
        Attachment firma = new Attachment(
            ParentId = documento.Id,
            Name = 'Signature.png',
            ContentType = 'image/png',
            Body = EncodingUtil.base64Decode('')
        );
        insert firma;
    }

    @isTest
    private static void documentsWithoutProducts() {

        system.debug([SELECT ONE_Expediente__c, ONE_Presupuesto__r.ONE_Expediente__c, ONE_Presupuesto__r.ONE_Estado__c, ONE_Presupuesto__r.ONE_Presupuesto_Cancelado__c, ONE_Estado__c, ONE_Producto__r.ONE_Categoria__r.ONE_Agrupacion__r.ONE_Momento__r.Name FROM ONE_Expediente_Line_item__c]);

        Test.startTest();
        Map<String, Id> recordTypeDocumentoMap = new Map<String, Id>();

        for(RecordType recType : [  SELECT DeveloperName FROM RecordType
                                    WHERE
                                        SobjectType = 'ONE_Documentos__c' AND
                                        DeveloperName LIKE 'DOC%' AND
                                        DeveloperName NOT IN (
                                            'DOC010_Control_Visita_Sala',
                                            'DOC035_CE_Orden_Trabajo_Cementerio',
                                            'DOC036_TA_Cartel_Informativo_Tumulo',
                                            'DOC037_Orden_de_servicio')])
        {
            recordTypeDocumentoMap.put(recType.DeveloperName, null);
        }

        for(ONE_Documentos__c documento : [SELECT Id, RecordType.DeveloperName FROM ONE_Documentos__c WHERE (ONE_Servicio__c != null OR ONE_Tarea__c != null) AND RecordType.DeveloperName IN :recordTypeDocumentoMap.keySet()]) {
            recordTypeDocumentoMap.put(documento.RecordType.DeveloperName, documento.Id);
        }

        for(String recordTypeDeveloperName : recordTypeDocumentoMap.keySet()) {
            
            PageReference pageRef = Page.PdfDocument;
        	pageRef.getParameters().put('documentoId', recordTypeDocumentoMap.get(recordTypeDeveloperName));
            pageRef.getParameters().put('language', 'es');
      		pageRef.getParameters().put('documentoRecordTypeName', recordTypeDeveloperName);
        	Test.setCurrentPage(pageRef);
        	
        	PdfDocumentController controller = new PdfDocumentController();

        	String html = controller.html;
        	System.assertNotEquals(null, html);
        	System.assertNotEquals('', html);
        }
        Test.stopTest();
    }

    @isTest
    private static void documentsWithProducts() {

        ONE_Expediente__c expediente = [SELECT Id FROM ONE_Expediente__c WHERE ONE_Difunto__r.FirstName = 'TEST' LIMIT 1];

        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c WHERE ONE_Expediente__c = :expediente.Id LIMIT 1];

        ONE_Momento__c momento = new ONE_Momento__c(
            Name = ONE_MomentoServiceConstants.ARTE_FLORAL_SERVICO_MOMENT
        );
        insert momento;

        ONE_Agrupacion__c agrupacion = new ONE_Agrupacion__c(
            Name = ONE_MomentoServiceConstants.ARTE_FLORAL_SERVICO_AGRUPACION_LIST.get(0),
            ONE_Momento__c = momento.Id
        );
        insert agrupacion;

        ONE_Categoria__c categoria = new ONE_Categoria__c(
            ONE_Agrupacion__c= agrupacion.Id,
            Name = (ONE_MomentoServiceConstants.ARTE_FLORAL_SERVICO_CATEGORIA_MAP.get(ONE_MomentoServiceConstants.ARTE_FLORAL_SERVICO_AGRUPACION_LIST.get(0))).get(0)
        );
        insert categoria;

        ONE_Producto__c producto = new ONE_Producto__c(
            Name = 'Producto',
            ONE_Categoria__c = categoria.Id
        );
        insert producto;

        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
            ONE_Expediente__c = expediente.Id,
            ONE_Estado__c = 'Contratado',
            ONE_Presupuesto_Cancelado__c = false,
            ONE_Tipo_De_Venta__c = ''
        );
        insert presupuesto;

        ONE_Expediente_Line_item__c lineaServicio = new ONE_Expediente_Line_item__c(
            ONE_Presupuesto__c = presupuesto.Id,
            ONE_Expediente__c = expediente.Id,
            ONE_Estado__c = 'Confirmado',
            ONE_Tarjeta_O_Lazo__c = 'Lazo',
            ONE_Texto_Banda_O_Lazo__c = 'Texto',
            ONE_Producto__c = producto.Id
        );
        insert lineaServicio;

        // Documento 010
        
        ONE_Documentos__c documentoServicio10 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC010_Control_Visita_Sala').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id,
            Fecha_y_hora__c = DateTime.now(),
            Inicio_Ceremonia__c = DateTime.now(),
            Fecha_hora_Inhumaci_n__c = DateTime.now(),
            Fecha_Hora_Incineraci_n__c = DateTime.now(),
            Fecha_control_y_revisi_n__c = DateTime.now(),
            Apertura_sala__c = DateTime.now(),
            Visita_sala__c = DateTime.now(),
            Visita_confort__c = DateTime.now()
        );
        insert documentoServicio10;

        // Documento 035
        
        ONE_Documentos__c documentoTarea35 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC035_CE_Orden_Trabajo_Cementerio').getRecordTypeId(),
            ONE_Tarea__c = tarea.Id
        );
        insert documentoTarea35;

        // Documento 036

        ONE_Documentos__c documentoTarea36 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC036_TA_Cartel_Informativo_Tumulo').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        insert documentoTarea36;

        // Documento 037
        
        ONE_Documentos__c documentoServicio37 = new ONE_Documentos__c(
            RecordTypeId = Schema.SObjectType.ONE_Documentos__c.getRecordTypeInfosByDeveloperName().get('DOC037_Orden_de_servicio').getRecordTypeId(),
            ONE_Servicio__c = expediente.Id
        );
        insert documentoServicio37;

        Test.startTest();
        Map<String, Id> recordTypeDocumentoMap = new Map<String, Id>();

        for(RecordType recType : [SELECT DeveloperName FROM RecordType WHERE SobjectType = 'ONE_Documentos__c' AND
                                    DeveloperName IN (
                                        'DOC010_Control_Visita_Sala',
                                        'DOC035_CE_Orden_Trabajo_Cementerio',
                                        'DOC036_TA_Cartel_Informativo_Tumulo',
                                        'DOC037_Orden_de_servicio')])
        {
            recordTypeDocumentoMap.put(recType.DeveloperName, null);
        }

        for(ONE_Documentos__c documento : [SELECT Id, RecordType.DeveloperName FROM ONE_Documentos__c WHERE (ONE_Servicio__c != null OR ONE_Tarea__c != null) AND RecordType.DeveloperName IN :recordTypeDocumentoMap.keySet()]) {
            recordTypeDocumentoMap.put(documento.RecordType.DeveloperName, documento.Id);
        }

        for(String recordTypeDeveloperName : recordTypeDocumentoMap.keySet()) {
           
            PageReference pageRef = Page.PdfDocument;
        	pageRef.getParameters().put('documentoId', recordTypeDocumentoMap.get(recordTypeDeveloperName));
            pageRef.getParameters().put('language', 'es');
      		pageRef.getParameters().put('documentoRecordTypeName', recordTypeDeveloperName);
        	Test.setCurrentPage(pageRef);
        	
        	PdfDocumentController controller = new PdfDocumentController();

        	String html = controller.html;
        	System.assertNotEquals(null, html);
        	System.assertNotEquals('', html);
        }
        Test.stopTest();
    }
}
public without sharing class ONE_CompanyPdfDocumentController {

    public Id casoId {public get; private set;}
    public String html {public get; private set;}
    
    public ONE_CompanyPdfDocumentController() {
        casoId = ApexPages.currentPage().getParameters().get('casoId').escapeHtml4();

        EmailTemplate plantilla = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Aviso_Compania' WITH SECURITY_ENFORCED LIMIT 1];
        html = plantilla.HtmlValue;

        ONE_Caso__c caso = [
            SELECT
                ONE_Prima_unica__c,
                ONE_Poliza_Menor_Ano__c,
                ONE_Difunto__r.Name,
                CreatedDate,
                ONE_Gerencia__r.Name,
                ToLabel(ONE_Tipo__c),
                Name,

                ONE_Lugar_de_Recogida_Lookup__r.Name,
                ONE_Direccion_De_Defuncion_Recogida__c,
                ONE_Municipio_De_Recogida__c,
                ONE_Codigo_Postal_De_Recogida__c,
                ToLabel(ONE_Provincia_De_Recogida__c),
                ToLabel(ONE_Pais_De_Recogida__c),

                ONE_Nombre_De_La_Persona_De_Contacto__c,
                ONE_Telefono_De_La_Persona_De_Contacto__c,
                ToLabel(ONE_Relacion_Con_El_Difunto__c),

                ONE_Avisador_Profesional__r.Name,
                ONE_Avisador_Particular__r.Name,
                ONE_Centro_De_Trabajo__r.Name,

                ONE_Observaciones2__c,

                ONE_Compania_Aseguradora__c,
                ONE_Numero_De_Siniestro_Texto__c,
                ONE_Numero_De_Poliza__c,
                ONE_Capital2__c
            FROM ONE_Caso__c
            WHERE Id = :casoId];

        html = html.replace('[primaUnica]', caso.ONE_Prima_unica__c != null ? caso.ONE_Prima_unica__c : '');
        html = html.replace('[polizaMenorAno]', caso.ONE_Poliza_Menor_Ano__c ? 'Sí' : 'No');
        html = html.replace('[difunto]', caso.ONE_Difunto__r.Name != null ? caso.ONE_Difunto__r.Name : '');
        html = html.replace('[fechaCreacion]', caso.CreatedDate != null ? caso.CreatedDate.format() : '');
        html = html.replace('[gerencia]', caso.ONE_Gerencia__c != null ? caso.ONE_Gerencia__r.Name : '');
        html = html.replace('[tipo]', caso.ONE_Tipo__c != null ? caso.ONE_Tipo__c : '');
        html = html.replace('[name]', caso.Name != null ? caso.Name : '');

        html = html.replace('[lugarRecogida]', caso.ONE_Lugar_de_Recogida_Lookup__r.Name != null ? caso.ONE_Lugar_de_Recogida_Lookup__r.Name : '');
        html = html.replace('[direccionDefuncionRecogida]', caso.ONE_Direccion_De_Defuncion_Recogida__c != null ? caso.ONE_Direccion_De_Defuncion_Recogida__c : '');
        html = html.replace('[municipioRecogida]', caso.ONE_Municipio_De_Recogida__c != null ? caso.ONE_Municipio_De_Recogida__c : '');
        html = html.replace('[codigoPostalRecogida]', caso.ONE_Codigo_Postal_De_Recogida__c != null ? caso.ONE_Codigo_Postal_De_Recogida__c : '');
        html = html.replace('[provinciaRecogida]', caso.ONE_Provincia_De_Recogida__c != null ? caso.ONE_Provincia_De_Recogida__c : '');
        html = html.replace('[paisRecogida]', caso.ONE_Pais_De_Recogida__c != null ? caso.ONE_Pais_De_Recogida__c : '');

        html = html.replace('[nombreContacto]', caso.ONE_Nombre_De_La_Persona_De_Contacto__c != null ? caso.ONE_Nombre_De_La_Persona_De_Contacto__c : '');
        html = html.replace('[telefonoContacto]', caso.ONE_Telefono_De_La_Persona_De_Contacto__c != null ? caso.ONE_Telefono_De_La_Persona_De_Contacto__c : '');
        html = html.replace('[parentescoContacto]', caso.ONE_Relacion_Con_El_Difunto__c != null ? caso.ONE_Relacion_Con_El_Difunto__c : '');

        html = html.replace('[avisadorProfesional]', caso.ONE_Avisador_Profesional__r.Name != null ? caso.ONE_Avisador_Profesional__r.Name : '');
        html = html.replace('[avisadorParticular]', caso.ONE_Avisador_Particular__r.Name != null ? caso.ONE_Avisador_Particular__r.Name : '');
        html = html.replace('[centroTrabajo]', caso.ONE_Centro_De_Trabajo__r.Name != null ? caso.ONE_Centro_De_Trabajo__r.Name : '');

        html = html.replace('[observaciones]', caso.ONE_Observaciones2__c != null ? caso.ONE_Observaciones2__c : '');

        html = html.replace('[companiaAseguradora]', caso.ONE_Compania_Aseguradora__c != null ? caso.ONE_Compania_Aseguradora__c : '');
        html = html.replace('[numeroSiniestro]', caso.ONE_Numero_De_Siniestro_Texto__c != null ? caso.ONE_Numero_De_Siniestro_Texto__c : '');
        html = html.replace('[numeroPoliza]', caso.ONE_Numero_De_Poliza__c != null ? caso.ONE_Numero_De_Poliza__c : '');
        html = html.replace('[capital]', caso.ONE_Capital2__c != null ? caso.ONE_Capital2__c.format() + ' €' : '');
    }
}
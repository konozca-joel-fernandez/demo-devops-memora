public without sharing class ONE_sendMailPendienteZonaBuilder {

    private EmailTemplate et;
    private ONE_Caso__c caso;

    public ONE_sendMailPendienteZonaBuilder(Id templateId, Id casoId) {
        this.caso = [
            SELECT Id,
                   Name,
                   CreatedDate,
                   ONE_Prima_unica__c,
                   ONE_Poliza_Menor_Ano__c,
                   ONE_Record_Type__c,
                   ONE_Tipo__c,
                   ONE_Tipo_De_Servicio__c,
                   ONE_Difunto__r.Name,
                   ONE_Gerencia__r.Name,
                   ONE_Lugar_de_Recogida_Lookup__r.Name,
                   ONE_Direccion_De_Defuncion_Recogida__c,
                   ONE_Municipio_De_Recogida__c,
                   ONE_Codigo_Postal_De_Recogida__c,
                   ONE_Provincia_De_Recogida__c,
                   ONE_Pais_De_Recogida__c,
                   ONE_Nombre_De_La_Persona_De_Contacto__c,
                   ONE_Telefono_De_La_Persona_De_Contacto__c,
                   ONE_Relacion_Con_El_Difunto__c,
                   ONE_Avisador_Profesional__r.Name,
                   ONE_Avisador_Particular__r.Name,
                   ONE_Observaciones2__c,
                   ONE_Compania_Aseguradora_Lookup__r.Name,
                   ONE_Contrato__r.Name,
                   ONE_Codigo_electium_Smart__c,
                   ONE_Centro_De_Trabajo__r.Name,
                   ONE_Numero_De_Siniestro_Texto__c,
                   ONE_Numero_De_Poliza__c,
                   ONE_Capital2__c
            FROM ONE_Caso__c
            WHERE Id = :casoId
            LIMIT 1
        ];

        this.et = [
            SELECT HtmlValue, Subject
            FROM EmailTemplate
            WHERE Id = :templateId
            LIMIT 1
        ];
    }

    public String getSubject() {
        String subject = et.Subject;
        subject = subject.replace('{!ONE_Caso__c.ONE_Gerencia__c}', caso.ONE_Gerencia__r != null ? caso.ONE_Gerencia__r.Name : '');
        subject = subject.replace('{!ONE_Caso__c.ONE_Numero_De_Siniestro_Texto__c}', caso.ONE_Numero_De_Siniestro_Texto__c != null ? caso.ONE_Numero_De_Siniestro_Texto__c : '');
        return subject;
    }

    public String getBody() {
        String body = et.HtmlValue;

        String recordLinkText = String.join(new List<String>{
            caso.ONE_Record_Type__c != null ? caso.ONE_Record_Type__c : '',
            caso.ONE_Tipo__c != null ? caso.ONE_Tipo__c : '',
            caso.ONE_Tipo_De_Servicio__c != null ? caso.ONE_Tipo_De_Servicio__c : ''
        }, ' - ') + ': ' + (caso.Name != null ? caso.Name : '');

        String caseUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/' + caso.Id;

        String htmlLink = '<a href="' + caseUrl + '">' + recordLinkText + '</a>';

        body = body.replace('{!ONE_Caso__c.ONE_Record_Type__c} - {!ONE_Caso__c.ONE_Tipo__c} - {!ONE_Caso__c.ONE_Tipo_De_Servicio__c}: {!ONE_Caso__c.Name}', htmlLink);

        body = body.replace('{!ONE_Caso__c.ONE_Prima_unica__c}', caso.ONE_Prima_unica__c != null ? caso.ONE_Prima_unica__c : '');
        body = body.replace('{!if(ONE_Caso__c.ONE_Poliza_Menor_Ano__c=true, "Si", "No")}', caso.ONE_Poliza_Menor_Ano__c ? 'Si' : 'No');
        body = body.replace('{!ONE_Caso__c.ONE_Record_Type__c}', caso.ONE_Record_Type__c != null ? caso.ONE_Record_Type__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Tipo__c}', caso.ONE_Tipo__c != null ? caso.ONE_Tipo__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Tipo_De_Servicio__c}', caso.ONE_Tipo_De_Servicio__c != null ? caso.ONE_Tipo_De_Servicio__c : '');
        body = body.replace('{!ONE_Caso__c.Name}', caso.Name != null ? caso.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Difunto__c}', caso.ONE_Difunto__r != null ? caso.ONE_Difunto__r.Name : '');
        body = body.replace('{!DATETIMEVALUE(ONE_Caso__c.CreatedDate)}', caso.CreatedDate.format('dd/M/yyyy, H:mm'));
        body = body.replace('{!ONE_Caso__c.ONE_Gerencia__c}', caso.ONE_Gerencia__r != null ? caso.ONE_Gerencia__r.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Lugar_de_Recogida_Lookup__c}', caso.ONE_Lugar_de_Recogida_Lookup__r != null ? caso.ONE_Lugar_de_Recogida_Lookup__r.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Direccion_De_Defuncion_Recogida__c}', caso.ONE_Direccion_De_Defuncion_Recogida__c != null ? caso.ONE_Direccion_De_Defuncion_Recogida__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Municipio_De_Recogida__c}', caso.ONE_Municipio_De_Recogida__c != null ? caso.ONE_Municipio_De_Recogida__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Codigo_Postal_De_Recogida__c}', caso.ONE_Codigo_Postal_De_Recogida__c != null ? caso.ONE_Codigo_Postal_De_Recogida__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Provincia_De_Recogida__c}', caso.ONE_Provincia_De_Recogida__c != null ? caso.ONE_Provincia_De_Recogida__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Pais_De_Recogida__c}', caso.ONE_Pais_De_Recogida__c != null ? caso.ONE_Pais_De_Recogida__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Nombre_De_La_Persona_De_Contacto__c}', caso.ONE_Nombre_De_La_Persona_De_Contacto__c != null ? caso.ONE_Nombre_De_La_Persona_De_Contacto__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Telefono_De_La_Persona_De_Contacto__c}', caso.ONE_Telefono_De_La_Persona_De_Contacto__c != null ? caso.ONE_Telefono_De_La_Persona_De_Contacto__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Relacion_Con_El_Difunto__c}', caso.ONE_Relacion_Con_El_Difunto__c != null ? caso.ONE_Relacion_Con_El_Difunto__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Avisador_Profesional__c}', caso.ONE_Avisador_Profesional__r != null ? caso.ONE_Avisador_Profesional__r.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Avisador_Particular__c}', caso.ONE_Avisador_Particular__r != null ? caso.ONE_Avisador_Particular__r.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Observaciones2__c}', caso.ONE_Observaciones2__c != null ? caso.ONE_Observaciones2__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Compania_Aseguradora__c}', caso.ONE_Compania_Aseguradora_Lookup__r != null ? caso.ONE_Compania_Aseguradora_Lookup__r.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Contrato__c}', caso.ONE_Contrato__r != null ? caso.ONE_Contrato__r.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Codigo_electium_Smart__c}', caso.ONE_Codigo_electium_Smart__c != null ? caso.ONE_Codigo_electium_Smart__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Centro_De_Trabajo__c}', caso.ONE_Centro_De_Trabajo__r != null ? caso.ONE_Centro_De_Trabajo__r.Name : '');
        body = body.replace('{!ONE_Caso__c.ONE_Numero_De_Siniestro_Texto__c}', caso.ONE_Numero_De_Siniestro_Texto__c != null ? caso.ONE_Numero_De_Siniestro_Texto__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Numero_De_Poliza__c}', caso.ONE_Numero_De_Poliza__c != null ? caso.ONE_Numero_De_Poliza__c : '');
        body = body.replace('{!ONE_Caso__c.ONE_Capital2__c}', caso.ONE_Capital2__c != null ? formatEuro(String.valueOf(caso.ONE_Capital2__c)) + ' €' : '');

        return body;
    }

    public String formatEuro(String value) {
        Decimal decimalValue = Decimal.valueOf(value);
        String formattedValue = decimalValue.format().replace('.', '$').replace(',', '.').replace('$', ',');
        return formattedValue;
    }
}
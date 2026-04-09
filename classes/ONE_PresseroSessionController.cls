public without sharing class ONE_PresseroSessionController {
    
    @InvocableMethod(label='Pressero Integration' description='Code "1" : Create New Session; \n Code "2" : Autocomplete Template; \n Code "3" : Get and Save PDF;  \n Code "2" : Get PDF Preview;')
    public static List<PresseroResult> presseroIntegration(List<PresseroRequest> request){
        
        List<PresseroResult> result = new List<PresseroResult>();
        
        String option = request[0].option;
        if(option == '1') {
           result = presseroNewSession(request[0].tareaId, request[0].docCode, request[0].docPwd, request[0].docTemplateName, request[0].nameSavedSession, request[0].docObs, request[0].docLang, request[0].docLugar, request[0].docType, request[0].plantillaEdoc, request[0].serviceId);
        } else if (option == '2') {
           presseroAutocompletTemplate(request[0].tareaId, request[0].docSession, request[0].docLang, request[0].docLugar, request[0].docType, request[0].serviceId, request[0].linkQr);
        } else if (option == '3') { 
            result = presseroGetAndSavePDF(request[0].tareaId, request[0].docSession, request[0].serviceId);
        } else if (option == '4') {
            result = getPdfPreview(request[0].docSession);
        }
        return result;
    }

    public static List<PresseroResult> presseroNewSession(String tareaId, String docCode, String docPwd, String docTemplateName, String nameSavedSession, String docObs, String docLang, String docLugar, String docType, String plantillaEdoc, String serviceId){
        
        PresseroResult result = new PresseroResult();
        String docSession = null;
        
        String endpoint = ONE_PresseroSessionHelper.presseroEndpoint();
        String bodyXML = ONE_PresseroSessionHelper.newSessionXMLgenerator(docCode, docPwd);
        System.debug('Body');
        System.debug(bodyXML);
        
        HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        	req.setHeader('Accept', 'application/xml');
        	req.setMethod('POST');
            req.setBody(bodyXML);
        
        Http http = new Http();
        
        HttpResponse res = http.send(req);
        
        System.debug('Response');
        System.debug(res);
        System.debug(res.getBodyDocument());
        
        if (res.getStatusCode() == 200) {
            DOM.Document doc = res.getBodyDocument();
            
            docSession = doc.getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('startDocSessionResponse', 'http://www.edocbuilder.com/')
                .getChildElement('startDocSessionResult', 'http://www.edocbuilder.com/')
                .getChildElement('docSession', 'http://www.edocbuilder.com/').getText();
                                    
            if(docSession != null) {
                addNewDocSession(tareaId, docSession, docCode, docPwd, docTemplateName, nameSavedSession, docObs, docLang, docLugar, docType, plantillaEdoc, serviceId);
            	result.status = 'OK';
            	result.newDocSession = docSession;
            } else {
                result.status = 'ERROR no se ha generado correctamente la sesión';
            }
            
        }
        else{
            System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
            System.debug(res.getBody());
            result.status = 'ERROR: ' + res.getStatusCode() + '. ' + res.getStatus();
        }

        return new List<PresseroResult>{result};
    }
    
    public static void presseroAutocompletTemplate(String tareaId, String docSession, String docLang, String docLugar, String docType, String serviceId, String linkQr){
        ONE_Expediente__c s;
        ONE_Tarea__c t;
        if(tareaId == null || tareaId == ''){
            s = [SELECT 
                ONE_Difunto__r.ONE_Nombre_Coloquial__c,
                ONE_Difunto__r.LastName,
                ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c,
                ONE_Difunto__r.ONE_Edad__c,
                toLabel(ONE_Lugar_De_Defuncion__r.ONE_Provincia__c),
                toLabel(ONE_Provincia_De_Defuncion__c),
                ONE_Lugar_De_Defuncion__r.ONE_Municipio__c,
                ONE_Lugar_De_Defuncion__r.ONE_Municipio__r.Name,
                ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c,
                ONE_Municipio_De_Defuncion__c,
                ONE_Lugar_De_Velacion__r.Name,
                ONE_Lugar_De_Velacion__r.ONE_Direccion__c,
                ONE_Lugar_De_Velacion__r.phone,
                ONE_Inicio_Velacion__c,
                ONE_Lugar_Ceremonia__r.Name, 
                ONE_Lugar_Ceremonia__r.ONE_Direccion__c,
                ONE_Lugar_Ceremonia__r.ONE_Municipio_Direccion__c,
                ONE_Inicio_Ceremonia__c,
                ONE_Lugar_Despedida__r.Name, 
                ONE_Lugar_Despedida__r.ONE_Direccion__c, 
                ONE_Inicio_Despedida__c,
                ONE_Centro_Del_Expediente__r.Name,
                ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c,
                ONE_Centro_Del_Expediente__r.phone,
                ONE_Centro_Del_Expediente__r.ONE_Provincia__c,
                ONE_Centro_Del_Expediente__r.ONE_Direccion__c,
                ONE_Destino_Final__r.Name,
                ONE_Cementerio__c, ONE_Incineracion__c,
                ONE_Lugar_Incineracion__r.Name,
                ONE_Velacion__C,
                ONE_Ceremonia__c,
                ONE_Despedida__c,
                ONE_Tipo_De_Ritual_Ceremonia__c,
                ONE_Sala_De_Velacion__r.ONE_Nombre_Base__c,
                ONE_Apenados__c,
                ONE_Parentesco__c,
                ONE_Oracion__c,
                ONE_Difunto__r.ONE_Apellido_Coloquial__c,
                ONE_Difunto__r.FirstName,
                Franja1_Dia1_De__c,
                ONE_Inicio_Incineracion__c,
                ONE_Hora_Destino_Final__c,
                ONE_Frase_De_Servicio__c
            FROM ONE_Expediente__c
            WHERE Id = :serviceId];
        } else {
            t = [SELECT 
                ONE_Nombre_Coloquial_Del_Difunto__c,
                ONE_Expediente__r.ONE_Difunto__r.LastName,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c,
                ONE_Fecha_De_Defuncion__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c,
                toLabel(ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Provincia__c),
                toLabel(ONE_Expediente__r.ONE_Provincia_De_Defuncion__c),
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name,
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Lugar_De_Velacion__r.phone,
                ONE_Expediente__r.ONE_Inicio_Velacion__c,
                ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name, 
                ONE_Expediente__r.ONE_Lugar_Ceremonia__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Lugar_Ceremonia__r.ONE_Municipio_Direccion__c,
                ONE_Expediente__r.ONE_Inicio_Ceremonia__c,
                ONE_Expediente__r.ONE_Lugar_Despedida__r.Name, 
                ONE_Expediente__r.ONE_Lugar_Despedida__r.ONE_Direccion__c, 
                ONE_Expediente__r.ONE_Inicio_Despedida__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.phone,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c,
                ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c,
                ONE_Expediente__r.ONE_Destino_Final__r.Name,
                ONE_Expediente__r.ONE_Cementerio__c, ONE_Expediente__r.ONE_Incineracion__c,
                ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name,
                ONE_Expediente__r.ONE_Velacion__C,
                ONE_Expediente__r.ONE_Ceremonia__c,
                ONE_Expediente__r.ONE_Despedida__c,
                ONE_Expediente__r.ONE_Tipo_De_Ritual_Ceremonia__c,
                ONE_Expediente__r.ONE_Sala_De_Velacion__r.ONE_Nombre_Base__c,
                ONE_Expediente__r.ONE_Apenados__c,
                ONE_Expediente__r.ONE_Parentesco__c,
                ONE_Expediente__r.ONE_Oracion__c,
                ONE_Expediente__r.ONE_Difunto__r.ONE_Apellido_Coloquial__c,
                ONE_Expediente__r.ONE_Difunto__r.FirstName,
                ONE_Expediente__r.Franja1_Dia1_De__c,
                ONE_Expediente__r.ONE_Inicio_Incineracion__c,
                ONE_Expediente__r.ONE_Hora_Destino_Final__c,
                ONE_Expediente__r.ONE_Frase_De_Servicio__c,
                ONE_Expediente__r.ONE_Municipio_De_Defuncion__c,
                ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c,
                ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Municipio__c,
                ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Municipio__r.Name
            FROM ONE_Tarea__c
            WHERE Id = :TareaId];
        }
        
        Map<String, String> fields = new Map<String, String>();
        Map<String, String> images = new Map<String, String>();
        if (linkQr != '' && linkQr != null) {
            System.debug('qr lleno: ' + linkQr);
            if (!linkQr.startsWith('Error')) {
                fields.put('qrLink', linkQr);
            }
        }
        
        if (tareaId!=null && tareaId!= ''){
            fields.put('nombreDifunto', 
                    t.ONE_Nombre_Coloquial_Del_Difunto__c != null ? t.ONE_Nombre_Coloquial_Del_Difunto__c + ' ' + (t.ONE_Expediente__r.ONE_Difunto__r.ONE_Apellido_Coloquial__c!=null ? t.ONE_Expediente__r.ONE_Difunto__r.ONE_Apellido_Coloquial__c : t.ONE_Expediente__r.ONE_Difunto__r.LastName) : (t.ONE_Expediente__r.ONE_Difunto__r.FirstName!=null ? t.ONE_Expediente__r.ONE_Difunto__r.FirstName + ' ' + (t.ONE_Expediente__r.ONE_Difunto__r.ONE_Apellido_Coloquial__c!=null ? t.ONE_Expediente__r.ONE_Difunto__r.ONE_Apellido_Coloquial__c : t.ONE_Expediente__r.ONE_Difunto__r.LastName) : (t.ONE_Expediente__r.ONE_Difunto__r.ONE_Apellido_Coloquial__c!=null ? t.ONE_Expediente__r.ONE_Difunto__r.ONE_Apellido_Coloquial__c : t.ONE_Expediente__r.ONE_Difunto__r.LastName))
                    );
            
            if(t.ONE_Fecha_De_Defuncion__c != null) {
                String fechaDefuncion = '';
                
                String day = String.valueOf(t.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.day());
                String month = ONE_PresseroSessionHelper.getMonthName(t.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.month(), docLang);
                String year = String.valueOf(t.ONE_Expediente__r.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.year());
                            
                if(docLang != 'Eus'){
                    fechaDefuncion = day + ' ' + month + ' ' + year;
                } else {
                    fechaDefuncion = year + ' ' + month + ' ' + day;
                }
                
                fields.put('fechaDefuncion', fechaDefuncion);
                
                //PARA RECORDATORIOS
                if (t.ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Provincia__c != null && t.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c != null){
                    fields.put('informacionDifunto', 'Que falleció en ' + t.ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Provincia__c + ' el ' + fechaDefuncion + ' a los ' + String.valueOf(t.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c) + ' años de edad.');
                }
            }
            
            if(t.ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Municipio__c != null){
                fields.put('lugarDefuncion', t.ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Municipio__r.Name);
            }
            else if(t.ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c != null){
                fields.put('lugarDefuncion', t.ONE_Expediente__r.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c);
            }
            else if (t.ONE_Expediente__r.ONE_Municipio_De_Defuncion__c != null){
                fields.put('lugarDefuncion', t.ONE_Expediente__r.ONE_Municipio_De_Defuncion__c);
            }
            
            if(t.ONE_Expediente__r.ONE_Parentesco__c != null){
                fields.put('aliasDifunto', t.ONE_Expediente__r.ONE_Parentesco__c);
            }
            if(t.ONE_Expediente__r.ONE_Apenados__c != null){
                fields.put('allegados', t.ONE_Expediente__r.ONE_Apenados__c);
            }
            if(t.ONE_Expediente__r.ONE_Oracion__c != null){
                fields.put('oracionPrincipal', t.ONE_Expediente__r.ONE_Oracion__c);
            }
            
            //VELACIÓN 
            if(t.ONE_Expediente__r.ONE_Lugar_De_Velacion__c != null) {
                fields.put('lugarVelacion', t.ONE_Expediente__r.ONE_Lugar_De_Velacion__r.Name);
                fields.put('direccionVelacion', t.ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Direccion__c);
            }
            
            if(t.ONE_Expediente__r.ONE_Inicio_Velacion__c != null) {
                if(docLang != 'Eus'){
                    fields.put('fechaVelacion', t.ONE_Expediente__r.Franja1_Dia1_De__c!=null
                            ? t.ONE_Expediente__r.Franja1_Dia1_De__c.format('dd-MM-yyyy')
                            : t.ONE_Expediente__r.ONE_Inicio_Velacion__c.format('dd-MM-yyyy'));
                } else {
                    fields.put('fechaVelacion', t.ONE_Expediente__r.Franja1_Dia1_De__c!=null
                            ? t.ONE_Expediente__r.Franja1_Dia1_De__c.format('yyyy-MM-dd')
                            : t.ONE_Expediente__r.ONE_Inicio_Velacion__c.format('yyyy-MM-dd'));
                }
                fields.put('horaVelacion', t.ONE_Expediente__r.ONE_Inicio_Velacion__c.format('HH:mm'));
                fields.put('salaVelacion', t.ONE_Expediente__r.ONE_Sala_De_Velacion__r.ONE_Nombre_Base__c);
            }
            
            //CEREMONIA
            if(t.ONE_Expediente__r.ONE_Lugar_Ceremonia__c != null) {
                fields.put('lugarCeremonia', t.ONE_Expediente__r.ONE_Lugar_Ceremonia__r.Name);
                //fields.put('direccionCeremonia', t.ONE_Expediente__r.ONE_Lugar_Ceremonia__r.ONE_Direccion__c);
                fields.put('MunicipioCeremonia', t.ONE_Expediente__r.ONE_Lugar_Ceremonia__r.ONE_Municipio_Direccion__c);
            }
            
            if(t.ONE_Expediente__r.ONE_Inicio_Ceremonia__c != null) {
                if(docLang != 'Eus'){
                    fields.put('fechaCeremonia', t.ONE_Expediente__r.ONE_Inicio_Ceremonia__c.format('dd-MM-yyyy'));
                } else {
                    fields.put('fechaCeremonia', t.ONE_Expediente__r.ONE_Inicio_Ceremonia__c.format('yyyy-MM-dd'));
                }
                fields.put('horaCeremonia', t.ONE_Expediente__r.ONE_Inicio_Ceremonia__c.format('HH:mm'));
            }
            
            //DESPEDIDA
            if(t.ONE_Expediente__r.ONE_Lugar_Despedida__c != null) {
                fields.put('lugarDespedida', t.ONE_Expediente__r.ONE_Lugar_Despedida__r.Name);
            }
            if(t.ONE_Expediente__r.ONE_Inicio_Despedida__c != null) {
                if(docLang != 'Eus'){
                    fields.put('fechaDespedida', t.ONE_Expediente__r.ONE_Inicio_Despedida__c.format('dd-MM-yyyy'));
                } else {
                    fields.put('fechaDespedida', t.ONE_Expediente__r.ONE_Inicio_Despedida__c.format('yyyy-MM-dd'));
                }
                
                fields.put('horaDespedida', t.ONE_Expediente__r.ONE_Inicio_Despedida__c.format('HH:mm'));
            }
            
            //FOOTER
            if(t.ONE_Expediente__r.ONE_Centro_Del_Expediente__c != null) {
                fields.put('nombreCentroDeTrabajo', t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.Name);
                fields.put('telefonoCentroDeTrabajo', t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.phone);
                fields.put('CalleCentro', t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c != null ? t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Direccion__c : '');
                fields.put('ProvinciaCentro', t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c != null ? t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Provincia__c : '');
                fields.put('webCentroDeTrabajo', t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c);    
                fields.put('logo',
                        t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null ? url_name(t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c) : t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c != null ? url_name(t.ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c) : '');
            }
            
            if (t.ONE_Expediente__r.ONE_Destino_Final__r.Name != null || t.ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name != null){
                fields.put('LugarInciOInhum', t.ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name != null ? t.ONE_Expediente__r.ONE_Lugar_Incineracion__r.Name : t.ONE_Expediente__r.ONE_Destino_Final__r.Name);  
            }
            if (t.ONE_Expediente__r.ONE_Inicio_Incineracion__c != null || t.ONE_Expediente__r.ONE_Hora_Destino_Final__c != null){
                fields.put('fechaInciOInhum', t.ONE_Expediente__r.ONE_Inicio_Incineracion__c != null ? t.ONE_Expediente__r.ONE_Inicio_Incineracion__c.format('dd-MM-yyyy') : t.ONE_Expediente__r.ONE_Hora_Destino_Final__c.format('dd-MM-yyyy'));
                fields.put('horaInciInhum', t.ONE_Expediente__r.ONE_Inicio_Incineracion__c != null ? t.ONE_Expediente__r.ONE_Inicio_Incineracion__c.format('HH:mm') : t.ONE_Expediente__r.ONE_Hora_Destino_Final__c.format('HH:mm'));
            }
            
            if(t.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Edad__c != null) {
                fields.put('edadDifunto', String.valueOf(t.ONE_Expediente__r.ONE_Difunto__r.ONE_Edad__c));
            }

            if(t.ONE_Expediente__r?.ONE_Municipio_De_Defuncion__c != null) {
                fields.put('MunicipioDefuncion', t.ONE_Expediente__r.ONE_Municipio_De_Defuncion__c);
            }

            if(t.ONE_Expediente__r?.ONE_Frase_De_Servicio__c != null) {
                fields.put('FraseServicio', t.ONE_Expediente__r.ONE_Frase_De_Servicio__c);
            }
        }
        else{
            fields.put('nombreDifunto', 
                   s.ONE_Difunto__r.ONE_Nombre_Coloquial__c != null ? s.ONE_Difunto__r.ONE_Nombre_Coloquial__c + ' ' + (s.ONE_Difunto__r.ONE_Apellido_Coloquial__c!=null ? s.ONE_Difunto__r.ONE_Apellido_Coloquial__c : s.ONE_Difunto__r.LastName) : (s.ONE_Difunto__r.FirstName!=null ? s.ONE_Difunto__r.FirstName + ' ' + (s.ONE_Difunto__r.ONE_Apellido_Coloquial__c!=null ? s.ONE_Difunto__r.ONE_Apellido_Coloquial__c : s.ONE_Difunto__r.LastName) : (s.ONE_Difunto__r.ONE_Apellido_Coloquial__c!=null ? s.ONE_Difunto__r.ONE_Apellido_Coloquial__c : s.ONE_Difunto__r.LastName))
                  );
        
            if(s.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c != null) {
                String fechaDefuncion = '';
                
                String day = String.valueOf(s.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.day());
                String month = ONE_PresseroSessionHelper.getMonthName(s.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.month(), docLang);
                String year = String.valueOf(s.ONE_Difunto__r.ONE_Fecha_De_Defuncion2__c.year());
                            
                if(docLang != 'Eus'){
                    fechaDefuncion = day + ' ' + month + ' ' + year;
                } else {
                    fechaDefuncion = year + ' ' + month + ' ' + day;
                }
                
                fields.put('fechaDefuncion', fechaDefuncion);
                
                //PARA RECORDATORIOS
                if (s.ONE_Lugar_De_Defuncion__r.ONE_Provincia__c != null && s.ONE_Difunto__r.ONE_Edad__c != null){
                    fields.put('informacionDifunto', 'Que falleció en ' + s.ONE_Lugar_De_Defuncion__r.ONE_Provincia__c + ' el ' + fechaDefuncion + ' a los ' + String.valueOf(s.ONE_Difunto__r.ONE_Edad__c) + ' años de edad.');
                }
            }
            
            if(s.ONE_Lugar_De_Defuncion__r.ONE_Municipio__c != null){
                fields.put('lugarDefuncion', s.ONE_Lugar_De_Defuncion__r.ONE_Municipio__r.Name);
            }
            else if(s.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c != null){
                fields.put('lugarDefuncion', s.ONE_Lugar_De_Defuncion__r.ONE_Municipio_Direccion__c);
            }
            else if (s.ONE_Municipio_De_Defuncion__c != null){
                fields.put('lugarDefuncion', s.ONE_Municipio_De_Defuncion__c);
            }
            
            if(s.ONE_Parentesco__c != null){
                fields.put('aliasDifunto', s.ONE_Parentesco__c);
            }
            if(s.ONE_Apenados__c != null){
                fields.put('allegados', s.ONE_Apenados__c);
            }
            if(s.ONE_Oracion__c != null){
                fields.put('oracionPrincipal', s.ONE_Oracion__c);
            }
            
            //VELACIÓN 
            if(s.ONE_Lugar_De_Velacion__c != null) {
                fields.put('lugarVelacion', s.ONE_Lugar_De_Velacion__r.Name);
                fields.put('direccionVelacion', s.ONE_Lugar_De_Velacion__r.ONE_Direccion__c);
            }
            
            if(s.ONE_Inicio_Velacion__c != null) {
                if(docLang != 'Eus'){
                    fields.put('fechaVelacion', s.Franja1_Dia1_De__c!=null
                            ? s.Franja1_Dia1_De__c.format('dd-MM-yyyy')
                            : s.ONE_Inicio_Velacion__c.format('dd-MM-yyyy'));
                } else {
                    fields.put('fechaVelacion', s.Franja1_Dia1_De__c!=null
                            ? s.Franja1_Dia1_De__c.format('yyyy-MM-dd')
                            : s.ONE_Inicio_Velacion__c.format('yyyy-MM-dd'));
                }
                fields.put('horaVelacion', s.ONE_Inicio_Velacion__c.format('HH:mm'));
                fields.put('salaVelacion', s.ONE_Sala_De_Velacion__r.ONE_Nombre_Base__c);
            }
            
            //CEREMONIA
            if(s.ONE_Lugar_Ceremonia__c != null) {
                fields.put('lugarCeremonia', s.ONE_Lugar_Ceremonia__r.Name);
                //fields.put('direccionCeremonia', s.ONE_Lugar_Ceremonia__r.ONE_Direccion__c);
                fields.put('MunicipioCeremonia', s.ONE_Lugar_Ceremonia__r.ONE_Municipio_Direccion__c);
            }
            
            if(s.ONE_Inicio_Ceremonia__c != null) {
                if(docLang != 'Eus'){
                    fields.put('fechaCeremonia', s.ONE_Inicio_Ceremonia__c.format('dd-MM-yyyy'));
                } else {
                    fields.put('fechaCeremonia', s.ONE_Inicio_Ceremonia__c.format('yyyy-MM-dd'));
                }
                fields.put('horaCeremonia', s.ONE_Inicio_Ceremonia__c.format('HH:mm'));
            }
            
            //DESPEDIDA
            if(s.ONE_Lugar_Despedida__c != null) {
                fields.put('lugarDespedida', s.ONE_Lugar_Despedida__r.Name);
            }
            if(s.ONE_Inicio_Despedida__c != null) {
                if(docLang != 'Eus'){
                    fields.put('fechaDespedida', s.ONE_Inicio_Despedida__c.format('dd-MM-yyyy'));
                } else {
                    fields.put('fechaDespedida', s.ONE_Inicio_Despedida__c.format('yyyy-MM-dd'));
                }
                
                fields.put('horaDespedida', s.ONE_Inicio_Despedida__c.format('HH:mm'));
            }
            
            //FOOTER
            if(s.ONE_Centro_Del_Expediente__c != null) {
                fields.put('nombreCentroDeTrabajo', s.ONE_Centro_Del_Expediente__r.Name);
                fields.put('telefonoCentroDeTrabajo', s.ONE_Centro_Del_Expediente__r.phone);
                fields.put('CalleCentro', s.ONE_Centro_Del_Expediente__r.ONE_Direccion__c != null ? s.ONE_Centro_Del_Expediente__r.ONE_Direccion__c : '');
                fields.put('ProvinciaCentro', s.ONE_Centro_Del_Expediente__r.ONE_Provincia__c != null ? s.ONE_Centro_Del_Expediente__r.ONE_Provincia__c : '');
                fields.put('webCentroDeTrabajo', s.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_Web__c);    
                fields.put('logo',
                        s.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c != null ? url_name(s.ONE_Centro_Del_Expediente__r.ONE_URL_logo__c) : s.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c != null ? url_name(s.ONE_Centro_Del_Expediente__r.ONE_Sociedad2__r.ONE_URL_logo__c) : '');
            }
            
            if (s.ONE_Destino_Final__r.Name != null || s.ONE_Lugar_Incineracion__r.Name != null){
                fields.put('LugarInciOInhum', s.ONE_Lugar_Incineracion__r.Name != null ? s.ONE_Lugar_Incineracion__r.Name : s.ONE_Destino_Final__r.Name);  
            }
            if (s.ONE_Inicio_Incineracion__c != null || s.ONE_Hora_Destino_Final__c != null){
                fields.put('fechaInciOInhum', s.ONE_Inicio_Incineracion__c != null ? s.ONE_Inicio_Incineracion__c.format('dd-MM-yyyy') : s.ONE_Hora_Destino_Final__c.format('dd-MM-yyyy'));
                fields.put('horaInciInhum', s.ONE_Inicio_Incineracion__c != null ? s.ONE_Inicio_Incineracion__c.format('HH:mm') : s.ONE_Hora_Destino_Final__c.format('HH:mm'));
            }
            
            if(s.ONE_Difunto__r?.ONE_Edad__c != null) {
                fields.put('edadDifunto', String.valueOf(s.ONE_Difunto__r.ONE_Edad__c));
            }

            if(s.ONE_Municipio_De_Defuncion__c != null) {
                fields.put('MunicipioDefuncion', s.ONE_Municipio_De_Defuncion__c);
            }

            if(s.ONE_Frase_De_Servicio__c != null) {
                fields.put('FraseServicio', s.ONE_Frase_De_Servicio__c);
            }
        }           
        String endpoint = ONE_PresseroSessionHelper.presseroEndpoint();
        String bodyXML = ONE_PresseroSessionHelper.autocompleteXMLgenerator(fields, docSession);
        
        HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        	req.setHeader('Accept', 'application/xml');
        	req.setMethod('POST');
            req.setBody(bodyXML);
        
		System.debug('bodyXML');
       	System.debug(bodyXML);
        
        Http http = new Http();
        
        HttpResponse res = http.send(req);
        
        System.debug('RESPONSE');
       	System.debug(res);
        
        if (res.getStatusCode() == 200) {
            return;
        } else {
            throw new CalloutException();
        }
    }
    
    public static void addNewDocSession(String tareaId, String docSession, String docCode, String docPwd, String docTemplateName, String nameSavedSession, String docObs, String docLang, String docLugar, String docType, String plantillaEdoc, String serviceId){
        
        ONE_Sesion__c session = new ONE_Sesion__c();
        session.ONE_Tarea__c = tareaId != '' ? tareaId : null;
        session.ONE_docSession__c = docSession;
        session.ONE_docCode__c = docCode;
        session.ONE_docPassword__c = docPwd;
        session.ONE_Nombre_Plantilla__c = docTemplateName; 
        session.Name = nameSavedSession.length() > 80 ? nameSavedSession.substring(0, nameSavedSession.length() - 80) : nameSavedSession;
        session.ONE_docObservaciones__c = docObs;
        session.ONE_docLang__c = docLang;
        session.ONE_docLugar__c = docLugar;
        session.ONE_docType__c = docType;
        session.ONE_Plantilla_Edoc__c = plantillaEdoc;
        session.ONE_Servicio__c = serviceId;
        
        insert session;
    }
    
    /*public static String splitPath(String filename) {
        if (filename == null)
            return null;
        List<String> parts = filename.split('/');
        filename = parts[parts.size()-1];
        return filename;
    }*/
    
    public static List<PresseroResult> presseroGetAndSavePDF(string tareaId, String docSession, String serviceId){
        PresseroResult result = new PresseroResult();
        
        String endpoint = ONE_PresseroSessionHelper.presseroEndpoint();
        String aproveXML = ONE_PresseroSessionHelper.aproveSession_XMLgenerator(docSession);
        
        HttpRequest reqAp = new HttpRequest();
            reqAp.setEndpoint(endpoint);
            reqAp.setHeader('Content-Type', 'text/xml; charset=utf-8');
        	reqAp.setHeader('Accept', 'application/xml');
        	reqAp.setMethod('POST');
            reqAp.setBody(aproveXML);
        
        Http http = new Http();
        HttpResponse resAp = http.send(reqAp);
        if (resAp.getStatusCode() == 200) {
            
            DOM.Document docAp = resAp.getBodyDocument();
            
            Boolean approvalStatus = docAp.getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('approveDocSessionResponse', 'http://www.edocbuilder.com/')
                .getChildElement('approveDocSessionResult', 'http://www.edocbuilder.com/')
                .getChildElement('approvalStatus', 'http://www.edocbuilder.com/').getText() == 'true';
            if (approvalStatus){	
                String pdfXML = ONE_PresseroSessionHelper.getPDF_XMLgenerator(docSession);

                HttpRequest reqPDF = new HttpRequest();
                    reqPDF.setEndpoint(endpoint);
                    reqPDF.setHeader('Content-Type', 'text/xml; charset=utf-8');
                    reqPDF.setHeader('Accept', 'application/xml');
                    reqPDF.setMethod('POST');
                    reqPDF.setBody(pdfXML);
                
                HttpResponse resPDF = http.send(reqPDF);
                
                if (resPDF.getStatusCode() == 200){

                    DOM.Document docPDF = resPDF.getBodyDocument();

                    String downloadURL = docPDF.getRootElement()
                        .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('getOrderFileResponse', 'http://www.edocbuilder.com/')
                        .getChildElement('getOrderFileResult', 'http://www.edocbuilder.com/').getText();
                
                	if(downloadURL != null){
                        ONE_Sesion__c session = [SELECT Id, Name, ONE_docType__c FROM ONE_Sesion__c WHERE ONE_docSession__c = :docSession LIMIT 1];
                        session.ONE_download_PDF_URL__c = downloadURL;
                        
                        HttpRequest downloadReq = new HttpRequest();
                            downloadReq.setEndpoint(downloadURL);
                            downloadReq.setMethod('GET');
        
                        HttpResponse downloadRes = http.send(downloadReq);
            
                        if (downloadRes.getStatusCode() == 200) {
                            ONE_Tarea__c t = new ONE_Tarea__c();
                            ONE_Expediente__c s = new ONE_Expediente__c();
                            if (tareaId != null && tareaId != ''){
                                t = [SELECT ONE_Expediente__c, ONE_Expediente__r.Name FROM ONE_Tarea__c WHERE Id = :tareaId LIMIT 1];            
                            }
                            else {
                                s = [SELECT Id, Name, RecordType.DeveloperName FROM ONE_Expediente__c WHERE Id = :serviceId LIMIT 1];
                            }
                            String basePdfName = 'PDF_Final_' + session.ONE_docType__c + '_' + (tareaId != null && tareaId != '' ? t.ONE_Expediente__r.Name : s.Name);
                            String finalPdfName = basePdfName + '_' + System.now().format('dd-MM-yyyy HH:mm') + '.pdf';
                                                        
                            List<ContentVersion> serviceCV = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE :basePdfName + '%' LIMIT 1];
                            
                            if (!serviceCV.isEmpty()) {
                                ContentVersion existingCV = serviceCV[0];
                                existingCV.Title = finalPdfName;
                                existingCV.VersionData = downloadRes.getBodyAsBlob();
                                update existingCV;
                            } else {
                                ContentVersion finalCV = new ContentVersion();
                                finalCV.Title = finalPdfName;
                                finalCV.PathOnClient = finalPdfName;
                                finalCV.VersionData = downloadRes.getBodyAsBlob();
                                finalCV.IsMajorVersion = false;
                                insert finalCV;
                                                                
                                Id finalConDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :finalCV.Id].ContentDocumentId;
                                
                                ContentDocumentLink finalCDL = new ContentDocumentLink();
                                finalCDL.ContentDocumentId = finalConDocId;
                                finalCDL.LinkedEntityId = tareaId != null && tareaId != '' ? t.ONE_Expediente__c : s.Id;
                                finalCDL.ShareType = 'V';
                                insert finalCDL;
                            }
                            
                            if (tareaId != null && tareaId != '') {
                                ContentVersion cv = new ContentVersion();
                                cv.Title = session.Name + '.pdf';
                                cv.PathOnClient =  session.Name + '.pdf';
                                cv.VersionData = downloadRes.getBodyAsBlob();
                                cv.IsMajorVersion = true;
                                Insert cv;
                                
                                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                    
                                ContentDocumentLink cdl = new ContentDocumentLink();
                                cdl.ContentDocumentId = conDocId;
                                cdl.LinkedEntityId = tareaId;
                                //V - Viewer permission. C - Collaborator permission. I - Inferred permission
                                cdl.ShareType = 'V';
                                Insert cdl;
                            }
                            
                        }
                        else {
							result.status = 'ERROR DESCARGA ' + downloadRes.getStatusCode() + '. ' + downloadRes.getStatus();
                        }
                        
                        update session;
                        result.status = 'OK';
                    } else {
                        result.status = 'ERROR DESCARGA ' + resPDF.getStatusCode() + '. ' + resPDF.getStatus();
                    }
                } 
                else {
                    result.status = 'ERROR URL PDF ' + resPDF.getStatusCode() + '. ' + resPDF.getStatus();
                }
            } 
            else {
                result.status = 'ERROR APROVAL ' + resAp.getStatusCode() + '. ' + resAp.getStatus();
            }            
        } 
        else {
            result.status = 'ERROR ' + resAp.getStatusCode() + '. ' + resAp.getStatus();
        }
        
        return new List<PresseroResult>{result};
    }
    
    public static List<PresseroResult> getPdfPreview(String docSession) {
        //get proof PDF
        PresseroResult result = new PresseroResult();
        String endpoint = ONE_PresseroSessionHelper.presseroEndpoint();
        HttpRequest reqPDF = new HttpRequest();
                    reqPDF.setEndpoint(endpoint);
                    reqPDF.setHeader('Content-Type', 'text/xml; charset=utf-8');
                    reqPDF.setHeader('Accept', 'application/xml');
                    reqPDF.setMethod('POST');
                    reqPDF.setBody(ONE_PresseroSessionHelper.getProofPdfBody(docSession));
        
        Http http = new Http();
        
        HttpResponse pdfRes = http.send(reqPDF);
        
        if (pdfRes.getStatusCode() == 200){
        
            DOM.Document doc = pdfRes.getBodyDocument();
            
            String previewUrl = doc.getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('getProofPDFResponse', 'http://www.edocbuilder.com/')
                .getChildElement('getProofPDFResult', 'http://www.edocbuilder.com/').getText();
                        
            HttpRequest getPreview = new HttpRequest();
                        getPreview.setEndpoint(previewUrl);
                        getPreview.setMethod('GET');
            
            HttpResponse getPreviewRes = http.send(getPreview);
            
            if (getPreviewRes.getStatusCode() == 200) {              
                ONE_Sesion__c session = [SELECT Id, Name, ONE_aceptadoFamilia__c FROM ONE_Sesion__c WHERE ONE_docSession__c = :docSession LIMIT 1];
                List<ContentDocumentLink> actualCdl = [SELECT ContentDocumentId
                                                    FROM ContentDocumentLink
                                                    WHERE LinkedEntityId =: session.Id];
                String actualVersion;
                ContentVersion actualCv;
                String newVersion = EncodingUtil.base64Encode(getPreviewRes.getBodyAsBlob());
				//COMPROBAMOS QUE EXISTA UNA VERSIÓN ANTERIOR
                if (actualCdl.size() > 0){
                    List<String> actualCldIds = new List<String>();
                    for (ContentDocumentLink cdl : actualCdl){
                        actualCldIds.add(cdl.ContentDocumentId);
                    }
                    ContentVersion signature;
                    List<ContentVersion> cvList = [SELECT Id, Title, VersionData, ContentDocumentId
                                  FROM ContentVersion
                                  WHERE ContentDocumentId IN :actualCldIds];
                    for (ContentVersion cv : cvList){
                        if (cv.Title.endsWith('.pdf')){
                        	actualCv = cv;
                        }
                        if (cv.Title.endsWith('.png')){
                            signature = cv;
                        }
                    }
                    actualVersion = EncodingUtil.base64Encode(actualCv.VersionData);
                    //SI LA NUEVA ES DIFERENTE GUARDAMOS LA NUEVA Y ELIMINAMOS LA FIRMA
                    if (actualVersion != newVersion){
                        session.ONE_aceptadoFamilia__c = false;
                        update session;
                        
                        if(signature != null){
                            ContentDocument signatureCD = [SELECT Id FROM ContentDocument WHERE Id =: signature.ContentDocumentId];
                            delete signatureCD;
                        }
                        actualCv.VersionData = getPreviewRes.getBodyAsBlob();
                        update actualCv;
                        
                        result.firstLoad = 'false';
                        result.contentData = newVersion;
                        result.previewDocumentVersionId = actualCv.Id;
                        result.previewDocumentId = actualCv.ContentDocumentId;
                    }
                    //EN CASO CONTRARIO NOS QUEDAMOS CON LA ANTIGUA
                    else {
                        result.firstLoad = 'false';
                        result.contentData = actualVersion;
                        result.previewDocumentVersionId = actualCv.Id;
                    	result.previewDocumentId = actualCv.ContentDocumentId; 
                    }
                }
                //SI NO HAY VERSION ANTIGUA CREAMOS PRIMERA VERSIÓN
                else {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = session.Name + '_preview.pdf';
                    cv.PathOnClient =  session.Name + '_preview.pdf';
                    cv.VersionData = getPreviewRes.getBodyAsBlob();
                    cv.IsMajorVersion = false;
                    insert cv;
                    
                    String conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
                    
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = conDocId;
                    cdl.LinkedEntityId = [SELECT Id FROM ONE_Sesion__c WHERE ONE_docSession__c = :docSession LIMIT 1].Id;
                    //V - Viewer permission. C - Collaborator permission. I - Inferred permission
                    cdl.ShareType = 'V';
                    insert cdl;
                    
                    result.firstLoad = 'true';
                    result.contentData = newVersion;
                    result.previewDocumentVersionId = cv.Id;
                    result.previewDocumentId = conDocId;
                }
    			result.status = 'OK';
            }
            else{
                result.status = 'ERROR GET PREVIEW ' + getPreviewRes.getStatusCode() + '. ' + getPreviewRes.getStatus();
            }
    	}
        else {
        	result.status = 'ERROR GET PREVIEW URL ' + pdfRes.getStatusCode() + '. ' + pdfRes.getStatus();  
        }
        return new List<PresseroResult>{result};
    }
    
    public static String url_name(String url) {
        List<String> splitted = url.split('/');
        String logoName = splitted[splitted.size()-1];
        if (logoName != null && logoName.endsWith('?')) {
            logoName = logoName.removeEnd('?');
        }
        System.debug('urlname: ' + logoName + '.png');
        return logoName + '.png';
    }
    
	@AuraEnabled
    public static void saveSign(String strSignElement,String recId){
 
        ONE_Sesion__c session = [SELECT Id, ONE_aceptadoFamilia__c FROM ONE_Sesion__c WHERE ONE_docSession__c = :recId LIMIT 1];
        
        if (session.ONE_aceptadoFamilia__c){
        	List<ContentDocumentLink> cdList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: session.Id];
            List<Id> contentDocumentIds = new List<Id>();
            for (ContentDocumentLink cdl : cdList) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
        	ContentVersion signature = [SELECT Title, PathOnClient, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds AND Title LIKE 'Firma%'];
            signature.VersionData = EncodingUtil.base64Decode(strSignElement);
            signature.PathOnClient = 'Firma-'+ System.now().format('dd-MM-yyyy HH:mm') +'.png';
            signature.Title = 'Firma-'+ System.now().format('dd-MM-yyyy HH:mm') +'.png';
            update signature;
        }
        else{
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = 'Firma-'+ System.now().format('dd-MM-yyyy HH:mm') +'.png';
            cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
            cVersion.Title = 'Firma-'+ System.now().format('dd-MM-yyyy HH:mm') +'.png';
            cVersion.VersionData = EncodingUtil.base64Decode(strSignElement);
            Insert cVersion;
           
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
           
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;
            cDocLink.LinkedEntityId = session.Id;
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
            
            session.ONE_aceptadoFamilia__c = true;
            update session;
        }
    }
 
    
    public class PresseroRequest{
        @InvocableVariable(label='Opción de acción' description='1 - Nueva Sesión // 2 - Autocompletar Plantilla // 3 - Get and Save PDF // 4 - Get Pdf Preview' required=true)
        public String option;
        
        @InvocableVariable(label='ID de la tarea' description='Requerido si no hay Id de servicio')
        public String tareaId;
        
        @InvocableVariable(label='docCode' description='requerido para la opción 1')
        public String docCode;

        @InvocableVariable(label='docPassword' description='requerido para la opción 1')
        public String docPwd;
        
        @InvocableVariable(label='docTemplateName' description='requerido para la opción 1')
        public String docTemplateName;
        
        @InvocableVariable(label='Nombre de la sessión' description='requerido para la opción 1')
        public String nameSavedSession;
        
        @InvocableVariable(label='docSession' description='requerido para las opciones 2, 3 y 4')
        public String docSession;
        
        @InvocableVariable(label='docLang' description='requerido para las opción 1 y 2 : Cat | Esp | Eus')
        public String docLang;
        
        @InvocableVariable(label='docObs' description='requerido para la opción 1')
        public String docObs;
        
        @InvocableVariable(label='docLugar' description='requerido para las opciones 1 y 2')
        public String docLugar;
        
        @InvocableVariable(label='docType' description='requerido para la opción 1 y 2')
        public String docType;
        
        @InvocableVariable(label='plantillaEdoc' description='requerido para la opción 1')
        public String plantillaEdoc;
        
        @InvocableVariable(label='Id del servicio' description='requerido si no hay id de la tarea')
        public String serviceId;

        @InvocableVariable(label='Link QR' description='requerido para la opción 2')
        public String linkQr;
    }
    
    public class PresseroResult{
        @InvocableVariable 
        public String status;
        
        @InvocableVariable
        public String previewDocumentId;
        
        @InvocableVariable
        public String newDocSession;
        
        @InvocableVariable
        public String previewDocumentVersionId;
        
        @InvocableVariable
        public String contentData;
        
        @InvocableVariable
        public String firstLoad;
    }
}
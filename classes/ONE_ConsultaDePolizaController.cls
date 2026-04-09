/**
 * Created by mbujak003 on 11.01.2021.
 */

public with sharing class ONE_ConsultaDePolizaController {
 

    @AuraEnabled
    public static String invokeIntegration(Object params) {
        String response = '';
        Map<String, Object> parsedParams = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(params));
        String integrationType = String.valueOf(parsedParams.get('integrationType')).toLowerCase().trim().removeStart('(').removeEnd(')');
        parsedParams.remove('integrationType');

        if (integrationType.equalsIgnoreCase(String.valueOf(ONE_InsuranceIntegrationCallout.InsuranceService.GENERALI))) {
            response = new ONE_InsuranceIntegrationCallout.GeneraliInsuranceCallout(parsedParams).invokeCallout(true).getBody();
        } else if (integrationType.equalsIgnoreCase(String.valueOf(ONE_InsuranceIntegrationCallout.InsuranceService.CAJAMAR))) {
            response = new ONE_InsuranceIntegrationCallout.CajamarInsuranceCallout(parsedParams).invokeCallout(true).getBody();
        } else if (integrationType.equalsIgnoreCase(String.valueOf(ONE_InsuranceIntegrationCallout.InsuranceService.KUTXABANK))) {
            // DOM.Document xml = new DOM.Document();
            // String xmlString = new ONE_InsuranceIntegrationCallout.KutxabankInsuranceCallout(parsedParams).invokeCallout(true).getBody();
            // xml.load(xmlString);
            // response = formatResponseKBS(xml);
            response = new ONE_InsuranceIntegrationCallout.KutxabankInsuranceCallout(parsedParams).invokeCallout(true).getBody();
            System.debug('RESPONSE KUTXA: ' + response);
            response = adaptNewKBSJson(response);
        }

        System.debug('RESPONSE: ' + response);
        
        return response;
    }

    public static String adaptNewKBSJson(String rawJson) {
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(rawJson);
        Integer status = (Integer) parsed.get('status');

        String json = '{';

        if (status == 200) {
            json += '"statusCode": 200,';
            json += '"code": "OK",';
            json += '"message": "",';
            json += '"listaErrores": null,';
            json += '"listaResultados": [';

            List<Object> resultado = (List<Object>) parsed.get('resultado');

            for (Object item : resultado) {
                Map<String, Object> poliza = (Map<String, Object>) item;
                json += '{';
                for (String key : poliza.keySet()) {
                    Object value = poliza.get(key);
                    String name = key;
                    String stringValue = String.valueOf(value);

                    switch on name {
                        when 'FormaPago' {
                            name = 'indPrimaUnica';
                        }
                        when 'Situacion' {
                            stringValue = stringValue == '01' ? 'ALTA' : stringValue == '02' ? 'BAJA' : stringValue;
                        }
                        when 'Mediador' {
                            stringValue = stringValue == '2095' ? 'Kutxabank' : stringValue == '0237' ? 'Cajasur' : stringValue;
                        }
                        when 'Sexo' {
                            stringValue = stringValue == 'H' ? 'Hombre' : stringValue == 'M' ? 'Mujer' : 'Indefinido';
                        }
                        when 'FechaNacimiento' {
                            stringValue = stringValue.substring(0, 4) + '-' + 
                                stringValue.substring(4, 6) + '-' + 
                                stringValue.substring(6, 8);
                        }
                        when 'FechaEfectoPoliza' {
                            stringValue = stringValue.substring(0, 4) + '-' + 
                                stringValue.substring(4, 6) + '-' + 
                                stringValue.substring(6, 8);
                        }
                    }

                    json += '"' + name + '": "' + stringValue + '",';
                }
                json = json.removeEnd(',') + '},';
            }

            json = json.removeEnd(',') + ']}';

        } else {
            Map <String, Object> error;
            if (status == 203) {
                error = (Map<String, Object>) parsed.get('resultado');
            }
            else if (status != 503){
                error = (Map<String, Object>) parsed.get('message');
            }
            String descripcion = 'Kutxabank seguros ha cerrado el servicio temporalmente';
            if(status != 503) descripcion = (String) error.get('Message');
            if(status == 404 || status == 401 || status == 503 || status == 500 || status == 203) { //Errores controlados 401 - No hay póliza, 203 - No autorizados a acceder a la póliza, 401 - Error de autenticación, 503 - Servicio no disponible, 500 - Error interno del servidor (Token)
                json += '"statusCode": 200,';
                json += '"code": "' + status.toString() + '",';
                json += '"message": "' + descripcion + '",';
                json += '"listaErrores": null,';
                json += '"listaResultados": null';
                json += '}';
            } else {
                json += '"statusCode": '+ status.toString() +',';
                json += '"code": "' + status.toString() + '",';
                json += '"message": "' + descripcion + '",';
                json += '"listaErrores": ["'+ descripcion +'"],';
                json += '"listaResultados": null';
                json += '}';
            }
        }

        return json;
    }

    // public static String formatResponseKBS(Dom.Document xml){
    //     DOM.XMLNode envelope = xml.getRootElement();
    //     DOM.XmlNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
    //     DOM.XmlNode consultaPolizaResponse = body.getChildElement('ConsultaPolizaResponse', 'http://wcf.catalanaoccidente.com/VID/Gestion/Asistea/BE/KBS/ConsultaPoliza');
    //     DOM.XmlNode consultaPolizaResult = consultaPolizaResponse.getChildElement('ConsultaPolizaResult', 'http://wcf.catalanaoccidente.com/VID/Gestion/Asistea/BE/KBS/ConsultaPoliza');
    //     String code = consultaPolizaResult.getChildElement('Codigo', 'http://schemas.datacontract.org/2004/07/GCO.Arquitectura.Framework').getText();
    //     String descripcion = consultaPolizaResult.getChildElement('Descripcion', 'http://schemas.datacontract.org/2004/07/GCO.Arquitectura.Framework').getText();
    //     System.debug(code + ' / ' + descripcion);

    //     String json = '{';

    //     if(code == '0'){
    //         json += '"statusCode": 200,';
    //         json += '"code": "OK",';
    //         json += '"message": "",';
    //         json += '"listaErrores": null,';
    //         json += '"listaResultados": [';

    //         DOM.XmlNode salida = consultaPolizaResponse.getChildElement('salida', 'http://wcf.catalanaoccidente.com/VID/Gestion/Asistea/BE/KBS/ConsultaPoliza');
    //         DOM.XmlNode polizas = salida.getChildElement('Polizas', 'http://schemas.datacontract.org/2004/07/VID.Gestion.Asistea.BE.KBS');
    //         for(Dom.XMLNode poliza : polizas.getChildElements()) {
    //             json += '{';
    //             for(Dom.XMLNode att : poliza.getChildElements()){
    //                 String name = att.getName();
    //                 String value = att.getText();

    //                 switch on name {
    //                     when 'FormaPago' {
    //                         name = 'indPrimaUnica';
    //                         value = value;
    //                     }
    //                     when 'Situacion' {
    //                         value = value == '01' ? 'ALTA' : value == '02' ? 'BAJA' : value; 
    //                     } 
    //                     when 'Mediador' {
    //                         value = value == '2095' ? 'Kutxabank' : value == '0237' ? 'Cajasur' : value;
    //                     }
    //                     when 'Sexo' {
    //                         value = String.fromCharArray(new List<Integer> { Integer.valueOf(value) }) == 'M' 
    //                             ? 'Mujer'
    //                             : String.fromCharArray(new List<Integer> { Integer.valueOf(value) }) == 'H'
    //                                 ? 'Hombre'
    //                                 : 'Indefinido';
    //                     }
    //                 }

    //                 json += '"' + name + '": "' + value + '",';
    //             }
    //             json = json.removeEnd(',');
    //             json += '},';
    //         }
    //         json = json.removeEnd(',');
    //         json += ']}';
    //     } else {
    //         if(code == '404'){
    //             // NOT FOUND 
    //             json += '"statusCode": 200,';
    //             json += '"code": "' + code + '",';
    //             json += '"message": "' + descripcion + '",';
    //             json += '"listaErrores": null,';
    //             json += '"listaResultados": null';
    //             json += '}';
    //         } else if (code != '203' || code != '401' || code != '400'){
    //             json += '"statusCode": '+ code +',';
    //             json += '"code": "' + code + '",';
    //             json += '"message": "' + descripcion + '",';
    //             json += '"listaErrores": ["'+ descripcion +'"],';
    //             json += '"listaResultados": null';
    //             json += '}';
    //         } 
    //         else { //error controlado por kbs
    //             json += '"statusCode": 400,';
    //             json += '"code": "' + code + '",';
    //             json += '"message": "' + descripcion + '",';
    //             json += '"listaErrores": ["'+ descripcion +'"],';
    //             json += '"listaResultados": null';
    //             json += '}';
    //         }
    //     }

    //     return json;
    // }

    @AuraEnabled
    public static void anadirAction(Object obj, String tipo) {
        System.debug('AÑADIR');

        List<Object> parsedList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        Map<String, Object> parsedObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(parsedList[0]));
        
        InsuranceDataWrapper idw = new InsuranceDataWrapper(parsedObject, tipo);

        System.debug(idw);

        List<Account> accs = ONE_AccountHelper.fetchAccountsByDocumento(idw.nDocumento);
        List<ONE_Contrato__c> contracts = ONE_ContratoHelper.fetchContratsByParams(idw.companiaAseguradora, idw.pol, idw.ramo);

        System.debug('ACC: ' + accs);
        System.debug('CONTRATOS: ' + contracts);

        if (accs.isEmpty()) {
            Account pa = createPersonAccount(idw, tipo);
            if (contracts.isEmpty()) {
                createNewContract(idw, pa);
            } else {
                updateExistingContract(contracts[0], idw);
                System.debug(contracts);
                pa.ONE_Polizas_1__pc = contracts[0].Id;
                update pa;
            }
        } else {
            if (accs[0].ONE_Polizas_1__pc != null) {
                if (checkPoliza1params(accs[0], idw)) {
                    updateExistingContract(contracts[0], idw);
                } else {
                    if (accs[0].ONE_Poliza_2__pc != null) {
                        if (checkPoliza2params(accs[0], idw)) {
                            updateExistingContract(contracts[0], idw);
                        }
                    } else {
                        if (contracts.isEmpty()) {
                            createNewContract(idw, accs[0]);
                        } else {
                            if (accs[0].ONE_Polizas_1__pc == null) {
                                updateExistingContract(contracts[0], idw);
                                accs[0].ONE_Polizas_1__pc = contracts[0].Id;
                                update accs;
                            } else {
                                updateExistingContract(contracts[0], idw);
                                accs[0].ONE_Poliza_2__pc = contracts[0].Id;
                                update accs;
                            }
                        }
                    }
                }
            } else {
                if (accs[0].ONE_Poliza_2__pc != null) {
                    if (checkPoliza2params(accs[0], idw)) {
                        updateExistingContract(contracts[0], idw);
                    }
                } else {
                    if (contracts.isEmpty()) {
                        createNewContract(idw, accs[0]);
                    } else {
                        if (accs[0].ONE_Polizas_1__pc == null) {
                            updateExistingContract(contracts[0], idw);
                            accs[0].ONE_Polizas_1__pc = contracts[0].Id;
                            update accs;
                        } else {
                            updateExistingContract(contracts[0], idw);
                            accs[0].ONE_Poliza_2__pc = contracts[0].Id;
                            update accs;
                        }
                    }

                }
            }
        }
    }

    private static Boolean updateExistingContract(ONE_Contrato__c handledContract, InsuranceDataWrapper idw) {
        handledContract.ONE_Ramo__c = idw.ramo;
        handledContract.ONE_Pol__c = idw.pol;
        handledContract.ONE_Compania_Aseguradora__c = idw.companiaAseguradora;
        handledContract.ONE_Capital__c = idw.capital;
        handledContract.ONE_Fecha_De_Contrato__c = idw.fechaDeContrato;
        handledContract.ONE_Indicador_De_Prima_Unica__c = idw.indicadorDePrimaUnica;
        handledContract.ONE_Funeraria_Deseada__c = idw.funerariaDeseada;
        handledContract.ONE_Aplicacion__c = idw.aplicacion;
        handledContract.ONE_Capital_Adicional__c = idw.capitalAdicional;
        handledContract.ONE_Repatriaci_n__c = idw.repatriacion == null ? false : idw.repatriacion;

        update handledContract;
        return true;
    }

    private static Boolean createNewContract(InsuranceDataWrapper idw, Account pa) {
        Savepoint sp = Database.setSavepoint();
        try {
            ONE_Contrato__c createdContract = new ONE_Contrato__c(
                ONE_Compania_Aseguradora__c = idw.companiaAseguradora,
                ONE_Ramo__c = idw.ramo,
                ONE_Pol__c = idw.pol,
                ONE_Aplicacion__c = idw.aplicacion,
                ONE_Capital__c = idw.capital,
                ONE_Fecha_De_Contrato__c = idw.fechaDeContrato,
                ONE_Indicador_De_Prima_Unica__c = idw.indicadorDePrimaUnica,
                ONE_Funeraria_Deseada__c = idw.funerariaDeseada,
                ONE_Capital_Adicional__c = idw.capitalAdicional,
                ONE_Repatriaci_n__c = idw.repatriacion == null ? false : idw.repatriacion,
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.CONTRATO, ONE_CommonConstants.CONT_RT_M1)
            );
            insert createdContract;
            pa.ONE_Polizas_1__pc = createdContract.Id;
            update pa;
            System.debug('CONTRATO CREADO: ' + createdContract);
        } catch (Exception ex) {
            System.debug('ERROR AL CREAR EL CONTRATO: ' + ex);
            Database.rollback(sp);
            throw new DmlException(ex);
        }
        return true;
    }

    public static Account createPersonAccount(InsuranceDataWrapper idw, String tipo) {
        System.debug('INIT CREATE ACCOUNT');
        Account acc;
        try {
            System.debug('CUMPLE::' + idw.fechaDeNacimiento);
            acc = new Account(
                RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(ONE_CommonConstants.ACCOUNT, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR),
                FirstName = idw.nombre,
                LastName = String.format('{0} {1}', new List<String>{
                    idw.apellido1, idw.apellido2
                }),
                ONE_Fecha_de_nacimiento__pc = idw.fechaDeNacimiento,
                ONE_Sexo__c = idw.sexo,
                ONE_Codigo_Postal__pc = idw.billingPostalCode,
                ONE_Municipio__pc = idw.poblacion,
                ONE_Provincia__pc = idw.provincia != null ? getPicklistApiName(idw.provincia) : null,
                ONE_N_Documento__pc = idw.nDocumento
            );
            if (tipo == 'kutxabank') {
                String fechaNormalizada = idw.fechaSituacion.replace('Z', '').replace('T', '');
                fechaNormalizada = fechaNormalizada.substring(0, fechaNormalizada.indexOf('.'));
                fechaNormalizada = fechaNormalizada.substring(0, 10) + ' ' + fechaNormalizada.substring(10);
                System.debug('FECHA NORMALIZADA: ' + fechaNormalizada);
                acc.ONE_Fecha_De_Defuncion2__c = idw.fechaSituacion != null ? DateTime.valueOf(fechaNormalizada) : null;
            }
            insert acc;
            System.debug(acc);
            return acc;
        } catch (Exception ex) {
            throw new DmlException(ex);
        }
    }

    public static Boolean checkPoliza1params(Account a, InsuranceDataWrapper idw) {
        return (a.ONE_Polizas_1__pr.ONE_Ramo__c == idw.ramo &&
            a.ONE_Polizas_1__pr.ONE_Compania_Aseguradora__c == idw.companiaAseguradora &&
            a.ONE_Polizas_1__pr.ONE_Pol__c == idw.pol
        ) ? true : false;
    }

    public static Boolean checkPoliza2params(Account a, InsuranceDataWrapper idw) {
        return (a.ONE_Poliza_2__pr.ONE_Ramo__c == idw.ramo &&
            a.ONE_Poliza_2__pr.ONE_Compania_Aseguradora__c == idw.companiaAseguradora &&
            a.ONE_Poliza_2__pr.ONE_Pol__c == idw.pol
        ) ? true : false;
    }

    public static String getPicklistApiName(String value) {
        String apiName;
        Schema.DescribeFieldResult fieldResult = Account.ONE_Provincia__pc.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry v : values) {
            if (v.getLabel().toLowerCase() == value.toLowerCase()) {
                apiName = v.getValue();
                break;
            }
        }
        return apiName;
    }

    public class InsuranceDataWrapper {
        public String nombre { get; private set; }
        public String companiaAseguradora { get; private set; }
        public String apellido1 { get; private set; }
        public String apellido2 { get; private set; }
        public Decimal capital { get; private set; }
        public Date fechaDeContrato { get; private set; }
        public Date fechaDeNacimiento { get; private set; }
        public String indicadorDePrimaUnica { get; private set; }
        public String funerariaDeseada { get; private set; }
        public String sexo { get; private set; }
        public String billingCity { get; private set; }
        public String billingState { get; private set; }
        public String billingPostalCode { get; private set; }
        public String nDocumento { get; private set; }
        public String ramo { get; private set; }
        public String pol { get; private set; }
        public String aplicacion { get; private set; }
        public String provincia { get; private set; }
        public String poblacion { get; private set; }
        public Decimal capitalAdicional { get; private set; }
        public Boolean repatriacion { get; private set; }
        public String situacion { get; private set; }
        public String servicioContratado { get; private set; }
        public String fechaSituacion { get; private set; }

        public InsuranceDataWrapper(Map<String, Object> key2Value, String tipo) {

            if(tipo == 'generali' || tipo == 'cajamar') {
                // DATOS DE CONTACTO
                nombre = String.valueOf(key2Value.get('nombre') != null ? key2Value.get('nombre') : '');
                apellido1 = String.valueOf(key2Value.get('apellido1') != null ? key2Value.get('apellido1') : '');
                apellido2 = String.valueOf(key2Value.get('apellido2') != null ? key2Value.get('apellido2') : '');
                nDocumento = String.valueOf(key2Value.get('dni') != null ? key2Value.get('dni') : '');
                sexo = String.valueOf(key2Value.get('sexo') != null ? key2Value.get('sexo') : '');
                fechaDeNacimiento = key2Value.get('fNacimiento') != null ? stringToDate(String.valueOf(key2Value.get('fNacimiento')), tipo) : null;

                // PÓLIZA
                companiaAseguradora = String.valueOf(key2Value.get('cia') != null ? key2Value.get('cia') : '');
                ramo = String.valueOf(key2Value.get('ramo') != null ? key2Value.get('ramo') : '');
                pol = String.valueOf(key2Value.get('pol') != null ? key2Value.get('pol') : '');
                
                Decimal newCapital, newCapitalAd;
                if (key2Value.get('fAltaAsegurado') != null) {
                    if (String.valueOf(key2Value.get('capGarDecesos')).contains(',')) {
                        newCapital = Decimal.valueOf(String.valueOf(key2Value.get('capGarDecesos')).replace('.', '').replace(',', '.'));
                    } else {
                        newCapital = Decimal.valueOf(String.valueOf(key2Value.get('capGarDecesos')));
                    }
                    
                    if(key2Value.containsKey('capitalAdicionalDecesos') && String.valueOf(key2Value.get('capitalAdicionalDecesos')) != null){
                        if (String.valueOf(key2Value.get('capitalAdicionalDecesos')).contains(',')) {
                            newCapitalAd = Decimal.valueOf(String.valueOf(key2Value.get('capitalAdicionalDecesos')).replace('.', '').replace(',', '.'));
                        } else {
                            newCapitalAd = Decimal.valueOf(String.valueOf(key2Value.get('capitalAdicionalDecesos')));
                        }
                    } 

                    fechaDeContrato = stringToDate(String.valueOf(key2Value.get('fAltaAsegurado')), tipo);
                }
                capital = newCapital;
                capitalAdicional = newCapitalAd;

                indicadorDePrimaUnica = String.valueOf(key2Value.get('indPrimaUnica') != null ? key2Value.get('indPrimaUnica') : '');
                funerariaDeseada = String.valueOf(key2Value.get('wnomco') != null ? key2Value.get('wnomco') : '');
                aplicacion = String.valueOf(key2Value.get('aplicacion') != null ? key2Value.get('aplicacion') : '');

                if(key2Value.containsKey('repatriacion')){
                    if (key2Value.get('repatriacion') != null){
                        repatriacion = String.valueOf(key2Value.get('repatriacion')) == 'true' ? true : false;
                    } else {
                        repatriacion = false;
                    }
                }

                // DIRECCIONES
                billingCity = String.valueOf(key2Value.get('poblacion') != null ? key2Value.get('poblacion') : '');
                billingState = String.valueOf(key2Value.get('provincia') != null ? key2Value.get('provincia') : '');
                billingPostalCode = String.valueOf(key2Value.get('codPostal') != null ? key2Value.get('codPostal') : '');

                provincia = String.valueOf(key2Value.get('provincia') != null ? key2Value.get('provincia') : '');
                poblacion = String.valueOf(key2Value.get('poblacion') != null ? key2Value.get('poblacion') : '');
            } else if( tipo == 'kutxabank') {
                // DATOS DE CONTACTO
                nombre = String.valueOf(key2Value.get('NombreAsegurado') != null ? key2Value.get('NombreAsegurado') : '');
                apellido1 = String.valueOf(key2Value.get('Apellido1Asegurado') != null ? key2Value.get('Apellido1Asegurado') : '');
                apellido2 = String.valueOf(key2Value.get('Apellido2Asegurado') != null ? key2Value.get('Apellido2Asegurado') : '');
                nDocumento = String.valueOf(key2Value.get('NifAsegurado') != null ? key2Value.get('NifAsegurado') : '');
                sexo = String.valueOf(key2Value.get('Sexo') != null ? key2Value.get('Sexo') : '');
                fechaDeNacimiento = key2Value.get('FechaNacimiento') != null ? stringToDate(String.valueOf(key2Value.get('FechaNacimiento')), tipo) : null;

                // PÓLIZA
                companiaAseguradora = String.valueOf(key2Value.get('Mediador') != null ? key2Value.get('Mediador') : '');
                pol = String.valueOf(key2Value.get('NumPoliza') != null ? key2Value.get('NumPoliza') : '');
                
                Decimal newCapital, newCapitalAd;
                if (key2Value.get('FechaEfectoPoliza') != null) {
                    if (String.valueOf(key2Value.get('SumaAsegurada')).contains(',')) {
                        newCapital = Decimal.valueOf(String.valueOf(key2Value.get('SumaAsegurada')).replace('.', '').replace(',', '.'));
                    } else {
                        newCapital = Decimal.valueOf(String.valueOf(key2Value.get('SumaAsegurada')));
                    }

                    fechaDeContrato = stringToDate(String.valueOf(key2Value.get('FechaEfectoPoliza')), tipo);
                }
                capital = newCapital;

                indicadorDePrimaUnica = String.valueOf(key2Value.get('indPrimaUnica') != null ? key2Value.get('indPrimaUnica') : '');

                // DIRECCIONES
                billingCity = String.valueOf(key2Value.get('Poblacion') != null ? key2Value.get('Poblacion') : '');
                billingPostalCode = String.valueOf(key2Value.get('CodigoINE') != null ? key2Value.get('CodigoINE') : '');

                poblacion = String.valueOf(key2Value.get('Poblacion') != null ? key2Value.get('Poblacion') : '');

                situacion = String.valueOf(key2Value.get('Situacion') != null ? key2Value.get('Situacion') : '');
                servicioContratado = String.valueOf(key2Value.get('ServicioContratado') != null ? key2Value.get('ServicioContratado') : '');
                fechaSituacion = String.valueOf(key2Value.get('fechaSituacion') != null ? key2Value.get('fechaSituacion') : '');
            }
        }

        private Date stringToDate(String fecha, String tipo){
            /*
                Ejemplo de date:
                    GENERALI = 01-04-2022
                    KUTXA = nuevo formato 2018-02-01 (antiguo 2018-02-01T00:00:00)
            */
            Date fechaDate;
            List<String> fNacimiento = String.valueOf(fecha.split('T')[0]).split('-');
            if(tipo == 'kutxabank'){
                fechaDate = Date.newInstance(
                    Integer.valueOf(fecha.split('-')[0]),
                    Integer.valueOf(fecha.split('-')[1]),
                    Integer.valueOf(fecha.split('-')[2])
                );
            } else {
                fechaDate = Date.newInstance(
                    Integer.valueOf(fNacimiento[2]),
                    Integer.valueOf(fNacimiento[1]),
                    Integer.valueOf(fNacimiento[0])
                );
            }
            return fechaDate;
        }
    }
}
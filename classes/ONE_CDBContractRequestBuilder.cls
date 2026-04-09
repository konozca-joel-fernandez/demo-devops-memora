/**
 * Created by mchruscick001 on 04.10.2021 11:59.
 */

public with sharing class ONE_CDBContractRequestBuilder {
	//Static variable definition
    static final String DIFUNT_NODE_NAME = 'difunt', DECLARANT_NODE_NAME = 'declarant',
            TITULAR_FRA_NODE_NAME = 'titular_fra', SOLIC_INCINE_NODE_NAME = 'solic_incine',
            DEFUNCION_NODE_NAME = 'defuncio', MORTUORIA_NODE_NAME = 'mortuoria',
            PARROQUIA_NODE_NAME = 'parroquia', COMPLEMENTS_NODE_NAME = 'complements';
	
    //Call methods to generate the request call
    public static Dom.Document buildRequest(ONE_Presupuesto__c onePresupuesto) {
        Dom.Document soapXMLDocument = new Dom.Document();
        Dom.XmlNode soapDocument = ONE_CDBSoapRequestBuilder.buildRequestBodyBase(soapXMLDocument);
        buildBaseParameters(soapDocument, onePresupuesto);
        buildDifuntNodeWithParameters(soapDocument, onePresupuesto);
        buildDeclarantNodeWithParametersIfRecordExists(soapDocument, onePresupuesto);
        buildTitularFraNodeWithParameters(soapDocument, onePresupuesto);
        buildSolicIncineNodeWithParameters(soapDocument, onePresupuesto);
        buildDefuncionNodeWithParameters(soapDocument, onePresupuesto);
        buildMortuoriaNodeWithParameters(soapDocument, onePresupuesto);
        buildParroquiaNodeWithParametersIfRecordExists(soapDocument, onePresupuesto);
        buildComplementsNodeWithParameters(soapDocument, onePresupuesto);
        return soapXMLDocument;
    }
	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildBaseParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'prosol', ONE_CDBReservationService.DEFAULT_IDENTIFICATION);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'ususol', ONE_CDBReservationService.DEFAULT_USERNAME);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'tipus', onePresupuesto?.ONE_Tipo_De_Solicitud_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'sepultura', onePresupuesto?.ONE_Codigo_General_Sepultura_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'basetaut', onePresupuesto?.ONE_Expediente__r?.ONE_Medida_Base_Feretro__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'altutaut', onePresupuesto?.ONE_Expediente__r?.ONE_Medida_altura_feretro__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'fondtaut', onePresupuesto?.ONE_Expediente__r?.ONE_Medida_Fondo_Feretro__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'nomcontac', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.FirstName + ' ' + onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.LastName);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'telcontac', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.PersonMobilePhone);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'capital', ONE_CDBRequestBuilderUtilities.getAsStringWithCommaSeparator(onePresupuesto?.ONE_Capital_Restante_CB__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'observac', onePresupuesto?.ONE_Observaciones__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(soapDocument, 'agent', onePresupuesto?.ONE_Asesor_Peticion_CB__r?.Name);
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildDifuntNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        Dom.XmlNode difuntNode = soapDocument.addChildElement(DIFUNT_NODE_NAME, null, null);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dicodicb', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_Difunto_CBSA__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'didires', ONE_CDBRequestBuilderUtilities.getShortTypeOfDeceased(onePresupuesto?.ONE_Expediente__r?.ONE_Tipo_De_Difunto__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'ditipser', onePresupuesto?.ONE_Expediente__r?.ONE_Tipo_De_Servicio_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'diestdif', onePresupuesto?.ONE_Expediente__r?.ONE_Estado_Del_Difunto__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dicaumor', ONE_CDBRequestBuilderUtilities.getCausasDefuncion(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinom', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.FirstName);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dicog1', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.LastName);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinomcol', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nombre_Coloquial__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'ditipdocu', ONE_CDBRequestBuilderUtilities.getShortTypeOfDocument(onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Tipo_de_documento__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinumdocu', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_N_Documento__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinompais', ONE_CDBRequestBuilderUtilities.getLongCountryName(onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Pais__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dicodprovi', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Provincia__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinommunic', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Municipio__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dicarrer', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'diampl1', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Ampliacion_De_Direccion_1__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'diampl2', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Ampliacion_De_Direccion_2__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinumcar', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Numero_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dicomnu', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_BIS__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'diescal', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Escalera_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dipis', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Piso_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'diporta', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Puerta_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dizip', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Codigo_Postal__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'ditelef', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.PersonMobilePhone);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'diemail', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.PersonEmail);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinaixe', ONE_CDBRequestBuilderUtilities.getFormattedDate(onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_de_nacimiento__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'disexe', ONE_CDBRequestBuilderUtilities.getShortSex(onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Sexo__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'didatdef', ONE_CDBRequestBuilderUtilities.getFormattedDate(onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dihordef', ONE_CDBRequestBuilderUtilities.getTime(onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Fecha_De_Defuncion2__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'didatser', ONE_CDBRequestBuilderUtilities.getFormattedDate(onePresupuesto?.ONE_Expediente__r.ONE_Fecha_Hora_Ceremonia_CBSA__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dihorser', ONE_CDBRequestBuilderUtilities.getTime(onePresupuesto?.ONE_Expediente__r.ONE_Fecha_Hora_Ceremonia_CBSA__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinompa', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Padres__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinomma', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nombre_De_La_Madre__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dillonai', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Lugar_de_nacimiento__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dinacio', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Nacionalidad__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'diecevil', onePresupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.ONE_Estado_Civil__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'didatexp', ONE_CDBRequestBuilderUtilities.getFormattedDate(onePresupuesto?.ONE_Expediente__r.ONE_Inicio_Velacion__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dihorexp', ONE_CDBRequestBuilderUtilities.getTime(onePresupuesto?.ONE_Expediente__r.ONE_Inicio_Velacion__c));
    }
    
	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildDeclarantNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        Dom.XmlNode difuntNode = soapDocument.addChildElement(DECLARANT_NODE_NAME, null, null);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'denom', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.FirstName);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'decog1', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.LastName);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'detipdocu', ONE_CDBRequestBuilderUtilities.getShortTypeOfDocument(onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Tipo_de_documento__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'denumdocu', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_N_Documento__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'denompais', ONE_CDBRequestBuilderUtilities.getLongCountryName(onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Pais__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'decodprovi', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Provincia__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'denommunic', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Municipio__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'decarrer', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'deampl1', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Ampliacion_De_Direccion_1__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'deampl2', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Ampliacion_De_Direccion_2__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'denumcar', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Numero_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'decomnu', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_BIS__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'deescal', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Escalera_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'depis', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Piso_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'deporta', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Puerta_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'dezip', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Codigo_Postal__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'detelef', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.PersonMobilePhone);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'detelef2', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Otro_Telefono__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'deemail', onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.PersonEmail);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(difuntNode, 'deparentiu', ONE_CDBRequestBuilderUtilities.getDeparentiu(onePresupuesto?.ONE_Expediente__r?.ONE_Relacion_Declarante_Y_Difunto__c,onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__r?.ONE_Sexo__c));
    }
    
	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildTitularFraNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        Dom.XmlNode titularFraNode = soapDocument.addChildElement(TITULAR_FRA_NODE_NAME, null, null);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'ticodi', onePresupuesto?.ONE_Codigo_Titular_CB__r.ONE_Autonumerico_Codigo_Titular_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'titipus', ONE_CDBRequestBuilderUtilities.getShortBusinessType(onePresupuesto?.ONE_Expediente__r?.ONE_Servicio__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tinom', ONE_CDBRequestBuilderUtilities.getTinom(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'ticog1', ONE_CDBRequestBuilderUtilities.getTicog1(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'titipdocu', ONE_CDBRequestBuilderUtilities.getShortTypeOfDocument(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Tipo_de_documento__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tinumdocu', ONE_CDBRequestBuilderUtilities.getTinumdocu(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tinompais', ONE_CDBRequestBuilderUtilities.getLongCountryNameFromAccountCountryPicklist(ONE_CDBRequestBuilderUtilities.getTinompais(onePresupuesto)));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'ticodprovi', ONE_CDBRequestBuilderUtilities.getTicodprovi(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tinommunic', ONE_CDBRequestBuilderUtilities.getTinommunic(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'ticarrer', ONE_CDBRequestBuilderUtilities.getTicarrer(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tizip', ONE_CDBRequestBuilderUtilities.getTizip(onePresupuesto));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tiampl1', ONE_CDBRequestBuilderUtilities.getValueIfRecordTypeMatch(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Ampliacion_De_Direccion_1__pc, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR, onePresupuesto?.ONE_Codigo_Titular_CB__r.RecordTypeId));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tiampl2', ONE_CDBRequestBuilderUtilities.getValueIfRecordTypeMatch(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Ampliacion_De_Direccion_2__pc, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR, onePresupuesto?.ONE_Codigo_Titular_CB__r.RecordTypeId));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tinumcar', ONE_CDBRequestBuilderUtilities.getValueIfRecordTypeMatch(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Numero_Calle__pc, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR, onePresupuesto?.ONE_Codigo_Titular_CB__r.RecordTypeId));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'ticomnu', ONE_CDBRequestBuilderUtilities.getValueIfRecordTypeMatch(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_BIS__pc, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR, onePresupuesto?.ONE_Codigo_Titular_CB__r.RecordTypeId));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tiescal', ONE_CDBRequestBuilderUtilities.getValueIfRecordTypeMatch(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Escalera_Calle__pc, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR, onePresupuesto?.ONE_Codigo_Titular_CB__r.RecordTypeId));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tipis', ONE_CDBRequestBuilderUtilities.getValueIfRecordTypeMatch(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Piso_Calle__pc, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR, onePresupuesto?.ONE_Codigo_Titular_CB__r.RecordTypeId));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tiporta', ONE_CDBRequestBuilderUtilities.getValueIfRecordTypeMatch(onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Puerta_Calle__pc, ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR, onePresupuesto?.ONE_Codigo_Titular_CB__r.RecordTypeId));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'titelef', onePresupuesto?.ONE_Codigo_Titular_CB__r?.PersonMobilePhone);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'titelef2', onePresupuesto?.ONE_Codigo_Titular_CB__r?.ONE_Otro_Telefono__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tiemail', onePresupuesto?.ONE_Codigo_Titular_CB__r?.PersonEmail);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tipagador', onePresupuesto?.ONE_Forma_De_Pago_Titular_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tiagencia', onePresupuesto?.ONE_Expediente__r?.ONE_GEA2__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tipoliza', onePresupuesto?.ONE_Expediente__r?.ONE_Numero_de_Poliza__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(titularFraNode, 'tisinies', onePresupuesto?.ONE_Expediente__r?.ONE_Numero_de_Siniestro__c);
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildSolicIncineNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        Dom.XmlNode solicIncineNode = soapDocument.addChildElement(SOLIC_INCINE_NODE_NAME, null, null);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sinom', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.FirstName);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sicog1', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.LastName);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sitipdocu', ONE_CDBRequestBuilderUtilities.getShortTypeOfDocument(onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Tipo_de_documento__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sinumdocu', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_N_Documento__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sinompais', ONE_CDBRequestBuilderUtilities.getLongCountryName(onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Pais__pc));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sicodprovi', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Provincia__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sinommunic', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Municipio__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sicarrer', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'siampl1', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Ampliacion_De_Direccion_1__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'siampl2', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Ampliacion_De_Direccion_2__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sinumcar', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Numero_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sicomnu', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_BIS__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'siescal', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Escalera_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sipis', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Piso_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'siporta', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Puerta_Calle__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sizip', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Codigo_Postal__pc);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sitelef', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.PersonMobilePhone);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'sitelef2', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.ONE_Otro_Telefono__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'siemail', onePresupuesto?.ONE_Solicitante_Incineracion_CB__r?.PersonEmail);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(solicIncineNode, 'siparentiu', onePresupuesto?.ONE_Relacion_Sol_Incineracion_Difunto__c);
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildDefuncionNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        Dom.XmlNode defuncionNode = soapDocument.addChildElement(DEFUNCION_NODE_NAME, null, null);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dftipus', ONE_CDBRequestBuilderUtilities.getShortPlaceOfDeath(onePresupuesto?.ONE_Expediente__r?.ONE_Tipo_De_Lugar_De_Defuncion__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfnom', String.isEmpty(onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__c) ? onePresupuesto?.ONE_Expediente__r?.ONE_Direccion_De_Defuncion__c : onePresupuesto.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__r?.Name);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfnumdocu', onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__r?.ONE_CIF__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfnompais', ONE_CDBRequestBuilderUtilities.getLongCountryName(onePresupuesto?.ONE_Expediente__r?.ONE_Pais_De_Defuncion__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfcodprovi', onePresupuesto?.ONE_Expediente__r?.ONE_Provincia_De_Defuncion__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfnommunic', onePresupuesto?.ONE_Expediente__r?.ONE_Municipio_De_Defuncion__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfcarrer', onePresupuesto?.ONE_Expediente__r?.ONE_Direccion_De_Defuncion__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfzip', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_Postal_De_Defuncion__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dftelef', onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__r?.ONE_Otro_Telefono__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(defuncionNode, 'dfemail', onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_De_Defuncion__r?.ONE_Email__c);
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildMortuoriaNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        Dom.XmlNode mortuoriaNode = soapDocument.addChildElement(MORTUORIA_NODE_NAME, null, null);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'motipus', onePresupuesto?.ONE_Tipo_Mortuorio_CB__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'monom', onePresupuesto?.ONE_Mortuorio_CB__r?.Name);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'monumdocu', onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_CIF__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'monompais', ONE_CDBRequestBuilderUtilities.getLongCountryName(onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_Pais__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'mocodprovi', onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_Provincia__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'monommunic', onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_Municipio_Direccion__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'mocarrer', onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_Direccion__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'mozip', onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_Codigo_Postal__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'motelef', onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_Otro_Telefono__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(mortuoriaNode, 'moemail', onePresupuesto?.ONE_Mortuorio_CB__r?.ONE_Email__c);
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildParroquiaNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        Dom.XmlNode parroquiaNode = soapDocument.addChildElement(PARROQUIA_NODE_NAME, null, null);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'panom', onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.Name);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'panumdocu', onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.ONE_CIF__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'panompais', ONE_CDBRequestBuilderUtilities.getLongCountryName(onePresupuesto?.ONE_Expediente__r?.ONE_Pais_Ceremonia__c));
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'pacodprovi', onePresupuesto?.ONE_Expediente__r?.ONE_Provincia_Ceremonia__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'panommunic', onePresupuesto?.ONE_Expediente__r?.ONE_Municipio_Ceremonia__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'pacarrer', onePresupuesto?.ONE_Expediente__r?.ONE_Direccion_Ceremonia__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'pazip', onePresupuesto?.ONE_Expediente__r?.ONE_Codigo_Postal_Ceremonia__c);
        ONE_CDBSoapRequestBuilder.addChildElementWithValue(parroquiaNode, 'patelef', onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r.ONE_Otro_Telefono__c);
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildComplementsNodeWithParameters(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        for (ONE_SLI_Producto_CB__c product : onePresupuesto.SLIs_Producto_CB__r) {
            Dom.XmlNode complementsNode = soapDocument.addChildElement(COMPLEMENTS_NODE_NAME, null, null);
            ONE_CDBSoapRequestBuilder.addChildElementWithValue(complementsNode, 'coarticle', product.ONE_Producto__r?.ONE_Codigo_Comercial__c);
            ONE_CDBSoapRequestBuilder.addChildElementWithValue(complementsNode, 'cotitular', product.ONE_Titular_SLI_CB__r.ONE_Autonumerico_Codigo_Titular_CB__c);
            ONE_CDBSoapRequestBuilder.addChildElementWithValue(complementsNode, 'coquantitat', String.valueOf(product.ONE_Unidades__c));
            ONE_CDBSoapRequestBuilder.addChildElementWithValue(complementsNode, 'cotext_frontal', product.ONE_Texto_Frontal_Lapida__c);
            ONE_CDBSoapRequestBuilder.addChildElementWithValue(complementsNode, 'cotext_lateral', product.ONE_Texto_Lateral_Lapida__c);
        }
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildDeclarantNodeWithParametersIfRecordExists(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        if (String.isNotEmpty(onePresupuesto?.ONE_Expediente__r?.ONE_Declarante__c)) {
            buildDeclarantNodeWithParameters(soapDocument, onePresupuesto);
        }
    }

	//Populate XML structure with the required data based on the Prsupuesto object in the parameters
    static void buildParroquiaNodeWithParametersIfRecordExists(Dom.XmlNode soapDocument, ONE_Presupuesto__c onePresupuesto) {
        if (String.isNotEmpty(onePresupuesto?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__c)) {
            buildParroquiaNodeWithParameters(soapDocument, onePresupuesto);
        }
    }
}
@isTest
private class ONE_CasoTriggerHandlerTest {

    @testSetup
    private static void setup() {

        Account difunto = ONE_TestDataFactory.createPersonAccount(new Account(LastName = 'Pepe'), true);
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account tanatorio = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);
        
    }

    @isTest
    private static void insertCaso() {

        Account difunto = [SELECT Id FROM Account WHERE LastName = 'Pepe' LIMIT 1];
        Account tanatorio = [SELECT Id FROM Account WHERE Name = 'Centro' LIMIT 1];

        Test.startTest();

        ONE_Caso__c caso = new ONE_Caso__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion'), ONE_Centro_del_Servicio__c = tanatorio.Id, ONE_Difunto__c = difunto.Id);
        insert caso;

        Test.stopTest();
    }

    @isTest
    private static void updateCaso1() {

        Test.startTest();

        Account difunto = [SELECT Id FROM Account WHERE LastName = 'Pepe' LIMIT 1];
        Account tanatorio = [SELECT Id FROM Account WHERE Name = 'Centro' LIMIT 1];

        ONE_Caso__c caso = new ONE_Caso__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion'), ONE_Centro_del_Servicio__c = tanatorio.Id, ONE_Difunto__c = difunto.Id);
        insert caso;

        ONE_Expediente__c expediente = ONE_TestDataFactory.createExpediente(new ONE_Expediente__c(ONE_Difunto__c = difunto.Id, ONE_Centro_Del_Expediente__c = tanatorio.Id), true);

        caso.ONE_Expediente__c = expediente.Id;

        update caso;

        Test.stopTest();
    }

    @isTest
    private static void updateCaso2() {

        Test.startTest();

        Account difunto = [SELECT Id FROM Account WHERE LastName = 'Pepe' LIMIT 1];
        Account difunto2 = ONE_TestDataFactory.createPersonAccount(new Account(LastName = 'Jaime'), true);
        Account tanatorio = [SELECT Id FROM Account WHERE Name = 'Centro' LIMIT 1];

        ONE_Caso__c caso = new ONE_Caso__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion'), ONE_Centro_del_Servicio__c = tanatorio.Id, ONE_Difunto__c = difunto.Id);
        insert caso;


        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c WHERE ONE_Lugar_Superior__r.ONE_Lugar_Superior__c != null LIMIT 1];
        Account tanatorio2 = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro 2', ONE_Tipo__c = 'Cementerio', ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN', ONE_Lugar__c = lugar.Id), true);

        caso.ONE_Difunto__c = difunto2.Id;
        caso.ONE_Centro_del_Servicio__c = tanatorio2.Id;
        caso.ONE_Tipo_De_Difunto__c = '3';

        update caso;

        Test.stopTest();
    }
    @isTest
    private static void createCasoOcaso() {

        Test.startTest();
		ONE_Municipio__c municipio =new ONE_Municipio__c (Name='Mombuey', ONE_Codigo_De_Municipio__c='491218', ONE_Provincia__c='49');
        insert municipio;
        ONE_Caso__c caso = new ONE_Caso__c(RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_Caso__c', 'ONE_Avisos_De_Defuncion'),ONE_Sistema_Externo_Origen__c='Ocaso',ONE_Emisor_Del_Aviso__c='Compañías',
                                            ONE_Record_type__c='Avisos de Defunción',
                                            ONE_Tipo__c='Asegurado/Acuerdo',
                                            ONE_Tipo_De_Difunto__c='2',
                                            ONE_Causas_Defuncion__c='Enfermedad',
                                            ONE_Tipo_De_Servicio__c='Servicio Integral',
                                            ONE_Certificado__c='Pendiente',
                                            ONE_Tipo_de_Lugar__c='Domicilio Particular ',
                                            ONE_Lugar_De_Defuncion__c=null,
                                            ONE_Direccion_De_Defuncion__c='Calle inventada 55',
                                            ONE_Provincia_De_Defuncion__c='08',
                                            ONE_Municipio__c=municipio.Id,
                                            ONE_Codigo_Postal_De_Defuncion__c='08025',
                                            ONE_Pais_De_Defuncion__c='ES',
                                            ONE_Observaciones2__c='Observaciones del caso',
                                            ONE_Nombre_Difunto__c='Maria',
                                            ONE_Apellidos_Difunto__c='Patiño',
                                            ONE_Tipo_Documento_Difunto__c='97',
                                            ONE_N_Documento_Difunto__c='90617986X',
                                            ONE_Fecha_Nacimiento_Difunto__c=Date.valueOf('1989-12-25'),
                                            ONE_Fecha_De_Defuncion__c=System.now(),
                                            ONE_Sexo_Difunto__c='Mujer',
                                            ONE_Nombre_Avisador__c='Lucia',
                                            ONE_Apellidos_Avisador__c='Castro',
                                            ONE_Telefono_Avisador__c='625897415',
                                            ONE_Persona_De_Contacto_Avisador__c=true,
                                            ONE_Nombre_De_La_Persona_De_Contacto__c=null,
                                            ONE_Telefono_De_La_Persona_De_Contacto__c=null,
                                            ONE_Relacion_Con_El_Difunto__c='Hijo',
                                            ONE_Numero_De_Siniestro_Texto__c='497593845793',
                                            ONE_Numero_De_Poliza_texto__c='29734287489273947',
                                            ONE_Capital_Real__c=Decimal.valueOf('2589.99'));
        insert caso;


        Test.stopTest();
    }
}
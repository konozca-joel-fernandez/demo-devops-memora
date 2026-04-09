/**
 * Created by mbujak003 on 24.02.2021.
 */
//Consulta Reserva test for the Reservation management componet
@IsTest
public without sharing class ONE_ConsultaReservaSalasTest {
	//Test setup for room management component
    @TestSetup
    public static void dataSetup() {
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account centro = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id, ONE_Cementiris_De_Barcelona__c = true), true);
        Account acc2 = ONE_TestDataFactory.createPersonAccount(null, true);

        ONE_Recursos_Internos__c rec = new ONE_Recursos_Internos__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                ONE_CommonConstants.RECURSOS_INTERNOS,
                ONE_CommonConstants.REC_RT_SALAS
            ),
            ONE_Centro__c = centro.Id
        );

        insert rec;
        system.debug(rec.RecordTypeId);

        ONE_Expediente__c exp = ONE_TestDataFactory.createExpediente(
            new ONE_Expediente__c(
                ONE_Centro_Del_Expediente__c = centro.Id
            ), true);

        ONE_Horario__c horario1 = new ONE_Horario__c(
            ONE_Sala__c = rec.Id,
            ONE_Hora_De_Inicio__c = Time.newInstance(9, 0, 0, 0),
            ONE_Hora_De_Fin__c = Time.newInstance(17, 0, 0, 0),
            ONE_Lunes__c = true,
            ONE_Martes__c = true,
            ONE_Miercoles__c = true,
            ONE_Jueves__c = true,
            ONE_Viernes__c = true,
            ONE_Sabado__c = true,
            ONE_Domingo__c = true
        );
        ONE_Horario__c horario2 = new ONE_Horario__c(
            ONE_Sala__c = rec.Id,
            ONE_Fecha_Excepcional__c = Date.newInstance(2020, 25,  6),
            ONE_Hora_De_Inicio__c = Time.newInstance(9, 0, 0, 0),
            ONE_Hora_De_Fin__c = Time.newInstance(17, 0, 0, 0)
        );

        insert horario1;
        insert horario2;
        ONE_Reservas__c reserva = new ONE_Reservas__c(
            ONE_Sala__c = rec.Id,
            ONE_Fecha_Inicio__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)),
            ONE_Fecha_Fin__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)),
            ONE_Expediente__c = exp.Id,
            ONE_Cuenta_Sitio_De_La_Reserva__c = acc2.Id,
            ONE_ManualRecordChangeIndicator__c = '#%$#'
        );
        insert reserva;
    }
	//Test consulta de reservas, this method query for the availabe resevation in an specific time interval 24h
    @IsTest
    public static void ConsultaResevaSalasControllerTest1()
    {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PageReference pageRef = Page.ONE_DisponibilidadSalas;
        pageRef.getParameters().put('objeto','centro');
        pageRef.getParameters().put('intervalo','1');
        pageRef.getParameters().put('idCentro', JSON.serialize(new Set<Id> { acc.Id }));
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ONE_ConsultaResevaSalasController contr = new ONE_ConsultaResevaSalasController();
        Test.stopTest();
    }
	//Test consulta de reservas, this method query for the availabe resevation in an specific time interval 48h
    @IsTest
    public static void ConsultaResevaSalasControllerTest2()
    {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PageReference pageRef = Page.ONE_DisponibilidadSalas;
        pageRef.getParameters().put('objeto','centro');
        pageRef.getParameters().put('intervalo','2');
        pageRef.getParameters().put('idCentro', JSON.serialize(new Set<Id> { acc.Id }));
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ONE_ConsultaResevaSalasController contr = new ONE_ConsultaResevaSalasController();
        Test.stopTest();
    }
	//Test consulta de reservas, this method query for the availabe resevation in an specific time interval 72h
    @IsTest
    public static void ConsultaResevaSalasControllerTest3()
    {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PageReference pageRef = Page.ONE_DisponibilidadSalas;
        pageRef.getParameters().put('objeto','centro');
        pageRef.getParameters().put('intervalo','3');
        pageRef.getParameters().put('idCentro', JSON.serialize(new Set<Id> { acc.Id }));
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ONE_ConsultaResevaSalasController contr = new ONE_ConsultaResevaSalasController();
        Test.stopTest();
    }
	//Test consulta de reservas, this method query for the availabe resevation in an specific time interval one week
    @IsTest
    public static void ConsultaResevaSalasControllerTest4()
    {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PageReference pageRef = Page.ONE_DisponibilidadSalas;
        pageRef.getParameters().put('objeto','centro');
        pageRef.getParameters().put('intervalo','4');
        pageRef.getParameters().put('idCentro', JSON.serialize(new Set<Id> { acc.Id }));
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ONE_ConsultaResevaSalasController contr = new ONE_ConsultaResevaSalasController();
        Test.stopTest();
    }
	//Test consulta de reservas, this method query for the availabe resevation in an specific time interval one week, and a specific place
    @IsTest
    public static void ConsultaResevaSalasControllerTest5()
    {
        ONE_Lugar__c lugar = [SELECT Id FROM ONE_Lugar__c LIMIT 1];
        PageReference pageRef = Page.ONE_DisponibilidadSalas;
        pageRef.getParameters().put('objeto','lugar');
        pageRef.getParameters().put('intervalo','4');
        pageRef.getParameters().put('idLugar', lugar.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ONE_ConsultaResevaSalasController contr = new ONE_ConsultaResevaSalasController();
        Test.stopTest();
    }
	//Test if the component is open from a service
    @IsTest
    public static void isExpedienteTest() {
        ONE_Expediente__c exp = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        Boolean isExp = false;
        Test.startTest();
        isExp = ONE_ConsultaResevaSalasController.isExpediente(exp.Id);
        Test.stopTest();
        System.assertEquals(isExp, true);
    }
	//Init component with the reservation for an specific account
    @IsTest
    public static void initLookupTest1() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<ONE_LookupSearchResult> lsr = null;
        Test.startTest();
        lsr = ONE_ConsultaResevaSalasController.initLookup(acc.Id);
        Test.stopTest();
        System.assertNotEquals(lsr, null);
    }
	//Init component with the reservation for an specific service
    @IsTest
    public static void initLookupTest2() {
        ONE_Expediente__c exp = [SELECT Id FROM ONE_Expediente__c LIMIT 1];
        List<ONE_LookupSearchResult> lsr = null;
        Test.startTest();
        lsr = ONE_ConsultaResevaSalasController.initLookup(exp.Id);
        Test.stopTest();
        System.assertNotEquals(lsr, null);
    }
	//Init component with the reservation for multiple account name
    @IsTest
    public static void searchCentroTest() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        List<ONE_LookupSearchResult> lsr = null;
        Test.startTest();
        lsr = ONE_ConsultaResevaSalasController.searchCentro(acc.Name, new List<String>());
        Test.stopTest();
        System.assertNotEquals(lsr, null);
    }
	//Init component with the reservation for multiple palce
    @IsTest
    public static void searchLugarTest() {
        ONE_Lugar__c lugar = [SELECT Id, Name FROM ONE_Lugar__c LIMIT 1];
        List<ONE_LookupSearchResult> lsr = null;
        Test.startTest();
        lsr = ONE_ConsultaResevaSalasController.searchLugar(lugar.Name, new List<String>());
        Test.stopTest();
        System.assertNotEquals(lsr, null);
    }
	//Delete record test
    @IsTest
    public static void deleteRecordTest() {
        Id expedienteId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        Map<String, String> key2Val = new Map<String, String> {
            'start' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0))).replaceAll('"', ''),
            'end' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0))).replaceAll('"', ''),
            'id' => [ SELECT Id FROM ONE_Recursos_Internos__c LIMIT 1].Id,
            'expedient' => [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id,
            'recordId' => [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id
        };
        ONE_Reservas__c reserva = [SELECT Id from ONE_Reservas__c WHERE ONE_Fecha_Inicio__c =:Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)) AND ONE_Fecha_Fin__c =:Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)) AND ONE_Expediente__c = :expedienteId];
        ONE_SlotSala__c slot = new ONE_SlotSala__c (ONE_InicioSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)), ONE_FinSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)));
        String retVal = '';
        Test.startTest();
        retVal = ONE_ConsultaResevaSalasController.deleteRecord(key2Val);
        Test.stopTest();
        System.assertEquals(retVal, 'SUCCESS');
    }
	//Update record test
    @IsTest
    public static void updateRecordTest() {
        Map<String, String> key2Val = new Map<String, String> {
            'expedient' => [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id,
            'start' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0))).replaceAll('"', ''),
            'newStart' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0))).replaceAll('"', ''),
            'end' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0))).replaceAll('"', ''),
            'newEnd' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 40, 0, 0))).replaceAll('"', ''),
            'id' => [ SELECT Id FROM ONE_Recursos_Internos__c LIMIT 1].Id,
            'recordId' => [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id
        };
        String retVal = '';
        Test.startTest();
        retVal = ONE_ConsultaResevaSalasController.updateRecord(key2Val);
        Test.stopTest();
        //System.assertEquals(retVal, 'SUCCESS');
    }
    
    @isTest
    public static void updateAccountTest() {
       
        Id sala = [ SELECT Id FROM ONE_Recursos_Internos__c LIMIT 1].Id;
        String retVal = '';
        Test.startTest();
        retVal = ONE_ConsultaResevaSalasController.updateCuenta(sala);
        Test.stopTest();
        //System.assertEquals(retVal, 'SUCCESS');
    }
    
    @isTest
    public static void getAccountTest() {
       
        Map<String, String> key2Val = new Map<String, String> {
            'start' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0))).replaceAll('"', ''),
            'end' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0))).replaceAll('"', ''),
            'id' => [ SELECT Id FROM ONE_Recursos_Internos__c LIMIT 1].Id
        };
        String retVal = '';
        Test.startTest();
        retVal = ONE_ConsultaResevaSalasController.getAccountSala(key2Val);
        Test.stopTest();
        //System.assertEquals(retVal, 'SUCCESS');
    }
    

    @IsTest
    public static void fetchReservasByTimeInterval() {

        ONE_SalasHelper.fetchReservas(null, ONE_SalasHelper.TimeInterval.INTERVAL_48H);

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        UserRole serfutosaRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'ONE_Serfutosa'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Polivalente'];
        User userWithRoleSerfutosa = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            UserRoleId = serfutosaRole.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName
        );

        System.runAs(userWithRoleSerfutosa) {
            ONE_SalasHelper.fetchReservas(null, ONE_SalasHelper.TimeInterval.INTERVAL_48H);
        }
    }

    @IsTest
    public static void fetchReservasByRecursos() {

        List<ONE_Recursos_Internos__c> recursos = [ SELECT Id FROM ONE_Recursos_Internos__c];
        ONE_SalasHelper.fetchReservas(recursos);

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        UserRole serfutosaRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'ONE_Serfutosa'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Polivalente'];
        User userWithRoleSerfutosa = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            UserRoleId = serfutosaRole.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName
        );

        System.runAs(userWithRoleSerfutosa) {
            ONE_SalasHelper.fetchReservas(recursos);
        }
    }

    @IsTest
    public static void fetchReservas() {

        List<ONE_Recursos_Internos__c> recursos = [ SELECT Id FROM ONE_Recursos_Internos__c];
        ONE_SalasHelper.fetchReservas();

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        UserRole serfutosaRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'ONE_Serfutosa'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Polivalente'];
        User userWithRoleSerfutosa = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            UserRoleId = serfutosaRole.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName
        );

        System.runAs(userWithRoleSerfutosa) {
            ONE_SalasHelper.fetchReservas();
        }
    }
    
    @isTest
    public static void isExpediente() {
        
        Id expedienteId = [SELECT Id FROM ONE_Expediente__c LIMIT 1].Id;
        ONE_ConsultaResevaSalasController.isExpediente(expedienteId);
        
        ONE_ConsultaResevaSalasController.getVisualforcePage();
    }

    @IsTest
    public static void initSecondaryLookupsTest() {

        Map<String, String> key2Val = new Map<String, String> {
            'start' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0))).replaceAll('"', ''),
            'end' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0))).replaceAll('"', ''),
            'id' => [ SELECT Id FROM ONE_Recursos_Internos__c LIMIT 1].Id
        };

        Test.startTest();
        String retVal = ONE_ConsultaResevaSalasController.initSecondaryLookups(key2Val);
        Test.stopTest();
    }

    @IsTest
    public static void canEditTest() {

        Map<String, String> key2Val = new Map<String, String> {
            'start' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0))).replaceAll('"', ''),
            'end' => JSON.serialize(Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0))).replaceAll('"', ''),
            'id' => [ SELECT Id FROM ONE_Recursos_Internos__c LIMIT 1].Id
        };

        Test.startTest();
        Boolean retVal = ONE_ConsultaResevaSalasController.canEdit(key2Val);
        Test.stopTest();
    }
}
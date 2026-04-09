@isTest
public class ONE_GestorSalasControllerTest {

    @TestSetup
    public static void makeData() {

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account centro = ONE_TestDataFactory.createCentro(new Account(Name = 'Centro Test', ONE_Lugar__c = lugar.Id), true);
        Account acc2 = ONE_TestDataFactory.createPersonAccount(null, true);

        ONE_Recursos_Internos__c rec = new ONE_Recursos_Internos__c(
            RecordTypeId = ONE_CommonUtils.getsObjectRecordTypeIdByName(
                ONE_CommonConstants.RECURSOS_INTERNOS,
                ONE_CommonConstants.REC_RT_SALAS
            ),
            ONE_Centro__c = centro.Id,
            ONE_Tipo_De_Sala__c = 'Sala Velatorio'
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
            ONE_Domingo__c = true,
            ONE_Inicio_De_Vigencia__c = Date.today()
        );
        ONE_Horario__c horario2 = new ONE_Horario__c(
            ONE_Sala__c = rec.Id,
            ONE_Fecha_Excepcional__c = Date.newInstance(2020, 25,  6),
            ONE_Hora_De_Inicio__c = Time.newInstance(9, 0, 0, 0),
            ONE_Hora_De_Fin__c = Time.newInstance(17, 0, 0, 0),
            ONE_Inicio_De_Vigencia__c = Date.today()
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

        ONE_SlotGenerator.generateSlotsByDate(Date.today());
    }

    @isTest
    public static void getCurrentCentroTest() {

        ONE_Expediente__c servicio = [SELECT Id, ONE_Centro_Del_Expediente__c FROM ONE_Expediente__c LIMIT 1];
        
        Test.startTest();
        List<LookupSearchResult> lookupSearchResultList = ONE_GestorSalasController.getCurrentCentro(servicio.Id);
        Test.stopTest();

        //System.assertEquals(1, lookupSearchResultList.size());
        //System.assertEquals(servicio.ONE_Centro_Del_Expediente__c, lookupSearchResultList[0].getId());
    }

    @isTest
    public static void searchCentrosTest() {

        Account centro = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'ONE_Centro_Memora' LIMIT 1];
        List<String> selectedIds = new List<String>();

        Test.startTest();
        List<LookupSearchResult> lookupSearchResultList = ONE_GestorSalasController.searchCentros(centro.Name, selectedIds);
        Test.stopTest();
    }

    @isTest
    public static void getSlotListTest() {

        Account centro = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'ONE_Centro_Memora' LIMIT 1];

        Test.startTest();
        List<ONE_SlotSala__c> slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, '', '');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, 'Disponible', '');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, 'Ocupado', '');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, '', 'Libre');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, '', 'Predefinido');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, 'Disponible', 'Libre');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, 'Disponible', 'Predefinido');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, 'Ocupado', 'Libre');
        slotList = ONE_GestorSalasController.getSlotList(Datetime.now().format('yyyy-MM-dd'), new List<String>{centro.Id}, 'Ocupado', 'Predefinido');
        Test.stopTest();
    }

    @isTest
    public static void createSlotsTest() {

        Test.startTest();
        ONE_GestorSalasController.createSlots(Datetime.now().format('yyyy-MM-dd'));
        Test.stopTest(); 
    }

    @isTest
    public static void getReservaDefaultValuesTest() {

        Id slotId = [SELECT Id FROM ONE_SlotSala__c LIMIT 1].Id;
        ONE_Expediente__c servicio = [SELECT Id, ONE_Centro_Del_Expediente__c FROM ONE_Expediente__c LIMIT 1];

        Test.startTest();
        ONE_Reservas__c reserva = ONE_GestorSalasController.getReservaDefaultValues(servicio.Id, slotId);
        Test.stopTest(); 

        System.assertEquals(servicio.Id, reserva.ONE_Expediente__c);
        System.assertEquals(servicio.ONE_Centro_Del_Expediente__c, reserva.ONE_Cuenta_Sitio_De_La_Reserva__c);
    }

    @isTest
    public static void updateSlotWithReservaTest() {
		
        Date myDateInit = Date.newInstance(2023, 11, 12);
        Date myDateFin = Date.newInstance(2023, 11, 14);
        Time myTimeInit = Time.newInstance(06,05,22,0);
        Time myTimeFin = Time.newInstance(20,05,23,0);
        
        DateTime IniSlot = DateTime.newInstanceGMT(myDateInit, myTimeInit);
        DateTime FinSlot = DateTime.newInstanceGMT(myDateFin, myTimeFin);
       
        Account centro = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'ONE_Centro_Memora' LIMIT 1];
        ONE_Expediente__c servicio = [SELECT Id, ONE_Centro_Del_Expediente__c FROM ONE_Expediente__c LIMIT 1];
        ONE_Recursos_Internos__c sala1 = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true, Name = 'Sala test', ONE_Tipo_De_Sala__c = 'Sala Ceremonia');
        insert sala1;
        ONE_Recursos_Internos__c sala2 = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, Name = 'ONE_Test', ONE_Activo__c = true, ONE_Sala_De_Ceremonia_Relacionada__c = sala1.Id );
        insert sala2;
        //ONE_Recursos_Internos__c sala = [SELECT Id FROM ONE_Recursos_Internos__c WHERE ONE_Sala_De_Ceremonia_Relacionada__c != null LIMIT 1];
        ONE_horario__c horario = new ONE_horario__c(ONE_Sala__c=sala2.Id,ONE_Domingo__c=true, ONE_Lunes__c = true, ONE_Martes__c = true, ONE_Miercoles__c = true, ONE_Jueves__c = true, ONE_Viernes__c = true);
        insert horario;
        
        ONE_SlotSala__c slot = new ONE_SlotSala__c(
            ONE_Servicio__c = servicio.Id,
            ONE_Sala__c = sala2.Id,
            ONE_InicioSlot__c = Datetime.now(),
            ONE_FinSlot__c = Datetime.now(),
            ONE_Horario__c = horario.Id,
            Fecha_inicio_Slot__c = Date.today(),
            Fecha_fin_slot__c = Date.today()
        );
        insert slot;
        
        System.debug ('servicio ' + servicio);
        ONE_Reservas__c reserva = new ONE_Reservas__c(ONE_Fecha_Inicio__c = Datetime.now(),ONE_Fecha_Fin__c = Datetime.now(), ONE_Expediente__c = servicio.Id, ONE_Sala__c = sala2.Id);
        reserva.ONE_Tipo_De_Reserva__c = 'Reserva';
        reserva.ONE_Momento_Al_Que_Aplica__c = 'Velación';
        reserva.ONE_Reserva_con_Ceremonia__c = true;
        insert reserva;

        Test.startTest();
        ONE_GestorSalasController.updateSlotWithReserva(slot.Id, reserva.Id);
        reserva.ONE_Fecha_Fin__c = Datetime.now().addMinutes(7);
        update reserva;
        ONE_GestorSalasController.updateSlotWithReserva(slot.Id, reserva.Id);
        Test.stopTest();
        

    }

    @isTest
    public static void deleteReservaTest() {

        Id slotId = [SELECT Id FROM ONE_SlotSala__c LIMIT 1].Id;
        ONE_Expediente__c servicio = [SELECT Id, ONE_Centro_Del_Expediente__c FROM ONE_Expediente__c LIMIT 1];
        Id salaId = [SELECT Id FROM ONE_Recursos_Internos__c LIMIT 1].Id;
        ONE_Reservas__c reserva = new ONE_Reservas__c(ONE_Fecha_Inicio__c = Datetime.now(),ONE_Fecha_Fin__c = Datetime.now(), ONE_Expediente__c = servicio.Id,  ONE_Sala__c = salaId, ONE_Momento_Al_Que_Aplica__c = 'Velación');
        reserva.ONE_Tipo_De_Reserva__c = 'Reserva';
        reserva.ONE_Reserva_con_Ceremonia__c = true;
        insert reserva;
        ONE_Reservas__c reservaCeremonia = new ONE_Reservas__c(ONE_Fecha_Inicio__c = Datetime.now(),ONE_Fecha_Fin__c = Datetime.now(), ONE_Expediente__c = servicio.Id,  ONE_Sala__c = salaId, ONE_Momento_Al_Que_Aplica__c = 'Ceremonia');
        insert reservaCeremonia;
        
        ONE_GestorSalasController.updateSlotWithReserva(slotId, reserva.Id);

        Test.startTest();
        ONE_GestorSalasController.deleteReserva(slotId, servicio.Id, reserva.Id);
        Test.stopTest();
    }
}
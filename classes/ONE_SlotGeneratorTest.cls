@isTest
public class ONE_SlotGeneratorTest {

    @TestSetup
    public static void makeData() {

        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
        Account centro = ONE_TestDataFactory.createCentro(new Account(ONE_Lugar__c = lugar.Id), true);
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
    }

    @isTest
    public static void generateSlotsForNextDaysTest() {

        Test.startTest();
        ONE_SlotGenerator.generateSlotsForNextDays(7);
        Test.stopTest();
    }

    @isTest
    public static void generateSlotsByDateTest() {

        Test.startTest();
        ONE_SlotGenerator.generateSlotsByDate(Date.today());
        Test.stopTest();
    }

    @isTest
    public static void reprocessSlots1Test() {

        Test.startTest();
        List<ONE_SlotGenerator.FlowInputs> fiList = new List<ONE_SlotGenerator.FlowInputs>();
        ONE_SlotGenerator.FlowInputs fi  = new ONE_SlotGenerator.FlowInputs();
        fi.record = null;
        fi.action = null;
        fiList.add(fi);
        ONE_SlotGenerator.reprocessSlots(fiList);
        Test.stopTest();
    }
    
    @isTest
    public static void reprocessSlots2Test() {
        Account centro = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'ONE_Centro_Memora' LIMIT 1];
        ONE_Recursos_Internos__c sala1 = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true, Name = 'Sala test', ONE_Tipo_De_Sala__c = 'Sala Ceremonia');
        insert sala1;
        ONE_Horario__c horario1 = new ONE_Horario__c(
            ONE_Sala__c = sala1.Id,
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
            ONE_Sala__c = sala1.Id,
            ONE_Fecha_Excepcional__c = Date.today(),
            ONE_Hora_De_Inicio__c = Time.newInstance(9, 0, 0, 0),
            ONE_Hora_De_Fin__c = Time.newInstance(17, 0, 0, 0),
            ONE_Inicio_De_Vigencia__c = Date.today()
        );
        insert horario1;
        insert horario2;
        Date tod = Date.today();
		Date date1 = tod.addDays(1);
        Date date2 = tod.addDays(2);
        ONE_Festivo__c festivo = new ONE_Festivo__c(ONE_Fecha_Cierre__c = date1, ONE_Sala__c = sala1.Id);
        insert festivo;
        Test.startTest();
        ONE_SlotSala__c slot1 = new ONE_SlotSala__c (ONE_Sala__c = sala1.Id, ONE_Horario__c = horario1.Id, Fecha_fin_slot__c = date2,Fecha_inicio_Slot__c = Date.today(),ONE_InicioSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)), ONE_FinSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)));
        ONE_SlotSala__c slot2 = new ONE_SlotSala__c (ONE_Sala__c = sala1.Id, ONE_Horario__c = horario2.Id, Fecha_fin_slot__c = date2.addDays(1),Fecha_inicio_Slot__c = Date.today(),ONE_InicioSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)), ONE_FinSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)));
        ONE_SlotSala__c slot3 = new ONE_SlotSala__c (ONE_Sala__c = sala1.Id, ONE_Horario__c = horario1.Id, Fecha_fin_slot__c = Date.today(),Fecha_inicio_Slot__c = Date.today(),ONE_InicioSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)), ONE_FinSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)));
        ONE_SlotSala__c slot4 = new ONE_SlotSala__c (ONE_Sala__c = sala1.Id, ONE_Horario__c = horario1.Id, Fecha_fin_slot__c = date2.addDays(2),Fecha_inicio_Slot__c = Date.today(),ONE_InicioSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)), ONE_FinSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)));
        ONE_SlotSala__c slot5 = new ONE_SlotSala__c (ONE_Sala__c = sala1.Id, ONE_Horario__c = horario1.Id, Fecha_fin_slot__c = date2.addDays(3),Fecha_inicio_Slot__c = Date.today(),ONE_InicioSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 0, 0, 0)), ONE_FinSlot__c = Datetime.newInstance(Date.today(), Time.newInstance(15, 30, 0, 0)));
        insert slot1;
        insert slot2;
        insert slot3;
        insert slot4;
        insert slot5;
        List<ONE_SlotGenerator.FlowInputs> fiList = new List<ONE_SlotGenerator.FlowInputs>();
        ONE_SlotGenerator.FlowInputs fi  = new ONE_SlotGenerator.FlowInputs();
        fi.record = null;
        fi.action = 'Eliminar';
        fiList.add(fi);
        ONE_SlotGenerator.reprocessSlots(fiList);
        Test.stopTest();
    }
}
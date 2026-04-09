@isTest
private class ReservasTest {
   
    public static testMethod void testReservas() {
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
	        
        String u = UserInfo.getUserId();
       	
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);    

        Account centro = new Account(
            Name = 'Centro test',
            ONE_Lugar__c = lugar.Id,
            ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN',
            ONE_Email_Grupo_De_Planificadores__c='michal.bujak@pwc.com',
            OwnerId = u,
            ONE_Cementiris_De_Barcelona__c = true);
        
        
        System.debug('centro1 ' + centro.Name + ' ' + centro.ONE_Cementiris_De_Barcelona__c);
        insert centro;
        System.debug('centro2 ' + centro.Id + ' ' + centro.ONE_Cementiris_De_Barcelona__c);

        
        
        ONE_Recursos_Internos__c sala = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true);
        ONE_Expediente__c servicio1 = new ONE_Expediente__c(ONE_Centro__c=centro.Id,ONE_Difunto__c=difunto.Id,ONE_Lugar_De_Defuncion__c=centro.Id,ONE_Lugar_De_Velacion__c=centro.Id,OwnerId=u, ONE_Velacion__c = true, ONE_Despedida__c = true);

        insert sala;
        System.debug('1.Number of Queries used in this apex code so far sala: ' + Limits.getQueries());
        insert servicio1;
        
        Date myDateInitVigencia = Date.newInstance(2022, 11, 12);
        Date myDateInit = Date.newInstance(2023, 11, 12);
        Date myDateFin = Date.newInstance(2023, 11, 14);
        Time myTimeInit = Time.newInstance(06,05,22,0);
        Time myTimeFin = Time.newInstance(20,05,23,0);
       
        
        Date myDateInit1 = Date.newInstance(2023, 12, 13);
        Date myDateFin1 = Date.newInstance(2023, 12, 13);
        Time myTimeInit1 = Time.newInstance(06,05,22,0);
        Time myTimeFin1 = Time.newInstance(20,05,23,0);

        
        //ONE_horario__c horario = new ONE_horario__c(ONE_Sala__c=sala.Id,ONE_Hora_De_Inicio__c=myTimeInit,ONE_Hora_De_Fin__c=myTimeFin, ONE_Fin_De_Vigencia__c = myDateInit, ONE_Inicio_De_Vigencia__c = myDateInitVigencia, ONE_Fecha_Excepcional__c = myDateFin, ONE_Domingo__c=true);
        ONE_horario__c horario = new ONE_horario__c(ONE_Sala__c=sala.Id,ONE_Domingo__c=true, ONE_Lunes__c = true, ONE_Martes__c = true, ONE_Miercoles__c = true, ONE_Jueves__c = true, ONE_Viernes__c = true);
        insert horario;
        
        DateTime IniReserva = DateTime.newInstanceGMT(myDateInit, myTimeInit);
        DateTime FinReserva = DateTime.newInstanceGMT(myDateFin, myTimeFin);
        
        DateTime IniReserva1 = DateTime.newInstanceGMT(myDateInit1, myTimeInit1);
        DateTime FinReserva1 = DateTime.newInstanceGMT(myDateFin1, myTimeFin1);
        
        
        servicio1.ONE_Inicio_Velacion__c = IniReserva;
        servicio1.ONE_Fin_Velacion__c = FinReserva;
        servicio1.ONE_Sala_De_Velacion__c = sala.Id;
        update servicio1;
        
               
        System.debug('1.Number of Queries used in this apex code so far inserts reservas: ' + Limits.getQueries());
        servicio1.ONE_Velacion__c = false;
        update servicio1;
      
        System.debug('1.Number of Queries used in this apex code so delete reservas ' + Limits.getQueries());
        


        //List<ONE_Reservas__c> reservas = new List<ONE_Reservas__c>();
        //reservas.add(reserva2);
        
        //ONE_ReservasHelper.fixWasWarnedField(reservas);
        //delete reserva1;
        //delete reserva2;
        
        System.debug('1.Number of Queries used in this apex code so TOTAL ' + Limits.getQueries());
        
    }
    
    public static testMethod void testReservas2() {
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
	        
        String u = UserInfo.getUserId();
       	
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);    

        Account centro = new Account(
            Name = 'Centro test',
            ONE_Lugar__c = lugar.Id,
            ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN',
            ONE_Email_Grupo_De_Planificadores__c='michal.bujak@pwc.com',
            OwnerId = u,
            ONE_Cementiris_De_Barcelona__c = true);
        
        
        System.debug('centro1 ' + centro.Name + ' ' + centro.ONE_Cementiris_De_Barcelona__c);
        insert centro;
        System.debug('centro2 ' + centro.Id + ' ' + centro.ONE_Cementiris_De_Barcelona__c);

        
        
        ONE_Recursos_Internos__c sala = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true);
        ONE_Expediente__c servicio1 = new ONE_Expediente__c(ONE_Centro__c=centro.Id,ONE_Difunto__c=difunto.Id,ONE_Lugar_De_Defuncion__c=centro.Id,ONE_Lugar_De_Velacion__c=centro.Id,OwnerId=u, ONE_Ceremonia__c = true);

        ONE_Recursos_Internos__c sala2 = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true);
        insert sala;
        insert sala2;
        System.debug('1.Number of Queries used in this apex code so far sala: ' + Limits.getQueries());
        insert servicio1;
        
        Date myDateInitVigencia = Date.newInstance(2022, 11, 12);
        Date myDateInit = Date.newInstance(2023, 11, 12);
        Date myDateFin = Date.newInstance(2023, 11, 14);
        Time myTimeInit = Time.newInstance(06,05,22,0);
        Time myTimeFin = Time.newInstance(20,05,23,0);
       
        
        Date myDateInit1 = Date.newInstance(2023, 12, 13);
        Date myDateFin1 = Date.newInstance(2023, 12, 13);
        Time myTimeInit1 = Time.newInstance(07,05,22,0);
        Time myTimeFin1 = Time.newInstance(21,05,23,0);

        
        ONE_horario__c horario = new ONE_horario__c(ONE_Sala__c=sala2.Id,ONE_Domingo__c=true, ONE_Lunes__c = true, ONE_Martes__c = true, ONE_Miercoles__c = true, ONE_Jueves__c = true, ONE_Viernes__c = true, ONE_Hora_De_Inicio__c=myTimeInit1,ONE_Hora_De_Fin__c=myTimeFin1, ONE_Fin_De_Vigencia__c = myDateInit, ONE_Inicio_De_Vigencia__c = myDateInitVigencia, ONE_Fecha_Excepcional__c = myDateFin);
        insert horario;
        
        DateTime IniReserva = DateTime.newInstanceGMT(myDateInit, myTimeInit);
        DateTime FinReserva = DateTime.newInstanceGMT(myDateFin, myTimeFin);
        
        DateTime IniReserva1 = DateTime.newInstanceGMT(myDateInit1, myTimeInit1);
        DateTime FinReserva1 = DateTime.newInstanceGMT(myDateFin1, myTimeFin1);
        
        
        servicio1.ONE_Inicio_Despedida__c = IniReserva;
        servicio1.ONE_Fin_Despedida__c = FinReserva;
        servicio1.ONE_Sala_Despedida__c= sala2.Id;
        servicio1.ONE_Lugar_Despedida__c = centro.Id;
        update servicio1;
        
        servicio1.ONE_Despedida__c = false;
        update servicio1;
        

        

        System.debug('1.Number of Queries used in this apex code so far insert1: ' + Limits.getQueries());
        
     
        List<ONE_Reservas__c> reservas = new List<ONE_Reservas__c>();
        ONE_Reservas__c reserva1 = new ONE_Reservas__c(ONE_Expediente__c=servicio1.Id,ONE_Sala__c=sala.Id,ONE_Momento_Al_Que_Aplica__c='Ceremonia',ONE_Fecha_Inicio__c=IniReserva, ONE_Fecha_Fin__c=FinReserva,OwnerId=u, ONE_ManualRecordChangeIndicator__c = '#%$#');
        insert reserva1;
        //ONE_Reservas__c reserva2 = new ONE_Reservas__c(ONE_Expediente__c=servicio1.Id,ONE_Sala__c=sala.Id,ONE_Momento_Al_Que_Aplica__c='Velación',ONE_Fecha_Inicio__c=IniReserva, ONE_Fecha_Fin__c=FinReserva,OwnerId=u, ONE_ManualRecordChangeIndicator__c = '#%$#');
        //insert reserva2;
        reservas.add(reserva1);
        
        System.debug('1.Number of Queries used in this apex code so update reserva1 ' + Limits.getQueries());
        ONE_ReservasHelper.fixWasWarnedField(reservas);
        delete reserva1;

        servicio1.ONE_Ceremonia__c = false;
        update servicio1;
        
        
        System.debug('1.Number of Queries used in this apex code so TOTAL ' + Limits.getQueries());
        
    }
    
    public static testMethod void testReservas3() {
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
	        
        String u = UserInfo.getUserId();
        System.debug('owner' + u);
       	
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);    

        Account centro = new Account(
            Name = 'Centro test',
            ONE_Lugar__c = lugar.Id,
            ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN',
            ONE_Email_Grupo_De_Planificadores__c='michal.bujak@pwc.com',
            OwnerId = u,
            ONE_Cementiris_De_Barcelona__c = true);
        
        
        System.debug('centro1 ' + centro.Name + ' ' + centro.ONE_Cementiris_De_Barcelona__c);
        insert centro;
        System.debug('centro2 ' + centro.Id + ' ' + centro.ONE_Cementiris_De_Barcelona__c);

        
        
        ONE_Recursos_Internos__c sala = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true);
        ONE_Expediente__c servicio1 = new ONE_Expediente__c(ONE_Centro__c=centro.Id,ONE_Difunto__c=difunto.Id,ONE_Lugar_De_Defuncion__c=centro.Id,ONE_Lugar_De_Velacion__c=centro.Id,OwnerId=u, ONE_Ceremonia__c = true);

        ONE_Recursos_Internos__c sala2 = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true);
        insert sala;
        insert sala2;
        System.debug('1.Number of Queries used in this apex code so far sala: ' + Limits.getQueries());
        insert servicio1;
        
        Date myDateInitVigencia = Date.newInstance(2022, 11, 12);
        Date myDateInit = Date.newInstance(2023, 11, 12);
        Date myDateFin = Date.newInstance(2023, 11, 14);
        Time myTimeInit = Time.newInstance(06,05,22,0);
        Time myTimeFin = Time.newInstance(20,05,23,0);
       
        
        Date myDateInit1 = Date.newInstance(2023, 12, 13);
        Date myDateFin1 = Date.newInstance(2023, 12, 13);
        Time myTimeInit1 = Time.newInstance(07,05,22,0);
        Time myTimeFin1 = Time.newInstance(21,05,23,0);

        
        ONE_horario__c horario = new ONE_horario__c(ONE_Sala__c=sala2.Id,ONE_Domingo__c=true, ONE_Lunes__c = true, ONE_Martes__c = true, ONE_Miercoles__c = true, ONE_Jueves__c = true, ONE_Viernes__c = true, ONE_Hora_De_Inicio__c=myTimeInit1,ONE_Hora_De_Fin__c=myTimeFin1, ONE_Fin_De_Vigencia__c = myDateInit, ONE_Inicio_De_Vigencia__c = myDateInitVigencia, ONE_Fecha_Excepcional__c = myDateFin);
        insert horario;
        
        DateTime IniReserva = DateTime.newInstanceGMT(myDateInit, myTimeInit);
        DateTime FinReserva = DateTime.newInstanceGMT(myDateFin, myTimeFin);
        
        DateTime IniReserva1 = DateTime.newInstanceGMT(myDateInit1, myTimeInit1);
        DateTime FinReserva1 = DateTime.newInstanceGMT(myDateFin1, myTimeFin1);
        
        servicio1.ONE_Inicio_Incineracion__c = IniReserva1;
        servicio1.ONE_Fin_Incineracion__c = FinReserva1;
        servicio1.ONE_Horno_Incineracion__c = sala.Id;
        update servicio1;
        
       
   
        System.debug('1.Number of Queries used in this apex code so far insert1: ' + Limits.getQueries());
        

        //ONE_Reservas__c reserva1 = new ONE_Reservas__c(ONE_Expediente__c=servicio1.Id,ONE_Sala__c=sala.Id,ONE_Momento_Al_Que_Aplica__c='Depósito',ONE_Fecha_Inicio__c=IniReserva, ONE_Fecha_Fin__c=FinReserva,OwnerId=u, ONE_ManualRecordChangeIndicator__c = '#$%#');
        ONE_Reservas__c reserva2 = new ONE_Reservas__c(ONE_Expediente__c=servicio1.Id,ONE_Sala__c=sala.Id,ONE_Momento_Al_Que_Aplica__c='Velación',ONE_Fecha_Inicio__c=IniReserva, ONE_Fecha_Fin__c=FinReserva,OwnerId=u, ONE_ManualRecordChangeIndicator__c = '');
        insert reserva2;


        servicio1.ONE_Incineracion__c = false;
        update servicio1;
        
        ONE_ReservasHelper.userPrivilaged();
        ONE_ReservasHelper.asesorPrivilege();
        ONE_ReservasHelper.skipValidation(false);
		//insert reserva1;
        
        System.debug('1.Number of Queries used in this apex code so TOTAL ' + Limits.getQueries());
        
    }
    
    public static testMethod void testReservas4SFB() {
        ONE_Lugar__c lugar3 = ONE_TestDataFactory.createLugar(null, true);
        ONE_Lugar__c lugar2 = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar3.Id), true);
        ONE_Lugar__c lugar = ONE_TestDataFactory.createLugar(new ONE_Lugar__c(ONE_Lugar_Superior__c = lugar2.Id), true);
	        
        String u = UserInfo.getUserId();
        System.debug('owner' + u);
       	
        Account difunto = ONE_TestDataFactory.createPersonAccount(null, true);    

        Account centro = new Account(
            Name = 'Centro test',
            ONE_Lugar__c = lugar.Id,
            ONE_Grupo_De_Planificadores_Responsable__c = 'Planificadores_BCN',
            ONE_Email_Grupo_De_Planificadores__c='michal.bujak@pwc.com',
            OwnerId = u,
            ONE_Cementiris_De_Barcelona__c = true);
        
        
        System.debug('centro1 ' + centro.Name + ' ' + centro.ONE_Cementiris_De_Barcelona__c);
        insert centro;
        System.debug('centro2 ' + centro.Id + ' ' + centro.ONE_Cementiris_De_Barcelona__c);

        
        
        ONE_Recursos_Internos__c sala = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true);
        ONE_Expediente__c servicio1 = new ONE_Expediente__c(ONE_Centro__c=centro.Id,ONE_Difunto__c=difunto.Id,ONE_Lugar_De_Defuncion__c=centro.Id,ONE_Lugar_De_Velacion__c=centro.Id,OwnerId=u, ONE_Ceremonia__c = true);

        ONE_Recursos_Internos__c sala2 = new ONE_Recursos_Internos__c(ONE_Centro__c=centro.Id, ONE_Activo__c = true);
        insert sala;
        insert sala2;
        System.debug('1.Number of Queries used in this apex code so far sala: ' + Limits.getQueries());
        insert servicio1;
        
        Date myDateInitVigencia = Date.newInstance(2022, 11, 12);
        Date myDateInit = Date.newInstance(2023, 11, 12);
        Date myDateFin = Date.newInstance(2023, 11, 14);
        Time myTimeInit = Time.newInstance(06,05,22,0);
        Time myTimeFin = Time.newInstance(20,05,23,0);
       
        
        Date myDateInit1 = Date.newInstance(2023, 12, 13);
        Date myDateFin1 = Date.newInstance(2023, 12, 13);
        Time myTimeInit1 = Time.newInstance(07,05,22,0);
        Time myTimeFin1 = Time.newInstance(21,05,23,0);

        
        ONE_horario__c horario = new ONE_horario__c(ONE_Sala__c=sala2.Id,ONE_Domingo__c=true, ONE_Lunes__c = true, ONE_Martes__c = true, ONE_Miercoles__c = true, ONE_Jueves__c = true, ONE_Viernes__c = true, ONE_Hora_De_Inicio__c=myTimeInit1,ONE_Hora_De_Fin__c=myTimeFin1, ONE_Fin_De_Vigencia__c = myDateInit, ONE_Inicio_De_Vigencia__c = myDateInitVigencia, ONE_Fecha_Excepcional__c = myDateFin);
        insert horario;
        
        DateTime IniReserva = DateTime.newInstanceGMT(myDateInit, myTimeInit);
        DateTime FinReserva = DateTime.newInstanceGMT(myDateFin, myTimeFin);
        
        DateTime IniReserva1 = DateTime.newInstanceGMT(myDateInit1, myTimeInit1);
        DateTime FinReserva1 = DateTime.newInstanceGMT(myDateFin1, myTimeFin1);
      
        System.debug('1.Number of Queries used in this apex code so far insert1: ' + Limits.getQueries());
        
		ONE_SlotSala__c slot = new ONE_SlotSala__c (ONE_Horario__c = horario.Id,
                                ONE_Sala__c = sala2.Id,
                                Fecha_inicio_Slot__c = myDateInit,
                                Hora_inicio_slot__c = myTimeInit,
                                Fecha_fin_slot__c = myDateFin,
                                Hora_fin_Slot__c = myTimeFin,
                                ONE_InicioSlot__c = IniReserva,
                                ONE_FinSlot__c = FinReserva);
        insert slot;
        //ONE_Reservas__c reserva1 = new ONE_Reservas__c(ONE_Expediente__c=servicio1.Id,ONE_Sala__c=sala.Id,ONE_Momento_Al_Que_Aplica__c='Depósito',ONE_Fecha_Inicio__c=IniReserva, ONE_Fecha_Fin__c=FinReserva,OwnerId=u, ONE_ManualRecordChangeIndicator__c = '#$%#');
        ONE_Reservas__c reserva2 = new ONE_Reservas__c(ONE_Expediente__c=servicio1.Id,ONE_Sala__c=sala2.Id,ONE_Momento_Al_Que_Aplica__c='Velación',ONE_Fecha_Inicio__c=IniReserva, ONE_Fecha_Fin__c=FinReserva,OwnerId=u, ONE_ManualRecordChangeIndicator__c = '');
        insert reserva2;
        
        System.debug('1.Number of Queries used in this apex code so TOTAL ' + Limits.getQueries());
        
    }  
	
}
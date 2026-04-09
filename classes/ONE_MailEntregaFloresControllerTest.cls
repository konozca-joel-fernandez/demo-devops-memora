@isTest
public class ONE_MailEntregaFloresControllerTest {
    @isTest
    static void testSendMail() {
        ONE_Tarea__c tarea = [SELECT Id FROM ONE_Tarea__c LIMIT 1];
        
        List<String> success = new List<String>();
        
        Test.startTest();
        success = ONE_MailEntregaFloresController.sendMail(new List<Id> { tarea.Id });
        Test.stopTest();
        
        System.assertEquals('success', success[0], 'An email should have been sent');
    }

    @TestSetup
    static void setup(){
        
        Id accountRecordtypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Person_Accout_Particular' LIMIT 1].Id;
        
        Account difunto = new Account(
        	FirstName = 'Vinicius',
            LastName = 'Jr',
            RecordTypeId = accountRecordtypeId
        );
        insert difunto;
        
        /*Account interlocutorAcc = new Account(
        	FirstName = 'Interlocutor',
            LastName = 'Test',
            ONE_Email__c = 'interlocutor@test.com'
        );
        insert interlocutorAcc;*/
        
        ONE_Expediente__c servicio = new ONE_Expediente__c(
        	ONE_Difunto__c = difunto.id
        );
        insert servicio;
        
        /*ONE_Interlocutor__c interlocutor = new ONE_Interlocutor__c(
            ONE_Expediente__c = servicio.Id,
            ONE_Relacion_con_el_difunto__c = 'Otro',
            ONE_Contacto__c = interlocutorAcc.Id
        );
        insert interlocutor;
            
        ONE_Presupuesto__c presupuesto = new ONE_Presupuesto__c(
        	ONE_Expediente__c = servicio.id,
            ONE_Tipo_De_Presupuesto__c = 'Presupuesto Servicio Completo',
            ONE_Tipo_De_Contrato__c = 'Hoja de servicio',
            ONE_Interlocutor__c = interlocutor.id
        );
        insert presupuesto;*/
        
        ONE_Producto__c flores = new ONE_Producto__c(
        	Name = 'Flores',
            ONE_Descripcion_En_Castellano__c = 'Flores',
            ONE_Clasificacion_ABC__c = 'A',
            ONE_Tipo_De_Precio__c = 'Precio indexado',
            ONE_Validez_Desde__c = Date.today().addDays(-1),
            ONE_Eco__c = 'N/A',
            ONE_Tipo_De_Producto__c = 'Producto comercial',
            ONE_Tipo_Impositivo__c = 'Normal',
            ONE_Flores__c = True            
        );
        insert flores;
        
        ONE_Expediente_Line_Item__c floresSLI = new ONE_Expediente_Line_Item__c(
            ONE_Producto__c = flores.id,
            //ONE_Presupuesto__c = presupuesto.id,
            ONE_Expediente__c = servicio.id,
            ONE_Importe_Base__c = 10,
            ONE_Importe_Neto__c = 12.1,
            ONE_Importe_Impuesto__c = 2.1,
            ONE_Precio__c = 10,
            ONE_Impuesto__c = 21
        );
        insert floresSLI;
        
        Id recordtypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ONE_Tarea_De_Flores' LIMIT 1].Id;
        
        ONE_Tarea__c tarea = new ONE_Tarea__c(
            RecordTypeId = recordtypeId,
            Name = 'Tarea de flores',
            ONE_Expediente__c = servicio.Id,
            ONE_Linea_De_Expediente__c = floresSLI.Id,
            ONE_Producto__c = flores.Id,
            ONE_Tipo_De_Recurso__c = 'Proveedor',
            ONE_Cantidad__c = 1,
            ONE_Tarjeta_O_Lazo__c = 'Lazo',
            ONE_Texto_Banda_O_Lazo__c = 'Texto Test',
            ONE_Correo_Confirmacion__c = 'test@test.com',
            ONE_Numero_Pedido__c = '123456789'
        );
        insert tarea;
    } 
}
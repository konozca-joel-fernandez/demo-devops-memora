public with sharing class ONE_CorreoCreateModPresupuestos {


        @InvocableMethod(label='Enviar Email de Presupuesto' description='Envía un email con la lista de productos contratados.')
        public static void sendEmail(List<EmailRequest> requests) {
            if (requests.isEmpty()) {return; } 
            
            EmailRequest request = requests[0]; 

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
            // Obtener las SLI (productos contratados) del presupuesto
            List<ONE_Expediente_Line_Item__c> sliList = [
             SELECT Name,
                    ONE_Producto__r.Name,
                    ONE_Modelo__r.Name, 
                    ONE_Comentarios__c, 
                    ONE_Cantidad__c FROM ONE_Expediente_Line_Item__c WHERE ONE_Presupuesto__c  = :request.presupuestoId
            ];

            //obtenemos datos para correo
            ONE_Presupuesto__c presupuesto = [
                SELECT 
                    ONE_Expediente__r.Id,
                    ONE_Expediente__r.ONE_Deposito__c,
                    ONE_Expediente__r.ONE_Sala_Deposito__r.Name,
                    ONE_Expediente__r.ONE_Inicio_Deposito__c,
                    ONE_Expediente__r.ONE_Velacion__c,
                    ONE_Expediente__r.ONE_Inicio_Velacion__c, 
                    ONE_Expediente__r.ONE_Sala_De_Velacion__r.Name,
                    ONE_Expediente__r.ONE_Lugar_De_Velacion__r.ONE_Email__c,
                    ONE_Expediente__r.ONE_Ceremonia__c,
                    ONE_Expediente__r.ONE_Inicio_Ceremonia__c,
                    ONE_Expediente__r.ONE_Sala_Ceremonia__r.Name,
                    ONE_Expediente__r.ONE_Lugar_Ceremonia__r.ONE_Email__c,
                    ONE_Expediente__r.ONE_Despedida__c, 
                    ONE_Expediente__r.ONE_Inicio_Despedida__c,
                    ONE_Expediente__r.ONE_Sala_Despedida__r.Name,
                    ONE_Expediente__r.ONE_Lugar_Despedida__r.ONE_Email__c,
                    ONE_Expediente__r.ONE_Centro_Del_Expediente__r.ONE_Email__c,
                    ONE_Expediente__r.ONE_Difunto__r.FirstName,
                    ONE_Expediente__r.ONE_Difunto__r.LastName,
                    ONE_Expediente__r.Name
                FROM ONE_Presupuesto__c 
                WHERE Id = :request.presupuestoId
                LIMIT 1
            ];

            String baseURL = URL.getOrgDomainUrl().toExternalForm();
            String servicioURL = baseURL + '/lightning/r/ONE_Expediente__c/' + presupuesto.ONE_Expediente__r.Id + '/view';
            System.debug('servicioURL: ' + servicioURL);

            List<ONE_Tarea__c> tareas = [ 
                SELECT 
                    Name,
                    ONE_Linea_De_Expediente__r.Name,
                    ONE_Fecha_Hora_Recepci_n_Del_Producto__c,
                    ONE_Lugar_de_Entrega__c
                FROM ONE_Tarea__c
                WHERE ONE_Expediente__r.Name = :presupuesto.ONE_Expediente__r.Name
            ];

            String asunto = getAsunto(presupuesto, sliList);
            String destinatario = getDestinatario(presupuesto);
            String body = getBody(sliList, tareas, servicioURL, presupuesto);
            System.debug('destinatario: ' + destinatario);
            System.debug('asunto: ' + asunto);
            System.debug('body: ' + body);
            
            mail.setToAddresses(new List<String> {destinatario});
            mail.setSubject(asunto);
            mail.setHtmlBody(body);

                
            // Enviar el correo
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
            System.debug('Correo enviado correctamente a: ' + destinatario);
        }








        private static String getAsunto(ONE_Presupuesto__c presupuesto, List<ONE_Expediente_Line_Item__c> sliList) {
            DateTime fechaInicioVelacion = presupuesto?.ONE_Expediente__r?.ONE_Inicio_Velacion__c;
            DateTime fechaInicioCeremonia = presupuesto?.ONE_Expediente__r?.ONE_Inicio_Ceremonia__c;
            DateTime fechaInicioDespedida = presupuesto?.ONE_Expediente__r?.ONE_Inicio_Despedida__c;
            String salaMomento;
        
            // Determinar la fecha más antigua
            DateTime fechaMasAntigua = fechaInicioVelacion;
            salaMomento = presupuesto?.ONE_Expediente__r?.ONE_Sala_De_Velacion__r?.Name;
            if (fechaInicioCeremonia != null && (fechaMasAntigua == null || fechaInicioCeremonia <= fechaMasAntigua)) {
                fechaMasAntigua = fechaInicioCeremonia;
                salaMomento = presupuesto?.ONE_Expediente__r?.ONE_Sala_Ceremonia__r?.Name;
            }
            if (fechaInicioDespedida != null && (fechaMasAntigua == null || fechaInicioDespedida <= fechaMasAntigua)) {
                fechaMasAntigua = fechaInicioDespedida;
                salaMomento = presupuesto?.ONE_Expediente__r?.ONE_Sala_Despedida__r?.Name;
            }
        
            // Construir el asunto

            if (sliList.isEmpty()) {
                return 'Presupuesto Segunda Venta' + ' ' + ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.FirstName) + ' ' +
                       ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.LastName) + ' - ' +
                       ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.Name) + ' - ' +
                       ONE_CommonUtils.changeNullToBlank(salaMomento) + ' - ' +
                       (fechaMasAntigua != null ? fechaMasAntigua.format('dd/MM/yyyy HH:mm') : 'Fecha no disponible') + ' - ' +
                       'Sin productos contratados';
            } else if (sliList.size() > 1) {

                String titulo = 'Presupuesto Segunda Venta' + ' ' + ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.FirstName) + ' ' +
                ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.LastName) + ' - ' +
                ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.Name) + ' - ' +
                ONE_CommonUtils.changeNullToBlank(salaMomento) + ' - ' +
                (fechaMasAntigua != null ? fechaMasAntigua.format('dd/MM/yyyy HH:mm') : 'Fecha no disponible') + ' - ' +
                String.valueOf(sliList.size());

                System.debug('asunto normal' + titulo);

                return titulo;
            } else {

                String titulo = 'Presupuesto Segunda Venta' + ' ' + ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.FirstName) + ' ' +
                ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.ONE_Difunto__r?.LastName) + ' - ' +
                ONE_CommonUtils.changeNullToBlank(presupuesto?.ONE_Expediente__r?.Name) + ' - ' +
                ONE_CommonUtils.changeNullToBlank(salaMomento) + ' - ' +
                (fechaMasAntigua != null ? fechaMasAntigua.format('dd/MM/yyyy HH:mm') : 'Fecha no disponible') + ' - ' +
                ONE_CommonUtils.changeNullToBlank(sliList[0].ONE_Producto__r?.Name);
                System.debug('asunto 1 SLI' + titulo);


                return titulo;
            }
        }

        private static String getDestinatario(ONE_Presupuesto__c presupuesto) {
            List<String> destinatarios = new List<String>{
                presupuesto?.ONE_Expediente__r?.ONE_Lugar_De_Velacion__r?.ONE_Email__c,
                presupuesto?.ONE_Expediente__r?.ONE_Lugar_Ceremonia__r?.ONE_Email__c,
                presupuesto?.ONE_Expediente__r?.ONE_Lugar_Despedida__r?.ONE_Email__c,
                presupuesto?.ONE_Expediente__r?.ONE_Centro_Del_Expediente__r?.ONE_Email__c
            };

            
        
            for (String mail : destinatarios) {
                if (mail != null && mail != '') {
                    return mail;
                }
            }
            return null;
        }

        private static String getBody(List<ONE_Expediente_Line_Item__c> sliList, List<ONE_Tarea__c> tareas, String servicioURL, ONE_Presupuesto__c presupuesto) {
            String productList = '';

            for (ONE_Expediente_Line_Item__c sli : sliList) {
                productList += '- ' + ONE_CommonUtils.changeNullToBlank(sli.ONE_Producto__r.Name) + ': ' + (sli.ONE_Modelo__r.Name != null ? sli.ONE_Modelo__r.Name : 'Modelo único')+ 
                               '(' + sli.ONE_Cantidad__c + '): ' + (sli.ONE_Comentarios__c != null ? sli.ONE_Comentarios__c : 'Sin comentarios');
                
                Boolean hayTarea = false;
                for(ONE_Tarea__c tarea : tareas){
                    if (tarea.ONE_Linea_De_Expediente__r.Name == sli.Name) {
                        productList += ' - Tarea: ' + tarea.Name + ' - ' +
                        (tarea.ONE_Fecha_Hora_Recepci_n_Del_Producto__c != null ? tarea.ONE_Fecha_Hora_Recepci_n_Del_Producto__c.format('dd/MM/yyyy HH:mm') : 'Fecha de recepción no disponible') + ' - ' +
                        (tarea.ONE_Lugar_de_Entrega__c != null ? ' - ' + tarea.ONE_Lugar_de_Entrega__c : 'Lugar de entrega no disponible');
                        hayTarea = true;
                        //productList += ' <br/>';
                        break;
                    }

                
                }

                productList += ' <br/>';
            }
        
            if (String.isEmpty(productList)) {
                productList = 'No hay productos contratados.';
            }


            if(presupuesto.ONE_Expediente__r.ONE_Deposito__c == true){
                productList += '<p>El servicio incluye momento de Deposito: </p>' + (presupuesto.ONE_Expediente__r.ONE_Sala_Deposito__r.Name != null ? presupuesto.ONE_Expediente__r.ONE_Sala_Deposito__r.Name : 'Sala depósito no disponible')
                + ' - ' + (presupuesto.ONE_Expediente__r.ONE_Inicio_Deposito__c != null ? presupuesto.ONE_Expediente__r.ONE_Inicio_Deposito__c.format('dd/MM/yyyy HH:mm') : 'Fecha no disponible');
            }
            if(presupuesto.ONE_Expediente__r.ONE_Velacion__c == true){
                productList += '<p>El servicio incluye momento de Velación: </p>' + (presupuesto.ONE_Expediente__r.ONE_Sala_De_Velacion__r.Name != null ? presupuesto.ONE_Expediente__r.ONE_Sala_De_Velacion__r.Name : 'Sala Velación no disponible')
                +' - ' + (presupuesto.ONE_Expediente__r.ONE_Inicio_Velacion__c != null ? presupuesto.ONE_Expediente__r.ONE_Inicio_Velacion__c.format('dd/MM/yyyy HH:mm') : 'Fecha no disponible');   
            }
            if(presupuesto.ONE_Expediente__r.ONE_Despedida__c == true){
                productList += '<p>El servicio incluye momento de Despedida: </p>' + (presupuesto.ONE_Expediente__r.ONE_Sala_Despedida__r.Name != null ? presupuesto.ONE_Expediente__r.ONE_Sala_Despedida__r.Name : 'Sala Despedida no disponible')
                +' - ' + (presupuesto.ONE_Expediente__r.ONE_Inicio_Despedida__c != null ? presupuesto.ONE_Expediente__r.ONE_Inicio_Despedida__c.format('dd/MM/yyyy HH:mm') : 'Fecha no disponible'); 
            }
            if(presupuesto.ONE_Expediente__r.ONE_Ceremonia__c == true){
                productList += '<p>El servicio incluye momento de Ceremonia: </p>' + (presupuesto.ONE_Expediente__r.ONE_Sala_Ceremonia__r.Name != null ? presupuesto.ONE_Expediente__r.ONE_Sala_Ceremonia__r.Name : 'Sala Ceremonia no disponible') 
                +' - ' + (presupuesto.ONE_Expediente__r.ONE_Inicio_Ceremonia__c != null ? presupuesto.ONE_Expediente__r.ONE_Inicio_Ceremonia__c.format('dd/MM/yyyy HH:mm') : 'Fecha no disponible');
            }



            String bodystructure = '<p>La lista de productos contratados en este presupuesto segunda venta es la siguiente:</p>' +
            '<p>' + productList + '</p>' + '<p>En el siguiente enlace se encuentra el servicio referenciado en el presupuesto: </p>' + 
            '<p>' + servicioURL + '</p>' +
            '<p>Un saludo,</p>';
        
            return bodystructure;
        }
        
    
        public class EmailRequest {
            @InvocableVariable(label='ID Presupuesto' required=true)
            public Id presupuestoId;
        }
}
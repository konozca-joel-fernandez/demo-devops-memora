public with sharing class ONE_SendNotisCasosAbiertos {

    public class CasoWrapper{
        @InvocableVariable()
        public List<ONE_Caso__c> casosNotificar;
    }

    @InvocableMethod(label='Notificar Casos Pendientes')
    public static void notificar(List<CasoWrapper> casosInput) {
        
    List<ONE_Caso__c> casos = new List<ONE_Caso__c>();
    for (CasoWrapper wrapper : casosInput) {
        if (wrapper.casosNotificar != null) {
            casos.addAll(wrapper.casosNotificar);
        }
    }
        
        Map<Id, List<ONE_Caso__c>> casosPorUsuario = new Map<Id, List<ONE_Caso__c>>();

        for (ONE_Caso__c caso : casos) {
            Id destinatario = caso.ONE_Asesor_Propuesto__c != null ? caso.ONE_Asesor_Propuesto__c : caso.OwnerId;

            if (!casosPorUsuario.containsKey(destinatario)) {
                casosPorUsuario.put(destinatario, new List<ONE_Caso__c>());
            }
            casosPorUsuario.get(destinatario).add(caso);
        }

        // Recuperamos los emails de los destinatarios
        Map<Id, User> usuarios = new Map<Id, User>(
            [SELECT Id, Name, Email FROM User WHERE Id IN :casosPorUsuario.keySet()]
        );

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id usuarioId : casosPorUsuario.keySet()) {
            User usuario = usuarios.get(usuarioId);
            if (usuario == null || String.isBlank(usuario.Email)) {
                continue; // Saltamos si no hay email
            }

            List<ONE_Caso__c> listaCasos = casosPorUsuario.get(usuarioId);
            String cuerpo = '<p> Han pasado más de 5 días desde la creación de estos casos y se encuentran en estado de gestión. Revisa si deben pasar a estado cerrado (por servicio o competencia) o anulado: </p></br>';

            for (ONE_Caso__c c : listaCasos) {
                    String url = URL.getOrgDomainUrl().toExternalForm() + '/' + c.Id;
                    cuerpo += '<li><a href="' + url + '">' + c.Name + '</a></li><br/></ul>';

            }

            

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ usuario.Email });
            email.setSubject('CASOS PENDIENTES DE GESTIONAR');
            email.setHtmlBody(cuerpo);
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }
    }
}
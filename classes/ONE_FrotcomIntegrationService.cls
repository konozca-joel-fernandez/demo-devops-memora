public with sharing class ONE_FrotcomIntegrationService {
    private static String TYPE_ID = '2991';
    
    @future(callout=true)
    public static void sendTask(Id taskId) {
        ONE_Tarea__c task = [
            SELECT Id, ONE_Nombre_Y_Apellidos_Del_Difunto__c
            FROM ONE_Tarea__c
            WHERE Id = :taskId
        ];
        
        List<RequestWrapperItem> requestWrapperItems = new List<RequestWrapperItem>();
        requestWrapperItems.add(new RequestWrapperItem(task.ONE_Nombre_Y_Apellidos_Del_Difunto__c, task.Id));
        requestWrapperItems.add(new RequestWrapperItem(task.ONE_Nombre_Y_Apellidos_Del_Difunto__c, task.Id));
        ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout callout = new ONE_FrotcomIntegrationCallout.FrotcomSendTasksCallout(requestWrapperItems);
        HttpResponse resp = callout.invokeCallout(false);
        Integer statusCode = resp.getStatusCode();
        
        if ( (statusCode == ONE_CommonConstants.HTPP_SUCCESS_CODE || statusCode == ONE_CommonConstants.HTPP_SUCCESS_CODE_CREATED) &&
              String.isNotBlank(resp.getBody()) ) {
                try {
                    List<ResponseItem> responseItems = (List<ResponseItem>) JSON.deserialize(resp.getBody(), List<ResponseItem>.class);
                    ResponseItem item = responseItems.get(0);
                    task.ONE_ID_Tarea_Frotcom__c = item.id;
                    task.ONE_ID_Task_Frotcom_Origen__c = item.tasks.get(0);
                    task.ONE_ID_Task_Frotcom_Destino__c = item.tasks.get(1);
                } catch (Exception ex) {
                    task.ONE_Creaci_n_Tarea_Frotcom_Fallida__c = true;
                    System.debug(ex);
                }
        } else {
            task.ONE_Creaci_n_Tarea_Frotcom_Fallida__c = true;
            System.debug(resp.getStatusCode() + ' ' + resp.getBody());
        }
        update task;
    }

    //In case we call this from flow
    public class FrotcomFlowInput {
        @InvocableVariable(required=true)
        public Id taskId;
    }

    @InvocableMethod(label='Enviar tarea a Frotcom' description='Enviar tarea a Frotcom')
    public static void sendTaskFlow(List<FrotcomFlowInput> inputs) {
        for (FrotcomFlowInput input : inputs) {
            sendTask(input.taskId); // método @future
        }
    }


    
    public class RequestWrapperItem {
        public String id {
            public get;
            private set;
        }
        public String typeId {
            public get;
            private set;
        }
        public WhatWrapper what {
            public get;
            private set;
        }
        public WhoWrapper who {
            public get;
            private set;
        }
        public WhenWrapper whenParam {public get; private set;}
        public HowWrapper how {
            public get;
            private set;
        }
        public WhereWrapper whereParam {
            public get;
            private set;
        }
        
        public RequestWrapperItem(String content, String reference) {
            this.id = null;
            this.typeId = TYPE_ID;
            this.what = new WhatWrapper(content, reference);
            this.who = new WhoWrapper();
            this.how = new HowWrapper();
            this.whenParam = new WhenWrapper();
            this.whereParam = new WhereWrapper();
        }
    }
    
    public class WhatWrapper {
        public String content;
        public String reference;
        public String notes;
        
        public WhatWrapper(String content, String reference) {
            this.content = content;
            this.reference = reference;
            this.notes = '';
        }
    }
    
    public class WhoWrapper {
        public String clientId;
        public String contactId;
        public String contactName;
        public String clientName;
        public String officePhone;
        public String mobilePhone;
        
        public WhoWrapper() {
            clientId = null;
            contactId = null;
            contactName = null;
            clientName = null;
            officePhone = null;
            mobilePhone = null;
        }
    }
    
    public class WhenWrapper {
        public String start;
        public String endParam;
        public Integer toleranceBefore;
        public Integer toleranceAfter;
        public String exclusionStart;
        public String exclusionEnd;
        public Boolean sla;
        public String whenParam;
        public Boolean exclusion;
        public Boolean tolerance;
        public String notes;
        
        public WhenWrapper() {
            this.start = null;
            this.endParam = null;
            this.toleranceBefore = 0;
            this.toleranceAfter = 0;
            this.exclusionStart = null;
            this.exclusionEnd = null;
            this.sla = false;
            this.whenParam = 'timeAndTolerance';
            this.exclusion = false;
            this.tolerance = false;
            this.notes = '';
        }
    }
    
    public class WhereWrapper {
        public String latitude;
        public String longitude;
        public String addressLine1;
        
        public WhereWrapper() {
            this.latitude = null;
            this.longitude = null;
            this.addressLine1 = '';
        }
    }
    
    public class HowWrapper {
        public String instructions;
        public String notes;
        
        public HowWrapper() {
            this.instructions = '';
            this.notes = '';
        }
    }
    
    public class ResponseItem {
        public String id {
            public get;
        }
        public List<String> tasks {
            public get;
        }
        public Boolean isNew {
            public get;
        }
    }
}
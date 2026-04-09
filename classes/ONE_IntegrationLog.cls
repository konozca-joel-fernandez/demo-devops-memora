/**
 * Created by mbujak003 on 15.02.2021.
 */

public without sharing class ONE_IntegrationLog {

    public enum Direction {
        OUTBOUND,
        INBOUND
    }

    public String request { get; private set; }
    public String response { get; private set; }
    public String method { get; private set; }
    public String endpoint { get; private set; }
    public String className { get; private set; }
    public Direction direction { get; private set; }
    public String details { get; private set; }

    public ONE_IntegrationLog(String newClassName, String newRequest, String newResponse, String newMethod, String newEndpoint, Direction newDirection) {
        className = newClassName;
        request = newRequest;
        response = newResponse;
        method = newMethod;
        endpoint = newEndpoint;
        direction = newDirection;
    }

    //2nd constructor with details
    public ONE_IntegrationLog(String newClassName, String newRequest, String newResponse, String newMethod, String newEndpoint, Direction newDirection, String newDetails) {
        className = newClassName;
        request = newRequest;
        response = newResponse;
        method = newMethod;
        endpoint = newEndpoint;
        direction = newDirection;
        details = newDetails;
    }

    public static void commitLog(ONE_IntegrationLog integrationLog, Boolean asyncCommit, Boolean asQueueable) {
        commitLogs(new List<ONE_IntegrationLog> { integrationLog }, asyncCommit, true);
    }

    public static void commitLogs(List<ONE_IntegrationLog> integrationLogs, Boolean asyncCommit, Boolean asQueueable) {
        List<ONE_LogIntegraciones__c> logsToCommit = new List<ONE_LogIntegraciones__c>();
        for(ONE_IntegrationLog integrationLog : integrationLogs) {

            String rtId = integrationLog.direction == Direction.OUTBOUND ?
                ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_LogIntegraciones__c', 'Outbound') :
                ONE_CommonUtils.getsObjectRecordTypeIdByName('ONE_LogIntegraciones__c', 'Inbound');

            logsToCommit.add(new ONE_LogIntegraciones__c(
                ONE_Request__c = integrationLog.request.length() > 131071 ? integrationLog.request.substring(0, 131071) : integrationLog.request,
                ONE_Response__c = integrationLog.response.length() > 131071 ? integrationLog.response.substring(0, 131071) : integrationLog.response,
                ONE_Method__c = integrationLog.method,
                ONE_Endpoint__c = integrationLog.endpoint.length() > 255 ? integrationLog.endpoint.substring(0, 255) : integrationLog.endpoint,
                ONE_ClassName__c = integrationLog.className,
                recordTypeId = rtId,
                ONE_Details__c = integrationLog.details?.length() > 32767 ? integrationLog.details.substring(0, 32767) : integrationLog.details
            ));
        }
        if(asyncCommit) {
            if(asQueueable && !System.isQueueable()) {
                commitLogAsQueueable(logsToCommit);
            } else {
                commitLogAsFuture(JSON.serialize(logsToCommit));
            }
        } else {
            insert logsToCommit;
        }
    }

    private static void commitLogAsQueueable(List<ONE_LogIntegraciones__c> logsToCommit) {
        System.enqueueJob(new LogQueueableJob(logsToCommit));
    }

    @Future
    private static void commitLogAsFuture(String logsJson) {
        List<ONE_LogIntegraciones__c> logsToCommit = (List<ONE_LogIntegraciones__c>)JSON.deserialize(logsJson, List<ONE_LogIntegraciones__c>.class);
        insert logsToCommit;
    }

    private class LogQueueableJob implements Queueable {
        private List<ONE_LogIntegraciones__c> logsToCommit;

        public LogQueueableJob(List<ONE_LogIntegraciones__c> newLogsToCommit) {
            logsToCommit = newLogsToCommit;
        }

        public void execute(QueueableContext context) {
            insert logsToCommit;
        }
    }
}
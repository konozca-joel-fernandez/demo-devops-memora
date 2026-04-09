/**
 * Created by mbujak003 on 19.01.2021.
 */

public with sharing class ONE_Exception extends Exception {

    public Enum ExceptionType {
        INTEGRATION
    }

    public String message;
    public ExceptionType type;
    public String stackTrace;

    public ONE_Exception(ExceptionType exType, String exMessage, String exStackTrace) {
        type = exType;
        message = exMessage;
        stackTrace = exStackTrace;
    }

    public ONE_Exception(ExceptionType exType, String exMessage) {
        type = exType;
        message = exMessage;
    }

    public void insertException() {
        //insert new ONE_Excepciones__c();
    }
}
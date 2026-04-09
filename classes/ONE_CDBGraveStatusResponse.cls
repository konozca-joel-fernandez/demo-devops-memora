/**
 * Created by mchruscick001 on 08.10.2021 10:42.
 */

public with sharing class ONE_CDBGraveStatusResponse {
    @AuraEnabled
    public String codi;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String pendent;
    @AuraEnabled
    public String mensaje;
}
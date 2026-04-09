/**
 * Created by mbujak003 on 15.12.2020.
 */

public with sharing class ONE_CreateAccountFormController {

    private static Set<String> availableRecordTypes = new Set<String> {
        ONE_CommonConstants.ACC_RT_PERSON_ACCOUNT_PARTICULAR
    };

    @AuraEnabled
    public static String fetchRecordTypes() {
        return ONE_CommonUtils.prepareRecordTypesPicklist(availableRecordTypes);
    }
}
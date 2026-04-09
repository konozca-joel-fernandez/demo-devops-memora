/**
 * Created by mbujak003 on 13.01.2021.
 */

public with sharing class ONE_NewAccountFlowButtonController {

    private static Set<String> availableRecordTypes = new Set<String> {
        ONE_CommonConstants.ACC_RT_OTRAS_CUENTAS
    };

    @AuraEnabled
    public static String fetchRecordTypes() {
        return ONE_CommonUtils.prepareRecordTypesPicklist(availableRecordTypes);
    }

}
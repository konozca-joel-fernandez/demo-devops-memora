/**
 * Created by mbujak003 on 27.11.2020.
 */

public with sharing class ONE_CommonUtils {

    private static Map<String, Map<String, Id>> objName2RtApiName;
    private static Map<String, Map<String, String>> objName2RtId;
    private static Map<String, Map<String, String>> objLabel2RtId;
    private static Map<Id, Profile> id2Profile;
    private static Map<String, Id> name2ProfileId;


    /**
     * Returns the number of specific day in a week
     * @param dt date to check the number of day for
     *
     * @return integer value for day of week
     */
    public static Integer dayNumber(Date dt) {
        return Math.mod(Date.newInstance(1900, 1, 7).daysBetween(dt), 7);
    }

    /**
     * Returns Id of the chosen object's record type.
     * @param objApiName the name of the object record type's from
     * @param rtName the name of chosen record type
     */
    public static String getsObjectRecordTypeIdByName(String objApiName, String rtApiName) {
        initializeRecTypes();
        if (objName2RtApiName.get(objApiName) == null) {
            return null;
        }

        return objName2RtApiName.get(objApiName).get(rtApiName);
    }

    /**
     * Returns Name of the chosen object's record type.
     * @param objApiName the name of the object record type's from
     * @param rtId the id of chosen record type
     */
    public static String getsObjectRecordTypeNameById(String objApiName, Id rtId) {
        initializeRecTypes();
        if (objName2RtId.get(objApiName) == null) {
            return null;
        }
        return objName2RtId.get(objApiName).get(rtId);
    }

    private static void initializeRecTypes() {
        if (objName2RtApiName == null || objName2RtId == null) {
            objName2RtApiName = new Map<String, Map<String, Id>>();
            objName2RtId = new Map<String, Map<String, String>>();

            for (RecordType rt : [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType]) {
                Map<String, Id> rtApiName2Id;
                Map<String, String> rtId2ApiName;
                if (objName2RtApiName.get(rt.SobjectType) == null) {
                    rtApiName2Id = new Map<String, Id>();
                    rtId2ApiName = new Map<String, String>();
                } else {
                    rtApiName2Id = objName2RtApiName.get(rt.SobjectType);
                    rtId2ApiName = objName2RtId.get(rt.SobjectType);
                }
                rtApiName2Id.put(rt.DeveloperName, rt.Id);
                objName2RtApiName.put(rt.SobjectType, rtApiName2Id);
                rtId2ApiName.put(rt.Id, rt.Name);
                objName2RtId.put(rt.SobjectType, rtId2ApiName);
            }
        }
    }

    /**
     * Returns Label of the chosen object.
     * @param obj sObject which Label is needed
     */
    public static String getsObjectLabel(sObject obj) {
        try {
            return obj.getSobjectType().getDescribe().getLabel();
        } catch (Exception ex) {
        }
        return null;
    }

    /**
     * Returns Name of the chosen object.
     * @param obj sObject which Name is needed
     */
    public static String getsObjectName(sObject obj) {
        try {
            return obj.getSobjectType().getDescribe().getName();
        } catch (Exception ex) {
        }
        return null;
    }

    /**
     * Returns Name of the chosen object.
     * @param objId sObject Id which Name is needed
     */
    public static String getsObjectName(Id objId) {
        try {
            return objId.getSobjectType().getDescribe().getName();
        } catch (Exception ex) {
        }
        return null;
    }

    /**
     * Builds dynamic query based on object api name and provided fields
     */
    public static String buildDynamicQuery(String objectApiName, Set<String> fields) {
        String query = 'SELECT ';
        for (String field : fields) {
            query += field + ',';
        }
        query = query.removeEnd(',');
        query += ' FROM ' + objectApiName;
        return query;
    }

    /**
     * Builds dynamic nested query based on relation api name and provided fields and inject to main query
     */
    public static String injectNestedDynamicQuery(String mainQuery, String relationName, Set<String> fields) {
        String query = buildDynamicQuery(relationName, fields);
        String reversed = mainQuery.reverse();
        reversed = reversed.replaceFirst((' FROM ').reverse(), (',( ' + query + ' ) FROM ').reverse());

        return reversed.reverse();
    }

    private static void initProfiles() {
        if (id2Profile == null || id2Profile.isEmpty()) {
            id2Profile = new Map<Id, Profile>([SELECT Id, Name FROM Profile]);
        }
    }
    /**
     * Returns the name of a profile from it's Id
     * @param profileId Id of the chosen profile
     */
    public static String getProfileNameById(Id profileId) {
        return new List<String>(getProfileNamesByIdSet(new Set<Id>{
            profileId
        })).get(0);
    }
    /**
     * Returns the Id of a profile from it's name
     * @param profileName name of the chosen profile
     */
    public static String getProfileIdByName(String profileName) {
        return new List<String>(getProfileIdsByNameSet(new Set<String>{
            profileName
        })).get(0);
    }
    /**
     * Returns set of names of profiles based on an Id set
     * @param profileIds Set of Ids of the chosen profile
     */
    public static Set<String> getProfileNamesByIdSet(Set<Id> profileIds) {
        initProfiles();
        Set<String> profileNames = new Set<String>();
        for (Id profileId : profileIds) {
            Profile profile = id2Profile.get(profileId);
            if (profile != null) {
                profileNames.add(profile.Name);
            }
        }
        return profileNames;
    }
    /**
     * Returns a set of Ids of profiles based on a set of their names
     * @param profileNames set of names of the chosen profile
     */
    public static Set<String> getProfileIdsByNameSet(Set<String> profileNames) {
        initProfiles();
        Set<String> profileIds = new Set<String>();
        if (name2ProfileId == null) {
            name2ProfileId = new Map<String, Id>();
            for (Profile profile : id2Profile.values()) {
                name2ProfileId.put(profile.Name, profile.Id);
            }
        }
        for (String profileName : profileNames) {
            profileIds.add(name2ProfileId.get(profileName));
        }
        return profileIds;
    }

    /**
    * @param dt Datetime value to format
    *
    * @return time value of datetime (no date)
    */
    public static String formatTimeValue(Datetime dt) {
        return dt.format(ONE_CommonConstants.TIME_FORMAT);
    }

    /**
    * @param dt Datetime value to format
    *
    * @return date value of datetime (no time)
    */
    public static String formatDateValue(Datetime dt) {
        return dt.format(ONE_CommonConstants.DATE_FORMAT);
    }
	
    //Replace null value for empty string
    public static String changeNullToBlank(String str) {
        return str == null ? '' : str;
    }
	
    //Convert string arrary into a single string
    public static String convertListToStringOfValues(List<String> values) {
        return (values != null) ? '\'' + String.join(values, '\',\'') + '\'' : '\'\'';
    }
	
    //Convert list into string values
    public static String convertListToStringOfValues(List<Database.Error> values) {
        List<String> errorMessages = new List<String>();
        for (Database.Error value : values) {
            errorMessages.add(value.getStatusCode() + ' : ' + value.getMessage());
        }
        return convertListToStringOfValues(errorMessages);
    }
	// Get ID and API Name based on the imput record type name
    public static String prepareRecordTypesPicklist(Set<String> recordTypes) {
        List<PicklistEntryWrapper> rtWrappers = new List<PicklistEntryWrapper>();
        for (RecordType rt : [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = :ONE_CommonConstants.ACCOUNT
            AND DeveloperName IN:recordTypes
        ]) {
            rtWrappers.add(new PicklistEntryWrapper(rt.Id, rt.Name));
        }
        return JSON.serialize(rtwrappers);
    }
	
    //Wrapper for picklist value population
    public class PicklistEntryWrapper {
        String id { get; private set; }
        String label { get; private set; }
        Boolean selected { get; private set; }
        public PicklistEntryWrapper(String id, String label) {
            this.id = id;
            this.label = label;
            this.selected = false;
        }
    }

    public class ProxyController {
        public ProxyController() {
            String lcBaseUrl = '';
            String hostname = Url.getSalesforceBaseUrl().getHost();
            String myDomain = hostname.split('\\.')[0];
            if (myDomain.contains('--')) {
                //uses lastIndex to exclude namespace but include sandbox names
                // e.g. https://mydomain--sandbox--namespace.visualforce.com
                // and https://mydomain--namespace.visualforce.com
                myDomain = myDomain.substring(0, hostname.lastIndexOf('--'));
            }
            lcBaseURL = 'https://' + myDomain + '.lightning.force.com';
            system.debug('lcBaseURL: '+lcBaseURL);
            Map<String, String> headers = ApexPages.currentPage().getHeaders();
            headers.put('X-Frame-Options', 'ALLOW-FROM ' + lcBaseURL);
            headers.put('Content-Security-Policy', 'frame-ancestors ' + lcBaseURL);
        }
    }
	
    @AuraEnabled
    public static List<String> getVFBaseURL() {

/*
        String hostname = Url.getSalesforceBaseUrl().getHost();
        // will support prod and sandboxes
        // e.g. https://mydomain--sandbox.lightning.force.com
        // and https://mydomain.lightning.force.com
        String myDomain = hostname.split('\\.')[0];
        String namespace = 'c';
        String pod = [SELECT InstanceName FROM Organization].InstanceName.toLowerCase();

        List<String> retList = new List<String>{
            ('https://' + myDomain + '--' + namespace + '.visualforce.com').replaceAll('--c--c', '--c'),
            ('https://' + myDomain + '--' + namespace + '.' + pod + '.visual.force.com').replaceAll('--c--c', '--c'),
            ('https://' + myDomain + '.lightning.force.com').replaceAll('--c', '')
        };
*/

        String hostname = Url.getSalesforceBaseUrl().getHost();
        String myDomain = hostname.split('\\.')[0];
        String sandbox = '';
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if (runningInASandbox) {
            sandbox = '.sandbox';
        }

        List<String> retList = new List<String>{
            ('https://' + myDomain + '--c' + sandbox + '.vf.force.com').replaceAll('--c--c', '--c'),
            (''),
            ('https://' + myDomain + sandbox + '.lightning.force.com').replaceAll('--c', '')
        };

        for (String s : retList) {
            System.debug(s);
        }

        return retList;
    }
	//Display Type MAP
    public static Map<DisplayType, Type> dispType2Type = new Map<DisplayType, Type>{
        DisplayType.BASE64 => Blob.class,
        DisplayType.BOOLEAN => Boolean.class,
        DisplayType.COMBOBOX => String.class,
        DisplayType.CURRENCY => Decimal.class,
        DisplayType.DATE => Date.class,
        DisplayType.DATETIME => Datetime.class,
        DisplayType.DOUBLE => Double.class,
        DisplayType.EMAIL => String.class,
        DisplayType.ID => String.class,
        DisplayType.INTEGER => Integer.class,
        DisplayType.JSON => String.class,
        DisplayType.LONG => Long.class,
        DisplayType.MULTIPICKLIST => String.class,
        DisplayType.PERCENT => Decimal.class,
        DisplayType.PHONE => String.class,
        DisplayType.PICKLIST => String.class,
        DisplayType.REFERENCE => String.class,
        DisplayType.STRING => String.class,
        DisplayType.TEXTAREA => String.class,
        DisplayType.TIME => Time.class,
        DisplayType.URL => String.class
    };
	
    //Method to create inbound integration log 
    public static void createInboundIntegrationLog(String className, String request, String response, String methodName, String endpointMetadataName) {
        ONE_Integration_endpoint__mdt endpointData = [
            SELECT DeveloperName, ONE_Resource__c, ONE_Active__c, ONE_Named_Credentials__c, ONE_LogActive__c
            FROM ONE_Integration_endpoint__mdt
            WHERE DeveloperName = :endpointMetadataName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (endpointData.ONE_LogActive__c) {
            ONE_IntegrationLog integrationLog = new ONE_IntegrationLog(
                className,
                request,
                response,
                methodName,
                Url.getOrgDomainUrl().toExternalForm() + endpointData.ONE_Resource__c,
                ONE_IntegrationLog.Direction.INBOUND
            );

            System.debug('integrationLog');
            System.debug(integrationLog);
            ONE_IntegrationLog.commitLog(integrationLog, true, true);
        }
    }


}
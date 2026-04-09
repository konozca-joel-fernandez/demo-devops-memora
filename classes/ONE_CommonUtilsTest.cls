//Test class for the Linea de Planificación handler
@IsTest
private class ONE_CommonUtilsTest {

    @isTest
    private static void getsObjectLabel() {

        ONE_CommonUtils.getsObjectLabel(new Account());
    }

    @isTest
    private static void getsObjectName() {

        ONE_CommonUtils.getsObjectName(new Account());
    }

    @isTest
    private static void injectNestedDynamicQuery() {

        String mainQuery = 'SELECT Id FROM Account';
        String relationName = 'Contact';
        Set<String> fields = new Set<String> {'Id'};
        ONE_CommonUtils.injectNestedDynamicQuery(mainQuery, relationName, fields);
    }

    @isTest
    private static void getProfileIdByName() {

        ONE_CommonUtils.getProfileIdByName('Polivalente');
    }

    @isTest
    private static void formatTimeValue() {

        ONE_CommonUtils.formatTimeValue(Datetime.now());
    }

    @isTest
    private static void formatDateValue() {

        ONE_CommonUtils.formatDateValue(Datetime.now());
    }

    @isTest
    private static void convertListToStringOfValues() {

        Database.SaveResult saveResult = Database.insert(new Account(Name = ''), false);
        List<Database.Error> values = saveResult.getErrors();
        ONE_CommonUtils.convertListToStringOfValues(values);
    }

    @isTest
    private static void ProxyController() {

        ONE_CommonUtils.ProxyController proxyController = new ONE_CommonUtils.ProxyController();
    }
}
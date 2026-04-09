public class ONE_NecrologicaPdfController {
    
    public Id accountOrLugarID {public get; private set;}
    public String level {public get; private set;} // zona_operativa, centro, area_operativa, delegacion, ambito
    public String language {public get; private set;}
    public Date startDate {public get; private set;}
    public Date endDate {public get; private set;}
    public ONE_NecrologicaData data {public get; private set;}

    public ONE_NecrologicaPdfController() {
        accountOrLugarID = ApexPages.currentPage().getParameters().get('accountOrLugarID');
        System.debug('accountOrLugarID ' + accountOrLugarID);

        language = ApexPages.currentPage().getParameters().get('language');
        System.debug('language ' + language);        

        level = ApexPages.currentPage().getParameters().get('level');
        System.debug('level ' + level);

        startDate = date.valueOf(ApexPages.currentPage().getParameters().get('startDate'));
        System.debug('startDate ' + startDate);

        endDate = date.valueOf(ApexPages.currentPage().getParameters().get('endDate'));
        System.debug('endDate ' + endDate);

        setupData(); 
    }

    public void setupData() {
        System.debug('setupData ' + accountOrLugarID + language + level +startDate+endDate);
        data = ONE_NecrologicaDataFactory.buildNecrologicaData(accountOrLugarID, language, level, startDate, endDate);
    }
}
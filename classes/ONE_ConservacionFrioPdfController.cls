/**
 * Created by Pau Galindo on 09.08.2022.
 */

public with sharing class ONE_ConservacionFrioPdfController {
    
    public Id accountId {public get; private set;}
    public String language {public get; private set;}
    public ONE_ConservacionFrioData data {public get; private set;}
    
    public ONE_ConservacionFrioPdfController() {
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        language = ApexPages.currentPage().getParameters().get('language');
        setupData();
    }
	//Add data to the PDF content
    public void setupData() {
        data = ONE_ConservacionFrioDataFactory.buildConservacionFrioData(accountId, language);
    }
}
/*
Name - OverrideNewMeeting_Test
Author - Shyam Prasad Nayakula
Purpose - Test Class
Date - May-2017
*/
@isTest
public class OverrideNewMeeting_Test 
{
    static testMethod void testOverrideMeetingForAccount()
    {
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        ApexPages.currentPage().getParameters().put('retURL','/'+acc.ID);
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        OverrideNewMeeting objVar = new OverrideNewMeeting(stdController);
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        objVar.BaseURL = baseURL;
        objVar.URL = baseURL+'/apex/OverrideNewMeeting/save_new=1';
        objVar.overridePage();
    }
    static testMethod void testOverrideMeetingForOppty()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('OpportunityTrigger').isActive__c=TRUE;
        insert triggerSwitches.values();

        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        insert opp;
        
        ApexPages.currentPage().getParameters().put('retURL','/'+opp.ID);
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        OverrideNewMeeting objVar = new OverrideNewMeeting(stdController);
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        objVar.BaseURL = baseURL;
        objVar.URL = baseURL+'/apex/OverrideNewMeeting/save_new=1';
        objVar.overridePage();
    }
}
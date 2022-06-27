@istest
public  Class GE_NAS_Carrier_Trigger_Test 
{
    static testMethod void carriertest()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        Account acc= TestDataUtil.createAccount();
        acc.Name='LAND AIR EXPRESS';
        acc.GE_NAS_AccountNO__c='9884034';
        
        GE_NAS_Carrier__c car=new GE_NAS_Carrier__c(GE_NAS_Account_Number__c='9884034',Name='LAND AIR EXPRESS');
        
        insert acc;
        insert car;
    }
}
@isTest
public class BlockAccountsByRepcodes_Test 
{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void multiplePOTest()
    {
        Test.startTest();
        Map<String,TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitchesMAP();
        switchList.get('OppPusher').isActive__c=false;
        switchList.get('GE_LGT_ShipDateShouldBeGTPODate').isActive__c=false;
        switchList.get('GE_LGT_ShipDateShouldBeGTPODate').isActive__c=false;
        insert switchList.values();
        
    
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId=recAccTypeID;
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.GE_LGT_EM_CustomerActiveFlag__c=true;
        acc.Account_Group__c='ZEAG';
        acc.GE_LGT_Rep_Code__c='H2E0001';
        insert acc;
        
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new SheduleBlockAccountsByRepcodes());
        Test.stopTest();
        
       
    }
}
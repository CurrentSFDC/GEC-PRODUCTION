@isTest
public class DeleteAccountsByflags_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void DeleteAccountsByflags()
    {
        Test.startTest();
        Map<String,TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitchesMAP();
        switchList.get('OppPusher').isActive__c=false;
        switchList.get('GE_LGT_ShipDateShouldBeGTPODate').isActive__c=false;
        switchList.get('GE_LGT_ShipDateShouldBeGTPODate').isActive__c=false;
        insert switchList.values();
        
        
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId=recAccTypeID;
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.GE_LGT_EM_SAP_Customer_Number__c='0000009456';
        acc.GE_LGT_EM_Sales_Org__c='1CA1';
        acc.GE_LGT_EM_Division__c='20-Comp';
        acc.GE_LGT_EM_PF_Type__c='SP';
        acc.GE_LGT_EM_Distribution_Channel__c='30-Sol';
        acc.GE_LGT_EM_CustomerActiveFlag__c=false;
        acc.Account_Group__c='ZEAG';
        acc.GE_LGT_Rep_Code__c='H2E0001';
        insert acc;
        SAP_Records_Recycle__c saprecylce=new SAP_Records_Recycle__c();
        saprecylce.GE_LGT_EM_SAP_Customer_Number__c='0000009456';
        saprecylce.GE_LGT_EM_Sales_Org__c='1CA1';
        saprecylce.GE_LGT_EM_Division__c='20-Comp';
        saprecylce.GE_LGT_EM_PF_Type__c='SP';
        saprecylce.GE_LGT_EM_Distribution_Channel__c='30-Sol';
        insert saprecylce;
        Id AccountBatchForBlockAccountsByRepcodesBatchId= Database.executeBatch(new DeleteAccountsByflags()); 
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new SheduleDeleteAccountsByflags());
        Test.stopTest();
        
        
    }
}
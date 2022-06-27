@isTest
public class GE_LGT_Batch_OrderDeletion_Test 
{
    static testmethod void deletionTestMethod()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.add(triggerSwitch2);
        TriggerSwitch__c triggerSwitch3=TestDataUtil.createTriggerSwitch('GE_LGT_OpptyBefInsBefUpdtAftIns',true);
        switchList.add(triggerSwitch3);
        TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',true);
        switchList.add(triggerSwitch4);
        insert switchList;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        insert acc;
        
        Order order=TestDataUtil.createOrder('9999');
        order.Accountid=acc.id;
        order.GE_Opportunity_Id__c='EU1234';
        insert order;
        
        Test.startTest();
        GE_LGT_Batch_OrderDeletion orderDel=new GE_LGT_Batch_OrderDeletion();
        Database.executeBatch(orderDel);
        Test.stopTest();
    }
    static testmethod void deletionScheduleTestMethod()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.add(triggerSwitch2);
        TriggerSwitch__c triggerSwitch3=TestDataUtil.createTriggerSwitch('GE_LGT_OpptyBefInsBefUpdtAftIns',true);
        switchList.add(triggerSwitch3);
        TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',true);
        switchList.add(triggerSwitch4);
        insert switchList;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        insert acc;
        
        Order order=TestDataUtil.createOrder('9999');
        order.accountid=acc.id;
        order.GE_Opportunity_Id__c='EU1234';
        insert order;
        
        Test.startTest();
        GE_LGT_OrderAndItemDeletion_Schedule orderDel=new GE_LGT_OrderAndItemDeletion_Schedule();
        orderDel.execute(NULL);
        Test.stopTest();
    }
}
@isTest
public class GE_LGT_EM_UnfollowRecords_Test 
{
    static testmethod void testBatchMethod()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
         ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.recordtypeid=recAccTypeID;
        insert acc;
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.Name = 'Testtandrasai';
        opp.StageName =  'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.recordtypeid=recOppTypeID;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.GE_LGT_Reason_Won_Lost__c=System.Label.Customer_Cancelled;
        opp.CloseDate = System.Today() + 20;
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 40;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 45;
        opp.GE_LGT_GE_Opportunity_Id__c = 'AATestID'; 
        opp.Warranty__c = 'Standard Product Warranty';   
        opp.Last_Ship_Date__c=System.Today() - 45;
        
        insert opp;
        EntitySubscription e=new EntitySubscription();
        e.ParentId=opp.id;
        e.SubscriberId=UserInfo.getUserId();
        insert e;
        
        
        Test.startTest();
        GE_LGT_EM_UnfollowRecords u=new GE_LGT_EM_UnfollowRecords();
        Database.executeBatch(u);
        Test.stopTest();
    }
    static testmethod void testBatchMethod1()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
         ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
         acc.recordtypeid=recAccTypeID;
        insert acc;
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.Name = 'Testtandrasai';
        opp.StageName = 'Closed Lost';
        opp.Type='End User - Retrofit';
        opp.recordtypeid=recOppTypeID;
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.GE_LGT_Reason_Won_Lost__c=System.Label.Customer_Cancelled;
        opp.CloseDate = System.Today() + 20;
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 40;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 45;
        opp.GE_LGT_GE_Opportunity_Id__c = 'AATestID'; 
        opp.Warranty__c = 'Standard Product Warranty';   
        opp.Last_Ship_Date__c=System.Today() - 45;
        insert opp;
        EntitySubscription e=new EntitySubscription();
        e.ParentId=opp.id;
        e.SubscriberId=UserInfo.getUserId();
        insert e;
        
        Test.startTest();
        
        GE_LGT_EM_UnfollowRecords_Schedule sh1 = new GE_LGT_EM_UnfollowRecords_Schedule();      
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();
    }
}
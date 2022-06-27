@isTest
public class Optyupdation_test {
    static testmethod void multiplePOTest()
    {
        Test.startTest();
        Map<String,TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitchesMAP();
        switchList.get('OppPusher').isActive__c=false;
        switchList.get('GE_LGT_ShipDateShouldBeGTPODate').isActive__c=false;
        switchList.get('GE_LGT_ShipDateShouldBeGTPODate').isActive__c=false;
        insert switchList.values();
        
        ID recOptyStandard=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId=recAccTypeID;
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        insert acc;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
        insert opp;
        
        Order order=TestDataUtil.createOrder('9999');
        order.GE_Opportunity_Id__c='12EU34';
        order.RecordTypeId=recOptyStandard;
        order.AccountId=acc.ID;
        order.OpportunityId=opp.ID;
        insert order;
       
        Test.stopTest();
        
        Optyupdation batch=new Optyupdation();
        Database.executeBatch(batch);
    }
}
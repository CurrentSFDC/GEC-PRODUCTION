@isTest(seeAllData=true)
public class GE_LGT_Fund_Request_AccountInfo_Test{    
    static testMethod void getFundRequest()
    {     
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc1 = TestDataUtil.createAccount();
        acc1.RecordTypeId = recAccTypeId;
        insert acc1;
        
        ID recFRequestTypeID = Schema.SObjectType.Fund_Request__c.getRecordTypeInfosByName().get('Marketing Fund').getRecordTypeId();
        
        Fund_Request__c fr_obj = TestDataUtil.createFundRequest(acc1);
        fr_obj.RecordTypeId = recFRequestTypeID ;
        fr_obj.Fund_Type__c='Marketing Funds';
        
        insert fr_obj;        
    }
}
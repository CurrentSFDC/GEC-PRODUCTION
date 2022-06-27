@isTest(SeeAllData=true)
public class FundRequestApprovalRequest_Test {
    static testMethod void testFRApproval(){
        
        
        ID recordAccTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId = recordAccTypeId;
        
        insert acc;
        
        ID recTypeIdD_FR = Schema.SObjectType.Fund_Request__c.getRecordTypeInfosByName().get('Marketing Fund').getRecordTypeId();
        Fund_Request__c FR_Obj = TestDataUtil.createFundRequest(acc);        
        FR_Obj.RecordTypeId = recTypeIdD_FR;
        
        insert FR_Obj;
        //Add attachment
        Blob b = Blob.valueOf('Test Data1234');   
        Attachment attachment = TestDataUtil.createAttachment('Test Attachment for Fund Request',b,FR_Obj.id);   
        insert(attachment);  
        
        Test.startTest();
        FundRequestApprovalRequest.SendApprovalRequest(FR_Obj.id);  
       
        
        Test.stopTest();
        
    }
    
    
}
@isTest(seeAllData=true)
Public class GE_LGT_FundRequestAttachment_Test{
    
    private static testMethod void addAttachmentToParent() {  
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc1 = TestDataUtil.createAccount();
        insert acc1;
        
        
        ID recFRequestTypeID = Schema.SObjectType.Fund_Request__c.getRecordTypeInfosByName().get('Marketing Fund').getRecordTypeId();
        
        Fund_Request__c fr_obj = TestDataUtil.createFundRequest(acc1);
        fr_obj.RecordTypeId = recFRequestTypeID;
        fr_obj.Approval_Status__c='Not Submitted';       
        fr_obj.Fund_Type__c='Marketing Funds';
            insert fr_obj;   
        
        Blob b = Blob.valueOf('Test Data');   
        
        Attachment attachment = TestDataUtil.createAttachment('Test Attachment for Parent',b,fr_obj.id);   
         
        
        insert(attachment);   
    }  
}
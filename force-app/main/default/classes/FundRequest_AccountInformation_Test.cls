@isTest
(seeAllData=false)
public class FundRequest_AccountInformation_Test {
	static testmethod void method1()
    {
       // GE_LGT_FundRequest_AccountInformation geLGT = new GE_LGT_FundRequest_AccountInformation();
        
        Id marketingFundRectype=[SELECT Id FROM RecordType WHERE DeveloperName ='US_Marketing_Funds'].Id;
       // Id userId = [select id from User where Email = 'derek.publicover@gecurrent.com'].Id;
         Profile pf= [Select Id from profile where Name='System Administrator']; 
       
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'derek.publicover@gecurrent.com', 
                         Username = 'publicover@hg.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'div',
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        );      
        
        insert uu;
        
        Account acc = new Account();
        acc.Name='Divya Pulluri';
        acc.AccountNumber = '001';
        insert acc;
        List<Fund_Request__c> fundRequestList = new List<Fund_Request__c>();
        Fund_Request__c fund = new Fund_Request__c();
   		fund.Bill_to_Name__c = acc.Id;
        fund.RecordTypeId = marketingFundRectype;
        fund.Remaining_Balance__c = 500;         
        fund.Approval_Status__c ='Approved';
        fund.Attached_Credit_Invoice__c=true;
        fund.Payment_Amount__c = 2200;
        fund.Region__c = 'WEST';
        fund.Pay_To__c = 'DIV';
        fund.Fund_Type__c = 'Marketing Funds';
        fund.Type_of_Reimbursement__c = 'Credit to Customers Account';
        fund.Event_Date__c = date.today();
        fund.Event_or_Promotion_Type__c= 'Customer Fees';
        fund.Specific_Event_Details__c = 'Promotion events';
        fund.Event_Goals__c = 'Sales';
        fund.Additional_Goal_information__c='description';
        
        
        //fund.Attached_Credit_Invoice__c = false;
        fundRequestList.add(fund);
        insert fundRequestList;
        GE_LGT_FundRequest_AccountInformation.fundRequestApprovalProcessErrrors(fundRequestList);
    }
}
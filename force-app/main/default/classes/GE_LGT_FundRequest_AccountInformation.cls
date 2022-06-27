public class GE_LGT_FundRequest_AccountInformation{
    /*  RQT-0005697
     * 
     * 
     "Remaining Balance" and "Attached Credit Invoice" fields are mandatory upon Jill Stugmyer final approval 
	  in either Step #3 if requested amount is > or equal to $2,500 or in Step #1 if it's <$2,500. 
	*/
    public static void fundRequestApprovalProcessErrrors(List<Fund_Request__c> fundRequestList){
        
        Id marketingFundRectype=[SELECT Id FROM RecordType WHERE DeveloperName ='US_Marketing_Funds'].Id;
        system.debug('marketingFundRectype'+marketingFundRectype);
        if(marketingFundRectype!=null){
            for(Fund_Request__c fundReq: fundRequestList){
                if(fundReq.Current_Approval_Step__c==3 || fundReq.Approval_Status__c =='Approved' ){ 
                    system.debug('fundReq.recordTypeId'+fundReq.recordTypeId);
                    if(fundReq.recordTypeId == marketingFundRectype){
                        if(fundReq.Attached_Credit_Invoice__c==false || fundReq.Remaining_Balance__c ==null){
                            fundReq.addError('  "Remaining Balance" and "Attached Credit Invoice" fields are mandatory');
                        }               
                    }            
                }
            }
        }        
        
    }

   // Commenting out and deactivating the trigger on 20 Oct 20
   /* public static void getAccountInfo(){
    for (Fund_Request__c fund_request : (List<Fund_Request__c>)Trigger.new){    
    
     if(fund_request.Bill_to_Name__c!=null){
     system.debug('Bill to Name ::: '+fund_request.Bill_to_Name__c);
      
     List<Account> acct_list = [select id, BillingCity, BillingState, BillingPostalCode from Account where Id = :fund_request.Bill_to_Name__c];
     system.debug('acct_list.size :: '+acct_list.size());
     if(acct_list.size()>0){
         for(integer i=0;i<acct_list.size();i++){
         system.debug('Billing City ::'+acct_list[i].BillingCity);
         fund_request.City__c = acct_list[i].BillingCity;
         fund_request.State_Province__c = acct_list[i].BillingState;
         fund_request.Postal_Code__c = acct_list[i].BillingPostalCode;
          }
     }
     }
  }

}
    */
    
    

}
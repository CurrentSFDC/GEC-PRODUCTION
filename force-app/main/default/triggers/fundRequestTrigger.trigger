/*Trigger Name - fundRequestTrigger 
Author - Neel (TechMahindra)
Project Module - Fund Request

*/

trigger fundRequestTrigger on Fund_Request__c (before insert,before update) {         
    GE_LGT_FundRequest_AccountInformation.fundRequestApprovalProcessErrrors(trigger.new);
    
}
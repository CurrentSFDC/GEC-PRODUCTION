/*Trigger Name - GE_LGT_Fund_Request_AccountInfo 
Author - Neel (TechMahindra)
Project Module - Fund Request
Purpose - This will pull information from fund request record's BillToName(account) and populate following info on fund request record
Billng City
Billing Province
Billing Zip Code
*/

trigger GE_LGT_Fund_Request_AccountInfo on Fund_Request__c (before insert) {
    
//Rashmitha Changed the API vesion from 32 to 45 on 5-Mar-2019 as per 1447 request    
    
    GE_LGT_FundRequest_AccountInformation.getAccountInfo();
}
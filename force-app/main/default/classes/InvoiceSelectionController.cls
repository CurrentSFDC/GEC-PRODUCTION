/*********************************************************************
Purpose: Controller for invoiceSelection community component. Searches for Invoice records based on search string,
            and populates myInvoiceTable.

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Nate Kanyok  16-Dec-2020  Created
*/
public class InvoiceSelectionController {
    @AuraEnabled
    public static List<sObject> searchForInvoice(String searchText, String startDateStr, String endDateStr) {

        Date startDate = Date.valueOf(startDateStr);
        Date endDate = Date.valueOf(endDateStr);

        startDate = startDate.addDays(1);
        endDate = endDate.addDays(1);

        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, ContactId, Account.GE_LGT_Rep_Code__c, Account.Id FROM User WHERE Id = : userId];
        Id getContactId = u.contactId;

        List<Id> relatedAccountIds = new List<Id>();
        for(AccountContactRelation relation : [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :getContactId]){
            relatedAccountIds.add(relation.AccountId);
        }

        String searchString = '%'+searchText+'%';
        List<sObject> results = new List<sObject>();


        if(u.Account.GE_LGT_Rep_Code__c == '' || u.Account.GE_LGT_Rep_Code__c == null){
            //user is distributor
            //         AND GE_LGT_EM_Sold_to_Account_Number__c = :u.Account.Id
            results = [SELECT  Name,
                                Id, 
                                GE_LGT_EM_Sold_to_Account_Number__c, 
                                GE_LGT_EM_SAPInvoiceNumber__c, 
                                GE_LGT_EM_Billing_Date__c, 
                                CurrencyIsoCode, 
                                GE_LGT_EM_CustomerName__c, 
                                GE_LGT_EM_Invoice_Creation_Date__c, 
                                GE_LGT_EM_Net_value__c, 
                                GE_LGT_EM_Tax_Number_1__c, 
                                Invoice_Currency__c 
                        FROM GE_LGT_EM_InvoiceHeader__c
                        WHERE (GE_LGT_EM_Invoice_Creation_Date__c >= :startDate
                            AND GE_LGT_EM_Invoice_Creation_Date__c <=: endDate
                            AND GE_LGT_EM_SAPInvoiceNumber__c LIKE :searchString)];
        }
        else{
            //user is agent
            // AND Agent_rep_code__c = :u.Account.GE_LGT_Rep_Code__c
            results = [SELECT  Name,
                                Id, 
                                GE_LGT_EM_Sold_to_Account_Number__c, 
                                GE_LGT_EM_SAPInvoiceNumber__c, 
                                GE_LGT_EM_Billing_Date__c, 
                                CurrencyIsoCode, 
                                GE_LGT_EM_CustomerName__c, 
                                GE_LGT_EM_Invoice_Creation_Date__c, 
                                GE_LGT_EM_Net_value__c, 
                                GE_LGT_EM_Tax_Number_1__c, 
                                Invoice_Currency__c 
                        FROM GE_LGT_EM_InvoiceHeader__c
                        WHERE (GE_LGT_EM_Invoice_Creation_Date__c >= :startDate
                            AND GE_LGT_EM_Invoice_Creation_Date__c <=: endDate
                            AND GE_LGT_EM_SAPInvoiceNumber__c LIKE :searchString)];
        }
        return results;
    }

    @AuraEnabled
    public static List<sObject> initInvoices(String startDateStr, String endDateStr){
        // return a list of invoices

        Date startDate = Date.valueOf(startDateStr);
        Date endDate = Date.valueOf(endDateStr);

        startDate = startDate.addDays(1);
        endDate = endDate.addDays(1);

        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, ContactId, Account.GE_LGT_Rep_Code__c, Account.Id FROM User WHERE Id = : userId];
        Id getContactId = u.contactId;

        List<Id> relatedAccountIds = new List<Id>();
        for(AccountContactRelation relation : [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :getContactId]){
            relatedAccountIds.add(relation.AccountId);
        }

        List<sObject> results = new List<sObject>();

        if(u.Account.GE_LGT_Rep_Code__c == '' || u.Account.GE_LGT_Rep_Code__c == null){
            //user is distributor
            //                             AND GE_LGT_EM_Sold_to_Account_Number__c = :u.Account.Id
            results = [SELECT  Name,
                                Id, 
                                GE_LGT_EM_Sold_to_Account_Number__c, 
                                GE_LGT_EM_SAPInvoiceNumber__c, 
                                GE_LGT_EM_Billing_Date__c, 
                                CurrencyIsoCode, 
                                GE_LGT_EM_CustomerName__c, 
                                GE_LGT_EM_Invoice_Creation_Date__c, 
                                GE_LGT_EM_Net_value__c, 
                                GE_LGT_EM_Tax_Number_1__c, 
                                Invoice_Currency__c 
                        FROM GE_LGT_EM_InvoiceHeader__c
                        WHERE (GE_LGT_EM_Invoice_Creation_Date__c >= :startDate
                            AND GE_LGT_EM_Invoice_Creation_Date__c <=: endDate)];
        }
        else{
            //user is agent
            // AND Agent_rep_code__c = :u.Account.GE_LGT_Rep_Code__c
            results = [SELECT  Name,
                                Id, 
                                GE_LGT_EM_Sold_to_Account_Number__c, 
                                GE_LGT_EM_SAPInvoiceNumber__c, 
                                GE_LGT_EM_Billing_Date__c, 
                                CurrencyIsoCode, 
                                GE_LGT_EM_CustomerName__c, 
                                GE_LGT_EM_Invoice_Creation_Date__c, 
                                GE_LGT_EM_Net_value__c, 
                                GE_LGT_EM_Tax_Number_1__c, 
                                Invoice_Currency__c 
                        FROM GE_LGT_EM_InvoiceHeader__c
                        WHERE (GE_LGT_EM_Invoice_Creation_Date__c >= :startDate
                            AND GE_LGT_EM_Invoice_Creation_Date__c <=: endDate)];
        }
        return results;

        // List<sObject> results = new List<sObject>();

        // results = InvoiceServices.getInvoiceHeader();

        // return results;
    }

    
}
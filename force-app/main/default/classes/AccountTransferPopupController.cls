public with sharing class AccountTransferPopupController 
{
    public String query {get; set;}
    public List<Account> accounts {get; set;}
    
    public PageReference runQuery()
    {
        //returns a list of Accounts that match the query string you searched for. Also filters on SAP Account, SAP Account - Strategic, and SAP Account - Agent
        List<List<Account>> searchResults=[FIND :query IN ALL FIELDS RETURNING Account (id,GE_LGT_EM_SAP_Customer_Number__c, name, billingstreet, billingcity, billingpostalcode WHERE RecordType.Name = 'SAP Account' or RecordType.Name = 'SAP Account - Strategic' or RecordType.Name = 'SAP Account - Agent')];
        accounts=searchResults[0];
        return null;
    }
}
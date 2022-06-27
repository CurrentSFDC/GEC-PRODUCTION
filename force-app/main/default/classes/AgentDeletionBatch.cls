/*
Name - AgentDeletionBatch
Test Class - AgentDeletionBatch_Test
Author - Shyam Prasad Nayakula
Purpose - Batch to delete Agents-KAFZY-1733 
Date - Sep-2016
*/
global class AgentDeletionBatch implements Database.Batchable<SObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //SAP Account - Fixture Agent - 012630000008bFT
        ID recTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
       
        return Database.getQueryLocator([SELECT ID FROM Account WHERE RecordTypeID=:recTypeID AND
                                         ((GE_LGT_EM_Sales_Org__c!='1CA1' AND GE_LGT_EM_Sales_Org__c!='1US1') OR
                                          (GE_LGT_Rep_Code__c LIKE '%0001'))]);    
    }
    global void execute(Database.BatchableContext bc,List<Account> Scope)
    {
        List<Account> delListAccount = new List<Account>();
        for(Account acct : [SELECT id,(SELECT ID FROM CONTACTS),(SELECT ID FROM CASES),(select id from Orders), 
                            (select id from AgentOrders__r),(SELECT ID FROM Opportunities) 
                            FROM Account WHERE ID IN:Scope])
        {
            if(acct.contacts!=NULL && acct.contacts.isEmpty() && acct.cases!=NULL && acct.cases.isEmpty() && 
               acct.orders!=NULL && acct.orders.isEmpty() && acct.agentorders__r!=NULL && acct.agentorders__r.isEmpty() && 
               acct.Opportunities!=NULL && acct.Opportunities.isEmpty())
            {
                delListAccount.add(acct);
            }
        }
        if(!delListAccount.isEmpty())
        {
            Database.delete(delListAccount,false);
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}
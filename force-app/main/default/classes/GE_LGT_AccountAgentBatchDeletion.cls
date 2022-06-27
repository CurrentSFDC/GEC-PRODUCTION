/*
Name - GE_LGT_AccountAgentBatchDeletion
Purpose - Delete agents(accounts) which are inactive and DO NOT have related records
Date - July-2016
Author - Neel(TechMahindra)
Test Class - TO DO

*/
global class GE_LGT_AccountAgentBatchDeletion implements Database.Batchable<sObject> 
{
    
    global string query;
    global GE_LGT_AccountAgentBatchDeletion()
    {
        List<RecordType> recordTypeIDs = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Account' AND DeveloperName='SAP_Account_Fixture_Agent'];
        if(recordTypeIDs!=NULL && !recordTypeIDs.isEmpty())
        {
            query = 'SELECT id,Name,GE_LGT_EM_CustomerActiveFlag__c,Opportunity_Count__c\n'+
                'FROM Account \n'+ 
                'WHERE RecordTypeid=\''+ recordTypeIDs[0].ID +'\' \n'+ 
                'AND GE_LGT_EM_CustomerActiveFlag__c=false \n'+ 
                'AND Opportunity_Count__c=0'; 
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug('SOQL Isued in start method :: '+query); 
        if(query!=NULL)
            return Database.getQueryLocator(query);
        else
            return NULL;
    }    
    
    global void execute(Database.BatchableContext bc,List<Account> scope)
    {
        List<Account> delListAccount = new List<Account>();
        System.debug('Scope:'+scope);
        for(Account acct : [SELECT id,(SELECT ID FROM CONTACTS),(SELECT ID FROM CASES),(select id from Orders), 
                            (select id from AgentOrders__r)  
                            FROM Account WHERE ID IN:Scope])
        {
            if(acct.contacts!=NULL && acct.contacts.isEmpty() && acct.cases!=NULL && acct.cases.isEmpty() && 
               acct.orders!=NULL && acct.orders.isEmpty() && acct.agentorders__r!=NULL && acct.agentorders__r.isEmpty() 
               )
            {
                delListAccount.add(acct); 
            }
        }
        system.debug('Records to be deleted ::'+delListAccount);
        if(!delListAccount.isEmpty())
        {
            Database.delete(delListAccount,false);
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        
        
    }
    
}
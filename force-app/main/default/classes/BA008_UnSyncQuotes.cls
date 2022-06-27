/*
Name - BA008_UnSyncQuotes
Test Class - BA008_UnSyncQuotes_Test
Author - Shyam Prasad Nayakula
Purpose - To UnSync the Quotes from Opportunities
Created Date - Oct-2017
*/
global class BA008_UnSyncQuotes implements Database.Batchable<sobject>
{
    global Database.Querylocator start (Database.BatchableContext BC) 
    {
       //
       //  return Database.getQueryLocator('Select ID FROM Opportunity WHERE UnSync_From_Quote__c = TRUE');
       // return Database.getQueryLocator('Select ID FROM Opportunity WHERE UnSync_From_Quote__c = TRUE AND id=\'0061g000002b44E\'' );
        return Database.getQueryLocator('Select ID FROM Opportunity WHERE UnSync_From_Quote__c = TRUE ' );
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) 
    {
        List<Opportunity> opptyListToUpdate = new List<Opportunity>();
        for(Opportunity var:oppList)
        {
            Opportunity oppVar = new Opportunity();
            oppVar.ID = var.ID;
            oppVar.SyncedQuoteId = NULL;
            oppVar.UnSync_From_Quote__c = FALSE;
            
            opptyListToUpdate.add(oppVar);
        }
        if(!opptyListToUpdate.isEmpty())
        {
            StaticVariables.unSyncQuoteFlag = FALSE;
            Database.update(opptyListToUpdate,FALSE);
        }
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}
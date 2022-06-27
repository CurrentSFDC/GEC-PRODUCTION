/*
Name - GE_LGT_Batch_StQuote_Deletion
Test Class - GE_LGT_Batch_StQuote_Deletion_Test
Author - Sai Tandra
Purpose - To delete Standard Quotes with Expiration Date lessthan today and not Sync
Date - March -2017
*/
global class GE_LGT_Batch_StQuote_Deletion implements Database.Batchable<sObject>
{
     Date dt = date.today();
    global Database.QueryLocator start(Database.BatchableContext bc)
    {  
        return Database.getQueryLocator([SELECT Id,Name,ExpirationDate,IsSyncing FROM Quote where ExpirationDate<:dt AND IsSyncing=false ]);
    }
    global void execute(Database.BatchableContext bc,List<Quote> qrecords)
    {
        delete qrecords;
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }   
        
}
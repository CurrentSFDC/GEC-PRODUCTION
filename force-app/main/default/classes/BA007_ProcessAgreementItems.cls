/*
Name - BA007_ProcessAgreementItems
Test Class - BA007_ProcessAgreementItems_Test
Author - Shyam Prasad Nayakula
Purpose - To Process the SAP Agreement Items
Created Date - Sep-2017
*/
global class BA007_ProcessAgreementItems implements Database.Batchable<sobject>
{    
    global String [] email = new String[] {'sateesh.chava@ge.com'};
    global Database.Querylocator start (Database.BatchableContext BC) 
    {
        return Database.getQueryLocator('Select id, Name, Processing_Status__c, Agreement_No__c,Condition_No__c,Price_Agreement__r.Expiration_Date__c FROM SAP_Price_Agreement_Item__c where Price_Agreement__r.Expiration_Date__c >TODAY order by Processing_Status__c');
    }
    global void execute (Database.BatchableContext BC, List<SAP_Price_Agreement_Item__c> itemList ) 
    {
        StaticVariables.runningQuoteItemBatch = true;
        List<SAP_Price_Agreement_Item__c> itemDelList = new List<SAP_Price_Agreement_Item__c>();
        List<SAP_Price_Agreement_Item__c> itemUpdList = new List<SAP_Price_Agreement_Item__c>();
        Set<String> conditionNumSet = new Set<String>();
        for (SAP_Price_Agreement_Item__c item : itemList ) 
        {
            if(item.Processing_Status__c == 'Processed')
            {
                itemDelList.add(item);
                conditionNumSet.add(item.Condition_No__c);
            }
        }
        List<QuoteLineItem> itemsToDelete = [SELECT ID FROM QuoteLineItem WHERE Condition_No__c IN:conditionNumSet];
        List<SObject> recordsToBeDeleted = new List<SObject>();
        recordsToBeDeleted.addAll((List<sObject>)itemDelList);
        recordsToBeDeleted.addAll((List<sObject>)itemsToDelete);
        if(recordsToBeDeleted != null && recordsToBeDeleted.size() > 0)
        {
            Database.delete(recordsToBeDeleted);
        }
        for(SAP_Price_Agreement_Item__c item : itemList) 
        {
            if(item.Processing_Status__c == 'Pending')
            {
                item.Processing_Status__c = 'Processed';
                itemUpdList.add(item);
            }
        }
        if(itemUpdList != null && itemUpdList.size() > 0)
        {
            Database.update(itemUpdList);
        }
    }
    global void finish(Database.BatchableContext BC)
    {
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        System.debug('$$$ Jobid is'+BC.getJobId());
        mail.setToAddresses(email);
        mail.setReplyTo('sateesh.chava@ge.com');
        mail.setSenderDisplayName('Price Agreement Item Batch');
        mail.setSubject('Price Agreement Line Item Processing: '+ a.Status);
        mail.setPlainTextBody('Price Agreement Line Item processing has been completed for today. The results are summarized below:' + '<br>' + 'Batches: ' + a.TotalJobItems + '<br>' + 'Errors: ' + a.NumberOfErrors + '<br>' + 'Items Processed: ' + a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
       
       BA009_SyncQuoteToOppty syncQuoteToOppty = new BA009_SyncQuoteToOppty();
       Database.executeBatch(syncQuoteToOppty); 
    }
}
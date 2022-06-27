/*
Name - BA009_SyncQuoteToOppty 
Test Class - BA009_SyncQuoteToOppty_Test
Author - Neel
Created Date - Jan-2018
Purpose: 
    1. Sync the Quotes for which GE Quote Number has been received as part of SAP Feed
    2. If there is any issue, error will be logged into GE_LGT_EM_ErrorLog__c object
    3. If for an oppty there are multiple quotes, then uncheck flag 'Last_Quote_Synced__c' for quotes which are not syncing
*/

global class BA009_SyncQuoteToOppty implements Database.Batchable<sObject>
{
    global String [] email = new String[] {'salesforcedevops@ge.com'};
    
    global Database.Querylocator start (Database.BatchableContext BC) {
    
      // String[] AgrNoList = new String[] {'0080110176','0080110177','0080110178','0080111111'};    
            
      // return Database.getQueryLocator('Select id, Name,OpportunityID  FROM Quote WHERE AutoSyncQuoteFromPAHeader__c = TRUE AND Agreement_No__c IN :AgrNoList ORDER BY LastModifiedDate DESC');
         return Database.getQueryLocator('Select id, Name,OpportunityID  FROM Quote WHERE AutoSyncQuoteFromPAHeader__c = TRUE ORDER BY LastModifiedDate DESC');
     
    }

    global void execute (Database.BatchableContext BC, List<Quote> quoteList ) {
        system.debug('BA009_SyncQuoteToOppty execute method begins::::');
        //find the QuoteIds and store in a set
        Set<Id> quoteIdSet = new Set<Id>();
        Map<Id,Id> opptyQuoteIdMap = new Map<Id,Id>();
        
        for(Quote headerListVar : quoteList){
            if(!opptyQuoteIdMap.containsKey(headerListVar.OpportunityID)){
            opptyQuoteIdMap.put(headerListVar.OpportunityID,headerListVar.ID);
            quoteIdSet.add(headerListVar.ID);
            }
        }
        
        system.debug('quoteIdSet after processing :: '+quoteIdSet);
        Set<Id> opptyIdSet = new Set<Id>(); //For storing Oppty id, so that for Unsynced quotes (IsSyncing=False), Last_Quote_Synced__c is made FALSE if Most_Recent_Synced_Date_Time__c is not null
        List<Opportunity> opptyListToUpdate = new List<Opportunity>();
        for(Quote quoteVar: [SELECT ID,OpportunityID FROM Quote WHERE ID IN : quoteIdSet]) {
            Opportunity oppVar = new Opportunity();
            oppVar.ID = quoteVar.OpportunityID;
            oppVar.SyncedQuoteId = quoteVar.ID;
            oppVar.UnSync_From_Quote__c = TRUE;
            opptyListToUpdate.add(oppVar);
            opptyIdSet.add(quoteVar.OpportunityID);
        }
        //Update the Oppty, if that fails then log the error to custom object GE_LGT_EM_ErrorLog__c
        
        if(!opptyListToUpdate.isEmpty()) {
            List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
            Database.SaveResult[] srList = Database.update(opptyListToUpdate,FALSE);
            for( Database.SaveResult srVar : srList ) {
                if( !srVar.isSuccess()) {
                    for( Database.Error err : srVar.getErrors()) {
                        GE_LGT_EM_ErrorLog__c errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'Opportunity','Opportunity-Quote Sync Error -BA009_SyncQuoteToOppty Class',err.getFields());
                        errorLogList.add(errLogVar);
                    }
                }
            }
            if(!errorLogList.isEmpty()) {
                Database.insert(errorLogList,false);
            }
        }
        //After quote has been synced - update flag 'AutoSyncQuoteFromPAHeader__c' to false
        List<Quote> qtFlagUpdateList = new List<Quote>();
        List<Quote> qtFlagUpdateTempList = [SELECT id, Name, AutoSyncQuoteFromPAHeader__c FROM Quote WHERE Id in :quoteIdSet];
            for ( Quote qtFlagVar : qtFlagUpdateTempList ) {
                qtFlagVar.AutoSyncQuoteFromPAHeader__c =FALSE;
                qtFlagUpdateList.add(qtFlagVar);
            }
          
          if( !qtFlagUpdateList.isEmpty()) {
          List<GE_LGT_EM_ErrorLog__c> errorLogList3=new List<GE_LGT_EM_ErrorLog__c>();
            Database.SaveResult[] srQtFlagList = Database.update(qtFlagUpdateList,false);
            for( Database.SaveResult srQtVar3 : srQtFlagList ) {
                if( !srQtVar3.isSuccess()) {
                    for( Database.Error errQtVar3 : srQtVar3.getErrors()) {
                        GE_LGT_EM_ErrorLog__c errLogQtVar3 = HandleErrorLogs.createErrorLog(errQtVar3.getMessage(),srQtVar3.getId(),'Quote','Quote AutoSyncQuoteFromPAHeader__c  flag Uncheck not success - BA009_SyncQuoteToOppty class',errQtVar3.getFields());
                        errorLogList3.add(errLogQtVar3);
                     }
                 }
              }
                if(!errorLogList3.isEmpty()) {
                    Database.insert(errorLogList3,false);
                }
            }
        
       //  Uncheck ( the quotes which are not syncing  but Last_Quote_Synced__c is still TRUE if
       //  Most_Recent_Synced_Date_Time__c is not null
        List<Quote> qtUnSyncUpdateList = new List<Quote>();
        List<Quote> qtUnSyncList = [ SELECT id, Name, Last_Quote_Synced__c FROM Quote WHERE Last_Quote_Synced__c=true and OpportunityId in :opptyIdSet];
            for(Quote qtUnSyncVar :qtUnSyncList ){
                qtUnSyncVar.Last_Quote_Synced__c=false;
                qtUnSyncUpdateList.add(qtUnSyncVar);
            }
          if(!qtUnSyncUpdateList.isEmpty()){
                
            List<GE_LGT_EM_ErrorLog__c> errorLogList2=new List<GE_LGT_EM_ErrorLog__c>();
            Database.SaveResult[] srQtList = Database.update(qtUnSyncUpdateList,false);
            for( Database.SaveResult srQtVar : srQtList ) {
                if( !srQtVar.isSuccess()) {
                    for( Database.Error errQtVar : srQtVar.getErrors()) {
                        GE_LGT_EM_ErrorLog__c errLogQtVar = HandleErrorLogs.createErrorLog(errQtVar.getMessage(),srQtVar.getId(),'Quote','Quote Last_Quote_Synced__c flag Uncheck not success - BA009_SyncQuoteToOppty class',errQtVar.getFields());
                        errorLogList2.add(errLogQtVar);
                    }
                }
            }
            if(!errorLogList2.isEmpty()) {
                Database.insert(errorLogList2,false);
            }
                
                
            }
  
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('BA009_SyncQuoteToOppty finish method begins::::');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        System.debug('$$$ Jobid is'+BC.getJobId());
        mail.setToAddresses(email);
        mail.setReplyTo('salesforcedevops@ge.com');
        mail.setSenderDisplayName('BA009_SyncQuoteToOppty');
        mail.setSubject('BA009_SyncQuoteToOppty : '+ a.Status);
        mail.setPlainTextBody('BA009_SyncQuoteToOppty processing has been completed for today. The results are summarized below:' + '<br>' + 'Batches: ' + a.TotalJobItems + '<br>' + 'Errors: ' + a.NumberOfErrors + '<br>' + 'Items Processed: ' + a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
        
        //Call the class which does the unsyncing of quote from Oppty
       BA008_UnSyncQuotes unsyncQuote = new BA008_UnSyncQuotes();
       Database.executeBatch(unsyncQuote);
    }
}
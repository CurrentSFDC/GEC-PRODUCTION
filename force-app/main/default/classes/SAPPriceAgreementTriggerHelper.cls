/*
Name - SAPPriceAgreementTriggerHelper
Test Class - SAPPriceAgreementTrigger_Test
Author - Shyam Prasad Nayakula
Purpose - Helper class for the Trigger SAPPriceAgreementTrigger
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Date (By User)   : Comments
Jul-2017 (Pavan) : Added logic to check invalid or non-existent GE Opportunity No
                                        currency is different from the currency specified by the GE Opportunity No
Feb-2018 (Neel) : Removed future calles for syncing. Now updating a flag on std Quote, and then 
                batch program syncs (and then unsyncs)
*/
global class SAPPriceAgreementTriggerHelper 
{
   /* Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method populates Opportunity and other neccessary fields based on the the information from SAP
    */
    public static Map<String,Super_Admin_Profiles__c> Profiles_Super =Super_Admin_Profiles__c.getAll();
    
    public static void updateFieldsOnCreate(List<SAP_Price_Agreement__c> newPAList)
    {
        Map<string,string> agreementMap = new Map<string, string>();
        Set<String> quoteSet = new Set<String>();
        // below block will be storing custom metadata records for Description mapping
        List<SAP_Customer_Code__mdt> codeList = new List<SAP_Customer_Code__mdt>(); 
        Map<string, string> codemap = new Map<string, string>();
        
        if ( codeList.size() == 0 ){
            codeList = [ SELECT MasterLabel, DeveloperName, Code__c, Is_Active__c FROM SAP_Customer_Code__mdt ];
        }

        for ( SAP_Customer_Code__mdt cd : codeList ){
            codeMap.put(cd.DeveloperName, cd.MasterLabel);
        }
        // end : custom metadata
        
        for(SAP_Price_Agreement__c aggVar:newPAList)
        {
            if (aggVar.Customer_List__c != null){
                List<String> tempCustomerList = aggVar.Customer_List__c.split(',');

                if(tempCustomerList.size() > 1){
                    aggVar.Customer_Name__c = 'MULTIPLE';
                }
            }

            if(aggVar.Opportunity_Name__c != null )
            {
                agreementMap.put(aggVar.Id, aggVar.Opportunity_Name__c);
            }
            if(aggVar.Quote_Name__c != null)
            {
                quoteSet.add(aggVar.Quote_Name__c);
            }
            //Below block will update Description fields for a given 'code' field
            
            string orgCode  = aggVar.Sales_Org__c != null ? 'SR' + '_' + aggVar.Sales_Org__c : null ;
            string divCode  = aggVar.Division__c != null ? 'DV' + '_' + aggVar.Division__c : null ;
            string chanCode = aggVar.Distribution_Channel__c != null ? 'DC' + '_' + aggVar.Distribution_Channel__c : null ;
            
            aggVar.Sales_Org_Description__c  = aggVar.Sales_Org_Description__c  != ( orgCode != null ? codeMap.get(orgCode) : null ) ? ( orgCode != null ? codeMap.get(orgCode) : null ) : aggVar.Sales_Org_Description__c  ;
            aggVar.Division_Description__c  = aggVar.Division_Description__c  != ( divCode != null ? codeMap.get(divCode) : null ) ? ( divCode != null ? codeMap.get(divCode) : null ) : aggVar.Division_Description__c  ;
            aggVar.Distribution_Channel_Description__c  = aggVar.Distribution_Channel_Description__c  != ( chanCode != null ? codeMap.get(chanCode) : null ) ? ( chanCode != null ? codeMap.get(chanCode) : null ) : aggVar.Distribution_Channel_Description__c  ;
         }
        
        if( !agreementMap.isEmpty() ) {
            Map<Id, Opportunity> opptyMap= new Map<Id, Opportunity>([SELECT Id, GE_LGT_GE_Opportunity_Id__c 
                                                                     FROM Opportunity 
                                                                     WHERE Id IN:agreementMap.values()]);
            for(SAP_Price_Agreement__c aggVar:newPAList)
            {
                if(opptyMap.containsKey(aggVar.Opportunity_Name__c))
                {
                    aggVar.GE_Opportunity_No__c = opptyMap.get(aggVar.Opportunity_Name__c).GE_LGT_GE_Opportunity_Id__c;
                system.debug('Ge Oppty Id :: '+opptyMap.get(aggVar.Opportunity_Name__c).GE_LGT_GE_Opportunity_Id__c);
                }
                
            }
        }
        if( !quoteSet.isEmpty() )  {
            Map<Id,Quote> quoteMap= new Map<Id,Quote>([SELECT Id, Name, GE_Quote_Number__c,OpportunityId,Opportunity.GE_LGT_GE_Opportunity_Id__c 
                                                       FROM Quote 
                                                       WHERE Id IN:quoteSet]);
            for(SAP_Price_Agreement__c aggVar:newPAList)
            {
              system.debug('For loop at line no 77');
                if(quoteMap.containsKey(aggVar.Quote_Name__c))
                {
                system.debug('If loop at line no 80,GE_Quote_No__c : '+quoteMap.get(aggVar.Quote_Name__c).GE_Quote_Number__c);
                    aggVar.GE_Quote_No__c = quoteMap.get(aggVar.Quote_Name__c).GE_Quote_Number__c;
                    aggVar.Opportunity_Name__c= quoteMap.get(aggVar.Quote_Name__c).OpportunityId;
                    aggVar.GE_Opportunity_No__c = quoteMap.get(aggVar.Quote_Name__c).Opportunity.GE_LGT_GE_Opportunity_Id__c;
                }
            }
        }
    }
  /*
    Author : Neel (TechMahindra)
    Date : April,2018
    Purpose : This method will clean Ge Opp Id field if user clears OpptyName 

  */
    Public static void clearGeOppId(List<SAP_Price_Agreement__c> newPAList, Map<ID,SAP_Price_Agreement__c> oldPAMap){
      system.debug('method called clearGeOppId()');
      //  String IntegrationUser = Profiles_Super.get('00e31000001XT6nAAG').Profile_Name__c;
       // if(!Profiles_Super.containsKey(UserInfo.getProfileId())) {
        for(SAP_Price_Agreement__c paVar :newPAList ){
            if(paVar.Opportunity_Name__c != oldPAMap.get(paVar.Id).Opportunity_Name__c && paVar.Opportunity_Name__c==null )
            paVar.GE_Opportunity_No__c  = null;
            system.debug('paVar.GE_Opportunity_No__c :: '+paVar.GE_Opportunity_No__c);
         }
      // }
    }
    
    
    
   /* Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method will be called on after insert which invokes a future method to create Standrad Quotes
    *           based on GE Opportunity ID or Update existing Quotes based on GE Quote ID
    */
    public static void createOrUpdateQuotes(List<SAP_Price_Agreement__c> newPAList)
    {
        //Creating a List to Store the Agreement Records IDs which are having GE_OPP_ID OR GE_Quote_Number
        List<SAP_Price_Agreement__c> PAListToProcess = new List<SAP_Price_Agreement__c>();
        //Iterating the list and adding the IDs to the created Set
        for( SAP_Price_Agreement__c aggVar:newPAList )  {
            if(aggVar.GE_Opportunity_No__c!=NULL || aggVar.GE_Quote_No__c!=NULL)
            {
                PAListToProcess.add(aggVar);
            }
        }
        //If PAListToProcess is not empty then sending those records to future method for processing
        if(!PAListToProcess.isEmpty())
            createORUpdateQuotesFromPricingAggrements(PAListToProcess);
    }
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method creates Quotes from Price Aggrements for which Opportunity is mapped and
    * updates existing Quotes based on GE Quote Number
    * This will be future method to reduce the transaction time and avoid locking issues
    */
    public static void createORUpdateQuotesFromPricingAggrements(List<SAP_Price_Agreement__c> retreivedPAList)
    {
        //Creating a Set to Store GE Opportunity IDs 
        Set<String> GEOppIDSet = new Set<String>();
        //Creating a Set to Store GE Quote Numbers 
        Set<String> GEQuoteNumSet = new Set<String>();
        //Map to Store Opportunities where GE Opportunity ID as Key
        Map<String,Opportunity> oppMap=new Map<String,Opportunity>();
        //Map to Store Quotes where GE Quote ID as Key
        Map<String,Quote> existingQuoteMap = new Map<String,Quote>();
        for(SAP_Price_Agreement__c aggVar:retreivedPAList)
        {
            if(aggVar.GE_Quote_No__c!=NULL) {
                GEQuoteNumSet.add(aggVar.GE_Quote_No__c);       //Need to check for the Placeholders based on the set and update the data
            }
            //if(aggVar.GE_Quote_No__c==NULL && aggVar.GE_Opportunity_No__c!=NULL)
            if(aggVar.GE_Opportunity_No__c!=NULL) {
                GEOppIDSet.add(aggVar.GE_Opportunity_No__c);
            }
        }
        if(!GEQuoteNumSet.isEmpty())
        {
            for(Quote quoteVar:[SELECT ID,Name,GE_Quote_Number__c,OpportunityID 
                                FROM Quote 
                                WHERE GE_Quote_Number__c!=NULL AND GE_Quote_Number__c IN:GEQuoteNumSet])
            {
                existingQuoteMap.put(quoteVar.GE_Quote_Number__c,quoteVar);
            }
            
        }
        if( !GEOppIDSet.isEmpty() )  {
            for(Opportunity oppVar:[SELECT ID,GE_LGT_GE_Opportunity_Id__c,PriceBook2Id FROM Opportunity  
                                    WHERE GE_LGT_GE_Opportunity_Id__c IN:GEOppIDSet AND GE_LGT_GE_Opportunity_Id__c!=NULL]) 
            {
                oppMap.put(oppVar.GE_LGT_GE_Opportunity_Id__c,oppVar);
            }
        }
        System.debug('oppMap::'+oppMap);
        List<Quote> quoteListToUpdate = new List<Quote>();
        List<Quote> quoteListToInsert = new List<Quote>();
        List<SAP_Price_Agreement__c> aggrementsToUpdate = new List<SAP_Price_Agreement__c>();
        Map<String,SAP_Price_Agreement__c> aggrementsToUpdateMap = new Map<String,SAP_Price_Agreement__c>();
        //Based on the above map, Opportunity will be mapped Quote
        for(SAP_Price_Agreement__c aggVar:retreivedPAList)
        {
            if(aggVar.GE_Quote_No__c!=NULL && !existingQuoteMap.isEmpty() && existingQuoteMap.containsKey(aggVar.GE_Quote_No__c))
            {
                //mapQuoteFields - This method maps the Quote fields based on Agreement fields
                Quote quoteVar = mapQuoteFields(aggVar);
                quoteVar.Name = 'Generated From SAP Agreement #'+ aggVar.Name;
                quoteVar.Agreement_No__c = aggVar.Name;
                quoteVar.ID = existingQuoteMap.get(aggVar.GE_Quote_No__c).ID;
                quoteVar.GE_Opportunity_No__c = aggVar.GE_Opportunity_No__c;
                quoteVar.GE_Quote_Number__c = aggVar.GE_Quote_No__c;
                quoteVar.AutoSyncQuoteFromPAHeader__c=true;
                
                quoteListToUpdate.add(quoteVar);
               
                SAP_Price_Agreement__c aggVarToUpdate = new SAP_Price_Agreement__c();
                aggVarToUpdate.ID = aggVar.ID;
                aggVarToUpdate.Opportunity_Name__c= existingQuoteMap.get(aggVar.GE_Quote_No__c).OpportunityID;
                aggVarToUpdate.Quote_Name__c = existingQuoteMap.get(aggVar.GE_Quote_No__c).ID;
                aggrementsToUpdate.add(aggVarToUpdate);
            }
            else if(aggVar.GE_Opportunity_No__c!=NULL && !oppMap.isEmpty() && oppMap.containsKey(aggVar.GE_Opportunity_No__c))
            {   
                Quote quoteVar =  mapQuoteFields(aggVar);
                quoteVar.Name = 'Generated From SAP Agreement #'+ aggVar.Name;
                quoteVar.Agreement_No__c = aggVar.Name;
                quoteVar.GE_Opportunity_No__c = aggVar.GE_Opportunity_No__c;
                quoteVar.GE_Quote_Number__c = aggVar.GE_Quote_No__c;
                quoteVar.OpportunityId = oppMap.get(aggVar.GE_Opportunity_No__c).ID;
                if(oppMap.get(aggVar.GE_Opportunity_No__c).PriceBook2Id!=NULL)
                    quoteVar.Pricebook2Id=oppMap.get(aggVar.GE_Opportunity_No__c).PriceBook2Id;
                
                quoteListToInsert.add(quoteVar);
                aggrementsToUpdateMap.put(aggVar.Name,aggVar);
            }
        }
        System.debug('quoteListToInsert::'+quoteListToInsert);
        System.debug('quoteListToUpdate::'+quoteListToUpdate);
        List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
        if(!quoteListToInsert.isEmpty())
        {
            Database.SaveResult[] srList;
            srList = Database.insert(quoteListToInsert,FALSE);
            for( Database.SaveResult srVar : srList)
            {
                if( !srVar.isSuccess())
                {
                    for( Database.Error err : srVar.getErrors())
                    {
                        GE_LGT_EM_ErrorLog__c errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'QUOTE','QUOTE INSERT Error',err.getFields());
                        errorLogList.add(errLogVar);
                    }
                }
            }
            for(Quote quoteVar:quoteListToInsert)
            {
                 if(aggrementsToUpdateMap.containsKey(quoteVar.Name))
                 {
                     SAP_Price_Agreement__c aggVarToUpdate = new SAP_Price_Agreement__c();
                     aggVarToUpdate.ID = aggrementsToUpdateMap.get(quoteVar.Name).ID;
                     aggVarToUpdate.Opportunity_Name__c= quoteVar.OpportunityID;
                     aggVarToUpdate.Quote_Name__c = quoteVar.ID;
                     aggrementsToUpdate.add(aggVarToUpdate);
                 }
            }
        }
        if(!quoteListToUpdate.isEmpty()) 
        {
            Database.SaveResult[] srList;
            srList = Database.update(quoteListToUpdate,FALSE);
            for( Database.SaveResult srVar : srList )
            {
                if( !srVar.isSuccess())
                {
                    for( Database.Error err : srVar.getErrors())
                    {
                        GE_LGT_EM_ErrorLog__c errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'QUOTE','QUOTE UPDATE Error -SAPPriceAgreementTriggerHelper class',err.getFields());
                        errorLogList.add(errLogVar);
                    }
                }
            }
        }
        if(!errorLogList.isEmpty())
        {
            Database.insert(errorLogList,false);
        }
         if(!aggrementsToUpdate.isEmpty())
            Database.update(aggrementsToUpdate,FALSE);
    }
    
    
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method updates existing Quotes based on Last_Modified_DateTime__c field - which comes from SAP 
    */
    public static void updateExistingQuotes(List<SAP_Price_Agreement__c> newPAList,Map<ID,SAP_Price_Agreement__c> oldPAMap)
    {
        List<SAP_Price_Agreement__c> PAListToSyncOnUpdate = new List<SAP_Price_Agreement__c>();
        List<SAP_Price_Agreement__c> PAListToProcess = new List<SAP_Price_Agreement__c>();
        
        for( SAP_Price_Agreement__c var:newPAList )  {
           
            if(var.Last_Modified_DateTime__c != NULL && var.Last_Modified_DateTime__c != oldPAMap.get(var.ID).Last_Modified_DateTime__c)  {
                PAListToProcess.add(var);
                //If QT number changes then syncing method should be called createORUpdateQuotesFromPricingAggrements()
                if ( var.GE_Quote_No__c != NULL && var.GE_Quote_No__c != oldPAMap.get(var.ID).GE_Quote_No__c )  {
                PAListToSyncOnUpdate.add(var);
                }
            }
        }
        if( !PAListToProcess.isEmpty() ) {
            updateQuotesFromPricingAggrements(PAListToProcess);
        }
        if( !PAListToSyncOnUpdate.isEmpty() ) {
            createORUpdateQuotesFromPricingAggrements(PAListToSyncOnUpdate);
        }
    }
    
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method creates Quotes from Price Aggrements for which Opportunity is mapped and
    * updates existing Quotes based on GE Quote Number
    * This will be future method to reduce the transaction time and avoid locking issues
    */
    public static void updateQuotesFromPricingAggrements(List<SAP_Price_Agreement__c> retreivedPAList)
    {
        //Creating a Set to Store Aggrement Numbers
        Set<String> aggrementNumSet = new Set<String>();
        for(SAP_Price_Agreement__c aggVar:retreivedPAList)
        {
            aggrementNumSet.add(aggVar.Name);
        }
        if(!aggrementNumSet.isEmpty())
        {
            List<Quote> existingQuoteList = [SELECT ID,Name,Agreement_No__c FROM Quote WHERE Agreement_No__c IN:aggrementNumSet];
            System.debug('existingQuoteList::'+existingQuoteList);
            List<SAP_Price_Agreement__c> agreementsWithOutQuotes = new List<SAP_Price_Agreement__c>();
            //Map to Store Quotes where GE Quote ID as Key
            Map<String,Quote> existingQuoteMap = new Map<String,Quote>();
            for(Quote var:existingQuoteList)
            {
                existingQuoteMap.put(var.Agreement_No__c,var);
            }
            List<Quote> quoteListToUpdate = new List<Quote>();
            //Based on the above map, Opportunity will be mapped Quote
            for(SAP_Price_Agreement__c aggVar:retreivedPAList)
            {
                if(existingQuoteMap.containsKey(aggVar.Name) && existingQuoteMap.get(aggVar.Name)!=NULL)
                {
                    Quote quoteVar = mapQuoteFields(aggVar);
                    quoteVar.ID = existingQuoteMap.get(aggVar.Name).ID;
                    quoteListToUpdate.add(quoteVar);
                }
                else if(!existingQuoteMap.containsKey(aggVar.Name) && (aggVar.GE_Quote_No__c!=NULL || aggVar.GE_Opportunity_No__c!=NULL))
                {
                    agreementsWithOutQuotes.add(aggVar);
                }
            }
            System.debug('quoteListToUpdate::'+quoteListToUpdate);
            System.debug('agreementsWithOutQuotes::'+agreementsWithOutQuotes);
            List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
            if(!quoteListToUpdate.isEmpty())
            {
                Database.SaveResult[] srList;
                srList = Database.update(quoteListToUpdate,FALSE);
                for( Database.SaveResult srVar : srList )
                {
                    if( !srVar.isSuccess())
                    {
                        for( Database.Error err : srVar.getErrors())
                        {
                            GE_LGT_EM_ErrorLog__c errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'QUOTE','QUOTE UPDATE Error 2 -SAPPriceAgreementTriggerHelper class',err.getFields());
                            errorLogList.add(errLogVar);
                        }
                    }
                }
                if(!errorLogList.isEmpty())
                {
                    Database.insert(errorLogList,false);
                }
            }
                
            if(!agreementsWithOutQuotes.isEmpty())
                createORUpdateQuotesFromPricingAggrements(agreementsWithOutQuotes);
        }
    }
    
    public static Quote mapQuoteFields(SAP_Price_Agreement__c agreement)
    {
        Quote quoteVar = new Quote();
        quoteVar.ExpirationDate = agreement.Expiration_Date__c;
        quoteVar.Partner_Customer_No__c = agreement.Partner_Customer_No__c;
        quoteVar.Bill_To_Customer_No__c = agreement.Bill_To_Customer_No__c;
        quoteVar.Description__c = agreement.Description__c;
        quoteVar.Ext_Description__c = agreement.Extended_Description__c;
        quoteVar.Rep_Number_Agent__c = agreement.Agent_Number__c;
        quoteVar.Strategic_Account__c = agreement.Strategic_Account__c;
        quoteVar.Strategic_Partner_Name1__c = agreement.Strategic_Partner_Name__c;
        quoteVar.End_User_Customer_No__c = agreement.End_User_Customer_No__c;
        //Added strategic account lookup (April-2018)
        quoteVar.Strategic_Partner_Name__c   = agreement.Strategic_Account_LookUp__c;
        return quoteVar;
    }
        
  //Below method will be called from "Sync to Opportunity" button on PA header layout
  //It will sync the quote and then un-sync
    webservice static string createQuoteWithLines(string newPAId) 
    {
        String status = '';
        SAP_Price_Agreement__c newPA = [Select ID,Name,Expiration_Date__c,GE_Opportunity_No__c,GE_Quote_No__c,
                                        Bill_To_Customer_No__c,Partner_Customer_No__c,Description__c,Extended_Description__c,
                                        Agent_Number__c,Strategic_Account__c,Strategic_Account_LookUp__c,End_User_Customer_No__c,Strategic_Partner_Name__c,
                                        (SELECT Id from SAP_Price_Agreement_Items__r)
                                        FROM SAP_Price_Agreement__c where Id=:newPAId];
       List<SAP_Price_Agreement_Item__c> items = [SELECT ID FROM SAP_Price_Agreement_Item__c 
                                                                 WHERE Price_Agreement__c =: newPAId];
          
                                                           
        List<Opportunity> opptyList = new List<Opportunity>();
        boolean withChilds =false;
        if (newPA.GE_Opportunity_No__c == null) 
        {
            return 'Error: GE Opportunity NO must be populated in order to activate the functionality';
        }
        else if( newPA.Expiration_Date__c<Date.TODAY()-90 ){
        return 'Error: This record is expired. You cannot sync an expired record!!';
        } 
        else
        {
            opptyList = [SELECT Id, SyncedQuoteId From Opportunity where GE_LGT_GE_Opportunity_Id__c =:newPA.GE_Opportunity_No__c];
            if (opptyList.isEmpty())
            {
                return 'Error: Invalid Opportunity No / Entered Opportunity No does not exist';
            }
            else 
            {
                try
                {
                    System.debug('Check1:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
                    //List<Quote> oldQuotes = [SELECT Id, Name from Quote where Name=:newPA.Name AND Opportunity.GE_LGT_GE_Opportunity_Id__c =: newPA.GE_Opportunity_No__c];
                    List<Quote> oldQuotes = [SELECT Id, Name from Quote where Agreement_No__c=:newPA.Name AND Opportunity.GE_LGT_GE_Opportunity_Id__c =: newPA.GE_Opportunity_No__c];
                    System.debug('OldQuote::'+oldQuotes);
                    if (!oldQuotes.isEmpty())
                    {
                        //updateQuotesFromPricingAggrements(new Set<Id>{newPA.Id});
                        updateQuotesFromPricingAggrements(new List<SAP_Price_Agreement__c>{newPA});
                    }
                    else 
                    {
                        createORUpdateQuotesFromPricingAggrements(new List<SAP_Price_Agreement__c>{newPA});
                    }
                    System.debug('Check2:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
                    if (!opptyList.isEmpty())
                    {
                        newPA.Opportunity_Name__c = opptyList[0].Id;
                        //List<Quote> tempQuote = [Select Id, Name, GE_Quote_Number__c from Quote where Name= :newPA.Name AND OpportunityId =:opptyList[0].Id ];
                        system.debug('Neel check opptyList[0].Id :: '+opptyList[0].Id);
                        List<Quote> tempQuote = [Select Id, Name, GE_Quote_Number__c from Quote where Agreement_No__c= :newPA.Name AND OpportunityId =:opptyList[0].Id ];
                        if (!tempQuote.isEmpty())
                        {
                            status = 'Quote has created/updated';
                            //List<SAP_Price_Agreement_Item__c> items = newPA.SAP_Price_Agreement_Items__r;
                            System.debug('Check22:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
                            if (!items.isEmpty())
                            {
                                system.debug('Neel check 1 items ::'+items);
                                withChilds=createOrUpdateQuoteLinesUpdate(newPA, opptyList[0].Id);
                                //System.assert(false, withChilds);
                            }
                            
                            System.debug('Check3:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
                            system.debug('Neel check 2 tempQuote[0].ID :: '+tempQuote[0].ID);
                            List<QuoteLineItem> lineItems = [Select Id from QuoteLineItem where QuoteId =:tempQuote[0].ID];
                            system.debug('Neel check 3 lineItems ::'+lineItems);
                            if(items.isEmpty() || (!lineItems.isEmpty() &&  items.size() == lineItems.size()))
                            {
                                status = 'Quote and Quote line items are created/ updated';
                                newPA.GE_Quote_No__c = tempQuote[0].GE_Quote_Number__c;
                                //newPA.Quote_Name__c = tempQuote[0].ID;
                                //newPA.Quote_Name__c = NULL;
                                //newPA.Opportunity_Name__c = NULL;
                                if (opptyList[0].SyncedQuoteId != tempQuote[0].ID)
                                {
                                    StaticVariables.unSyncQuoteFlag = TRUE;
                                    opptyList[0].SyncedQuoteId = tempQuote[0].ID;
                                    List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
                                    Database.SaveResult OpptyUpdateResult = Database.update(opptyList[0],FALSE);
                                    if (!OpptyUpdateResult.isSuccess()){
                                        for( Database.Error err : OpptyUpdateResult.getErrors())
                                        {
                                            GE_LGT_EM_ErrorLog__c errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),OpptyUpdateResult.getId(),'Opportunity','Opportunity UPDATE Error - SAPPriceAgreementTriggerHelper class',err.getFields());
                                            errorLogList.add(errLogVar);
                                        status = 'Opportunity is not synced \n ' +err.getMessage();
                                        }
                                    }
                                    if(!errorLogList.isEmpty())
                                    {
                                       // status = 'Opportunity is not synced \nPlease contact Administrator';
                                        Database.insert(errorLogList,false);
                                    }
                                    else
                                    {
                                        if(items.isEmpty()){
                                            status = 'Quote is created/ updated and Opportunity is synced ';
                                        }
                                        status = 'Quote and Quote line items are created/ updated and Opportunity is synced ';
                                    }
                                }
                                
                                opptyList[0].SyncedQuoteId = NULL;
                                StaticVariables.unSyncQuoteFlag = FALSE;
                                Update opptyList[0];
                                
                                List<GE_LGT_EM_ErrorLog__c> PAErrorLogList=new List<GE_LGT_EM_ErrorLog__c>();
                                Database.SaveResult PAUpdateResult = Database.update(newPA,FALSE);
                                System.debug('Check4:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
                                if (!PAUpdateResult.isSuccess()){
                                    for( Database.Error err : PAUpdateResult.getErrors())
                                    {
                                        GE_LGT_EM_ErrorLog__c errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),PAUpdateResult.getId(),'SAP Price Agreement','SAP Price Agreement UPDATE Error - SAPPriceAgreementTriggerHelper class webservice method',err.getFields());
                                        PAErrorLogList.add(errLogVar);
                                    }
                                }
                                if(!PAErrorLogList.isEmpty())
                                {
                                    Database.insert(PAErrorLogList,false);
                                }
                            }
                            else
                            {
                                status = 'Error in Quote Items creating / updating \nPlease contact Administrator';
                            }
                        }
                        else
                        {
                            status = 'Quote is not created/updated \nPlease contact Administrator';
                        }
                    }
                }catch (Exception e) {
                    return('Error: '+e.getMessage());
                }
                return status;
            }
        }
    }
    
    public static boolean createOrUpdateQuoteLinesUpdate(SAP_Price_Agreement__c PAHeader, string OpptyId) 
    {
        System.debug('Check5:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
        List<QuoteLineItem> QuoteLineItemList = [SELECT Id,Quantity,UnitPrice,Condition_No__c,Description,Item_Alternate_Description__c
                                                 FROM QuoteLineItem 
                                                 WHERE Quote.Agreement_No__c =:PAHeader.Name And Quote.OpportunityId = :OpptyId];
        Map<Id, SAP_Price_Agreement_Item__c> newPAItemMap = new Map<Id, SAP_Price_Agreement_Item__c>
            ([SELECT ID,Agreement_No__c,Price_Agreement__c,Material_No__c,Quantity__c,Sales_Price__c,
              Item_Alternate_Description__c,Hierarchy_Level_1_Code__c,Hierarchy_Level_1_Description__c,Hierarchy_Level_2_Code__c,
              Hierarchy_Level_2_Description__c,Hierarchy_Level_3_Code__c,Hierarchy_Level_3_Description__c,Condition_No__c,
              Hierarchy_Level_4_Code__c,Hierarchy_Level_4_Description__c,Hierarchy_Level_5_Code__c,Hierarchy_Level_5_Description__c,
              Item_Description__c FROM SAP_Price_Agreement_Item__c WHERE Price_Agreement__c =:PAHeader.Id]);
        System.debug('newPAItemMap::'+newPAItemMap.values());
        System.debug('Check Time Taken For Delete-Start::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
        List<QuoteLineItem> QuoteLineItemListToInsert = new List<QuoteLineItem>();
        List<QuoteLineItem> QuoteLineItemListToUpdate = new List<QuoteLineItem>();
        List<SAP_Price_Agreement_Item__c> itemsToInsert = new List<SAP_Price_Agreement_Item__c>();
        Map<String, QuoteLineItem> itemMap = new Map<String, QuoteLineItem>();
        for(QuoteLineItem item:QuoteLineItemList)
        {
            itemMap.put(item.Condition_No__c,item);
        }
        for(SAP_Price_Agreement_Item__c agrItemVar:newPAItemMap.values())
        {
            if(itemMap.containsKey(agrItemVar.Condition_No__c))
            {
                System.debug('Compare Status');
                QuoteLineItem  quoteItemVar = itemMap.get(agrItemVar.Condition_No__c); 
                if( quoteItemVar.Quantity != agrItemVar.Quantity__c || quoteItemVar.UnitPrice != agrItemVar.Sales_Price__c || 
                   quoteItemVar.Description != agrItemVar.Item_Description__c || quoteItemVar.Item_Alternate_Description__c != agrItemVar.Item_Alternate_Description__c)
                {
                    QuoteLineItem quoteItemVar1 = new QuoteLineItem();
                    quoteItemVar1.ID = quoteItemVar.ID;
                    quoteItemVar1.Quantity = agrItemVar.Quantity__c;
                    quoteItemVar1.UnitPrice = agrItemVar.Sales_Price__c;
                    quoteItemVar1.Description = agrItemVar.Item_Description__c;
                    quoteItemVar1.Item_Alternate_Description__c = agrItemVar.Item_Alternate_Description__c;
                    QuoteLineItemListToUpdate.add(quoteItemVar1);
                }
            }
            else
            {
                itemsToInsert.add(agrItemVar);
            }
        }
        System.debug('Check Time Taken For Delete-End::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
        if (!itemsToInsert.isEmpty() || !QuoteLineItemListToUpdate.isEmpty()) 
        {
            List<QuoteLineItem> lineItems = new List<QuoteLineItem>();
            System.debug('Check Time Taken For Creation-Start::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
            if(!itemsToInsert.isEmpty())
                SAPPriceAgreementItemTriggerHelper.createQuoteItems(itemsToInsert);
            System.debug('Check Time Taken For Creation-End::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
            System.debug('Check Time Taken For Updation-Start::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
            if(!QuoteLineItemListToUpdate.isEmpty())
                Database.update(QuoteLineItemListToUpdate,FALSE);
            System.debug('Check Time Taken For Updation-End::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
            return true;
        }
        else 
        {
            return false;
        }
    }
    
    public static void updateFieldsOnCreateOrUpdate(List<SAP_Price_Agreement__c> newPAList)
    {
        // below block will be storing custom metadat records for Description mapping
        List<SAP_Customer_Code__mdt> codeList = new List<SAP_Customer_Code__mdt>(); 
        Map<string, string> codemap = new Map<string, string>();
        if(codeList.size() == 0)
        {
            codeList = [SELECT MasterLabel, DeveloperName, Code__c, Is_Active__c FROM SAP_Customer_Code__mdt];
        }
        for(SAP_Customer_Code__mdt cd : codeList)
        {
            codeMap.put(cd.DeveloperName, cd.MasterLabel);
        }
        // end : custom metadata
         Set<String> accountIntegrationKeySet = new Set<String>();
        for(SAP_Price_Agreement__c agrVar:newPAList)
        {
            if (agrVar.Customer_List__c != null){
                List<String> tempCustomerList = agrVar.Customer_List__c.split(',');

                if(tempCustomerList.size() > 1){
                    agrVar.Customer_Name__c = 'MULTIPLE';
                }
            }
            String orgCode  = agrVar.Sales_Org__c != NULL ? 'SR' + '_' + agrVar.Sales_Org__c : NULL ;
            String divCode  = agrVar.Division__c != NULL ? 'DV' + '_' + agrVar.Division__c : NULL ;
            String chanCode = agrVar.Distribution_Channel__c != NULL ? 'DC' + '_' + agrVar.Distribution_Channel__c : NULL ;
            
            if(agrVar.Fixture_Agent_Integration_Key__c!=NULL) accountIntegrationKeySet.add(agrVar.Fixture_Agent_Integration_Key__c);
            if(agrVar.Strategic_Account_Integration_Key__c!=NULL) accountIntegrationKeySet.add(agrVar.Strategic_Account_Integration_Key__c);
            
            agrVar.Sales_Org_Description__c = (orgCode!=NULL && codeMap.containsKey(orgCode) && codeMap.get(orgCode)!=NULL) ? codeMap.get(orgCode) : NULL;
            agrVar.Division_Description__c = (divCode!=NULL && codeMap.containsKey(divCode) && codeMap.get(divCode)!=NULL) ? codeMap.get(divCode) : NULL;
            agrVar.Distribution_Channel_Description__c = (chanCode!=NULL && codeMap.containsKey(chanCode) && codeMap.get(chanCode)!=NULL) ? codeMap.get(chanCode) : NULL;
        }
        if(!accountIntegrationKeySet.isEmpty())
        {
            Map<String,String> accMap = new Map<String,String>();
            for(Account acc:[SELECT ID,Customer_Integration_Key__c FROM Account WHERE Customer_Integration_Key__c IN:accountIntegrationKeySet])
            {
                accMap.put(acc.Customer_Integration_Key__c,acc.ID);
            }
            for(SAP_Price_Agreement__c agrVar:newPAList)
            {
                 if(agrVar.Fixture_Agent_Integration_Key__c!=NULL && accMap.containsKey(agrVar.Fixture_Agent_Integration_Key__c))
                     agrVar.Fixture_Agent__c = accMap.get(agrVar.Fixture_Agent_Integration_Key__c);
                if(agrVar.Strategic_Account_Integration_Key__c!=NULL && accMap.containsKey(agrVar.Strategic_Account_Integration_Key__c))
                     agrVar.Strategic_Account_LookUp__c = accMap.get(agrVar.Strategic_Account_Integration_Key__c);
            }
        }
    }    
    
    // CODE ENDS HERE
}
/*
Name - QuoteTriggerHelper
Test Class - QuoteTriggerHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Helper class for the Trigger SAPPriceAgreementTrigger
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
public class QuoteTriggerHelper 
{
    /*
* Author  : Shyam Prasad Nayakula
* Date    : July - 2017
* Purpose : This method populates the Account Lookups based on the SAP Unique Identifier
*/
    public static void updateQuoteDetails(List<Quote> quoteList)
    {
        //Creating a Set to Store the Account Customer Numbers
        Set<String> accIDSet=new Set<String>();
        for(Quote quoteVar:quoteList)
        {
            if(quoteVar.Partner_Customer_No__c!=NULL)
                accIDSet.add(quoteVar.Partner_Customer_No__c);
            if(quoteVar.Bill_To_Customer_No__c!=NULL)
                accIDSet.add(quoteVar.Bill_To_Customer_No__c);
        }
        //Retrieving the Account Records from Databased based on the Customer Numbers passed
        List<Account> retrievedAccList=[SELECT ID,GE_LGT_EM_SAPUniqueIdentifier__c 
                                        FROM Account 
                                        WHERE GE_LGT_EM_SAPUniqueIdentifier__c IN:accIDSet];
        //Map to Store Account where Customer Number as Key
        Map<String,Account> accMap=new Map<String,Account>();
        for(Account accVar:retrievedAccList)
        {
            accMap.put(accVar.GE_LGT_EM_SAPUniqueIdentifier__c,accVar);
        }
        //Based on the above map, Accounts will be mapped Quote
        for(Quote quoteVar:quoteList)
        {
            if(quoteVar.Bill_To_Customer_No__c!=NULL && accMap.containsKey(quoteVar.Bill_To_Customer_No__c))
            {
                quoteVar.Bill_To_Customer__c=accMap.get(quoteVar.Bill_To_Customer_No__c).Id;
            }
            if(quoteVar.Partner_Customer_No__c!=NULL && accMap.containsKey(quoteVar.Partner_Customer_No__c))
            {
                quoteVar.Partner_Name__c=accMap.get(quoteVar.Partner_Customer_No__c).Id;
            }
        }
    }
    
    
    // Below method will prevent syncing if ExpirationDate is in past
    public static void validateExpirationDateCurrency ( List<Quote> quoteList )  {
        //Iterating over each element to check the expiry date while sync is attempted
        
        for( Quote quoteVarExp : quoteList  ){
            if( quoteVarExp.ExpirationDate<Date.TODAY()-90 && quoteVarExp.isSyncing ){
                quoteVarExp.addError('You can not sync a quote which has expired!!');
            }
        }
    }
    
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : Nov - 2017
    * Purpose : This method updates Sync related fields on Quote
    */
    public static void updateQuoteSyncDetails(List<Quote> quoteList)
    {
        System.debug('IN::'+StaticVariables.unSyncQuoteFlag);
        if(StaticVariables.unSyncQuoteFlag)
        {
            //Creating a Set to Store the Account Customer Numbers
            Set<String> opptyIDSet=new Set<String>();
            Map<String,String> quoteOpptyMap = new Map<String,String>();
            for(Quote quoteVar:quoteList)
            {
                if(quoteVar.IsSyncing)
                {
                    quoteVar.Most_Recent_Synced_Date_Time__c = DateTime.now();
                    quoteVar.Last_Quote_Synced__c = TRUE;
                    quoteOpptyMap.put(quoteVar.ID,quoteVar.OpportunityId);
                }
                else
                {
                //    quoteVar.Last_Quote_Synced__c = FALSE;
                }
            }
            System.debug('quoteList::'+quoteList);
            System.debug('quoteOpptyMap::'+quoteOpptyMap);
            List<Quote> existingQuoteList = [SELECT ID FROM Quote WHERE OpportunityID IN:quoteOpptyMap.values() 
                                             AND Last_Quote_Synced__c = TRUE AND ID NOT IN:quoteList];
            List<Quote> quotesToUpdate = new List<Quote>();
            if(!existingQuoteList.isEmpty())
            {
                for(Quote var:existingQuoteList)
                {
                    Quote quotevar = new Quote();
                    quotevar.ID = var.ID;
                    quoteVar.Last_Quote_Synced__c = FALSE;
                    quotesToUpdate.add(quotevar);
                }
            }
            if(!quotesToUpdate.isEmpty())
                Database.update(quotesToUpdate,FALSE);
        }
    }
}
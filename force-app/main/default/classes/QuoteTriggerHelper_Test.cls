/*
Name - QuoteTriggerHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Test Class
Date - May-2016
*/
@isTest
public class QuoteTriggerHelper_Test 
{
   /* static testmethod void quoteTestmethod1()
    {   
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.recordtypeid=recOppTypeID;
        insert opp;
        
        //SAP_Quote__c sapQuote=TestDataUtil.createSAPQuote('999');
        sapQuote.Strategic_SAPUniqueId__c='1230011644-2FR1-20-10-SP';
        sapQuote.Agent_SAPUniqueId__c='1230011644-2FR1-20-10-SP';
        sapQuote.GE_Opportunity_Id__c='GE123';
        insert sapQuote;
        
        SAP_Quote_LineItem__c sapQuoteItem1=TestDataUtil.createSAPQuoteLineItem('999','10');
        SAP_Quote_LineItem__c sapQuoteItem2=TestDataUtil.createSAPQuoteLineItem('999','11');
        List<SAP_Quote_LineItem__c> sapQuoteItemList=new List<SAP_Quote_LineItem__c>();
        sapQuoteItemList.add(sapQuoteItem1);
        sapQuoteItemList.add(sapQuoteItem2);
        insert sapQuoteItemList;
        
        Quote quote=TestDataUtil.createQuote('999',opp);
        insert quote;
    }
    */
    static testMethod void testLastSyncedCheckbox()
    {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        insert switchList;
        
        PriceBook2 LEDPriceBook = TestDataUtil.createPriceBook('LED');
        insert LEDPriceBook;
        
        //Creating Account Record 
        Account acc = TestDataUtil_PA2Q.createAccounts(1)[0];
        acc.GE_LGT_EM_SAPUniqueIdentifier__c = '1246A01-1US1-20-10-SP';
        insert acc;
        
        Account acc1 = [SELECT ID,RecordType.Name FROM Account WHERE ID=:acc.ID];
        System.debug('acc1:'+acc1);
        
        //Creating Opportunity Record
        Opportunity opp = TestDataUtil_PA2Q.createOpportunities(1,acc)[0];
        insert opp;
        
        List<Quote> quoteList = TestDataUtil_PA2Q.createQuotes(2,9000001);
        for(Quote quoteVar:quoteList)
        {
            quoteVar.Pricebook2Id = LEDPriceBook.ID;
            quoteVar.OpportunityID = opp.ID;
            quoteVar.Partner_Customer_No__c = '1246A01-1US1-20-10-SP';
            quoteVar.Bill_To_Customer_No__c = '1246A01-1US1-20-10-SP';
        }
		insert quoteList;
        opp.SyncedQuoteId = quoteList[0].ID;
        update opp;
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> updatedQuoteList1 = [SELECT ID,Name,Last_Quote_Synced__c FROM Quote WHERE ID=:quoteList[0].ID];
        System.assertEquals(TRUE,updatedQuoteList1[0].Last_Quote_Synced__c);

		Opportunity retOpp = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID=:opp.ID];
        opp.SyncedQuoteId = quoteList[1].ID;
        update opp;
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> updatedQuoteList2 = [SELECT ID,Name,Last_Quote_Synced__c FROM Quote WHERE ID=:quoteList[1].ID];
        System.assertEquals(TRUE,updatedQuoteList2[0].Last_Quote_Synced__c);
        
        List<Quote> updatedQuoteList3 = [SELECT ID,Name,Last_Quote_Synced__c FROM Quote WHERE ID=:quoteList[0].ID];
        System.assertEquals(FALSE,updatedQuoteList3[0].Last_Quote_Synced__c);

    }
}
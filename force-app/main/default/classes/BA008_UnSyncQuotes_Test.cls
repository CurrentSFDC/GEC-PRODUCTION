/*
Name - BA008_UnSyncQuotes_Test
Author - Shyam Prasad Nayakula
Purpose - Test class of BA008_UnSyncQuotes
Created Date - October -2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
@isTest
public class BA008_UnSyncQuotes_Test 
{
    static testMethod void testCreateQuoteItems()
    {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        insert switchList;
        
        //Creating Account Record 
        Account acc = TestDataUtil_PA2Q.createAccounts(1)[0];
        insert acc;
        
        Account acc1 = [SELECT ID,RecordType.Name FROM Account WHERE ID=:acc.ID];
        System.debug('acc1:'+acc1);
        
        //Creating Opportunity Record
        Opportunity opp = TestDataUtil_PA2Q.createOpportunities(1,acc)[0];
        insert opp;
        System.debug('opp:'+opp);
        
        Opportunity retOpp = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID=:opp.ID];
        
        //Creating OSR Record
        Opportunity_Support_Request__c osrVar = TestDataUtil.createOSR();
        osrVar.Opportunity_Name__c = opp.ID;
        osrVar.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        osrVar.Status__c = 'Not Submitted';
        insert osrVar;
        System.debug('osrVar:'+osrVar);
        
        //Updating the OSR Status to Submitted, so that Quote Record will be created automatically.
        osrVar.Status__c = 'Submitted';
        update osrVar;
        System.debug('osrVar-Update:'+osrVar);
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> quoteList = [SELECT ID,OpportunityId,GE_Quote_Number__c FROM Quote WHERE OpportunityId=:opp.ID];
        System.assertEquals(opp.ID,quoteList[0].OpportunityId);        
        
        
        //SAP_Price_Agreement__c agreement = TestDataUtil.createPriceAgreement('9988',retOpp.GE_LGT_GE_Opportunity_Id__c);
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        agreement.GE_Quote_No__c = quoteList[0].GE_Quote_Number__c;
        insert agreement;
        
        Test.startTest();
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> updatedQuoteList = [SELECT ID,Name FROM Quote WHERE ID=:quoteList[0].ID];
        //System.assertEquals('Generated From SAP Agreement #9988',updatedQuoteList[0].Name);
        
        BA008_UnSyncQuotes batchTest = new BA008_UnSyncQuotes();
        Database.executeBatch(batchTest);
        
        retOpp = [SELECT ID,UnSync_From_Quote__c FROM Opportunity WHERE ID=:opp.ID];
        System.assertEquals(retOpp.UnSync_From_Quote__c,FALSE);      
        
        Test.stopTest();
        
    }
}
/*
Name - BA009_SyncQuoteToOppty_Test
Auth - Neel (Feb-2018)
Purpose - To provde test coverage to batch class 'BA009_SyncQuoteToOppty'

*/

@isTest
public class BA009_SyncQuoteToOppty_Test{
    static testMethod void syncQuoteToOppty(){
    //Create Quote with flag (AutoSyncQuoteFromPAHeader__c)=true
     
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
        List<Quote> quoteList = [SELECT ID,OpportunityId,GE_Quote_Number__c,AutoSyncQuoteFromPAHeader__c FROM Quote WHERE OpportunityId=:opp.ID];
        System.assertEquals(opp.ID,quoteList[0].OpportunityId);        
        
        
        //SAP_Price_Agreement__c agreement = TestDataUtil.createPriceAgreement('9988',retOpp.GE_LGT_GE_Opportunity_Id__c);
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        agreement.GE_Quote_No__c = quoteList[0].GE_Quote_Number__c;
        agreement.Quote_Name__c = quoteList[0].Id;
        insert agreement;
        System.debug('agreement+++++++++++++++++++++:'+agreement);
        
        //Retrieve Agreement 'Quote_Name__c' so that corresponding Quote's flag 'AutoSyncQuoteFromPAHeader__c' can be chacked
        SAP_Price_Agreement__c agreementVar = [SELECT id, Quote_Name__c FROM SAP_Price_Agreement__c WHERE id=:agreement.id];
        system.debug('***AgrementId***'+agreementVar.Quote_Name__c);
        
        //Retrieve Quote to check for assertion
         Quote quoteVar = [SELECT ID, AutoSyncQuoteFromPAHeader__c FROM Quote WHERE Id=:agreementVar.Quote_Name__c];
        
        //System.assertEquals(quoteVar.AutoSyncQuoteFromPAHeader__c ,false);   
        
        Database.executeBatch(new BA009_SyncQuoteToOppty());
    
    }
}
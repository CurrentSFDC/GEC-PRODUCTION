/*
Name - SAPPriceAgreementItemTrigger_Test
Author - Shyam Prasad Nayakula
Purpose - Test class of SAPPriceAgreementItemTrigger and SAPPriceAgreementItemTriggerHelper
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
@isTest
public class SAPPriceAgreementItemTrigger_Test 
{
    static testMethod void testupdateFieldsOnCreateOrUpdate()
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
        insert acc;
        //Creating Opportunity Record
        Opportunity opp = TestDataUtil_PA2Q.createOpportunities(1,acc)[0];
        opp.Pricebook2Id = LEDPriceBook.ID;
        insert opp;
        Opportunity retOpp = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID=:opp.ID]; 
        
        Test.startTest();
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        insert agreement;
        try
        {
            SAP_Price_Agreement_Item__c agrItem = TestDataUtil_PA2Q.createPriceAgreementItems(1,1000000001)[0];
            agrItem.Agreement_No__c = NULL;
            insert agrItem;
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains('SAP Price Agreement header is needed to create SAP Price Agreement Item'));
        }
        Test.stopTest();
    }
    static testMethod void testCreateQuoteItems()
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
        insert acc;
        
        //Creating Opportunity Record
        Opportunity opp = TestDataUtil_PA2Q.createOpportunities(1,acc)[0];
        opp.Pricebook2Id = LEDPriceBook.ID;
        insert opp;
        
        Opportunity retOpp = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID=:opp.ID];      
        
        Test.startTest();
        
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        insert agreement;
        
        SAP_Price_Agreement_Item__c agrItem = TestDataUtil_PA2Q.createPriceAgreementItems(1,1000000001)[0];
        agrItem.Agreement_No__c = agreement.Agreement_No__c;
        agrItem.Material_No__c = '1000000001';
        insert agrItem;
        
        Test.stopTest();
        
        List<Product2> prodList = [SELECT ID,Name FROM Product2 LIMIT 1];
        System.debug('ProdList::'+prodList);
        System.assertEquals('1000000001',prodList[0].Name);
        
        List<PriceBookEntry> priceBookEntryList = [SELECT ID,Product2ID FROM PriceBookEntry];
        System.debug('priceBookEntryList::'+priceBookEntryList);
        
        List<Quote> quoteList = [SELECT ID,OpportunityId,GE_Quote_Number__c,Name,PriceBook2ID FROM Quote WHERE Name =: agreement.Name];
        //System.assertEquals(agreement.Name,quoteList[0].Name); 
        System.debug('quoteList::'+quoteList);
        
        //List<QuoteLineItem> itemList = [SELECT ID FROM QuoteLineItem WHERE QuoteID =: quoteList[0].ID];
        //System.assertEquals(1,itemList.size());
        
        List<GE_LGT_EM_ErrorLog__c> logList = [SELECT ID,GE_LGT_EM_Description__c FROM GE_LGT_EM_ErrorLog__c];
        System.debug('LogList::'+logList);
        
    }
    
    static testMethod void testCreateQuoteItems1()
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
        insert acc;
        
        //Creating Opportunity Record
        Opportunity opp = TestDataUtil_PA2Q.createOpportunities(1,acc)[0];
        opp.Pricebook2Id = LEDPriceBook.ID;
        insert opp;
        
        Opportunity retOpp = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID=:opp.ID];      
        
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        insert agreement;
       
        Test.startTest();
        
        SAP_Price_Agreement_Item__c  agrItem = TestDataUtil_PA2Q.createPriceAgreementItems(1,1000000001)[0];
        agrItem.Material_No__c = '1000000001';
        agrItem.Agreement_No__c = agreement.Agreement_No__c;
        insert agrItem;
        
        SAP_Price_Agreement_Item__c agrItem1 = TestDataUtil_PA2Q.createPriceAgreementItems(1,1000000001)[0];
        agrItem1.Agreement_No__c = agreement.Agreement_No__c;
        agrItem1.Material_No__c = '1000000001';
        agrItem1.Hierarchy_Level_1_Code__c = 'Level 1 Code';
        insert agrItem1;
        
        agrItem1.Quantity__c = 30;
        update agrItem1;
        
        Test.stopTest();
        
        //List<Product2> prodList = [SELECT ID,Name,Hierarchy_Level_1_Code__c FROM Product2 WHERE Name =: '1000000001'];
        //System.assertEquals('Level 1 Code',prodList[0].Hierarchy_Level_1_Code__c);
    }
}
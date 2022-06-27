/*
Name - BA007_ProcessAgreementItems_Test
Author - Shyam Prasad Nayakula
Purpose - Test class of BA007_ProcessAgreementItems and SC007_ProcessAgreementItems
Created Date - October -2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
@isTest
public class BA007_ProcessAgreementItems_Test 
{
    static testMethod void testCreateQuoteItems()
    {
        AdminOverride__c adminOverride = new AdminOverride__c();
        adminOverride.Switch_Off_Trigger__c = TRUE;
        insert adminOverride;
        
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
        
        SAP_Price_Agreement_Item__c  agrItem = TestDataUtil_PA2Q.createPriceAgreementItems(1,1000000001)[0];
        agrItem.Material_No__c = '1000000001';
        agrItem.Agreement_No__c = agreement.Agreement_No__c;
        insert agrItem;
        
        SC007_ProcessAgreementItems scheduleTest = new SC007_ProcessAgreementItems();
        scheduleTest.execute(NULL);
        
        Test.stopTest();
        
    }
}
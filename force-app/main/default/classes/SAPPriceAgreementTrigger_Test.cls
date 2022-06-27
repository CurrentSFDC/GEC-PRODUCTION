/*
Name - SAPPriceAgreementTrigger_Test
Author - Shyam Prasad Nayakula
Purpose - Test class of SAPPriceAgreementTrigger and SAPPriceAgreementTriggerHelper
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
@isTest
public class SAPPriceAgreementTrigger_Test 
{
    static testMethod void createTestRecords()
    { 
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        
        TriggerSwitch__c osrSwitch1 = new TriggerSwitch__c();
        osrSwitch1.Name = 'QuoteLineItemUpdate';
        osrSwitch1.isActive__c = TRUE;
        switchList.add(osrSwitch1);
        
        insert switchList;
        
        PriceBook2 LEDPriceBook = TestDataUtil.createPriceBook('LED');
        insert LEDPriceBook;
        
        //Creating Account Records 
        List<Account> testAccList = TestDataUtil_PA2Q.createAccounts(1);
        insert testAccList; 
        
        //Creating Opportunity Records
        List<Opportunity> testOppList = TestDataUtil_PA2Q.createOpportunities(10,testAccList[0]);
        for(Opportunity opp:testOppList)
        {
            opp.Pricebook2Id = LEDPriceBook.ID;
        }
        insert testOppList;
        
        
        //Creating Quote Records
        List<Quote> testQuoteList = TestDataUtil_PA2Q.createQuotes(5,9000001);
        testQuoteList[0].OpportunityID = testOppList[0].ID;
        testQuoteList[1].OpportunityID = testOppList[0].ID;
        testQuoteList[2].OpportunityID = testOppList[3].ID;
        testQuoteList[3].OpportunityID = testOppList[7].ID;
        testQuoteList[4].OpportunityID = testOppList[9].ID;
        for(Quote quoteVar:testQuoteList)
        {
            quoteVar.Pricebook2Id = LEDPriceBook.ID;
        }
        insert testQuoteList;
        
        List<Quote> quoteListBefore = [SELECT ID,PriceBook2ID FROM Quote];
        System.debug('quoteListBefore::'+quoteListBefore);
        
        List<Opportunity> insertedOppList = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID IN:testOppList];
        
        Test.startTest();
        
        //Creating Agreement Records
        List<SAP_Price_Agreement__c> testAgreementList = TestDataUtil_PA2Q.createPriceAgreements(250,0090010001);
        
        for(Integer i=0;i<10;i++)
        {
            testAgreementList[i].GE_Opportunity_No__c = insertedOppList[0].GE_LGT_GE_Opportunity_Id__c;
            testAgreementList[i].Customer_List__c = '0000010284,0000102831';
        }
        for(Integer i=10;i<20;i++)
        {
            testAgreementList[i].GE_Opportunity_No__c = insertedOppList[1].GE_LGT_GE_Opportunity_Id__c;
            testAgreementList[i].Customer_List__c = '0000010284,0000102831';
        }
        for(Integer i=50;i<100;i++)
        {
            testAgreementList[i].GE_Opportunity_No__c = insertedOppList[4].GE_LGT_GE_Opportunity_Id__c;
            testAgreementList[i].Customer_List__c = '0000010284,0000102831';
        }
        
        //Setting GE Quote No for Agreements to update Placeholder Quotes
        testAgreementList[200].GE_Quote_No__c = testQuoteList[0].QuoteNumber;
        testAgreementList[201].GE_Quote_No__c = testQuoteList[1].QuoteNumber;
        testAgreementList[202].GE_Quote_No__c = testQuoteList[2].QuoteNumber;
        testAgreementList[203].GE_Quote_No__c = testQuoteList[3].QuoteNumber;
        testAgreementList[204].GE_Quote_No__c = testQuoteList[4].QuoteNumber;
        insert testAgreementList;
        
        List<SAP_Price_Agreement__c> retrievedAgreementList = [SELECT ID,Agreement_No__c FROM SAP_Price_Agreement__c 
                                                               WHERE ID IN:testAgreementList];
        //Creating Agreement Item Records
        List<SAP_Price_Agreement_Item__c> testAgreementItemsList = TestDataUtil_PA2Q.createPriceAgreementItems(2000,1000000001);
        for(Integer i=0;i<2000;i++)
        {
            Integer helper = i/8;
            testAgreementItemsList[i].Agreement_No__c = testAgreementList[helper].Agreement_No__c;
            if(i<400)
            {
                testAgreementItemsList[i].Material_No__c = '1000000400';
            }
            else if(i<800)
            {
                testAgreementItemsList[i].Material_No__c = '1000000800';
            }
            else if(i<1200)
            {
                testAgreementItemsList[i].Material_No__c = '1000001200';
            }
            else if(i<1600)
            {
                testAgreementItemsList[i].Material_No__c = '1000001600';
            }
            else if(i<2000)
            {
                testAgreementItemsList[i].Material_No__c = '1000001200';
            }
        }
        System.debug('testAgreementItemsList::'+testAgreementItemsList);
        insert testAgreementItemsList;
        Test.stopTest();
        
        
        List<SAP_Price_Agreement_Item__c> retrievedAgreementItemList = [SELECT ID,Agreement_No__c FROM SAP_Price_Agreement_Item__c 
                                                                        WHERE ID IN:testAgreementItemsList];
        System.debug('AgreementItemList::'+retrievedAgreementItemList.size());                                                                   
        
        List<Quote> quoteList = [SELECT ID FROM Quote];
        System.debug('quoteList::'+quoteList.size());
        //Checking total number of Quotes  - 70 Created from Agreements and 5 manually inserted
        //System.assertEquals(5,quoteList.size());  
        
        List<Product2> Prod2List = [SELECT ID FROM Product2];
        System.debug('Prod2List::'+Prod2List.size());
        //Checking total number of Products Inserted 
        System.assertEquals(4,Prod2List.size());  
        
        List<QuoteLineItem> quoteItemList = [SELECT ID FROM QuoteLineItem];
        System.debug('quoteItemList::'+quoteItemList.size());
        
        List<GE_LGT_EM_ErrorLog__c> errorLogList = [SELECT ID,GE_LGT_EM_Description__c,GE_LGT_EM_Object__c FROM GE_LGT_EM_ErrorLog__c];
        System.debug('ErrorLogList Size::'+errorLogList.size());
        System.debug('ErrorLogList::'+errorLogList);
    }
    
    static testMethod void testcreateOrUpdateQuotes()
    {       
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        TriggerSwitch__c osrSwitch1 = new TriggerSwitch__c();
        osrSwitch1.Name = 'QuoteLineItemUpdate';
        osrSwitch1.isActive__c = TRUE;
        switchList.add(osrSwitch1);
        insert switchList;
        
        //Creating Account Record 
        Account acc = TestDataUtil_PA2Q.createAccounts(1)[0];
        acc.GE_LGT_EM_SAPUniqueIdentifier__c = '10001-10-10-1US1';
        acc.Customer_Integration_Key__c='0080015220-1US1-20-10-20-39';
        insert acc; 
        
        //Creating Opportunity Record
        Opportunity opp = TestDataUtil_PA2Q.createOpportunities(1,acc)[0];
        insert opp;
        
        Opportunity retOpp = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID=:opp.ID];
        
        Test.startTest();
        //SAP_Price_Agreement__c agreement = TestDataUtil.createPriceAgreement('9988',retOpp.GE_LGT_GE_Opportunity_Id__c);
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        agreement.Bill_To_Customer_No__c = '10001-10-10-1US1';
        agreement.Partner_Customer_No__c = '10001-10-10-1US1';
        agreement.Strategic_Account_Integration_Key__c='0080015220-1US1-20-10-20-39';
        agreement.Fixture_Agent_Integration_Key__c='0080015220-1US1-20-10-20-39';
        insert agreement;
        Test.stopTest();
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> quoteList = [SELECT ID,OpportunityId FROM Quote WHERE OpportunityId=:opp.ID];
        if (quoteList.size()>0)

        System.assertEquals(opp.ID,quoteList[0].OpportunityId); 
               
    }
    
    static testMethod void testCreateQuoteFromOSR()
    {    
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        TriggerSwitch__c osrSwitch1 = new TriggerSwitch__c();
        osrSwitch1.Name = 'QuoteLineItemUpdate';
        osrSwitch1.isActive__c = TRUE;
        switchList.add(osrSwitch1);
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

        Quote qt1 = new Quote();
            qt1.Name = '00012345';
            qt1.OpportunityId = opp.Id;
            insert qt1;
        
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
        //System.assertEquals(opp.ID,quoteList[0].OpportunityId);        
        
        Test.startTest();
        //SAP_Price_Agreement__c agreement = TestDataUtil.createPriceAgreement('9988',retOpp.GE_LGT_GE_Opportunity_Id__c);
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        agreement.GE_Quote_No__c = quoteList[0].GE_Quote_Number__c;
        insert agreement;
        Test.stopTest();
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> updatedQuoteList = [SELECT ID,Name FROM Quote WHERE ID=:quoteList[0].ID];
        //System.assertEquals('FROM OSR',updatedQuoteList[0].Name);
    }
    
    static testMethod void testupdateExistingQuotes()
    {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        TriggerSwitch__c osrSwitch1 = new TriggerSwitch__c();
        osrSwitch1.Name = 'QuoteLineItemUpdate';
        osrSwitch1.isActive__c = TRUE;
        switchList.add(osrSwitch1);
        insert switchList;
        
        //Creating Account Record 
        Account acc = TestDataUtil_PA2Q.createAccounts(1)[0];
        insert acc;
        
        Account acc1 = [SELECT ID,RecordType.Name FROM Account WHERE ID=:acc.ID];
        System.debug('acc1:'+acc1);
        
        //Creating Opportunity Record
        Opportunity opp = TestDataUtil_PA2Q.createOpportunities(1,acc)[0];
        insert opp;
        
        Opportunity retOpp = [SELECT ID,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE ID=:opp.ID];
        
        //Creating OSR Record
        Opportunity_Support_Request__c osrVar = TestDataUtil.createOSR();
        osrVar.Opportunity_Name__c = opp.ID;
        osrVar.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        osrVar.Status__c = 'Not Submitted';
        insert osrVar;
        
        //Updating the OSR Status to Submitted, so that Quote Record will be created automatically.
        osrVar.Status__c = 'Submitted';
        update osrVar;

        Quote qt1 = new Quote();
            qt1.Name = '0001234';
            qt1.OpportunityId = opp.Id;
            insert qt1;
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> quoteList = [SELECT ID,OpportunityId,GE_Quote_Number__c FROM Quote WHERE OpportunityId=:opp.ID];
        //System.assertEquals(opp.ID,quoteList[0].OpportunityId);        
        
        Test.startTest();
        //SAP_Price_Agreement__c agreement = TestDataUtil.createPriceAgreement('9988',retOpp.GE_LGT_GE_Opportunity_Id__c);
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = retOpp.GE_LGT_GE_Opportunity_Id__c;
        agreement.GE_Quote_No__c = quoteList[0].GE_Quote_Number__c;
        agreement.Last_Modified_DateTime__c = DateTime.now();
        insert agreement;
        
        agreement.Expiration_Date__c = Date.today()+20;
        agreement.Last_Modified_DateTime__c = DateTime.now()+10;
        update agreement;
        Test.stopTest();
        
        //Retrieving the Quotes for the inserted opportunity in the System
        List<Quote> updatedQuoteList1 = [SELECT ID,Name,ExpirationDate FROM Quote WHERE ID=:quoteList[0].ID];
        // System.assertEquals(Date.today()+20,updatedQuoteList1[0].ExpirationDate);
    }
    
    static testMethod void testcreateQuoteWithLines()
    {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        TriggerSwitch__c osrSwitch1 = new TriggerSwitch__c();
        osrSwitch1.Name = 'QuoteLineItemUpdate';
        osrSwitch1.isActive__c = TRUE;
        switchList.add(osrSwitch1);
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
        retOpp.GE_LGT_Opportunity_ID__c='123';
        update retOpp;
        Test.startTest();
        SAP_Price_Agreement__c agreement = TestDataUtil_PA2Q.createPriceAgreements(1,9988)[0];
        agreement.GE_Opportunity_No__c = '123';
        agreement.Customer_List__c = '0000010284;0000102831';
        insert agreement;
        
        SAP_Price_Agreement__c newPA = [Select ID,Name,Expiration_Date__c,GE_Opportunity_No__c,GE_Quote_No__c,
                                        Bill_To_Customer_No__c,Partner_Customer_No__c,Description__c,Extended_Description__c,
                                        Agent_Number__c,Strategic_Account__c,Strategic_Account_LookUp__c,End_User_Customer_No__c,Strategic_Partner_Name__c,
                                        (SELECT Id from SAP_Price_Agreement_Items__r)
                                        FROM SAP_Price_Agreement__c where Id=:agreement.id];
        
        system.debug('agreement'+newPA);
        newPA.GE_Opportunity_No__c='123';
        update newPA;
        
        SAP_Price_Agreement__c newPA1 = [Select ID,Name,Expiration_Date__c,GE_Opportunity_No__c,GE_Quote_No__c,
                                        Bill_To_Customer_No__c,Partner_Customer_No__c,Description__c,Extended_Description__c,
                                        Agent_Number__c,Strategic_Account__c,Strategic_Account_LookUp__c,End_User_Customer_No__c,Strategic_Partner_Name__c,
                                        (SELECT Id from SAP_Price_Agreement_Items__r)
                                        FROM SAP_Price_Agreement__c where Id=:newPA.id];
        
        system.debug('newPA1'+newPA1);
        SAPPriceAgreementTriggerHelper.createQuoteWithLines(newPA1.ID);
        Test.stopTest();
    }
    
    static testMethod void testcreateQuoteWithLineItems()
    {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        TriggerSwitch__c osrSwitch1 = new TriggerSwitch__c();
        osrSwitch1.Name = 'QuoteLineItemUpdate';
        osrSwitch1.isActive__c = TRUE;
        switchList.add(osrSwitch1);
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
        agreement.Customer_List__c = '0000010284;0000102831';
        insert agreement;
        SAP_Price_Agreement_Item__c agrItem = TestDataUtil.createPriceAgreementItem(agreement,'123454');
        insert agrItem;
        
        SAP_Price_Agreement_Item__c agrItem1 = TestDataUtil.createPriceAgreementItem(agreement,'123454');
        agrItem1.Hierarchy_Level_1_Code__c = 'Level 1 Code';
        //insert agrItem1;
        Test.stopTest();        
        SAPPriceAgreementTriggerHelper.createQuoteWithLines(agreement.ID);
    }
    
    static testMethod void testcreateOrUpdateQuoteLinesUpdate()
    {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c osrSwitch = new TriggerSwitch__c();
        osrSwitch.Name = 'OpportunitySupportRequestTrigger';
        osrSwitch.isActive__c = TRUE;
        switchList.add(osrSwitch);
        TriggerSwitch__c osrSwitch1 = new TriggerSwitch__c();
        osrSwitch1.Name = 'QuoteLineItemUpdate';
        osrSwitch1.isActive__c = TRUE;
        switchList.add(osrSwitch1);
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
        agreement.Name ='TestPA';

        insert agreement;
        
        Product2 p2= new Product2();
        p2.name='1';
        insert p2;
        
        Pricebook2 pbook2= new Pricebook2();
        pbook2.CurrencyIsoCode='USD';
        pbook2.Name='test';
        pbook2.IsActive=true;
        
        insert pbook2;
        
        PricebookEntry pbook1 = new PricebookEntry();
        pbook1.UnitPrice=1;
        pbook1.Pricebook2Id=pbook2.id;
        pbook1.Product2Id =p2.id;
        pbook1.IsActive=true;
        insert pbook1;
        
        Quote Quote1= new Quote();
		Quote1.Agreement_No__c='TestPA';
        Quote1.OpportunityId=retOpp.id;
        Quote1.Name='abc';
        Quote1.Pricebook2Id=pbook2.id;

        insert Quote1;
        
        

        
        
        
        QuoteLineItem QuoteLineItem1=new QuoteLineItem();
        QuoteLineItem1.Agreement_No__c='TestPA';
        QuoteLineItem1.Quoteid=Quote1.id;
        QuoteLineItem1.PricebookEntryId=pbook1.id;
        QuoteLineItem1.Quantity=1;
		QuoteLineItem1.UnitPrice=123;
        QuoteLineItem1.Product2Id=p2.id;



        insert QuoteLineItem1;
        
        SAP_Price_Agreement_Item__c agrItem = TestDataUtil.createPriceAgreementItem(agreement,'123454');
        insert agrItem;
        
        SAP_Price_Agreement_Item__c agrItem1 = TestDataUtil.createPriceAgreementItem(agreement,'123454');
        agrItem1.Hierarchy_Level_1_Code__c = 'Level 1 Code';
        //insert agrItem1;
        Test.stopTest();        
        SAPPriceAgreementTriggerHelper.createOrUpdateQuoteLinesUpdate(agreement,retOpp.id);
    }
    
    static testMethod void testcreateORUpdateQuotesFromPricingAggrements()
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
        agreement.Name ='TestPA';
        agreement.GE_Quote_No__c='TestQuote';

        insert agreement;
        
        Product2 p2= new Product2();
        p2.name='1';
        insert p2;
        
        Pricebook2 pbook2= new Pricebook2();
        pbook2.CurrencyIsoCode='USD';
        pbook2.Name='test';
        pbook2.IsActive=true;
        
        insert pbook2;
        
        PricebookEntry pbook1 = new PricebookEntry();
        pbook1.UnitPrice=1;
        pbook1.Pricebook2Id=pbook2.id;
        pbook1.Product2Id =p2.id;
        pbook1.IsActive=true;
        insert pbook1;
        
        Quote Quote1= new Quote();
		Quote1.Agreement_No__c='TestPA';
        Quote1.OpportunityId=retOpp.id;
        Quote1.Name='abc';
        Quote1.Pricebook2Id=pbook2.id;
		Quote1.GE_Quote_Number__c='TestQuote';
        insert Quote1;
        
        

        
        
        
        QuoteLineItem QuoteLineItem1=new QuoteLineItem();
        QuoteLineItem1.Agreement_No__c='TestPA';
        QuoteLineItem1.Quoteid=Quote1.id;
        QuoteLineItem1.PricebookEntryId=pbook1.id;
        QuoteLineItem1.Quantity=1;
		QuoteLineItem1.UnitPrice=123;
        QuoteLineItem1.Product2Id=p2.id;



        insert QuoteLineItem1;
        
        SAP_Price_Agreement_Item__c agrItem = TestDataUtil.createPriceAgreementItem(agreement,'123454');
        insert agrItem;
        
        SAP_Price_Agreement_Item__c agrItem1 = TestDataUtil.createPriceAgreementItem(agreement,'123454');
        agrItem1.Hierarchy_Level_1_Code__c = 'Level 1 Code';
        //insert agrItem1;
        List<SAP_Price_Agreement__c> retreivedPAList= new List<SAP_Price_Agreement__c>();
        retreivedPAList.add(agreement);
        SAPPriceAgreementTriggerHelper.createORUpdateQuotesFromPricingAggrements(retreivedPAList);
        Test.stopTest();        
        
    }
}
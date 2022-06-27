@isTest
public class GE_LGT_ProductsSearch_Test 
{
    //Rashmitha Changed the API vesion from 33 to 45 on 6-Mar-2019 as per 1447 request
    static testMethod void ProductsSearch()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        // INSERT ACCOUNT RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = date.parse('3/10/2099');
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');// changed the date as there is a validation rule on PO Recipt date. Changed on 20 Oct 20
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';     
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('TestProd1');
        product.name = 'TestProd1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product; 
        
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem();
        lineItem1.ServiceDate = opp.closedate + 50;
        lineItem1.UnitPrice=200;
        lineItem1.Quantity=3;
        lineItem1.Description='Test33';
        lineItem1.Pricebookentryid=pbet_id;
        lineItem1.OpportunityId=opp.Id;
        lineItem1.ServiceDate= opp.closedate + 30;
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=6;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.closedate + 30;
        lineItem2.Pricebookentryid=pbet_id;
        oppLineItems.add(lineItem2);
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
        Mn.Level_4__c='test000023311-test22-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn; 
        
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch control =new GE_LGT_ProductsSearch(sc);
        control.csvfile='OpptyProductMassUploadTemplate.csv';
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nTest33,93022645,10,100\n');
        control.ReadFile();
        control.contentFile=Blob.valueOf('\n');
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nABV101V571GV41BNW,93022645,20,100\n');
        
        control.HeadCheck();
        control.validateCSV();
        control.ReadFile();
        control.onLoadPage_Products();
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nABV101V571GV41BNW,93022645,20,1200\n');
        control.HeadCheck();
        control.validateCSV();
        control.ReadFile();
        control.saveoli();
        Test.stoptest();
    }
    
    static testMethod void ProductsSearchvalidation()
    {
      
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        // INSERT ACCOUNT RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = date.parse('3/10/2099');
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');//Changed on 20 Oct 20 as validation rule is preventing test to run
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';    
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('TestProd1');
        product.name = 'TestProd1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product; 
        
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem();
        lineItem1.ServiceDate = opp.closedate + 50;
        lineItem1.UnitPrice=200;
        lineItem1.Quantity=3;
        lineItem1.Description='Test33';
        lineItem1.Pricebookentryid=pbet_id;
        lineItem1.OpportunityId=opp.Id;
        lineItem1.ServiceDate= opp.closedate + 30;
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=6;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.closedate + 30;
        lineItem2.Pricebookentryid=pbet_id;
        oppLineItems.add(lineItem2);
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
        Mn.Level_4__c='test000023311-test22-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn;
        
        opp.StageName = 'Closed Lost';
        update opp;
        Opportunity stagevalu =[select StageName from opportunity where Id=:opp.Id];
        System.assertEquals('Closed Lost', stagevalu.StageName);
        
        String s2 = 'Quarterly';
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch control =new GE_LGT_ProductsSearch(sc);
        
        
         Profile p = [SELECT Id FROM Profile WHERE Name='EUROPE Current Sales']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@ge.com.satishdev',
             GE_LGT_Business_Division__c='EMEA Service' );
        try{
            
             System.runAs ( u ) { 
              control.saveoli();
            
             }
        }
         catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Users cannot modify an opportunity Products that are PO Received or Closed Lost') ? TRUE : FALSE;
                                       
            System.AssertEquals(expectedExceptionThrown, True);
        } 
        try{
            
             System.runAs ( u ) { 
              
               control.deloli();
            
             }
        }
         catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Users cannot modify an opportunity Products that are PO Received or Closed Lost') ? TRUE : FALSE;
                                       
            System.AssertEquals(expectedExceptionThrown, True);
        } 

        Test.stoptest();
    }
    Static TestMethod void ProductsSearchbulkinsertionopptylineitem()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        /// INSERT ACCOUNT RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = date.parse('3/10/2099');
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');// changed on 20th Oct 20 for validation rule on this field
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';  
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('TestProd1');
        product.name = 'TestProd1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product; 
        
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem();
        lineItem1.ServiceDate = opp.closedate + 50;
        lineItem1.UnitPrice=200;
        lineItem1.Quantity=3;
        lineItem1.Description='Test33';
        lineItem1.OpportunityId=opp.Id;
        lineItem1.ServiceDate= opp.closedate + 30;
        lineItem1.Pricebookentryid=pbet_id;
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=3;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.Pricebookentryid=pbet_id;
        lineItem2.ServiceDate= opp.closedate + 30;
        
        oppLineItems.add(lineItem2);
        
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
       Mn.Level_4__c='test000023311-test22-4';
       Mn.Is_Active_Internal__c=true;
        Mn.Product_Hierarchy_Code_2__c=product.id;
        insert Mn;
       
       // product.name='test000023311-test22-4';
      //  update product;
      
        
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch control =new GE_LGT_ProductsSearch(sc);
        GE_LGT_ProductsSearch.oliwrapper oW = new GE_LGT_ProductsSearch.oliwrapper(True,lineItem2);
        control.csvfile='OpptyProductMassUploadTemplate.csv';
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nABV101V571GV41BNW,93022645,10,100\n');
        control.ReadFile();
        try
        {
        control.nextcmd();
        control.prevcmd();
        control.flagrecordupsert=false;
        control.flagrecordupsert1=false;
        control.contentFile=Blob.valueOf('\n');
        control.contentFile=Blob.valueOf('Sep\nCATLogic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nABV101V571GV41BNW,,100\n');
        control.contentFile=Blob.valueOf('Sep\nCATLogic/Description;Product Code/SKU/Material #;Quantity;Sales Price per Unit\nABV101V571GV41BNW;;100\n');
        control.ReadFile();
        control.HeadCheck();
        control.validateCSV();
        }
        catch(exception e)
        {
        }
        control.selectedValueAtL1='test00-test22';
        control.setLevel2Value();
        control.selectedValueAtL2='test00012-test22';
        control.setLevel3Value();
        control.selectedValueAtL3='test000222-test22';
        control.setLevel4Value();
        control.next();
        control.previous();
        control.searchStr = 'T';
        control.searchProduct();
        control.productSearchList[0].IsActive=true;
        control.addLines();
        control.flag=True;
        control.addLines();
        control.keyword = '9';
        control.searchProductBySAPMatNumber();
        control.next();
        control.previous();
        control.addLinesforMMsearchresults();
        control.flag=True;
        control.flag=False;
        control.addLinesforMMsearchresults();
        control.flag=False;
        control.selectedValueAtL4='T';
        control.searchMMByLevel4();
        List<OpportunityLineItem> olilist=new List<OpportunityLineItem>();
        olilist.add(lineItem1);
        control.Opptyline1=olilist;
        control.addLines1();
        Test.stoptest();
    }
    static testMethod void ProductsSearchbulkinsertMaterialmasters()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
    
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = System.Today();
        opp.PO_Receipt_Date__c = System.Today();
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';  
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
        insert opp;
         system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(System.Today(), opp.PO_Receipt_Date__c);
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('TestProd1');
        product.name = 'Test Prod1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product; 
        
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbet_id,UnitPrice=40,ServiceDate = opp.PO_Receipt_Date__c + 50,quantity=5);
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2= new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=5;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.PO_Receipt_Date__c + 50;
        lineItem2.PricebookEntryId=pbet_id;
        oppLineItems.add(lineItem2);
        
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
        Mn.Level_4__c='test000023311-test22-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn;
        GE_LGT_EM_MaterialMaster__c Mn1 = TestDataUtil.createMaterialMaster('TEST123');
        Mn1.GE_LGT_EM_SAP_MaterialNumber__c ='93022645u';
        Mn1.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn1.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn1.Level_1__c='test00-test22-1'; 
        Mn1.Level_2__c='test00012-test22-2';
        Mn1.Level_3__c='test000222-test22-3'; 
        Mn1.Level_4__c='test000023311-test22-4';
        Mn1.Is_Active_Internal__c=true;
        insert Mn1;
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch control =new GE_LGT_ProductsSearch(sc);
        control.matMasListSearchresultNext=NULL;
        control.OppId=NULL;
        GE_LGT_ProductsSearch.OliWrapper w=new GE_LGT_ProductsSearch.OliWrapper(true,lineItem1);
        List<GE_LGT_ProductsSearch.OliWrapper> listTempWrapper = new List<GE_LGT_ProductsSearch.OliWrapper>();
        listTempWrapper.add(w);
        control.lstwrapper=listTempWrapper;
        control.deloli();
        control.csvfile='OpptyProductMassUploadTemplate.csv';
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nTest33,93022645,10,100,\n');

        control.contentFile=Blob.valueOf('\n');
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nABV101V571GV41BNW,93022645,10,20,\n');
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit,\nABV101V571GV41BNW,,10,20,\n'); 
        control.ReadFile();
        control.HeadCheck();
        control.validateCSV();

        Test.stoptest();
    }
    static testMethod void ProductsSearchMassuploadandWrapper()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        // INSERT ACCOUNT RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;

        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        Opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = System.Today();
        opp.PO_Receipt_Date__c = System.Today();
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';    
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(System.Today(), opp.PO_Receipt_Date__c);  
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('test');
        product.name = 'Test Prod1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product; 
        
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbet_id,UnitPrice=40,ServiceDate = opp.PO_Receipt_Date__c + 50,quantity=5);
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=5;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.PO_Receipt_Date__c + 50;
        lineItem2.PricebookEntryId=pbet_id;
        oppLineItems.add(lineItem2);
        
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
        Mn.Level_4__c='test000023311-test22-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn;

        //String s2 = 'Quarterly';
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch contr =new GE_LGT_ProductsSearch(sc);
        GE_LGT_ProductsSearch.oliwrapper oW = new GE_LGT_ProductsSearch.oliwrapper(True,lineItem2);
        contr.addLines();
        GE_LGT_ProductsSearch.OliWrapper w=new GE_LGT_ProductsSearch.OliWrapper(true,lineItem1);
        List<GE_LGT_ProductsSearch.OliWrapper> listTempWrapper = new List<GE_LGT_ProductsSearch.OliWrapper>();
        listTempWrapper.add(w);
        contr.lstwrapper=listTempWrapper;
        contr.Saveoli();
        contr.csvfile='OpptyProductMassUploadTemplate.csv';
        contr.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nTest33,93022645,10,100\n');
        contr.ReadFile();

        contr.csvfile='OpptyProductMassUploadTemplate.pdf';
        contr.contentFile=Blob.valueOf('\n');
        contr.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\n,93022645,,,\n');
        contr.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\n,,,,\n');
        contr.HeadCheck();
        contr.validateCSV();
        contr.ReadFile();
        Test.stoptest();
    }
    static testMethod void ProductsSearchbulkloptylineitems()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        // INSERT ACCOUNT RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        Opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = date.parse('3/10/2099');
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');//changed on 20 oct 20 for validation Rule on this field
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';    
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);  
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('test');
        product.name = 'Test Prod1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product; 
        
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbet_id,UnitPrice=40,ServiceDate = opp.PO_Receipt_Date__c + 50,quantity=5);
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2= new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=5;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.PO_Receipt_Date__c + 50;
        lineItem2.PricebookEntryId=pbet_id;
        oppLineItems.add(lineItem2);
        
        OpportunityLineItem lineItem3= new OpportunityLineItem();
        lineItem3.UnitPrice=10;
        lineItem3.Quantity=5;
        lineItem3.Description='Test33';
        lineItem3.OpportunityId=opp.Id;
        lineItem3.ServiceDate= opp.PO_Receipt_Date__c + 50;
        lineItem3.PricebookEntryId=pbet_id;
        oppLineItems.add(lineItem3);
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = new GE_LGT_EM_MaterialMaster__c();
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
        Mn.Level_4__c='test000023311-test22-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn;
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch contr =new GE_LGT_ProductsSearch(sc);
        contr.searchStr = 'Test Prod12';
        contr.searchProduct();
        contr.addLines();
        contr.addLines1();
        contr.Saveoli();
        contr.csvfile='OpptyProductMassUploadTemplate.csv';
        contr.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nTest33,93022645,10,100\n');
        contr.ReadFile();
        contr.csvfile='OpptyProductMassUploadTemplate.csv';
        contr.contentFile=Blob.valueOf('\n');
        contr.contentFile=Blob.valueOf('Sep\nCAT Logic/Description;ProductCode/SKU/Material #Quantityp,SalesPrice per Unit\null,93022645,20,20\n');
        contr.ReadFile();
        contr.HeadCheck();
        contr.validateCSV();
        Test.stoptest();
    }
    static testMethod void ProductsSearchbulkProducts()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = [select Id,GE_LGT_Business_Division__c from User where GE_LGT_Business_Division__c='Europe' and  isactive = true limit 1].id;
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        // INSERT ACCOUNT RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        Opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = system.today()+3;
        opp.PO_Receipt_Date__c = system.today()+3;
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(system.today()+3, opp.PO_Receipt_Date__c);
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('test');
        product.name = 'Test Prod1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product;

        List<Product2> prdList=new List<Product2>();
        for(Integer i=0;i<200;i++)
        {
            Product2 product1 = TestDataUtil.createProduct('Test Prod'+i);
            product1.Level_1__c = 'AUT - AUTOMOTIVE';
            product1.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
            product1.Level_3__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
            prdList.add(product1);
        }
        insert prdList;
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbet_id,UnitPrice=40,ServiceDate = opp.PO_Receipt_Date__c + 50,quantity=5);
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2= new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=5;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.PO_Receipt_Date__c + 50;
        lineItem2.PricebookEntryId=pbet_id;
        oppLineItems.add(lineItem2);
        
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='930226452345';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW2';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
        Mn.Level_4__c='test000023311-test22-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn;
        
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch control =new GE_LGT_ProductsSearch(sc);
        control.searchStr='T';
        control.searchProduct();
        control.nextcmd();
        control.lastcmd();
        control.prevcmd();
        control.firstcmd();
        control.nextc();
        control.prevc();
        control.addLines();
        PageReference savepage =control.savegtooppty();
        PageReference cancelpage =control.cancelprod();
        control.Saveoli();
        control.csvfile='OpptyProductMassUploadTemplate.csv';
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\nTest33,93,10,100\n');
        control.contentFile=Blob.valueOf('\n');
        control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description,Product Code/SKU/Material #,Quantity,Sales Price per Unit\n,930226452345,100,100\n');
        control.ReadFile();
        control.HeadCheck();
        control.validateCSV();

        Test.stoptest();
    }
    
    static testMethod void ProductsSearchmassuploadtest()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        

        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        Opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testtandrasai';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = date.parse('3/10/2099');
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');//Changed on 20 Oct 20 due to validation rule on this field
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
        insert opp;
        system.assertEquals('Testtandrasai', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);
        
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('test');
        product.name = 'Test Prod1';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product; 
        
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
        
        Test.startTest(); 
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbet_id,UnitPrice=40,ServiceDate = opp.PO_Receipt_Date__c + 50,quantity=5);
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=5;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.PO_Receipt_Date__c + 50;
        lineItem2.PricebookEntryId=pbet_id;
        oppLineItems.add(lineItem2);
        
        insert oppLineItems;
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22-1'; 
        Mn.Level_2__c='test00012-test22-2';
        Mn.Level_3__c='test000222-test22-3'; 
        Mn.Level_4__c='test000023311-test22-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn;
        Pagereference pref=Page.GE_LGT_ProductsSearch;
        pref.getParameters().Put('Id',Opp.Id);
        Test.setCurrentPage(pref);
        
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
        GE_LGT_ProductsSearch control =new GE_LGT_ProductsSearch(sc);
            control.csvfile='OpptyProductMassUploadTemplate.csv';
            control.contentFile=Blob.valueOf('\n');
            control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description;Product Code/SKU/Material #;Quantity;Sales Price per Unit\n;930226452345;50;100;5/10/2015\ntest;930226452345;50;100\n');
            control.ReadFile();
            control.HeadCheck();
            control.validateCSV(); 
            control.csvfile='OpptyProductMassUploadTemplate.csv';
            control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description;ProductCode/SKU/Material #;Quantity;SalesPrice per Unit\n;930226452345;50;100;5/10/2015\ntest;930226452345;50;100\n');
            control.ReadFile();
            control.HeadCheck();
            control.validateCSV();
            control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description1;ProductCode/SKU/Material #;Quantity1;SalesPrice per Unite\nnull;null;50;100\ntest;930226452345;50;100\nnull;6332558;50;100\ntestdecs;null;suan;100\nnull;null;t;u\nnull;null;u;i\n');
            control.csvfile=control.contentFile.toString(); 
            control.filelines= control.csvfile.split('\n');
            control.HeadCheck();
            control.validateCSV();  
            control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description;Product Code/SKU/Material #;Quantity;Sales Price per Unit\n;;50;100;5/10/2015\ntest;930226452345;50;100;5/10/2015\n');
            control.ReadFile();
            control.HeadCheck();
            control.validateCSV();
            control.contentFile=Blob.valueOf('Sep\nCAT Logic/Description1;Quantity1;SalesPrice per Unit\nnull;null;50;100\ntest;930226452345;50;100\nnull;6332558;50;100\ntest;6332558;suan;100\nnull;null;t;u5\ntest;6332558;u;i\n');
            control.csvfile=control.contentFile.toString(); 
            control.filelines= control.csvfile.split('\n');
            control.HeadCheck();
            control.validateCSV();
            control.delopptyid='jfhsddfsiodfjsdi';
            control.prdName='test';
            control.prdList1=new List<PricebookEntry>();

        Test.stoptest();
    }
    
    
    
}
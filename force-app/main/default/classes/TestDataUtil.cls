/*
Class Name - TestDataUtil 
Date - July-2016
Created By - Shyam Prasad Nayakula
Purpose - Used for creation of Test Data
*/
public class TestDataUtil 
{
    public static TriggerSwitch__c createTriggerSwitch(String name,Boolean flag)
    {
        TriggerSwitch__c triggerSwitch=new TriggerSwitch__c();
        triggerSwitch.name=name;
        triggerSwitch.isActive__c=flag;
        return triggerSwitch;
    }
    public static List<TriggerSwitch__c> insertTriggerSwitches()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.add(triggerSwitch2);
        TriggerSwitch__c triggerSwitch3=TestDataUtil.createTriggerSwitch('GE_LGT_OpptyBefInsBefUpdtAftIns',true);
        switchList.add(triggerSwitch3);
        TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',true);
        switchList.add(triggerSwitch4);
        TriggerSwitch__c triggerSwitch5=TestDataUtil.createTriggerSwitch('Update_Pricebook2ids',false);
        switchList.add(triggerSwitch5);
        TriggerSwitch__c triggerSwitch6=TestDataUtil.createTriggerSwitch('OppPusher',false);
        switchList.add(triggerSwitch6);
        TriggerSwitch__c triggerSwitch7=TestDataUtil.createTriggerSwitch('GE_LGT_AddOptyTeamFromAccOwner',false);
        switchList.add(triggerSwitch7);
        TriggerSwitch__c triggerSwitch8=TestDataUtil.createTriggerSwitch('GE_LGT_OpportunityInsertUpdateDelete',false);
        switchList.add(triggerSwitch8);
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_ShipDateShouldBeGTPODate',false);
        switchList.add(triggerSwitch9);
        TriggerSwitch__c triggerSwitch10=TestDataUtil.createTriggerSwitch('GE_LGT_Project_Triggers',true);
        switchList.add(triggerSwitch10);
        TriggerSwitch__c triggerSwitch11=TestDataUtil.createTriggerSwitch('GE_LGT_EM_OppProductHistory',true);
        switchList.add(triggerSwitch11);
        TriggerSwitch__c triggerSwitch12=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
        switchList.add(triggerSwitch12);
        TriggerSwitch__c triggerSwitch13=TestDataUtil.createTriggerSwitch('CaseTrigger',true);
        switchList.add(triggerSwitch13);
        return switchList;
    }
    public static Map<string,TriggerSwitch__c> insertTriggerSwitchesMAP()
    {
        Map<String,TriggerSwitch__c> switchList=new Map<String,TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.put('OrderTrigger',triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.put('GE_LGT_EM_AvoidDuplicateAccount',triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.put('GE_LGT_preventDuplicateAccount',triggerSwitch2);
        TriggerSwitch__c triggerSwitch3=TestDataUtil.createTriggerSwitch('GE_LGT_OpptyBefInsBefUpdtAftIns',true);
        switchList.put('GE_LGT_OpptyBefInsBefUpdtAftIns',triggerSwitch3);
        TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',true);
        switchList.put('OpportunityTrigger',triggerSwitch4);
        TriggerSwitch__c triggerSwitch5=TestDataUtil.createTriggerSwitch('Update_Pricebook2ids',true);
        switchList.put('Update_Pricebook2ids',triggerSwitch5);
        TriggerSwitch__c triggerSwitch6=TestDataUtil.createTriggerSwitch('OppPusher',true);
        switchList.put('OppPusher',triggerSwitch6);
        TriggerSwitch__c triggerSwitch7=TestDataUtil.createTriggerSwitch('GE_LGT_AddOptyTeamFromAccOwner',true);
        switchList.put('GE_LGT_AddOptyTeamFromAccOwner',triggerSwitch7);
        TriggerSwitch__c triggerSwitch8=TestDataUtil.createTriggerSwitch('GE_LGT_OpportunityInsertUpdateDelete',true);
        switchList.put('GE_LGT_OpportunityInsertUpdateDelete',triggerSwitch8);
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_ShipDateShouldBeGTPODate',true);
        switchList.put('GE_LGT_ShipDateShouldBeGTPODate',triggerSwitch9);
        TriggerSwitch__c triggerSwitch10=TestDataUtil.createTriggerSwitch('GE_LGT_Project_Triggers',true);
        switchList.put('GE_LGT_Project_Triggers',triggerSwitch10);
        TriggerSwitch__c triggerSwitch11=TestDataUtil.createTriggerSwitch('GE_LGT_EM_OppProductHistory',true);
        switchList.put('GE_LGT_EM_OppProductHistory',triggerSwitch11);
        TriggerSwitch__c triggerSwitch12=TestDataUtil.createTriggerSwitch('QuoteTrigger',true);
        switchList.put('QuoteTrigger',triggerSwitch12);
        TriggerSwitch__c triggerSwitch13=TestDataUtil.createTriggerSwitch('QuoteLineItemUpdate',true);
        switchList.put('QuoteLineItemUpdate',triggerSwitch13);
        TriggerSwitch__c triggerSwitch14=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
        switchList.put('AccountTrigger',triggerSwitch14);
        TriggerSwitch__c triggerSwitch15=TestDataUtil.createTriggerSwitch('CaseTrigger',true);
        switchList.put('CaseTrigger',triggerSwitch15);
        return switchList;
        
    }
    public static Account createAccount()
    {
        Account acc=new Account();
        acc.Name='Test Account';
        acc.BillingCountry='United States';
        acc.ShippingCountry='United States';
        acc.GE_LGT_Vertical__c='Finan';
        acc.GE_LGT_EM_Sales_Org__c='1HU1';
        acc.GE_LGT_EM_Partner_Function__c='Sold To Party';
        acc.CurrencyIsoCode='USD';
        //acc.RecordTypeId = 
        acc.GE_LGT_EM_SAP_Customer_Number__c='Test_And';
        acc.GE_LGT_EM_Distribution_Channel__c='10-Con';
        acc.GE_LGT_EM_Division__c='10-Fin';
        acc.GE_NAS_Language__c='English';        
        return acc;
    }
    public static Opportunity createOpportunity(Account acc)
    {
        Opportunity opp = new Opportunity();
        opp.Name = 'OpportunityTrigger';
        opp.GE_LGT_GE_Opportunity_Id__c='12EU34';
        opp.StageName = 'S1 Consult';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Distribution_Channel__c ='No';
        opp.Going_through_agent__c ='No';
        opp.CloseDate = System.Today() + 20;
        opp.PO_Receipt_Date__c = System.Today() + 20;
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 40;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 45;
        opp.Warranty__c = 'Standard Product Warranty';
        //opp.GE_LGT_Reason_Won_Lost__c='GE Brand';
        opp.GE_LGT_Reason_Won_Lost__c='Lost to Competitor'; //Since Rashmi's ticket on 2/22/2019 value inactivated and new validations listed
        opp.Competitor__c='Don’t know';
        
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        return opp;
    }
    public static PriceBook2 createPriceBook(String name)
    {
        PriceBook2 customPB=new PriceBook2();
        customPB.name=name;
        customPB.isActive=true;
        return customPB;
    }
    public static Product2 createProduct(String name)
    {
        Product2 prod=new Product2();
        prod.name=name;
        prod.IsActive=true;
        prod.Description='Test Product Entry 1';
        prod.CurrencyIsoCode='USD';
        prod.Product_Hierarchy_Code__c='testproduct345';
        prod.CanUseQuantitySchedule =true;
        prod.CanUseRevenueSchedule=true;
        prod.ProductCode ='testproduct1';
        prod.Product_Hierarchy_Code__c='testproduct12';
        return prod;
    }
    public static PricebookEntry createPriceBookEntry(String priceBookID,Product2 prodct)
    {
        PricebookEntry priceBookEntry=new PricebookEntry();
        priceBookEntry.Pricebook2Id=priceBookID;
        priceBookEntry.Product2Id=prodct.Id;
        priceBookEntry.UnitPrice = 100;
        priceBookEntry.UseStandardPrice=true;
        priceBookEntry.IsActive = true;
        return priceBookEntry;
    }
    public static OpportunityLineItem createOpportunityLineItem(Opportunity opp,PriceBookEntry pbe,decimal quty,decimal price)
    {
        OpportunityLineItem lineItem = new OpportunityLineItem();
        lineItem.OpportunityID=opp.id;
        lineItem.PriceBookEntryID=pbe.id;
        lineItem.UnitPrice=price;
        lineItem.quantity=quty;
        return lineItem;
    }
    public static GE_LGT_EM_MaterialMaster__c createMaterialMaster(String skuNum)
    {
        GE_LGT_EM_MaterialMaster__c matMaster=new GE_LGT_EM_MaterialMaster__c();
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c=skuNum;
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        matMaster.Level_1__c='IDL-INDUSTRIAL FIXTURES - LED-1';
        matMaster.Level_2__c='IDL100-HIGH BAY-2';
        matMaster.Level_3__c='IDL1001006-ABV1 UL-3';
        matMaster.Level_4__c='IDL1001006001-ABV1 UL 1 MODULE-4';
        matMaster.Level_5__c='IDL100100600100-IDL HIGH BAY ABV1 UL 1 MODULE-5';
        return matMaster;
    }
  
    public static Quote createQuote(String quoteNum,Opportunity opp)
    {
        Quote quote=new Quote();
        quote.Name=quoteNum;
        quote.SAP_Unique_Id__c='1230011644-2FR1-20-10-SP';
        quote.GE_Quote_Number__c=quoteNum;
        quote.Quote_created__c=Date.Today();
        quote.ExpirationDate=Date.today()+5;
        quote.GE_Opportunity_Id__c='12EU34';
        quote.OpportunityId=opp.Id;
        return quote;
    }
    public static QuoteLineItem createQuoteItem(String quoteNum,String quoteItemNum)
    {
        QuoteLineItem quoteItem=new QuoteLineItem();
        quoteItem.Quote_Number__c=quoteNum;
        quoteItem.Quote_Item_Number__c=quoteItemNum;
        quoteItem.SKU__c='93036710';
        quoteItem.SKU_Description_Cat_Logic__c='35-963370-15';
        quoteItem.UnitPrice=200;
        quoteItem.Quantity=500;
        quoteItem.Quote_Item_External_ID__c=quoteNum+quoteItemNum;
        return quoteItem;
    }
    public static Order createOrder(String orderNum)
    {
        Order order=new Order();
        order.GE_Order_NO__c=orderNum;
        order.status='Draft';
        order.EffectiveDate=Date.Today();
        order.CurrencyIsoCode='USD';
        order.Customer_PO_Number__c='215043';
        order.SAP_Unique_Id__c='1230011644-2FR1-20-10-SP';
        order.Strategic_SAPUniqueId__c='1230011644-2FR1-20-10-SP';
        order.Agent_SAPUniqueId__c='1230011644-2FR1-20-10-SP';        
        return order;
    }
    public static OrderItem createOrderItem(String orderNum,String orderItemNum)
    {
        OrderItem orderItem=new OrderItem();
        orderItem.Order_Number__c=orderNum;
        orderItem.Order_Line_Number__c=orderItemNum;
        orderItem.SKU__c='93036710';
        orderItem.SKU_Description_Cat_Logic__c='35-963370-15';
        orderItem.UnitPrice=200;
        orderItem.Quantity=500;
        orderItem.Ship_Qty__c=200;
        orderItem.Agreement_Quote__c='';     
        return orderItem;
    }
    public static Distributor__c createAccountsetup()
    {
        Distributor__c dstr_var=new Distributor__c();
        dstr_var.Customer_Legal_Name__c = 'Test Distributor-Neel';
        dstr_var.Billing_Address__c = 'Test Address by Neel';
        dstr_var.Billing_City__c = 'Test City by Neel';
        dstr_var.Billing_State__c = 'Test State by Neel';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test123.com';
        dstr_var.GE_Sales_Contact__c=UserInfo.getUserId();
        dstr_var.Status__c = 'Not Submitted';
        dstr_var.State_Province_1__c='Test';
        dstr_var.Counties_State_1__c='TestRecord';
        date myDate = date.today();
        dstr_var.Date_of_Visit_by_Account_Manager__c = myDate ;
        dstr_var.GE_Sales_Representative_Contact_Core__c =UserInfo.getUserId();
        dstr_var.GE_Sales_Representative_Core__c = 'test neel';//text
        dstr_var.Region_District_Core__c = 'test neel';//text
        dstr_var.GE_Sales_Rep_Contact_Solutions__c=UserInfo.getUserId(); //lookup to user
        dstr_var.GE_Sales_Rep_Solutions__c = 'test neel';//text
        dstr_var.Region_District_Solutions__c = 'test neel'; //text
        dstr_var.Estimated_Annual_Volume_in_Dollars__c = 123;
        dstr_var.Amount_of_First_Order__c=234;
        dstr_var.IFN_INDOOR_FIXTURE_NON_LED__c=true;
        return dstr_var;
    }
    public static Opportunity_Support_Request__c createOSR()
    {
        Opportunity_Support_Request__c osrequest=new Opportunity_Support_Request__c();
        osrequest.Status__c='Not Submitted';
        osrequest.EMEA_Order_logic__c='testlogic';  
        osrequest.use_cases__c='Test note';
        osrequest.Box_link__c='http:\\ge.com';
        osrequest.Comment_for_Legal_OSR__c='Test note';
        osrequest.Planned_duration_if_small_deployment__c='1 day';
        osrequest.Number_of_Fixtures__c=200;
        osrequest.Sub_Type__c='Agreement Request';
        osrequest.Sold_to_Account__c='Test A';
        osrequest.EMEA_Shipment_street__c='Test A';
        osrequest.EMEA_Shipment_City__c='Test A';
        osrequest.EMEA_Shipment_State_Province__c='Test A';
        osrequest.EMEA_Shipment_Zip_Postal_Code__c='Test A';
        osrequest.EMEA_Shipment_Country__c='Test A';
        osrequest.EMEA_Shipment_Mode__c='Standard';
        osrequest.Billing_address_is_same_as_shipping__c=True;
        osrequest.EMEA_Who_Pays_It__c='FOC';
        osrequest.GE_LGT_Quantity_of_Product__c=10;
        osrequest.EMEA_Required_Arrival_Date__c=System.Today() + 60;
        osrequest.Purpose__c='Internal Usage';
        osrequest.EMEA_Order_logic_Validation__c='xxxxxxxx';
        osrequest.EMEA_Generic_SKU__c='93011747 - OK L/1/SAMPLE';
        osrequest.EMEA_Billing_Street__c='Test A';
        osrequest.EMEA_Billing_City__c='Test A';
        osrequest.Billing_Zip_Postal_Code__c='Test A';
        osrequest.EMEA_Billing_Country__c='Test A';
        osrequest.EMEA_Product_line__c='Outdoor';
        
        return osrequest;
    }
    public static Contact createContact(Account acc)
    {
        Contact con = new Contact();
        con.LastName='Test AA';
        con.AccountId=acc.id;
        con.FirstName='Hello';
        con.Email='saikrishna@ge.com';
        con.Phone='8106131465';
        return con;
        
    }
    public static Fund_Request__c createFundRequest(Account acc)
    {
        Fund_Request__c FR_Obj = new Fund_Request__c();
        //FR_Obj.Bill_to_Name__c   = acc.Id;
        FR_Obj.Bill_To_Account_Number__c='1243';
        FR_Obj.District__c = 'East District';
        FR_Obj.Region__c = '310 Northeast';
        FR_Obj.Type_of_Reimbursement__c = 'Credit to Customers Account';
        FR_Obj.Event_Date__c =System.Today() + 3; // date type
        FR_Obj.Event_or_Promotion_Type__c = 'Advertising';
        FR_Obj.Event_or_Promotion_Description__c = 'Radio';
        FR_Obj.Specific_Event_Details__c='Test details';
        FR_Obj.Event_Goals__c='Sales';
        FR_Obj.Additional_Goal_information__c='Test Goal info';
        FR_Obj.Approval_Status__c='Not Submitted';
        FR_Obj.CurrencyISOCode='USD';
        FR_Obj.Pay_To__c='123';
        //FR_Obj.RecordTypeId = '0123j000000X8yIAAS';
        
        return FR_Obj;
        
    }
    public static Attachment createAttachment(string name,blob b,id parentid)
    {
        Attachment attachment = new Attachment();
        attachment.ParentId = parentid;   
        attachment.Name = name;   
        attachment.Body = b;
        return attachment;
        
    }
    public static Task createtask()
    {
        Task t=new Task();
        t.GE_LGT_EM_Case_Status__c='In Progress';
        t.Description='Description for Test Class';       
        t.GE_LGT_EM_Call_Reason__c='Enquiry - Price&Stock';
        t.Type='Call - Inbound';
        t.Subject='Call - Inbound:8106131465'; 
        //t.WhoId=con.id; 
        return t;
    }
    public static Sample__c createSample(Opportunity opp)
    {
        Sample__c sam = new Sample__c();
        sam.Opportunity__c = opp.ID;
        sam.Bill_To_Same_as_Ship_To__c = true;
        sam.Quote_Order_Number__c='1232123';
        return sam;
    }
    public static Case createCase(Account acc)
    {
        Case case1=new Case();
        case1.Accountid=acc.ID;
        case1.Subject='TEST1';
        case1.Type='Account Management';
        case1.GE_NAS_Invoice__c='836999';
        case1.GE_NAS_SR_Number__c='12345';
        case1.GE_NAS_Sub_Type__c='CPRD Maintenance';
        case1.Priority='Medium';
        case1.Status='Open';
        return case1;
    }
    public static user createUser(id profileid,string email)
    { 
        user testuser=new user();
        testuser.ProfileId=profileid;
        testuser.Alias = 'standt';
        testuser.GE_NAS_IBMID__c='LIDPTUT';
        testuser.Email=email;
        testuser.EmailEncodingKey='UTF-8';
        testuser.LastName='Testing';
        testuser.LanguageLocaleKey='en_US';
        testuser.LocaleSidKey='en_US';
        testuser.TimeZoneSidKey='America/Los_Angeles';
        testuser.UserName='standarduse1@testorg.com';
        
        return testuser;
    } 
    
    public static SAP_Records_Recycle__c createsrr()
    {
        SAP_Records_Recycle__c d = New SAP_Records_Recycle__c();
        d.GE_LGT_EM_SAP_Customer_Number__c = '8106131465';
        d.GE_LGT_EM_Distribution_Channel__c ='10-Consumer';
        d.GE_LGT_EM_Division__c ='10-Finished Products';
        //d.GE_LGT_EM_PF_Type__c ='Z8';
        d.GE_LGT_EM_Sales_Org__c ='1CA1';
        return d;
    }
    
    public static Distributor__c createDistributor(String recTypeID)
    {
        Distributor__c distributor = new Distributor__c(RecordTypeId=recTypeID);
        distributor.Customer_Legal_Name__c = 'Test Distributor';
        distributor.Billing_Address__c = 'Test Address ';
        distributor.Billing_City__c = 'Test City';
        distributor.Billing_State__c = 'Test State';
        distributor.Billing_Postal_Code__c = '11111';
        distributor.Billing_Contact_Name__c = 'Test Contact';
        distributor.Billing_Contact_Phone__c = '23456' ;
        distributor.Billing_Contact_Email__c = 'test@test123.com';
        distributor.GE_Sales_Contact__c=UserInfo.getUserId();
        distributor.Status__c = 'test';
        distributor.Mail_To_Same_as_Bill_To__c = true;
        distributor.Shipping_Information_Same_as_Bi__c=true;
        distributor.Core_choose_all_that_apply__c='Sensors'; //multi-select picklist
        distributor.Solutions_choose_all_that_apply__c='Traffic Products'; ////multi-select picklist
        distributor.Requested_Terms__c = 'Standard';  
        distributor.Estimated_Annual_Volume_in_Dollars__c = 123;
        distributor.Amount_of_First_Order__c=234;
        distributor.Does_Customer_Have_EDI_Capability__c='Yes';
        distributor.Customer_On_Electronic_Funds_Tra__c = 'No';
        distributor.Is_the_Customer_Tax_Exempt__c='No';
        distributor.Equipped_to_Handle_GE_Product__c = 'Yes';
        distributor.Date_of_Visit_by_Account_Manager__c = Date.today() ;
        distributor.GE_Sales_Representative_Contact_Core__c  =UserInfo.getUserId();
        distributor.GE_Sales_Representative_Core__c = 'test';
        distributor.Region_District_Core__c = 'test neel';
        distributor.GE_Sales_Rep_Contact_Solutions__c= UserInfo.getUserId();
        distributor.GE_Sales_Rep_Solutions__c = 'test';
        distributor.Region_District_Solutions__c = 'test';
        distributor.Account_Released__c=False;
        distributor.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        return distributor;
    }
    
    public static SAP_Price_Agreement__c createPriceAgreement(String aggrementNum,String GEOppNum)
    {
        SAP_Price_Agreement__c agreement = new SAP_Price_Agreement__c();
        agreement.Name = aggrementNum;
        //agreement.SAP_External_ID__c = aggrementNum;
        agreement.GE_Opportunity_No__c = GEOppNum;
        agreement.Expiration_Date__c = Date.today()+10;
        agreement.Last_Modified_DateTime__c = DateTime.now();
        return agreement;
    }
    
    public static SAP_Price_Agreement_Item__c createPriceAgreementItem(SAP_Price_Agreement__c aggrement,String materialNum)
    {
        SAP_Price_Agreement_Item__c agreementItem = new SAP_Price_Agreement_Item__c();
        agreementItem.Name = materialNum;
        agreementItem.Agreement_No__c = aggrement.Name;
        agreementItem.Material_No__c = materialNum;
        // agreementItem.List_Price__c = 20;
        agreementItem.Quantity__c = 20;
        // agreementItem.SAP_External_ID__c = aggrement.Name+materialNum;
        agreementItem.Last_Modified_DateTime__c = DateTime.Now();
        return agreementItem;
    }
    
}
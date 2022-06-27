@isTest
public class OpptyProductOSR_Test
{
    //Rashmitha Changed the API vesion from 36 to 45 on 6-Mar-2019 as per 1447 request
    static testMethod void ProductsSearch()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        
        insert triggerSwitches.values();
        
        TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
        insert OSRtriggerSwitch;
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID recOSRTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Opportunity_Support_Request__c' 
                           AND NAME='EMEA Risk buy'].ID;
        
        // INSERT ACCOUNT RECORD
        Account acc = new Account(RecordTypeId = recAccTypeId,Name='Test Acc4',GE_LGT_EM_Sales_Org__c='1CA1',GE_LGT_EM_Partner_Function__c='Sold To Party',CurrencyIsoCode='USD',billingcountry='canada',GE_LGT_EM_SAP_Customer_Number__c='Test_Ta45',GE_LGT_EM_Distribution_Channel__c='10-Con',GE_NAS_Language__c='English');
        //Account acc = new Account(RecordTypeId = recAccTypeId,Name='Test Acc4', GE_LGT_EM_Partner_Function__c='Sold To Party',CurrencyIsoCode='USD',billingcountry='canada',GE_LGT_EM_SAP_Customer_Number__c='TestSai_Ta45',/*GE_LGT_EM_Distribution_Channel__c='10-Consumer',*/GE_NAS_Language__c='English');//GE_LGT_EM_Division__c='10-Finished Products',
        insert acc;
        
        // INSERT CONTACT RECORD
        Contact con = new Contact(LastName='Test Con15',FirstName='FirstName1', Email='Saikrishna.tandra@ge.com',AccountId=acc.ID,OwnerID=userID);
        insert con;
        
        // INSERT OPPTY RECORD
        Opportunity opp = new Opportunity(RecordTypeId = recOppTypeId);
        opp.Name = 'Testtandrasai';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate =System.Today() + 2;
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';      
        insert opp;
        
        // Create a new product 
        Product2 product = new Product2();
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
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbet_id,UnitPrice=40,ServiceDate = opp.closedate + 50,quantity=5);
        List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
        oppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2= new OpportunityLineItem();
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=5;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.closedate + 50;
        lineItem2.PricebookEntryId=pbet_id;
        oppLineItems.add(lineItem2);
        
        insert oppLineItems;
        
        Opportunity_Support_Request__c osrequest = new Opportunity_Support_Request__c(RecordTypeId = recOSRTypeID);
        osrequest.Status__c='Not Submitted';
        osrequest.Opportunity_Name__c=opp.id;
        osrequest.Risk_by_valid_to__c=System.Today() + 60;
        insert osrequest;
        PageReference pageRef = Page.OpptyProducts_for_OSR;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(osrequest);       
        ApexPages.currentPage().getParameters().put('Id',osrequest.id);
        system.debug('&&&&id' + osrequest.id);
        OpptyProductOSR il=new OpptyProductOSR(sc);
        il.saveAll();
        Test.stoptest();
    }
}
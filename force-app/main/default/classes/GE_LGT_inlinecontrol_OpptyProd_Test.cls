@isTest
public class GE_LGT_inlinecontrol_OpptyProd_Test {
static testMethod void inlinecontrolTest() {
   TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
        insert OSRtriggerSwitch;
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID recOSRTypeID = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Custom Product Request').getRecordTypeId();

        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = date.parse('3/10/2099');// changed the closed date too based on PO receipt dates
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');// Changed the date due to validation rule on 20 oct 2020
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';      
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);
        

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
        OpportunityLineItem lineItem = new OpportunityLineItem();
        lineItem.ServiceDate = opp.closedate + 50;
        lineItem.UnitPrice=200;
        lineItem.Quantity=3;
        lineItem.Description='Test33';
        lineItem.Pricebookentryid=pbet_id;
        lineItem.OpportunityId=opp.Id;
        lineItem.ServiceDate= opp.closedate + 30;
        oppLineItems.add(lineItem);
        
        OpportunityLineItem lineIt = new OpportunityLineItem();
        lineIt.UnitPrice=200;
        lineIt.Quantity=6;
        lineIt.Description='Test33';
        lineIt.OpportunityId=opp.Id;
        lineIt.ServiceDate= opp.closedate + 30;
        lineIt.Pricebookentryid=pbet_id;
        oppLineItems.add(lineIt);
        insert oppLineItems;
        list<OpportunityLineItem> OpportunityLineitemlist = [select id,OpportunityId,Pricebookentryid,UnitPrice,Quantity from OpportunityLineItem where Opportunityid=:opp.id];
        
        system.assertequals(2,OpportunityLineitemlist.size());
        
        system.assertequals(pbet_id,OpportunityLineitemlist[0].Pricebookentryid);
        
        system.assertequals(200,OpportunityLineitemlist[0].UnitPrice);
        
        //system.assertequals(3,OpportunityLineitemlist[0].Quantity);
        
        PageReference pageRef = Page.GE_LGT_inlinecontrol_OpptyProd;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(opp);       
        ApexPages.currentPage().getParameters().put('Id',opp.id);
        GE_LGT_inlinecontrol_OpptyProd il=new GE_LGT_inlinecontrol_OpptyProd(sc);  
        Test.stopTest(); 
 
    }
    }
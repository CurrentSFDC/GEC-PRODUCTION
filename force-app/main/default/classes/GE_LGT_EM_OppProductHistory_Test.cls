@istest(seealldata=true)
public class GE_LGT_EM_OppProductHistory_Test {
   static testMethod void OppProductHistory()
    {
        ID userID = UserInfo.getUserID();
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        // INSERT ACCOUTN RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
      
        Account accnt=TestDataUtil.createAccount();
        accnt.RecordTypeId = recAccTypeID;
        insert accnt;
      
        // INSERT CONTACT RECORD
        Contact ct= TestDataUtil.createContact(acc);
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct;
            
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        Opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testtandrasai';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.CloseDate = System.Today() + 3;
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';
        opp.LED_Content__c = 'Partially LED';
        insert opp;
        
        // Create a new product 
        Product2 product = TestDataUtil.createProduct('tandrasai');
        product.name = 'Test Prod72';
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
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22'; 
        Mn.Level_2__c='test00012-test22';
        Mn.Level_3__c='test000222-test22'; 
        Mn.Level_4__c='test000023311-test22';
        insert Mn;
        
        PriceBookEntry pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1];
        
        List<OpportunityLineItem> opptyList=new List<OpportunityLineItem>();
        
        OpportunityLineItem lineItem1 = TestDataUtil.createOpportunityLineItem(opp,pbet_id,10.00,100.00);
        
        lineItem1.ServiceDate = opp.closedate + 50;
        opptyList.add(lineItem1);
        Test.starttest();
        OpportunityLineItem lineItem2= TestDataUtil.createOpportunityLineItem(opp,pbet_id,3,200);
        lineItem2.UnitPrice=200;
        lineItem2.Quantity=3;
        lineItem2.Description='Test33';
        lineItem2.OpportunityId=opp.Id;
        lineItem2.ServiceDate= opp.closedate + 30;
        opptyList.add(lineItem2);
        insert opptyList;
        
        OpportunityLineItemSchedule lis=new OpportunityLineItemSchedule(OpportunityLineItemId=lineItem2.id,Quantity=5,Revenue=50,ScheduleDate=System.Today() + 3,Type='Both');
        insert lis; 
        
        delete opp;
        
        
    } 

}
@isTest(seeAllData=true)
private class GE_LGT_inlinecontrol_Test {
    //Rashmitha Changed the API vesion from 33 to 45 on 6-Mar-2019 as per 1447 request
    static testMethod void inlinecontrol()
    {
     ID userID = UserInfo.getUserID();
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        ID recOSRTypeID = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Custom Product Request').getRecordTypeId();

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
       
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 45;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 30;
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
        
        PricebookEntry pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1];
        
        List<OpportunityLineItem> opptyList=new List<OpportunityLineItem>();
        
        OpportunityLineItem lineItem1 = TestDataUtil.createOpportunityLineItem(opp,pbet_id,10,100);
      
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
       // Insert OSR
       Opportunity_Support_Request__c osrequest = TestDataUtil.createOSR();
       osrequest.RecordTypeId = recOSRTypeID;
       osrequest.GE_LGT_Indoor_Product_Category__c='Recessed/Surface Mount';
       osrequest.GE_LGT_Prototype_Required__c='Yes';
       osrequest.GE_LGT_Sample_Required__c='Yes';
       osrequest.Status__c='Not Submitted';
       osrequest.GE_LGT_Product__c='Controls';
       osrequest.Opportunity_Name__c=opp.id;
       osrequest.GE_LGT_Delivery_Time_for_1st_Product__c=date.parse('4/11/2015');
       osrequest.GE_LGT_Indoor_Product_Category__c='Others';
       osrequest.GE_LGT_Sample_Needed_By__c=date.parse('4/11/2015');
       osrequest.GE_LGT_Prototype_Need_By__c=date.parse('4/11/2015');
      
       insert osrequest;
       PageReference pageRef = Page.GE_LGT_inlinecontrol;
       Test.setCurrentPage(pageRef);
       ApexPages.StandardController sc = new ApexPages.standardController(osrequest);       
       ApexPages.currentPage().getParameters().put('Id',osrequest.id);
       system.debug('&&&&id' + osrequest.id);
       GE_LGT_inlinecontrol il=new GE_LGT_inlinecontrol(sc);
    }
    
    
    }
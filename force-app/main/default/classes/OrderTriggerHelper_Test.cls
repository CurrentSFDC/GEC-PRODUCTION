/*
Name - OrderTriggerHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Test Class
Date - May-2016
*/
@isTest
public class OrderTriggerHelper_Test 
{
    static testmethod void method1()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
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
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch9);
        insert switchList;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        //setting up test running user as changing EffectiveDate only allowed to this profile
        Profile intUser = [ select id from Profile where Name LIKE 'Integration U%' limit 1 ];

        string randomName = string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','');
        
        User testUser1 = new User();
        testUser1.ProfileId = intUser.id;
        testUser1.GE_LGT_Business_Division__c = 'NA';
        testUser1.Alias = 'test1';
        testUser1.Email = 'testUserOne@test.com';
        testUser1.EmailEncodingKey = 'UTF-8';
        testUser1.LastName = 'TestingOrder';
        testUser1.LanguageLocaleKey = 'en_US';
        testUser1.LocaleSidKey = 'en_US';
        testUser1.TimeZoneSidKey = 'America/Los_Angeles';
        testUser1.UserName = randomname + '1@test.com';
        insert testUser1;
        System.runAs(testUser1) {
            //creating Account
            Account acc=TestDataUtil.createAccount();
            acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
            acc.recordtypeid=recAccTypeID;
            insert acc;
            Account Assertacc=[select id from Account where id=:acc.id limit 1];
            system.assert(Assertacc.id!=null);
            Opportunity opp=TestDataUtil.createOpportunity(acc);
            opp.recordtypeid=recOppTypeID;
            insert opp;
            Opportunity Assertopp=[select id from Opportunity where id=:opp.id limit 1];
            system.assert(Assertopp.id!=null);
            //checking Estimated order created automatically Or not?
            Order order=TestDataUtil.createOrder('9999');
            order.GE_Opportunity_Id__c='EU1234';
            order.accountId=acc.id;
            order.EffectiveDate=date.valueof(Datetime.now()-30);
            insert order;
            
            Test.startTest(); // this is testing if only GE Oppty ID changes
            order.GE_Opportunity_Id__c='12EU34';
            update order;
            Order asertorder=[select id,Opportunityid,accountid,GE_Order_NO__c from order where id=:order.id];
    
            // this is testing if only EffectiveDate changes
            order.EffectiveDate=date.valueof(Datetime.now()-10);
            update order;
            Order asertorder2=[select id,Opportunityid,accountid,GE_Order_NO__c from order where id=:order.id];
    
            system.assertEquals(acc.id, asertorder.accountid);                
            system.assertEquals(acc.id, asertorder2.accountid);
            system.assertEquals('9999', order.GE_Order_NO__c);
            Test.stopTest();
            }
        }
    static testmethod void method2()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
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
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch9);
        insert switchList;
        //insert switchList;
        
        NA_Profiles__c NAProfile=new NA_Profiles__c();
        NAProfile.Name=UserInfo.getProfileId();
        insert NAProfile;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        Account Assertacc=[select id from Account where id=:acc.id limit 1];
        system.assert(Assertacc.id!=null);
        //creating Opportunity
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.recordtypeid=recOppTypeID;
        insert opp;
        Opportunity Assertopp=[select id from Opportunity where id=:opp.id limit 1];
        system.assert(Assertopp.id!=null);
        
        Order order=TestDataUtil.createOrder('9999');
        order.GE_Opportunity_Id__c='EU34';
        order.accountid=acc.id;
        insert order;
        Test.startTest();
        order.GE_Opportunity_Id__c='12EU34';
        order.OpportunityId=opp.ID;
        order.Order_Amount__c=100;
        update order;
        Order asertorder=[select id,Opportunityid,accountid,GE_Order_NO__c from order where id=:order.id];
        system.assertEquals(opp.id, asertorder.Opportunityid);
        system.assertEquals(acc.id, asertorder.accountid);
        system.assertEquals('9999', order.GE_Order_NO__c);
        Test.stopTest();
    }
    static testmethod void method3()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
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
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch9);
        insert switchList;
        //insert switchList;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-15';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        Account Assertacc=[select id from Account where id=:acc.id limit 1];
        system.assert(Assertacc.id!=null);
        //creating Opportunity
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.recordtypeid=recOppTypeID;
        insert opp;
        Opportunity Assertopp=[select id from Opportunity where id=:opp.id limit 1];
        system.assert(Assertopp.id!=null);
        Id estimatedOrderID = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        Order order=TestDataUtil.createOrder('9999');
        order.GE_Opportunity_Id__c='EU1234';
        order.RecordTypeID=estimatedOrderID;
        order.SAP_Unique_Id__c='';
        order.PO_Received__c=True;
        order.AccountId=acc.ID;
        insert order;
        Test.startTest();
        try{
        order.GE_Opportunity_Id__c='12EU34';
        update order;
        }
        catch(exception e){}
        Opportunity assertOpty=[select id,closedate,PO_Receipt_Date__c from Opportunity where id=:opp.id];
        system.assertNOtEquals(order.EffectiveDate, assertOpty.PO_Receipt_Date__c);
        Test.stopTest();
    }
    static testmethod void method4()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
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
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch9);
        insert switchList;
        
        Profile objProfile = [Select Id, Name from Profile where Name =: 'EUROPE Current Super User' limit 1];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='newusergetest1@testorg.com',GE_LGT_Business_Division__c='Europe',GE_LGT_Region__c='Europe Functional',GE_LGT_Sub_Region__c='Europe Operations');
        insert u2;
        
        EMEAProfiles__c EMEAProfile=new EMEAProfiles__c();
        EMEAProfile.Name=objProfile.ID;
        insert EMEAProfile;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        Account Assertacc=[select id from Account where id=:acc.id limit 1];
        system.assert(Assertacc.id!=null);
        //creating Opportunity
        System.runAs(u2) 
        {
            Opportunity opp=TestDataUtil.createOpportunity(acc);
            opp.recordtypeid=recOppTypeID;
            insert opp;
            Opportunity Assertopp=[select id from Opportunity where id=:opp.id limit 1];
            system.assert(Assertopp.id!=null);
            Order order=TestDataUtil.createOrder('9999');
            order.accountid=acc.id;
            order.GE_Opportunity_Id__c='EU34';
            insert order;
            Test.startTest();
            order.GE_Opportunity_Id__c='12EU34';
            order.OpportunityId=opp.ID;
            update order;
            Order asertorder=[select id,Opportunityid,accountid,GE_Order_NO__c from order where id=:order.id];
            system.assertEquals(opp.id, asertorder.Opportunityid);
            system.assertEquals(acc.id, asertorder.accountid);
            system.assertEquals('9999', order.GE_Order_NO__c);
            Test.stopTest();
        }
    }
    static testmethod void method5()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
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
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch9);
        insert switchList;
        
        NA_Profiles__c NAProfile=new NA_Profiles__c();
        NAProfile.Name=UserInfo.getProfileId();
        insert NAProfile;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        Account Assertacc=[select id from Account where id=:acc.id limit 1];
        system.assert(Assertacc.id!=null);
        //creating Opportunity
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.recordtypeid=recOppTypeID;
        insert opp;
        Opportunity Assertopp=[select id from Opportunity where id=:opp.id limit 1];
        system.assert(Assertopp.id!=null);
        
        StaticvariablesForOrder.OrderOwnerChangeIfOptyOwnerChange=true;
        Order order=TestDataUtil.createOrder('99999');
        order.RecordTypeid=Schema.SObjectType.order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        order.SAP_Unique_Id__c=null;
        order.Customer_PO_Number__c=null;
        order.SAP_Unique_Id__c=null;
        order.Strategic_SAPUniqueId__c=null;
        order.Agent_SAPUniqueId__c=null;
        order.Agent_SAPUniqueId__c=null;
        order.Forecast__c='Stretch';
        order.Order_Amount__c=10000;
        order.Accountid=acc.id;
        order.Opportunityid=opp.id;
        insert order;
        
        Test.startTest();
        order.GE_Opportunity_Id__c='12EU34';
        order.OpportunityId=opp.ID;
        update order;
        list<order> testorder=[select id,EffectiveDate from Order  order by EffectiveDate Desc limit 1];
        Opportunity assertOpty=[select id,closedate,PO_Receipt_Date__c,Total_Order_Amount__c from Opportunity where id=:opp.id];
        system.assertEquals(testorder[0].EffectiveDate, assertOpty.PO_Receipt_Date__c);
        system.assertEquals(order.Order_Amount__c, assertOpty.Total_Order_Amount__c);
        Test.stopTest();
    }
    static testmethod void method6()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
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
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch9);
        insert switchList;
        Profile objProfile = [Select Id, Name from Profile where Name =: 'EUROPE Current Super User' limit 1];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='newusergetest1@testorg.com',GE_LGT_Business_Division__c='Europe',GE_LGT_Region__c='Europe Functional',GE_LGT_Sub_Region__c='Europe Operations');
        insert u2;
        
        EMEAProfiles__c EMEAProfile=new EMEAProfiles__c();
        EMEAProfile.Name=objProfile.ID;
        insert EMEAProfile;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        Account Assertacc=[select id from Account where id=:acc.id limit 1];
        system.assert(Assertacc.id!=null);
        //creating Opportunity
        System.runAs(u2) 
        {
            Opportunity opp=TestDataUtil.createOpportunity(acc);
            opp.recordtypeid=recOppTypeID;
            insert opp;
            Opportunity Assertopp=[select id from Opportunity where id=:opp.id limit 1];
            system.assert(Assertopp.id!=null);
            StaticvariablesForOrder.OrderOwnerChangeIfOptyOwnerChange=true;
            Order order=TestDataUtil.createOrder('99999');
            order.RecordTypeid=Schema.SObjectType.order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
            order.SAP_Unique_Id__c=null;
            order.Customer_PO_Number__c=null;
            order.SAP_Unique_Id__c=null;
            order.Strategic_SAPUniqueId__c=null;
            order.Agent_SAPUniqueId__c=null;
            order.Agent_SAPUniqueId__c=null;
            order.Forecast__c='Stretch';
            order.Order_Amount__c=10000;
            order.Accountid=acc.id;
            order.Opportunityid=opp.id;
            order.EffectiveDate=Date.today()+10;
            Order saporder=TestDataUtil.createOrder('10000');
            saporder.Accountid=acc.id;
            saporder.RecordTypeid=Schema.SObjectType.order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
            list<order>  insertOrders=new list<Order>();
            insertOrders.add(order);
            insertOrders.add(saporder);
            insert insertOrders;
            Test.startTest();
            order.GE_Opportunity_Id__c='12EU34';
            order.OpportunityId=opp.ID;
            order.EffectiveDate=Date.today()+18;
            update order;
            saporder.currencyISOCode='EUR';
            update saporder;
            order assertOrder=[select id,currencyISOCode from Order where id=:saporder.id];
            system.assertEquals(assertOrder.currencyISOCode, 'USD');
            list<order> testorder=[select id,EffectiveDate from Order order by EffectiveDate Desc limit 1];
            testorder[0].EffectiveDate=Date.today()+40;
            update  testorder[0];
            Opportunity assertOpty=[select id,closedate,PO_Receipt_Date__c,Total_Order_Amount__c from Opportunity where id=:opp.id];
            system.assertEquals(testorder[0].EffectiveDate, assertOpty.PO_Receipt_Date__c);
            system.assertEquals(order.Order_Amount__c, assertOpty.Total_Order_Amount__c);
            delete order;
            Test.stopTest();
        }
    }
    
}
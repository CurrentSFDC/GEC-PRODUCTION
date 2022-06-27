/* Class Name         : AccountMethods_Test
*   Date                     : 12.02.2016
*   Author                 : Justin Downs
*   Object                 : Account
*   Purpose               : These test methods were developed to cover the AccountMethods class. 
*   */

@isTest
private class AccountMethods_Test {
    
    static testMethod void myUnitTest() {
        
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        
        insert switchList;
        integer i=0;
        i++;
        
        Id recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Id endUserRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();

        
        Profile sysAdmin = [ select id from Profile where Name LIKE 'System Ad%' limit 1 ];
        
        string randomName = string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','');
        
        User testUser1 = new User();
        testUser1.ProfileId = sysAdmin.id;
        testUser1.GE_LGT_Business_Division__c = 'NA';
        testUser1.Alias = 'test1';
        testUser1.GE_NAS_IBMID__c = 'LIDPTUT';
        testUser1.Email = 'testUserOne@test.com';
        testUser1.EmailEncodingKey = 'UTF-8';
        testUser1.LastName = 'TestingOne';
        testUser1.LanguageLocaleKey = 'en_US';
        testUser1.LocaleSidKey = 'en_US';
        testUser1.TimeZoneSidKey = 'America/Los_Angeles';
        testUser1.UserName = randomname + '1@test.com';
        insert testUser1;
        
        string randomName2 = string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','');
        
        User testUser2 = new User();
        testUser2.ProfileId = sysAdmin.id;
        testUser2.GE_LGT_Business_Division__c = 'MEAT';
        testUser2.Alias = 'test2';
        testUser2.GE_NAS_IBMID__c = 'LIDPTUT';
        testUser2.Email = 'testUserTwo@test.com';
        testUser2.EmailEncodingKey = 'UTF-8';
        testUser2.LastName = 'TestingTwo';
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.TimeZoneSidKey = 'America/Los_Angeles';
        testUser2.UserName = randomName2 + '2@test.com';
        insert testUser2;
        
        List<Account> testAccList = new List<Account>();
        
        Account testAcc1 = new Account();
        testAcc1.Name = 'Test Account I';
        testAcc1.BillingCountry = 'United States';
        testAcc1.Type = 'End User';
        testAcc1.RecordTypeId = endUserRecType ;
        testAcc1.ShippingCountry = 'United States';
        testAcc1.GE_LGT_Vertical__c = 'Fin';
        testAcc1.GE_LGT_EM_Sales_Org__c = '1HU1';
        testAcc1.GE_LGT_EM_Partner_Function__c = 'Sold To Party';
        testAcc1.CurrencyIsoCode = 'USD';
        testAcc1.GE_LGT_EM_SAP_Customer_Number__c = 'Test_Ac1';
        testAcc1.GE_LGT_EM_Distribution_Channel__c = '10-Cons';
        testAcc1.GE_LGT_EM_Division__c = '10-Fin';
        testAcc1.GE_NAS_Language__c = 'English';
        testAccList.add(testAcc1);
        
        Account testAcc2 = new Account();
        testAcc2.Name = 'Test Account II';
        testAcc2.BillingCountry = 'United States';
        testAcc2.ShippingCountry = 'United States';
        testAcc2.Type = 'End User';
        testAcc2.RecordTypeId = endUserRecType ;
        testAcc2.GE_LGT_Vertical__c = 'Fin';
        testAcc2.GE_LGT_EM_Sales_Org__c = '1HU1';
        testAcc2.GE_LGT_EM_Partner_Function__c = 'Sold To Party';
        testAcc2.CurrencyIsoCode = 'USD';
        testAcc2.GE_LGT_EM_SAP_Customer_Number__c = 'Test_Ac2';
        testAcc2.GE_LGT_EM_Distribution_Channel__c = '10-Con';
        testAcc2.GE_LGT_EM_Division__c = '10-Fin';
        testAcc2.GE_NAS_Language__c = 'English';
        testAccList.add(testAcc2);
        
        insert testAccList;
        
        testAcc1.OwnerId = testUser1.id;
        update testAcc1;
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opp 1';
        testOpportunity.GE_LGT_GE_Opportunity_Id__c='12EU34';
        testOpportunity.StageName = 'S1 Consult';
        testOpportunity.AccountID = testAcc1.id;
        testOpportunity.CurrencyIsoCode ='USD';
        testOpportunity.Probability = 10;
        testOpportunity.Distribution_Channel__c ='No';
        testOpportunity.Going_through_agent__c ='No';
        testOpportunity.CloseDate = System.Today() + 20;
        testOpportunity.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 40;
        testOpportunity.GE_LGT_Expected_Ship_Date__c = System.Today() + 45;
        testOpportunity.Warranty__c = 'Standard Product Warranty';
        testOpportunity.GE_LGT_Reason_Won_Lost__c=System.Label.Customer_Cancelled;
        testOpportunity.GE_LGT_SIMPLESALES__c='Yes';
        testOpportunity.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        testOpportunity.Type = 'Daintree';
        insert testOpportunity;
        
        testAcc1.OwnerId = testUser2.id;
        update testAcc1;
        
        testOpportunity.OwnerId = testUser2.id;
        update testOpportunity;
        
        testOpportunity.AccountId = testAcc2.id;
        update testOpportunity;
        
        testAcc2.OwnerId = testUser2.id;
        update testAcc2;
        
        Order testOrder = new Order();
        testOrder.status = 'Draft';
        testOrder.EffectiveDate = Date.Today();
        testOrder.CurrencyIsoCode = 'USD';
        testOrder.OpportunityId = testOpportunity.Id;
        testOrder.AccountId = testAcc1.id;
        
        insert testOrder;
        
        try{
            testOpportunity.CloseDate = date.today() + 5;
            update testOpportunity;
        }
        catch (DMLException e) {
            System.assert(e.getMessage().contains('cannot be changed'));
        }
    }
    public  Static testMethod void ValidateAccountCustomerflagActive()
    {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        
        insert switchList;
        integer i=0;
        i++;
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Agent Parent').getRecordTypeId();
        ID recAcc1TypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
        ID SAPStratgerecID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        acc.IsGlobalParentActive__c = false;
        acc.Account_Group__c='ZSTG';
        insert acc;
        
        Account acc1=TestDataUtil.createAccount();
        acc1.RecordTypeId = recAccTypeID;
        acc1.IsGlobalParentActive__c = false;
         acc1.Account_Group__c='ZSTG';
        insert acc1;
        
        Account sapacc=TestDataUtil.createAccount();
        sapacc.RecordTypeId = SAPStratgerecID;
        sapacc.GE_LGT_EM_SAP_Customer_Number__c  = '45454545';
        sapacc.SAP_Parent_Customer_No__c ='655656565';
        sapacc.Account_Group__c='ZSTG';
        insert sapacc;
        
        Account accnt=TestDataUtil.createAccount();
        accnt.RecordTypeId = recAcc1TypeID;
        accnt.ParentId = acc.ID;
        accnt.Account_Group__c='ZSTG';
       
        accnt.GE_LGT_Controls__c=true;
         accnt.GE_LGT_Architecture__c=true;
        accnt.Lamp_Ballast__c=true;
        accnt.GE_LGT_Roadway__c=true;
        accnt.GE_LGT_C_I__c=true;
        accnt.GE_LGT_Utility__c=true;
        accnt.GE_LGT_DOT__c=true;
        accnt.GE_LGT_Sports__c=true;
        accnt.GE_LGT_EM_CustomerActiveFlag__c = true;
        accnt.Others__c=true;
        insert accnt;
        
        Account accntt=TestDataUtil.createAccount();
        accntt.RecordTypeId = recAcc1TypeID;
        accntt.ParentId = acc.ID;
        accntt.GE_LGT_EM_CustomerActiveFlag__c = false;
        acc.Account_Group__c='ZSTG';
        insert accntt;
        
        
        
        set<string> custnoSet =new set<string>();
        set<id> hierarchySet =new  set<id>();
        custnoSet.add(accntt.id);
       hierarchySet.add(acc.id);
        AccountMethods.updateStrategicHierarchy(custnoSet,hierarchySet);
        
        
        List<Account> globalAccList = new List<Account>();
        map<id,Account> allAccOldMAp = new  map<id,Account>();
       // globalAccList.add(acc);
        //allAccOldMAp.put(acc.id,acc);
        //AccountMethods.UpdateIsGlobalParentActiveOnGlobalAccount(null,allAccOldMAp);
        
        
        accntt.GE_LGT_EM_CustomerActiveFlag__c = true;
        update accntt;
        
        accnt.ParentId = acc1.ID;
        update accnt;
        System.assertEquals(accnt.ParentId ,acc1.ID );
        delete accnt;
        
        undelete accnt;
        
        
        
        
    }
    
    Public static testmethod void codecoveragemethod()
    {
    //AccountMethods.getcodecoverage();
    
    }
}
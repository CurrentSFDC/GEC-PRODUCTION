@isTest
public class OpportunityKeyPlayerTriggerhelper_Test 
{
    static testmethod void validateAllianceISVPartnerAccountName_Positive()
    {   
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('OpportunityTrigger').isActive__c=true;
        insert triggerSwitches.values();

        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        ID recAccEndUserTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        Account acc=TestDataUtil.createAccount();
        acc.Name='Alliance account';
        acc.RecordTypeId=recAccTypeID;
        acc.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        insert acc;
        
        Account accE=TestDataUtil.createAccount();
        accE.Name='Test account';
        accE.RecordTypeId=recAccEndUserTypeID;
        insert accE;
        
        ID recOPPTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        Opportunity opp = TestDataUtil.createOpportunity(accE); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = accE.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';  
        insert opp;
        system.debug('Created date' +opp.CreatedDate);
        System.debug('Decision date' +opp.PO_Receipt_Date__c);
        
        CDT_Opportunity_Key_Player__c okpVar = new CDT_Opportunity_Key_Player__c();
        okpVar.Account__c=acc.id;
        okpVar.CDT_Opportunity_Name__c=opp.id;
        
        Test.startTest();
        
        insert okpVar;
        
        opportunity Parent = [select id ,Alliance_ISV_Partner_Account_Name__c, Intelligent_Environments_Segment__c, RecordTypeId from Opportunity where id=:okpVar.CDT_Opportunity_Name__c];
        Account parentAccount = [Select id, Name, Alliance_Partner_Type_Primary__c from Account where Id=:okpVar.Account__c];
        
        system.assertEquals(Parent.Alliance_ISV_Partner_Account_Name__c, 'Alliance account');
        system.assertEquals(Parent.Intelligent_Environments_Segment__c, 'ISV Productivity Segment');
        system.assertEquals(Parent.RecordTypeId, recOPPTypeID);
        system.assertEquals(parentAccount.Alliance_Partner_Type_Primary__c, 'Independent Software Vendor');
        
        Test.stopTest();
    }
    static testmethod void validateAllianceISVPartnerAccountName_Negative()
    {   
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('OpportunityTrigger').isActive__c=true;
        insert triggerSwitches.values();
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        ID recAccEndUserTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.Name='Alliance account';
        acc.RecordTypeId=recAccEndUserTypeID;
        acc.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        insert acc;
        
        Account accE=TestDataUtil.createAccount();
        accE.Name='Test account';
        accE.RecordTypeId=recAccTypeID;
        accE.Alliance_Partner_Type_Primary__c ='Solution Provider';
        insert accE;
        
        ID recOPPTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';      
        insert opp;
        system.debug('Created date' +opp.CreatedDate);
        System.debug('Decision date' +opp.PO_Receipt_Date__c);

        CDT_Opportunity_Key_Player__c okpVar = new CDT_Opportunity_Key_Player__c();
        okpVar.Account__c=accE.id;
        okpVar.CDT_Opportunity_Name__c=opp.id;
        
        Test.startTest();
        
        insert okpVar;
        
        opportunity Parent = [select id ,Alliance_ISV_Partner_Account_Name__c from Opportunity where id=:okpVar.CDT_Opportunity_Name__c];
        
        system.assertNotEquals(Parent.Alliance_ISV_Partner_Account_Name__c, 'Independent Software Vendor');
        
        Test.stopTest();
    }
    static testmethod void opportunitykeyplayermethodToDelete()
    {   
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('OpportunityTrigger').isActive__c=true;
        insert triggerSwitches.values();

        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        ID recAccEndUserTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.Name='Alliance accounttest';
        acc.RecordTypeId=recAccTypeID;
        acc.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        insert acc;
        
        Account accE=TestDataUtil.createAccount();
        accE.Name='Test account';
        accE.RecordTypeId=recAccEndUserTypeID;
        insert accE;
        

        ID recOPPTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();

        Opportunity opp = TestDataUtil.createOpportunity(acc); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = accE.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';      
        insert opp;
        system.debug('Created date' +opp.CreatedDate);
        System.debug('Decision date' +opp.PO_Receipt_Date__c);

        CDT_Opportunity_Key_Player__c okpVar = new CDT_Opportunity_Key_Player__c();
        okpVar.Account__c=acc.id;
        okpVar.CDT_Opportunity_Name__c=opp.id;
        
        Test.startTest();
        insert okpVar;  
        delete okpVar;
        opportunity Parent = [select id ,Alliance_ISV_Partner_Account_Name__c from Opportunity where id=:okpVar.CDT_Opportunity_Name__c];
        system.assertEquals(Parent.Alliance_ISV_Partner_Account_Name__c, null);
        Test.stopTest();
    }
}
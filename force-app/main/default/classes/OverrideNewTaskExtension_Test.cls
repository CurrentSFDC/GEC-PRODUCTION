@isTest
public class OverrideNewTaskExtension_Test 
{
    static testmethod void testPrePopulateValues()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
       
       
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        
        
        insert triggerSwitches.values();
        TriggerSwitch__c taskT=new TriggerSwitch__c(name='TaskTrigger',isActive__c=true);
        insert taskT;
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'Europe',true);
        
       
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
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');// changed on 20 Oct 20
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';      
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);
        
        TriggerSwitch__c triSwitch=new TriggerSwitch__c(Name='GE_LGT_Project_Triggers',isActive__c=True);
        insert triSwitch;
        
        ID reqRecTypeID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
        
        Task task=new Task(RecordTypeID=reqRecTypeID,subject='Test');
        task.status = 'Not Started';
        task.Whatid=opp.id;
        insert task;
        ApexPages.currentPage().getParameters().put('RecordType',reqRecTypeID);
        ApexPages.currentPage().getParameters().put('retURL','Test');
        ApexPages.currentPage().getParameters().put('what_id','opp.id');
        ApexPages.currentPage().getParameters().put('who_id','u2.id');
        ApexPages.currentPage().getParameters().put('tsk1','joshua+Bates'); // new Contract task owner
        ApexPages.currentPage().getParameters().put('tsk12','u2.id');
        ApexPages.currentPage().getParameters().put('email','joshua.bates1@ge.com');
        OverrideNewTaskExtension taskExt=new OverrideNewTaskExtension(NULL);
        taskExt.prepopulateValues();
    }
    
     static testmethod void testPrePopulateValues1()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
       
       
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        
        
        insert triggerSwitches.values();
        TriggerSwitch__c taskT=new TriggerSwitch__c(name='TaskTrigger',isActive__c=true);
        insert taskT;
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'Europe',true);
        
       
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
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';      
        insert opp;
        system.assertEquals('Testoppty', opp.Name);
        system.assertEquals('S1 Consult', opp.StageName);
        system.assertEquals(date.parse('3/10/2099'), opp.PO_Receipt_Date__c);
        
        TriggerSwitch__c triSwitch=new TriggerSwitch__c(Name='GE_LGT_Project_Triggers',isActive__c=True);
        insert triSwitch;
        
        ID reqRecTypeID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE Request Task').getRecordTypeId();
        
        Task task=new Task(RecordTypeID=reqRecTypeID,subject='Test');
        task.status = 'Not Started';
        task.Whatid=opp.id;
        insert task;
        ApexPages.currentPage().getParameters().put('RecordType',reqRecTypeID);
        ApexPages.currentPage().getParameters().put('retURL','Test');
        ApexPages.currentPage().getParameters().put('what_id','opp.id');
        ApexPages.currentPage().getParameters().put('who_id','u2.id');
        ApexPages.currentPage().getParameters().put('tsk1','joshua+Bates'); // new Contract task owner
        ApexPages.currentPage().getParameters().put('tsk12','u2.id');
        ApexPages.currentPage().getParameters().put('email','joshua.bates1@ge.com');
        OverrideNewTaskExtension taskExt=new OverrideNewTaskExtension(NULL);
        taskExt.prepopulateValues();
    }
}
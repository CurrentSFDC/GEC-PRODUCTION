@isTest
public class GE_LGT_Project_Triggers_Test
{
    static testMethod void checkTaskPositiveCase()
    {

        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('OpportunityTrigger').isActive__c=true;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        Id recOppTypeIDStdAdvance = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.recordtypeid=recOppTypeIDStdAdvance;
        opp.Name = 'Test Oppty Test Class - 3';
        opp.StageName = 'S1 Consult';
        opp.Type='Standard';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Distribution_Channel__c ='No';
        opp.Going_through_agent__c ='No';
        opp.CloseDate = date.parse('3/10/2050');
        opp.GE_LGT_SIMPLESALES__c='';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = date.parse('4/10/2050');
        opp.GE_LGT_Expected_Ship_Date__c = date.parse('4/11/2050');
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v1';
        insert opp;  
        Test.StartTest();
       try{
         insert opp;
       }catch(Exception ext){
       
          system.debug('Exception while creating oppty :::'+ext);    
       }
     
     
     Id recTypeIDTaskAssignment = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE Assignment Task').getRecordTypeId();
     system.debug('recTypeIDTaskAssignment  :::: '+recTypeIDTaskAssignment);

     //////////////////////////////
     Task t = new task();
     try{   
          t.RecordTypeId = recTypeIDTaskAssignment ;
          t.GE_LGT_Task_type__c = 'Design';
          t.status = 'Not Started';        
          t.whatid = opp.id; 
          t.Sales_AE_Requestor__c='005i0000002gTrg'; //Murugan ID
          t.subject='AE Assignment Task';
        
          t.Priority='Normal';
       
          t.ActivityDate=System.Today()+8;
          Insert t;
      
      }Catch(Exception exc1){
        Boolean expectedExceptionThrown =  exc1.getMessage().contains('The Due Date on task cannot be within 7 days') ? true: false;
        System.AssertEquals(expectedExceptionThrown, false);
        system.debug('Exception while creating task ::'+exc1);   
      }
     
      try{
         t.Status='Completed';
         update t;
      }Catch(Exception exc2){          
        system.debug('Exception updating task ::: '+exc2);
      } 
     
     
     Test.StopTest();
      
      try{
         t.ActivityDate=System.Today()+2;
         update t;
      }Catch(Exception ee){          
        Boolean expectedExceptionThrown1 =  ee.getMessage().contains('The Due Date on task cannot be within 7 days') ? true: false;
        //System.AssertEquals(expectedExceptionThrown1, true);
      }     
    }
}
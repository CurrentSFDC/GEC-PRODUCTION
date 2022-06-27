/*
Name - AttachmentTriggerHelper_Test
Created By - Shyam Prasad Nayakula
Purpose - Test class of AttachmentTriggerHelper
Date - June 2017
*/
@isTest
public class AttachmentTriggerHelper_Test 
{   
    /*
    * Author : Shyam Prasad Nayakula
    * Date : June - 2017
    * Test method for checkForPilotDoc()
    */
    static testMethod void testCheckForPilotDoc()
    {
      
       
       TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
         insert OSRtriggerSwitch;
          Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
          triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
          triggerSwitches.get('OrderTrigger').isActive__c=true;
          triggerSwitches.get('AccountTrigger').isActive__c=true;
          insert  triggerSwitches.values();
       
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        insert opp;
        
        Test.startTest();
        
        ID recordOSRTypeId = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Digital Pilot Request').getRecordTypeId();
        Opportunity_Support_Request__c osr = TestDataUtil.createOSR();
        osr.Opportunity_Name__c=opp.id;
        osr.New_Customer__c='Yes';
        osr.Status__c='Not Submitted';
        osr.recordTypeID = recordOSRTypeId;
        insert osr;
        
        Attachment att = TestDataUtil.createAttachment('Test',Blob.valueOf('Test Data1234'),osr.ID);
        insert att;
        
        Opportunity_Support_Request__c osrRetrieved = [SELECT ID,Is_Pilot_Outcome_Map_Added__c FROM Opportunity_Support_Request__c WHERE ID=:osr.ID];
        System.assertEquals(TRUE,osrRetrieved.Is_Pilot_Outcome_Map_Added__c);
        
        delete att;
        
        Opportunity_Support_Request__c osrRetrieved1 = [SELECT ID,Is_Pilot_Outcome_Map_Added__c FROM Opportunity_Support_Request__c WHERE ID=:osr.ID];
        System.assertEquals(FALSE,osrRetrieved1.Is_Pilot_Outcome_Map_Added__c);
       
        Test.stopTest();
    }
    
    static testMethod void testUpdateParent()
    {
        /*TriggerSwitch__c caseSwitch=TestDataUtil.createTriggerSwitch('CaseTrigger',true);
        insert caseSwitch;*/
        
        TriggerSwitch__c  caseTrig = new TriggerSwitch__c();
        caseTrig.Name='CaseTrigger';
        caseTrig.TriggerName__c = 'CaseTrigger';
        caseTrig.isActive__c = true;
        insert caseTrig;
        
        TriggerSwitch__c taskTrig = new TriggerSwitch__c();
        taskTrig.Name='TaskTrigger';
        taskTrig.TriggerName__c = 'TaskTrigger';
        taskTrig.isActive__c = true;
        insert taskTrig;
        
        Id Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
        User usr = [select id from User where Id= :UserInfo.getUserID()];
        case newCase = new case(subject='test');
        newCase.RecordTypeId = Lighting_RecordType;
        newCase.Origin ='eLight - Daintree Request';
        newCase.OwnerId = usr.id;
        insert newCase;
        EmailMessage newIncomingMail = new EmailMessage();
        newIncomingMail.FromAddress = 'LDRReply@ge.com';
        newIncomingMail.TextBody = '@@firstName::Shared';
        newIncomingMail.Subject = 'test for LDR mail; Case : ref:oldCase';
        newIncomingMail.ParentId = newCase.Id;
        newIncomingMail.Incoming = true;
        insert newIncomingMail;
        Attachment att = TestDataUtil.createAttachment('Test',Blob.valueOf('Test Data1234'),newIncomingMail.ID);
        insert att;
        List<Attachment> newAttachments = [Select Id, Name from Attachment where Name = :'Test' and ParentId =:newCase.Id];
        System.assertEquals(1, newAttachments.size());
    }
     private static testMethod void addAttachmentToParent() {  
        TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
        insert OSRtriggerSwitch;
          Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
          
          triggerSwitches.get('OrderTrigger').isActive__c=true;
          triggerSwitches.get('AccountTrigger').isActive__c=true;
          insert  triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc1 = TestDataUtil.createAccount();
        insert acc1;
        
        
        ID recFRequestTypeID = Schema.SObjectType.Fund_Request__c.getRecordTypeInfosByName().get('Marketing Fund').getRecordTypeId();
        
        Fund_Request__c fr_obj = TestDataUtil.createFundRequest(acc1);
        fr_obj.RecordTypeId = recFRequestTypeID;
        fr_obj.Approval_Status__c='Not Submitted';       
        fr_obj.Fund_Type__c='Marketing Funds';
            insert fr_obj;   
        Fund_Request__c testfr1 =[select id,Approval_Status__c from Fund_Request__c  where id=:fr_obj.id limit 1];
        system.assertEquals(testfr1.Approval_Status__c,'Not Submitted');
        Blob b = Blob.valueOf('Test Data');   
        
        Attachment attachment = TestDataUtil.createAttachment('Test Attachment for Parent',b,fr_obj.id);   
         
        
        insert(attachment);  
         Fund_Request__c testfr =[select id,Has_Attachments__c from Fund_Request__c  where id=:fr_obj.id limit 1];
         system.assertEquals(testfr.Has_Attachments__c,true);
    }  
}
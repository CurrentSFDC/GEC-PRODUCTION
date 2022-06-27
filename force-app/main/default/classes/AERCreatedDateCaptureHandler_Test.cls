/**
 * Test class for GE_LGT_EM_AssignCase trigger handler to update AER_CreatedDate field with the 
 * "CreatedDate" of RecordType AE Request Task of the same Opportunity.
 * Created By: Aditya Ghadigaonkar
 * Created Date: 8/8/2016  
 */

@isTest
public class AERCreatedDateCaptureHandler_Test {

    
    static testMethod void validatAERCreatedDate() {
        TriggerSwitch__c taskT=new TriggerSwitch__c(name='TaskTrigger',isActive__c=true);
        insert taskT;
    ID accRecTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
    ID oppRecTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    //ID aeRequestRecTypeID = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name='AE Request Task' LIMIT 1].Id;
    //ID aeAssignmentRecTypeID = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name='AE Assignment Task' LIMIT 1].Id;
    ID aeRequestRecTypeID = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name='SE Request Task' LIMIT 1].Id;
    ID aeAssignmentRecTypeID = [SELECT Id,Name FROM RecordType WHERE SobjectType='Task' and Name='SE Assignment Task' LIMIT 1].Id;
    ID userID = UserInfo.getUserID();
    Account acc;
    Opportunity oppr;
    Task aeRequestTask;
    Task aeAssignmentTask;
    List<Task> aeAssignmentTaskList = new List<Task>();
    AERCreatedDateCaptureHandler aerHandler = new AERCreatedDateCaptureHandler();
    list<TriggerSwitch__c> triggerswitches=TestDataUtil.insertTriggerSwitches();
        insert triggerswitches;
        //Creating Account
        acc = TestDataUtil.createAccount();
        acc.RecordTypeId = accRecTypeID;
        acc.GE_LGT_Vertical__c = 'Retail';
        insert acc;
        
        //Creating Opportunity
        oppr =TestDataUtil.createOpportunity(acc);
        oppr.RecordTypeId = oppRecTypeID;
        insert oppr;
        
        //Creating AER Task
        aeRequestTask = TestDataUtil.createtask();
        aeRequestTask.RecordTypeId = aeRequestRecTypeID;
        aeRequestTask.OwnerId = userID;
        aeRequestTask.WhatId = oppr.Id;
        aeRequestTask.Priority = 'Normal';
        aeRequestTask.Status = 'Open';
        aeRequestTask.AE_Task_Type__c = 'Evaluate';
        insert aeRequestTask;
        
        //Creating AEA Task
      
            aeAssignmentTask= TestDataUtil.createtask();
            aeAssignmentTask.RecordTypeId = aeAssignmentRecTypeID;
            aeAssignmentTask.OwnerId = userID;
            aeAssignmentTask.Sales_AE_Requestor__c = userID;
            aeAssignmentTask.WhatId = oppr.Id;
            aeAssignmentTask.Priority = 'Normal';
            aeAssignmentTask.Status = 'Open';
            aeAssignmentTask.AE_Task_Type__c = 'Evaluate';
            insert aeAssignmentTask;
            aeAssignmentTaskList.add(aeAssignmentTask);
        
        aerHandler.CaptureCD(aeAssignmentTaskList);
        Task tsk = [Select CreatedDate from Task where WhatId =: oppr.Id and RecordTypeId =: aeRequestRecTypeID Limit 1];
        Task aeaTask = [Select AER_CreatedDate__c from Task where WhatId =: oppr.Id and RecordTypeId =: aeAssignmentRecTypeID Limit 1];
      
            System.assertEquals(tsk.CreatedDate,aeaTask.AER_CreatedDate__c);
       
    }

}
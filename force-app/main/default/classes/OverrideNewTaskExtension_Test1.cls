@isTest
public class OverrideNewTaskExtension_Test1 
{
    static testmethod void createTaskTest1()
    {
        TriggerSwitch__c triSwitch=new TriggerSwitch__c(Name='GE_LGT_Project_Triggers',isActive__c=True);
        insert triSwitch;
        ID reqRecTypeID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('TaskTrigger',true);
        insert triggerswitch;
        //ID AE_AssignRecID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('AE Assignment Task').getRecordTypeId();
        ID AE_AssignRecID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
       System.debug('assignid'  + AE_AssignRecID);
       
        Task task=new Task(RecordTypeID=reqRecTypeID,subject='Test');
        task.Sales_AE_Requestor__c=userinfo.getuserId();
        task.status = 'Not Started';  
       insert task;
       
        Task task1=new Task(RecordTypeID=AE_AssignRecID, subject='Call');
        task1.status = 'Not Started'; 
        task1.Sales_AE_Requestor__c=userinfo.getuserId();
       insert task1;
       task1.status ='Completed';
       
       update task1;
                
      
    }
}
/***********************************************************************************************
Trigger Name    : GE_LGT_Project_Triggers
*   Date            : 01/11/2017
*   Author          : MahindraSatyam
*   Object          : Task
*   Purpose         : For Assign all tasks with Task Type = "Design" to Jim Wasko and,
*                     Task Completion Date should be captured upon status change to "Complete" 
*   Change History  :
*   Date                      Developer              Reason 
*   --------------------      -------------------    -------------------------
*  01/11/2017                  Satish k               Trigger Consolidation.                 
*************************************************************************************************/
trigger TaskTrigger on Task (before insert, before update, after insert,after update,after delete) {

    if(TriggerSwitch__c.getInstance('TaskTrigger').isActive__c)
    {
        //Tasktriggerhelper Taskhelper = new Tasktriggerhelper();
        TaskTriggerMethods taskmethod = new TaskTriggerMethods();

            // before events
            if(trigger.isBefore){
                //before Insert event
                if(trigger.isInsert){
                    taskmethod.methodsToInvokeOnBeforeInsert(Trigger.New);
                }
                // before Update event
                if(trigger.isUpdate){
                    taskmethod.methodsToInvokeOnBeforeUpdate(Trigger.New);
                    
                }
                // before Delete event
                if(trigger.isDelete){
                    taskmethod.methodsToInvokeOnBeforeDelete(Trigger.Old);
                }
                
            }
            // after events
            if(trigger.isAfter){
                // after Insert event
                if(trigger.isInsert){
                   taskmethod.methodsToInvokeOnAfterInsert(Trigger.New);
                }
                // after update event
                if(trigger.isUpdate){
                    taskmethod.methodsToInvokeOnAfterUpdate(Trigger.New);
                }
                // after Delete event
                if(trigger.isDelete){
                    taskmethod.methodsToInvokeOnAfterDelete(Trigger.Old);
                }
            }
        }
    }
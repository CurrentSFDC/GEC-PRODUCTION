/***********************************************************************************************
*   Trigger Name    : GE_LGT_Project_Triggers
*   Date            : 05/28/2013
*   Author          : MahindraSatyam
*   Object          : Task
*   Purpose         : For Assign all tasks with Task Type = "Design" to Jim Wasko and,
*                     Task Completion Date should be captured upon status change to "Complete" 
*   Change History  :
*   Date                      Developer              Reason 
*   --------------------      -------------------    -------------------------
*                                         
**************************************************************************************************/
trigger GE_LGT_Project_Triggers on Task ( before insert, before update ) {
    if(TriggerSwitch__c.getInstance('GE_LGT_Project_Triggers').isActive__c)
    {
        Tasktriggerhelper Taskhelper = new Tasktriggerhelper();
            if(trigger.isInsert || trigger.isUpdate)
            {
                  Taskhelper.updateTaskfields(trigger.new);
            }
    }       
}
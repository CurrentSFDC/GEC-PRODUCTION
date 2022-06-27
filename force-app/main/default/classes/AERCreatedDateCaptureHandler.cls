/**
* GE_LGT_EM_AssignCase trigger handler to update AER_CreatedDate field with the 
* CreatedDate of RecordType AE Request Task of the same Opportunity.
* Created By: Aditya Ghadigaonkar
* Created Date: 7/20/2016  
*/

public class AERCreatedDateCaptureHandler {
    private static final String AERequestTask = 'SE Request Task';
    List<Task> taskAERList;
    List<Id> oppIdList;
    map<Id,Datetime> taskOppMap;
    
    //Constructor
    public AERCreatedDateCaptureHandler(){
        taskOppMap = new map<Id,Datetime>();
        oppIdList = new List<Id>();
        
    }
    
    //Method to update AER_CreatedDate field
    public void CaptureCD(List<Task> taskListNew){
        for(Task oppTask: taskListNew){
            oppIdList.add(oppTask.WhatId);
        }
        //Task records with Record type SE Request Task and Opportunity Ids as that in trigger.new        
        taskAERList = [Select WhatId,CreatedDate from Task 
                       where RecordType.Name =: AERequestTask and WhatId In: oppIdList];
        for (Task task: taskAERList ){
            taskOppMap.put(task.WhatId, task.CreatedDate);
        }
        for(Task task: taskListNew){
            if(taskOppMap.containsKey(task.WhatId)){
                task.AER_CreatedDate__c   = taskOppMap.get(task.WhatId);  
            }
        }
    }//End of CaptureCD
}
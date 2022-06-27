/***********************************************************************************************
*   Class Name      : TaskTriggerMethods
*   Date            : 11/11/2017
*   Author          : Satish Babu
*   Object          : Task
*   Purpose         : These methods fire on Task.
*   Test Class      : TaskTriggertHelperTest
**************************************************************************************************/
public class TaskTriggerMethods {
    
    
    //Contain methods to invoke "before insert" Event On Task
    public  void methodsToInvokeOnBeforeInsert(List<Task> NewTaskList){
        Tasktriggerhelper TaskHelper = new Tasktriggerhelper();
        TaskHelper.InsertTaskfields (NewTaskList);
        TaskHelper.InsertCaseUponTaskValidation(NewTaskList);//sepcifically only in before insert.
         TaskHelper.taskDefaultAssignTo(NewTaskList);
         
        
    }
    //Contain methods to invoke "before update" Event On Task
    public void methodsToInvokeOnBeforeUpdate(List<Task> NewTaskList){
        Tasktriggerhelper TaskHelper = new Tasktriggerhelper();
        TaskHelper.updateTaskfields(NewTaskList);
       
    }
    //Contain methods to invoke "Before delete" Event On Task
    public  void methodsToInvokeOnBeforeDelete(List<Task> OldTaskList){
        
    }
    //Contain methods to invoke "after insert" Event On Task
    public  void methodsToInvokeOnAfterInsert(List<Task> NewTaskList){
        Tasktriggerhelper TaskHelper = new Tasktriggerhelper();
        TaskHelper.InsertTask(NewTaskList);
        
        
    }
    //Contain methods to invoke "after update" Event On Task
    public  void methodsToInvokeOnAfterUpdate(List<Task> NewTaskList){
        Tasktriggerhelper TaskHelper = new Tasktriggerhelper();
        TaskHelper.UpdateTask(NewTaskList);
        
    }
    
    
    //Contain methods to invoke "after delete" Event On Task
    public void methodsToInvokeOnAfterDelete(list<task> OldTaskList){
        Tasktriggerhelper TaskHelper = new Tasktriggerhelper();
        TaskHelper.DeleteTask(OldTaskList);
        
    }
    
}
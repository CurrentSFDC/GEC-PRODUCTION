trigger AccountSetupTrigger on Distributor__c (before insert, before update, after insert, after update) 
{
 //.below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    if(!AdminOverrideUser.Switch_Off_Trigger__c) {
    
    AccountSetupTriggerHelper  Acctsetuphandler = new AccountSetupTriggerHelper ();
        //before events
        if(Trigger.isBefore){                        
     
             // before Insert event
            if((trigger.isInsert) ||(trigger.isUpdate)){
                     Acctsetuphandler.showErrorMessages(trigger.new);
                 
                  }
              
             }
    else
    {
        if(Trigger.isUpdate)
        {
            Acctsetuphandler.updateApprovalHistory(trigger.new,trigger.oldMap);
            Acctsetuphandler.showErrorMessagesAfterUpdate(trigger.new);
             Acctsetuphandler.autoSubmitToProcess(trigger.new,trigger.oldMap);
             
            
        }
    }
   }
}
/***********************************************************************************************
*   Trigger Name    : SalesConcessionTrigger 
*   Date            : 
*   Author          : 
*   Object          : Sales_Concession_Request__c 
*   Helper Class    : SalesConcessionAutoCaseCreationhelper,UpdateApprover
*   Test Class      : NewApproverTest,GE_LGT_SalesConcession_Test
**************************************************************************************************/

trigger SalesConcessionTrigger on Sales_Concession_Request__c (before insert,before update, after update,after insert) {
    
    //below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    System.debug('AdminOverrideUser: '+ AdminOverrideUser + 'Switch Status: '+ AdminOverrideUser.Switch_Off_Trigger__c);
    if(AdminOverrideUser.Switch_Off_Trigger__c == False) {
        TriggerSwitch__c SalesConcessionSetting = TriggerSwitch__c.getInstance('SalesConcessionTrigger');
        if(!(SalesConcessionSetting != NULL && SalesConcessionSetting.isActive__c == False)){
    
    
            If((Trigger.isInsert||Trigger.isUpdate) && Trigger.isbefore){
              UpdateApprover.ChangeApprover();
             } 
        
            If((Trigger.isInsert||Trigger.isUpdate) && Trigger.isAfter){
              SalesConcessionAutoCaseCreationhelper.AutoCaseCreation(trigger.new);
             }
        }
    }
}
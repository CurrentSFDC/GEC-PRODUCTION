trigger AccountTrigger on Account (before insert, before update, after insert, after update, after delete,after undelete) {
    
    //below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    System.debug('AdminOverrideUser: '+ AdminOverrideUser + 'Switch Status: '+ AdminOverrideUser.Switch_Off_Trigger__c);
    if(AdminOverrideUser.Switch_Off_Trigger__c == false) {
        TriggerSwitch__c caseSetting = TriggerSwitch__c.getInstance('AccountTrigger');
        if(!(caseSetting != NULL && caseSetting.isActive__c == false)){
    
            Map<id, Account> oldAccMap, newAccMap;
             
            
            List<Account> accList = trigger.isDelete ? trigger.old : trigger.new ;
        
            if ( trigger.isInsert ){
                newAccMap = trigger.newMap;
            }
        
            if ( trigger.isUpdate ){
                oldAccMap = trigger.oldMap;
                newAccMap = trigger.newMap;
            }
            
            if ( trigger.isDelete ){
                oldAccMap = trigger.oldMap;
            }
            
            if ( trigger.isBefore ){
                AccountTriggerFactory.beforeIntegration(oldAccMap, newAccMap, accList);
            }
            
            if ( trigger.isAfter ){
                AccountTriggerFactory.afterIntegration(oldAccMap, newAccMap, accList);
                  AccountMethods.UpdateIsGlobalParentActiveOnGlobalAccount(accList,oldAccMap);
            }
        
            if (Trigger.isInsert && Trigger.isAfter) {
                new AccountSharingController().shareChildAccountsFromAccountTrigger(Trigger.new);
            }
            if (Trigger.isUpdate && Trigger.isAfter) {
                new AccountSharingController().shareChildAccountsFromAccountTrigger(Trigger.new);
            }
        }
      }
}
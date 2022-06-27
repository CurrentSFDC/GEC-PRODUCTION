trigger eMailMessageTrigger on EmailMessage (after insert) {
    
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    System.debug('AdminOverrideUser: '+ AdminOverrideUser + 'Switch Status: '+ AdminOverrideUser.Switch_Off_Trigger__c);
    if(AdminOverrideUser.Switch_Off_Trigger__c == False) {
        TriggerSwitch__c EmailTrigger = TriggerSwitch__c.getInstance('eMailMessageTrigger');
        if(!(EmailTrigger != NULL && EmailTrigger.isActive__c == False)){
    
	eMailMessageMethods.afterInsert(Trigger.new, Trigger.newMap);
        }
    }
}
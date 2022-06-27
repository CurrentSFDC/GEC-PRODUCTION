/*
Trigger Name - AssetTrigger
Author - Neel (TechMahindra)
Date - Oct-2016
Purpose - To handle incoming asseets from SAP.
        This will attach assets to respective accounts based on field 'Account_SAP_UniqueId__c '
Imp Points:
1. Custom Setting 'AdminOverride' has been used in this trigger. 
    If the current user exists in CustomSetting then trigger wont fire. 
    However this trigger will work for all other users(business).
2. Custom Setting 'TriggerSwitch' can be used to switch off this trigger for all users.
*/

trigger AssetTrigger on Asset (before insert, before Update) {
    //Below CucstomSetting can swith off this trigger if the current user is added in CS 'AdminOverride__c'
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    system.debug('***'+AdminOverrideUser.Switch_Off_Trigger__c);
      if(AdminOverrideUser.Switch_Off_Trigger__c){
        
        if(TriggerSwitch__c.getInstance('AssetTrigger').isActive__c){
           if(Trigger.isInsert && Trigger.isBefore){
              AssetTriggerHelper.updateAssetDetails(trigger.new);
           }
        }
      
      } //AdminOverride if loop closes
}
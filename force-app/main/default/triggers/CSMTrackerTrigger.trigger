/*
Trigger Name - CSMTrackerTrigger
Author - Dharmendra Oswal
Date - Aug-2018
Purpose - To handle business logic for Daintree Licensing
Imp Points:
1. Custom Setting 'AdminOverride' has been used in this trigger. 
    If the current user exists in CustomSetting then trigger wont fire. 
    However this trigger will work for all other users(business).
2. Custom Setting 'TriggerSwitch' can be used to switch off this trigger for all users.

Revision History(Date, Version, author, comments):
*******************************************************************
06 SEP 2018, Version 1.0, Dharmendra Oswal, Initial Version 
*/

trigger CSMTrackerTrigger on Daintree_Order_Tracker__c (after Update) {
    //Below CucstomSetting can swith off this trigger if the current user is added in CS 'AdminOverride__c'
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
      if (!AdminOverrideUser.Switch_Off_Trigger__c)
      {
        TriggerSwitch__c checkSwitch = TriggerSwitch__c.getInstance('CSMTrackerTrigger');
        //Trigger is always active, unless the switch is explicitly set to False
        if (!(checkSwitch != NULL && checkSwitch.isActive__c == False))
        {          
           if (Trigger.isUpdate && Trigger.isAfter)
           {
             CSMTrackerTriggerHelper.processTrackers(trigger.old, trigger.new);
           }            
        }
      } //AdminOverride if loop closes
}
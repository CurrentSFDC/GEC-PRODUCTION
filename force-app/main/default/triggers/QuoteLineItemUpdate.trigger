/*
Name - QuoteLineItem
Test Class - QuoteLineItemUpdateHelper_Test
Author - Shyam Prasad Nayakula
Purpose - To update fields on QuoteLineItem
Date - May-2016
*/
trigger QuoteLineItemUpdate on QuoteLineItem (before insert,before update,before Delete) 
{
    // AdminOverride__c will let us prevent firing of trigger if we add a 
    // user name in custom setting 'AdminOverride__c'. This will be user specific
    
    if((Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) && Trigger.isBefore)
    {
        StaticVariables.unSyncQuoteFlag = FALSE;
    }
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    if(!AdminOverrideUser.Switch_Off_Trigger__c){
        
        if(TriggerSwitch__c.getInstance('QuoteLineItemUpdate').isActive__c)
        {
            QuoteLineItemUpdateHelper qlih=new QuoteLineItemUpdateHelper();
            
            if ( Trigger.isBefore && Trigger.isInsert ) {
                qlih.UpdateQuoteLineItems( Trigger.New );
            }
            
            if ( Trigger.isBefore && Trigger.isInsert ) {
                qlih.mapSKUFromOpptyLineItem( Trigger.New );
            }
            
            //Below call will prevent deletion of QLI if oppty stage is S3 or above  
            if ( Trigger.isBefore && Trigger.isDelete ){
                qlih.preventDeleteQLI( Trigger.oldMap, Trigger.old );
            }
            
            
        }
    } // Admin Override closes
}
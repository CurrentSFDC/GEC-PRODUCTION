/*
* Modified by By -- Shyam -Tech Mahindra
* Added code to insert the Opportunity Products that are inserted,modified and deleted in OpportunityProductsDeleted Object.
*/
trigger GE_LGT_EM_OppProductHistory on OpportunityLineItem (before insert,before update,after insert,after update,before delete,after delete) 
{
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    if(!AdminOverrideUser.Switch_Off_Trigger__c){
        if(TriggerSwitch__c.getInstance('GE_LGT_EM_OppProductHistory').isActive__c)
        {
            if(Trigger.isBefore)
            {
                if( Trigger.isInsert || trigger.isupdate)
                {
                    OptyLineItemTriggerHelper.populateServicedate(Trigger.new);
                }
                if( Trigger.isDelete)
                {
                    //GE_LGT_EM_OppProductHistory_Helper.insertOppProductHistory(Trigger.old,'Delete');
                }
            }
            if(Trigger.isAfter)
            {
                if(Trigger.isInsert)
                {
                    //GE_LGT_EM_OppProductHistory_Helper.insertOppProductHistory(Trigger.new,'Insert');
                    GE_LGT_EM_OppProductHistory_Helper.UpdateOppLedContent(Trigger.new);
                }
                else if(Trigger.isUpdate)
                {
                    //GE_LGT_EM_OppProductHistory_Helper.updateCheck(Trigger.old,Trigger.new,trigger.oldMap);
                    if(AvoidRecursiveTriggerHelper.oppLineItem)
                    {
                        AvoidRecursiveTriggerHelper.oppLineItem=False;
                        GE_LGT_EM_OppProductHistory_Helper.UpdateOppLedContent(Trigger.new);            
                    }
                }
                else if(Trigger.isDelete)
                {
                    GE_LGT_EM_OppProductHistory_Helper.UpdateOppLedContent(Trigger.old);
                }
            }
        }
        
    }
}
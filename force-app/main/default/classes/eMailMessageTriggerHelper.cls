/***********************************************************************************************
*   Class Name      : eMailMessageTriggerHelper 
*   Date            : 27/10/2017
*   Author          : Pavan Kumar
*   Object          : Case
*   Purpose         : These methods fire on Case.
*   Test Class      : eMailMessageTrigger_Test
**************************************************************************************************/

public class eMailMessageTriggerHelper {
  /***********************************************************************************************
  *   Method Name     : updateCaseDescription 
  *   Purpose         : This method is to Update case Description field if the email come as reply to any case.
  *            case Record type should be "GE_LGT_Design_Request", and reply should contain case threadId also
  *   Input           : using Trigger.new and trigger.newMap  
  *   Return          : N/A
  **************************************************************************************************/
    public static void updateCaseDescription(List<EmailMessage> newList, Map<Id, EmailMessage> newMap)
    {
        List<string> caseIds = new List<string>();
        for (EmailMessage each : newList)
        {
            Id caseId = each.ParentId;
           
            if (caseId != null && caseId.getSObjectType().getDescribe().getName() == 'Case' && each.Incoming)
            {
                caseIds.add(caseId);
            }
        }
        /*if (!caseIds.isEmpty())
        {*/
            Id Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
            Map<Id, Case> updatingCases = new Map<Id, Case>([Select Id, Description,RecordTypeId from Case where id in :caseIds ]);
            if (!updatingCases.isEmpty())
            {
                for (EmailMessage each : newList)
                {
                    Id caseId = each.ParentId;
                    string subject = each.Subject;
                  
                    if (caseId.getSObjectType().getDescribe().getName() == 'Case' && each.Incoming )
                    {
                        if(subject!='' && subject!=null){
                            boolean isReplyMail =  subject.contains('ref:');
                            if(isReplyMail && updatingCases.get(caseId).RecordTypeId==Lighting_RecordType){
                                updatingCases.get(caseId).Description = each.TextBody;
                                
                            }
                        }
                        else {
                            updatingCases.get(caseId).Description = each.FromAddress;
                        }
                        
                    }
                }
                update updatingCases.values();
            }
        //}
        
    }
}
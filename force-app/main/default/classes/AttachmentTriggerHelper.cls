/*
Name - AttachmentTriggerHelper
Test Class - AttachmentTriggerHelper_Test
Created By - Shyam Prasad Nayakula
Purpose - Helper class of AttachmentTrigger
Date - June 2017
*/
public class AttachmentTriggerHelper 
{
    /*
    * Author : Shyam Prasad Nayakula
    * Date : June - 2017
    * This method updates the checkbox Is_Pilot_Outcome_Map_Added__c in Opportunity_Support_Request__c 
    * when an attachment is added/deleted.
    */
    public static void checkForPilotDoc(List<Attachment> newAttachments)
    {
        Schema.DescribeSObjectResult describeTask = Opportunity_Support_Request__c.sObjectType.getDescribe();
        String attchmentKeyPrefix = describeTask.getKeyPrefix();
        Set<ID> oppSupRequestIDSet = new Set<ID>();
        for(Attachment attachVar:newAttachments)
        {
            if(String.valueOf(attachVar.ParentID).startsWith(attchmentKeyPrefix))
            {
                oppSupRequestIDSet.add(attachVar.ParentID);
            }
        }
        if(!oppSupRequestIDSet.isEmpty())
        {
            List<Opportunity_Support_Request__c> requestsToUpdate=new List<Opportunity_Support_Request__c>();
            for(Opportunity_Support_Request__c osrVar:[SELECT ID,(SELECT ID,Name FROM Attachments) 
                                                       FROM Opportunity_Support_Request__c
                                                       WHERE ID IN:oppSupRequestIDSet])
            {
                if(!osrVar.Attachments.isEmpty())
                {
                    Opportunity_Support_Request__c osrObj = new Opportunity_Support_Request__c();
                    osrObj.Is_Pilot_Outcome_Map_Added__c = TRUE;
                    osrObj.ID = osrVar.ID;
                    requestsToUpdate.add(osrObj);
                }
                else
                {
                    Opportunity_Support_Request__c osrObj = new Opportunity_Support_Request__c();
                    osrObj.Is_Pilot_Outcome_Map_Added__c = FALSE;
                    osrObj.ID = osrVar.ID;
                    requestsToUpdate.add(osrObj);
                }
            }
            if(!requestsToUpdate.isEmpty())
                update requestsToUpdate;
        }
    }
    
    /***********************************************************************************************
    *   Method Name     : updateParent 
    *   Purpose         : This method is to reparent if the case comes from emailMessage and 
    *                     that email Message is for Case, Case Record type should be "GE_LGT_Design_Request"
    *   Input           : using Trigger.new and trigger.newMap  
    *   Return          : N/A
    **************************************************************************************************/
    
    public static void updateParent(List<Attachment> newList, Map<Id, Attachment> newMap)
    {
        Schema.DescribeSObjectResult eMailDescribe = EmailMessage.sObjectType.getDescribe();
        String eMailKeyPrefix = eMailDescribe.getKeyPrefix();
        Schema.DescribeSObjectResult caseDescribe = Case.sObjectType.getDescribe();
        String caseKeyPrefix = caseDescribe.getKeyPrefix();
        List<string> emailIds = new List<string>();
        Map<string, string> emailAttachmentMap = new Map<String, String>();
        for(Attachment attachVar:newList)
        {
            if(String.valueOf(attachVar.ParentID).startsWith(eMailKeyPrefix))
            {
                emailIds.add(attachVar.ParentID);
                emailAttachmentMap.put(attachVar.Id, attachVar.ParentId);
            }
        }
        Map<Id, EmailMessage> messages = new Map<Id, EmailMessage>([Select Id, ParentId, Parent.RecordTypeId, Parent.Origin from EmailMessage where Id in : emailIds]);
        if(!messages.isEmpty())
        {
            Id Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
            Map<String, String> updatingParents = new Map<String, String>();
            for (Attachment each : newList)
            {
                if(emailAttachmentMap.containsKey(each.Id))
                {
                    string emailId = emailAttachmentMap.get(each.Id);
                    if (messages.containsKey(emailId))
                    {
                        EmailMessage eachMessage = messages.get(emailId);
                        if (String.valueOf(eachMessage.ParentId).startsWith(caseKeyPrefix))
                        {
                            if (eachMessage.parent.RecordTypeId == Lighting_RecordType)
                            {
                                updatingParents.put(each.Id, eachMessage.ParentId);
                            }
                        }
                    }
                }
            }
            if (!updatingParents.isEmpty())
            {
                List<Attachment> tobeDeleted= [select Body,ContentType,Description,Id,Name,ParentId from Attachment where id in :updatingParents.keySet()];
                List<Attachment> tobeInserted = new List<Attachment>();
                if (!tobeDeleted.isEmpty())
                {
                    for (Attachment each : tobeDeleted)
                    {
                        Attachment eachAttach = new Attachment(body =each.Body, ContentType= each.ContentType, name =each.Name, ParentId= updatingParents.get(each.Id));
                        tobeInserted.add(eachAttach);
                    }
                    insert tobeInserted;
                    delete tobeDeleted;
                }
            }
        }
    }
    /***********************************************************************************************
    *   Method Name     : Update_HasAttachment_OnFundRequest 
    *   Purpose         : This method is to update the has Attachment field on fundrequest object.
    *   Input           : using Trigger.new and trigger.newMap  
    *   Return          : N/A
    **************************************************************************************************/
    
    public static void updateHasAttachmentOnFundRequest (List<Attachment> newList, Map<Id, Attachment> newMap)
    {
    List<Id> frIds=new List<Id>();
    Schema.DescribeSObjectResult r = Fund_Request__c.SObjectType.getDescribe();
    string frPrifix=r.getKeyPrefix();
    for(Attachment att:newList){
     String myIdPrefix = String.valueOf(att.parentId).substring(0,3);
     if(frPrifix.equals(myIdPrefix)){
     frIds.add(att.parentId);
     }
    
    }
    if(frIds.size()>0){
    List<Fund_Request__c> FR_obj = [select id, Has_Attachments__c from Fund_Request__c where id IN: frIds];
    if(FR_obj.size()>0){
    for(Fund_Request__c fr:FR_obj ){
    fr.Has_Attachments__c =true;
    }
    update FR_obj;
    }
    }
    
    } 
}
trigger Update_HasAttachment_OnFundRequest on Attachment (after insert) {
  List<Fund_Request__c> FR_obj = [select id, Has_Attachments__c from Fund_Request__c where id =: Trigger.New[0].ParentId];
        if(FR_obj.size()>0){
        FR_obj[0].Has_Attachments__c = true;
        update FR_obj;
        }     
}
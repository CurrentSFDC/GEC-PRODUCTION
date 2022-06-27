global class InsertAttachment implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.InboundEnvelope envelope) {
                                                               Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
                                                               
                                                               try {
                                                                   
                                                                   JSON_Attachment__c parentRecord = [select ID from JSON_Attachment__c where name ='JSON File' order by createddate desc LIMIT 1];
                                                                   
                                                                   if(email.textAttachments != null)
                                                                   {
                                                                       
                                                                       for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments)
                                                                       {
                                                                           Attachment attachment = new Attachment();
                                                                           attachment.Name = tAttachment.fileName;
                                                                           attachment.Body = Blob.valueOf(tAttachment.body);
                                                                           attachment.ParentId = parentRecord.ID;
                                                                           insert attachment;
                                                                           //SlasifyInsertCategoryMapping.CategoryMapping();
                                                                           SalsifyMetadata.Salsify(attachment.Id);
                                                                           //System.debug('Attachment body : '+ tAttachment.body);
                                                                       }
                                                                       
                                                                   } 
                                                                   
                                                                   if(email.binaryAttachments != null)
                                                                   {
                                                                       for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                                                                           Attachment attachment = new Attachment();
                                                                           
                                                                           attachment.Name = bAttachment.fileName;
                                                                           attachment.Body = bAttachment.body;
                                                                           attachment.ParentId = parentRecord.ID;
                                                                           insert attachment;
                                                                           //SlasifyInsertCategoryMapping.CategoryMapping();
                                                                           SalsifyMetadata.Salsify(attachment.Id);
                                                                           // System.debug('Attachment body : '+ bAttachment.body);
                                                                       }
                                                                       
                                                                   }
                                                                   
                                                                   
                                                               } 
                                                               catch (Exception e) {
                                                                   result.success = false;
                                                                   result.message = 'Error : '+e.getMessage();
                                                                   messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                                                  // message.toAddresses = new String[] {'ravi.singh@gecurrent.com','sagar.suryawanshi@gecurrent.com'};
           															 message.toAddresses = new String[] {'salsify.support@gecurrent.com'};
                                                                   message.optOutPolicy = 'FILTER';
                                                                   message.subject = 'Processing of Salsify JSON Feed Email: JOB ABORTED!!!';
                                                                   message.plainTextBody = 'The following exception has occurred:' + e.getMessage();
                                                                   Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                                                                   Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
                                                                   
                                                               }
                                                               result.success = true;
                                                               return result;
                                                           }
    
}
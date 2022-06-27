global with sharing class CaseUtilities {
   // Class method to Transfer Email Attachments to Case.
   // Returns a string that indicates success or failure.
   webservice static String TransferAttachmentsToCase(String CaseId) {
     
     //Query for attachments that are already on the case
     List<Attachment> CaseAttachments = [Select Name From Attachment Where ParentId = :CaseId];
     set<string> AttachmentNames = new set<string>();
     
     for(Attachment CaseItems : CaseAttachments){
         AttachmentNames.add(CaseItems.Name);
     }    
     
      //Query for a list of the email attachments
    List<Attachment> EmailAttachments =
          [Select SystemModstamp, ParentId, Name, LastModifiedDate, LastModifiedById, IsPrivate, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, BodyLength, Body 
          FROM Attachment 
          WHERE ParentId IN (Select Id FROM EmailMessage Where ParentId = :CaseId)];
    
    //Attachment Lists for inserting and deleting
    List<Attachment> attachmentsToInsert = new List<Attachment>();
    List<Attachment> attachmentsToDelete = new List<Attachment>();

    Attachment tempAtt;
     
      // Loop through each Email and update Parent Id to CaseId as you go.
      for (Attachment item : EmailAttachments) {
      
              if(AttachmentNames.contains(item.Name))
              {
                     
              }else{
                  try {
                         tempAtt = item.clone(false,false);
             
                         tempAtt.parentId = CaseId;
             
                         attachmentsToInsert.add(tempAtt);
             
            
                     }catch(DMlException e){
                          System.debug('An unexpected error has occurred: ' + e.getMessage());
                     }
              }
         
      }
      
      // On success, try to insert cloned attachments with updated parentId
      // delete old attachments from  return a message to the calling program.
      if(attachmentsToInsert.isEmpty()){
           return 'No new attachments to transfer';
       }else{
           insert attachmentsToInsert;
           return 'Transfer Completed Successfully.';
       }
       
       
       
        
        
   }
}
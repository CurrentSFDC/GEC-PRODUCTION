global class GE_LGT_EM_UpdateEmailAttachment {

  @future(callout=true)
  Public static void UpdateAttachmentLink(Map<Id,Id> EmailCaseMap) {
  
    Map<string,string> RecrdIdMap=new Map<string,string>(); 
    List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]); 
    for(Recordtype rt:recrdlist){
        RecrdIdMap.put(rt.Name,rt.Id);      
    }
    System.debug('~:Before Record Type');
    Id ComplaintRecId = RecrdIdMap.get('EMEA Complaint');
    Id recordtID = RecrdIdMap.get('GE Lighting EMEA'); 
    System.debug('~:ComplaintRecId'+ComplaintRecId+'   recordtID'+recordtID);
    
      List<Attachment> CaseEmailAttachment = new List<Attachment>();
      Map<Id,String> AttachmentMap = new Map<Id,String>();
      list<Case> casesToUpdate = new list<Case>();
       System.debug('~:EmailCaseMap '+EmailCaseMap);
      CaseEmailAttachment = [Select Id,Parentid from Attachment where Parentid in: EmailCaseMap.keyset()];   
      
      if(CaseEmailAttachment.size()>0){        
        for(Attachment a:CaseEmailAttachment){
            if(EmailCaseMap.containskey(a.parentId)) {
                AttachmentMap.put(EmailCaseMap.get(a.parentId),URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + a.Id);                                       
            }               
         }                                     
      }
       System.debug('~:AttachmentMap '+AttachmentMap);
      casesToUpdate = [Select Id,GE_LGT_EM_Email_Attachment__c From Case Where Id in: EmailCaseMap.values() and (recordtypeid=: recordtID OR recordtypeid=:ComplaintRecId)];                   
      for(Case c: casesToUpdate){
      c.GE_LGT_EM_Email_Attachment__c=AttachmentMap.get(c.Id);          
      }
       System.debug('~:casesToUpdate '+ casesToUpdate);
      Update casesToUpdate;
       System.debug('~:after DML');
   }
}